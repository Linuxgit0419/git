#!/bin/bash
# server 上的RHCE脚本
setenforce 1
getenforce
echo "server0.example.com" > /etc/hostname
echo "DenyUsers *@*.my133t.org  *@172.34.0.*" >> /etc/ssh/sshd_config
systemctl restart sshd
systemctl enable sshd
echo "alias qstat='/bin/ps -Ao pid,tt,user,fname,rsz'" >> /etc/bashrc
source /etc/bashrc
qstat
echo "selinux,别名设置完成"
sleep 3
firewall-cmd --set-default-zone=trusted
firewall-cmd --permanent --add-source=172.34.0.0/24 --zone=block
firewall-cmd --permanent --zone=trusted --add-forward-port=port=5423:proto=tcp:toport=80
firewall-cmd --reload
echo "防火墙端口转发设置完成"
lab teambridge setup
nmcli connection add type team con-name team0 ifname team0 config '{"runner":{"name":"activebackup"} }'
nmcli connection add type team-slave con-name team0-1 ifname eth1 master team0
nmcli connection add type team-slave con-name team0-2 ifname eth2 master team0
nmcli connection modify team0 ipv4.method manual ipv4.addresses "172.16.3.20/24" connection.autoconnect yes
nmcli connection up team0
nmcli connection up team0-1
nmcli connection up team0-2
teamdctl team0 state
nmcli connection modify "System eth0" ipv6.method manual ipv6.addresses "2003:ac18::305/64" connection.autoconnect yes
nmcli connection up "System eth0"
echo "ipv6地址,聚合链路设置完成"
sed -i '116s/localhost/loopback-only/g' /etc/postfix/main.cf
sed -i '164s/$myhostname, localhost.$mydomain, localhost//g' /etc/postfix/main.cf
echo "myorigin = desktop0.example.com
mynetworks = 127.0.0.0/8 [::1]/128
relayhost = [smtp0.example.com]
local_transport = error:error" >> /etc/postfix/main.cf
systemctl restart postfix
systemctl enable postfix
mail -s "test" student </etc/passwd
mail -u student
echo "邮件服务搭建完成"
sleep 3
yum -y install samba
mkdir /common /devops
useradd harry
useradd kenji
useradd chihiro
setfacl -m u:chihiro:rwx /devops/
pdbedit -a harry << EOF
migwhisk
migwhisk
EOF
pdbedit -a kenji << EOF
atenorth
atenorth
EOF
pdbedit -a chihiro << EOF
atenorth
atenorth
EOF
sed -i '89s/MYGROUP/STAFF/g' /etc/samba/smb.conf
echo "[common]
path = /common
hosts allow = 172.25.0.0/24
[devops]
path = /devops
hosts allow = 172.25.0.0/24
write list = chihiro" >> /etc/samba/smb.conf
setsebool -P samba_export_all_ro=on
setsebool -P samba_export_all_rw=on
getsebool -a | grep samba
systemctl restart smb
systemctl enable smb
echo "samba服务搭建完成"
lab nfskrb5 setup
mkdir -p  /public  /protected/project
chown ldapuser0 /protected/project
echo "/public 172.25.0.0/24(ro)
/protected 172.25.0.0/24(rw,sec=krb5p)" >> /etc/exports
wget -O /etc/krb5.keytab http://classroom.example.com/pub/keytabs/server0.keytab
systemctl restart nfs-secure-server nfs-server
systemctl enable nfs-secure-server nfs-server
echo "nfs服务搭建完成"
yum -y install httpd
cd /var/www/html
wget http://classroom.example.com/pub/materials/station.html
mv station.html index.html
ls
cd /
sleep 3
echo "<VirtualHost *:80>
  ServerName server0.example.com
  DocumentRoot /var/www/html
</VirtualHost>" >> /etc/httpd/conf.d/nsd01.conf
systemctl restart httpd
systemctl enable httpd
yum -y install mod_ssl
cd /etc/pki/tls/certs
wget http://classroom.example.com/pub/tls/certs/server0.crt
wget http://classroom.example.com/pub/example-ca.crt
cd /etc/pki/tls/private/
wget http://classroom.example.com/pub/tls/private/server0.key
cd /
sed -i '59s/^#Do/Do/' /etc/httpd/conf.d/ssl.conf
sed -i '60s/^#Se/Se/' /etc/httpd/conf.d/ssl.conf
sed -i '122s/^#SSL/SSL/' /etc/httpd/conf.d/ssl.conf
sed -i '60s/www/server0/g' /etc/httpd/conf.d/ssl.conf
sed -i '100s/localhost/server0/g' /etc/httpd/conf.d/ssl.conf
sed -i '107s/localhost/server0/g' /etc/httpd/conf.d/ssl.conf
sed -i '122s/ca-bundle/example-ca/g' /etc/httpd/conf.d/ssl.conf
systemctl restart httpd
systemctl enable httpd
echo "安全web搭建完成"
mkdir /var/www/virtual
cd /var/www/virtual
wget http://classroom.example.com/pub/materials/www.html
mv www.html index.html
cd /
useradd fleyd
setfacl -m u:fleyd:rwx /var/www/virtual/
echo "<VirtualHost *:80>
  ServerName www0.example.com
  DocumentRoot /var/www/virtual
</VirtualHost>" >> /etc/httpd/conf.d/nsd01.conf
systemctl restart httpd
systemctl enable httpd
echo "虚拟主机配置完成"
mkdir /var/www/html/private
cd /var/www/html/private
wget http://classroom.example.com/pub/materials/private.html
mv private.html index.html
cd /
echo "<Directory /var/www/html/private>
  Require ip 172.25.0.11
</Directory>" >> /etc/httpd/conf.d/nsd02.conf
systemctl restart httpd
systemctl enable httpd
echo "private配置完成"
yum -y install mod_wsgi
mkdir /var/www/webapp0
cd /var/www/webapp0
wget http://classroom.example.com/pub/materials/webinfo.wsgi
cd /
echo "Listen 8909
<VirtualHost *:8909>
  ServerName webapp0.example.com
  DocumentRoot /var/www/webapp0
  WSGIScriptAlias / /var/www/webapp0/webinfo.wsgi
</VirtualHost>" >> /etc/httpd/conf.d/nsd01.conf
semanage port -a -t http_port_t -p tcp 8909
semanage port -a -t http_port_t -p tcp 890
semanage port -a -t http_port_t -p tcp 8909
systemctl restart httpd
systemctl enable httpd
echo "动态web设置完成"
sleep 3
echo '#!/bin/bash
if [ "$1" = redhat ];then
echo fedora
elif [ "$1" = fedora ];then
echo redhat
else
echo "/root/foo.sh redhat|fedora"
fi ' >> /root/foo.sh
chmod +x /root/foo.sh
cd /root
wget http://classroom.example.com/pub/materials/userlist
cd /
echo '#!/bin/bash
if [ $# -eq 0 ];then
echo "Usage: /root/batchusers <userfile>"
exit 1
fi
if [ ! -f $1 ];then
echo "Input file not found"
exit 2
fi
for name in $(cat $1)
do
useradd -s /bin/false $name >/dev/null
done ' >> /root/batchusers
chmod +x /root/batchusers
echo "脚本编辑完成"
fdisk /dev/vdb << EOF
n
p


+3G
w
EOF
partprobe
lsblk
sleep 3
yum -y install targetcli
targetcli << EOF
backstores/block create name=iscsi_store dev=/dev/vdb1
iscsi/ create iqn.2016-02.com.example:server0
iscsi/iqn.2016-02.com.example:server0/tpg1/luns create /backstores/block/iscsi_store
iscsi/iqn.2016-02.com.example:server0/tpg1/acls create iqn.2016-02.com.example:desktop0
iscsi/iqn.2016-02.com.example:server0/tpg1/portals create 172.25.0.11 3260
exit
EOF
systemctl restart target
systemctl enable target
echo "iscsi设置完成"
yum -y install mariadb-server mariadb
echo "skip-networking" >> /etc/my.cnf
systemctl restart mariadb
systemctl enable mariadb
mysqladmin -u root password 'atenorth'
mysql -u root -patenorth << EOF
create database Contacts;
grant select on Contacts.* to Raikon@localhost identified by 'atenorth';
delete from mysql.user where password='';
quit
EOF
cd /
wget http://classroom.example.com/pub/materials/users.sql
mysql -u root -patenorth Contacts < users.sql
mysql -u root -patenorth << EOF
use Contacts;
select name from base where password='solicitous';
select count(*) from base,location where base.name='Barbara' and  location.city='Sunnyvale' and  base.id=location.id;
quit
EOF
echo "mariadb数据查询完成"
echo "Server所有配置设置完成"
