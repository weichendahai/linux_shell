#!/bin/bash

###################################################################################################
# esayops public tools
# file_ver: 1.0.0
# 磁盘使用率
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
echo "磁盘使用率及挂载项："
df -ahP
num=0
for d in `df -ahP | awk '$5 != "-" {print $5}'| sed 's/%//g'`
do
    if [[ "${d}" -gt 80 ]];then
        let num++
    fi
done

echo ""
if [[ "${num}" -gt 0 ]]; then
    echo "有挂载磁盘的使用率超过80%，请检查磁盘！"
else
    echo "磁盘使用状况良好"
fi
