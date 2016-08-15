#!/bin/bash

###################################################################################################
# esayops public tools
# file_ver: 1.0.0
# 同步机器时间
#
# create by Turing Chu, 2016-07-06 12:06:11
# Copyright 2016 Turing Chu
# 本工具版权信息归作者所有，未经授权不可用于平台外的其它商业用途。
#
# Input variables: 
#        ntpServer: ntp服务器，非必填，若不填则为默认值
# # Output variables:
#
# Usage: ntpServer指定ntp服务器 默认为pool.ntp.org
#
###################################################################################################

_syncTime() {
    local ntpServer="$1"
    which ntpdate >> /dev/null 2>&1
    if [ $? -ne 0 ];then
        printf "[ Error ] 未找到ntpdate命令, 请先安装ntpdate\n"
        exit 1
    fi

    if [ "${ntpServer}X" = "X" ];then
        ntpServer="pool.ntp.org"
        printf "[ Warning ] 未提供ntp服务器, 使用${ntpServer} 作为默认ntp服务器\n"

    fi

    ping -c4 ${ntpServer} >/dev/null 2>&1
    if [ $? -ne 0 ];then
        printf "[ Error ] 连接ntp服务器 ${ntpServer} 失败!\n"
        exit 2
    fi

    ntpdate -t 5 ${ntpServer} >> /dev/null 2>&1
    if [ $? -ne 0 ];then
        printf "[ Error ] 没有合适ntp服务器可用或同步失败\n"
        exit 3
    fi
}

########## main begin ##########
_syncTime "${ntpServer}"
########## main end #############
