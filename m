From: "Davis, Jeff (Houston)" <jdavis@hess.com>
Subject: showmount -a output gets larger and larger and things to get a bit flaky
Date: Fri, 1 Apr 2005 17:47:05 -0600
Message-ID: <292E6FA1FCA21C45B614DAC7FBED6D4B028AD91E@hacssex002.ihess.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01C53715.1BF693DC"
Cc: "Global Technical Computing Infrastructure" <gtci@hess.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DHVr5-0003bE-8H
	for nfs@lists.sourceforge.net; Fri, 01 Apr 2005 15:47:11 -0800
Received: from mailgwy1.hess.com ([63.105.228.200] helo=[172.31.1.229])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DHVr3-0000cb-SW
	for nfs@lists.sourceforge.net; Fri, 01 Apr 2005 15:47:11 -0800
To: <nfs@lists.sourceforge.net>
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

This is a multi-part message in MIME format.

------_=_NextPart_001_01C53715.1BF693DC
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

=09

i have a 10 server nfs server cluster with 75 exported filesystems about
1500 clients.=20

i use automount on the clients

clustering software is polyserve

OS on nfs servers is redhat enterprise 3 update 3 runing 2.4.21-20.ELsmp
kernel
OS on nfs clients is redhat enterprise 3 update 4 running
2.4.27-0.2.ELsmp kernel

i run a showmount -a | wc -l   against all my servers

hacscs001
   4091
=20
hacscs015
   4428
=20
hacscs027
   4136
=20
hacscs028
   4744
=20
hacscs029
   4962
=20
hacscs030
   4567
=20
hacscs031
   5323
=20
hacscs032
   4585
=20
hacsstc004
   4065


when i actually check my clients, id say the total number of mounts is
really between 400-800 accross
all 10 servers. even after running exportfs -rv, the numbers from
showmount -a still tend to show 1000s of
entries per server (no where near the 400-800 total)

1. when client unmounts a nfs filesystem, does the entry get removed the
nfs servers mount table?

2. i would assume there be no difference between automounted nfs client
versus fstab mounted client?

3. it does seem like when number of entries in nfs mount table gets
large, that problems start occurring and
i need to run exportfs -rv to make thing run more smoothly.

errors on server look generally like

Apr  1 15:48:42 hacscs030 rpc.mountd: authenticated mount request from
v00001.ihess.com:923 for /export/e1 (/export/e1)
Apr  1 15:48:42 hacscs030 rpc.mountd: getfh failed: Operation not
permitted

errors on client look like

Apr  1 15:48:41 v00001 automount[23633]: attempting to mount entry
/san/e1
Apr  1 15:48:42 v00001 automount[23641]: >> mount:
hacscf001.ihess.com:/export/e1 failed, reason given by server:
Permission denied
Apr  1 15:48:42 v00001 automount[23641]: mount(nfs): nfs: mount failure
hacscf001.ihess.com:/export/e1 on /san/e1
Apr  1 15:48:42 v00001 automount[23641]: failed to mount /san/e1

/etc/exports from all 10 servers
=20
/export/e1      *(rw,no_subtree_check,no_root_squash)
/export/e2      *(rw,no_subtree_check,no_root_squash)
/export/e3      *(rw,no_subtree_check,no_root_squash)
/export/e4      *(rw,no_subtree_check,no_root_squash)
/export/e5      *(rw,no_subtree_check,no_root_squash)
/export/e6      *(rw,no_subtree_check,no_root_squash)
/export/e7      *(rw,no_subtree_check,no_root_squash)
/export/e8      *(rw,no_subtree_check,no_root_squash)
/export/e9      *(rw,no_subtree_check,no_root_squash)
/export/e10     *(rw,no_subtree_check,no_root_squash)
/export/e11     *(rw,no_subtree_check,no_root_squash)
/export/e12     *(rw,no_subtree_check,no_root_squash)
/export/e13     *(rw,no_subtree_check,no_root_squash)
/export/e14     *(rw,no_subtree_check,no_root_squash)
/export/e15     *(rw,no_subtree_check,no_root_squash)
/export/e16     *(rw,no_subtree_check,no_root_squash)
/export/e17     *(rw,no_subtree_check,no_root_squash)
/export/e18     *(rw,no_subtree_check,no_root_squash)
/export/e19     *(rw,no_subtree_check,no_root_squash)
/export/e20     *(rw,no_subtree_check,no_root_squash)
/export/e21     *(rw,no_subtree_check,no_root_squash)
/export/e22     *(rw,no_subtree_check,no_root_squash)
/export/e23     *(rw,no_subtree_check,no_root_squash)
/export/e24     *(rw,no_subtree_check,no_root_squash)
/export/e25     *(rw,no_subtree_check,no_root_squash)
/export/e26     *(rw,no_subtree_check,no_root_squash)
/export/e27     *(rw,no_subtree_check,no_root_squash)
/export/e28     *(rw,no_subtree_check,no_root_squash)
/export/e29     *(rw,no_subtree_check,no_root_squash)
/export/e30     *(rw,no_subtree_check,no_root_squash)
/export/e31     *(rw,no_subtree_check,no_root_squash)
/export/e32     *(rw,no_subtree_check,no_root_squash)
/export/e33     *(rw,no_subtree_check,no_root_squash)
/export/e34     *(rw,no_subtree_check,no_root_squash)
/export/e35     *(rw,no_subtree_check,no_root_squash)
/export/e36     *(rw,no_subtree_check,no_root_squash)
/export/e37     *(rw,no_subtree_check,no_root_squash)
/export/e38     *(rw,no_subtree_check,no_root_squash)
/export/e39     *(rw,no_subtree_check,no_root_squash)
/export/e40     *(rw,no_subtree_check,no_root_squash)
/export/e41     *(rw,no_subtree_check,no_root_squash)
/export/e42     *(rw,no_subtree_check,no_root_squash)
/export/e43     *(rw,no_subtree_check,no_root_squash)
/export/e44     *(rw,no_subtree_check,no_root_squash)
/export/e45     *(rw,no_subtree_check,no_root_squash)
/export/e46     *(rw,no_subtree_check,no_root_squash)
/export/e47     *(rw,no_subtree_check,no_root_squash)
/export/e48     *(rw,no_subtree_check,no_root_squash)
/export/e49     *(rw,no_subtree_check,no_root_squash)
/export/e50     *(rw,no_subtree_check,no_root_squash)
/export/e51     *(rw,no_subtree_check,no_root_squash)
/export/e52     *(rw,no_subtree_check,no_root_squash)
/export/e53     *(rw,no_subtree_check,no_root_squash)
/export/e54     *(rw,no_subtree_check,no_root_squash)
/export/e55     *(rw,no_subtree_check,no_root_squash)
/export/e56     *(rw,no_subtree_check,no_root_squash)
/export/e57     *(rw,no_subtree_check,no_root_squash)
/export/e58     *(rw,no_subtree_check,no_root_squash)
/export/e59     *(rw,no_subtree_check,no_root_squash)
/export/e60     *(rw,no_subtree_check,no_root_squash)
/export/e61     *(rw,no_subtree_check,no_root_squash)
/export/e62     *(rw,no_subtree_check,no_root_squash)
/export/e63     *(rw,no_subtree_check,no_root_squash)
/export/e64     *(rw,no_subtree_check,no_root_squash)
/export/e65     *(rw,no_subtree_check,no_root_squash)
/export/e66     *(rw,no_subtree_check,no_root_squash)
/export/e67     *(rw,no_subtree_check,no_root_squash)
/export/e68     *(rw,no_subtree_check,no_root_squash)
/export/e69     *(rw,no_subtree_check,no_root_squash)
/export/e70     *(rw,no_subtree_check,no_root_squash)
/export/e71     *(rw,no_subtree_check,no_root_squash)
/export/e72     *(rw,no_subtree_check,no_root_squash)
/export/e73     *(rw,no_subtree_check,no_root_squash)
/export/e74     *(rw,no_subtree_check,no_root_squash)
/export/e75     *(rw,no_subtree_check,no_root_squash)

/etc/auto.master

san    /etc/auto.san    --timeout=3D1000 --ghost --verbose

/etc/auto.san

rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retra=
ns=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e1
e2
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e2
e3
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e3
e4
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e4
e5
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e5
e6
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e6
e7
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e7
e8
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e8
e9
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e9
e10
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e10
e11
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e11
e12
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e12
e13
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e13
e14
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e14
e15
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e15
e16
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e16
e17
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e17
e18
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e18
e19
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e19
e20
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e20
e21
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e21
e22
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e22
e23
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e23
e24
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e24
e25
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e25
e26
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e26
e27
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e27
e28
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e28
e29
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e29
e30
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e30
e31
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e31
e32
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e32
e33
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e33
e34
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e34
e35
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e35
e36
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e36
e37
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e37
e38
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e38
e39
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e39
e40
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e40
e41
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e41
e42
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e42
e43
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e43
e44
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e44
e45
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e45
e46
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e46
e47
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e47
e48
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e48
e49
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e49
e50
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e50
#DDN1
e51
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e51
e52
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e52
e53
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e53
e54
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e54
e55
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e55
e56
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e56
e57
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e57
e58
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e58
e59
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e59
e60
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e60
e61
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e61
e62
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e62
e63
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e63
e64
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e64
e65
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e65
e66
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e66
e67
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e67
e68
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e68
#DDN2
e69
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e69
e70
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e70
e71
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e71
e72
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e72
e73
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e73
e74
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e74
e75
-rw,hard,bg,intr,nfsvers=3D3,rsize=3D32768,wsize=3D32768,timeo=3D100,retr=
ans=3D10
hacscf001.ihess.com(1),hacscf001.ihess.com(2),hacscf001.ihess.com(3):/ex
port/e75


thanks for any help and for a fine mailing list...jeff davis, amerada
hess




































































------_=_NextPart_001_01C53715.1BF693DC
Content-Type: text/plain;
	name="exports.txt"
Content-Transfer-Encoding: base64
Content-Description: exports.txt
Content-Disposition: attachment;
	filename="exports.txt"

L2V4cG9ydC9lMSAgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4
cG9ydC9lMiAgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9y
dC9lMyAgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9l
NCAgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNSAg
ICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNiAgICAg
ICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNyAgICAgICoo
cncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lOCAgICAgICoocncs
bm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lOSAgICAgICoocncsbm9f
c3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lMTAgICAgICoocncsbm9fc3Vi
dHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lMTEgICAgICoocncsbm9fc3VidHJl
ZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lMTIgICAgICoocncsbm9fc3VidHJlZV9j
aGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lMTMgICAgICoocncsbm9fc3VidHJlZV9jaGVj
ayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lMTQgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxu
b19yb290X3NxdWFzaCkKL2V4cG9ydC9lMTUgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19y
b290X3NxdWFzaCkKL2V4cG9ydC9lMTYgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290
X3NxdWFzaCkKL2V4cG9ydC9lMTcgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3Nx
dWFzaCkKL2V4cG9ydC9lMTggICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFz
aCkKL2V4cG9ydC9lMTkgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkK
L2V4cG9ydC9lMjAgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4
cG9ydC9lMjEgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9y
dC9lMjIgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9l
MjMgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lMjQg
ICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lMjUgICAg
ICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lMjYgICAgICoo
cncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lMjcgICAgICoocncs
bm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lMjggICAgICoocncsbm9f
c3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lMjkgICAgICoocncsbm9fc3Vi
dHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lMzAgICAgICoocncsbm9fc3VidHJl
ZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lMzEgICAgICoocncsbm9fc3VidHJlZV9j
aGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lMzIgICAgICoocncsbm9fc3VidHJlZV9jaGVj
ayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lMzMgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxu
b19yb290X3NxdWFzaCkKL2V4cG9ydC9lMzQgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19y
b290X3NxdWFzaCkKL2V4cG9ydC9lMzUgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290
X3NxdWFzaCkKL2V4cG9ydC9lMzYgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3Nx
dWFzaCkKL2V4cG9ydC9lMzcgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFz
aCkKL2V4cG9ydC9lMzggICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkK
L2V4cG9ydC9lMzkgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4
cG9ydC9lNDAgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9y
dC9lNDEgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9l
NDIgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNDMg
ICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNDQgICAg
ICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNDUgICAgICoo
cncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNDYgICAgICoocncs
bm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNDcgICAgICoocncsbm9f
c3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNDggICAgICoocncsbm9fc3Vi
dHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNDkgICAgICoocncsbm9fc3VidHJl
ZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNTAgICAgICoocncsbm9fc3VidHJlZV9j
aGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNTEgICAgICoocncsbm9fc3VidHJlZV9jaGVj
ayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNTIgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxu
b19yb290X3NxdWFzaCkKL2V4cG9ydC9lNTMgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19y
b290X3NxdWFzaCkKL2V4cG9ydC9lNTQgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290
X3NxdWFzaCkKL2V4cG9ydC9lNTUgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3Nx
dWFzaCkKL2V4cG9ydC9lNTYgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFz
aCkKL2V4cG9ydC9lNTcgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkK
L2V4cG9ydC9lNTggICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4
cG9ydC9lNTkgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9y
dC9lNjAgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9l
NjEgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNjIg
ICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNjMgICAg
ICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNjQgICAgICoo
cncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNjUgICAgICoocncs
bm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNjYgICAgICoocncsbm9f
c3VidHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNjcgICAgICoocncsbm9fc3Vi
dHJlZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNjggICAgICoocncsbm9fc3VidHJl
ZV9jaGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNjkgICAgICoocncsbm9fc3VidHJlZV9j
aGVjayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNzAgICAgICoocncsbm9fc3VidHJlZV9jaGVj
ayxub19yb290X3NxdWFzaCkKL2V4cG9ydC9lNzEgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxu
b19yb290X3NxdWFzaCkKL2V4cG9ydC9lNzIgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19y
b290X3NxdWFzaCkKL2V4cG9ydC9lNzMgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290
X3NxdWFzaCkKL2V4cG9ydC9lNzQgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3Nx
dWFzaCkKL2V4cG9ydC9lNzUgICAgICoocncsbm9fc3VidHJlZV9jaGVjayxub19yb290X3NxdWFz
aCkK

------_=_NextPart_001_01C53715.1BF693DC--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
