{{/*
Expand the name of the chart.
*/}}
{{- define "bluemap.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "bluemap.fullname" -}}
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
{{- define "bluemap.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "bluemap.labels" -}}
helm.sh/chart: {{ include "bluemap.chart" . }}
{{ include "bluemap.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "bluemap.selectorLabels" -}}
app.kubernetes.io/name: {{ include "bluemap.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "bluemap.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "bluemap.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generates ConfigMap templates from bluemap.config, either from content or an existing ConfigMap reference
*/}}
{{- define "bluemap.configmaps" -}}
{{- range $i, $cfg := .Values.bluemap.config }}
{{- if $cfg.content }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: bluemap-config-{{ $i }}
data:
  {{ base $cfg.path }}: |
{{ $cfg.content | indent 4 }}
{{- else if $cfg.configMap }}
# Existing ConfigMap is used, no generation needed
{{- end }}
{{- end }}
{{- end }}

{{/*
Generates VolumeMounts for the ConfigMaps
*/}}
{{- define "bluemap.configmapVolumeMounts" -}}
{{- range $i, $cfg := .Values.bluemap.config }}
{{- if $cfg.content }}
- name: bluemap-config-{{ $i }}
  mountPath: {{ $cfg.path }}
  subPath: {{ base $cfg.path }}
{{- else if $cfg.configMap }}
- name: {{ $cfg.configMap.name }}
  mountPath: {{ $cfg.path }}
  subPath: {{ $cfg.configMap.key }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generates Volumes for the ConfigMaps
*/}}
{{- define "bluemap.configmapVolumes" -}}
{{- range $i, $cfg := .Values.bluemap.config }}
{{- if $cfg.content }}
- name: bluemap-config-{{ $i }}
  configMap:
    name: bluemap-config-{{ $i }}
{{- else if $cfg.configMap }}
- name: {{ $cfg.configMap.name }}
  configMap:
    name: {{ $cfg.configMap.name }}
{{- end }}
{{- end }}
{{- end }}
