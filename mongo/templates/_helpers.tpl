{{- define "mongo-mongodb.labels" -}}
app.kubernetes.io/name: mongo-mongodb
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
