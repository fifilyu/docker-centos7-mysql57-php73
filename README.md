# docker-centos7-mysql57-php73
基于CentOS7 + MySQL57 + PHP73的Docker镜像

## CentOS7 + MySQL57基础镜像

本项目基于 [docker-centos7-mysql57](https://github.com/fifilyu/docker-centos7-mysql57) 构建。

请访问 [docker-centos7-mysql57](https://github.com/fifilyu/docker-centos7-mysql57) 查看基本使用方法。

## 构建镜像

```bash
git clone https://github.com/fifilyu/docker-centos7-mysql57-php73.git
cd docker-centos7-mysql57-php73
docker buildx build -t fifilyu/centos7-mysql57-php73:latest .
```

## 内置组件

* Nginx
* MySQL57
* PHP73-FPM

## 使用方法

```bash
docker run -d \
    --env LANG=en_US.UTF-8 \
    --env TZ=Asia/Shanghai \
    -p 2080:80 \
    -p 23306:3306 \
    --name phpdemo fifilyu/centos7-mysql57-php73:latest
```

*容器默认Web目录： `/data/web/default`*

测试URL： http://localhost:2080

测试MySQL： `mysql -h 127.0.0.1 -P23306 -uroot -p'密码'`

_注意，MySQL连接必须用 `127.0.0.1`，`localhost` 会走sock连接，导致连接到本机MySQL。_

### PHP代码如何连接数据库

直接在PHP代码中，填写以下MySQL连接信息：

* MySQL主机地址：`localhost`
* MySQL主机端口：`3306`
* MySQL用户名称：`root`
* MySQL用户密码：(执行 `docker logs phpdemo` 命令查看MySQL默认密码)

## 环境说明

### Nginx配置文件

* /etc/nginx/nginx.conf
* /etc/nginx/conf.d/default.conf

### PHP配置文件

* /etc/opt/rh/rh-php73/php.ini
* /etc/opt/rh/rh-php73/php.d

[NOTE]
如果要启用或禁用模块，请直接修改 `php.d` 下的 `.ini` 文件。

### PHP-FPM配置文件

* /etc/opt/rh/rh-php73/php-fpm.conf
* /etc/opt/rh/rh-php73/php-fpm.d

### PHP-FPM日志文件

* /var/opt/rh/rh-php73/log/php-fpm/error.log

### PHP环境配置变更明细

    [PHP]
    # 启用 '<? ... ?>' 代码风格
    engine = On

    # 禁止一些危险性高的函数
    disable_functions = passthru,exec,system,putenv,chroot,chgrp,chown,shell_exec,popen,proc_open,pcntl_exec,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,imap_open,apache_setenv

    # 是否向外界公开PHP版本号，如 "X-Powered-By: PHP/7.3.33"
    expose_php = Off

    # 执行时间相关
    max_execution_time = 300
    max_input_time = 60
    memory_limit = 128M

    # 错误相关
    error_reporting = E_ALL & ~E_NOTICE
    display_errors = On
    track_errors = Off

    # 上传相关
    post_max_size = 50M
    file_uploads = On
    upload_max_filesize = 50M
    max_file_uploads = 20
    
    # CGI设置
    cgi.fix_pathinfo = 1

    [Date]
    # 配置中国时区
    date.timezone = Asia/Shanghai

### PHP启用模块

* bcmath
* bz2
* calendar
* ctype
* curl
* dom
* exif
* fileinfo
* ftp
* gd
* gettext
* iconv
* intl
* json
* mbstring
* mysqli
* mysqlnd
* pdo
* pdo_mysql
* pdo_sqlite
* phar
* posix
* shmop
* simplexml
* sockets
* sqlite3
* sysvmsg
* sysvsem
* sysvshm
* tokenizer
* wddx
* xml
* xmlreader
* xmlrpc
* xmlwriter
* xsl
* zip