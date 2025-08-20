#!/bin/bash
set -euo pipefail

# 统一变量
APP_NAME="vaultwarden"
RESOURCE_GROUP="${APP_NAME}-rg"
LOCATION="eastus"
ENV_NAME="${APP_NAME}-env"
ADMIN_TOKEN="kamazheng@19770224"

# 创建资源组
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# 创建 Container Apps 环境
az containerapp env create \
    --name "$ENV_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION"

# 获取环境 ID
ENV_ID=$(az containerapp env show \
  --name "$ENV_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query id -o tsv)

if [[ -z "$ENV_ID" ]]; then
  echo "ERROR: Environment ID not found!"
  exit 1
fi

echo "=== 生成 YAML 配置文件 ==="
cat <<EOF > app.yaml
properties:
  environmentId: $ENV_ID
  configuration:
    ingress:
      allowInsecure: false
      external: true
      targetPort: 80
  template:
    containers:
      - name: $APP_NAME
        image: vaultwarden/server:latest
        resources:
          cpu: 0.5
          memory: 1Gi
        env:
          - name: ADMIN_TOKEN
            value: "$ADMIN_TOKEN"
          - name: DATABASE_URL
            value: "postgres://username:password@postgres.database.azure.com:5432/vaultwarden"
    scale:
      minReplicas: 0
      maxReplicas: 1

EOF

echo "=== 部署 Container App ==="
az containerapp create --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" --environment "$ENV_NAME"  --yaml app.yaml

echo "=== 删除临时 YAML 文件 ==="
rm app.yaml

echo "=== 获取公网访问地址 ==="
APP_URL=$(az containerapp show \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "properties.configuration.ingress.fqdn" -o tsv)

echo "访问地址：https://$APP_URL"