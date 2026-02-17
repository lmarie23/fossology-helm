{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "fossology.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fossology.fullname" -}}
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
{{- define "fossology.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "fossology.labels" -}}
helm.sh/chart: {{ include "fossology.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "fossology.dbname" -}}
{{ include "fossology.fullname" . }}-db
{{- end -}}

{{/*
Database host helper - returns CNPG cluster service name if enabled, otherwise uses configured host
*/}}
{{- define "fossology.dbhost" -}}
{{- if and .Values.postgresql.enabled .Values.postgresql.name -}}
{{- printf "%s-rw" .Values.postgresql.name -}}
{{- else -}}
{{- .Values.fossology.db_host -}}
{{- end -}}
{{- end -}}

{{/*
Database name helper - returns CNPG database name if enabled, otherwise uses configured name
*/}}
{{- define "fossology.database" -}}
{{- if and .Values.postgresql.enabled .Values.postgresql.database -}}
{{- .Values.postgresql.database -}}
{{- else -}}
{{- .Values.fossology.db_name -}}
{{- end -}}
{{- end -}}

{{/*
Database username helper - returns CNPG username if enabled, otherwise uses configured username
*/}}
{{- define "fossology.dbuser" -}}
{{- if and .Values.postgresql.enabled .Values.postgresql.username -}}
{{- .Values.postgresql.username -}}
{{- else -}}
{{- .Values.fossology.db_user -}}
{{- end -}}
{{- end -}}
