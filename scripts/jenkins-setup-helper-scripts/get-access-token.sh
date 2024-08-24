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

# MAKE THE REQUEST TO GET THE ACCESS TOKEN
curl -s -X POST -u "admin:$password" $url/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken \
  -H 'Connection: keep-alive' \
  -H 'Accept: application/json, text/javascript, */*; q=0.01' \
  -H 'X-Requested-With: XMLHttpRequest' \
  -H "$full_crumb" \
  -H 'Content-Type: application/json' \
  -H 'Accept-Language: en,en-US;q=0.9,it;q=0.8' \
  --cookie $cookie_jar \
  --data-raw "newTokenName=" | jq -r '.data.tokenValue'

