[https://www.jianshu.com/p/f45085e042c3](https://)

### 安装mysql8.0

更新源

```
sudo apt update
```

执行MySQL安装命令，安装完毕默认启动

```
sudo apt install mysql-server
```

查看/启动/停止 MySQL服务状态：

```
sudo systemctl status mysql
sudo systemctl start mysql
sudo systemctl stop mysql
```

MySQL快速安装脚本mysql_secure_installation，。

调用脚本来轻松设置和管理mysql 初始化工作,配置数据库服务器的安全性工作。

安全设置之一，设置MySQL root用户的密码

```
sudo mysql_secure_installation
```

接下来，脚本将要求删除匿名用户，限制root用户对本地计算机的访问，删除测试数据库并重新加载特权表。

先以root用户身份登录到MySQL服务器，请输入：

```
sudo mysql
sudo mysql -u root -p
```

### 远程访问相关设置

向MySQL用户帐户授予权限

要授予对特定数据库用户帐户的所有特权，请使用以下命令：

```mysql
CREATE USER 'developer'@'localhost' IDENTIFIED BY 'KamaZheng@830591';
GRANT ALL PRIVILEGES ON database_name.* TO 'developer'@'localhost';

# myroot 用户设置所有主机可以访问,并给定操作数据库所有权限
GRANT ALL PRIVILEGES ON *.* TO 'developer'@'localhost';
ALTER USER 'developer'@'localhost' IDENTIFIED BY 'KamaZheng@830591' PASSWORD EXPIRE NEVER;
ALTER USER 'developer'@'localhost' IDENTIFIED WITH mysql_native_password BY 'KamaZheng@830591';

FLUSH PRIVILEGES;

```

<br/>

更改mysql配置文件：

在更改MySQL配置文件时一定要停止MySQL服务否则配置文件无法保存

```
sudo systemctl stop mysql
vim /etc/mysql/mysql.conf.d/mysqld.cnf
```

注掉 bind-address = 127.0.0.1

```
# bind-address = 127.0.0.1
```

启动MySQL服务：

远程登录测试

使用 Navicat Premium 12 测试远程登录

[defcon.cn/513.html](https://)

### 忘记密码：

```
cat /etc/mysql/debian.cnf
```

