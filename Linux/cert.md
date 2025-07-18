# 信任证书流程

- 显示证书

```
openssl s_client -connect kochsource.io:443  -showcerts

```

- 获取证书链
```
HOST=kochsource.io
echo | openssl s_client -connect ${HOST}:443 -servername ${HOST} -showcerts 2>/dev/null | sed -n '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' > fullchain.pem

```

- 拆分证书

```
filename="fullchain.pem"; prefix="cert"; count=0; while IFS= read -r line; do if [[ "$line" == "-----BEGIN CERTIFICATE-----" ]]; then count=$((count+1)); certfile="${prefix}-${count}.pem"; fi; echo "$line" >> "$certfile"; done < "$filename"

```

- 查看某个证书详情
```
openssl x509 -in cert-1.pem -text -noout
```

- 判断是否是根证书
```
openssl x509 -in cert-1.pem -noout -issuer -subject
```

- 添加根证书到系统信任库（从网络下载的根证书， openssl不会返回根证书）
```
sudo cp cert-3.pem /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust extract
```

- 清理
```
rm fullchain.pem  cert-*.pem
```

在整个 HTTPS/TLS 证书链中，**根证书、中间证书和服务器证书（终端实体证书）必须满足一系列条件才能完成认证（验证成功）**。下面是它们各自的角色以及整个链在验证过程中需要满足的条件。

---

## 🧩 一、证书链的基本组成

一个典型的证书链如下：

```
[服务器证书] → [中间证书 CA 1] → [中间证书 CA 2] → ... → [根证书]
```

- **服务器证书（Leaf Certificate / End-Entity Certificate）**：颁发给网站域名（如 `kochsource.io`）。
- **中间证书（Intermediate CA）**：由根证书签发，用于签发服务器证书。
- **根证书（Root CA）**：可信锚点，预装在操作系统或浏览器中。

---

## ✅ 二、整个证书链认证成功的必要条件

要使 TLS 握手时证书链验证成功，以下所有条件都必须满足：

### 1. **证书链完整**
- 客户端必须能够从服务器证书出发，**逐级找到签发者**，直到到达一个**受信任的根证书**。
- 如果缺少中间证书，客户端无法建立信任链，会报错如：
  ```
  unable to get local issuer certificate
  ```

> 🔍 提示：使用 `openssl s_client -showcerts` 可以看到服务器发送了哪些证书。

---

### 2. **每个证书必须有效（未过期）**
- 所有证书（服务器、中间、根）都必须处于有效期内。
- 检查方式：
  ```bash
  openssl x509 -in cert.pem -text -noout | grep "Not Before\|Not After"
  ```

---

### 3. **每个证书必须没有被吊销（CRL/OCSP）**
- 虽然很多客户端默认不检查吊销状态，但在严格模式下（如某些企业环境），会通过 CRL 或 OCSP 验证证书是否被吊销。
- 如果证书被吊销，则认证失败。

---

### 4. **证书用途匹配（EKU / Key Usage）**
- 每个证书都有自己的用途限制，例如：
  - 根证书：只能用来签发其他证书（CA:TRUE）
  - 中间证书：可以签发证书，但不能是最终实体
  - 服务器证书：只能用于服务器身份认证（TLS Web Server Authentication）

如果用途不匹配，也会导致验证失败。

---

### 5. **域名匹配**
- 服务器证书的 Common Name (CN) 或 Subject Alternative Name (SAN) 必须包含当前访问的域名。
- 如访问 `https://kochsource.io`，则证书中必须包含该域名。

---

### 6. **签名有效性**
- 每个证书必须能用上一级证书的公钥正确验证签名。
- 例如：
  - 服务器证书的签名必须能用中间证书的公钥验证。
  - 中间证书的签名必须能用上级中间或根证书的公钥验证。

---

### 7. **信任锚点存在**
- 最终的信任链必须终结于一个客户端信任的根证书（root CA）。
- 这些根证书通常预装在操作系统、浏览器或应用程序的信任库中。

---

## 🛠️ 三、OpenSSL 命令验证证书链

你可以手动验证某个证书链是否可信任：

```bash
openssl verify -CAfile root-ca.pem -untrusted intermediate.pem server-cert.pem
```

- `root-ca.pem`：根证书
- `intermediate.pem`：中间证书（多个可用 `-untrusted` 多次指定）
- `server-cert.pem`：服务器证书

如果输出：

```
server-cert.pem: OK
```

说明证书链验证通过。

---

## 📌 四、总结：证书链验证成功的关键条件一览表

| 条件 | 是否必需 |
|------|----------|
| 证书链完整（包括必要的中间证书） | ✅ 是 |
| 所有证书未过期 | ✅ 是 |
| 证书未被吊销（视配置而定） | ⚠️ 可选（取决于实现） |
| 证书用途匹配（KeyUsage, EKU） | ✅ 是 |
| 域名与证书中的 CN/SAN 匹配 | ✅ 是 |
| 每个证书的签名都能被上一级证书验证 | ✅ 是 |
| 根证书是受信任的 | ✅ 是 |

---

如果你正在调试某个具体的服务或命令（比如 `curl`, `openssl s_client`, 或写代码验证证书），欢迎贴出你的操作步骤或错误信息，我可以帮你进一步分析哪个环节出了问题。