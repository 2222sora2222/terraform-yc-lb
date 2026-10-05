# main.tf
# 1. Создание двух ВМ с помощью count
resource "yandex_compute_instance" "web" {
  count       = 2
  name        = "nginx-vm-${count.index + 1}"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd827b91d99psvq5fjit" # Ubuntu 22.04 LTS
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    user-data = <<-EOF
#cloud-config
users:
  - name: user
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - ${file("~/.ssh/id_rsa.pub")}
runcmd:
  - apt-get update
  - apt-get install -y nginx
  - systemctl enable nginx
  - systemctl start nginx
  - sed -i "s/ nginx/ Nginx-VM-${count.index + 1}/" /var/www/html/index.nginx-debian.html
EOF
  }
}

# 2. Создание целевой группы
resource "yandex_lb_target_group" "web-group" {
  name = "nginx-target-group"

  dynamic "target" {
    for_each = yandex_compute_instance.web[*].network_interface[0].ip_address
    content {
      subnet_id = yandex_vpc_subnet.subnet.id
      address   = target.value
    }
  }
}

# 3. Создание сетевого балансировщика
resource "yandex_lb_network_load_balancer" "web-lb" {
  name = "nginx-network-balancer"

  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.web-group.id

    healthcheck {
      name = "http-healthcheck"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

# Вспомогательные ресурсы (сеть, подсеть, security group)
resource "yandex_vpc_network" "network" {
  name = "my-network"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "my-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

resource "yandex_vpc_security_group" "sg" {
  name       = "my-sg"
  network_id = yandex_vpc_network.network.id

  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
}