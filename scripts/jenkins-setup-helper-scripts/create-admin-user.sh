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
new_password=$(cat /tmp/jenkins-admin-password.txt)

# NEW ADMIN CREDENTIALS URL ENCODED USING PYTHON3
username=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input(), safe=''))" <<< "admin")
new_password=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input(), safe=''))" <<< "$new_password")
fullname=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input(), safe=''))" <<< "admin")
email=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input(), safe=''))" <<< "admin@example.com")

# GET THE CRUMB AND COOKIE
cookie_jar="$(mktemp)"
full_crumb=$(curl -s -u "admin:$password" --cookie-jar "$cookie_jar" $url/crumbIssuer/api/xml?xpath=concat\(//crumbRequestField,%22:%22,//crumb\))
arr_crumb=(${full_crumb//:/ })
only_crumb=$(echo ${arr_crumb[1]})

# MAKE THE REQUEST TO CREATE AN ADMIN USER
curl -s -X POST -u "admin:$password" $url/setupWizard/createAdminUser \
        -H "Connection: keep-alive" \
        -H "Accept: application/json, text/javascript" \
        -H "X-Requested-With: XMLHttpRequest" \
        -H "$full_crumb" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        --cookie $cookie_jar \
        --data-raw "username=$username&password1=$new_password&password2=$new_password&fullname=$fullname&email=$email&Jenkins-Crumb=$only_crumb&json=%7B%22username%22%3A%20%22$username%22%2C%20%22password1%22%3A%20%22$new_password%22%2C%20%22%24redact%22%3A%20%5B%22password1%22%2C%20%22password2%22%5D%2C%20%22password2%22%3A%20%22$new_password%22%2C%20%22fullname%22%3A%20%22$fullname%22%2C%20%22email%22%3A%20%22$email%22%2C%20%22Jenkins-Crumb%22%3A%20%22$only_crumb%22%7D&core%3Aapply=&Submit=Save&json=%7B%22username%22%3A%20%22$username%22%2C%20%22password1%22%3A%20%22$new_password%22%2C%20%22%24redact%22%3A%20%5B%22password1%22%2C%20%22password2%22%5D%2C%20%22password2%22%3A%20%22$new_password%22%2C%20%22fullname%22%3A%20%22$fullname%22%2C%20%22email%22%3A%20%22$email%22%2C%20%22Jenkins-Crumb%22%3A%20%22$only_crumb%22%7D"
