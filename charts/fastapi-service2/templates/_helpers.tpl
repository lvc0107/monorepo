{{/*
Base chart name
*/}}
{{- define "fastapi-service2.name" -}}
fastapi-service2
{{- end }}

{{/*
Full release name
*/}}
{{- define "fastapi-service2.fullname" -}}
{{- printf "%s" (include "fastapi-service2.name" .) -}}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fastapi-service2.labels" -}}
app: {{ include "fastapi-service2.name" . }}
release: {{ .Release.Name }}
chart: {{ .Chart.Name }}-{{ .Chart.Version }}
version: {{ .Chart.AppVersion }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fastapi-service2.selectorLabels" -}}
app: {{ include "fastapi-service2.name" . }}
{{- end }}
