#!/bin/bash
mount /dev/cdrom /mnt &> /dev/null
if [ $? != 0 ];then
  echo "请先添加光盘!"
  exit
fi
a=`ifconfig |head -2 |awk '/inet/{print $2}'`
touch /ip.txt
echo "`ifconfig |head -2 |awk '/inet/{print $2}'`" > /ip.txt
b=`awk -F. '{print $1}' ip.txt`
c=`awk -F. '{print $2}' ip.txt`
d=`awk -F. '{print $3}' ip.txt`
e=`awk -F. '{print $4}' ip.txt`
echo "本机的ip地址为:$a"
sleep 3
echo "[development]
name=CentOS-$releasever - Base
baseurl="ftp://$b.$c.$d.254/centos-1804"
enabled=1
gpgcheck=0" > /etc/yum.repos.d/local.repo
yum -y install dhcp tftp-server syslinux
echo "subnet $b.$c.$d.0 netmask 255.255.255.0 {
  range $b.$c.$d.100 $b.$c.$d.200;
  option domain-name-servers $a;
  option routers $b.$c.$d.254;
  default-lease-time 600;
  max-lease-time 7200;
  next-server $a;
  filename \"pxelinux.0\";
} " >> /etc/dhcp/dhcpd.conf
systemctl restart dhcpd
cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
mount /dev/cdrom /mnt/
mkdir /var/lib/tftpboot/pxelinux.cfg
cp /mnt/isolinux/isolinux.cfg /var/lib/tftpboot/pxelinux.cfg/default
cp /mnt/isolinux/vesamenu.c32 /mnt/isolinux/splash.png /mnt/isolinux/vmlinuz /mnt/isolinux/initrd.img /var/lib/tftpboot/
ls /var/lib/tftpboot/
sleep 3
sed -i '65,$d' /var/lib/tftpboot/pxelinux.cfg/default
sed -i '11s/CentOS 7/NSD1905/g' /var/lib/tftpboot/pxelinux.cfg/default
sed -i '62s/\^Install/Install/' /var/lib/tftpboot/pxelinux.cfg/default
sed -i '62amenu default' /var/lib/tftpboot/pxelinux.cfg/default
sed -i '65s/inst.stage2=hd\:LABEL=CentOS\\x207\\x20x86_64 quiet//g' /var/lib/tftpboot/pxelinux.cfg/default
systemctl disable tftp
systemctl restart tftp
systemctl restart dhcpd
yum -y install httpd
mkdir /var/www/html/centos
mount /dev/cdrom /var/www/html/centos/
systemctl restart httpd
yum -y install system-config-kickstart
touch /root/ks.cfg
echo "#platform=x86, AMD64, or Intel EM64T
#version=DEVEL
# Install OS instead of upgrade
install
# Keyboard layouts
keyboard 'us'
# Root password
rootpw --iscrypted \$1\$7ptbO297\$HZggXgee81aFSNCBC1ZdD/
# Use network installation
url --url="http://$a/centos"
# System language
lang en_US
# System authorization information
auth  --useshadow  --passalgo=sha512
# Use graphical install
graphical
firstboot --disable
# SELinux configuration
selinux --disabled

# Firewall configuration
firewall --disabled
# Network information
network  --bootproto=dhcp --device=eth0
# Reboot after installation
reboot
# System timezone
timezone Asia/Shanghai
# System bootloader configuration
bootloader --location=mbr
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all --initlabel
# Disk partitioning information
part / --fstype="xfs" --grow --size=1

%post --interpreter=/bin/bash
useradd lisi
echo 123456 | passwd --stdin lisi
%end

%packages
@base

%end " > /root/ks.cfg
cp /root/ks.cfg /var/www/html/
sed -i "65s/append initrd=initrd.img/append initrd=initrd.img ks=http:\/\/$a\/ks.cfg/g" /var/lib/tftpboot/pxelinux.cfg/default
echo "root密码为:123456"
echo "pxe一键装机搭建完成!"
