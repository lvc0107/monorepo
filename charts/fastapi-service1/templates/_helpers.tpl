{{/*
Base chart name
*/}}
{{- define "fastapi-service1.name" -}}
fastapi-service1
{{- end }}

{{/*
Full release name
*/}}
{{- define "fastapi-service1.fullname" -}}
{{- printf "%s" (include "fastapi-service1.name" .) -}}
{{- end }}

{{/*
Labels compartidos entre Deployment y Service
*/}}
{{- define "fastapi-service1.labels" -}}
app: fastapi-service1
{{- end }}
