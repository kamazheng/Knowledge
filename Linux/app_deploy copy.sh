#!/bin/bash

# ===================================================================
# 🔧 全自动发布脚本：cdu_amp 类应用部署
# 功能：
#   - 交互输入参数
#   - 智能推荐下一个可用端口（基于现有 conf 文件）
#   - 生成 Nginx 配置：${PORT}_${APP_NAME}.conf
#   - 分离管理：Nginx 在专用服务器，应用在各自环境
#   - 备份并更新远程 docker-compose.yml
#   - 支持密码登录（sshpass）
#   - 本地使用 yq 合并 YAML
# ===================================================================

set -euo pipefail

# ============ 检查依赖工具 ============
for cmd in sshpass scp ssh yq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌ 错误: 缺少必需工具 '$cmd'"
    echo "💡 请安装: brew install $cmd"
    exit 1
  fi
done

# ============ 临时目录 ============
TEMP_DIR="/tmp/deploy_${RANDOM}"
mkdir -p "$TEMP_DIR"
trap 'rm -rf "$TEMP_DIR"' EXIT
echo "=> 创建临时工作目录: $TEMP_DIR"

# ============ 应用服务器配置（测试 & 生产）============
TEST_APP_USER="opex"
TEST_APP_HOST="MLXCDUVLQAPP01.molex.com"
TEST_APP_PASS="opex1234"
TEST_DOCKER_DIR="/app/docker/data"  # docker-compose.yml 所在目录

PROD_APP_USER="opex"
PROD_APP_HOST="MLXCDUVLPAPP01.molex.com"
PROD_APP_PASS="opex1234"
PROD_DOCKER_DIR="/app/docker/data"

# ============ Nginx 服务器配置（统一管理测试+生产）============
NGINX_USER="opex"
NGINX_HOST="MLXCDUVLPAPP02.molex.com"
NGINX_PASS="opex1234"
NGINX_CONF_DIR="/app/docker/data/nginx/conf.d/"
NGINX_CONTAINER_NAME_HINT="nginx"  # 容器名关键词，如 nginx, proxy

# ============ 函数：从已有 .conf 文件推测下一个端口 ============
suggest_next_port() {
  local SERVER_USER=$1
  local SERVER_HOST=$2
  local SERVER_PASS=$3
  local NGINX_DIR=$4

  local SERVER="${SERVER_USER}@${SERVER_HOST}"
  echo "=> 正在分析 ${SERVER_HOST} 上的 Nginx 配置以推荐端口..."

  # 使用 find 安全提取所有 匹配 '数字_名字.conf' 的文件，并提取端口
  PORTS=$(sshpass -p "$SERVER_PASS" ssh \
    -o StrictHostKeyChecking=no \
    "$SERVER" "
      find '${NGINX_DIR}' -type f -name '[0-9]*_*.conf' -printf '%f\n' | \\
      grep -o '^[0-9]\\+' | \\
      sort -n
  " || true)

  if [ -z "$PORTS" ]; then
    echo "=> 未发现历史配置，推荐起始端口 8500"
    echo 8500
    return
  fi

  MAX_PORT=$(echo "$PORTS" | tail -n1)
  NEXT_PORT=$((MAX_PORT + 1))

  echo "=> 已占用端口: $(echo $MAX_PORT | tr '\n' ' ')"
  echo "=> 推荐端口: ${NEXT_PORT}"
  echo $NEXT_PORT
}

# ============ 交互输入参数 ============
echo ""
echo "=== 🚀 开始交互式部署流程 ==="

read -rp "请输入程序名称 (如 cdu_amp): " APP_NAME
while [[ -z "$APP_NAME" ]]; do
  read -rp "程序名称不能为空，请重新输入: " APP_NAME
done

RECOMMENDED_PORT=$(suggest_next_port "$NGINX_USER" "$NGINX_HOST" "$NGINX_PASS" "$NGINX_CONF_DIR")



read -rp "请输入主机映射端口 PORT_HOST (推荐 ${RECOMMENDED_PORT}): " PORT_HOST_INPUT
PORT_HOST=${PORT_HOST_INPUT:-$RECOMMENDED_PORT}
while ! [[ "$PORT_HOST" =~ ^[0-9]+$ ]] || [ "$PORT_HOST" -lt 1 ] || [ "$PORT_HOST" -gt 65535 ]; do
  read -rp "请输入有效端口 (1-65535，默认 ${RECOMMENDED_PORT}): " PORT_HOST_INPUT
  PORT_HOST=${PORT_HOST_INPUT:-$RECOMMENDED_PORT}
done

read -rp "请输入测试环境域名 (如 amp.cduqa.molex.com): " SERVER_NAME_TEST
while [[ -z "$SERVER_NAME_TEST" ]]; do
  read -rp "测试域名不能为空: " SERVER_NAME_TEST
done

read -rp "请输入正式环境域名 (如 amp.cdu.molex.com): " SERVER_NAME_PROD
while [[ -z "$SERVER_NAME_PROD" ]]; do
  read -rp "正式域名不能为空: " SERVER_NAME_PROD
done

read -rp "请输入容器内端口 PORT_CONTAINER (默认 8080): " PORT_CONTAINER_INPUT
PORT_CONTAINER=${PORT_CONTAINER_INPUT:-8080}
while ! [[ "$PORT_CONTAINER" =~ ^[0-9]+$ ]] || [ "$PORT_CONTAINER" -lt 1 ] || [ "$PORT_CONTAINER" -gt 65535 ]; do
  read -rp "请输入有效的容器端口 (1-65535，默认 8080): " PORT_CONTAINER_INPUT
  PORT_CONTAINER=${PORT_CONTAINER_INPUT:-8080}
done

# ============ 初始镜像版本，用于测试是否成功 ============
DOCKER_TEST_IMAGE="nexus.cdu.molex.com:135/cdu_spp:1.1.1"

# ============ 文件命名 ============
NGINX_CONF_FILE="${PORT_HOST}_${APP_NAME}.conf"
NGINX_CONF_LOCAL="$TEMP_DIR/$NGINX_CONF_FILE"

# ============ 1. 生成 Nginx 配置文件 ============
cat > "$NGINX_CONF_LOCAL" << EOF
# Testing Environment
server {
    listen 443 ssl;
    listen 80;
    server_name $SERVER_NAME_TEST;
    ssl_certificate conf.d/ssl/cdu.molex.com.crt;
    ssl_certificate_key conf.d/ssl/cdu.molex.com.key;

    location / {
        proxy_pass http://app.cduqa.molex.com:${PORT_HOST};
    }
}

# Production Environment
server {
    listen 443 ssl;
    listen 80;
    server_name $SERVER_NAME_PROD;
    ssl_certificate conf.d/ssl/cdu.molex.com.crt;
    ssl_certificate_key conf.d/ssl/cdu.molex.com.key;

    location / {
        proxy_pass http://app.cdu.molex.com:${PORT_HOST};
    }
}
EOF

echo "=> 已生成 Nginx 配置文件: $NGINX_CONF_LOCAL"

# ============ 2. 生成 Docker Compose 片段 ============
cat > "$TEMP_DIR/docker-compose-fragment.yml" << EOF
  ${APP_NAME}:
    userns_mode: host
    container_name: ${APP_NAME}
    image: ${DOCKER_TEST_IMAGE}
    restart: always
    ports:
      - 0.0.0.0:${PORT_HOST}:${PORT_CONTAINER}
EOF

echo "=> 已生成 docker-compose 服务片段"

# ============ 函数：部署到指定应用服务器 ============
deploy_to_app_server() {
  local SERVER_USER=$1
  local SERVER_HOST=$2
  local SERVER_PASS=$3
  local DOCKER_DIR=$4    # docker-compose.yml 所在目录
  local ENV_NAME=$5

  local SERVER="${SERVER_USER}@${SERVER_HOST}"
  local COMPOSE_PATH="${DOCKER_DIR}/docker-compose.yml"
  local BAK_TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
  local REMOTE_BAK_PATH="${COMPOSE_PATH}.${APP_NAME}.bak.${BAK_TIMESTAMP}"

  echo "==> 🛠️  开始部署到 ${ENV_NAME} 环境应用服务器: ${SERVER_HOST}"

  # 检查 docker-compose.yml 是否存在
  if ! sshpass -p "$SERVER_PASS" ssh -o StrictHostKeyChecking=no "$SERVER" "test -f '${COMPOSE_PATH}'"; then
    echo "    ❌ 错误: ${COMPOSE_PATH} 不存在"
    return 1
  fi

  # 备份
  echo "    -> 备份远程 docker-compose.yml → ${REMOTE_BAK_PATH}"
  sshpass -p "$SERVER_PASS" ssh -o StrictHostKeyChecking=no "$SERVER" "
    cp '${COMPOSE_PATH}' '${REMOTE_BAK_PATH}' && echo '✅ 备份成功'
  "

  # 下载
  echo "    -> 下载当前 docker-compose.yml"
  scp_file="${TEMP_DIR}/docker-compose.yml.${ENV_NAME}"
  sshpass -p "$SERVER_PASS" scp -o StrictHostKeyChecking=no "${SERVER}:${COMPOSE_PATH}" "$scp_file"

    # 合并后再去除 !!merge
    if ! yq -i '
    .services."'${APP_NAME}'" = load("'"$TEMP_DIR/docker-compose-fragment.yml"'")."'${APP_NAME}'"
    ' "$scp_file"; then
    echo "❌ yq 合并失败"
    return 1
    fi

    echo "✅ 已去除 !!merge 标签"

    # 手动添加锚点引用（关键！）
    yq -i '
    .services."'${APP_NAME}'".__merge_placeholder__ = true
    ' "$scp_file"
    # macOS 和 Linux 兼容写法
    if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' 's/__merge_placeholder__:.*/!!merge <<: *common-environment/' "$scp_file"
    else
    # Linux
    sed -i 's/__merge_placeholder__:.*/!!merge <<: *common-environment/' "$scp_file"
    fi

    echo "    ✅ 服务 '${APP_NAME}' 已成功合并并添加 <<: *common-environment"
    echo "    ✅ 服务 '${APP_NAME}' 已成功合并"

    # 上传回服务器
    echo "    -> 上传更新后的 docker-compose.yml"
    sshpass -p "$SERVER_PASS" scp \
        -o StrictHostKeyChecking=no \
        "$scp_file" \
        "$SERVER:${COMPOSE_PATH}"

    # 重启应用容器
    echo "    -> 重启测试应用容器: ${APP_NAME}"
    sshpass -p "$SERVER_PASS" ssh \
    -o StrictHostKeyChecking=no \
    "$SERVER" "
        echo '🚀 正在重启服务 ${APP_NAME} ...'

        # 进入 docker-compose 所在目录
        cd '${DOCKER_DIR}' || { echo '❌ 目录不存在: ${DOCKER_DIR}'; exit 1; }

        # 拉取新镜像（可选）
        docker pull ${DOCKER_TEST_IMAGE} || echo '🟡 忽略镜像拉取失败'

        # 重启服务
        if docker compose up -d ${APP_NAME}; then
        echo '✅ 服务 ${APP_NAME} 已成功启动'
        else
        echo '❌ 启动失败，请登录检查配置'
        exit 1
        fi
    "
    

}

# ============ 函数：更新 Nginx 配置并重载 ============
update_nginx_server() {
  local NGINX_USER=$1
  local NGINX_HOST=$2
  local NGINX_PASS=$3
  local NGINX_CONF_DIR=$4
  local CONTAINER_HINT=$5

  local SERVER="${NGINX_USER}@${NGINX_HOST}"

  echo "==> 🌐 更新 Nginx 服务器: ${NGINX_HOST}"

  # 上传 Nginx 配置
  echo "    -> 上传配置: ${NGINX_CONF_FILE}"
  sshpass -p "$NGINX_PASS" scp \
    -o StrictHostKeyChecking=no \
    "$NGINX_CONF_LOCAL" \
    "${SERVER}:${NGINX_CONF_DIR}/${NGINX_CONF_FILE}"

  # 探测 Nginx 容器名
    sshpass -p "$NGINX_PASS" ssh -o StrictHostKeyChecking=no "$SERVER" "
    echo '[SSH] 连接成功，开始处理...'
    CONTAINER=\$(docker ps --filter \"name=${CONTAINER_HINT}\" --format '{{.Names}}' | head -n1)
    if [ -z \"\$CONTAINER\" ]; then
        echo '❌ [ERROR] 未找到 Nginx 容器 (hint: ${CONTAINER_HINT})'
        exit 1
    fi
    echo \"🔍 使用容器: \$CONTAINER\"

    if docker exec \"\$CONTAINER\" nginx -t; then
        docker exec \"\$CONTAINER\" nginx -s reload
        echo '✅ Nginx 配置已安全重载'
    else
        echo '🚨 nginx -t 失败，请登录检查语法'
        exit 1
    fi
    "

  echo "==> ✅ Nginx 配置更新完成"
}

# ============ 执行部署流程 ============
echo ""
deploy_to_app_server "$TEST_APP_USER" "$TEST_APP_HOST" "$TEST_APP_PASS" "$TEST_DOCKER_DIR" "Test"
echo ""
deploy_to_app_server "$PROD_APP_USER" "$PROD_APP_HOST" "$PROD_APP_PASS" "$PROD_DOCKER_DIR" "Production"
echo ""
update_nginx_server "$NGINX_USER" "$NGINX_HOST" "$NGINX_PASS" "$NGINX_CONF_DIR" "$NGINX_CONTAINER_NAME_HINT"

# ============ 完成提示 ============
echo ""
echo "🎉 🚀 所有部署已完成！"
echo "📌 配置文件: ${NGINX_CONF_FILE}"
echo "📌 主机端口: ${PORT_HOST} → 容器端口 ${PORT_CONTAINER}"
echo "🔗 测试访问: https://${SERVER_NAME_TEST}"
echo "🔗 正式访问: https://${SERVER_NAME_PROD}"
echo "📦 Nginx 和 docker-compose 已备份并生效"