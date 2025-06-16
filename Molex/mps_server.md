# MPS Server

| 环境 | 类型 | 操作系统 | 应用名称 | 主机名 | 系统版本 | 网络区域 | IP 地址 | 配置 |
|------|------|----------|----------|--------|-----------|----------|---------|------|
| Prod | APP | Linux | MPS-数据中台1 | MLXCDUVLPSC01 | Linux Redhat 9.x | DMZ | 10.221.164.201 | 16核-内存24G-硬盘850G |
| Prod | APP | Linux | MPS-数据中台2 | MLXCDUVLPSC02 | Linux Redhat 9.x | DMZ | 10.221.164.202 | 16核-内存24G-硬盘850G |
| Prod | APP | Linux | MPS-数据中台3 | MLXCDUVLPSC03 | Linux Redhat 9.x | DMZ | 10.221.164.203 | 16核-内存24G-硬盘850G |
| Prod | APP | Linux | MPS-应用（主计划平台应用） | MLXCDUVLPSC04 | Linux Redhat 9.x | DMZ | 10.221.164.204 | 8核-内存8G-硬盘600G |
| Prod | APP | Linux | MPS-应用（主计划平台应用） | MLXCDUVLPSC06 | Linux Redhat 9.x | DMZ | 10.221.164.206 | 8核-内存8G-硬盘100G |
| Prod | DB-Postgre SQL | Linux | MPS-数据库 | MLXCDUVLPSC05 | Linux Redhat 9.x | DMZ | 10.221.164.205 | 8核-内存24G-硬盘500G |
| Prod | APP | Linux | MPS-负载均衡 | MLXCDUVLPSC07 | Linux Redhat 9.x | DMZ | 10.221.164.207 (域名：mpsapp.cdu.molex.com/mps.cdu.molex.com) | 4核-内存4G-硬盘50G |