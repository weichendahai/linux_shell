#!/usr/bin/python
# encoding:utf-8

#########################################################################
# easyops public tools
# file_ver: 1.0.0
# create by Neven, 2016-7-18
# Copyright 2016 Neven Liang
# 本工具版权信息归作者所有，未经授权不可用于平台外的其它商业用途。
#
# Input variables:
#
# Output variables:
#
# Usage: 查看网络的配置信息（优先显示ip route和ip addr的结果，其次才是route、ifconfig)
#########################################################################

import subprocess
import re


def output_selection():
    retcode = subprocess.call("which ip > /dev/null 2>&1", shell=True)
    if retcode != 0:
        print_route_info()
        print_ifconfig_info()
    else:
        print_ip_route()
        print_ip_addr()    

def print_route_info():
    #获取路由表信息  
    print '路由表：（第一行的网关地址为当前默认网关）\n'
    subprocess.call("route -n | sed '1 d' | sed 's/Destination/ 目的地址/g'  \
                   | sed 's/Gateway/网关地址/g' | sed 's/Genmask/掩码地址/g'  \
                   | sed 's/Iface/接口名/g' | sed 's/Flags/路由标志/g'  \
                   | sed 's/Metric/跃点数/g' | sed 's/Use/路由查找次数/g' \
                   | awk '{print $1,$2,$3,$4,$5,$7,$8}' | column -t", shell=True)

def print_ip_route():
    print '路由表：（第一行的IP地址为当前默认网关）\n'
    subprocess.call("ip route", shell=True)
        
    
def print_ifconfig_info():
    #获取接口名列表
    print '\n\n接口信息：\n'
    interface_str = subprocess.check_output("ifconfig | cut -d ' ' -f1 | sed '/^$/d'", shell=True)
    interface_list = interface_str.split()
    interface_num = len(interface_list)
    
    #获取接口详细信息
    info_translation = subprocess.check_output("ifconfig | cut -c 11- | grep -A 2 'Link encap' \
                                               | sed 's/inet addr/IP地址/g' | sed 's/Bcast/广播地址/g' \
                                               | sed 's/Mask/掩码地址/g' | sed 's/Link encap/接口类型/g' \
                                               | sed 's/HWaddr/MAC地址:/g' | sed 's/inet6 addr/IPv6地址/g' \
                                               | sed 's/Scope/接口IP地址作用范围/g'", shell=True)
    info_list = info_translation.split('--')
    
    #输出接口信息
    i = 0
    for i in range(interface_num):
        print interface_list[i]
        regsub = re.sub('^\n', '', info_list[i])
        i += 1
        print regsub          

def print_ip_addr():
    print '\n接口信息：\n'
    ip_addr_result_str = subprocess.check_output("ip addr ", shell=True)
    ip_addr_result_list = ip_addr_result_str.split('\n')

    iface_name=[]
    index = []
    #找出接口名的位置
    for row in ip_addr_result_list:
        match = re.search('<.*>', row)
        if match:
            index.append(ip_addr_result_list.index(row))
            iface_name.append(row.split(': ')[1])
    #截取ip addr前面的空格并翻译
    ip_addr_info_str = subprocess.check_output("ip addr | cut -c 5- | sed 's/^link/接口类型(MAC地址)/g' \
                                                 | sed 's/brd / 广播地址 /g' | sed 's/inet6 /Ipv6地址 /g'\
                                                 | sed 's/inet /IP地址 /g' | sed 's/scope / 范围 /g'", shell=True)
    ip_addr_info_list = ip_addr_info_str.split('\n')
    #找出匹配的行号
    mac_row = []
    ip_row = []
    ipv6_row = []
    for row in ip_addr_info_list:
        match = re.search('接口类型', row)
        if match:
            mac_row.append(ip_addr_info_list.index(row))
        match = re.search('IP地址', row)
        if match:
            ip_row.append(ip_addr_info_list.index(row))
        match = re.search('Ipv6地址', row)
        if match:
            ipv6_row.append(ip_addr_info_list.index(row))

    #输出ip addr命令的信息
    for i in range(len(iface_name)):
        print iface_name[i]
        if i != len(index)-1:
            for a in range(len(mac_row)):
                if index[i] < mac_row[a] and index[i+1] > mac_row[a]:
                    print ip_addr_info_list[mac_row[a]]
            for b in range(len(ip_row)):
                if index[i] < ip_row[b] and index[i+1] > ip_row[b]:
                    print ip_addr_info_list[ip_row[b]]
            for c in range(len(mac_row)):
                if index[i] < ipv6_row[c] and index[i+1] > ipv6_row[c]:
                    print ip_addr_info_list[ipv6_row[c]]
        else:
            for a in range(len(mac_row)):
                if index[i] < mac_row[a]:
                    print ip_addr_info_list[mac_row[a]]
            for b in range(len(ip_row)):
                if index[i] < ip_row[b]:
                    print ip_addr_info_list[ip_row[b]]
            for c in range(len(mac_row)):
                if index[i] < ipv6_row[c]:
                    print ip_addr_info_list[ipv6_row[c]]
        print '\n'        
        
def main():
    output_selection()
    
########## main begin ##########
if __name__ == '__main__':
    main()
########### main end ###########
