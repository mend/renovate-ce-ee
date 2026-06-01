{{/*
Build merged worker values for a specific pool.

Input dict:
  root: full chart context
  poolName: target pool name

Behavior:
  - Base worker values are .Values.renovateWorker with pools omitted.
  - If pools are configured, the named pool is merged over the base.
  - If pools are configured and the pool is missing, template rendering fails.
  - If pools are not configured, the base worker map is returned.

Usage:
  {{- $worker := include "mend-renovate.worker-for-pool" (dict "root" . "poolName" "main") | fromYaml -}}
  {{- $_ := set $worker "mendRnvSingleJobWorker" true -}}
  {{- $_ := set $worker "restartPolicy" "Never" -}}
  {{ include "mend-renovate.worker-pod-spec" (dict "root" . "worker" $worker) }}
*/}}
{{- define "mend-renovate.worker-for-pool" -}}
{{- $root := .root -}}
{{- $poolName := required "mend-renovate.worker-for-pool: poolName is required" .poolName -}}

{{- $baseWorker := mustDeepCopy (omit $root.Values.renovateWorker "pools") -}}
{{- $workerPools := default (list) $root.Values.renovateWorker.pools -}}

{{- $state := dict "found" false "pool" (dict) -}}

{{- range $pool := $workerPools -}}
  {{- if and (kindIs "map" $pool) (eq (default "" $pool.name) $poolName) -}}
    {{- $_ := set $state "pool" (mustDeepCopy $pool) -}}
    {{- $_ := set $state "found" true -}}
  {{- end -}}
{{- end -}}

{{- $hasPools := gt (len $workerPools) 0 -}}
{{- $poolFound := index $state "found" -}}
{{- if and $hasPools (not $poolFound) -}}
  {{- fail (printf "renovateWorker.pools are configured, but pool %q was not found in renovateWorker.pools[].name" $poolName) -}}
{{- end -}}

{{- if index $state "found" -}}
{{- mustMergeOverwrite (mustDeepCopy $baseWorker) (index $state "pool") | toYaml -}}
{{- else -}}
{{- toYaml $baseWorker -}}
{{- end -}}
{{- end -}}


{{/*
Render the worker pod inner template.spec for reuse across Deployment and custom manifests.
Input dict:
  root: full chart context
  worker: merged worker values for the current pool (or root worker values)
*/}}
{{- define "mend-renovate.worker-pod-spec" -}}
{{- $root := required "mend-renovate.worker-pod-spec: root is required" .root -}}
{{- $renovateWorker := required "mend-renovate.worker-pod-spec: worker is required" .worker -}}
automountServiceAccountToken: {{ $renovateWorker.automountServiceAccountToken | default false }}
{{- with $renovateWorker.podSecurityContext }}
securityContext: {{- toYaml . | nindent 2 }}
{{- end }}
terminationGracePeriodSeconds: {{ $renovateWorker.terminationGracePeriodSeconds }}
{{- if $renovateWorker.restartPolicy }}
restartPolicy: {{ $renovateWorker.restartPolicy | quote }}
{{- end }}
{{- if or $root.Values.renovateWorker.serviceAccount.create $root.Values.renovateWorker.serviceAccount.existingName }}
serviceAccountName: {{ include "mend-renovate.worker-service-account-name" $root }}
{{- end }}
{{- with $renovateWorker.initContainers }}
initContainers: {{- toYaml . | nindent 2 }}
{{- end }}
containers:
  - name: {{ $root.Chart.Name }}-worker
    image: "{{ $renovateWorker.image.repository }}:{{ $renovateWorker.image.version }}"
    imagePullPolicy: {{ $renovateWorker.image.pullPolicy }}
    {{- with $renovateWorker.containerSecurityContext }}
    securityContext: {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- if or $renovateWorker.extraEnvFromConfigMaps $renovateWorker.extraEnvFromSecrets }}
    envFrom:
    {{- with $renovateWorker.extraEnvFromConfigMaps }}
      {{- range . }}
      - configMapRef:
          name: {{ .name }}
      {{- end }}
    {{- end }}
    {{- with $renovateWorker.extraEnvFromSecrets }}
      {{- range . }}
      - secretRef:
          name: {{ .name }}
      {{- end }}
    {{- end }}
    {{- end }}
    env:
      {{- with $renovateWorker.extraEnvVars }}
      {{- toYaml . | nindent 6 }}
      {{- end }}
      - name: MEND_RNV_SERVER_HOSTNAME
        {{- $httpsPort := "" }}
        {{- $scheme := "http" }}
        {{- if or $renovateWorker.mendRnvClientHttpsConfig $renovateWorker.mendRnvClientHttpsConfigPath }}
          {{- $httpsPort = print ":" $root.Values.service.ports.https }}
          {{- $scheme = "https" }}
        {{- end }}
        value: "{{ $scheme }}://{{ include "mend-renovate.fullname" $root }}-svc-server{{ $httpsPort }}"
      {{- if or $root.Values.renovateServer.mendRnvServerApiSecret $root.Values.renovateServer.existingSecret }}
      - name: MEND_RNV_SERVER_API_SECRET
        valueFrom:
          secretKeyRef:
            name: {{ include "mend-renovate.server-secret-name" $root }}
            key: mendRnvServerApiSecret
      {{- end }}

      {{- if $root.Values.license.mendRnvAcceptTos }}
      - name: MEND_RNV_ACCEPT_TOS
        value: {{ $root.Values.license.mendRnvAcceptTos | quote }}
      {{- end }}
      {{- if or $root.Values.license.mendRnvLicenseKey $root.Values.license.existingSecret }}
      - name: MEND_RNV_LICENSE_KEY
        valueFrom:
          secretKeyRef:
            name: {{ include "mend-renovate.license-secret-name" $root }}
            key: mendRnvLicenseKey
      {{- end }}
      {{- if $renovateWorker.mendRnvWorkerCleanup }}
      - name: MEND_RNV_WORKER_CLEANUP
        value: {{ $renovateWorker.mendRnvWorkerCleanup | quote }}
      {{- end }}
      {{- if $renovateWorker.mendRnvWorkerCleanupDirs }}
      - name: MEND_RNV_WORKER_CLEANUP_DIRS
        value: {{ $renovateWorker.mendRnvWorkerCleanupDirs | quote }}
      {{- end }}
      {{- if $renovateWorker.mendRnvDiskUsageWarnThreshold }}
      - name: MEND_RNV_DISK_USAGE_WARN_THRESHOLD
        value: {{ $renovateWorker.mendRnvDiskUsageWarnThreshold | quote }}
      {{- end }}
      {{- if $renovateWorker.mendRnvDiskUsageFilter }}
      - name: MEND_RNV_DISK_USAGE_FILTER
        value: {{ $renovateWorker.mendRnvDiskUsageFilter | quote }}
      {{- end }}
      {{- if $renovateWorker.mendRnvExitInactiveCount }}
      - name: MEND_RNV_EXIT_INACTIVE_COUNT
        value: {{ $renovateWorker.mendRnvExitInactiveCount | quote }}
      {{- end }}
      {{- if $renovateWorker.mendRnvWorkerNodeArgs }}
      - name: RENOVATE_NODE_ARGS
        value: {{ $renovateWorker.mendRnvWorkerNodeArgs | quote }}
      {{- end }}
      {{- if $renovateWorker.mendRnvWorkerQueues }}
      - name: MEND_RNV_WORKER_QUEUES
        value: {{ $renovateWorker.mendRnvWorkerQueues | quote }}
      {{- end }}
      {{- if $renovateWorker.mendRnvSingleJobWorker }}
      - name: MEND_RNV_SINGLE_JOB_WORKER
        value: {{ $renovateWorker.mendRnvSingleJobWorker | quote }}
      {{- end }}

      {{- if or $renovateWorker.githubComToken $renovateWorker.existingSecret }}
      - name: GITHUB_COM_TOKEN
        valueFrom:
          secretKeyRef:
            name: {{ include "mend-renovate.worker-secret-name-for-pool" (dict "root" $root "worker" $renovateWorker) }}
            key: githubComToken
            optional: true
      {{- end }}
      {{- if or $renovateWorker.pipIndexUrl $renovateWorker.existingSecret }}
      - name: PIP_INDEX_URL
        valueFrom:
          secretKeyRef:
            name: {{ include "mend-renovate.worker-secret-name-for-pool" (dict "root" $root "worker" $renovateWorker) }}
            key: pipIndexUrl
            optional: true
      {{- end }}
      {{- if $renovateWorker.mendRnvWorkerExecutionTimeout }}
      - name: MEND_RNV_WORKER_EXECUTION_TIMEOUT
        value: {{ $renovateWorker.mendRnvWorkerExecutionTimeout | quote }}
      {{- end }}
      {{- if $renovateWorker.mendRnvDisableGlobalAgent }}
      - name: MEND_RNV_DISABLE_GLOBAL_AGENT
        value: {{ $renovateWorker.mendRnvDisableGlobalAgent | quote }}
      {{- end }}
      {{- if $renovateWorker.mendRnvEnableHttp2 }}
      - name: MEND_RNV_ENABLE_HTTP2
        value: {{ $renovateWorker.mendRnvEnableHttp2 | quote }}
      {{- end }}
      {{- if $renovateWorker.mendRnvClientHttpsConfig }}
      - name: MEND_RNV_CLIENT_HTTPS_CONFIG
        value: {{ toJson $renovateWorker.mendRnvClientHttpsConfig | quote }}
      {{- end }}
      {{- if $renovateWorker.mendRnvClientHttpsConfigPath }}
      - name: MEND_RNV_CLIENT_HTTPS_CONFIG_PATH
        value: {{ $renovateWorker.mendRnvClientHttpsConfigPath | quote }}
      {{- end }}
      {{- if $renovateWorker.noNodeTlsVerify }}
      - name: NODE_TLS_REJECT_UNAUTHORIZED
        value: '0'
      {{- end }}
      {{- if $renovateWorker.noGitTlsVerify }}
      - name: GIT_SSL_NO_VERIFY
        value: 'true'
      {{- end }}
      {{- if $renovateWorker.renovateUserAgent }}
      - name: RENOVATE_USER_AGENT
        value: {{ $renovateWorker.renovateUserAgent | quote }}
      {{- end }}
      {{- if $renovateWorker.logLevel }}
      - name: LOG_LEVEL
        value: {{ $renovateWorker.logLevel | quote }}
      {{- end }}
      {{- if $renovateWorker.logFormat }}
      - name: LOG_FORMAT
        value: {{ $renovateWorker.logFormat | quote }}
      {{- end }}
    ports:
      - name: ee-worker
        containerPort: 8080
        protocol: TCP
    {{- with $renovateWorker.livenessProbe }}
    livenessProbe:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with $renovateWorker.readinessProbe }}
    readinessProbe:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    resources:
      {{- toYaml $renovateWorker.resources | nindent 6 }}
    volumeMounts:
      - name: {{ $root.Release.Name }}-config-js-volume
        readOnly: true
        mountPath: /usr/src/app/config.js
        subPath: config.js
      {{- if or $renovateWorker.npmrc $renovateWorker.npmrcExistingSecret }}
      - name: {{ $root.Release.Name }}-npmrc-volume
        readOnly: true
        mountPath: /home/ubuntu/.npmrc
        subPath: .npmrc
      {{- end }}
      {{- if not $renovateWorker.disableCacheVolume }}
      - name: {{ $root.Release.Name }}-cache-volume
        readOnly: false
        mountPath: /tmp/renovate
      {{- end }}
      {{- with $renovateWorker.extraVolumeMounts }}
        {{- toYaml . | nindent 6 }}
      {{- end }}
{{- with $renovateWorker.nodeSelector }}
nodeSelector:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- if $renovateWorker.imagePullSecrets }}
imagePullSecrets:
  - name: {{ $renovateWorker.imagePullSecrets }}
{{- end }}
volumes:
  - name: {{ $root.Release.Name }}-config-js-volume
    configMap:
      name: {{ include "mend-renovate.worker-configmap-name-for-pool" (dict "root" $root "worker" $renovateWorker) }}
  {{- if or $renovateWorker.npmrc $renovateWorker.npmrcExistingSecret }}
  - name: {{ $root.Release.Name }}-npmrc-volume
    secret:
      secretName: {{ include "mend-renovate.npmrc-secret-name" $root }}
  {{- end }}
  {{- if not $renovateWorker.disableCacheVolume }}
  - name: {{ $root.Release.Name }}-cache-volume
    {{- if $root.Values.dataPersistence.enabled }}
    persistentVolumeClaim:
      claimName: {{ $root.Values.dataPersistence.existingClaim | default (printf "%s-data" (include "mend-renovate.fullname" $root)) }}
    {{- else if $root.Values.dataInMemory.enabled }}
    emptyDir:
      medium: Memory
    {{- else }}
    emptyDir: { }
    {{- end }}
  {{- end }}
{{- with $renovateWorker.extraVolumes }}
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $renovateWorker.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $renovateWorker.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}
