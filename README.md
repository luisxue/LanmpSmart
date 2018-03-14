## TreesShell 定制化、自动化 部署 WEB项目生产环境。
### TreesShell 会极大方便项目生产环境的快速交付
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
**优点**

* 定制化  可定制化编译安装项目运行的生产环境。
* 自动化  配置检查好shell脚本后，一键自动化安装。
* 持续更新  定制配置和执行脚本持续更新，保证安全可用可持续更新

> 目前只有文档版本（sh脚本不稳定，在测试当中）
目前有两个生产环境的的文档版本，一个是centos6稳定版平台，一个是centos7稳定版平台。在此基础上搭建WEB服务

备注：生产环境平台系统和服务镜像，阿里云开源系统：https://opsx.alibaba.com/mirror

Centos7稳定版平台（稳定性测试中...）
=================================


*
*
*


Centos6稳定版平台（Centos6.5系统）
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
*
*
*

### WEB服务安装

### 安装Nginx
Centos6.5下 安装nginx/1.10.0
---------------------------
#### 1.安装环境
nginx的编译需要c++，同时prce（重定向支持）和openssl（https支持）也需要安装。
顺序安装依赖
```
yum install gcc-c++  
yum -y install pcre*  
yum -y install openssl* 

```
#### 2.下载nginx-1.10.0.tar.gz，可放在 /home/local/ 目录下
```
cd /usr/local/  
wget http://nginx.org/download/nginx-1.9.9.tar.gz 
```

#### 3.解压及编译安装
```
tar -zxvf nginx-1.9.9.tar.gz 
cd nginx-1.9.9 
./configure --prefix=/usr/local/nginx 
make  &&  make  install
```
#### 4.启动nginx服务
```
cd /usr/local/nginx  
./nginx
./nginx  -t
./nginx  -s reload
```
#### 5.查看进程
```
ps -ef | grep nginx
./nginx -s reload
```

#### 6.添加、编写启动脚本 /etc/init.d/nginx
```
vim /etc/init.d/nginx
```
编写启动脚本
```
#!/bin/sh 
# 
# nginx - this script starts and stops the nginx daemon 
# 
# chkconfig:   - 85 15 
# description: Nginx is an HTTP(S) server, HTTP(S) reverse \ 
#               proxy and IMAP/POP3 proxy server 
# processname: nginx 
# config:      /etc/nginx/nginx.conf 
# config:      /etc/sysconfig/nginx 
# pidfile:     /var/run/nginx.pid 

# Source function library. 
. /etc/rc.d/init.d/functions 

# Source networking configuration. 
. /etc/sysconfig/network 

# Check that networking is up. 
[ "$NETWORKING" = "no" ] && exit 0 

nginx="/usr/local/nginx/sbin/nginx" 
prog=$(basename $nginx) 

NGINX_CONF_FILE="/usr/local/nginx/conf/nginx.conf" 

[ -f /etc/sysconfig/nginx ] && . /etc/sysconfig/nginx 

lockfile=/var/lock/subsys/nginx 

start() { 
    [ -x $nginx ] || exit 5 
    [ -f $NGINX_CONF_FILE ] || exit 6 
    echo -n $"Starting $prog: " 
    daemon $nginx -c $NGINX_CONF_FILE 
    retval=$? 
    echo 
    [ $retval -eq 0 ] && touch $lockfile 
    return $retval 
} 

stop() { 
    echo -n $"Stopping $prog: " 
    killproc $prog -QUIT 
    retval=$? 
    echo 
    [ $retval -eq 0 ] && rm -f $lockfile 
    return $retval 
killall -9 nginx 
} 

restart() { 
    configtest || return $? 
    stop 
    sleep 1 
    start 
} 

reload() { 
    configtest || return $? 
    echo -n $"Reloading $prog: " 
    killproc $nginx -HUP 
RETVAL=$? 
    echo 
} 

force_reload() { 
    restart 
} 

configtest() { 
$nginx -t -c $NGINX_CONF_FILE 
} 

rh_status() { 
    status $prog 
} 

rh_status_q() { 
    rh_status >/dev/null 2>&1 
} 

case "$1" in 
    start) 
        rh_status_q && exit 0 
    $1 
        ;; 
    stop) 
        rh_status_q || exit 0 
        $1 
        ;; 
    restart|configtest) 
        $1 
        ;; 
    reload) 
        rh_status_q || exit 7 
        $1 
        ;; 
    force-reload) 
        force_reload 
        ;; 
    status) 
        rh_status 
        ;; 
    condrestart|try-restart) 
        rh_status_q || exit 0 
            ;; 
    *)    
      echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload|configtest}" 
        exit 2 

esac
```

执行启动脚本 /etc/init.d/nginx
```
chmod 755 /etc/init.d/nginx
chkconfig --add nginx
```
#### nginx启动、停止、平滑重启
```
service nginx start
service nginx stop
service nginx reload
```

> nginx vhosts配置 新建mkdir /usr/local/nginx/conf/vhosts目录后，编辑vi /usr/local/nginx/conf/nginx.conf 加入include vhosts/* 自我定制配置vhosts下test.conf等配置文件

### 安装Apache
Centos6.5下 安装Apache/2.4.20 
---------------------------







### 安装Redis redis-3.2.5

Centos6.5下 安装redis-3.2.5
---------------------------
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

**报错一：**

make[2]: cc: Command not found
异常原因：没有安装gcc
解决方案：yum install gcc-c++

**报错二：**

zmalloc.h:51:31: error: jemalloc/jemalloc.h: No such file or directory
异常原因：一些编译依赖或原来编译遗留出现的问题
解决方案：make distclean。清理一下，然后再make。
在make成功以后，需要make test。在make test出现异常。

**报错三：**

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

**开启6379端口**
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
**yum安装python**

#### 安装Erlang
##### 1. 下载erlang
官方下载地址：
```
wget http://erlang.org/download/otp_src_18.3.tar.gz
```

##### 2.安装
**解压**
```
tar xvf otp_src_18.3.tar.gz
cd otp_src_18.3
```
**配置 '--prefix'指定的安装目录**
```
./configure --prefix=/usr/local/erlang --with-ssl -enable-threads -enable-smmp-support -enable-kernel-poll --enable-hipe --without-javac
```
**安装**
``
make && make install
```
#### 3.配置erlang环境变量
```
vim /etc/profile
``
**在文件末尾添加下面代码 'ERLANG_HOME'等于上一步'--prefix'指定的目录**
``
ERLANG_HOME=/usr/local/erlang
PATH=$ERLANG_HOME/bin:$PATH
export ERLANG_HOME
export PATH
``
**使环境变量生效** 
``
source /etc/profile
``
**输入命令检验是否安装成功** 
``
erl
``


#### 安装RabbitMQ
##### 1.下载RabbitMQ

**官方下载地址：**
```
wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.3/rabbitmq-server-generic-unix-3.6.3.tar.xz
```
##### 2.安装 
RabbitMQ3.6版本无需make、make install 解压就可以用

**解压rabbitmq，官方给的包是xz压缩包，所以需要使用xz命令**
```
xz -d rabbitmq-server-generic-unix-3.6.3.tar.xz
```
**xz解压后得到.tar包，再用tar命令解压**
```
tar -xvf rabbitmq-server-generic-unix-3.6.3.tar
```
**移动目录 看个人喜好**
```
cp -rf ./rabbitmq_server-3.6.3 /usr/local/
cd /usr/local/
```
**修改文件夹名**
```
mv rabbitmq_server-3.6.3 rabbitmq-3.6.3
```
**开启管理页面插件**
```
cd ./rabbitmq-3.6.3/sbin/
./rabbitmq-plugins enable rabbitmq_management
```
3.启动
**启动命令，该命令ctrl+c后会关闭服务**
```
./rabbitmq-server
```
**在后台启动Rabbit**
```
./rabbitmq-server -detached
```
**关闭服务**
```
./rabbitmqctl stop
```
**关闭服务(kill) 找到rabbitmq服务的pid  [不推荐]**
```
ps -ef|grep rabbitmq
kill -9 ~~~~
```
##### 4. 添加管理员账号

**进入RabbitMQ安装目录**
```
cd /usr/local/rabbitmq-3.6.3/sbin
```
**添加用户**
```
#rabbitmqctl add_user Username Password
./rabbitmqctl add_user treesmq treesmq421
```
**分配用户标签**
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
**RabbitMQ iptables config**
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

Centos6.5 安装 sphinx-2.2.11
-----------------------------

#### 1.下载
```
cd /usr/software
wget http://sphinxsearch.com/files/sphinx-2.2.11-release.tar.gz
```
或者直接去Sphinx官网去下载最新版本
#### 2、安装依赖包
```
yum -y install make gcc g++ gcc-c++ libtool autoconf automake imake mysql-devel libxml2-devel expat-devel
```
#### 3、安装Sphinx 
```
tar zxvf sphinx-2.2.11-release.tar.gz

cd sphinx-2.2.11-release
```
检测一下当前的环境是否满足安装Sphinx的要求且指定安装路径。命令如下：
```
./configure --prefix=/usr/local/sphinx
```
**编译安装**
make
如果make失败了，可以用make clean 清除下再重新make 一下
make install
```
vi /etc/ld.so.conf 

/usr/local/mysql/lib #增加这一行保存 

/sbin/ldconfig -v
```
#### 4、配置Sphinx

```
cd /usr/local/sphinx/etc
cp sphinx-min.conf.dist csft.conf
vi csft.conf
```
```
source mysql
{
 type       = mysql
 sql_host     = 10.10.3.203
 sql_user     = root
 sql_pass     = dsideal
 sql_db      = test
 sql_port     = 3306
 sql_sock     = /usr/local/mysql/mysql.sock
 sql_query_pre   = SET NAMES utf8
 sql_query     = SELECT id, group_id, UNIX_TIMESTAMP(date_added) AS date_added, title, content FROM documents
 sql_attr_uint   = group_id
 #sql_attr_timestamp= date_added
 #sql_query_info_pre= SET NAMES utf8
 #sql_query_info  = SELECT * FROM aaa WHERE id=$id
}
index index_mysql
{
 source    = mysql
 path     = /usr/local/sphinx/var/data
 docinfo    = extern
 mlock     = 0
 min_word_len = 1
 charset_type = utf-8
 charset_table = U+FF10..U+FF19->0..9, 0..9, U+FF41..U+FF5A->a..z, U+FF21..U+FF3A->a..z,A..Z->a..z, a..z, U+0149, U+017F, U+0138, U+00DF, U+00FF, U+00C0..U+00D6->U+00E0..U+00F6,U+00E0..U+00F6, U+00D8..U+00DE->U+00F8..U+00FE, U+00F8..U+00FE, U+0100->U+0101, U+0101,U+0102->U+0103, U+0103, U+0104->U+0105, U+0105, U+0106->U+0107, U+0107, U+0108->U+0109,U+0109, U+010A->U+010B, U+010B, U+010C->U+010D, U+010D, U+010E->U+010F, U+010F,U+0110->U+0111, U+0111, U+0112->U+0113, U+0113, U+0114->U+0115, U+0115, U+0116->U+0117,U+0117, U+0118->U+0119, U+0119, U+011A->U+011B, U+011B, U+011C->U+011D,U+011D,U+011E->U+011F, U+011F, U+0130->U+0131, U+0131, U+0132->U+0133, U+0133, U+0134->U+0135,U+0135, U+0136->U+0137, U+0137, U+0139->U+013A, U+013A, U+013B->U+013C, U+013C,U+013D->U+013E, U+013E, U+013F->U+0140, U+0140, U+0141->U+0142, U+0142, U+0143->U+0144,U+0144, U+0145->U+0146, U+0146, U+0147->U+0148, U+0148, U+014A->U+014B, U+014B,U+014C->U+014D, U+014D, U+014E->U+014F, U+014F, U+0150->U+0151, U+0151, U+0152->U+0153,U+0153, U+0154->U+0155, U+0155, U+0156->U+0157, U+0157, U+0158->U+0159,U+0159,U+015A->U+015B, U+015B, U+015C->U+015D, U+015D, U+015E->U+015F, U+015F, U+0160->U+0161,U+0161, U+0162->U+0163, U+0163, U+0164->U+0165, U+0165, U+0166->U+0167, U+0167,U+0168->U+0169, U+0169, U+016A->U+016B, U+016B, U+016C->U+016D, U+016D, U+016E->U+016F,U+016F, U+0170->U+0171, U+0171, U+0172->U+0173, U+0173, U+0174->U+0175,U+0175,U+0176->U+0177, U+0177, U+0178->U+00FF, U+00FF, U+0179->U+017A, U+017A, U+017B->U+017C,U+017C, U+017D->U+017E, U+017E, U+0410..U+042F->U+0430..U+044F, U+0430..U+044F,U+05D0..U+05EA, U+0531..U+0556->U+0561..U+0586, U+0561..U+0587, U+0621..U+063A, U+01B9,U+01BF, U+0640..U+064A, U+0660..U+0669, U+066E, U+066F, U+0671..U+06D3, U+06F0..U+06FF,U+0904..U+0939, U+0958..U+095F, U+0960..U+0963, U+0966..U+096F, U+097B..U+097F,U+0985..U+09B9, U+09CE, U+09DC..U+09E3, U+09E6..U+09EF, U+0A05..U+0A39, U+0A59..U+0A5E,U+0A66..U+0A6F, U+0A85..U+0AB9, U+0AE0..U+0AE3, U+0AE6..U+0AEF, U+0B05..U+0B39,U+0B5C..U+0B61, U+0B66..U+0B6F, U+0B71, U+0B85..U+0BB9, U+0BE6..U+0BF2, U+0C05..U+0C39,U+0C66..U+0C6F, U+0C85..U+0CB9, U+0CDE..U+0CE3, U+0CE6..U+0CEF, U+0D05..U+0D39, U+0D60,U+0D61, U+0D66..U+0D6F, U+0D85..U+0DC6, U+1900..U+1938, U+1946..U+194F, U+A800..U+A805,U+A807..U+A822, U+0386->U+03B1, U+03AC->U+03B1, U+0388->U+03B5, U+03AD->U+03B5,U+0389->U+03B7, U+03AE->U+03B7, U+038A->U+03B9, U+0390->U+03B9, U+03AA->U+03B9,U+03AF->U+03B9, U+03CA->U+03B9, U+038C->U+03BF, U+03CC->U+03BF, U+038E->U+03C5,U+03AB->U+03C5, U+03B0->U+03C5, U+03CB->U+03C5, U+03CD->U+03C5, U+038F->U+03C9,U+03CE->U+03C9, U+03C2->U+03C3, U+0391..U+03A1->U+03B1..U+03C1,U+03A3..U+03A9->U+03C3..U+03C9, U+03B1..U+03C1, U+03C3..U+03C9, U+0E01..U+0E2E,U+0E30..U+0E3A, U+0E40..U+0E45, U+0E47, U+0E50..U+0E59, U+A000..U+A48F, U+4E00..U+9FBF,U+3400..U+4DBF, U+20000..U+2A6DF, U+F900..U+FAFF, U+2F800..U+2FA1F, U+2E80..U+2EFF,U+2F00..U+2FDF, U+3100..U+312F, U+31A0..U+31BF, U+3040..U+309F, U+30A0..U+30FF,U+31F0..U+31FF, U+AC00..U+D7AF, U+1100..U+11FF, U+3130..U+318F, U+A000..U+A48F,U+A490..U+A4CF
 min_prefix_len = 0
 min_infix_len = 1
 ngram_len   = 1

}
indexer
{
 mem_limit  = 256M
}
searchd
{
 listen      = 3312
 listen      = 3313:mysql41
 log        = /usr/local/sphinx/var/log/searchd.log
 query_log     = /usr/local/sphinx/var/log/query.log
 read_timeout   = 5
 client_timeout  = 300
 max_children   = 30
 pid_file     = /usr/local/sphinx/var/log/searchd.pid
 max_matches    = 1000
 seamless_rotate  = 1
 preopen_indexes  = 1
 unlink_old    = 1
}
```
**备注： 当前复制原有环境，批量修改配置是最快的方法**

#### 5、启动Sphinx、创建索引

**启动**
```
/usr/local/sphinx/bin/searchd -c /usr/local/sphinx/etc/csft.conf
```
**创建索引**
```
/usr/local/sphinx/bin/indexer -c /usr/local/sphinx/etc/csft.conf --rotate --all
```
**停止**
```
/usr/local/sphinx/bin/searchd -c /usr/local/sphinx/etc/csft.conf --stop
```

```
CREATE TABLE `documents_sphinxse` (
 `id` bigint(20) unsigned NOT NULL,
 `weight` int(11) DEFAULT '1',
 `query` varchar(3072) NOT NULL,
 `author_id` int(10) unsigned DEFAULT '0',
 `group_id` int(10) unsigned DEFAULT '0',
 KEY `query` (`query`(1024))
) ENGINE=SPHINX DEFAULT CHARSET=utf8 CONNECTION='sphinx://10.10.3.203:3312';
```
```
Select id from   documents_sphinxse where query="增加用户"; 
```
```
#/usr/local/sphinx/bin/searchd -c /etc/sphinx/sphinx_pro.conf
#/usr/local/sphinx/bin/indexer --config /etc/sphinx/sphinx_pro.conf --all --rotate
```

> 备注： 在centos系统的定时服务中，写入crontab：/etc/crontab，每分钟执行sphinx同步一次
```
*/1 * * * * /usr/local/sphinx/bin/indexer --config /etc/sphinx/sphinx_pro.conf --all --rotate
```
[Docker for Mac 下载](https://dn-dao-github-mirror.qbox.me/docker/install/mac/Docker.dmg)
在Mac上运行Docker。系统要求，OS X 10.10.3 

**windows 7 下安装**

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


