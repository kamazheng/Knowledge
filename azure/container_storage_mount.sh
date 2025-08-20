#!/bin/bash
set -euo pipefail

# 变量
APP_NAME="postgres"
RESOURCE_GROUP="${APP_NAME}-rg"
LOCATION="eastus"
STORAGE_ACCOUNT_NAME="$(echo "${APP_NAME}store$RANDOM" | tr -cd '[:lower:][:digit:]' | cut -c1-24)"
FILE_SHARE_NAME="${APP_NAME}fileshare"
MOUNT_PATH="/var/lib/postgresql/data"
STORAGE_QUOTA=10
ACI_CPU=2
ACI_MEMORY=4
POSTGRES_PASSWORD="YourSecurePassword123!"
POSTGRES_USER="postgres"
POSTGRES_DB="mydb"
CONTAINER_NAME="$APP_NAME"
ACI_NAME="$APP_NAME-aci"
DNS_LABEL="${APP_NAME}-$(openssl rand -hex 3)"   # 例如 postgres-a1b2c3

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

echo "=== 开始创建 Azure Container Instance ==="

az container create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACI_NAME" \
  --image postgres:16 \
  --cpu "$ACI_CPU" \
  --memory "$ACI_MEMORY" \
  --ports 5432 \
  --os-type Linux \
  --restart-policy OnFailure \
  --environment-variables \
      POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
      POSTGRES_USER="$POSTGRES_USER" \
      POSTGRES_DB="$POSTGRES_DB" \
  --azure-file-volume-share-name "$FILE_SHARE_NAME" \
  --azure-file-volume-account-name "$STORAGE_ACCOUNT_NAME" \
  --azure-file-volume-account-key "$STORAGE_KEY" \
  --azure-file-volume-mount-path "$MOUNT_PATH" \
  --dns-name-label "$DNS_LABEL" \
  --location "$LOCATION"

FQDN="${DNS_LABEL}.${LOCATION}.azurecontainer.io"

echo "=== 连接信息 ==="
echo "PG主机：$FQDN"
echo "端口：5432"
echo "用户名：$POSTGRES_USER"
echo "密码：$POSTGRES_PASSWORD"
echo "数据库：$POSTGRES_DB"
echo
echo "连接字符串："
echo "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$FQDN:5432/$POSTGRES_DB"