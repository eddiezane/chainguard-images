#!/usr/bin/env bash

set -o errexit -o nounset -o errtrace -o pipefail -x

if [[ "${IMAGE_NAME}" == "" ]]; then
    echo "Must set IMAGE_NAME environment variable. Exiting."
    exit 1
fi

CONTAINER_NAME=${CONTAINER_NAME:-"prometheus-smoketest-$(date +%s)"}

docker run -p 9090:9090 -d --name $CONTAINER_NAME $IMAGE_NAME --config.file=/etc/prometheus/prometheus.yml
trap "docker logs $CONTAINER_NAME && docker rm -f $CONTAINER_NAME" EXIT
sleep 5
curl -L localhost:9090/-/healthy | grep "Prometheus Server is Healthy."
