# Proxmox Hypervisor'da kullanmak üzere Ubuntu Focal Server Şablon sunucu oluşturma
---

Bu dökümanda belirtilen adımları takip ederek __Ubuntu 20.04.4 LTS (Focal Fossa)__ sunucu kurulumunu gerçekleştirebilirsiniz.

ProxMox'da Sanal makineyi şablona dönüştürme işlemi iki türlü gerçekleştirilebilir.
__Bunlardan birincisi__, ilgili proxmox sunucusuna ssh ile bağlanarak qemu komutları kullanılarak yapılabilir.

__İkincisi ise__, ProxMox arayüzü kullanarak önce bir sanal makine oluşturup kurulumunu tamamladıktan sonra ilgili sanal makineden şablon oluşturulabilir.

Şu an okuduğunuz bu yönergede Sanal makine şablonu oluşturma işlemini en hızlı ve kolay yöntem olan, komut satırı üzerinden oluşturma adımlarını işlemekteyiz.

---

### Birinci bölüm, Proxmox Sanal Makine Oluşturma adımları:
***_1. Adım, İlgili sunucu'ya ssh ile login olalım_***

```bash
ssh root@ProxmoxSunucuIP
```
___
***_2. Adım, Yapılandıracağımız şablon suncunun ihtiyacı olan, (qemu-guest-agent) paketinin sunucu imajına dahil edilme işlemi._***

Sanal makine imajına __(qemu-guest-agent)__ paketini eklemek için __(libguestfs-tools)__ paketine ihtiyacımız var.
libguestfs, sanal makine imajları üzerinde modifikasyon yapmak için bir çok aracı barındıran QEMU,KVM ve libvirt sanallaştırma yazılımlarında kullanılabilir.

Oluşturacağımız Sunucu şablonumuza qemu-guest-agent'i sanal makinemizi oluşturmadan ekleyip imajımızı tekrar oluşturacağız. Bu işlemi hangi sunucu üzerinde gerçekleştirmek istiyorsanız, o sunucu üzerinde __(libguestfs-tools)__ paketini yüklemelisiniz.

Yükleme komutumuzda, no-upgrade argümanı, eğer bu paket zaten mevcutta var ise yeniden yüklemesini gerçekleştirmeyecektir.

```bash
apt-get install --no-upgrade libguestfs-tools
```
___
***_3. Adım, Sanal makineye kurulumu yapılacak olan işletim sisteminin Cloud imajını seç._***

Ubuntu dağıtımının ve diğer bir çok Linux dağıtımlarının Cloud imajları mevcuttur, Cloud imajları bulut platformlarında kullanılmak üzere özel tasarlanmış imajlar olup, boyutları normal ISO dosyalarına göre çok daha küçüktür. Imajlar oluşturulurken, içlerine Cloud-init servisi eklenerek hazır hale getirilmektedir. Cloud-init endüstri standartı haline gelmiş, çoklu platformlarda kullanılmak üzere oluşturulan sanal makinenin ihtiyaç duyduğu ağ, depolama, ssh, kullanıcı bilgileri gibi sistem bilgilerini ilgili sanal makineye işlenmesini sağlamaktadır.

Ubuntunun Bulut imajlarına [Ubuntu Cloud Images](https://cloud-images.ubuntu.com/) adresinden erişebilirsin.

Bu yapılandırmamızda, Ubuntunun Focal Fossa imajını kullanacağım, diğer sürümler ile bu uygulamayı tecrübe etmediğim için herhangi ibir öneride bulunamıyorum.

Focal imajını wget ile download edelim.
```bash
wget -nc https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img
```
Kullanacağımız imajımızın downloadı tamamlandıktan sonra, Proxmox, disk formatlarını .img şeklinde kullanmayıp .qcow2 formatında kullanmaktadır.

Download ettiğimiz imajı qcow2 formatında çevireceğiz.

```bash
mv  focal-server-cloudimg-amd64-disk-kvm.img focal-server-cloudimg-amd64-disk-kvm.img.qcow2
```

***_4. Adım, qemu-guest-agent'in imaja eklenmesi._***

virt-customize komutu ile, kullanacağımız imaja qemu-guest-agent'i yükleyebiliriz.

```bash
virt-customize --install qemu-guest-agent -a focal-server-cloudimg-amd64-disk-kvm.img.qcow2
```
___
***_5. Adım, Şablon sunucu oluşturma._***

Proxmox'da komut satırı ile sanal makine oluşturma __"qm"__ ile başlamaktadır.

Her sanal makinenin benzersiz bir ID'si olmak zorunda, bu tür şablon oluşumlarında mümkünse, yüksek bir ID seçilerek diğer sanal makinelerden ayrıştırılmalı.

Ubuntu-TMP isimli __3333__ ID'li 512 mb RAM'li bir sanal makine oluştur.

```bash
qm create 3333 --name Ubuntu-TMP --memory 512 --net0 virtio,bridge=vmbr0
```
Download ettiğimiz imajı local-lvm veri deposuna import edelim.

```bash
qm importdisk 3333 focal-server-cloudimg-amd64-disk-kvm.img.qcow2 local-lvm
```
Veri deposunu scsi sürücüsü olarak ekleyelim.

```bash
qm set 3333 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-3333-disk-0
```

Cloud-init sürücüsünü ekleyelim.

```bash
qm set 3333 --ide2 local-lvm:cloudinit
```

Sanal makinenin scsi sürücüsünden boot edilmesini sağlayalım.

```bash
qm set 3333 --boot c --bootdisk scsi0
```

Sanal makineyi vnc aracılığı ile yönetebilmek için seri port ekleyelim.

```bash
qm set 3333 --serial0 socket --vga serial0
```

Qemu agent'in kullanılabilmesi için etkinleştirelim.

```bash
qm set 3333 --agent enabled=1
```

Sanal makinemizi ***__"ÇALIŞTIRMADAN"__*** şablona dönüştürelim.

```bash
qm template 3333
```

Şablon sunucumuzun sonucunu  Proxmox ara yüzüne login olup gözlemleyelim.

Tebrikler, komut satırı kullanrak Proxmox'da şablon sunucu oluşturma çalışmasını böylece tamamalamış olduk.

## [Üst menüye dön](#)
