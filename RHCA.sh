#!/bin/bash
echo "server0.example.com" > /etc/hostname
rm -rf /etc/yum.repos.d/*
echo "[fee]
name=dev
baseurl=http://content.example.com/rhel7.0/x86_64/dvd
enabled=1
gpgcheck=0" > /etc/yum.repos.d/dev.repo
echo "yum仓库搭建完成"
nmcli connection modify 'System eth0' ipv4.method manual ipv4.addresses '172.25.0.11/24 172.25.0.254' ipv4.dns 172.25.254.254 connection.autoconnect yes
nmcli connection up 'System eth0'
echo 'ip地址设置完成'
fdisk /dev/vdb << EOF
n
p
1

+1G
w
EOF
partprobe
sleep 3
lsblk
vgcreate systemvg /dev/vdb1
lvcreate -n vo -L 200M systemvg
lvextend -L 300M /dev/systemvg/vo
mkdir /vo
mkfs.ext3 /dev/systemvg/vo
echo "/dev/systemvg/vo  /vo  ext3 defaults  0  0" >> /etc/fstab
mount -a
df -h
echo '300M逻辑卷创建完成'
groupadd adminuser
useradd -G adminuser natasha
useradd -G adminuser harry
useradd -s /sbin/nologin sarah
useradd -u 3456 alex
echo '用户创建完成'
echo 'flectrag' | passwd --stdin natasha
echo 'flectrag' | passwd --stdin harry
echo 'flectrag' | passwd --stdin sarah
echo "用户密码设置完成"
cp -p /etc/fstab  /var/tmp/fstab
setfacl -m u:natasha:rw /var/tmp/fstab
setfacl -m u:harry:--- /var/tmp/fstab
echo '文件权限设置完成'
mkdir /home/admins
chown :adminuser /home/admins
chmod g+w /home/admins
chmod g+s /home/admins
chmod o=--- /home/admins
echo '共享文件创建完成'
echo "23 14 * * *  /bin/echo hiya" >> /var/spool/cron/natasha
crontab -l -u natasha
crontab -l -u natasha
echo "cron定时任务创建完成"
wget http://classroom.example.com/content/rhel7.0/x86_64/errata/Packages/kernel-3.10.0-123.1.2.el7.x86_64.rpm
sleep 5
rpm -ivh kernel-3.10.0-123.1.2.el7.x86_64.rpm
echo "内核升级完成"
yum -y install sssd
mkdir /etc/openldap/cacerts/ 
cd /etc/openldap/cacerts/ 
wget http://classroom.example.com/pub/example-ca.crt
cd /
authconfig-tui
systemctl restart sssd
systemctl enable sssd
id ldapuser0
sleep 3
yum -y install autofs
mkdir /home/guests
echo "/home/guests   /etc/auto.guests"  >> /etc/auto.master
echo "* -rw classroom.example.com:/home/guests/&"  > /etc/auto.guests
systemctl restart autofs
systemctl enable autofs
echo "autofs设置完成"
yum -y install chrony
sed -i '3,5s/^/#/' /etc/chrony.conf
sed -i '6s/server 3.rhel.pool.ntp.org iburst/server classroom.example.com iburst/' /etc/chrony.conf
echo "NTP网络时间设置完成"
fdisk /dev/vdb  << EOF
n
p


+512M
w
EOF
partprobe
lsblk
mkswap /dev/vdb2
echo "/dev/vdb2  swap  swap  defaults  0  0 " >> /etc/fstab
swapon -s
swapon -a
swapon -s
sleep 10
echo "swap创建完成"
mkdir /root/findfiles
find / -user student -type f -exec cp -p {} /root/findfiles \;
touch /root/wordlist
grep seismic /usr/share/dict/words > /root/wordlist
tar -jcPf /root/backup.tar.bz2  /usr/local
echo "字符串,文件,文档查找完成"
fdisk /dev/vdb << EOF
n
p


+1G
w
EOF
partprobe
sleep 3
vgcreate -s 16M datastore /dev/vdb3
lvcreate -n database -l 50 datastore
mkfs.ext3 /dev/datastore/database
mkdir /mnt/database
echo "/dev/datastore/database /mnt/database ext3 defaults 0  0" >> /etc/fstab
mount -a
df -h
echo "逻辑卷创建完成"
echo "脚本运行完成"
