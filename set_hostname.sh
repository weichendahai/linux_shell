#!/bin/bash

#########################################################################
# easyops public tools
# file_ver: 1.0.0
# create by Neven, 2016-7-15
# Copyright 2016 Neven Liang
# 本工具版权信息归作者所有，未经授权不可用于平台外的其它商业用途。
#
# Input variables:
#    input_hostname:输入想要设置的主机名
#
# Output variables:
#
# Usage: 修改主机名,确保重启后依然生效
# Memo:
#1、执行hostname XXX命令，在新的对话中，新的hostname生效，但重启主机后失效；
#2、为了重启后新的hostname依然生效，修 改/etc/sysconfig/network文件的HOSTNAME的值。
#########################################################################

# To check the permission of the current user
function user_check() {
    user=`whoami`
    if [ "$user" != "root" ];then
        echo '当前用户没有权限执行该工具,执行失败！'
        exit 1
    fi
}

# To backup the network file before modification
function backup()
{
    user=`whoami`
    if [[ ! -d /data/backup/hostname.bk ]]; then
        mkdir -p /data/backup/hostname.bk
    fi
    if [[ -f /etc/sysconfig/network ]]; then
        cat /etc/sysconfig/network > /data/backup/hostname.bk/${user}.`date +%Y%m%d-%H%M%S`
    else
        echo '/etc/sysconfig/network不存在，备份失败' && exit 100
    fi
    filename=`ls -lrt /data/backup/hostname.bk/ | tail -n 1 | awk '{print $NF}'`
    if [[ $? -ne 0 ]]; then
        echo "network 文件备份失败！已退出！" && exit 1
    else
        echo "network 备份文件 ${filename} 在 /data/backup/hostname.bk 目录下"
    fi
}

# To rollback the network file if modification is failed
function rollback()
{   
    if [[ -f /data/backup/hostname.bk/${filename} ]]; then
        cat /data/backup/hostname.bk/${filename} > /etc/sysconfig/network
        if [[ $? -ne 0 ]]; then
            echo "文件回滚失败！！！" && exit 200
        else
            echo "network 文件已经回滚为 ${filename}"
        fi
    else
        echo '备份文件不存在，回滚失败' && 255
    fi
}

# To excute the modification
function hostname_modification() {
    sed -i "s/^HOSTNAME=.*$/HOSTNAME=$input_hostname/g" /etc/sysconfig/network
    hostname $input_hostname
}

# To check the hostname in the specific file
function result_check() {
    result=`cat /etc/sysconfig/network | grep -i '^hostname' | awk -F '=' '{printf $2}'`
    echo "系统文件中HOSTNAME为 $result"
    if [ "$result" == "$input_hostname" ];then
        echo '修改成功！'
    else 
        echo '修改失败！'
        rollback && exit 1
    fi    
}

function main() {
    user_check
    backup
    hostname_modification
    result_check
}

########## main begin ##########
input_hostname=$1
if [ "$input_hostname"x == "x" ] ;then
    echo '-1|error: muste input rename hostname'
    exit -1
fi
echo $input_hostname
main
########### main end ###########
