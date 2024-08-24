#!/bin/bash

# Define colors.
RED='\033[0;91m'
NOCOLOR='\033[0m'

# Ensure we are root
if [ "$EUID" -ne 0 ]; then
  >&2 echo -e "${RED}Please run as root${NOCOLOR}"
  exit 1
fi

url=http://localhost:8080
if [ -n "/var/lib/jenkins/secrets/initialAdminPassword" ]; then
  password=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
else
  password=$(cat /tmp/jenkins-admin-password.txt)
fi

# GET THE CRUMB AND COOKIE
cookie_jar="$(mktemp)"
full_crumb=$(curl -s -u "admin:$password" --cookie-jar "$cookie_jar" $url/crumbIssuer/api/xml?xpath=concat\(//crumbRequestField,%22:%22,//crumb\))
arr_crumb=(${full_crumb//:/ })
only_crumb=$(echo ${arr_crumb[1]})

# MAKE THE REQUEST TO DOWNLOAD AND INSTALL REQUIRED MODULES
curl -s -X POST -u "admin:$password" $url/pluginManager/installPlugins \
  -H 'Connection: keep-alive' \
  -H 'Accept: application/json, text/javascript, */*; q=0.01' \
  -H 'X-Requested-With: XMLHttpRequest' \
  -H "$full_crumb" \
  -H 'Content-Type: application/json' \
  -H 'Accept-Language: en,en-US;q=0.9,it;q=0.8' \
  --cookie $cookie_jar \
  --data-raw "{'dynamicLoad':true,'plugins':['cloudbees-folder','antisamy-markup-formatter','build-timeout','credentials-binding','timestamper','ws-cleanup','ant','gradle','workflow-aggregator','github-branch-source','pipeline-github-lib','pipeline-stage-view','git', 'git-client', 'ssh-slaves','matrix-auth','pam-auth','ldap','email-ext','mailer'],'Jenkins-Crumb':'$only_crumb'}"
