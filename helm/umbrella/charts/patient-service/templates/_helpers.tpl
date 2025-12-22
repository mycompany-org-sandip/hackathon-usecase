{{- define "patient-service.name" -}}
patient-service
{{- end }}

{{- define "patient-service.fullname" -}}
{{- printf "%s-%s" .Release.Name "patient-service" | trunc 63 | trimSuffix "-" -}}
{{- end }}
