# Loadbalancer Sunucularının Kurulum & Yapılandırma Adımları
---
### 1. Adım, HAProxy yazılımını kuralım.

```bash
sudo apt install haproxy -y
```

### 2. Adım, HAProxy yapılandırmasını gerçekleştirelim.

```bash
sudo nano /etc/haproxy/haproxy.cfg
```

### 3. Adım, Aşağıdaki satırları yapılandırma belgemize ekleyip kaydetip kapatalım.

```nano
listen stats
    bind *:1936
    log global
    stats enable
    stats hide-version
    stats show-node
    stats uri /haproxy?stats

frontend kube_cluster-frontend
  bind *:6443
  mode tcp
  option tcplog
  default_backend kube_cluster-backend

backend kube_cluster-backend
  option httpchk GET /healthz
  http-check expect status 200
  mode tcp
  balance roundrobin
    server kubemaster1 192.168.1.231:6443 check fall 5 rise 2
    server kubemaster2 192.168.1.232:6443 check fall 5 rise 2
    server kubemaster3 192.168.1.233:6443 check fall 5 rise 2
```
#### Parametre Açıklamaları:

::: __*fall parametresi*__ :::

*Kaç adet başarısız kontrole izin verileceğini belirler.*

::: __*rise parametresi*__ :::

*Daha önce başarısız olmuş bir sunucuya tekrar bir kontrol için kaç adet kontrol'ün geçmesi gerektiğini belirler.*



### 4. Adım, HAProxy servisini restart ederek yeni yapılandırma ayarlarımızı etkinleştirelim.

```bash
sudo systemctl enable haproxy && sudo systemctl restart haproxy
```
Servislerin restart edilmesinin ardından, sunculardan herhangi birinin HAProxy Stats sayfasını ziyaret ederek kontrol edelim.

http://192.168.1.236:1936/haproxy?stats

### 5. Adım, Keepalived kurulumunu yapalım.

```bash
sudo apt install keepalived -y
```

### 6. Adım, Keepalived yapılandırmasını yapalım.

Keepalived, sunucnun sağlık kontrolünü sağlamada kullanılan en yaygın yöntem kurulu olduğu sunucu üzerinde belirli bir servis veya process'in kontrolü yapılarak sağlanmaktadır.

6.1 Yapılandırmamızın bu aşamasında HAProxy servisini kontrol eden skriptimi kullanacağız.

Bu skript'i her iki sunucumuzun ***__/etc/keepalived/haproxysvc.sh__*** klasörü altına kopyalayalım.

Script'in çalışabilir yetkisine sahip olması için __sudo chmod +x /etc/keepalived/haproxysvc.sh__ komutu ile yetkilendirelim.

[Servis Kontrol Skriptini download etmek için buraya tıkla.](./haproxysvc.sh)

Kullandığım skriptimin içeriği:

```sh
#!/bin/bash

# Servis Adı tanımla
ServisAdi=haproxy

# Servis Durmunu değişkene ata
Durum="$(systemctl is-active $ServisAdi)"

Hata() {
    while [ "$1" != "" ]; do
      echo "### $1 ###"
      return
    done
}

# Servis Durum denetleyicisi
if [ "$Durum" = "active" ]; then
    Hata "$ServisAdi Servisi çalışıyor"
    exit 0
else
    Hata "$ServisAdi Servisi çalışmıyor"
    exit 1
fi
```

6.2 Keepalived yapılandırma belgesi:

Keepalived'ın çalışması esnasında uygulayacağı kuralların tanımlandığı keepalived.conf belgesine ihtiyacı vardır, bu belge /etc/keepalived/keepalived.conf klasörü altında olup kullanım ihtiyacına göre yapılandırılmaktadır.

Bizim kurgumuza uygun yapılandırma belge içeriği aşağıda'ki gibi olacaktır, ilgili konfigurasyonu kopyalayıp /etc/keepalived/keepalived.conf belgesinin içerisine yapıştıralım.

#### Master Node Keepalived'ın Yapılandırma belgesi

```cfg
vrrp_script haproxy_servis_kontrol {
  script "/etc/keepalived/haproxysvc.sh"
  interval 2
  weight -2
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 1
    priority 101
    advert_int 1
    unicast_src_ip 192.168.1.236
    unicast_peer {
      192.168.1.237
    }

    authentication {
        auth_type PASS
        auth_pass parolam12345
    }

    virtual_ipaddress {
        192.168.1.239/24
    }

        track_script {
        haproxy_servis_kontrol
    }
}
```

#### Backup Node Keepalived'ın Yapılandırma belgesi

```cfg
vrrp_script haproxy_servis_kontrol {
  script "/etc/keepalived/haproxysvc.sh"
  interval 2
  timeout 10
  fall 5
  rise 2
  weight -2
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 1
    priority 100
    advert_int 1
    unicast_src_ip 192.168.1.237
    unicast_peer {
      192.168.1.236
    }

    authentication {
        auth_type PASS
        auth_pass parolam12345
    }

    virtual_ipaddress {
        192.168.1.239/24
    }

        track_script {
        haproxy_servis_kontrol
    }
}
```

#### Parametre Açıklamaları:

| Parametre   | Açıklama |
| ----------- | ----------- |
| interval    | Kaç saniye aralıklarla sağlık kontrolü scriptinin çalıştıracağını belirler.        |
| timeout     | Çalıştırılan komutun cevap dönmesi belirtilen süreden uzun sürer ise, keepalived sağlık kontrolünün başarısız olduğunu kabul eder.|
| fall    | Belirtilen sayıda hata olması durumunda ilgili sunucunun başarısız olduğu anlamındadır.|
| rise    | Sunucunun tekrar çalıştığının teyidi için, iki sefer başarılı olması gerktiği anlamındadır.|
| weight  | Sunucunun başarısız olması halinde, kontrolün gerçekleştiği sunucu Önceliği puanını ne kadar düşüreceği anlamına gelmektedir.|
| state   | Sunuculardan birisinin Master diğerinin ise backup olması gerkliliği vardır, buna göre ilgili master sunucu aktif şekilde çalışırken, diğer backup sunucusu pasif modda bekelemde olacaktır.|
| interface | Sunucular arası iletişimin hangi ethernet kartı üzerinden gerçekleştirileceği belirtilmektedir.|
| virtual_router_id   | Router tanımlama numarası 1-255 arasında bir numara olmak zorunda.|
| priority   | Öncelik numarası |
| advert_int  | Keepalived sunucuları kendi aralarında, ne kadar süre ile birbirlerini kontrol edeceklerini saniye bazında belirtilmektedir. |
| authentication  | Sunucuların, birbirlerini kontrol esnasında kullandıkları kimlik doğrulama yöntemi. |
| virtual_ipaddress  | Kullanılacak sanl ip |
| track_script  | Denetleme script'inin adı. |

Yapılandırma belgemizi oluşturma aşamasından sonra keepalived servisini etkinleştirelim.

```bash
sudo systemctl enable keepalived
```

Keepalived servisinin çalıştığını kontrol edelim.

```bash
sudo systemctl status keepalived
```

```bash
journalctl -f -u keepalived
```

Keepalived kontrolünü gerçekleştirmek için sanal IP adresimiz ile haproxy stats arayüzümüzü kontrol edelim.

[http://192.168.1.239:1936/haproxy?stats](http://192.168.1.239:1936/haproxy?stats)

## [Üst menüye dön](https://github.com/techakademi/Highly-Availiable-Kubernetes)
