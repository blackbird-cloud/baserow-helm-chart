{{/*
Expand the name of the chart.
*/}}
{{- define "baserow.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the namespace of the chart.
*/}}
{{- define "baserow.namespace" -}}
{{- default .Release.Namespace .Values.namespace }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "baserow.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "baserow.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "baserow.labels" -}}
helm.sh/chart: {{ include "baserow.chart" . }}
{{ include "baserow.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "baserow.selectorLabels" -}}
app.kubernetes.io/name: {{ include "baserow.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "baserow.serviceAccountName" -}}
{{- if not .Values.global.baserow.serviceAccount.shared -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "baserow.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{ else }}
{{- default "default" .Values.global.baserow.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Create command for readiness probe
*/}}
{{- define "baserow.readinessProbeCommand" -}}
{{- $command := .Values.readinessProbe.command }}
{{- if $command }}
{{- printf "command:" | nindent 4 -}}
{{- toYaml $command | nindent 6 -}}
{{ else }}
{{- printf "command:" | nindent 4 -}}
{{- printf "- /bin/bash" | nindent 6 -}}
{{- printf "- -c" | nindent 6 -}}
{{- printf "- /baserow/backend/docker/docker-entrypoint.sh backend-healthcheck" | nindent 6 -}}
{{- end }}
{{- end }}

{{/*
Create full readinessProbe
*/}}
{{- define "baserow.readinessProbe" -}}
{{- if .Values.readinessProbe }}
readinessProbe:
  exec: {{ include "baserow.readinessProbeCommand" . }}
  initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds }}
  periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
  timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
  successThreshold: {{ .Values.readinessProbe.successThreshold }}
  failureThreshold: {{ .Values.readinessProbe.failureThreshold }}
{{- end }}
{{- end }}

{{/*
Create command for liveness probe
*/}}
{{- define "baserow.livenessProbeCommand" -}}
{{- $command := .Values.livenessProbe.command }}
{{- if $command }}
{{- printf "command:" | nindent 4 -}}
{{- toYaml $command | nindent 6 -}}
{{ else }}
{{- printf "command:" | nindent 4 -}}
{{- printf "- /bin/bash" | nindent 6 -}}
{{- printf "- -c" | nindent 6 -}}
{{- printf "- /baserow/backend/docker/docker-entrypoint.sh backend-healthcheck" | nindent 6 -}}
{{- end }}
{{- end }}

{{/*
Create full livenessProbe
*/}}
{{- define "baserow.livenessProbe" -}}
{{- if .Values.livenessProbe }}
livenessProbe:
  exec: {{ include "baserow.livenessProbeCommand" . }}
  initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
  periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
  timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
  successThreshold: {{ .Values.livenessProbe.successThreshold }}
  failureThreshold: {{ .Values.livenessProbe.failureThreshold }}
{{- end }}
{{- end }}

{{/*
Image Pull secrets combine the global and local imagePullSecrets
*/}}
{{- define "baserow.imagePullSecrets" -}}
{{- $global := .Values.global.baserow.imagePullSecrets }}
{{- $local := .Values.imagePullSecrets }}
{{- if and $global $local }}
{{- $all := concat $global $local -}}
{{- toYaml $all | nindent 8}}
{{- else if $global }}
{{- toYaml $global | nindent 8}}
{{- else if $local }}
{{- toYaml $local | nindent 8}}
{{- end }}
{{- end }}

{{/*
Create image url to use
*/}}
{{- define "baserow.image" -}}
{{- if and .Values.global.baserow.imageRegistry .Values.global.baserow.image.tag -}}
{{- printf "%s/%s:%s" .Values.global.baserow.imageRegistry .Values.image.repository .Values.global.baserow.image.tag }}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag }}
{{- end }}
{{- end }}

{{/*
Create envFrom options
*/}}
{{- define "baserow.envFrom" -}}
{{- if .Values.mountConfiguration.backend -}}
- configMapRef:
    name: {{ .Values.global.baserow.backendConfigMap }}
- secretRef:
    name: {{ .Values.global.baserow.backendSecret }}
{{ end }}
{{- if .Values.mountConfiguration.frontend -}}
- configMapRef:
    name: {{ .Values.global.baserow.frontendConfigMap }}
{{ end }}
{{- if .Values.global.baserow.envFrom }}
{{ toYaml .Values.global.baserow.envFrom }}
{{- end }}
{{- if .Values.envFrom }}
{{ toYaml .Values.envFrom }}
{{- end }}
{{- end }}

# {{/*
# Return the name for the user to use
# */}}
# {{- define "baserow.postgresql.username" -}}
#   {{- if .Values.postgresql.enabled -}}
#     {{- printf "%s" (include "postgresql.v1.username" .Subcharts.postgresql) -}}
#   {{- else -}}
#     {{- printf "%s" (tpl .Values.externalPostgresql.auth.username $) -}}
#   {{- end -}}
# {{- end -}}

# {{/*
# Get the name of the secret containing the postgresql user password
# */}}
# {{- define "baserow.postgresql.secretName" -}}
#   {{- if .Values.postgresql.enabled -}}
#     {{- printf "%s" (include "postgresql.v1.secretName" .Subcharts.postgresql) -}}
#   {{- else if .Values.externalPostgresql.auth.existingSecret -}}
#     {{- printf "%s" (tpl .Values.externalPostgresql.auth.existingSecret $) -}}
#   {{- else -}}
#       {{- printf "%s" (include "baserow.fullname" .) -}}-postgresql
#   {{- end -}}
# {{- end -}}

# {{/*
# Get the user-password key for the postgresql user password
# */}}
# {{- define "baserow.postgresql.userPasswordKey" -}}
#   {{- if .Values.postgresql.enabled -}}
#     {{- printf "%s" (include "postgresql.v1.userPasswordKey" .Subcharts.postgresql) -}}
#   {{- else if .Values.externalPostgresql.auth.userPasswordKey -}}
#     {{- printf "%s" (tpl .Values.externalPostgresql.auth.userPasswordKey $) -}}
#   {{- else -}}
#     {{- "password" -}}
#   {{- end -}}
# {{- end -}}

# {{/*
# Return the hostname of the redis to use
# */}}
# {{- define "baserow.redis.hostname" -}}
#   {{- if .Values.redis.enabled -}}
#     {{- printf "%s-master" (include "common.names.fullname" .Subcharts.redis) -}}
#   {{- else -}}
#     {{- printf "%s" (tpl .Values.externalRedis.hostname $) -}}
#   {{- end -}}
# {{- end -}}

# {{/*
# Return redis service port
# */}}
# {{- define "baserow.redis.port" -}}
#   {{- if .Values.redis.enabled -}}
#     {{- printf "%s" (tpl (toString .Values.redis.master.service.ports.redis) $) -}}
#   {{- else -}}
#     {{- printf "%s" (tpl (toString .Values.externalRedis.port) $) -}}
#   {{- end -}}
# {{- end -}}

# {{/*
# Get the user-password key for the redis password
# */}}
# {{- define "baserow.redis.auth.enabled" -}}
#   {{- if or (and (.Values.redis.enabled) (.Values.redis.auth.enabled)) (and (not .Values.redis.enabled) (.Values.externalRedis.auth.enabled)) -}}
#     {{- printf "true" -}}
#   {{- else -}}
#     {{- printf "false" -}}
#   {{- end -}}
# {{- end -}}

# {{/*
# Get the name of the secret containing the redis password
# */}}
# {{- define "baserow.redis.secretName" -}}
#   {{- if .Values.redis.enabled -}}
#     {{- printf "%s" (include "redis.secretName" .Subcharts.redis) -}}
#   {{- else if .Values.externalRedis.auth.existingSecret -}}
#     {{- printf "%s" (tpl .Values.externalRedis.auth.existingSecret $) -}}
#   {{- else -}}
#       {{- printf "%s" (include "baserow.fullname" .) -}}-redis
#   {{- end -}}
# {{- end -}}

# {{/*
# Get the user-password key for the redis password
# */}}
# {{- define "baserow.redis.userPasswordKey" -}}
#   {{- if .Values.redis.enabled -}}
#     {{- printf "%s" (include "redis.secretPasswordKey" .Subcharts.redis) -}}
#   {{- else if .Values.externalRedis.auth.userPasswordKey -}}
#     {{- printf "%s" (tpl .Values.externalRedis.auth.userPasswordKey $) -}}
#   {{- else -}}
#     {{- "password" -}}
#   {{- end -}}
# {{- end -}}
