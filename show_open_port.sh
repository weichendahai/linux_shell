#!/bin/bash

###################################################################################################
# esayops public tools
# file_ver: 1.0.0
# 主机开放端口检查
#
# create by Nano, 2016-7-1
# Copyright 2016 Nano Guo
# 本工具版权信息归作者所有，未经授权不可用于平台外的其它商业用途。
#
# Input variables:
#
# Output variables:
#
# Usage:
#
###################################################################################################

_checkEnv()
{
    which netstat > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "未找到 netstat 命令，尝试使用 nmap 命令检查..."
        comm="_nmap"
    else
         comm="_netstat" && return
    fi
    
    which nmap > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "未找到 nmap ！" && exit 1
    fi
}

_nmap()
{
    # get local_ip
    local_ip=`ip route|egrep 'proto kernel  scope link  src 172\.|proto kernel  scope link  src 10\.|proto kernel  scope link  src 192\.'|awk '{print $9}'|head -n 1`
    if [[ "x${local_ip}" == "x" ]]; then
        local_ip=`ip route|egrep 'proto kernel  scope link  src' |awk '{print $9}'|head -n 1`
    fi

    echo "PORT        SERVICE"
    nmap -p 1-65535 ${local_ip} | awk 'f;/Not/{f=1}' | grep -v "Nmap" | grep -v "PORT" | awk '{printf "%-10s %-20s\n ", $1 ,$3}'
}

_netstat()
{
    echo "PORT   SERVICE"
    netstat -tlnp | grep -v "State" | grep -v "only servers" | grep -v "127.0.0.1"| awk '{print $4, $7}' | awk 'BEGIN{FS=":|:::"} {print $2}' | sort -n -k1| uniq | awk -F / '{print $1, $NF}' | awk -F " " '{printf("%-6s %-30s\n ", $1, $3)}'
}

_checkOpenPort()
{
    ${comm}
}

############# main begin ###############
_checkEnv
_checkOpenPort
############# main end ################
