terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-noble-base"
  source = var.vm_image
  format = "qcow2"
}

resource "libvirt_volume" "worker_disk" {
  name           = "${var.worker_name}-disk"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = var.disk_size
}

resource "libvirt_volume" "db_disk" {
  name           = "${var.db_name}-disk"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = var.disk_size
}

data "template_file" "worker_cloud_init" {
  template = file("${path.module}/cloud-init-worker.yaml")
  vars = {
    student_ssh_key = var.student_ssh_key
    ansible_ssh_key = var.ansible_ssh_key
  }
}

data "template_file" "db_cloud_init" {
  template = file("${path.module}/cloud-init-db.yaml")
  vars = {
    student_ssh_key = var.student_ssh_key
    ansible_ssh_key = var.ansible_ssh_key
  }
}

resource "libvirt_cloudinit_disk" "worker_init" {
  name      = "${var.worker_name}-init.iso"
  user_data = data.template_file.worker_cloud_init.rendered
}

resource "libvirt_cloudinit_disk" "db_init" {
  name      = "${var.db_name}-init.iso"
  user_data = data.template_file.db_cloud_init.rendered
}

resource "libvirt_network" "lab_network" {
  name      = "lab-network"
  mode      = "nat"
  addresses = ["192.168.100.0/24"]
  dhcp {
    enabled = true
  }
  dns {
    enabled = true
  }
}

resource "libvirt_domain" "worker" {
  name   = var.worker_name
  memory = var.worker_memory
  vcpu   = var.worker_vcpu

  cloudinit = libvirt_cloudinit_disk.worker_init.id

  network_interface {
    network_id     = libvirt_network.lab_network.id
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.worker_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

resource "libvirt_domain" "db" {
  name   = var.db_name
  memory = var.db_memory
  vcpu   = var.db_vcpu

  cloudinit = libvirt_cloudinit_disk.db_init.id

  network_interface {
    network_id     = libvirt_network.lab_network.id
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.db_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}