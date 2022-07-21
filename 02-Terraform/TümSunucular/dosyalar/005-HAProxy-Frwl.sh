#!/bin/bash

echo isleme baslama zamani:
date +"%H:%M:%S"

echo Mevcut Firewall kurallarinin yedegini aliyorum.
echo --------------------------------------
sudo iptables-save > /home/kubeadmin/iptables-kurallar-yedek
sleep 7
echo yedek Kontrolünü gerceklestiriyorum
ls | grep iptables-kurallar-yedek
sleep 5
echo -----------------------------------------------------------------
echo Kurallari degistiriyorum, DROP ve REJECT kurallarını temizliyorum.
echo -----------------------------------------------------------------
sudo grep -v "DROP"  /home/kubeadmin/iptables-kurallar-yedek > iptablesdegisen-DROP
sleep 5
sudo mv iptablesdegisen-DROP iptables-kurallar-degisen
sleep 7
sudo grep -v "REJECT" /home/kubeadmin/iptables-kurallar-degisen > iptablesdegisen-GREP
sleep 5
sudo mv iptablesdegisen-GREP iptables-kurallar-temiz
sleep 7
echo Yeni kurallari uyguluyorum.
echo ---------------------------
sudo iptables-restore < /home/kubeadmin/iptables-kurallar-temiz
# HAProxy'nin ihtiyaç duyduğu TCP portları.
sudo iptables -A INPUT -p tcp -m multiport --dports 80,443,22,1936  -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp -m multiport --dports 80,443,22,1936 -m conntrack --ctstate ESTABLISHED -j ACCEPT
sleep 2
echo Yeni kurallari kontrol ediyorum.
echo ---------------------------
sudo iptables -L
sleep 2
echo Degisiklikleri kayit ediyorum.
echo ---------------------------
sudo su -c "/sbin/iptables-save > /etc/iptables/rules.v4; exit" root
sleep 5
