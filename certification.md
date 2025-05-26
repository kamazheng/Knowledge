## 生成Molex签名的证书

### 导出pfx文件

#### certlm.msc

1. Login Windows Server by Administrator account
2. Personal right click => All Task => request new Certificate => AD Enrollment Policy => Next => Web Server SHA2
3. Subject:
   1. Alternative name, **DNS** => *.cdu.molex.com, Common name => cud.molex.com
   2. Private key => **option: Make private key exportable**
4. Apply => Enroll => Finish
5. Find the cert created in Personal.Certificates, Export with private key, Encryption -> AES256-SHA256, give the name of pfx file.

### 转出证书和私钥

你可以使用 `openssl` 工具来从 `.pfx` 文件中导出证书和私钥。以下是具体步骤：

1. **导出证书**：
   ```sh
   openssl pkcs12 -in cdu.molex.com.pfx -clcerts -nokeys -out cdu.molex.com.pem
   ```
   ```
   openssl pkcs12 -in cdu.molex.com.pfx -clcerts -nokeys -out cdu.molex.com.crt
   ```
2. **导出私钥**：
   ```sh
   openssl pkcs12 -in molex.server.pfx -nocerts -out molex.server.key.pem
   ```
   ```
   openssl pkcs12 -in cdu.molex.com.pfx -nocerts -out cdu.molex.com.key
   ```
3. **移除私钥的密码保护（如果需要）**：
   ```sh
   openssl rsa -in cdu.molex.com.key -out cdu.molex.com.key
   ```

```
openssl rsa -in cduall_cert.key -out cduall_cert.key
```

确保将 `yourfile.pfx` 替换为你的实际文件名。执行这些命令时，系统会提示你输入 `.pfx` 文件的密码。

***

<br/>

服务器执行
cd /etc/pki/ca-trust/source/anchors/        --存储SSL证书和密钥的位置
wget http://jenkins.aip.molex.com/files/molex-aip-bash/redhat9/certificate/molexrootca-sha2.crt     --下载molex根证书
sudo update-ca-trust extract           --更新系统中的SSL证书信任列表
systemctl restart docker                   --重启docker
docker pull nexus.aip.molex.com:135/mysql:8                    --从私有镜像库中pull镜像

<br/>

windows根证书导出步骤：
1.certmgr.msc进入证书管理界面
2.找到molex根证书 Trusted Root C... => Certificates => MolexCA-SHA2
3.导出根证书 => Base64编码X.509

<br/>

> sudo dnf install ca-certificates
> 
> sudo update-ca-trust

<br/>

check expired or not, centos:

openssl x509 -enddate -noout -in /etc/pki/tls/certs/ca-bundle.crt

<br/>

#### go inside docker:

docker exec -it --user root {docker id} bash

docker exec -it --user root 048258586b64 bash

#### copy cert from centos into container(ubuntu):

> docker cp /etc/pki/tls/certs/ca-bundle.crt <container_id>:/usr/local/share/ca-certificates/
> 
> docker cp /etc/pki/tls/certs/ca-bundle.crt 048258586b64:/usr/local/share/ca-certificates/
> 
> update-ca-certificates
> 
> exit

<br/>

### Generate Self-signed Certificate in Windows

```powershell
New-SelfSignedCertificate -DnsName "MOLEX.com" -CertStoreLocation "Cert:\LocalMachine\My" -NotAfter (Get-Date).AddYears(100)
```

你已经成功生成了证书，并将其存储在本地计算机的“我的”证书存储区中。要找到并管理这个证书，你可以使用以下方法：

1. **使用证书管理器（GUI）**：
   - 按 `Win + R` 打开运行对话框，输入 `certlm.msc` 并按回车。
   - 在左侧导航栏中，展开 `个人`（Personal） -> `证书`（Certificates）。
   - 你应该能在右侧看到刚刚生成的证书，主题（Subject）为 `CN=MOLEX.com`。
2. **使用 PowerShell**：
你可以使用 PowerShell 命令来查看和导出证书。例如，查看证书的详细信息：
   ```powershell
   Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Thumbprint -eq "3D30966FEF79EFEC614F19A8AC8D51D294E74E10" }
   ```
   
   导出证书为 `.cer` 文件：
   ```powershell
   Export-Certificate -Cert Cert:\LocalMachine\My\3D30966FEF79EFEC614F19A8AC8D51D294E74E10 -FilePath "C:\Users\kzheng\OneDrive - kochind.com\Desktop\molex.cer"
   ```

这样，你就可以找到并管理你生成的证书了。如果你有其他问题或需要进一步的帮助，请告诉我！
