#!/bin/bash
###################################################################################################
# esayops public tools
# file_ver: 1.0.0
# 查看文件内容 文件后1000行
#
# create by Turing Chu, 2016-07-14 11:23:46
# Copyright 2016 Turing Chu
# 本工具版权信息归作者所有，未经授权不可用于平台外的其它商业用途。
#
# Input variables: path
# Output variables:
#
# Usage: path指定文件路径
#
###################################################################################################

function _main() {
    local path=$1
    if [ -z "$path" ];then
        printf "[ ERROR 1 ] 缺少参数: path 不能为空\n"
        exit 1
    elif [ -d "$path" ];then
        printf "[ ERROR 2 ] 指定参数path为文件夹, 请提供文件路径参数\n"
        exit 2
    elif [ ! -f "$path" ];then
        printf "[ ERROR 3 ] 指定文件不存在: ${path}"
        exit 3
    elif [ -f "$path" ];then
        tail -n 1000 $path
    fi
}
########### main begin ##########
path=$1
_main $path
########## main end #############
