# Cluster
kind create cluster --name monitoring-cluster --config kind-config.yaml

# Ingress-NGINX
helm upgrade --install ingress-nginx ./vendor/ingress-nginx \
  -n ingress-nginx --create-namespace \
  -f ingress-nginx-values-kind.yaml

kubectl -n ingress-nginx wait --for=condition=available deploy/ingress-nginx-controller --timeout=120s

# DNS MAC OS
sudo sh -c 'echo "127.0.0.1 grafana.local prometheus.local basic-login.local" >> /etc/hosts'
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder || true

# DNS WIN (PowerShell Admin)
$hosts="$env:WINDIR\System32\drivers\etc\hosts"
attrib -r $hosts
Add-Content -Path $hosts -Value "`r`n127.0.0.1 grafana.local" -Encoding ASCII
Add-Content -Path $hosts -Value "`r`n127.0.0.1 prometheus.local" -Encoding ASCII
Add-Content -Path $hosts -Value "`r`n127.0.0.1 basic-login.local" -Encoding ASCII
ipconfig /flushdns

kubectl create ns monitoring
helm upgrade --install prom ./prometheus -n monitoring
helm upgrade --install gfn  ./grafana    -n monitoring

kubectl create ns app-dev
helm upgrade --install bl ./basic-login -n app-dev
