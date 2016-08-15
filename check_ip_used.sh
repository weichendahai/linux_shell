#!/bin/bash

###################################################################################################
# esayops public tools
# file_ver: 1.0.0
# 扫描网段内已占用IP
#
# create by Nano, 2016-6-30
# Copyright 2016 Nano Guo
# 本工具版权信息归作者所有，未经授权不可用于平台外的其它商业用途。
#
# Input variables:
#     ip_section: 网段范围，参数格式如 192.168.100.20-50
# Output variables:
#
# Usage:
#
###################################################################################################

_help()
{
    echo "------------------------------------------------------"
    echo "参数格式：192.168.100.20-50"
    echo "检查 192.168.100.20 到192.168.100.50 之间的IP使用情况"
    echo "仅支持最后一个数字变化"
    echo "------------------------------------------------------"
}
# 检查系统环境
_checkEnv()
{
    which nmap > /dev/null 2>&1
    if [[ $? -ne 0 ]];then
        echo "没有找到 nmap 命令，尝试使用ping检查"
        comm="_ping"
    else
        comm="_nmap" && return
    fi
    which ping > /dev/null
    if [[ $? -ne 0 ]];then
        echo "没有找到 ping 命令" && exit 1
    fi
}

# 参数合法性检查
_checkPara()
{
    if [[ ${ip_section} =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\-(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]];then
        start=`echo ${ip_section} | awk -F "." '{print $4}' | awk -F "-" '{print $1}'`
        end=`echo ${ip_section} | awk -F "." '{print $4}' | awk -F "-" '{print $2}'`
        num=`expr ${end} - ${start} + 1`
        if [[ $(echo ${start}/1|bc) == "${start}" ]] && [[ ${start} -ge 0 ]] && [[ ${start} -le 255 ]];then
            if [[ $(echo ${end}/1|bc) == "${end}" ]] && [[ ${end} -ge 0 ]] && [[ ${end} -le 255 ]] && [[ ${start} -le ${end} ]];then
                echo "开始检查网段IP是否已经分配..."
            else
                echo "结束IP不合法！请检查！"
                _help && exit 1
            fi
        else
            echo "开始IP不合法！请检查！"
            _help && exit 1
        fi
    else
        echo "网段不合法！请检查"
        _help && exit 1
    fi
}

# 检查IP是否被分配
_nmap()
{
    nmap -nsP ${ip_section} | grep "Nmap" | grep -v "nmap" | grep -v "address" | awk '{print $5}'
    used=`nmap -nsP ${ip_section} | grep "Nmap" | grep -v "nmap" | grep -v "address" | awk '{print $5}' | wc -l`
    echo "以上IP已经被使用，网段内共 ${num} 个IP，已经被占用 ${used} 个"
}

_ping()
{
    net=`echo ${ip_section} | awk -F "-" '{print $1}' | awk -F "." '{print $1"."$2"."$3}'`
    used=0
    for sitenu in $(seq ${start} ${end})
    do
        ping -c 1 -w 1 ${net}.${sitenu} &> /dev/null && result=0 || result=1
        if [ "${result}" -eq 0 ]; then
            echo "${net}.${sitenu}"
            let used++
        fi
    done
    echo "检查已经完成，仅显示已分配IP。"
    echo "以上IP已经被使用，网段内共 ${num} 个IP，已经被占用 ${used} 个"
    echo "注意：ping的结果并不保证准确，机器设置禁止ping时不会列在这里，推荐使用nmap"
}

_timeout()
{
    waitsec=300
    ( $* ) & pid=$!
    ( sleep $waitsec && kill -HUP $pid ) 2>/dev/null & watchdog=$!
    if wait $pid 2>/dev/null; then
        pkill -HUP -P $watchdog
        wait $watchdog
        if [[ $? -ne 0 ]]; then
            exit 0
        fi
    fi
    echo ""
    echo "工具未能在超时时间内执行完毕！" && exit 1

}

_checkNet()
{
   ${comm}
}
######### main begin ############
_checkPara
_checkEnv
_timeout _checkNet
######### main end ###############
