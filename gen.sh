#!/usr/bin/env bash

set -e

which curl sed > /dev/null

cd $(cd $(dirname $0); pwd)/templates

export RELEASE=$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)

curl -LO https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-operator.yaml
sed -i -E "s/^\s\sname: kubevirt$/  name: {{ .Release.Namespace | quote }}/" kubevirt-operator.yaml
sed -i -E "s/namespace:\s*?kubevirt/namespace: {{ .Release.Namespace | quote }}/g" kubevirt-operator.yaml

curl -LO https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-cr.yaml
sed -i -E "s/namespace:\s*?kubevirt/namespace: {{ .Release.Namespace | quote }}/g" kubevirt-cr.yaml

export CDI_VERSION=$(curl -s https://api.github.com/repos/kubevirt/containerized-data-importer/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

curl -LO https://github.com/kubevirt/containerized-data-importer/releases/download/$CDI_VERSION/cdi-operator.yaml
sed -i -E "s/^\s\sname:\s*?cdi$/  name: {{ .Values.cdi.namespaceName }}/" cdi-operator.yaml
sed -i -E "s/namespace:\s*?cdi/namespace: {{ .Values.cdi.namespaceName }}/g" cdi-operator.yaml
cat <<EOS > cdi-operator.yaml
{{- if .Values.cdi.created }}
$(cat cdi-operator.yaml)
{{- end }}
EOS

curl -LO https://github.com/kubevirt/containerized-data-importer/releases/download/$CDI_VERSION/cdi-cr.yaml
sed -i -E "s/namespace:\s*?cdi/namespace: {{ .Values.cdi.namespaceName }}/g" cdi-cr.yaml
cat <<EOS > cdi-cr.yaml
{{- if and .Values.cdi.created .Values.cdiCr.created }}
$(cat cdi-cr.yaml)
{{- end }}
EOS
