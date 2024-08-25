#cloud-config
timezone: ${timezone}
locale: ${locale}
fqdn: ${fqdn}
hostname: ${hostname}
users:
- name: ${username}
  groups:
  - sudo
  shell: /bin/bash
  lock_passwd: false
  chpasswd: { expire: False }
  passwd: ${password}
  sudo: ALL=(ALL) NOPASSWD:ALL
  ssh_authorized_keys:
  %{ for _ in ssh_public_key }
  - ${_}
  %{ endfor }
  ssh_pwauth: ${ssh_pwauth}
apt_mirror: ${apt_mirror}
package_update: true
package_upgrade: true
packages:
- qemu-guest-agent
- net-tools
- unattended-upgrades
write_files:
- path: /etc/systemd/system/getty@tty1.service.d/override.conf
  permissions: '0644'
  content: |
    [Service]
    Type=simple
    ExecStart=
    ExecStart=-/sbin/agetty --autologin ${username} --noclear %I 38400 linux
runcmd:
- systemctl enable qemu-guest-agent
- systemctl start qemu-guest-agent
