#!/bin/bash

# Define colors.
RED='\033[0;91m'
GREEN='\033[0;32m'
LIGHTBLUE='\033[0;94m'
GRAY='\033[0;90m'
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

# cd vyos-jenkins directory
cd $USER_HOME/vyos-jenkins

# EnsureStage 8 complete check
if [ ! -f /var/cache/vyos-installer/installer_stage_8_completed ]; then
  echo "${RED}Stage 8 has not been completed - please run that first.${NOCOLOR}"
  exit 1
fi

# Define username and token filenames.
USERNAME_FILE="/var/cache/vyos-installer/installer_username"
TOKEN_FILE="/var/cache/vyos-installer/installer_token"

convert_groovy_to_xml() {
    local groovy_file=$1

    cat <<EOF
<flow-definition plugin="workflow-job@2.40">
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.92">
    <script>
$(sed 's/^/      /' $groovy_file)
    </script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF
}

java -jar jenkins-cli.jar -s http://172.17.17.17:8080 -auth $(cat $USERNAME_FILE):$(cat $TOKEN_FILE) create-job build-vyos-iso-equuleus <<< $(convert_groovy_to_xml /tmp/jenkinsfiles/build-vyos-iso-equuleus.groovy)
java -jar jenkins-cli.jar -s http://172.17.17.17:8080 -auth $(cat $USERNAME_FILE):$(cat $TOKEN_FILE) create-job build-vyos-iso-sagitta <<< $(convert_groovy_to_xml /tmp/jenkinsfiles/build-vyos-iso-sagitta.groovy)
java -jar jenkins-cli.jar -s http://172.17.17.17:8080 -auth $(cat $USERNAME_FILE):$(cat $TOKEN_FILE) create-job build-vyos-cloudimage-equuleus <<< $(convert_groovy_to_xml /tmp/jenkinsfiles/build-vyos-cloudimage-equuleus.groovy)
java -jar jenkins-cli.jar -s http://172.17.17.17:8080 -auth $(cat $USERNAME_FILE):$(cat $TOKEN_FILE) create-job build-vyos-cloudimage-sagitta <<< $(convert_groovy_to_xml /tmp/jenkinsfiles/build-vyos-cloudimage-sagitta.groovy)

