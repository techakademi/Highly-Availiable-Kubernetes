#!/bin/bash

# Dosyaları Kopyalama adımı
scp -o StrictHostKeyChecking=no -C -i ~/.ssh/ProxVms -r ~/ProxProje/dosyalar/ ${kullanıcı}@${sunucuIP}:/home/kubeadmin

# İlgili Script'leri uyguluyorum.
ssh -o StrictHostKeyChecking=no -C -i ~/.ssh/ProxVms ${kullanıcı}@${sunucuIP} << EOF
  chmod -R +x /home/kubeadmin
  ./dosyalar/001-Iptables-Kurulum.sh
  sleep 5
  echo
  ./dosyalar/002-Master-Frwl.sh  
  sleep 5
EOF