variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
}

variable "kullanıcı" {
    default = "kubeadmin"

}

variable "parola" {
    default = 1

}

variable "ssh_anahtar" {
    default = "SSH Public anahtar çıktısını eklenir"

}

variable "KubeMaster" {
    default = {
        "Kubemaster01" = {
            hostname = "Kubemaster01",
            ip_address = "192.168.1.231/24",
            sshIP = "192.168.1.231",
            nameserver = "192.168.1.2",
            gateway = "192.168.1.1",
            target_node = "proxsrv",
            cpu_cores = 2,
            cpu_sockets = 1,
            memory = "2048",
            hdd_size = "75G",
            vm_template = "Ubuntu-TMP"
        }
    }
}

variable "KubeMasterNode" {
    default = {
        "Kubemaster02" = {
            hostname = "Kubemaster02",
            ip_address = "192.168.1.232/24",
            sshIP = "192.168.1.232",
            nameserver = "192.168.1.2",
            gateway = "192.168.1.1",
            target_node = "proxsrv",
            cpu_cores = 2,
            cpu_sockets = 1,
            memory = "2048",
            hdd_size = "75G",
            vm_template = "Ubuntu-TMP"
        },

        "Kubemaster03" = {
            hostname = "Kubemaster03",
            ip_address = "192.168.1.233/24",
            sshIP = "192.168.1.233",
            nameserver = "192.168.1.2",
            gateway = "192.168.1.1",
            target_node = "proxsrv2",
            cpu_cores = 2,
            cpu_sockets = 1,
            memory = "2048",
            hdd_size = "75G",
            vm_template = "Ubuntu-TMP"
        }
    }
}

variable "KubeNode" {
    default = {
        "KubeNode01" = {
            hostname = "KubeNode01",
            ip_address = "192.168.1.234/24",
            sshIP = "192.168.1.234",
            nameserver = "192.168.1.2",
            gateway = "192.168.1.1",
            target_node = "proxsrv",
            cpu_cores = 2,
            cpu_sockets = 1,
            memory = "2048",
            hdd_size = "75G",
            vm_template = "Ubuntu-TMP"
        },

        "KubeNode02" = {
            hostname = "KubeNode02",
            ip_address = "192.168.1.235/24",
            sshIP = "192.168.1.235",
            nameserver = "192.168.1.2",
            gateway = "192.168.1.1",
            target_node = "proxsrv2",
            cpu_cores = 2,
            cpu_sockets = 1,
            memory = "2048",
            hdd_size = "75G",
            vm_template = "Ubuntu-TMP"
        }
    }
}

variable "HAProxy" {
    default = {
        "HAproxy01" = {
            hostname = "HAproxy01",
            ip_address = "192.168.1.236/24",
            sshIP = "192.168.1.236",
            nameserver = "192.168.1.2",
            gateway = "192.168.1.1",
            target_node = "proxsrv",
            cpu_cores = 1,
            cpu_sockets = 1,
            memory = "1024",
            hdd_size = "50G",
            vm_template = "Ubuntu-TMP"
        },

        "HAproxy02" = {
            hostname = "HAproxy02",
            ip_address = "192.168.1.237/24",
            sshIP = "192.168.1.237",
            nameserver = "192.168.1.2",
            gateway = "192.168.1.1",
            target_node = "proxsrv2",
            cpu_cores = 1,
            cpu_sockets = 1,
            memory = "1024",
            hdd_size = "50G",
            vm_template = "Ubuntu-TMP"
        }
    }
}
