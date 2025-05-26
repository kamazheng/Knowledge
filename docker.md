Docker install====

```
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

<br/>

https://docs.docker.com/engine/install/centos/
systemctl status docker
docker info
https://codewithmukesh.com/blog/docker-guide-for-dotnet-developers/
https://learn.microsoft.com/zh-cn/visualstudio/containers/container-tools?view=vs-2022

##### 常用docker命令

###### Dock logs:

```
sudo journalctl -u docker -n 100 --no-pager
```

sudo docker build -t name:tag .

sudo journalctl -u docker.service
sudo docker logs dockername
sudo docker images
sudo docker save -o output_file.tar image_name:tag
sudo docker load -i output_file.tar
sudo docker start dockername
sudo docker update --restart always dockername

docker logs <container_id> 2>&1 | grep -i error

docker logs <container_id> 2>&1 | grep -i warn

### Using Docker’s Restart Policy

##### Start a new container with the restart policy:

> docker run -d --restart unless-stopped <container-name>

##### Update an existing container to use the restart policy:

> docker update --restart unless-stopped <container-name>

##### Apply the restart policy to all running containers:

> docker update --restart unless-stopped $(docker ps -q)

<br/>

#### List all Docker images:

docker images -a

This command will show all images, including intermediate layers.
Remove a specific image:
docker rmi <image_id>

Replace <image_id> with the ID of the image you want to remove.
Remove all unused images:
docker image prune -a

This command will remove all images that are not associated with any containers12.
Remove dangling images (images that are not tagged and not referenced by any container):
docker image prune

<br/>

##### /etc/docker/daemon.json

```
{
  "data-root": "/app/docker/lib",
  "dns-search": [
    "molex.com",
    "khc.local"
  ],
  "registry-mirrors": [
    "https://nexus.aip.molex.com:135",
    "http://nexus.cdu.molex.com:8083"
  ],
  "insecure-registries": [
    "nexus.aip.molex.com:135",
    "nexus.cdu.molex.com:8083"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "256m",
    "max-file": "4",
    "compress": "true"
  }
}
```

<br/>

### Docker network issue

manul check docker waring (ctl-c break):

```
dockerd
```

> ```
> sudo systemctl stop docker
> sudo ip link delete docker0
> 
> # remove the network files, update the path:
> sudo rm -rf /var/lib/docker/network/files
> 
> sudo systemctl restart NetworkManager
> sudo systemctl start docker
> 
> sudo docker network prune
> 
> docker compose down
> docker compose up -d
> ```

<br/>

```
 docker system prune -a
 docker volume prune
 
journalctl -u gitlab-runner -f

```
