## TreesShell 定制化、自动化 部署 WEB项目生产环境。
### TreesShell 会极大方便项目生产环境的快速交付
&nbsp;
&nbsp;
&nbsp;
**优点**

* 定制化  可定制化编译安装项目运行的生产环境。
* 自动化  配置检查好shell脚本后，一键自动化安装。
* 持续更新  定制配置和执行脚本持续更新，保证安全可用可持续更新

> 目前只有文档版本（sh脚本不稳定，在测试当中）
目前有两个生产环境的的文档版本，一个是centos6稳定版平台，一个是centos7稳定版平台。在此基础上搭建WEB服务

备注：生产环境平台系统和服务镜像，阿里云开源系统：https://opsx.alibaba.com/mirror

Centos7稳定版平台（稳定性测试中...）
=================================

Centos7稳定版平台（Centos6.5系统）
=================================
**生产环境服务**：

* 1.nginx ：nginx/1.10.0
* 2.apache：Apache/2.4.20 (Unix)
* 3.php：PHP 5.6.22 (cli)
* 4.mysql：mysql  Distrib 5.7.11
* 5.redis：redis-3.2.5
* 6.rabbitmq：rabbitmq-3.6.3
* 7.shpinx：sphinx-2.2.11

**架构部署** LNMPA一层反向代理三台负载架构


### 服务安装

### 安装Nginx


### 安装Apache

### 安装Redis redis-3.2.5
#### 一、环境准备
1、安装 gcc gcc-c++ tcl
```
[root@iZ94ebgv853Z ~]# yum install gcc gcc-c++ tcl -y
```
2、下载redis-3.2.5.tar.gz、phpredis-4.0.0rc2
```
[root@iZ94ebgv853Z ~]#cd /home/soft
[root@iZ94ebgv853Z ~]#wget http://download.redis.io/releases/redis-3.2.5.tar.gz
[root@iZ94ebgv853Z ~]#wget https://codeload.github.com/phpredis/phpredis/zip/4.0.0RC2
```
#### 二、安装Redis
```
[root@iZ94ebgv853Z ~]# tar zvxf redis-3.2.5.tar.gz  #解压
[root@iZ94ebgv853Z ~]# cd redis-3.2.5
[root@iZ94ebgv853Z redis-3.2.5]# make
[root@iZ94ebgv853Z redis-3.2.5]# make test
[root@iZ94ebgv853Z redis-3.2.5]# make install
[root@iZ94ebgv853Zredis-3.2.5]# cp redis.conf /etc/  #复制配置文件
```
如果需自定义配置redis，可修改其配置文件/etc/redis.conf

通过vim命令修改/etc/redis.conf

将daemonize no 修改成 daemonize yes //默认后台程序运行

##### 报错如下：

前面3步应该没有问题，主要的问题是执行make的时候，出现了异常。

** 报错一： **

make[2]: cc: Command not found
异常原因：没有安装gcc
解决方案：yum install gcc-c++

** 报错二： **

zmalloc.h:51:31: error: jemalloc/jemalloc.h: No such file or directory
异常原因：一些编译依赖或原来编译遗留出现的问题
解决方案：make distclean。清理一下，然后再make。
在make成功以后，需要make test。在make test出现异常。

** 报错三： **

couldn’t execute “tclsh8.5”: no such file or directory
异常原因：没有安装tcl
解决方案：yum install -y tcl。

#### 三、启动redis
```
[root@iZ94ebgv853Z ~]# redis-server /etc/redis.conf
```
##### 四、编写自init.d脚本Redisinit

内容如下:
```
vim Redisinit
```
脚本
```
#chkconfig: 2345 10 90
#description: Start and Stop redis
PATH=/usr/local/bin:/sbin:/usr/bin:/bin
REDISPORT=6379
EXEC=/usr/local/bin/redis-server
REDISCLI=/usr/local/bin/redis-cli
PIDFILE=/var/run/redis.pid
CONF=”/etc/redis.conf”
case “$1” in
start)
if [ -f $PIDFILE ]
then
echo “$PIDFILE exists, process is already running or crashed”
else
echo “Starting Redis server…”
$EXEC $CONF
fi
if [ “$?”=”0” ]
then
echo “Redis is running…”
fi
;;
stop)
if [ ! -f $PIDFILE ]
then
echo “$PIDFILE does not exist, process is not running”
else
PID=$(cat $PIDFILE)
echo “Stopping …”
$REDIS_CLI -p $REDISPORT SHUTDOWN
while [ -x ${PIDFILE} ]
do
echo “Waiting for Redis to shutdown …”
sleep 1
done
echo “Redis stopped”
fi
restart|force-reload)
${0} stop
${0} start
;;
*)
echo “Usage: /etc/init.d/redis {start|stop|restart|force-reload}” >&2
exit 1
esac
```
cp到/etc/init.d/目录下

修改权限，可以运行
```
chmod +x /etc/init.d/redis
```
启动服务：
```
service redis start
```
停止服务：
```
service redis stop
```
#### 五、设置防火墙
```
[root@iZ94ebgv853Z ~]# iptables -I INPUT 1 -p tcp --dport6379 -j ACCEPT  #开启6379端口
[root@iZ94ebgv853Z ~]# service iptables save  #保存防火墙的配置
```
如果没有/etc/sysconfig/iptables 文件，执行上面命令
如果有/etc/sysconfig/iptables 文件，将下面代码复制到文件中

** 开启6379端口 **
```
-A INPUT -m state --state NEW -m tcp -p tcp --dport 6379 -j ACCEPT
/etc/sysconfig/iptables文件
# Firewall configuration written bysystem-config-firewall
# Manual customization of this file is notrecommended.
filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
#开启6379端口
-A INPUT -m state --state NEW -m tcp -p tcp --dport 6379 -j ACCEPT

COMMIT
```
把文本框内容写入到/etc/sysconfig/iptables，覆盖原来的内容(如果有的话)。
```
[root@iZ94ebgv853Z ~]# service iptables start    #启动防火墙 service iptables restart 
```
六、设置开机启动

设置iptables开机启动
```
[root@iZ94ebgv853Z~]# chkconfig iptables on  #设置iptables开机启动
```
设置redis开机启动：
在/etc/rc.local中添加：
```
/usr/local/bin/redis-server /etc/redis.conf > /dev/null &
```

### 安装Rabbitmq rabbitmq-3.6.3

Centos6.5 安装 RabbitMQ3.6.3
-----------------------------
安装编译工具
```
yum -y install make gcc gcc-c++ kernel-devel m4 ncurses-devel openssl-devel
```
** yum安装python **

#### 安装Erlang
##### 1. 下载erlang
官方下载地址：
```
wget http://erlang.org/download/otp_src_18.3.tar.gz
```

##### 2.安装
** 解压 **
```
tar xvf otp_src_18.3.tar.gz
cd otp_src_18.3
```
** 配置 '--prefix'指定的安装目录**
```
./configure --prefix=/usr/local/erlang --with-ssl -enable-threads -enable-smmp-support -enable-kernel-poll --enable-hipe --without-javac
```
** 安装 **
``
make && make install
```
#### 3.配置erlang环境变量
```
vim /etc/profile
``
** 在文件末尾添加下面代码 'ERLANG_HOME'等于上一步'--prefix'指定的目录 **
``
ERLANG_HOME=/usr/local/erlang
PATH=$ERLANG_HOME/bin:$PATH
export ERLANG_HOME
export PATH
``
** 使环境变量生效 ** 
``
source /etc/profile
``
**  输入命令检验是否安装成功 ** 
``
erl
``


#### 安装RabbitMQ
##### 1.下载RabbitMQ

** 官方下载地址： **
```
wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.3/rabbitmq-server-generic-unix-3.6.3.tar.xz
```
##### 2.安装 
RabbitMQ3.6版本无需make、make install 解压就可以用

** 解压rabbitmq，官方给的包是xz压缩包，所以需要使用xz命令 **
```
xz -d rabbitmq-server-generic-unix-3.6.3.tar.xz
```
** xz解压后得到.tar包，再用tar命令解压 **
```
tar -xvf rabbitmq-server-generic-unix-3.6.3.tar
```
** 移动目录 看个人喜好 **
```
cp -rf ./rabbitmq_server-3.6.3 /usr/local/
cd /usr/local/
```
** 修改文件夹名 **
```
mv rabbitmq_server-3.6.3 rabbitmq-3.6.3
```
** 开启管理页面插件 **
```
cd ./rabbitmq-3.6.3/sbin/
./rabbitmq-plugins enable rabbitmq_management
```
3.启动
** 启动命令，该命令ctrl+c后会关闭服务 **
```
./rabbitmq-server
```
** 在后台启动Rabbit **
``
./rabbitmq-server -detached
```
** 关闭服务 **
``
./rabbitmqctl stop
``
** 关闭服务(kill) 找到rabbitmq服务的pid  [不推荐] **
```
ps -ef|grep rabbitmq
kill -9 ****
```
##### 4. 添加管理员账号

** 进入RabbitMQ安装目录 **
```
cd /usr/local/rabbitmq-3.6.3/sbin
```
** 添加用户 **
```
#rabbitmqctl add_user Username Password
./rabbitmqctl add_user treesmq treesmq421
```
** 分配用户标签 **
```
#rabbitmqctl set_user_tags User Tag
#[administrator]:管理员标签
./rabbitmqctl set_user_tags treesmq administrator
```
##### 5.登录管理界面
浏览器输入地址：http://服务器IP地址:15672/ 
输入第4部添加的账号密码登录 
其他
1.访问不了 
安装完成之后如果机器有iptables，需要开放端口
```
vim /etc/sysconfig/iptables
```
** RabbitMQ iptables config**
```
#RabbitMQ
-A INPUT -p tcp -m state --state NEW -m tcp --dport 15672 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 25672 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 5672 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 4369 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 5671 -j ACCEPT
#RabbitMQ
```

#### RabbitMQ压缩包.xz解压问题
需要安装xz软件（网上有教程，我之后也会补充）
如果嫌麻烦，可直接下载我解压好的包
下载地址：http://download.csdn.net/detail/a15134566493/9518835

Linux中没有xz解压工具
```
wget https://jaist.dl.sourceforge.net/project/lzmautils/xz-5.2.3.tar.gz
```
1.下载xz包
https://tukaani.org/xz/

2.解压安装包
```
$tar -jxvf xz-xxx.tar.bz2
tar -zxvf xz-xxx.tar.bz2
cd xz-xxx.tar.bz2
3.配置&安装
$ ./configure --prefix=/opt/gnu/xz
$ make
$ sudo make install

$ln -s /opt/gnu/xz/bin/xz /bin/xz
```
### rabbitmq的简单管理命令笔记
rabbitmq最新版本在外部的访问权限上进行了进一步的控制，其中默认情况下，guest用户只能通过本地loopback端口访问
为了在外部对rabbitmq进行连接和访问，需要新增用户，对用到的命令进行简单记录
```
rabbitmqctl add_user <username> <userpass>
rabbitmqctl add_vhost <path>
rabbitmqctl set_user_tags <username> administrator
rabbitmqctl set_permissions -p <path> <username> ".*" ".*" ".*"

rabbitmq简单状态查询命令
rabbitmqctl list_connections  ---用于查看当前的连接
rabbitmqctl list_queues    ---会列出所有队列名称，后边可能还会带着这个队列当前消息数
rabbitmqctl status       ---查看当前队列信息

rabbitmq恢复出厂设置命令
rabbitmqctl stop_app
rabbitmqctl reset/force_reset
rabbitmqctl start_app

rabbitmq清除队列里的消息
rabbitmqctl -p ${vhost-name} purge_queue ${queue-name}
```
##### 权限修复
```
cd /usr/local/rabbitmq/sbin
[origalom@developers ~] rabbitmqctl add_user rabbit rabbit   # 添加用户
[origalom@developers ~] rabbitmqctl set_permissions -p / treesmq ".*" ".*" ".*" # 添加权限
[origalom@developers ~] rabbitmqctl set_user_tags treesmq administrator # 修改角色
```


### 安装shpinx  sphinx-2.2.11



[Docker for Mac 下载](https://dn-dao-github-mirror.qbox.me/docker/install/mac/Docker.dmg)
在Mac上运行Docker。系统要求，OS X 10.10.3 

** windows 7 下安装 **

[Docker for Windows 下载](https://dn-dao-github-mirror.qbox.me/docker/install/windows/InstallDocker.msi)
在Windows上运行Docker


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


