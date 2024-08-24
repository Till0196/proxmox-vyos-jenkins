#!/bin/bash

if [ "$SUDO_USER" != "root" ]; then
  USER_HOME=$(eval echo ~$SUDO_USER)
  USER_ID=$(id -u $SUDO_USER)
  USER_NAME=$(echo $SUDO_USER)
else
  USER_HOME="/root"
  USER_ID=$(id -u)
  USER_NAME=$(whoami)
fi

# cd vyos-jenkins directory
cd $USER_HOME/vyos-jenkins

bash ./5-docker-jobs.sh
bash ./6-provision-project-jobs.sh
bash ./7-build-project-jobs.sh
bash ./8-nginx.sh

chmod +x /tmp/scripts/vyos-jenkins-add-build-image-job.sh
bash /tmp/scripts/vyos-jenkins-add-build-image-job.sh &
pid=$!
echo "Script is running with PID: $pid"
