### 使用TreesDockerfile 部署 lnmp+redis+rabtitmq+mongodb+sphinx 等等测试和生产环境。
### TreesDockerfile 会极大方便项目的快速迭代开发和Git代码交付工作。


### 什么是



### 为什么


**下安装**

[Docker for Mac 下载](https://dn-dao-github-mirror.qbox.me/docker/install/mac/Docker.dmg)
在Mac上运行Docker。系统要求，OS X 10.10.3 或者更高版本，至少4G内存，4.3.30版本以前的VirtualBox会与Docker for Mac产生冲突，所以请卸载旧版本的VitrualBox。

**windows 7 下安装**

[Docker for Windows 下载](https://dn-dao-github-mirror.qbox.me/docker/install/windows/InstallDocker.msi)
在Windows上运行Docker。系统要求，Windows10x64位，支持Hyper-V。





yum 安装

```
sudo yum update
sudo yum install docker
#安装程序将docker程序安装到/usr/bin⺫⽬目录下，配置⽂文件安装在/etc/sysconfig/docker。安装好docker之后，可以 将docker加⼊入到启动服务组中 
sudo systemctl enable docker.service
#手动启动docker服务器，使⽤用命令 sudo systemctl start docker.service
```


### 常用命令
* docker start 容器名（容器ID也可以）
* docker stop 容器名（容器ID也可以）
* docker run 命令加 -d 参数，docker 会将容器放到后台运行
* docker ps 正在运行的容器

### docker 三剑客之Docker Compose

注：需要安装
```
yum -y install epel-release
yum -y install python-pip
pip install -U docker-compose

```


