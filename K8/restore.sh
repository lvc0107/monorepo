#!/bin/bash
BACKUP_DIR=$1

# Restaurar con Helm
for values in $BACKUP_DIR/helm-values-*.yaml; do
  release=$(basename $values | sed 's/helm-values-//' | sed 's/.yaml//')
  chart="charts/${release}"  # Asumiendo que tienes los charts
  
  if [ -d "$chart" ]; then
    helm upgrade --install $release $chart -f $values
  else
    echo "Chart no encontrado para $release, saltando..."
  fi
done

echo "Restauración completada"