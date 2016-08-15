#!/bin/bash

###################################################################################################
# esayops public tools
# file_ver: 0.0.1
# 查看端口回收与重用
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

_main()
{
    echo "查看端口重用是否开启:"
    flag=`cat /etc/sysctl.conf | grep "^net.ipv4.tcp_tw_reuse" | awk '{print $3}'`
    if [[ "x${flag}" != "x1" ]]; then
        echo "端口重用配置处于【 关闭 】状态."
    else
        echo "端口重用配置处于【 开启 】状态."
    fi
    echo "查看端口回收是否开启:"
    flag=`cat /etc/sysctl.conf | grep "^net.ipv4.tcp_tw_recycle" | awk '{print $3}'`
    if [[ "x${flag}" != "x1" ]]; then
        echo "端口回收配置处于【 关闭 】状态."
    else
        echo "端口回收配置处于【 开启 】状态."
    fi
    echo "查看端口回收是否开启:"
    flag=`cat /etc/sysctl.conf | grep "^net.ipv4.tcp_tw_timestamps" | awk '{print $3}'`
    if [[ "x${flag}" != "x1" ]]; then
        echo "TCP时间戳配置处于【 关闭 】状态."
    else
        echo "TCP时间戳配置处于【 开启 】状态."
    fi
    echo ""
    echo "注意，以上配置是在 /etc/sysctl.conf 中读取的，若没有执行过 sysctl -p ,"
    echo "或者执行上述命令后报错，提示未知的键，则结果未必准确！"
}

############ main begin ###########################
_main
############# main end #############################
