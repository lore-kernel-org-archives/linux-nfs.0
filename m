From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: issues with nfsv4 secure(krb5) and non-secure mounts on RHEL4 u2
Date: Wed, 8 Mar 2006 07:35:42 -0800 (PST)
Message-ID: <20060308153542.62119.qmail@web51603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FH0hc-0005EO-BA
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 07:35:52 -0800
Received: from web51603.mail.yahoo.com ([206.190.38.208])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FH0hb-0005cO-M2
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 07:35:52 -0800
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,
     I am facing couple of issues with nfsv4 mounts
1. Some times mount command cannot mount the exported
   filesytem. mount gives error "Mount: File exists"
   When i used a different mount point, it gets
mounted
  =20
[root@vcslinux121 ~]# mount
/dev/sda1 on / type ext3 (rw)
none on /proc type proc (rw)
none on /sys type sysfs (rw)
none on /dev/pts type devpts (rw,gid=3D5,mode=3D620)
usbfs on /proc/bus/usb type usbfs (rw)
tmpfs on /dev/vx type tmpfs
(rw,size=3D4k,nr_inodes=3D2097152,mode=3D0755)
none on /dev/shm type tmpfs (rw)
none on /proc/sys/fs/binfmt_misc type binfmt_misc (rw)
sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
[root@vcslinux121 ~]# mount -t nfs4=20
vcslinux139.vxindia.veritas.com:/  /mnt
mount: File exists
[root@vcslinux121 ~]# mount
/dev/sda1 on / type ext3 (rw)
none on /proc type proc (rw)
none on /sys type sysfs (rw)
none on /dev/pts type devpts (rw,gid=3D5,mode=3D620)
usbfs on /proc/bus/usb type usbfs (rw)
tmpfs on /dev/vx type tmpfs
(rw,size=3D4k,nr_inodes=3D2097152,mode=3D0755)
none on /dev/shm type tmpfs (rw)
none on /proc/sys/fs/binfmt_misc type binfmt_misc (rw)
sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
[root@vcslinux121 ~]#
[root@vcslinux121 ~]# mount -t nfs4=20
vcslinux139.vxindia.veritas.com:/  /home/gu
est
[root@vcslinux121 ~]# mount
/dev/sda1 on / type ext3 (rw)
none on /proc type proc (rw)
none on /sys type sysfs (rw)
none on /dev/pts type devpts (rw,gid=3D5,mode=3D620)
usbfs on /proc/bus/usb type usbfs (rw)
tmpfs on /dev/vx type tmpfs
(rw,size=3D4k,nr_inodes=3D2097152,mode=3D0755)
none on /dev/shm type tmpfs (rw)
none on /proc/sys/fs/binfmt_misc type binfmt_misc (rw)
sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
vcslinux139.vxindia.veritas.com:/ on /home/guest type
nfs4 (rw,addr=3D10.212.88.31)


After client reboot, i can again mount on /mnt






  =20
2. i am able to mount the filesystem(exported with=20
   krb5) and cannot access individual mounts.=20

************ server side ***********************
[root@vcslinux139 ~]# exportfs -v
/home/export/nshare1
              =20
<world>(rw,wdelay,nohide,no_root_squash)
/home/export/nshare3
              =20
<world>(rw,wdelay,nohide,no_root_squash)
/home/export/nshare2
              =20
<world>(rw,wdelay,nohide,no_root_squash)
/home/export  =20
<world>(rw,wdelay,nohide,no_root_squash,fsid=3D0)
/home/export/nshare3
              =20
gss/krb5(rw,wdelay,nohide,no_root_squash)
/home/export/nshare2
              =20
gss/krb5(rw,wdelay,nohide,no_root_squash)
/home/export/nshare1
              =20
gss/krb5(rw,wdelay,nohide,no_root_squash)
/home/export  =20
gss/krb5(rw,wdelay,nohide,no_root_squash,fsid=3D0)

[root@vcslinux139 ~]# hostname
vcslinux139.vxindia.veritas.com
[root@vcslinux139 ~]# ps -ef | grep nfs
root      8964     1  0 20:35 ?        00:00:00 [nfsd]
root      8965     1  0 20:35 ?        00:00:00 [nfsd]
root      8966     1  0 20:35 ?        00:00:00 [nfsd]
root      8967     1  0 20:35 ?        00:00:00 [nfsd]
root      8968     1  0 20:35 ?        00:00:00 [nfsd]
root      8969     1  0 20:35 ?        00:00:00 [nfsd]
root      8970     1  0 20:35 ?        00:00:00 [nfsd]
root      8971     1  0 20:35 ?        00:00:00 [nfsd]
root      8972     1  0 20:35 ?        00:00:00 [nfsd]
root      8973     1  0 20:35 ?        00:00:00 [nfsd]
root     15577  7051  0 21:05 pts/1    00:00:00 grep
nfs
[root@vcslinux139 ~]# ps -ef | grep rpc
rpc       5179     1  0 20:30 ?        00:00:00
portmap
root      8975     1  0 20:35 ?        00:00:00
[rpciod]
root      8977     1  0 20:35 ?        00:00:00
rpc.mountd
rpcuser   8983     1  0 20:35 ?        00:00:00
rpc.statd
root      8985     1  0 20:35 ?        00:00:00
rpc.idmapd
root      8987     1  0 20:35 ?        00:00:00
rpc.svcgssd
root     15579  7051  0 21:05 pts/1    00:00:00 grep
rpc
[root@vcslinux139 ~]# /usr/kerberos/bin/klist -k
/etc/krb5.keytab
Keytab name: FILE:/etc/krb5.keytab
KVNO Principal
----
-------------------------------------------------------------------------=
-
   4
nfs/vcslinux139.vxindia.veritas.com@VXINDIA.VERITAS.COM

***********************************************



***********************client side **********

[root@vcslinux121 ~]# mount
/dev/sda1 on / type ext3 (rw)
none on /proc type proc (rw)
none on /sys type sysfs (rw)
none on /dev/pts type devpts (rw,gid=3D5,mode=3D620)
usbfs on /proc/bus/usb type usbfs (rw)
tmpfs on /dev/vx type tmpfs
(rw,size=3D4k,nr_inodes=3D2097152,mode=3D0755)
none on /dev/shm type tmpfs (rw)
none on /proc/sys/fs/binfmt_misc type binfmt_misc (rw)
sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
vcslinux139.vxindia.veritas.com:/ on /mnt1 type nfs4
(rw,sec=3Dkrb5,addr=3D10.212.88
.31)
[root@vcslinux121 ~]# cd /mnt1
[root@vcslinux121 mnt1]# ls
lost+found  nshare0  nshare1  nshare2  nshare3=20
nshare4  nshare5
[root@vcslinux121 mnt1]# cd
[root@vcslinux121 ~]# klist -k /etc/krb5.keytab
Keytab name: FILE:/etc/krb5.keytab
KVNO Principal
----
-------------------------------------------------------------------------=
-
   2
nfs/vcslinux121.vxindia.veritas.com@VXINDIA.VERITAS.COM
[root@vcslinux121 ~]# ps -ef | grep rpc
rpc       4054     1  0 20:42 ?        00:00:00
portmap
rpcuser   4074     1  0 20:42 ?        00:00:00
rpc.statd
root      4102     1  0 20:42 ?        00:00:00
rpc.idmapd
root      5992     1  0 20:42 ?        00:00:00
rpc.gssd -m
root      6633     1  0 20:57 ?        00:00:00
[rpciod]
root      6890  4533  0 21:00 pts/0    00:00:00 grep
rpc

[root@vcslinux121 mnt1]# cd nshare2
        ..... gets hung

***************************************************


thanks,
 kiran
    =20

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
