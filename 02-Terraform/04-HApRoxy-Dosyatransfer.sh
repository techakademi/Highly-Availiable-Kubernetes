#!/bin/bash

# Dosyaları Kopyalama adımı
scp -o StrictHostKeyChecking=no -C -i ~/.ssh/ProxVms -r ~/ProxProje/dosyalar/ ${kullanıcı}@${sunucuIP}:/home/kubeadmin

# İlgili Script'leri uyguluyorum.
ssh -o StrictHostKeyChecking=no -C -i ~/.ssh/ProxVms ${kullanıcı}@${sunucuIP} << EOF
  chmod -R +x /home/kubeadmin
  ./dosyalar/001-Iptables-Kurulum.sh
  sleep 5
  echo
  ./dosyalar/005-HAProxy-Frwl.sh
  sleep 5
  echo
  ./dosyalar/006-HA-Failover-Kurulum.sh
  sleep 5
  sudo mv  /home/kubeadmin/dosyalar/haproxysvc.sh /etc/keepalived/haproxysvc.sh
  sleep 3
  sudo mv  /home/kubeadmin/dosyalar/haproxy.cfg /etc/haproxy/haproxy.cfg
  sleep 3
  ./dosyalar/007-Keepalive-Conf.sh
EOF