#!/bin/sh

echo "echoing this line to force appearance of this script in the logs"
echo "123d14a0-88b9-43c8-9844-deb9c5c9c485"
jwt encode --exp=600 --iss ${GH_APP_ID} --secret b64:${BASE64_PRIVATE_KEY} > ${TOKEN_FILE}