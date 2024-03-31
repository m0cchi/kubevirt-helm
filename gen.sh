#!/usr/bin/env bash

set -e

which curl sed > /dev/null

cd $(cd $(dirname $0); pwd)/templates

export RELEASE=$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)

curl -LO https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-operator.yaml
sed -i -E "s/namespace:\s*?kubevirt/namespace: {{ .Release.Namespace | quote }}/g" kubevirt-operator.yaml

curl -LO https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-cr.yaml
sed -i -E "s/namespace:\s*?kubevirt/namespace: {{ .Release.Namespace | quote }}/g" kubevirt-cr.yaml
