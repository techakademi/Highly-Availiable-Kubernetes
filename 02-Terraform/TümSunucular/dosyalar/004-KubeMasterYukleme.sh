#!/bin/bash

# Bu skript ile, Ubuntu işletim sistemine yeni Kubernetes'in son sürümün yükleme işlemini gerçekleştirebilirsiniz.
echo
echo -------------------------------------------------------------------------------------
echo "Merhaba, Ben Ubuntu Sunucusuna Kubernetes'in MASTER node kuracak olan Droid'inim. :)"
echo -------------------------------------------------------------------------------------
sleep 2
echo

# Sunucu Version kontrol & görüntüleme
echo
echo -------------------------------------------------------------------------------------
echo "Sunucu Sürüm Kontrolünü yapıyorum."
echo -------------------------------------------------------------------------------------
sleep 2
echo
lsb_release -a
sleep 1

# Güncelleme İndex'ini güncelleme adımı
echo
echo -------------------------------------------------------------------------------------
echo "Güncelleme Index'ini Güncelliyorum."
echo -------------------------------------------------------------------------------------
sleep 2
echo
sudo apt update -y
sleep 1

# Güncellenecek paketlerin uygulanması
echo
echo -------------------------------------------------------------------------------------
echo "Güncel Paketleri Yükleme işlemine başlıyorum."
echo -------------------------------------------------------------------------------------
sleep 2
echo
sudo apt upgrade -y
sleep 1

# Tüm node'larda swap'ı kapatıyoruz, Kubelet üzerinde çalıştığı Node'un bilgilerini anlık olarak controlplane'a iletebilmesi için swap kapatılmaktadır.
echo
echo -------------------------------------------------------------------------------------
echo "Swap'ı kapatıyorum (kalıcı olarak kapatmak için fstab'dan disable etmelisin)"
echo -------------------------------------------------------------------------------------
sleep 2
echo
sudo swapoff -a
sleep 2

# Tüm node'lar reboot edildiklerinde swap'ın tekrar oluşmaması için fstab'dan kapatıyoruz.
echo
echo ----------------------------------------------------------------------------------------------------
echo "Swap dosyasının Sunucu reboot edildiğinde tekrar oluşmaması için kalıcı olarak etkisizleştiriyorum"
echo ----------------------------------------------------------------------------------------------------
sleep 2
echo
sudo sed -i '/ swap / s/^/#/' /etc/fstab
sleep 5

# Cluster'ın overlay trafiği oluşturabilmesi, IP tables'in bridge trafiğini görebilmesi için kernel modüllerini etkin hale getiriyoruz.
echo
echo -------------------------------------------------------------------------------------
echo "Overlay trafiği için IP tables etkinleştiriyorum."
echo -------------------------------------------------------------------------------------
sleep 2
echo
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sleep 1
sudo modprobe overlay
sleep 1
sudo modprobe br_netfilter
sleep 1

# Sistemlerin reboot edildiklerinde, mevcut parametreleri korumaları için ayarları set ediyoruz.
echo
echo -------------------------------------------------------------------------------------
echo "Sistemlerin reboot edildiklerinde, mevcut parametreleri korumaları için ayarları set ediyoruz."
echo -------------------------------------------------------------------------------------
sleep 2
echo
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sleep 1

# Sunucuları yeniden başlatmadan sistem parametrelerini uygulamaya alıyoruz.
echo
echo -------------------------------------------------------------------------------------
echo "Sunucuları sistem parametrelerini uygulamaya alıyorum."
echo -------------------------------------------------------------------------------------
sleep 2
echo
sudo sysctl --system
sleep 1

# Kubernetes kurulumu için ihtiyaç duyulan ek paketlerin kurulumu
echo
echo -------------------------------------------------------------------------------------
echo "Kubernetes Kurulumu ek paketleri yüklüyorum."
echo -------------------------------------------------------------------------------------
sleep 2
echo
sudo apt-get install -y apt-transport-https ca-certificates curl
sleep 1

# Kubernetes'in resmi GPG anahtarını yükleyelim
echo
echo -------------------------------------------------------------------------------------
echo "Kubernetes'in resmi GPG anahtarini yüklüyorum."
echo -------------------------------------------------------------------------------------
sleep 2
echo
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
sleep 1

# Kubernetes'in Kararlı deposunu kurmak için aşağıdaki komutu kullanın.
echo
echo -------------------------------------------------------------------------------------
echo "Kubernetes'in deposunu kuruyorum."
echo -------------------------------------------------------------------------------------
sleep 2
echo
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sleep 1

# Kubernetes kurulumuna başlayalım.
echo
echo -------------------------------------------------------------------------------------
echo "Güncelleme yapıyorum."
echo -------------------------------------------------------------------------------------
sleep 2
echo
sudo apt update
sleep 1

# Containerd paketlerini yükleyelim.
echo
echo -------------------------------------------------------------------------------------
echo "Containerd paketlerini yüklüyorum."
echo -------------------------------------------------------------------------------------
sudo apt install containerd -y
sleep 2

# Containerd konfigurasyonu için klasör oluşturup, varsayılan konfigurasyonu uyguluyoruz.
echo
echo -------------------------------------------------------------------------------------
echo "Containerd için klasör oluşturuyorum"
echo -------------------------------------------------------------------------------------
sleep 2
echo
sudo mkdir -p /etc/containerd
sleep 2
containerd config default | sudo tee /etc/containerd/config.toml

# Containerd Servisleri restart et.
echo
echo -------------------------------------------------------------------------------------
echo "Containerd Servisini Etkinleştirip restart ediyorum."
echo -------------------------------------------------------------------------------------
sudo systemctl restart containerd && sudo systemctl enable containerd
sleep 2

# Kubernetes kubeadm, kubelet, kubectl ve Containerd paketlerini yükleyelim.
echo
echo -------------------------------------------------------------------------------------
echo "Kubernetes kubeadm, kubelet, kubectl ve paketlerini yüklüyorum."
echo -------------------------------------------------------------------------------------
sudo apt install kubelet kubeadm kubectl -y
sleep 2

# Kubernetes & Containerd update hold komutunu çalıştır.
echo
echo -------------------------------------------------------------------------------------
echo "Kubernetes & Containerd apt-update donduruyorum."
echo -------------------------------------------------------------------------------------
sleep 2
echo
sudo apt-mark hold kubelet kubeadm kubectl containerd
sleep 1

# Kubeadm kurulumun başlatabiliriz, bu adımı Master Node üzerinde gerçekleştirmekteyiz.
echo -------------------------------------------------------------------------------------
echo "Kubeadm kurulumun başlatıyorum, bu adımı yalnızca Master Node üzerinde gerçekleştirmekteyiz."
echo -------------------------------------------------------------------------------------
sleep 2
while true; do
    echo
    echo "1. Kube Master için Kullanacağım Sanal IP adresini belirt: "
    read VIRTIP
    echo
    echo "2. API server'in IP Adresini belirt: "
    read APIIP
    echo
    echo "3. Pod networkü için IP bloğu (10.0.0.1/16) şeklinde belirt: "
    read PODIP
    echo
    if [ -z "$VIRTIP" ] || [ -z "$APIIP" ] || [ -z "$PODIP" ] ; then
       echo
       echo "-----------------------------------------------Dikkat--------------------------------------------------"
       echo "Sanal IP, API, veya Pod networkü için belirtimde bulunmadın,IP bilgileri olmadan kuruluma devam edemem."
       echo "-----------------------------------------------Dikkat--------------------------------------------------"
       echo
       continue
    fi
    break
done
echo
echo "Control Plane için Kullanacağım ip adresi: $VIRTIP"
echo
echo "API Yayını için kullanacağım IP: $APIIP"
echo
echo "Pod Networkü için kullanacağım IP: $PODIP"
echo
echo "Onaylıyorsan Kuruluma başlayacağım :)"
while true; do
   read -p "(e/h)?" onay
   case "$onay" in
    e|E ) sudo kubeadm init --control-plane-endpoint="$VIRTIP:6443" --upload-certs --apiserver-advertise-address=$APIIP --pod-network-cidr=$PODIP --v=5
          echo
          # kubectl'ın root olmayan kullanıcılarda çalışabilmesi için, aşağda ki komutları çalıştırıyoruz.
          echo -------------------------------------------------------------------------------------
          echo "kubectl'ın root olmayan kullanıcılarda çalışabilmesi için, işlemleri gerçekleştiriyorum"
          echo -------------------------------------------------------------------------------------
          sleep 2
          echo
          mkdir -p $HOME/.kube
          sleep 1
          sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
          sleep 1
          sudo chown $(id -u):$(id -g) $HOME/.kube/config

          # Pod networkü oluşturma.
          echo -------------------------------------------------------------------------------------
          echo "Pod network'ü için Calico'yu kuruyorum"
          echo -------------------------------------------------------------------------------------
          sleep 2
          echo
          curl https://projectcalico.docs.tigera.io/manifests/calico.yaml -O
          sleep 2
          kubectl apply -f calico.yaml
          echo
          echo -------------------------------------------------------------------------------------
          echo "Worker node’ların cluster’a katılımlarını gerçekleştirmek için,
          kubernetes kurulum işleminin tamamlanmasının ardından son satırda belirttiği
          kubeadm join ile başlayan komutu worker node’larda root kullanıcısı olarak uygulayarak,
          tümünü kubernetes cluster’ine dahil etmeniz gerekir."
          echo
          echo -------------------------------------------------------------------------------------
          sleep 10
          echo -------------------------------------------------------------------------------------

          echo "Kubernetes Cluster Nodelarını listeliyorum"
          kubectl get nodes
          sleep 2
          echo -------------------------------------------------------------------------------------
          sleep 5
          echo -------------------------------------------------------------------------------------
          echo
          echo "Master node üzerinde Kubectl autocomplete kurulumunu gerçekleştiriyorum"
          source /usr/share/bash-completion/bash_completion
          sleep 2
          kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
          sleep 2
          echo
          echo -------------------------------------------------------------------------------------
          echo
          echo -------------------------------------------------------------------------------------
          echo "Kurulum İşlemlerini tamamladım, İyi günler dilerim"
          echo -------------------------------------------------------------------------------------
          echo
          sleep 2
          exit 0;;
    h|H ) echo "Kurulum İptal Edilmistir"
          echo
          exit 0;;
    * ) echo "Onayın Olmazsa Kuruluma Devam edemem :("
        echo
        exit 1;;
   esac
done
echo
