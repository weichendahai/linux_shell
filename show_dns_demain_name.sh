#########################################################################
# easyops public tools
# file_ver: 1.0.0
# create by Neven, 2016-7-13
# Copyright 2016 Neven Liang
# 本工具版权信息归作者所有，未经授权不可用于平台外的其它商业用途。
#
# Input variables:
#   website：合法且存在的域名，不带http://或https://(例如：www.baidu.com)
#
# Output variables:
#
# Usage: 可得到输入域名的DNS解释结果，且得到目前本地使用的DNS的IP地址，以及dns解析时间
#########################################################################

#查看是否有dig命令
function dig_check(){
    which dig > /dev/null 2>&1
    retcode=$?
    if [ "${retcode}" -ne 0 ] ;then
        echo "目标机器没有安装dig命令，请参照以下命令安装（注意权限）"
        echo -e "Ubuntu: \n# sudo apt-get install dnsutils\n"
        echo -e "Debian: \n# apt-get update \n# apt-get install dnsutils\n"
        echo -e "Fedora / Centos: \n# yum install bind-utils\n"
        exit 1
    fi
}

#优化输出函数
function output(){
    dig "${website}" 1> /tmp/dig.txt
    retcode=$?
    if [ "${retcode}" -eq 0 ]; then
        #获取dns解析的结果数目
        answer_num=`cat /tmp/dig.txt | awk -F "ANSWER: " '{print $2}' | awk -F ',' '{print $1}'`
        #查询失败
        if [[ "${answer_num}" -eq "0" ]]; then
            echo '查询不到所输入的域名，请检查域名输入是否正确!'
            exit 1
        fi
        #正常输出
        echo '域名                 TTL（缓存时间）      记录类型     记录结果'
        cat /tmp/dig.txt | grep -A "${answer_num}" 'ANSWER SECTION:' | sed "1 d"
        echo -e "\n"
        cat /tmp/dig.txt | grep -A 1 ';; Query time' | sed "s/^;; Query time/查询时间/g" | sed "s/msec$/毫秒/g" | sed "s/^;; SERVER/本地DNS地址/g"   
    fi
}

#删除执行dig命令时结果输出的文件
function delete_dig_file(){
    cd /tmp
    rm -f dig.txt
}

########## main begin ##########
website=$1
dig_check
output
delete_dig_file
########### main end ###########
