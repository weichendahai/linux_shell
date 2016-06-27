#!/bin/bash

#项目git url
repository='http://172.16.10.196:8360/liuliwei/test.git'

#项目名称，项目路径
#project_name='gaea'
project_name='tscript'

#git 版本号码
#sha='f706ae635dc832559311ea163411b28d4cabf417'
sha='1a4e9f10dd7c2dd8d7eb23ef52553ebf305758e1'

#版本归档tar文件名称(项目名称_sha截取前8位.tar)
release_archive_name="${project_name}_${sha:0:8}.tar"

#本次运行Id(创建远程保存目录使用)
ci_build_id='20160906194813185'

#项目自定义构建脚本字符串
#build_project_script="echo '111111'>${release_path}/success.md"
build_project_script=`cat <<'EOF'

EOF`

#项目发布到生产服务器后，执行命令
#deploy_after_script="echo 'deployed success'>./success.md"
deploy_after_script=`cat <<'EOF'

EOF`

#项目文件黑名单,打包时，不包涵设置文件
#deploy_black_files=''
deploy_black_files=''

#项目大包目录(使用编译型项目java)设置参数，讲忽略黑名单文件
#deploy_files='*'
deploy_files='*'

#fix:params(暂时没有定义，后续优化)
#Install apt addons
#before_install
#install
#before_script
#script
#after_success or after_failure
#OPTIONAL before_deploy
#OPTIONAL deploy
#OPTIONAL after_deploy
#after_script


function setMsg() {
    run_result=$?
    msg=$1
    if [ "$run_result" -eq 0 ];then
        #echo $msg' 完成'
        echo -e "$msg 完成"
    else
        echo -e "ERR!!!!  $msg 失败"
        exit 123
    fi
}

#ci工作空间目录
#workspace='/home/liuliwei/ci_workspace'
workspace='/data/ci_workspaces'
if [ ! -d $workspace ]; then
    mkdir -p $workspace
fi

#文件目录分隔符
sep='/'

#项目名称，项目路径
#project_name='gaea'
#project_name='tscript'
project_path="${workspace}/${project_name}"

#项目仓库镜像路径(mirror_项目名称)
mirror_dir_name="mirror_${project_name}"
mirror_path="${project_path}/${mirror_dir_name}"

#项目release路径(release_项目名称_sha截取前8位)
release_dir_name="release_${project_name}_${sha:0:8}"
release_path="${project_path}/${release_dir_name}"

if [ ! -d $project_path ]; then
    mkdir -p $project_path
fi

if [ ! -d $mirror_path ]; then
    mkdir -p $mirror_path
fi

if [ ! -d $release_path ]; then
    mkdir -p $release_path
fi

#git 版本本
echo `git --version`

echo $repository
#更新镜像仓库(注入更新成功文件gaea_init.md)
if [ ! -d $mirror_path ]; then
    git clone --mirror $repository $mirror_path
    setMsg '克隆项目'
    #echo "git clone --mirror $repository $mirror_path"
    echo 'init mirror success'>"${mirror_path}/gaea_init.md"
else
    if [ ! -f "${mirror_path}/gaea_init.md" ]; then
        git clone --mirror $repository $mirror_path
        setMsg '克隆项目'
        #echo "git clone --mirror $repository $mirror_path"
        echo 'init mirror success'> "${mirror_path}/gaea_init.md"
    fi
fi

cd $mirror_path
git fetch --all --prune
setMsg '更新项目'

ci_gaea_target_dir='ci_gaea_target'
save_diff_dir='diff_log'
if [ ! -d $ci_gaea_target_dir ]; then
    mkdir $ci_gaea_target_dir
fi

#查看某个版本的提交信息
git log $sha -n1 --pretty=format:"%H %x09 %an %x09 %ae %x09 %s" > "./${ci_gaea_target_dir}/change.log"
echo `git log $sha -n1 --pretty=format:"%H%x09%an%x09%ae%x09%s"`

#查看距离当前版本，上一个版本版本号
pre_sha=`git rev-list $sha |  sed -n '2p'`

#打包diff文件
#git diff $sha $pre_sha --name-only | xargs tar -zcvf update.tar.gz
#git diff $pre_sha $sha --name-only > "./${ci_gaea_target_dir}/change_file_list.log"
#git diff $pre_sha $sha > "./${ci_gaea_target_dir}/change_content.log"

diff_files=`git diff $pre_sha $sha --name-only`
echo "git diff $pre_sha $sha --name-only"
echo $diff_files
echo "$diff_files" > "./${ci_gaea_target_dir}/diff_files_list.log"

for file in $diff_files
do
    file_name=`basename $file`
    file_dir=`dirname  $file`
    if [ ! -d "$ci_gaea_target_dir/$save_diff_dir/$file_dir"  ]; then
        mkdir -p $ci_gaea_target_dir/$save_diff_dir/$file_dir
    fi
    file_diff_content=`git diff $pre_sha $sha -- $file`
    #echo "git diff $pre_sha $sha $file"
    echo "$file_diff_content" > $ci_gaea_target_dir/$save_diff_dir/$file_dir/$file_name
done

cd $ci_gaea_target_dir
tar -zcf 'diff_log.tar.gz' $save_diff_dir
md5sum 'diff_log.tar.gz' >diff_log_md5.md
#echo "tar -zcf 'diff_log.tar.gz' $save_diff_dir"
rm -rf $save_diff_dir

#根据git 版本号 打包源代码(归档压缩包)
cd $mirror_path
#(git archive --format=tar $sha | gzip > $release_archive_name)
git archive $sha --format=tar > $release_archive_name
setMsg '归档项目源码'

#将此次ci收集git信息归档进 源码包
tar -rf $release_archive_name $ci_gaea_target_dir

rm -rf $ci_gaea_target_dir

# 创建release_path路径
cd $project_path
if [ ! -d $release_path ]; then
    mkdir -p $release_path
fi

# 解压归档源代码
cd $release_path

#echo -e "Extracting...\n"
remote_archive="${mirror_path}/${release_archive_name}"
#tar --warning=no-timestamp --gunzip --verbose --extract --file=$remote_archive --directory=$release_path >> /dev/null 2>&1
tar --warning=no-timestamp --verbose --extract --file=$remote_archive --directory=$release_path >> /dev/null 2>&1
setMsg '解压项目源码'
rm -f $remote_archive

#执行项目构建脚本
cd $release_path

#注:此处echo 需加 “”；不分行命令
build_sh_name='build_pro.sh'
echo -e "$build_project_script" > $build_sh_name
#build_log=`sh ./$build_sh_name 2>&1`
echo '执行构建脚本 开始'
build_log=$(sh $build_sh_name 2>&1)
setMsg "\n${build_log}\n\n执行构建脚本"

#注:此处echo 需加 “”；不分行命令
#将部署后执行脚本斜入ci_deploy_after.sh,随源码打包
project_deployed_sh_name='ci_deploy_after.sh'
echo "$deploy_after_script" > $project_deployed_sh_name

#打包可执行程序(去除部署黑名单文件);全部文件或是指定一个特定目录;
release_pack_name="${project_name}.tar.gz"
#tar -zcvf $release_pack_name $deploy_black_files --exclude=$release_pack_name --exclude=.git `ls -A` >> /dev/null 2>&1
if [ "$deploy_files"x == "*x" ]; then
    #打包所有包涵隐藏文件
    tar -zcvf $release_pack_name $deploy_black_files --exclude=$release_pack_name --exclude=.git `ls -A` >> /dev/null 2>&1
    setMsg '打包构建程序'
else
    #打包指定文件
    tar -zcvf $release_pack_name $deploy_black_files --exclude=$release_pack_name --exclude=.git $deploy_files $project_deployed_sh_name >> /dev/null 2>&1
    setMsg '打包构建程序'
fi

remote_package_repository='/data/download/download/gaea/packages/production'
if [ ! -d $remote_package_repository  ]; then mkdir -p $remote_package_repository; fi;
cd ${remote_package_repository}; mkdir -p ./${project_name}/${ci_build_id}_${sha:0:8};
setMsg '创建保存目录'

remove_pack_path="${remote_package_repository}/${project_name}/${ci_build_id}_${sha:0:8}"
cp ${release_path}/${release_pack_name} ${remove_pack_path}
setMsg '上传程序至文件服务器'
cp ${release_path}/${ci_gaea_target_dir}/* ${remove_pack_path}
setMsg '上传程序至文件服务器'

echo -e "\n项目构建成功；请及时发布\n"
exit 0


##拷贝可执行程序至文件服务器
#cd $project_path
#cp ${release_path}/${release_pack_name} $release_pack_name

#拷贝可执行程序至文件服务器(需建立免密登录)
cd $project_path

private_key='ssh_key.md'
port='22'
username='liuliwei'
ip_address='172.16.10.10'

#/data/download/download/gaea/packages/test
remote_package_repository='/data/download/download/gaea/packages/test'
script_cmd1="if [ ! -d $remote_package_repository ]; then mkdir -p $remote_package_repository; fi; "
script_cmd2="cd ${remote_package_repository}; mkdir -p ./${project_name}/${ci_build_id}_${sha:0:8}; "
script_cmd="${script_cmd1}${script_cmd2}"

remove_pack_path="${remote_package_repository}/${project_name}/${ci_build_id}_${sha:0:8}"
ssh -p ${port} ${username}@${ip_address} ${script_cmd}
setMsg '远程创建保存目录'

#ssh -p ${port} ${username}@${ip_address} 'bash -s' << 'EOF'
    ## Turn on quit on non-zero exit
    #set -e
    #{{ remote_package_repository_script }}
#EOF

scp ${release_path}/${release_pack_name} ${username}@${ip_address}:${remove_pack_path}
setMsg '上传程序至文件服务器'
scp ${release_path}/${ci_gaea_target_dir}/* ${username}@${ip_address}:${remove_pack_path}
setMsg '上传程序至文件服务器'

#echo "${release_path}/${release_pack_name} ${username}@${ip_address}:${remove_pack_path}"
#echo "${release_path}/${ci_gaea_target_dir}/* ${username}@${ip_address}:${remove_pack_path}"
#ssh -p ${port} ${username}@${ip_address} ${script_cmd}

#清理release路径
#rm -rf $release_path
echo -e "\n项目构建成功；请及时发布\n"
exit 0
