# New VM START
## 确定时区
```
sudo timedatectl set-timezone Asia/Shanghai
timedatectl
date

```
## Repo ssl issue

/etc/yum.repos.d
Inside each section, add or modify this line:
```

sslverify=0

```

## Docker install

https://docs.docker.com/engine/install/rhel/

```

id kzheng
sudo chown -R kzheng:support /app/

```

```
sudo useradd -m opex && echo "opex:opex1234" | sudo chpasswd
sudo usermod -aG docker opex
```

## Rsync data from old server

- download rsync
```
mkdir -p ~/rsync-packages
cd ~/rsync-packages
dnf download --resolve rsync
```

- upload rsync.rpm and install it

```
rpm -Uvh *.rpm
```

- Dry run
```
sshpass -p 'Molex@2024' rsync -avhn \
  --no-o --no-g \
  --chown=kzheng:support \
  -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
  root@10.221.165.47:/app/docker/data/ \
  /app/docker/data/
```

- Real run
```
sshpass -p 'Molex@2024' rsync -avz --info=progress2 \
  --no-o --no-g \
  --chown=kzheng:support \
  -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
  root@10.221.165.47:/app/docker/data/ \
  /app/docker/data/ \
  | tee -a /var/log/rsync_pull_$(date +%F).log


  ```

## DNS/IP 牵移

- 旧服务器：halt
- 新服务器增加旧服器的IP：

2: ens192: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:9a:7b:97 brd ff:ff:ff:ff:ff:ff
    altname enp11s0
    inet 10.221.164.172/23 brd 10.221.165.255 scope global noprefixroute ens192
       valid_lft forever preferred_lft forever

```
sudo ip addr add 10.221.165.47/23 dev ens192
```
- 永久增加地址：

```
kzheng@mlxcduvlpapp01:~$ sudo cat /etc/NetworkManager/system-connections/ens192.nmconnection

[connection]
id=ens192
uuid=a1a75081-e2af-3fb9-88e1-6cf39d186428
type=ethernet
autoconnect-priority=-999
interface-name=ens192
timestamp=1748341178

[ethernet]

[ipv4]
address1=10.221.164.14/23,10.221.164.1
address2=10.221.164.171/23
dns=10.175.2.6;10.159.12.223;
dns-search=khc.local;molex.com;
method=manual

[ipv6]
addr-gen-mode=eui64
method=disabled

```
- 重启网络服务
```
sudo nmcli connection reload
sudo nmcli connection down ens192 && sudo nmcli connection up ens192
```


## Install Telegraf

```
rpm -ivh *.rpm
//update the config file instance to current server

sudo chmod 666 /var/run/docker.sock
systemctl enable telegraf.service
systemctl start telegraf.service

sudo journalctl -u telegraf.service -n 20

```

## App server update

- install yq

```
chmod +x /urs/local/bin/yq
/usr/local/bin/yq --version

chmod +rw /app/docker/data/docker-compose.yml

```

- 更新ssh证书

```
su - gitlab-runner
ssh-keyscan -H -t rsa,ecdsa,ed25519 app.cdu.molex.com >> ~/.ssh/known_hosts

```
- docker login
```
docker login kochsource.io:5005/mlxnetdev/chengdu --username=kamazheng --password=dwiXryqN1hz9KE7CGvXV
```