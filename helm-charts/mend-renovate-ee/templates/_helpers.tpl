{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mend-renovate.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mend-renovate.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mend-renovate.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the license secret
*/}}
{{- define "mend-renovate.license-secret-name" -}}
{{- if .Values.license.existingSecret -}}
{{- .Values.license.existingSecret -}}
{{- else -}}
{{- include "mend-renovate.name" . }}-license
{{- end -}}
{{- end -}}

{{/*
Expand the name of the server secret
*/}}
{{- define "mend-renovate.server-secret-name" -}}
{{- if .Values.renovateServer.existingSecret -}}
{{- .Values.renovateServer.existingSecret -}}
{{- else -}}
{{- include "mend-renovate.name" . }}-server
{{- end -}}
{{- end -}}

{{/*
Expand the name of the worker secret
*/}}
{{- define "mend-renovate.worker-secret-name" -}}
{{- if .Values.renovateWorker.existingSecret -}}
{{- .Values.renovateWorker.existingSecret -}}
{{- else -}}
{{- include "mend-renovate.name" . }}-worker
{{- end -}}
{{- end -}}

{{/*
Expand the name of the npmrc secret
*/}}
{{- define "mend-renovate.npmrc-secret-name" -}}
{{- if .Values.renovateWorker.npmrcExistingSecret -}}
{{- .Values.renovateWorker.npmrcExistingSecret -}}
{{- else -}}
{{- include "mend-renovate.name" . }}-npmrc
{{- end -}}
{{- end -}}

{{/*
Expand the name of the server service account
*/}}
{{- define "mend-renovate.server-service-account-name" -}}
{{- if .Values.renovateServer.serviceAccount.create -}}
{{- include "mend-renovate.name" . }}-server-sa
{{- else -}}
{{- .Values.renovateServer.serviceAccount.existingName -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the worker service account
*/}}
{{- define "mend-renovate.worker-service-account-name" -}}
{{- if .Values.renovateWorker.serviceAccount.create -}}
{{- include "mend-renovate.name" . }}-worker-sa
{{- else -}}
{{- .Values.renovateWorker.serviceAccount.existingName -}}
{{- end -}}
{{- end -}}
