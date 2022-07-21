# Terraform Kurulum Adımları
---
### 1. Adım, HashiCorp'un gpg anahtarını ekleyelim.

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
```

### 2. Adım, HashiCorp'un repository'sini ekleyelim.

```bash
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
```

### 3. Adım, Terraform kurulumunu gerçekleştirelim.

```bash
sudo apt-get update && sudo apt-get install terraform
```

### 4. Adım, Kurulum Version kontrolünü yapalım.

```bash
terraform version
```

Ekran çıktısı olarak aşağıdaki gibi olacaktır.

```bash
Terraform v1.2.1
on linux_amd64

Your version of Terraform is out of date! The latest version
is 1.2.2. You can update by downloading from https://www.terraform.io/downloads.html
```
[Üst menüye dön](./README.md)
