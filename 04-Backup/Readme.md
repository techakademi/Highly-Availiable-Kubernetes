### Min.io Kurulum & Yapılandırma ###

### İhtiyaçlar:

1. Docker sunucu
2. Docker Compose
2. Storage (Qnap Kullanıyorum)
3. Min.io

### Qnap:

1. Storage Space Volume oluştur.
2. Control Panel> Privilege> Shared Folders> Create Shared Folder> Klasöre isim verip "Disk Volume" Menüsünden Oluşturduğun Volume'u seç.
3. Klasör seçili iken Edit Shared Folder Permission'u seç.
4. Permission Type: menüsünden NFS host access'i seç.
5. "Access right" işaretle.
6. Allow IP Address or Domain Name bölümünde, erişim izni vermek istediğin sunucu IP adresi, yazma okuma haklarını belirtip "Apply" tuşuna bas.

### Ubnuntu NFS Yapılandırma:
Ubuntu Sunucuna login olup aşağıda ki komutları sırasıyla çalıştır.

##### Sunucu Güncellemesini gerçekleştir.
```bash
sudo apt update
```

##### NFS paketi yüklü değil ise yüklemesini gerçekleştir.
```bash
sudo apt install nfs-common -y
```
##### NFS paylaşımlarını kontrol etmek için Storage IP adresini kullanrak listele.
```bash
showmount -e 192.168.1.45
```
##### NFS için bir mount point oluştur.
```bash
sudo mkdir mnt/Minioverinoktasi
```

##### NFS bağlantısını gerçekleştirmek için:
```bash
sudo mount -t nfs 192.168.1.45:/Minio /mnt/Minioverinoktasi
```

##### NFS noktasını fstab'a kalıcı hale getir.
```bash
sudo nano /etc/fstab
```

Aşağıdaki Satırı en alta ekleyip **"ctrl+o"** ile kaydetip **"ctrl+x"** ile çıkış yap.

```nano
192.168.1.45:/Minio /mnt/Minioverinoktasi nfs defaults,bg 0 0 
```
### Minio Yapılandırma ve Çalıştırma ###

##### 1.Adım, Docker Voulme oluşturma.
```bash
docker volume create --name minio --opt type=none --opt device=/mnt/Minioverinoktasi --opt o=bind
```
##### 2.Adım, Minio Container'ini çalıştırma.
[Minio Docker Compose belgesini proje klasörüne buradan indirebilirsiniz.](./01-Minio/docker-compose.yml)
```bash
docker compose up -d
```

##### 3.Adım, Docker Sunucu IP adresi & Minio port'unu kullanarak Kullanıcı arayüzüne erişelim.

#### [http://Sunucunun_IP_Adresi:9001](http://#:9001)

##### 4.Adım, Minio'da yeni bir servis hesabı oluşturma.
#### [Minio Servis hesabı oluşturma adımlarını buradan izleyebilirisiniz.](https://youtu.be/0zoI_BkPIrk)

##### 5.Adım, Minio'da yeni bucket oluşturma.
#### [Minio Bucket oluşturma adımlarını buradan izleyebilirisiniz.](https://youtu.be/0zoI_BkPIrk)