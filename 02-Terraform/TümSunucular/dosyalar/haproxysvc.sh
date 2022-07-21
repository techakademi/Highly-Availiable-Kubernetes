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
