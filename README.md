# devops-terraform-ansible

## Варіант (N=4)
Task Tracker, MariaDB, порт 5000, конфігурація через аргументи командного рядка.

## Архітектура
- VM1 (worker): Flask app + Nginx
- VM2 (db): MariaDB

## Вимоги
- Terraform >= 1.5
- Ansible >= 2.14
- libvirt / KVM на хост-машині
- Python 3

## Розгортання

### 1. Підготовка SSH-ключів

Згенеруй два SSH-ключі — для student і для ansible:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/student_key -N ""
ssh-keygen -t ed25519 -f ~/.ssh/ansible_key -N ""
```

### 2. Terraform

```bash
cd terraform
terraform init
terraform apply \
  -var="student_ssh_key=$(cat ~/.ssh/student_key.pub)" \
  -var="ansible_ssh_key=$(cat ~/.ssh/ansible_key.pub)"
```

Після завершення запиши IP-адреси з виводу:
worker_ip = "192.168.100.X"
db_ip     = "192.168.100.Y"

### 3. Inventory

Підстав IP-адреси в `ansible/inventory.ini`.

### 4. Ansible

```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml \
  --private-key ~/.ssh/ansible_key
```

### 5. Перевірка

```bash
curl http://<worker_ip>/tasks
curl -X POST http://<worker_ip>/tasks \
     -H "Content-Type: application/json" \
     -d '{"title": "Test task"}'
curl http://<worker_ip>/tasks
```
