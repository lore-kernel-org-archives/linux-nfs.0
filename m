From: "T. Horsnell" <tsh@mrc-lmb.cam.ac.uk>
Subject: fsid and stale-filehandle
Date: Thu, 21 Dec 2006 11:17:19 +0000 (GMT)
Message-ID: <E1GxLvL-0014jr-6F@alf1.lmb.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GxLw2-0003HQ-N6
	for nfs@lists.sourceforge.net; Thu, 21 Dec 2006 03:18:02 -0800
Received: from ppsw-9.csi.cam.ac.uk ([131.111.8.139])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GxLw1-0001dv-KU
	for nfs@lists.sourceforge.net; Thu, 21 Dec 2006 03:18:04 -0800
Received: from server1.mrc-lmb.cam.ac.uk ([131.111.85.23]:49023)
	by ppsw-9.csi.cam.ac.uk (ppsw.cam.ac.uk [131.111.8.139]:25)
	with esmtp id 1GxLvL-0006fG-Uw (Exim 4.63) for
	nfs@lists.sourceforge.net
	(return-path <tsh@mrc-lmb.cam.ac.uk>); Thu, 21 Dec 2006 11:17:20 +0000
Received: from alf1.lmb.internal ([10.1.0.1])
	by server1.mrc-lmb.cam.ac.uk with esmtp (Exim 4.10)
	id 1GxLvL-00025s-00
	for nfs@lists.sourceforge.net; Thu, 21 Dec 2006 11:17:19 +0000
Received: from tsh by alf1.lmb.internal with local (Exim 4.32)
	id 1GxLvL-0014jr-6F
	for nfs@lists.sourceforge.net; Thu, 21 Dec 2006 11:17:19 +0000
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I want to use the exports fsid= option to avoid 
'NFS stale-filehandle' errors, but have some questions.

1. If I use the fsid= option for any filesystem in
   my exportfs file, do I have to use it for *all*
   entries? If not, how do I avoid choosing an fsid
   which may be the same as one calculated by the system
   for those entries where I havent specified it?

2. Someone on the fedora list said that export options
   chosen for a filesystem with a particular fsid will
   apply to *all* clients using that fsid. So that if
   I have exports entries like:

   /filesystem client1(ro,fsid=10) client2(rw,fsid=10)

   either the filesystem will be exported ro to both
   clients, or it will be exported rw to both, (he
   couldnt say which would take precedence).
   Is this correct? Do I have to use a different fsid
   for each filesystem/client pair if I want different
   export options for them?

3. According to 'man stat', 'stat -f /filesystem' should show me
   the filesystem ID in hex of /filesystem, but all I get is
   zero for my exported fs's:

[root@dev1 ~]# stat -f /test10
  File: "/test10"
    ID: 0        Namelen: 255     Type: ext2/ext3
Block size: 4096       Fundamental block size: 4096
Blocks: Total: 8750377    Free: 8705316    Available: 8260818
Inodes: Total: 4447744    Free: 4447732
[root@dev1 ~]# stat -f /test11
  File: "/test11"
    ID: 0        Namelen: 255     Type: ext2/ext3
Block size: 4096       Fundamental block size: 4096
Blocks: Total: 2520130    Free: 1393714    Available: 1265697
Inodes: Total: 1281696    Free: 1106401
[root@dev1 ~]# 

[root@dev1 ~]# mount
/dev/hdb2 on / type ext3 (rw)
proc on /proc type proc (rw)
sysfs on /sys type sysfs (rw)
devpts on /dev/pts type devpts (rw,gid=5,mode=620)
tmpfs on /dev/shm type tmpfs (rw)
/dev/sda1 on /test10 type ext3 (rw)
/dev/sdb2 on /test11 type ext3 (rw)
none on /proc/sys/fs/binfmt_misc type binfmt_misc (rw)
sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
nfsd on /proc/fs/nfsd type nfsd (rw)
[root@dev1 ~]# 

[root@dev1 ~]# cat /etc/exports
/test10 fm*.lmb.internal(no_root_squash,fsid=1)
/test11 fm*.lmb.internal(no_root_squash,fsid=2)
[root@dev1 ~]# 

Any ideas anyone?

Cheers,
Terry.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
