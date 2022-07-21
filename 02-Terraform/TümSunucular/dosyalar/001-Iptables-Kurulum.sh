#!/bin/bash
echo "*************************************************"
echo "***Güncelleme & Yükleme Islemlerine Basliyorum***"
echo "*************************************************"
sudo apt update && sudo apt upgrade -y
echo "*************************************************"
echo "***iptables-persistent    yüklemeye Basliyorum***"
echo "*************************************************"
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
sudo apt install iptables-persistent -y
echo "*****************************************************"
echo "***netfilter-persistent servisini etkinlesitiyorum***"
echo "*****************************************************"
sudo systemctl start netfilter-persistent.service
sudo systemctl enable netfilter-persistent.service
echo "*****************************************************"
echo "***netfilter-persistent servisini Kontrol ediyorum***"
echo "*****************************************************"
sudo systemctl is-active netfilter-persistent >/dev/null 2>&1 && echo Servis Calisiyor || echo Servis Calismiyor
echo "*****************************************************"
echo "        ***Kurulum işlemi tamamlanmıştır.***         "
echo "*****************************************************"
