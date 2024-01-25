#!/bin/bash

# we stop execution upon failure
set -e

access_token=$(cat $TOKEN_FILE)

# get access token for installation
installation_access_token=$(curl --fail -X POST \
    -H "Authorization: Bearer ${access_token}" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/app/installations/${GH_APP_INSTALLATION_ID}/access_tokens" | jq .token --raw-output)

# get registration token for new runner
registration_token=$(curl --fail -X POST \
    -H "Authorization: Bearer ${installation_access_token}" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/orgs/"${ORG_NAME}"/actions/runners/registration-token | jq .token --raw-output)

./config.sh --url https://github.com/"${ORG_NAME}" ${RUNNER_LABELS} --token "${registration_token}" --unattended --ephemeral
./run.sh
