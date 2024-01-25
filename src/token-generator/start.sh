#!/bin/sh

echo ${BASE64_PRIVATE_KEY} | base64 -d > /tmp/private-key.pem
jwt encode --exp=$(($(date +%s)+600)) --alg RS256 --iss ${GH_APP_ID} --secret @/tmp/private-key.pem > ${TOKEN_FILE}
rm /tmp/private-key.pem