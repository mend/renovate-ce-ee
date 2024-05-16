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
Expand the name of the default secret
*/}}
{{- define "mend-renovate.secret-name" -}}
{{- if .Values.renovate.existingSecret -}}
{{- .Values.renovate.existingSecret -}}
{{- else -}}
{{- include "mend-renovate.name" . -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the npmrc secret
*/}}
{{- define "mend-renovate.npmrc-secret-name" -}}
{{- if .Values.renovate.npmrcExistingSecret -}}
{{- .Values.renovate.npmrcExistingSecret -}}
{{- else -}}
{{- include "mend-renovate.name" . }}-npmrc
{{- end -}}
{{- end -}}

{{/*
Expand the name of the service account
*/}}
{{- define "mend-renovate.service-account-name" -}}
{{- if eq "string" (printf "%T" .Values.serviceAccount) -}}
{{- .Values.serviceAccount -}}
{{- else if .Values.serviceAccount.create -}}
{{- include "mend-renovate.name" . }}-sa
{{- else -}}
{{- .Values.serviceAccount.existingName -}}
{{- end -}}
{{- end -}}
