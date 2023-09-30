#!/bin/sh

/sbin/sshd

rm -f /var/run/mysqld/mysqld.pid /var/lib/mysql/mysql.sock
/usr/sbin/mysqld --daemonize --user=mysql --pid-file=/var/run/mysqld/mysqld.pid

/opt/rh/rh-php73/root/usr/sbin/php-fpm --daemonize

/usr/sbin/nginx -c /etc/nginx/nginx.conf

sleep 1

auth_lock_file=/var/log/docker_init_auth.lock

if [ ! -z "${PUBLIC_STR}" ]; then
    if [ -f ${auth_lock_file} ]; then
        echo "`date "+%Y-%m-%d %H:%M:%S"` [信息] 跳过添加公钥"
    else
        echo "${PUBLIC_STR}" >> /root/.ssh/authorized_keys

        if [ $? -eq 0 ]; then
            echo "`date "+%Y-%m-%d %H:%M:%S"` [信息] 公钥添加成功"
            echo `date "+%Y-%m-%d %H:%M:%S"` > ${auth_lock_file}
        else
            echo "`date "+%Y-%m-%d %H:%M:%S"` [错误] 公钥添加失败"
        fi
    fi
fi

pw=$(pwgen -1 20)
echo "$(date +"%Y-%m-%d %H:%M:%S") [信息] Root用户密码：${pw}"
echo "root:${pw}" | chpasswd

mysql_lock_file=/var/log/docker_init_mysql.lock

if [ -f ${mysql_lock_file} ]; then
    echo "`date "+%Y-%m-%d %H:%M:%S"` [信息] 跳过初始化MySQL密码"
else
    MYSQL_ROOT_PASSWORD=$(pwgen -1 20)
    echo "`date "+%Y-%m-%d %H:%M:%S"` [信息] MySQL新密码："${MYSQL_ROOT_PASSWORD}

    MYSQL_TMP_ROOT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | tail -n 1 | awk '{print $NF}')
    mysqladmin -uroot -p"${MYSQL_TMP_ROOT_PASSWORD}" password ${MYSQL_ROOT_PASSWORD}

    if [ $? -eq 0 ]; then
        echo "`date "+%Y-%m-%d %H:%M:%S"` [信息] MySQL密码修改成功"
    else
        echo "`date "+%Y-%m-%d %H:%M:%S"` [错误] MySQL密码修改失败"
    fi

    unbuffer expect -c "
    spawn mysql_config_editor set --skip-warn --login-path=client --host=localhost --user=root --password
    expect -nocase \"Enter password:\" {send \"${MYSQL_ROOT_PASSWORD}\n\"; interact}
    "

    mysql -e 'show databases;'

    if [ $? -eq 0 ]; then
        echo "`date "+%Y-%m-%d %H:%M:%S"` [信息] MySQL容器无密码登录设置成功"
    else
        echo "`date "+%Y-%m-%d %H:%M:%S"` [错误] MySQL容器无密码登录设置失败"
    fi

    mysql -e "CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;"

    if [ $? -eq 0 ]; then
        echo "`date "+%Y-%m-%d %H:%M:%S"` [信息] 设置MySQL远程登录成功"
        # 密码和远程登录设置成功后锁定
        echo `date "+%Y-%m-%d %H:%M:%S"` > ${mysql_lock_file}
    else
        echo "`date "+%Y-%m-%d %H:%M:%S"` [错误] 设置MySQL远程登录失败"
    fi
fi

# 保持前台运行，不退出
while true
do
    sleep 3600
done

