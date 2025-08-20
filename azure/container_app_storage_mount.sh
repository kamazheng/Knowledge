
#!/bin/bash
set -euo pipefail

# 统一变量
APP_NAME="pass"
RESOURCE_GROUP="${APP_NAME}-rg"
LOCATION="eastus"
ENV_NAME="${APP_NAME}-env"
STORAGE_ACCOUNT_NAME="${APP_NAME}store$RANDOM"
STORAGE_NAME="${APP_NAME}-storage"
VOLUME_NAME="${APP_NAME}-volume"
FILE_SHARE_NAME="${APP_NAME}fileshare"
MOUNT_PATH="/data"
STORAGE_QUOTA=1
ADMIN_TOKEN="kamazheng@19770224"

# 创建资源组
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# 创建存储账号
az storage account create \
    --name "$STORAGE_ACCOUNT_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2

# 创建文件共享
az storage share-rm create \
    --resource-group "$RESOURCE_GROUP" \
    --storage-account "$STORAGE_ACCOUNT_NAME" \
    --name "$FILE_SHARE_NAME" \
    --quota "$STORAGE_QUOTA"

# 获取存储密钥
STORAGE_KEY=$(az storage account keys list \
    --resource-group "$RESOURCE_GROUP" \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --query "[0].value" -o tsv)

# 创建 Container Apps 环境
az containerapp env create \
    --name "$ENV_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION"

# 创建存储定义
az containerapp env storage set \
    --name "$ENV_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --storage-name "$STORAGE_NAME" \
    --azure-file-account-name "$STORAGE_ACCOUNT_NAME" \
    --azure-file-account-key "$STORAGE_KEY" \
    --azure-file-share-name "$FILE_SHARE_NAME" \
    --access-mode ReadWrite

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
          - name: ENABLE_DB_WAL
            value: false  # No quotes around "false"
        volumeMounts:
          - mountPath: $MOUNT_PATH
            volumeName: $VOLUME_NAME
    volumes:
      - name: $VOLUME_NAME
        storageName: $STORAGE_NAME
        storageType: AzureFile
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
