# 变量部分（请根据实际需要修改）
RESOURCE_GROUP=postgresql-rg
LOCATION=EastUS
SERVER_NAME=postgretest$RANDOM
ADMIN_USER=kzheng
ADMIN_PASSWORD='kama&8212'  # 建议用强密码

# 创建资源组（如果还没有）
az group create --name $RESOURCE_GROUP --location $LOCATION

# 创建 PostgreSQL Flexible Server（最便宜配置、指定用户名和密码）
az postgres flexible-server create \
  --resource-group $RESOURCE_GROUP \
  --name $SERVER_NAME \
  --location $LOCATION \
  --storage-size 32 \
  --admin-user $ADMIN_USER \
  --admin-password $ADMIN_PASSWORD \
  --high-availability Disabled \
  --version 16 \
  --public-access 0.0.0.0  # 允许所有IP访问（测试用，生产环境需收紧） 没有起作用，还是要到门户修改？
  --tier Serverless \
  --auto-pause-delay 5  # 5分钟无连接自动暂停，可以调节
  --sku-name Standard_D2ds_v4 \
