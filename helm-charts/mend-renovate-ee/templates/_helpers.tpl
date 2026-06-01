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
Expand the name of the worker configmap
*/}}
{{- define "mend-renovate.worker-configmap-name" -}}
{{- include "mend-renovate.fullname" . }}-config-js
{{- end -}}

{{/*
Expand the name of the worker configmap for a pooled worker deployment.
Input dict:
  root: full chart context
  worker: merged worker values for the current pool
*/}}
{{- define "mend-renovate.worker-configmap-name-for-pool" -}}
{{- if gt (len (default (list) .root.Values.renovateWorker.pools)) 0 -}}
{{- $poolName := required "renovateWorker.pools[].name is required when pools are configured" .worker.name -}}
{{- include "mend-renovate.worker-configmap-name" .root }}-{{ $poolName }}
{{- else -}}
{{- include "mend-renovate.worker-configmap-name" .root -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the worker secret for a pooled worker deployment.
Input dict:
  root: full chart context
  worker: merged worker values for the current pool
*/}}
{{- define "mend-renovate.worker-secret-name-for-pool" -}}
{{- if .worker.existingSecret -}}
{{- .worker.existingSecret -}}
{{- else if gt (len (default (list) .root.Values.renovateWorker.pools)) 0 -}}
{{- $poolName := required "renovateWorker.pools[].name is required when pools are configured" .worker.name -}}
{{- include "mend-renovate.name" .root }}-worker-{{ $poolName }}
{{- else -}}
{{- include "mend-renovate.worker-secret-name" .root -}}
{{- end -}}
{{- end -}}

{{/*
Validate worker pools configuration.
*/}}
{{- define "mend-renovate.validate-worker-pools" -}}
{{- $workerPools := default (list) .Values.renovateWorker.pools -}}
{{- $workerPoolNames := dict -}}

{{- range $pool := $workerPools -}}
  {{- $poolName := required "renovateWorker.pools[].name is required when pools are configured" $pool.name -}}
  
  {{- if hasKey $workerPoolNames $poolName -}}
    {{- fail (printf "duplicate renovateWorker.pools[].name %q is not allowed" $poolName) -}}
  {{- end -}}
  
  {{- $_ := set $workerPoolNames $poolName true -}}
  
  {{- if and (kindIs "map" $pool) (hasKey $pool "serviceAccount") -}}
    {{- fail (printf "renovateWorker.pools[%s].serviceAccount is not supported; use renovateWorker.serviceAccount for all worker pools" $poolName) -}}
  {{- end -}}
  
  {{- if and (kindIs "map" $pool) (hasKey $pool "npmrc") -}}
    {{- fail (printf "renovateWorker.pools[%s].npmrc is not supported; use renovateWorker.npmrc at root level" $poolName) -}}
  {{- end -}}
  
  {{- if and (kindIs "map" $pool) (hasKey $pool "npmrcExistingSecret") -}}
    {{- fail (printf "renovateWorker.pools[%s].npmrcExistingSecret is not supported; use renovateWorker.npmrcExistingSecret at root level" $poolName) -}}
  {{- end -}}
  
  {{- if and (kindIs "map" $pool) (hasKey $pool "extraDeploy") -}}
    {{- fail (printf "renovateWorker.pools[%s].extraDeploy is not supported; use extraDeploy at root level" $poolName) -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the web secret
*/}}
{{- define "mend-renovate.web-secret-name" -}}
{{- if .Values.renovateWeb.existingSecret -}}
{{- .Values.renovateWeb.existingSecret -}}
{{- else -}}
{{- include "mend-renovate.name" . }}-web
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
Expand the name of the worker service account.
*/}}
{{- define "mend-renovate.worker-service-account-name" -}}
{{- if .Values.renovateWorker.serviceAccount.create -}}
{{- include "mend-renovate.name" . }}-worker-sa
{{- else -}}
{{- .Values.renovateWorker.serviceAccount.existingName -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the web service account
*/}}
{{- define "mend-renovate.web-service-account-name" -}}
{{- if .Values.renovateWeb.serviceAccount.create -}}
{{- include "mend-renovate.name" . }}-web-sa
{{- else -}}
{{- .Values.renovateWeb.serviceAccount.existingName -}}
{{- end -}}
{{- end -}}
