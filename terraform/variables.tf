variable "vm_image" {
  default = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "worker_name" {
  default = "worker"
}

variable "db_name" {
  default = "db"
}

variable "worker_memory" {
  default = 1024
}

variable "db_memory" {
  default = 1024
}

variable "worker_vcpu" {
  default = 1
}

variable "db_vcpu" {
  default = 1
}

variable "disk_size" {
  default = 10737418240
}

variable "student_ssh_key" {
  description = "SSH public key for student user"
}

variable "ansible_ssh_key" {
  description = "SSH public key for ansible user"
}