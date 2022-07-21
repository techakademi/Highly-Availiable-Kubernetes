#!/bin/bash
echo "*************************************************"
echo "***Güncelleme & Yükleme Islemlerine Basliyorum***"
echo "*************************************************"
sudo apt update && sudo apt upgrade -y
echo "*************************************************"
echo "***HAProxy   paketini    yüklemeye  Basliyorum***"
echo "*************************************************"
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
sudo apt install haproxy -y
echo "*****************************************************"
echo "***      HAProxy servisini  etkinlesitiyorum      ***"
echo "*****************************************************"
sudo systemctl start haproxy.service
sudo systemctl enable haproxy.service
sudo systemclt restart haproxy.service
echo "*****************************************************"
echo "***      HAProxy servisini Kontrol ediyorum       ***"
echo "*****************************************************"
sudo systemctl is-active haproxy.service >/dev/null 2>&1 && echo HAProxy Servis Calisiyor || echo HAProxy Servis Calismiyor
sleep 5
echo "*************************************************"
echo "***Keepalived paketini   yüklemeye  Basliyorum***"
echo "*************************************************"
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
sudo apt install keepalived -y
echo "*****************************************************"
echo "***   Keepalived servisini  etkinlesitiyorum      ***"
echo "*****************************************************"
sudo systemctl restart keepalived.service
sudo systemctl enable keepalived.service
echo "*****************************************************"
echo "***     Keepalived servisini Kontrol ediyorum     ***"
echo "*****************************************************"
sudo systemctl is-active keepalived.service >/dev/null 2>&1 && echo Keepalived Servis Calisiyor || echo Keepalived Servis Calismiyor
sleep 5
echo "*****************************************************"
echo "        ***Kurulum işlemi tamamlanmıştır.***         "
echo "*****************************************************"