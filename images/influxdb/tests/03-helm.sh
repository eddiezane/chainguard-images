#!/usr/bin/env bash

# monopod:tag:k8s

set -o errexit -o nounset -o errtrace -o pipefail -x

function preflight() {
  if [[ "${IMAGE_REGISTRY}" == "" ]]; then
    echo "Must set IMAGE_REGISTRY environment variable. Exiting."
    exit 1
  fi

  if [[ "${IMAGE_REPOSITORY}" == "" ]]; then
    echo "Must set IMAGE_REPOSITORY environment variable. Exiting."
    exit 1
  fi

  if [[ "${IMAGE_TAG}" == "" ]]; then
    echo "Must set IMAGE_TAG environment variable. Exiting."
    exit 1
  fi
}

preflight

helm repo add influxdata https://helm.influxdata.com/

helm upgrade --install\
    influxdb influxdata/influxdb2 \
    --set image.repository="${IMAGE_REGISTRY}/${IMAGE_REPOSITORY}" \
    --set image.tag="${IMAGE_TAG}"

kubectl wait --for=condition=ready pod --selector app.kubernetes.io/instance=influxdb
