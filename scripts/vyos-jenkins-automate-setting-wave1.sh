#!/bin/bash

# Define colors.
RED='\033[0;91m'
NOCOLOR='\033[0m'

# Ensure we are root
if [ "$EUID" -ne 0 ]; then
  >&2 echo -e "${RED}Please run as root${NOCOLOR}"
  exit 1
fi

if [ "$SUDO_USER" != "root" ]; then
  USER_HOME=$(eval echo ~$SUDO_USER)
  USER_ID=$(id -u $SUDO_USER)
  USER_NAME=$(echo $SUDO_USER)
else
  USER_HOME="/root"
  USER_ID=$(id -u)
  USER_NAME=$(whoami)
fi

# swap
TOTAL_MEM_GB=16
RAM_SIZE_GB=$(free -g | awk '/^Mem:/{print $2}')
CURRENT_SWAP_GB=$(free -g | awk '/^Swap:/{print $2}')
NEEDED_SWAP_GB=$((TOTAL_MEM_GB - RAM_SIZE_GB))

if [ "$CURRENT_SWAP_GB" -eq 0 ] && [ "$NEEDED_SWAP_GB" -gt 0 ]; then
    SWAP_SIZE_MB=$((NEEDED_SWAP_GB * 1024))

    fallocate -l "${SWAP_SIZE_MB}M" /swapfile
    chmod 600 /swapfile

    mkswap /swapfile
    swapon /swapfile

    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

    echo "Swap area has been set to ${NEEDED_SWAP_GB}GB."
else
    echo "Current RAM size: ${RAM_SIZE_GB}GB"
    echo "Swap is already set or no additional swap is needed."
fi

# cd user home
cd $USER_HOME

# move scripts
mkdir jenkins-setup-helper-scripts
mv /tmp/scripts/jenkins-setup-helper-scripts/confirm-url.sh jenkins-setup-helper-scripts
mv /tmp/scripts/jenkins-setup-helper-scripts/get-access-token.sh jenkins-setup-helper-scripts
mv /tmp/scripts/jenkins-setup-helper-scripts/install-plugin.sh jenkins-setup-helper-scripts
mv /tmp/scripts/jenkins-setup-helper-scripts/create-admin-user.sh jenkins-setup-helper-scripts

chown -R $USER_ID:$USER_ID jenkins-setup-helper-scripts

# clone repo
git clone https://github.com/dd010101/vyos-jenkins.git

chown -R $USER_ID:$USER_ID vyos-jenkins
cd vyos-jenkins

chmod +x "../jenkins-setup-helper-scripts/confirm-url.sh"
chmod +x "../jenkins-setup-helper-scripts/get-access-token.sh"
chmod +x "../jenkins-setup-helper-scripts/install-plugin.sh"
chmod +x "../jenkins-setup-helper-scripts/create-admin-user.sh"

bash ./1-prereqs.sh
usermod -aG docker $USER_NAME

# Install packer
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

apt-get update
apt-get install -y packer qemu-system
usermod -a -G kvm jenkins

# Check if expect command is available
if ! command -v expect &> /dev/null; then
    # Update package lists
    apt-get update

    # Install expect
    apt-get install -y expect
fi

# Check if python3 command is available
if ! command -v python3 &> /dev/null; then
    # Update package lists
    apt-get update

    # Install python3
    apt-get install -y python3
fi

expect << EOF
set timeout 3600

spawn bash ./2-jenkins.sh

expect -re "http://.*:8080"
set external_url \$expect_out(0,string)

expect "Press enter when you are logged on."
send "\n"

expect "Press enter when the plugins are done installing."
send "\n"
exec bash -c "../jenkins-setup-helper-scripts/install-plugin.sh"

expect "Please enter the username you choose here, and press enter:"
send "admin\n"
exec bash -c "../jenkins-setup-helper-scripts/confirm-url.sh \$external_url"

expect "Please enter the generated token here, and press enter:"
set token [exec bash -c "../jenkins-setup-helper-scripts/get-access-token.sh"]
send "\$token\n"

expect -re "Here you click the .*Add new Token.* button, followed by the .*Generate.* button \\(leave the text field empty\\)."

EOF

echo "Jenkins admin Password setting..."
bash ../jenkins-setup-helper-scripts/create-admin-user.sh

bash ./3-repositories.sh
bash ./4-uncron.sh

chmod +x /tmp/scripts/vyos-jenkins-automate-setting-wave2.sh
bash /tmp/scripts/vyos-jenkins-automate-setting-wave2.sh &
pid=$!
echo "Script is running with PID: $pid"
echo "Log in to Jenkins and check the status for subsequent stages."
echo "User: admin / password: <your setting password>"
