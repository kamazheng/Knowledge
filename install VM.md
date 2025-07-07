### VMare新建VM

> 内存锁定（动态分配有些要出错）
> 
> 硬盘挂载, 新建目录App用于docker数据。

- 启动机器后：

### reinstall ca-certificates

```
sudo yum reinstall ca-certificates
```

<br/>

##### 更新网络

```
nmcli connection show
ip addr show
```

> ```
> sudo nmcli con modify "Wired connection 1" ipv4.addresses 10.221.164.17/24
> sudo nmcli con modify "Wired connection 1" ipv4.gateway 10.221.164.1
> sudo nmcli con modify "Wired connection 1" ipv4.dns "10.175.2.6 10.159.12.223"
> sudo nmcli con modify "Wired connection 1" ipv4.method manual
> sudo systemctl restart NetworkManager
> ```
> 
> ```
> sudo nmcli con modify "Wired connection 1" ipv4.method auto
> sudo nmcli con modify "Wired connection 1" ipv4.addresses ""
> sudo nmcli con modify "Wired connection 1" ipv4.gateway ""
> sudo nmcli con modify "Wired connection 1" ipv4.dns ""
> sudo systemctl restart NetworkManager
> ```

##### Remove old Ip

> sudo ip addr del 10.221.164.19/23 dev ens224

<br/>

##### 更新yum新增proxy，公司内网不支持下载（或者启用334网络）

> ```
> [main]
> gpgcheck=1
> installonly_limit=3
> clean_requirements_on_remove=True
> best=True
> skip_if_unavailable=False
> proxy=http://10.227.80.43:53
> 
> ```

<br/>

#### 安装Docker

[https://docs.docker.com/engine/install/centos/](https://docs.docker.com/engine/install/centos)

```
sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

```
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

```
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

```
sudo systemctl enable --now docker
```

#### 新建用户

1. 新增用户到下面文件，如果需要root权限。

> /etc/sudoers
Allow root to run any commands anywhere
root    ALL=(ALL)       ALL
your_username    ALL=(ALL)       ALL

```
sudo useradd -m opex && echo "opex:opex1234" | sudo chpasswd
```

2. **用户（给予Docker权力）：**

```
sudo useradd -m -p $(openssl passwd -1 'opex1234') opex
sudo usermod -aG docker opex
//for sudo user
sudo usermod -aG wheel opex
//switch to new user test
su - opex
whoami
```

d#### 更新 /etc/docker/daemon.json

```
{
  "data-root": "/app/docker/lib",
  "dns-search": [
    "molex.com",
    "khc.local"
  ],
  "registry-mirrors": [
    "https://nexus.cdu.molex.com:135"
  ],
  "insecure-registries": [
    "nexus.cdu.molex.com:135"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "256m",
    "max-file": "4",
    "compress": "true"
  }
}

```

### 设置网络

<br/>

### ***

#### Xray

#### Nacos

Zipkin

VI command:

[https://www.runoob.com/linux/linux-vim.html](https://)
