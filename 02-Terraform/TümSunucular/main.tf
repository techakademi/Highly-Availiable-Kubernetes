#Kubemaster sunucuları oluşturma Bölümü
resource "proxmox_vm_qemu" "KubeMaster" {
    for_each = var.KubeMaster
    name = each.value.hostname
    target_node = each.value.target_node
    clone = each.value.vm_template
    full_clone = true
    os_type = "cloud-init"
    agent = 1
    cores = each.value.cpu_cores
    sockets = each.value.cpu_sockets
    cpu = "host"
    memory = each.value.memory
    scsihw = "virtio-scsi-pci"
    bootdisk = "scsi0"
    disk {
        slot = 0
        size = each.value.hdd_size
        type = "scsi"
        storage = "local-lvm"
        iothread = 1
    }

    vga {
        type = "serial0"
    }

    network {
        model = "virtio"
        bridge = "vmbr0"
    }
    ipconfig0 = "ip=${each.value.ip_address},gw=${each.value.gateway}"
    nameserver = each.value.nameserver
    ciuser = var.kullanıcı
    cipassword = var.parola
    sshkeys = var.ssh_anahtar

    provisioner "local-exec" {
    command = templatefile("./01-KubeM-Dosyatransfer.sh",
    {
        "kullanıcı" = var.kullanıcı
        "sunucuIP"  = each.value.sshIP
    })
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
    }

}

resource "time_sleep" "KubeMasteri_Bekle" {
    depends_on = [proxmox_vm_qemu.KubeMaster]
    create_duration = "120s"
}

resource "proxmox_vm_qemu" "KubeMasterNode" {
  depends_on = [time_sleep.KubeMasteri_Bekle]
    for_each = var.KubeMasterNode
    name = each.value.hostname
    target_node = each.value.target_node
    clone = each.value.vm_template
    full_clone = true
    os_type = "cloud-init"
    agent = 1
    cores = each.value.cpu_cores
    sockets = each.value.cpu_sockets
    cpu = "host"
    memory = each.value.memory
    scsihw = "virtio-scsi-pci"
    bootdisk = "scsi0"
    disk {
        slot = 0
        size = each.value.hdd_size
        type = "scsi"
        storage = "local-lvm"
        iothread = 1
    }

    vga {
        type = "serial0"
    }

    network {
        model = "virtio"
        bridge = "vmbr0"
    }

    ipconfig0 = "ip=${each.value.ip_address},gw=${each.value.gateway}"
    nameserver = each.value.nameserver
    ciuser = var.kullanıcı
    cipassword = var.parola
    sshkeys = var.ssh_anahtar

    provisioner "local-exec" {
    command = templatefile("./02-KubeMNodes-Dosyatransfer.sh",
    {
        "kullanıcı" = var.kullanıcı
        "sunucuIP"  = each.value.sshIP
    })
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
    }
}

resource "time_sleep" "KubeMasterNode_Bekle" {
    depends_on = [proxmox_vm_qemu.KubeMasterNode]
    create_duration = "120s"
}

resource "proxmox_vm_qemu" "KubeNode" {
  depends_on = [time_sleep.KubeMasterNode_Bekle]
    for_each = var.KubeNode
    name = each.value.hostname
    target_node = each.value.target_node
    clone = each.value.vm_template
    full_clone = true
    os_type = "cloud-init"
    agent = 1
    cores = each.value.cpu_cores
    sockets = each.value.cpu_sockets
    cpu = "host"
    memory = each.value.memory
    scsihw = "virtio-scsi-pci"
    bootdisk = "scsi0"
    disk {
        slot = 0
        size = each.value.hdd_size
        type = "scsi"
        storage = "local-lvm"
        iothread = 1
    }

    vga {
        type = "serial0"
    }

    network {
        model = "virtio"
        bridge = "vmbr0"
    }

    ipconfig0 = "ip=${each.value.ip_address},gw=${each.value.gateway}"
    nameserver = each.value.nameserver
    ciuser = var.kullanıcı
    cipassword = var.parola
    sshkeys = var.ssh_anahtar

    provisioner "local-exec" {
    command = templatefile("./03-KubeNodes-Dosyatransfer.sh",
    {
        "kullanıcı" = var.kullanıcı
        "sunucuIP"  = each.value.sshIP
    })
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
    }
}

resource "time_sleep" "KubeNodeleri_Bekle" {
   depends_on = [proxmox_vm_qemu.KubeNode]
   create_duration = "120s"
}

resource "proxmox_vm_qemu" "HAProxy" {
    depends_on = [time_sleep.KubeNodeleri_Bekle]
    for_each = var.HAProxy
    name = each.value.hostname
    target_node = each.value.target_node
    clone = each.value.vm_template
    full_clone = true
    os_type = "cloud-init"
    agent = 1
    cores = each.value.cpu_cores
    sockets = each.value.cpu_sockets
    cpu = "host"
    memory = each.value.memory
    scsihw = "virtio-scsi-pci"
    bootdisk = "scsi0"
    disk {
        slot = 0
        size = each.value.hdd_size
        type = "scsi"
        storage = "local-lvm"
        iothread = 1
    }

    vga {
        type = "serial0"
    }

    network {
        model = "virtio"
        bridge = "vmbr0"
    }
    ipconfig0 = "ip=${each.value.ip_address},gw=${each.value.gateway}"
    nameserver = each.value.nameserver
    ciuser = var.kullanıcı
    cipassword = var.parola
    sshkeys = var.ssh_anahtar

    provisioner "local-exec" {
    command = templatefile("./04-HApRoxy-Dosyatransfer.sh",
    {
        "kullanıcı" = var.kullanıcı
        "sunucuIP"  = each.value.sshIP
    })
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
    }

}