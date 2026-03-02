#!/bin/bash
mkdir -p k8s-backup-$(date +%Y%m%d)

# Backup de Helm (recomendado)
helm list --all-namespaces > k8s-backup-$(date +%Y%m%d)/helm-list.txt

for release in $(helm list -q); do
  helm get values $release > k8s-backup-$(date +%Y%m%d)/helm-values-${release}.yaml
done

# Backup de recursos crudos (por si acaso)
kubectl get deployments,services,configmaps,secrets,ingress,pvc --all-namespaces -o yaml > \
  k8s-backup-$(date +%Y%m%d)/all-resources.yaml

echo "Backup en: k8s-backup-$(date +%Y%m%d)/"