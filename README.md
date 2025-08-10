# Kubernetes + Helm ile Grafana & Prometheus Kurulumu (Kind üzerinde)
Bu repo; Kind üzerinde Ingress-NGINX kullanarak Prometheus, Grafana ve örnek “basic-login” uygulamasını domain üzerinden çalıştırmak için hazırlanmış bir pratik setidir.

## Ortam Kurulumu
- Docker Desktop (veya eşdeğeri)
- Kind, kubectl, helm kurulu olmalı.
- Docker Desktop arka planda çalışır durumda olmalı.

---

## Cluster Oluşturma
Port-forward kullanmadan erişebilmek için `extraPortMappings` ile kind config oluşturduk.

## Cluster’ı başlattık
```bash
kind create cluster --name monitoring-cluster --config kind-config.yaml
```

## Namespace’leri Oluşturma
```bash
kubectl create namespace monitoring
kubectl create ns app-dev
```

## Helm Chart’ları Lokal’e İndirme
```bash
helm pull grafana/grafana --untar
helm pull prometheus-community/prometheus --untar
```
Bu sayede chart yapısını (Chart.yaml, values.yaml, templates/) görebildik.

## Prometheus Kurulumu
```bash
helm upgrade --install prom ./prometheus -n monitoring
```
Erişim:
http://prometheus.local/

## Grafana Kurulumu
```bash
helm upgrade --install gfn ./grafana -n monitoring
```
Erişim:
http://grafana.local/ (admin / admin123)

## Web App Kurulumu
```bash
helm upgrade --install bl ./basic-login -n app-dev
```
Erişim:
http://grafana.local/ (admin / admin123)

## Doğrulama
Pod ve servis durumlarını kontrol ettik:
```bash
kubectl -n monitoring get pods,svc
```

## Öğrendiklerimiz
- Helm Chart yapısını (values.yaml, templates/) lokal indirerek inceledik.
- helm get values ve helm get manifest ile Kubernetes’e uygulanan konfigürasyonu görebiliyoruz.

## Cluster Oluşturma / Bağlanma
```bash
# kind ile cluster oluştur
kind create cluster --name monitoring-cluster --config kind-config.yaml

# cluster’ı sil
kind delete cluster --name monitoring-cluster

# mevcut context ve cluster bilgisi
kubectl config current-context
kubectl config get-contexts
kubectl cluster-info
kubectl version --short
```

## Temel Keşif
```bash
# node ve namespace’ler
kubectl get nodes -o wide
kubectl get ns

# bir ns içindeki kaynaklar (kısa adlarla)
kubectl get deploy,sts,ds,svc,pod,cm,secret,ing -n monitoring
kubectl get all -n monitoring

# sürekli izle
kubectl get pods -n monitoring -w
```

## Sağlık Kontrolü (Pod/Deployment)
```bash
# pod listesi, geniş görünüm + hazır olma
kubectl get pods -n monitoring -o wide

# pod detay (event’ler son kısımda)
kubectl describe pod -n monitoring <pod-adı>

# deployment durumu / rollout
kubectl rollout status deploy/gfn-grafana -n monitoring
kubectl rollout history deploy/gfn-grafana -n monitoring
kubectl rollout undo deploy/gfn-grafana -n monitoring   # geri al
```

## Log, exec, port-forward
```bash
# son 200 log satırı
kubectl logs -n monitoring <pod> --tail=200

# container seç (çokluysa)
kubectl logs -n monitoring <pod> -c <container>

# takip ederek izle
kubectl logs -f -n monitoring <pod>

# pod içine gir
kubectl exec -it -n monitoring <pod> -- sh

# yerel porta bağla (geçici erişim)
kubectl -n monitoring port-forward svc/gfn-grafana 3000:80
```

 ## Uygulama (apply/delete/patch)
```bash
# yaml uygula / sil
kubectl apply -f my.yaml
kubectl delete -f my.yaml

# tek kaynak sil
kubectl delete pod -n monitoring <pod>
kubectl delete svc -n monitoring <svc>

# hızlı json patch (ör: Service type’ını değiştir)
kubectl patch svc -n monitoring gfn-grafana -p '{"spec":{"type":"NodePort"}}'
```

## Filtreleme, etiket, seçim
```bash
# label ekle/çıkar
kubectl label ns grafana purpose=grafana --overwrite
kubectl label ns grafana purpose-

# selector ile listele
kubectl get pods -n monitoring -l app=prometheus

# sadece adları yazdır
kubectl get pods -n monitoring -o name
```

JSONPath / Yararlı Çıktılar
```bash
# servis NodePort değerini çek
kubectl get svc -n monitoring prom-prometheus-server \
  -o jsonpath='{.spec.ports[0].nodePort}'; echo

# secret içeriğini çöz
kubectl get secret -n monitoring gfn-grafana \
  -o go-template='{{ index .data "admin-password" | base64decode }}'; echo
```

## Dokümantasyon ve API keşfi
```bash
kubectl explain deployment.spec.template.spec.containers --recursive | less
kubectl api-resources     
kubectl api-versions
```

## Kaynak kullanımı (metrics-server varsa)
```bash
kubectl top nodes
kubectl top pods -n monitoring
```

## Hızlı Sağlık Checklist’i
- kubectl get nodes → Ready?
- kubectl get pods -n <ns> → Running / READY 1/1?
- kubectl describe pod → son event’lerde hata var mı?
- kubectl logs <pod> → crash/hata mesajı?
- kubectl get svc → doğru port/targetPort?
- (Gerekirse) port-forward ile canlı test.