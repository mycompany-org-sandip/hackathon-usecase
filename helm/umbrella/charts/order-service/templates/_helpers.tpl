{{- define "order-service.name" -}}
order-service
{{- end }}

{{- define "order-service.fullname" -}}
{{- printf "%s-%s" .Release.Name "order-service" | trunc 63 | trimSuffix "-" -}}
{{- end }}
