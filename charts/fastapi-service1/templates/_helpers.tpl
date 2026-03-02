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
Labels shared between Deployment and Service
*/}}
{{- define "fastapi-service1.labels" -}}
app: fastapi-service1
{{- end }}
