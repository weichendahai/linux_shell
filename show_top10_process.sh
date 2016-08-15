#!/bin/bash

###################################################################################################
# esayops public tools
# file_ver: 0.0.1
# 分别查看占用系统CPU、内存、IO最高的10个进程
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

echo "CPU占用最高的10个进程："
ps axww -o user,pid,pcpu,pmem,start,time,comm | head -1
ps axww -o user,pid,pcpu,pmem,start,time,comm  | grep -v PID |  sort -nr -k 3 | head
echo
echo "内存占用最高的10个进程："
ps axww -o user,pid,pcpu,pmem,start,time,comm | head -1
ps axww -o user,pid,pcpu,pmem,start,time,comm  | grep -v PID |  sort -nr -k 4 | head
echo

echo "10秒内IO占用最高的进程："
which iotop > /dev/null 2>&1
if [ $? -eq 0 ];then
    iotop -obqtn 10 > /dev/null 2>&1
    if [ $? -eq 0 ];then
        iotop -obqtn 10
    else
        echo "iotop 不可用，请修复！"
    fi
else
    echo "查看进程IO需要iotop命令，请安装iotop命令！"
fi
