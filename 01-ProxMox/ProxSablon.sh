#!/bin/bash
echo "******************************************************************"
echo "***Ben Proxmox sunucusu üzerinde Şablon oluşturacak Droid'im :)***"
echo "******************************************************************"
echo
echo "******************************************************************"
echo "***     Ubuntu Focal-Server Cloud Image Download edeceğim      ***"
echo "******************************************************************"
echo
ImajKaynak="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img"
Imaj_Adi="focal-server-cloudimg-amd64-disk-kvm.img.qcow2"
echo
echo "*************************************************"
echo "***          Imajı Download ediyorum          ***"
echo "*************************************************"
wget -nc -O $Imaj_Adi $ImajKaynak
echo
echo "*************************************************"
echo "***   libguestfs-tools Download ediyorum      ***"
echo "*************************************************"
apt-get install --no-upgrade libguestfs-tools
echo
echo "*************************************************"
echo "***   qemu-guest-agent'ini Imaja ekşiyorum    ***"
echo "*************************************************"
virt-customize --install qemu-guest-agent -a $Imaj_Adi
echo
echo "*************************************************"
echo "***   Şablon Sunucu Oluşumunu başlatıyorum    ***"
echo "*************************************************"
qm create 3333 --name Ubuntu-TMP --memory 512 --net0 virtio,bridge=vmbr0
qm importdisk 3333 focal-server-cloudimg-amd64-disk-kvm.img.qcow2 local-lvm
qm set 3333 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-3333-disk-0
qm set 3333 --ide2 local-lvm:cloudinit
qm set 3333 --boot c --bootdisk scsi0
qm set 3333 --serial0 socket --vga serial0
qm set 3333 --agent enabled=1
qm template 3333
sleep 5s
echo "*****************************************************"
echo "*** $Sablon_ADI Şablon Sunucu Oluşumu tamamlandı  ***"
echo "*****************************************************"
qm list
