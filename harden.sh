#!/bin/bash
set -euo pipefail
LOG_FILE="/var/log/harden.log"
echo "$(date) - Stating hardening script" >> $LOG_FILE
echo "Updating system..." >> $LOG_FILE
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y
if ! dpkg | grep -q unattended-upgrades; then
	sudo apt install -y unattended-upgrades
	sudo dpkg-reconfigure --priority=low unattended-upgrades
fi
echo "Patches applied" >> $LOG_FILE

NEW_USER="devopsadmin"
NEW_PASS="password"
if ! id "$NEW_USER" &>/dev/null; then
	sudo adduser --gecos "" --disabled-password $NEW_USER
	echo "$NEW_USER:$NEW_PASS" | sudo chpasswd
	sudo usermod -aG sudo $NEW_USER
	echo "User $NEW_USER created" >> $LOG_FILE
else
	echo "User $NEW_USER exists" >> $LOG_FILE
fi
sudo passwd -l root
sudo apt install -y openssh-server
SSH_CONFIG="/etc/ssh/sshd_config"
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' $SSH_CONFIG
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' $SSH_CONFIG
sudo sed -i 's/#Port 22/Port 2222/' $SSH_CONFIG
if ! grep -q "ClientAliveInterval" $SSH_CONFIG; then
	echo "ClientAliveInterval 300" | sudo tee -a $SSH_CONFIG
	echo "ClientAliveCountMax 2"  sudo tee -a $SSH_CONFIG
fi
sudo systemctl restart ssh
echo "SSH hardened" >> $LOG_FILE

sudo apt install -y ufw
sudo ufw allow from $(curl ifconfig.me) to any port 2222 proto tcp
sudo ufw allow 2222/tcp
sudo ufw logging on
sudo ufw --force enable
sudo ufw status verbose >> $LOG_FILE


sudo apt install -y fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo sed -i 's/bantime  = 10m/bantime  = 1h/' /etc/fail2ban/jail.local
sudo sed -i 's/maxretry = 5/maxretry = 3/' /etc/fail2ban/jail.local
sudo systemctl enable fail2ban && sudo systemctl start fail2ban
sudo fail2ban-client status sshd >> $LOG_FILE

echo "$(date) - Hardening complete" >> $LOG_FILE






