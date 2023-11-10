#!/bin/bash

REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/orgs/"${ORGANIZATION}"/actions/runners/registration-token | jq .token --raw-output)

cd /home/docker/actions-runner || exit

./config.sh --url https://github.com/"${ORGANIZATION}" --token "${REG_TOKEN}"

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token "${REG_TOKEN}"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
