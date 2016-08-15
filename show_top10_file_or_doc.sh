###################################################################################################
# esayops public tools
# file_ver: 1.0.0
# 查找指定目录下的最大文件或者目录
#
# create by Turing Chu, 2016-07-06 12:06:11
# Copyright 2016 Turing Chu
# 本工具版权信息归作者所有，未经授权不可用于平台外的其它商业用途。
#
# Input variables: 
#           path ：目录（路径）
# Output variables:
#
# Usage: path指定目录路径 默认为根目录 /
#
###################################################################################################

function _main() {
    # 参数 提取
    local path=$1
    if [ -z "${path}" ];then
        printf "[ Warning ] 未提供参数path, 将使用默认参数 path=/\n"
        local path='/'
    elif [ -f $path ];then
        du -sh $path
        exit 0
    fi

    # 处理path最后的/
    if [ "$(echo ${path:((${#path} - 1))})" = "/" ];then
        local slash=""
    else
        local slash="/"
    fi

    if [ -d $path ];then
        local original_files=$(ls -A $path)
        local files=""
        for file in $original_files;do
            du -s "${path}${slash}${file}" >>/dev/null 2>&1
            if [ $? -eq 0 ];then
                local files="$files ${path}${slash}${file}"
            fi
        done
        local max_files=$(du -s $files | sort -rn | head -10| awk '{print $2}')
        du -sh $max_files
    else
        printf "[ Error ] 指定路径不存在: ${path}\n"
        exit 2
    fi
}

########## main begin ##########
path=$1
_main $path
########## main end #############
