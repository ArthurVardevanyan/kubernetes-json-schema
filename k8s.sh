#!/usr/bin/env bash

set -o errexit # exit on any failure. Same as set -e
# set -o xtrace  # command tracing. Same as set -x

# Modified from: https://github.com/yannh/kubernetes-json-schema/blob/master/build.sh

K8S_VERSIONS=$(git ls-remote --refs --tags https://github.com/kubernetes/kubernetes.git | cut -d/ -f3 | grep -e '^v1\.[0-9]\{2\}\.[0-9]\{1,2\}$' | grep -v -e '^v1\.1[0-8]\{1\}' | tail -n1)
OPENAPI2JSONSCHEMABIN="podman run --rm --platform linux/amd64 -i -v ${PWD}:/out:z ghcr.io/yannh/openapi2jsonschema:latest"

if [[ -n "${K8S_VERSION_PREFIX}" ]]; then
  K8S_VERSIONS=$(git ls-remote --refs --tags https://github.com/kubernetes/kubernetes.git | cut -d/ -f3 | grep -e '^'"${K8S_VERSION_PREFIX}" | grep -e '^v1\.[0-9]\{2\}\.[0-9]\{1,2\}$')
fi
export K8S_VERSIONS
for K8S_VERSION in "${K8S_VERSIONS}" master; do
  SCHEMA=https://raw.githubusercontent.com/kubernetes/kubernetes/${K8S_VERSION}/api/openapi-spec/swagger.json
  # PREFIX=https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/${K8S_VERSION}/_definitions.json

  if [[ ! -d "${K8S_VERSION}-standalone-strict" ]]; then
    ${OPENAPI2JSONSCHEMABIN} -o "master-standalone-strict" --expanded --kubernetes --stand-alone --strict "${SCHEMA}"
    ${OPENAPI2JSONSCHEMABIN} -o "master-standalone-strict" --kubernetes --stand-alone --strict "${SCHEMA}"
  fi

  if [[ ! -d "${K8S_VERSION}-local" ]]; then
    ${OPENAPI2JSONSCHEMABIN} -o "master-local/" --expanded --kubernetes "${SCHEMA}"
    ${OPENAPI2JSONSCHEMABIN} -o "master-local" --kubernetes "${SCHEMA}"
  fi
done
