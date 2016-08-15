#!/bin/bash
###################################################################################################
# esayops public tools
# file_ver: 1.0.0
# 查看进程数最多的10个进程
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

_top10Proc()
{
    echo "进程数最多的10个进程："
    ps axww | grep -v "\[" | awk '{print $5, $6, $7, $8}' | uniq -c | sort -nr | head
}


########### main begin ############
_top10Proc
########### main end ##############
