#!/bin/bash

# ============================================================
# Azure Container Instances Deployment Script for Vaultwarden
# Not support ssl, please use "https_proxy" to make it work.
# ============================================================

# Configuration variables
RESOURCE_GROUP="vaultwarden-rg"
LOCATION="EastUS"
CONTAINER_NAME="vaultwarden-container"

# Vaultwarden environment variables
ADMIN_EMAIL="kamazheng@163.com"
ADMIN_PASSWORD="kamazheng@19770224"
ADMIN_TOKEN="kamazheng@19770224"

# Create a resource group
echo "Creating resource group..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# Deploy the container to Azure Container Instances
echo "Creating Azure Container Instance..."
az container create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_NAME" \
    --image "vaultwarden/server:latest" \
    --os-type Linux \
    --cpu 0.25 \
    --memory 0.5 \
    --ports 80 \
    --environment-variables \
        ADMIN_EMAIL="$ADMIN_EMAIL" \
        ADMIN_PASSWORD="$ADMIN_PASSWORD" \
        ADMIN_TOKEN="$ADMIN_TOKEN" \
        ENABLE_DB_WAL="true" \
    --dns-name-label "$CONTAINER_NAME" \
    --location "$LOCATION"

# Get the public URL of the container
echo "Retrieving container URL..."
APP_URL=$(az container show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_NAME" \
    --query "ipAddress.fqdn" \
    --output tsv)

# Output the result
echo "=============================================="
echo "Vaultwarden has been successfully deployed!"
echo "Access your instance at: http://$APP_URL"
echo "=============================================="
