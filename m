From: Paul Hartlipp <paul@ldeo.columbia.edu>
Subject: RPC Timeout Error when trying to mount Linux client to Solaris Server
Date: Thu, 30 Jan 2003 10:03:41 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200301301003.41367.paul@ldeo.columbia.edu>
Reply-To: paul@ldeo.columbia.edu
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ldgo.columbia.edu ([129.236.10.30] helo=lamont.ldeo.columbia.edu)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18eGFr-0001zd-00
	for <nfs@lists.sourceforge.net>; Thu, 30 Jan 2003 07:05:27 -0800
Received: from eagle.ldeo.columbia.edu (eagle.ldgo.columbia.edu [129.236.22.31])
	(user=paul mech=PLAIN bits=0)
	by lamont.ldeo.columbia.edu (8.12.3/8.12.3/LDEO-1.27) with ESMTP id h0UF5Jk0029445
	for <nfs@lists.sourceforge.net>; Thu, 30 Jan 2003 10:05:19 -0500 (EST)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Good Day,

I know the reason for this is probably inexperience, but here goes with t=
he=20
problem.

[root@eagle paul]# uname -a
Linux eagle.ldeo.columbia.edu 2.4.18-3 #1 Thu Apr 18 07:37:53 EDT 2002 i6=
86=20
unknown
 am running LINUX on the client. uname output

For the server, the information is as follows:

1-imnavait% uname -a
SunOS imnavait 5.8 Generic_108528-17 sun4u sparc SUNW,Ultra-250I have not=
=20
applied any patches or tried any new nfs tools.

When I go into the linux /proc filesystem I don't see a nfs module in the=
re.=20
I'vetried adding it though to no avail.
/proc/filesystems.

hanodev   rootfs
nodev   bdev
nodev   proc
nodev   sockfs
nodev   tmpfs
nodev   shm
nodev   pipefs
        ext2
nodev   ramfs
        iso9660
nodev   devpts
        ext3
nodev   usbdevfs
nodev   usbfs
        ntfs
        vfat
nodev   autofs
nodev   bin_fmt
I have run insmod but on reboot the entry in the /proc/filesystem file=20
disappears.
Now for the rpcinfo from the client.
[root@eagle sbin]# ./rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    100011    1   udp    867  rquotad
    100011    2   udp    867  rquotad
    100011    1   tcp    870  rquotad
    100011    2   tcp    870  rquotad
    100005    1   udp  32769  mountd
    100005    1   tcp  32769  mountd
    100005    2   udp  32769  mountd
    100005    2   tcp  32769  mountd
    100005    3   udp  32769  mountd
    100005    3   tcp  32769  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  32770  nlockmgr
    100021    3   udp  32770  nlockmgr
    100021    4   udp  32770  nlockmgr
rpcinfo running from the client to the server.
[root@eagle sbin]# ./rpcinfo -p imnavait
   program vers proto   port
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100007    3   udp  32774  ypbind
    100007    2   udp  32774  ypbind
    100007    1   udp  32774  ypbind
    100007    3   tcp  32771  ypbind
    100007    2   tcp  32771  ypbind
    100007    1   tcp  32771  ypbind
    100024    1   udp  32780  status
    100024    1   tcp  32772  status
    100133    1   udp  32780
    100133    1   tcp  32772
    100232   10   udp  32782  sadmind
    100011    1   udp  32784  rquotad
    100002    2   udp  32787  rusersd
    100002    3   udp  32787  rusersd
    100021    1   udp   4045  nlockmgr
    100021    2   udp   4045  nlockmgr
    100021    3   udp   4045  nlockmgr
    100021    4   udp   4045  nlockmgr
    100002    2   tcp  32779  rusersd
    100002    3   tcp  32779  rusersd
    100012    1   udp  32793  sprayd
    100021    1   tcp   4045  nlockmgr
    100021    2   tcp   4045  nlockmgr
    100021    3   tcp   4045  nlockmgr
    100021    4   tcp   4045  nlockmgr
    100008    1   udp  32797  walld
    100001    2   udp  32800  rstatd
    100001    3   udp  32800  rstatd
    100001    4   udp  32800  rstatd
    100083    1   tcp  32789
    100221    1   tcp  32791
    100235    1   tcp  32793
    100068    2   udp  32812
    100068    3   udp  32812
    100068    4   udp  32812
    100068    5   udp  32812
 536870916    1   udp  32814
    100005    1   udp  32823  mountd
    100005    2   udp  32823  mountd
    100005    3   udp  32823  mountd
    100005    1   tcp  32801  mountd
    100005    2   tcp  32801  mountd
    100005    3   tcp  32801  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100227    2   udp   2049  nfs_acl
    100227    3   udp   2049  nfs_acl
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100227    2   tcp   2049  nfs_acl
    100227    3   tcp   2049  nfs_acl
    150001    1   udp    942  pcnfsd
    150001    2   udp    942  pcnfsd
    150001    1   tcp    943  pcnfsd
    150001    2   tcp    943  pcnfsd


And now for the error itself:
[root@eagle sbin]# mount /mnt/imnavait/data
mount: RPC: Timed out

And my /etcfstab entry:
imnavait:/local/data/imnavait   /mnt/imnavait/data      nfs     =20
exec,dev,suid,ro,hard,rsize=3D32768,wsize=3D32768,udp 1 1

Any help or pointers would br greatfully appreciated.

Paul




-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
