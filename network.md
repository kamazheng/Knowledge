##### Windows Find avaible Ips:

arg -a

#### open port scan:

```
nmap -iL ips.txt -p 1-65535
```

```
nmap 10.221.165.49 -p 1-65535

C:\Users\kzheng>nmap 10.221.165.49 -p 1-65535
Starting Nmap 7.95 ( https://nmap.org ) at 2024-12-10 14:20 China Standard Time
Nmap scan report for opentelemetry-collector.cdu.molex.com (10.221.165.49)
Host is up (0.0066s latency).
Not shown: 65498 filtered tcp ports (no-response), 31 closed tcp ports (reset)
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
443/tcp  open  https
8008/tcp open  http
8015/tcp open  cfg-cloud
8080/tcp open  http-proxy
```

> inet 10.221.164.13/24 brd 10.221.164.255 scope global noprefixroute ens224
> 
> C:\Users\kzheng>nmap 10.221.164.13 -p 1-65535
Starting Nmap 7.95 ( https://nmap.org ) at 2024-10-25 02:21 China Standard Time
Nmap scan report for cdujenkins.molex.com (10.221.164.13)
Host is up (0.0029s latency).
Not shown: 65523 filtered tcp ports (no-response), 7 filtered tcp ports (admin-prohibited)
PORT     STATE  SERVICE
22/tcp   open   ssh
113/tcp  closed ident
8008/tcp open   http
8015/tcp open   cfg-cloud
8080/tcp open   http-proxy
> 
> Nmap done: 1 IP address (1 host up) scanned in 116.94 seconds

<br/>

### Linux network setting

cd /etc/NetworkManager/system-connections

List Network Interfaces:
nmcli device status

##### Show Connection Details:

```
nmcli connection show
```

```
ip addr show
```

```
ip route show
```

<br/>

##### Configure a Static IP Address: Replace enp0s3 with your network interface name.

> ```
> sudo nmcli con modify "ens192" ipv4.addresses 10.221.164.14/24
> ```
> 
> *<u>注意：子网掩码23，设置成24，端口才可以被公网络访问（Molex CD）访问</u>*
> 
> ```
> sudo nmcli con modify "Wired connection 1" ipv4.gateway 10.221.164.1
> sudo nmcli con modify "Wired connection 1" ipv4.dns "10.175.2.6 10.159.12.223"
> sudo nmcli con modify "Wired connection 1" ipv4.method manual
> sudo systemctl restart NetworkManager
> ```
> 
> sudo nmcli con modify "Wired connection 1" ipv4.method auto

<br/>

##### Remove Ip

> sudo ip addr del 10.221.164.19/24 dev enp11s0

<br/>

#### Docker Images下载 公司网络问题：

```
cd /etc/docker/
```

##### /etc/docker/daemon.json

```json


{
  "dns-search": [
    "molex.com",
    "khc.local"
  ],
  "registry-mirrors": [
    "https://nexus.aip.molex.com:135"
  ],
  "insecure-registries": [
    "nexus.aip.molex.com:135"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "256m",
    "max-file": "4",
    "compress": "true"
  }
}
```

```
{
  "dns-search": [
    "molex.com",
    "khc.local"
  ],
  "registry-mirrors": [
    "https://nexus.cdu.molex.com:8080/"
  ],
  "insecure-registries": [
    "nexus.cdu.molex.com:8080"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "256m",
    "max-file": "4",
    "compress": "true"
  }
}

```

#### Proxy

> 下载IE的配置文件 LocalProxy.pac
> 
> ```
>  if (zappLocalProxy == "127.0.0.1:9000") 
>     return "PROXY 165.225.116.34:10077; PROXY 165.225.102.143:10077";
>   else 
>     return "PROXY 127.0.0.1:9000";
> ```
> 
> **<u>设置 Http/Https PROXY 165.225.116.34:10077; PROXY 165.225.102.143:10077</u>**

<br/>

Update:

```
{
  "data-root": "/app/docker/lib",
  "dns-search": [
    "molex.com",
    "khc.local"
  ],
  "registry-mirrors": [
    "https://nexus.cduqa.molex.com:135"
  ],
  "insecure-registries": [
    "nexus.cduqa.molex.com:135"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "256m",
    "max-file": "4",
    "compress": "true"
  }
}
```

Yum proxy (etc/yum.conf)

```
[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=True
skip_if_unavailable=False
proxy=http://10.227.80.43:53
```

<br/>

### inside docker add env.

If you run the `echo $http_proxy` command and it returns nothing, it means the `http_proxy` environment variable is not set. Let's set it again inside the container:

1. **Enter the Container's Shell**:
   ```sh
   docker exec -it d9b14aac9859 /bin/bash
   ```
2. **Set the Environment Variable**:
Inside the container, set the `http_proxy` environment variable:
   ```sh
   export http_proxy=http://165.225.116.34:10077
   ```
3. **Verify the Environment Variable**:
Check if the environment variable is set:
   ```sh
   echo $http_proxy
   ```

This should display `http://165.225.116.34:10077`, confirming that the environment variable is set.

If you need further assistance, feel free to ask!

<br/>

```
sudo lsof -i :11434
```
