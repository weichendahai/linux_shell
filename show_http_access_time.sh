#!/bin/bash

###################################################################################################
# esayops public tools
# file_ver: 1.0.0
# 统计访问域名花费的时间
#
# create by Nano, 2016-7-1
# Copyright 2016 Nano Guo
# 本工具版权信息归作者所有，未经授权不可用于平台外的其它商业用途。
#
# Input variables:
#     domain_name: 参数为域名 例如  www.easyops.cn 或者 https://console.easyops.cn
# Output variables:
#
# Usage:
#
###################################################################################################

_help()
{
    echo "【参数说明】domain_name: 参数为域名 例如 www.easyops.cn 或者 https://console.easyops.cn"
}

_checkEnv()
{
    which curl > /dev/null 2>&1
    if [[ $? -eq 0 ]];then
        if [[ `curl -V | head -n 1 | awk '{print $2}' | awk -F "." '{print$1}'` -ge 7 ]]  && [[ `curl -V | head -n 1 | awk '{print $2}' | awk -F "." '{print$2}'` -ge 19 ]];then
            echo "HTTP访问时间探测..."
        else
            echo "curl 版本太低，请更新到7.19以上" && exit 1
        fi
    else
        echo "curl 命令不可用，请检查." && exit 1
    fi
}
_checkPara()
{
    if [[ -z "${domain_name}" ]]; then
        echo "请输入URL"
        _help && exit 1
    fi
}
_curl()
{
    curl -m 10 -w  "     DNS 解析时间：%{time_namelookup} 秒，\n \
    SSL 握手耗时: %{time_appconnect} 秒,\n \
    TCP 握手耗时: %{time_connect} 秒,\n \
    服务器首包时间：%{time_starttransfer} 秒，\n \
    下载速度：%{speed_download} 字节/秒，\n \
    请求总时间：%{time_total} 秒. \n" ${domain_name} -so /dev/null 2>/tmp/http_error.log
    
    if [[ $? -ne 0 ]];then
        echo ""
        printf "参数错误！"
        cat /tmp/http_error.log | head -n 1 | awk -F ":" '{print $2}'
        echo ""
        if [[ -f /tmp/http_error.log ]]; then
            rm -rf /tmp/http_error.log
        fi
        _help && exit 1
    fi
}

########### main start ##########
domain_name=$1
_checkPara
_checkEnv
_curl
########### main end ############
