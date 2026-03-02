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
Labels shared between Deployment and Service
*/}}
{{- define "fastapi-service2.labels" -}}
app: fastapi-service2
{{- end }}
