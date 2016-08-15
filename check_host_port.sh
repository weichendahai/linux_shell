#!/bin/bash

###################################################################################################
# esayops public tools
# file_ver: 1.0.0
# 检查端口是否能否连通
#
# create by Nano, 2016-7-1
# Copyright 2016 Nano Guo
# 本工具版权信息归作者所有，未经授权不可用于平台外的其它商业用途。
#
# Input variables:
#     参数为 ip和port, 示例 192.168.100.36 2181
# Output variables:
#
# Usage:
#
###################################################################################################

_help()
{
    echo "---------------------------------------------------"
    echo "【参数】为 ip和port ，示例 192.168.100.36 2181"
    echo "---------------------------------------------------"
}
_checkEnv()
{
    which nc > /dev/null 2>&1
    if [[ $? -ne 0 ]];then
        echo "未找到 nc 命令，尝试使用 nmap 检查"
        comm='_nmap'
    else
        comm='_nc' && return
    fi
    which nmap > /dev/null 2>&1
    if [[ $? -ne 0 ]];then
        echo "未找到 nmap 命令，尝试使用 telnet 检查"
        comm='_telnet'
    else
        comm='_nmap' && return
    fi

    which telnet > /dev/null 2>&1
    if [[ $? -ne 0 ]];then
        echo "未找到 telnet 命令，无法进行检查" && exit 1
    fi
    
    which bc > /dev/bull 2>&1
    if [[ $? -ne 0 ]]; then
        echo "为判断端口是否为整数，需要bc命令，请安装" && exit 1
    fi
}

_checkPara()
{
    if [[ ${ip} =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]];then
        echo ""
    else
        echo "ip不正确!"
        _help && exit 1
    fi
    if [[ $(echo ${port}/1|bc) == "${port}" ]] && [[ ${port} -ge 0 ]] && [[ ${port} -le 65535 ]];then
        echo ""
    else
        echo "端口不合法！"
        _help && exit 1
    fi
    
}

_nc()
{
    nc -zn -w 10 ${ip} ${port} > /dev/null
    if [[ $? -eq 0 ]];then
        echo "连接到 ${ip} ${port} 成功！"
    else
        echo "连接到 ${ip} ${port} 失败" && exit 1
    fi
}

_nmap()
{
    nmap -p ${port} ${ip} | grep "open" > /dev/null
    if [[ $? -eq 0 ]];then
        echo "连接到 ${ip} ${port} 成功！"
    else
        echo "连接到 ${ip} ${port} 失败！" && exit 1
    fi
}

_telnet()
{
    echo "xxx" | telnet ${ip} ${port} | grep -i "Connected" > /dev/null
    if [[ $? -eq 0 ]];then
        echo "连接到 ${ip} ${port} 成功！"
    else
        echo "连接到 ${ip} ${port} 失败！" && exit 1
    fi
}

_checkPort()
{
    echo ""
    $comm
}
############ main begin ##############
ip=$1
port=$2
_checkPara
_checkEnv
_checkPort
############ main end ################
