#!/bin/bash
#desktop 上的RHCE脚本
setenforce 1
getenforce
echo "desktop0.example.com" > /etc/hostname
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
nmcli connection modify team0 ipv4.method manual ipv4.addresses "172.16.3.25/24" connection.autoconnect yes
nmcli connection up team0
nmcli connection up team0-1
nmcli connection up team0-2
teamdctl team0 state
nmcli connection modify "System eth0" ipv6.method manual ipv6.addresses "2003:ac18::306/64" connection.autoconnect yes
nmcli connection up "System eth0"
echo "ipv6地址,聚合链路设置完成"
lab smtp-nullclient setup
yum -y install samba-client cifs-utils
mkdir /mnt/dev
echo '//server0.example.com/devops /mnt/dev cifs username=kenji,password=atenorth,multiuser,sec=ntlmssp,_netdev 0  0' >> /etc/fstab
mount -a
df -h
echo "samba服务挂载完成"
sleep 3
lab nfskrb5 setup
mkdir /mnt/nfssecure /mnt/nfsmount
wget -O /etc/krb5.keytab http://classroom.example.com/pub/keytabs/desktop0.keytab
systemctl restart nfs-secure
systemctl enable nfs-secure
showmount –e server0
echo "server0.example.com:/public /mnt/nfsmount nfs _netdev  0  0
server0.example.com:/protected /mnt/nfssecure nfs sec=krb5p,_netdev  0  0" >> /etc/fstab
mount -a
df -h
echo "nfs服务挂载完成"
sleep 3
yum -y install iscsi-initiator-utils
echo "InitiatorName=iqn.2016-02.com.example:desktop0" > /etc/iscsi/initiatorname.iscsi
systemctl restart iscsid
systemctl enable iscsid
iscsiadm --mode discoverydb --type sendtargets --portal 172.25.0.11 --discover
sed -i '50s/manual/automatic/g' /var/lib/iscsi/nodes/iqn.2016-02.com.example\:server0/*/default
systemctl restart iscsi
systemctl enable iscsi
lsblk
sleep 3
fdisk /dev/sda << EOF
n
p

 
+2100M
w
EOF
partprobe
mkdir /mnt/data
lsblk
sleep 3
mkfs.ext4 /dev/sda1
echo "/dev/sda1 /mnt/data ext4 _netdev 0  0" >> /etc/fstab
mount -a
df -h
echo "iscsi硬盘挂载完成"
echo "desktop所有配置已经完成,如果需要重启,请输入sync;reboot -f"
