#!/bin/bash

###################################################################################################
# esayops public tools
# file_ver: 1.0.0
# 当前机器上的TCP连接统计
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
    which ss > /dev/null 2>&1
    if [[ $? -ne 0 ]];then
        echo "未找到 ss 命令，尝试使用 netstat 继续检测..."
        comm="netstat"
    else
        comm="ss"
    fi

    which netstat > /dev/null 2>&1
    if [[ $? -ne 0 ]];then
        echo "未找到 netstat 命令!" && exit 1
    fi
}

_default()
{
    if [[ "${comm}" == "ss" ]]; then
        echo "查看连接摘要:"
        ss -s
        echo "统计当前连接数:"
        ss -an | grep -v "State" | awk '{++S[$1]} END {for(a in S) print a, S[a]}'
        echo ""
        echo "当前连接数最多的10个进程："
        ss -tnp | grep -v "State" | awk '{print $6}' | awk -F '"' '{print $2}' | awk '{++S[$1]} END {for(a in S) print a, S[a]}' | sort -nr -k2 | head
        echo ""
    else
        echo "统计当前连接数:"
        netstat -tan  | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
        echo ""
        echo "当前连接数最多的10个进程："
        netstat -tnp | grep -v "Active" | grep -v "TIME_WAIT" | grep -v "State" | awk -F '/' '{print $NF}' | awk '{++S[$1]} END {for(a in S) print a, S[a]}' | sort -nr -k2 | head
        echo ""
    fi
}

########## main begin ##############
_checkEnv
_default
########## main end ################
