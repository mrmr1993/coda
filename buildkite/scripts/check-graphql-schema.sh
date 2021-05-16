#!/bin/bash

set -eo pipefail

export DUNE_PROFILE=devnet

# Don't prompt for answers during apt-get install
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y git python3 apt-transport-https ca-certificates make curl

# Source the environment script to get the proper ${VERSION}. Must be executed after installing git but before installing mina.
source buildkite/scripts/export-git-env-vars.sh

echo "deb [trusted=yes] http://packages.o1test.net unstable main" | tee /etc/apt/sources.list.d/coda.list
apt-get update
apt-get install --allow-downgrades -y curl mina-devnet=${VERSION}

mina daemon --seed --proof-level none --rest-port 8080 &

# Update the graphql schema
num_retries=15
for ((i=1;i<=$num_retries;i++)); do
  sleep 15s
  set +e
  make update-graphql
  status_exit_code=$?
  set -e
  if [ $status_exit_code -eq 0 ]; then
    break
  elif [ $i -eq $num_retries ]; then
    exit $status_exit_code
  fi
done

kill %1

git diff --exit-code -- graphql_schema.json
