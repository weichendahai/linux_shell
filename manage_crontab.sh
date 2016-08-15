#!/bin/bash

###################################################################################################
# esayops public tools
# file_ver: 1.0.0
# 增删改查 crontab
#
# create by Nano, 2016-7-1
# Copyright 2016 Nano Guo
# 本工具版权信息归作者所有，未经授权不可用于平台外的其它商业用途。
#
# Input variables:
#     crontab_comm : 一条完整的crontab规则，若含有双引号，需要转义， 示例 * * * * * date >> /tmp/date.log
#                 【注意】若不填则默认为查看当前用户的crontab，而且第二个参数也不需要填写。
#     option : 增删改操作，必填，具体操作参数如下：
#     [a|A|add|ADD]                 添加crontab
#     [d|D|delete|DELETE]           删除crontab
#     [c|C|comment|COMMENT]         注释crontab
#     [u|U|uncomment|UNCOMMENT]     解注释crontab
#     注意，解注释crontab时输入参数需要带上注释符'#'
#
# Output variables:
#
# Usage:
#
###################################################################################################

_help()
{
    echo "---------------------------------------------------------------------------------------------"
    echo "参数格式："
    echo "crontab_comm : 一条完整合法的crontab规则，若包含双引号，则需要转义， 示例 * * * * * date >> /tmp/date.log"
    echo "        【注意】若不填则默认为查看当前用户的crontab，而且第二个参数也不需要填写。"
    echo "option : 增删改操作，必填，具体操作参数"
    echo "      [a|A|add|ADD]               添加crontab"
    echo "      [d|D|delete|DELETE]         删除crontab"
    echo "      [c|C|comment|COMMENT]       注释crontab"
    echo "      [u|U|uncomment|UNCOMMENT]   解注释crontab"
    echo "注意，解注释crontab时输入参数需要带上注释符'#'"
    echo "---------------------------------------------------------------------------------------------"
    echo ""
}

_checkPara()
{
    if [[ "x${crontab_comm}" == "x" ]]; then
        _help
        echo "你选择了【查看】crontab！"
        _crontabList && exit 0
    fi
    if [[ "x${option}" == "x" ]]; then
        _help
        echo "你选择了【查看】crontab！"
        _crontabList && exit 0
    fi

    re="`echo "${crontab_comm}" | sed -e "s:*:\\\\\\*:g"`"
}

_backup()
{
    user=`whoami`
    if [[ ! -d /data/backup/cron.bk ]]; then
        mkdir -p /data/backup/cron.bk
    fi
    crontab -l > /data/backup/cron.bk/${user}.`date +%Y%m%d-%H%M%S`
    filename=`ls -lrt /data/backup/cron.bk/ | tail -n 1 | awk '{print $NF}'`
    if [[ $? -ne 0 ]]; then
        echo "crontab 文件备份失败！已退出！" && exit 1
    else
        echo "crontab 备份文件 ${filename} 在 /data/backup/cron.bk 目录下"
    fi
}

_rollback()
{
    if [[ -f /data/backup/cron.bk/${filename} ]]; then
        echo "检查备份文件..."
        cat /data/backup/cron.bk/${filename} | crontab - > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo "文件回滚失败！！！" && exit 255
        else
            echo "crontab 文件已经回滚为 ${filename}"
        fi
    else
        echo "备份文件不存在！" && exit 1
    fi
}

_crontabList()
{
    echo ""
    echo "当前用户的 crontab 列表:"
    crontab -l
}

_addCrontab()
{
    crontab -l > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        crontab -l | grep "^${re}$" > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            oldCrontabList=`crontab -l`
            newCrontabList=`echo "${oldCrontabList}"; echo "${crontab_comm}"`
            echo "${newCrontabList}" | crontab -
            if [[ $? -eq 0 ]]; then
                echo "crontab ""${crontab_comm} 添加成功！"
            else
                echo "crontab 添加失败！"
                _rollback && exit 1
            fi
        else
            echo "此crontab存在，请检查是否要修改！" && exit 2
        fi
    else
        echo "读取crontab失败！" && exit 3
    fi
}

_deleteCrontab()
{
    crontab -l > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        crontab -l | grep "^${re}$" > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo "要删除的 crontab: ""${crontab_comm} 不存在！" && exit 1
        else
            oldCrontabList=`crontab -l`
            newCrontabList=`echo "${oldCrontabList}" | grep -v "^${re}$"`
            echo "${newCrontabList}" | crontab -
            if [[ $? -eq 0 ]]; then
                echo "crontab ""${crontab_comm} 删除成功！"
            else
                echo "crontab 删除失败！"
                _rollback && exit 1
            fi
        fi
    else
        echo "读取crontab失败！" && exit 3
    fi
}

_commCrontab()
{
    crontab -l > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        crontab -l | grep "^${re}$" > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo "要注释的 crontab: ""${crontab_comm} 不存在！" && exit 1
        else
            oldCrontabList=`crontab -l | grep -v "^${re}$"`
            newCrontabList=`echo "${oldCrontabList}"; echo "#${crontab_comm}"`
            echo "${newCrontabList}" | crontab -
            if [[ $? -eq 0 ]]; then
                echo "crontab ""${crontab_comm} 注释成功！"
            else
                echo "crontab 注释失败！"
                _rollback && exit 1
            fi
        fi
    else
        echo "读取crontab失败！" && exit 3
    fi
}

_uncommCrontab()
{
    crontab -l > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        crontab -l | grep "^${re}$" > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo "要解注释的 crontab: ""${crontab_comm} 不存在！" && exit 1
        else
            oldCrontabList=`crontab -l | grep -v "^${re}$"`
            newCrontabList=`echo "${oldCrontabList}"; echo "${crontab_comm}" | sed "s/^#//g"`
            echo "${newCrontabList}" | crontab -
            if [[ $? -eq 0 ]]; then
                echo "crontab ""${crontab_comm} 解注释成功！"
            else
                echo "crontab 解注释失败！"
                _rollback && exit 1
            fi
        fi
    else
        echo "读取crontab失败！" && exit 3
    fi
}

_option()
{
    if [[ "${option}" == "add" ]] || [[ "${option}" == "a" ]] || [[ "${option}" == "A" ]] || [[ "${option}" == "ADD" ]]; then
        echo "你选择了【添加】 crontab."
        _addCrontab
    else
        if [[ "${option}" == "delete" ]] || [[ "${option}" == "d" ]] || [[ "${option}" == "D" ]] || [[ "${option}" == "DELETE" ]]; then
            echo "你选择了【删除】 crontab."
            _deleteCrontab
        else
            if  [[ "${option}" == "comment" ]] || [[ "${option}" == "c" ]] || [[ "${option}" == "C" ]] || [[ "${option}" == "COMMENT" ]]; then
                echo "你选择了【注释】 crontab."
                _commCrontab
            else
                if  [[ "${option}" == "uncomment" ]] || [[ "${option}" == "u" ]] || [[ "${option}" == "U" ]] || [[ "${option}" == "UNCOMMENT" ]]; then
                    echo "你选择了【解注释】 crontab."
                    _uncommCrontab
                else
                    echo "你做出了无效的选择！"
                    _help && exit 1
                fi
            fi
        fi
    fi
}

######### main begin ############
_checkPara
_backup
_option
_crontabList
######### main end ##############
