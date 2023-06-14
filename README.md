# 使用方法

原作者的示范视频.<br>
[![tr_st](http://img.youtube.com/vi/e9I-5srNfNY/0.jpg)](https://youtu.be/e9I-5srNfNY) 

![image](https://user-images.githubusercontent.com/42568682/218249473-f8fe1241-49dd-482c-a0fa-4d673fcfd754.png)

** NAS上下载补丁 **

1. 使用DSM的管理员账户登录SSH到NAS. (DSM > 控制面板 > 终端机和SNMP > 终端机 > 启用 SSH 功能)

2. 切换到root:

   > sudo su -
   
   (输入SSH的管理员密码)

3. 使用 Wget 下载补丁

   > wget https://github.com/WenqiOfficial/ch_cpuinfo_zh/releases/download/v4.2.1-r01-zhv2/ch_cpuinfo.sh

4. 从 "电脑下载补丁 6." 继续

** 电脑下载补丁 **

1. 将补丁下载到电脑上 ([ch_cpuinfo.sh](https://github.com/WenqiOfficial/ch_cpuinfo_zh/releases/download/v4.2.1-r01-zhv2/ch_cpuinfo.sh))

2. 上传补丁到DSM的共享目录 (File Station, sftp, webdav 等等都行...)

3. 使用DSM的管理员账户登录SSH到NAS. (DSM > 控制面板 > 终端机和SNMP > 终端机 > 启用 SSH 功能)

4. 切换到root:

   > sudo su -
   
   (输入SSH的管理员密码)

5. 按你的实际情况切换到补丁放置的路径(例：上传至挂载到 "存储空间1" 的 "temp" 文件夹):

   > cd /volume1/temp

6. 允许执行补丁:

   > chmod 755 ch_cpuinfo.sh

7. 运行补丁

   > ./ch_cpuinfo.sh
 
8. 按照提示操作

9. 完成！( •̀ ω •́ )y


# 额外链接

https://xpenology.com/forum/topic/13030-dsm-5x6x7x-cpu-name-cores-infomation-change-tool
