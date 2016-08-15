#!/bin/bash

###################################################################################################
# esayops public tools
# file_ver: 1.0.0
# 开启TCP端口快速回收与端口重用
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
    user=`whoami`
    if [[ "${user}" != "root" ]]; then
        echo "该配置仅允许 root 用户修改！" && exit 1
    fi
}

_backup()
{
    if [[ ! -d /data/backup/sysctl.conf.bk/ ]]; then
        mkdir -p /data/backup/sysctl.conf.bk/
    fi
    
    if [[ -e /etc/sysctl.conf ]]; then
        cp -f /etc/sysctl.conf /data/backup/sysctl.conf.bk/sysctl.conf.bk.`date +%Y%m%d-%H%M%S` > /dev/null 2>&1
        filename=`ls -lrt /data/backup/sysctl.conf.bk/ | tail -n 1 | awk '{print $NF}'`
        if [[ $? -ne 0 ]]; then
            echo "备份文件失败，已退出！" && exit 1
        else
            echo "文件已经备份为 /data/backup/sysctl.conf.bk/${filename} "
            echo ""
        fi
    else
        echo "文件 /etc/sysctl.conf 不存在，请检查！" && exit 1
    fi
}

_rollback()
{
    cp -f /data/backup/sysctl.conf.bk/${filename} /etc/sysctl.conf > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "回滚失败！！！" && exit 1
    else
        echo "文件已经回滚！"
    fi
}
_openReuse()
{
    cat /etc/sysctl.conf | grep "^net.ipv4.tcp_tw_reuse" > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        flag=`cat /etc/sysctl.conf | grep "^net.ipv4.tcp_tw_reuse" | awk '{print $3}'`
        if [[ "x${flag}" == "x1" ]]; then
            echo "端口重用已开启，无需修改！"
        else
            sed -i 's/^net.ipv4.tcp_tw_reuse\s=\s.*/net.ipv4.tcp_tw_reuse = 1/g' /etc/sysctl.conf
            confirm=`cat /etc/sysctl.conf | grep "^net.ipv4.tcp_tw_reuse" | awk '{print $3}'`
            if [[ "x${confirm}" == "x1" ]]; then
                echo "端口重用配置已经打开！"
            else
                echo "端口重用配置开启失败！"
                _rollback && exit 1
            fi
        fi
    else
        sed -i "$ a net.ipv4.tcp_tw_reuse = 1" /etc/sysctl.conf
        confirm=`cat /etc/sysctl.conf | grep "^net.ipv4.tcp_tw_reuse" | awk '{print $3}'`
        if [[ "x${confirm}" == "x1" ]]; then
            echo "端口重用配置已经打开！"
        else
            echo "端口重用配置开启失败！"
            _rollback && exit 1
        fi
    fi
}

_openRecycle()
{
    cat /etc/sysctl.conf | grep "^net.ipv4.tcp_tw_recycle" > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        flag=`cat /etc/sysctl.conf | grep "^net.ipv4.tcp_tw_recycle" | awk '{print $3}'`
        if [[ "x${flag}" == "x1" ]]; then
            echo "端口回收已开启，无需修改！"
        else
            sed -i 's/^net.ipv4.tcp_tw_recycle\s=\s.*/net.ipv4.tcp_tw_recycle = 1/g' /etc/sysctl.conf
            confirm=`cat /etc/sysctl.conf | grep "^net.ipv4.tcp_tw_recycle" | awk '{print $3}'`
            if [[ "x${confirm}" == "x1" ]]; then
                echo "端口回收配置已经打开！"
            else
                echo "端口回收配置开启失败！"
                _rollback && exit 1
            fi
        fi
    else
        sed -i " $ a net.ipv4.tcp_tw_recycle = 1" /etc/sysctl.conf
        confirm=`cat /etc/sysctl.conf | grep "^net.ipv4.tcp_tw_recycle" | awk '{print $3}'`
        if [[ "x${confirm}" == "x1" ]]; then
            echo "端口回收配置已经打开！"
        else
            echo "端口回收配置开启失败！"
            _rollback && exit 1
        fi
    fi
}

_openStamps()
{
    cat /etc/sysctl.conf | grep "^net.ipv4.tcp_tw_timestamps" > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        flag=`cat /etc/sysctl.conf | grep "^net.ipv4.tcp_tw_timestamps" | awk '{print $3}'`
        if [[ "x${flag}" == "x1" ]]; then
            echo "TCP时间戳已开启，无需修改！"
        else
            sed -i 's/^net.ipv4.tcp_tw_timestamps\s=\s.*/net.ipv4.tcp_tw_timestamps = 1/g' /etc/sysctl.conf
            confirm=`cat /etc/sysctl.conf | grep "^net.ipv4.tcp_tw_timestamps" | awk '{print $3}'`
            if [[ "x${confirm}" == "x1" ]]; then
                echo "TCP时间戳配置已经打开！"
            else
                echo "TCP时间戳配置开启失败！"
                _rollback && exit 1
            fi
        fi
    else
        sed -i "$ a net.ipv4.tcp_tw_timestamps = 1" /etc/sysctl.conf
        confirm=`cat /etc/sysctl.conf | grep "^net.ipv4.tcp_tw_timestamps" | awk '{print $3}'`
        if [[ "x${confirm}" == "x1" ]]; then
            echo "TCP时间戳配置已经打开！"
        else
            echo "TCP时间戳配置开启失败！"
            _rollback && exit 1
        fi
    fi
}

_openConfig()
{
    _openReuse
    _openRecycle
    _openStamps
    ret=`sysctl -p 2>/dev/null`
    if [[ $? -ne 0 ]]; then
        echo "修改配置失败！机器不支持修改此配置！"
        _rollback && exit 255
    else
        echo "所有修改已经生效！"
        echo "${ret}"
    fi

}
############################## main begin ###################################
_checkEnv
_backup
_openConfig
############################# main end ######################################
