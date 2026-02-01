{{/* Devuelve el nombre completo de la app incluyendo release */}}
{{- define "fastapi-service1.fullname" -}}
{{ .Release.Name }}
{{- end }}

{{/* Devuelve etiquetas comunes */}}
{{- define "fastapi-service1.labels" -}}
app.kubernetes.io/name: {{ include "fastapi-service1.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
