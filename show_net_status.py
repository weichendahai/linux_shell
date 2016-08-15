#!/usr/bin/python
# encoding:utf-8

#########################################################################
# easyops public tools
# file_ver: 1.0.0
# create by Neven, 2016-7-14
# Copyright 2016 Neven Liang
# 本工具版权信息归作者所有，未经授权不可用于平台外的其它商业用途。
#
# Input variables:
#	pingtime（ping操作的次数）: 整数；
#	host（ping的地址）: 域名或ip；
#   （以上两个参数需要同时填写，或者同时不填）
#
# Output variables:
#
# Usage: 查看当前网络ping的延时，丢包率以及本机的外网IP。
#
# example：
#    pingtime：5
#    host：www.baidu.com
#########################################################################

import sys
import re   
import subprocess
try:
    import requests
except(ImportError):
    print '缺少requests库，请执行sudo /usr/local/easyops/python/bin/pip install requests，安装requests库！'
    sys.exit(1)

#输入参数检查
def input_check():
    if len(ping_times) == 0 and len(host) != 0:
        print '请输入ping的次数，0<次数<11！'
        sys.exit(2)
    if len(ping_times) != 0 and len(host) == 0:
        print '请输入合理的域名或ip！'
        sys.exit(3)
    if  len(ping_times) != 0 and len(host) != 0:   
        if int(ping_times) > 10 or int(ping_times)< 1:
            print '请输入合理的次数，0<次数<11！'
            sys.exit(4)                                   

def ping():
    input_check()
    #ping百度
    print '~~~~~~~~~~~~~ping百度:(获取ping的延时与丢包率信息)~~~~~~~~~~~~~~~~~'
    subprocess.call('ping -c 5 www.baidu.com', shell=True)
    print '\n'
    if  len(ping_times) != 0 and len(host) != 0:  
        print '~~~~~~~~~~~~~~~~~~~~~~以下为输入得到的结果~~~~~~~~~~~~~~~~~~~~~~~~~~'
        subprocess.call(['ping', '-c', ping_times, host])
        print '\n'
    print '~~~~~~~~~~~~~~~~以下为主机的外网ip地址与运营商信息~~~~~~~~~~~~~~~~~~' 

def get_output_ip():
    url = 'http://ip.chinaz.com/getip.aspx'           
    result = requests.get(url)                        
    #将返回结果变成dict                                      
    match1 = re.sub('ip', "'本机外网ip:'", result.content)
    match2 = re.sub('address', "'ip所属地区:'", match1)   
    r = eval(match2)                                  
    #输出外网ip                                              
    for k, v in r.iteritems():                        
        print k, v     
   
def main():
    ping()
    get_output_ip()
    
########## main begin ##########
if __name__ == '__main__':
    main()
########### main end ###########
