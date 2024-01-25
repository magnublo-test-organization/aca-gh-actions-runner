#!/bin/sh

echo "${GH_APP_PRIVATE_KEY}" > /tmp/private-key.pem
echo "lines in private key: $(wc -l /tmp/private-key.pem)" # debug
jwt encode --exp=$(($(date +%s)+600)) --alg RS256 --iss ${GH_APP_ID} --secret @/tmp/private-key.pem > ${TOKEN_FILE}
rm /tmp/private-key.pem