#!/bin/bash

access_token=$(cat $TOKEN_FILE)
echo "access_token: $access_token" #debug
echo "env variables: $(printenv)" #debug
REG_TOKEN=$(curl -sX POST -H "Authorization: token ${access_token}" https://api.github.com/orgs/"${ORG_NAME}"/actions/runners/registration-token | jq .token --raw-output)
./config.sh --url https://github.com/"${ORG_NAME}" --token "${REG_TOKEN}" --unattended "${RUNNER_LABELS}" --ephemeral && ./run.sh
