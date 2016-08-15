#!/bin/bash
#########################################################################
# easyops public tools
# file_ver: 1.0.0
# create by Neven, 2016-7-06
# Copyright 2016 Neven Liang
# 本工具版权信息归作者所有，未经授权不可用于平台外的其它商业用途。
#
#
# Input variables:
#   table_name:可以选择查看指定的表，可填filter,nat,mangle 
#
# Output variables:
#
# Usage: 查看iptables的详情（-L），端口以数字显示（-n），显示规则前的序号（--line-number）
#########################################################################

#检测是否存在iptables命令
function iptables_check(){
    which iptables > /dev/null 2>&1
    retcode=$?
    if [ "${retcode}" -ne "0" ] ;then
        echo "目标机器没有安装iptables命令，请参照以下命令安装（注意权限）"
        echo -e "Ubuntu: \n# apt-get install iptables\n"
        echo -e "Debian: \n# apt-get update \n# apt-get install iptables\n"
        echo -e "Fedora / Centos: \n# yum install -y iptables"
        exit 1
    fi
}

#判断是否指定表名
function command()
{
    if [[ -z "${table_name}" ]]; then
        iptables -L -n --line-number
    else
        iptables -L -n --line-number -t $table_name
    fi
}

########## main begin ##########
iptables_check
command
########### main end ###########
