{{- define "application-service.name" -}}
application-service
{{- end }}

{{- define "application-service.fullname" -}}
{{- printf "%s-%s" .Release.Name "application-service" | trunc 63 | trimSuffix "-" -}}
{{- end }}
