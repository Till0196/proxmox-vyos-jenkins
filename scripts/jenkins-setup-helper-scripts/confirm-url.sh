#!/bin/bash

# Define colors.
RED='\033[0;91m'
NOCOLOR='\033[0m'

# Ensure we are root
if [ "$EUID" -ne 0 ]; then
  >&2 echo -e "${RED}Please run as root${NOCOLOR}"
  exit 1
fi

# check url
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <jenkins_url>"
    exit 1
fi

# The jenkins URL, if you are on an amazon instance, you can put there the
# public DNS name, in order to be able to access jenkins thorugh that URL
url=$1
if [ -n "/var/lib/jenkins/secrets/initialAdminPassword" ]; then
  password=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
else
  password=$(cat /tmp/jenkins-admin-password)
fi

url_urlEncoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input(), safe=''))" <<< "$url")

cookie_jar="$(mktemp)"
full_crumb=$(curl -s -u "admin:$password" --cookie-jar "$cookie_jar" $url/crumbIssuer/api/xml?xpath=concat\(//crumbRequestField,%22:%22,//crumb\))
arr_crumb=(${full_crumb//:/ })
only_crumb=$(echo ${arr_crumb[1]})

curl -s -X POST -u "admin:$password" $url/setupWizard/configureInstance \
  -H 'Connection: keep-alive' \
  -H 'Accept: application/json, text/javascript, */*; q=0.01' \
  -H 'X-Requested-With: XMLHttpRequest' \
  -H "$full_crumb" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Accept-Language: en,en-US;q=0.9,it;q=0.8' \
  --cookie $cookie_jar \
  --data-raw "rootUrl=$url_urlEncoded%2F&Jenkins-Crumb=$only_crumb&json=%7B%22rootUrl%22%3A%20%22$url_urlEncoded%2F%22%2C%20%22Jenkins-Crumb%22%3A%20%22$only_crumb%22%7D&core%3Aapply=&Submit=Save&json=%7B%22rootUrl%22%3A%20%22$url_urlEncoded%2F%22%2C%20%22Jenkins-Crumb%22%3A%20%22$only_crumb%22%7D"
