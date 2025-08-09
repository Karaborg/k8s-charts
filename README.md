# Kubernetes + Helm ile Grafana & Prometheus Kurulumu (Kind üzerinde)

## Ortam Kurulumu
- **MacOS** üzerinde çalışıldı.
- Kind, kubectl, helm kurulu olmalı.
- Docker Desktop arka planda çalışır durumda olmalı.

---

## Cluster Oluşturma
Port-forward kullanmadan erişebilmek için `extraPortMappings` ile kind config oluşturduk.

**kind-config.yaml**
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
    - containerPort: 30080
      hostPort: 30080
      protocol: TCP
    - containerPort: 30476
      hostPort: 30476
      protocol: TCP
```

## Cluster’ı başlattık
```bash
kind create cluster --name monitoring-cluster --config kind-config.yaml
```

## Namespace’leri Oluşturma
```bash
kubectl create namespace monitoring
kubectl create namespace grafana
```

## Helm Chart’ları Lokal’e İndirme
```bash
helm pull grafana/grafana --untar
helm pull prometheus-community/prometheus --untar
```
Bu sayede chart yapısını (Chart.yaml, values.yaml, templates/) görebildik.

## Prometheus Kurulumu
NodePort ayarıyla kurulum:
```bash
helm upgrade --install prom ./prometheus -n monitoring \
  --set server.service.type=NodePort \
  --set server.service.nodePort=30476 \
  --set server.service.servicePort=80
```
Erişim:
http://localhost:30476

## Grafana Kurulumu
Zsh ile uyumlu tek satırlık komut:
```bash
helm upgrade --install gfn ./grafana -n grafana \
  --set adminUser=admin \
  --set adminPassword=admin123 \
  --set service.type=NodePort \
  --set service.nodePort=30080 \
  --set 'datasources.datasources\.yaml.apiVersion'=1 \
  --set 'datasources.datasources\.yaml.datasources[0].name'=Prometheus \
  --set 'datasources.datasources\.yaml.datasources[0].type'=prometheus \
  --set 'datasources.datasources\.yaml.datasources[0].url'=http://prom-prometheus-server.monitoring.svc.cluster.local \
  --set 'datasources.datasources\.yaml.datasources[0].access'=proxy \
  --set 'datasources.datasources\.yaml.datasources[0].isDefault'=true
```
Erişim:
http://localhost:30080 (admin / admin123)

## Doğrulama
Pod ve servis durumlarını kontrol ettik:
```bash
kubectl -n monitoring get pods,svc
kubectl -n grafana get pods,svc
```
Grafana arayüzünden:

Data Sources → Prometheus → Save & Test

Dashboards → Import → 1860 (Node Exporter Full)

## Öğrendiklerimiz
- Helm Chart yapısını (values.yaml, templates/) lokal indirerek inceledik.
- NodePort sadece 30000–32767 arasında olabilir; kind ile extraPortMappings sayesinde localhost’ta sabit portlardan eriştik.
- Zsh ile --set kullanırken özel karakterli key’leri tek tırnak içine almak gerekiyor.
- Prometheus ve Grafana’yı ayrı namespace’lere kurmak yönetimi kolaylaştırıyor.
- helm get values ve helm get manifest ile Kubernetes’e uygulanan konfigürasyonu görebiliyoruz.

