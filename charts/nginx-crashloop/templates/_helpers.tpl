{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "nginx-crashloop.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nginx-crashloop.fullname" -}}
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
{{- define "nginx-crashloop.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Flask Common labels
*/}}
{{- define "nginx-crashloop.flask.labels" -}}
helm.sh/chart: {{ include "nginx-crashloop.chart" . }}
{{ include "nginx-crashloop.flask.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Flask Selector labels
*/}}
{{- define "nginx-crashloop.flask.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nginx-crashloop.name" . }}-flask
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "nginx-crashloop.flask.image" -}}
{{- include "image_for_component" (dict "root" . "component" "flask") -}}
{{- end -}}

{{/*
Nginx Common labels
*/}}
{{- define "nginx-crashloop.nginx.labels" -}}
helm.sh/chart: {{ include "nginx-crashloop.chart" . }}
{{ include "nginx-crashloop.nginx.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Nginx Selector labels
*/}}
{{- define "nginx-crashloop.nginx.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nginx-crashloop.name" . }}-nginx
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "nginx-crashloop.nginx.image" -}}
{{- include "image_for_component" (dict "root" . "component" "nginx") -}}
{{- end -}}

{{/* 
Use like: {{ include "define_component_image" (dict "root" . "component" "<component_name>" }}
*/}}
{{- define "image_for_component" -}}
{{- $overrideValue := tpl (printf "{{- .Values.%s.image.overrideValue -}}" .component) .root }}
{{- if $overrideValue }}
    {{- $overrideValue -}}
{{- else -}}
    {{- $imageRegistry := tpl (printf "{{- .Values.%s.image.registry -}}" .component) .root -}}
    {{- $imageRepository := tpl (printf "{{- .Values.%s.image.repository -}}" .component) .root -}}
    {{- $imageTag := tpl (printf "{{- .Values.%s.image.tag -}}" .component) .root -}}
    {{- $globalRegistry := (default .root.Values.global dict).imageRegistry -}}
    {{- $globalRegistry | default $imageRegistry | default "docker.io" -}} / {{- $imageRepository -}} : {{- $imageTag -}}
{{- end -}}
{{- end -}}