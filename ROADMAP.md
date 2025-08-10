# K8s Practice Project — Roadmap & Checklist

Bu belge, hedeflediğimiz pratik projenin yol haritası ve yapılacaklar listesidir. Odak: Node.js tabanlı custom web uygulaması, Kubernetes/Helm, ArgoCD (GitOps), Bitbucket CI, monitoring & observability, çoklu ortam (dev/test/prod) simülasyonu.

---

## 0) Proje Kapsamı ve Hedef Çıktılar
- [ ] Node.js uygulamasını Docker image olarak yeniden paketlemek (gerekirse refactor)
- [ ] DB entegrasyonu (MongoDB Atlas **veya** cluster içi Mongo): ayrı namespace ve güvenli erişim
- [ ] Kaynak kodu Bitbucket repo’suna taşıma; branch stratejisi: `feature/*`, `dev`, `test`, `main`
- [ ] Helm chart(lar) ile deploy (tek chart + environment-specific values)
- [ ] ArgoCD ile GitOps: dev/test/prod için ayrı Application tanımları
- [ ] CI/CD: Bitbucket Pipelines → Build/Test/Docker/Scan/Deploy
- [ ] Observability: Prometheus, Grafana, Loki (log), OTel + Jaeger (trace)
- [ ] Ingress + TLS (Let’s Encrypt) ve gerekiyorsa CDN (Cloudflare)
- [ ] HPA ve temel otomatik ölçekleme
- [ ] Basit load test (k6 veya Locust)

**Definition of Done (DoD)**
- [ ] `main` branch push → prod’e (onaylı) otomatik deploy
- [ ] `dev` branch push → dev’e otomatik deploy; `test` branch → test’e
- [ ] Dashboard’larda servis metrikleri + loglar + temel trace akıyor
- [ ] HPA aktif, basit load test raporu mevcut
- [ ] Tüm secret/config yönetimi şifreli ve version-controlled (SOPS/SealedSecrets)

---

## 1) Repo ve Kod Taşıma
- [ ] Bitbucket’ta mono-repo mu multi-repo mu kararı (varsayılan: mono-repo)
- [ ] Klasör yapısı:
    - `/app` (Node.js kaynak)
    - `/helm/<app-name>` (chart)
    - `/env/dev|test|prod/values.yaml`
    - `/infra/monitoring` (prom/grafana/loki/tempo/jaeger/otel-collector)
    - `/argo/applications` (ArgoCD manifests)
    - `/pipelines` (Bitbucket pipeline templates)
- [ ] Dockerfile (multi-stage), `.dockerignore`
- [ ] Container healthcheck endpoint

---

## 2) Secrets ve Config Yönetimi (Öneri 1)
- [ ] Seçim: **SOPS** (age/GPG) **veya** **SealedSecrets**
- [ ] DB URI, API keys, JWT secrets → şifrelenmiş olarak git’te tutuluyor
- [ ] CI/CD’de decrypt için gerekli key management kurgusu
- [ ] Namespace bazlı RBAC ve Secret/ConfigMap ayrımı

---

## 3) Observability’yi Genişletmek (Öneri 2)
### Metrics & Dashboards
- [ ] Prometheus install + scrape configs
- [ ] Grafana provisioning (dashboards + datasources as code)

### Logs
- [ ] Loki + Promtail (uygulama log formatı: JSON önerilir)

### Traces
- [ ] OpenTelemetry SDK/auto-instrumentation (Node.js)
- [ ] OTel Collector → Jaeger/Tempo backend

---

## 4) Environment Separation (Öneri 3)
- [ ] Namespaces: `app-dev`, `app-test`, `app-prod`
- [ ] Helm values ayrımı: image tag, replicas, resource limits, env vars
- [ ] Prod deploy’da manuel onay (ArgoCD Sync Policy veya Pipeline manual step)

---

## 5) Yayın Katmanı (Öneri 4)
- [ ] Ingress Controller: NGINX **veya** Traefik
- [ ] TLS: cert-manager + Let’s Encrypt Issuer (staging → prod)
- [ ] (Opsiyonel) Cloudflare CDN + cache rules (static assets)

---

## 6) CI/CD Pipeline Gelişmişlik (Öneri 5)
- [ ] Adımlar: Lint/Test → Build → Docker Build/Push → Trivy Scan → Helm Lint → ArgoCD Sync
- [ ] Branch/Tag kuralları: `dev` → dev, `test` → test, `main` → prod (onay)
- [ ] Versiyonlama: SemVer + image tag olarak `git sha` + `semver`
- [ ] Artifacts: test raporları, SBOM (syft), scan sonuçları

---

## 7) Scaling ve Load Testing (Öneri 6)
- [ ] HPA: CPU/Mem (veya custom metrics) ile scale rules
- [ ] Resource requests/limits belirleme (profiling’e göre)
- [ ] k6/Locust ile smoke & stress senaryoları + baseline rapor

---

## 8) DB Seçenekleri ve Ağ Topolojisi
- [ ] MongoDB Atlas kullanılırsa: IP allow-list, VPC Peering/Private Endpoint
- [ ] Cluster içi Mongo ise: StatefulSet + PVC + StorageClass + backup stratejisi
- [ ] NetworkPolicy ile east-west erişim kontrolü

---

## 9) Güvenlik ve Uyum
- [ ] Container image scanning (Trivy/Grype)
- [ ] SBOM üretimi ve imza (cosign)
- [ ] Pod Security Standards / SecurityContext (non-root, readOnlyRootFS)
- [ ] NetworkPolicy, Ingress sınırlamaları

---

## 10) ArgoCD Yapılandırması
- [ ] Project ve Application tanımları (dev/test/prod)
- [ ] Sync Policy (auto vs manual), Health checks, Prune
- [ ] App-of-Apps modeli (opsiyonel)

---

## 11) Yol Haritası (Sıralı İlerleyiş)
1. Node.js uygulamasını ayağa kaldır → Dockerize et → local test
2. Bitbucket repo ve pipeline iskeletini kur
3. Helm chart oluştur; dev namespace’e manuel deploy (helm install/upgrade)
4. ArgoCD’yi dev/test/prod için bağla (GitOps akışı)
5. Secrets yönetimini dev’den başlayarak entegre et
6. Ingress + TLS’yi dev’de doğrula, sonra test/prod’a taşı
7. Monitoring (Prom/Graf/Loki) → dashboard’ları görünür hale getir
8. OTel + Jaeger → basit trace üret → dashboard linkleri
9. HPA ve resource tuning → k6 ile kısa testler → raporla
10. Prod’de manuel onaylı release akışını tamamla

---

## 12) Açık Kararlar / Notlar
- [ ] SOPS mı SealedSecrets mı? (ekosistem uyumu + kişisel tercih)
- [ ] Ingress Controller seçimimiz? (NGINX vs Traefik)
- [ ] Mongo Atlas mı cluster içi Mongo mu? (maliyet, erişim, yedekleme)
- [ ] Log backend: Loki mi ELK mi? (başlangıç: Loki)

---

## 13) Ek — Dokümantasyon & Sunum
- [ ] Proje README: mimari diyagram, nasıl çalıştırılır, demo URL’ler
- [ ] CI/CD ve GitOps akış diyagramları
- [ ] CV için özet: kullanılan teknolojiler, ölçülebilir çıktılar (SLA, RPS, latency)

---

### Hızlı Kontrol Listesi
- [ ] App dockerized
- [ ] Helm chart + values
- [ ] ArgoCD projects/apps
- [ ] Secrets şifreli
- [ ] Ingress + TLS
- [ ] Prom+Graf+Loki
- [ ] OTel+Jaeger
- [ ] HPA aktif
- [ ] k6 raporu
- [ ] CI/CD tamam
