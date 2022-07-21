#!/bin/bash
SunucuAd=HAProxy01
host=$(hostname)

if [ $host != $SunucuAd ]

then
    cat > keepalived.conf << EOF
vrrp_script haproxy_servis_kontrol {
  script "/etc/keepalived/haproxysvc.sh"
  interval 2
  timeout 10
  fall 5
  rise 2
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
EOF

sudo mv keepalived.conf /etc/keepalived/
sleep 2
sudo systemctl restart keepalived.service && sudo systemctl restart haproxy.service
else

	cat > keepalived.conf << EOF
vrrp_script haproxy_servis_kontrol {
  script "/etc/keepalived/haproxysvc.sh"
  interval 2
  weight -2
}

vrrp_instance VI_2 {
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
EOF
sudo mv keepalived.conf /etc/keepalived/
sleep 2
sudo systemctl restart keepalived.service && sudo systemctl restart haproxy.service
fi
