#/bin/bash
echo“server0.example.com”>/etc/hostname
rm/rf/etc/yum.Storage.d/*
echo“[fee]
 name=dev
base url=http：/content.example.com/rhel7.0/x86_64/dvd
启用=1
gpgcheck=0>/etc/yum.资源库d/dev.repo
echo”yum仓库搭建完成“yum”
nmcli连接修改‘System eth0’ipvv 4.方法手动ipv4.172.0.25.11/24 172.25.0.254‘ipv4.dns 172.25.254.254 connection.autoconnect yes
nmcli connection up’System eth0‘
echo’ip地址设置完成‘
fdisk/dev/vdb<<EOF
n
p
1

+1G
w
EOF
partprobe
sleep 3
lsblk
vgcreate systemvg/dev/vdb1
lvcreate-n vo-L 200M systemvg
lvextend-L 300M/dev/systemvg/vo
mkdir/vo
mkfs.ext3/dev/systemvg/vo
echo“/dev/systemvg/vo/vo ext3 defaults 0 0“>>/etc/fstab
mount-a
df-h
echo‘300M逻辑卷创建完成’
groupadd adminuser
useradd-G adminuser natasha
useradd-G adminuser harry
useradd-s/sbin/nologin sarah
useradd-u 3456 alex
echo‘用户创建完成’
echo‘flectrag’passwd--stdin natasha
echo‘flectrag’passwd--stdin harry
echo‘flectrag’passwd--stdin sarah
echo”用户密码设置完成
cp/etc/f剧/var/tmp/f剧
setfacl-m：Natasha：rw/var/tmp/f剧
setfacl-m：harry：-/var/tmp/文件权限设置完成‘nmkdir/home/adminsnchmog+w/home/admins
chmod g+s/home/admins
chmodo=-/home/admins
chmod o=-/home/admins
echo’共享文件创建完成
echo
echo 2314*bin/echo hiya>/var/spool/cron/Natasha
crontab-l-u Natasha
echo“cron定时任务创建完成”
wget http：/classRoom.example.com/content/rhel7.0/x86_64/errata/Packages/内核-3.10.0-123.2.el7.x86_64.rpm
睡眠5
rpm-IVH内核-3.10.0-123.1.2。el7.x86_64.rpm
echo“内核升级完成”
yum-y install sssd
mkdir/etc/openldap/cacerts/
cd/etc/openldap/cacerts/
wget http://classroom.example.com/pub/example-ca.crt
cd/
authconfig-tui
systemctl restart sssd
systemctl enable sssd
id ldapuser0
sleep 3
yum-y install autofs
mkdir/home/guests
echo“/home/guests/etc/auto.guests”>>/etc/auto.master
echo“*-rw classRoom.example.com：/home/来宾/&lt；&lt；
fdisk/dev/vdb<EOF
n
p

+512M
w
EOF
partprobe
lsblk
mkswap/dev/vdb 2
echo“/dev/vdb 2交换默认值为0”>/etc/f剧
swapon-s
swapon-a
swapon-s
swapon 10
echo“设置完成创建完成”mkdir/root/findfile
查找/-用户学生类型f-exec cp{}/设置完成/findfiles；
touch/root/wordlist
grep地震/usr/share/dict/word>/root/wordlist
tar-jcPf/root/backup.tar.bz2/usr/local
echo“字符串，文件，文档查找完成“
fdisk/dev/vdb<<EOF
n
p

+1G
w
EOF
partprobe
sleep 3
vgcreate-s 16M datastore/dev/vdb3
lvcreate-n database-l 50 datastore
mkfs.ext3/dev/datastore/database
mkdir/mnt/database
echo”/dev/datastore/database/mnt/database ext3 defaults 0 0“>>/etc/fstab
mount-a
df-h
echo”逻辑卷创建完成“
echo”脚本运行完成“
