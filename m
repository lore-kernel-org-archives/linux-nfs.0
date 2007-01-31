From: Dan Goetzman <dan_goetzman@bmc.com>
Subject: NFS "Not a directory" problem
Date: Wed, 31 Jan 2007 15:53:38 -0600
Message-ID: <45C10FE2.9060606@bmc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCNOl-0001Wn-Nd
	for nfs@lists.sourceforge.net; Wed, 31 Jan 2007 13:53:48 -0800
Received: from sky.bmc.com ([198.207.223.240] helo=babbler.bmc.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HCNOm-0005Co-Cx
	for nfs@lists.sourceforge.net; Wed, 31 Jan 2007 13:53:49 -0800
Received: from color.bmc.com (houcfs2.bmc.com [172.19.17.2])
	by babbler.bmc.com (Postfix) with ESMTP id 0010A1307ED
	for <nfs@lists.sourceforge.net>; Wed, 31 Jan 2007 15:53:38 -0600 (CST)
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

Linux client = 2.6.19-1.2895.fc6
NFS server = Tru64 5.1B-2 (aka 5.1 + PK4)

NFS mount is NFSV3 over UDP or TCP. NFSV2 works OK, NFSV3 has the 
following problem;

$ cd /mnt/
$ cd fvance
$ cd src
 returns "*Not a directory*" error message.
 src is simply a directory under "fvance". Normally a umount/mount cycle 
will remove the problem and then all is well.

Turning debug on with "*rpcdebug -m nfs -s all*" and I get the following 
in messages;

*When it works;*
> Jan 31 15:30:40 rds-icap kernel: NFS:      
> nfs_updatepage(HISTFILES/.sh_history-rds-icap.bmc.com 8@1542)
> Jan 31 15:30:40 rds-icap kernel: NFS:      nfs_updatepage returns 0 
> (isize 1550)
> Jan 31 15:30:40 rds-icap kernel: NFS: permission(0:25/8), mask=0x1, res=0
> Jan 31 15:30:40 rds-icap kernel: NFS: revalidating (0:25/656353)
> Jan 31 15:30:40 rds-icap kernel: NFS call  getattr
> Jan 31 15:30:40 rds-icap kernel: NFS reply getattr: 0
> Jan 31 15:30:40 rds-icap kernel: NFS: nfs_update_inode(0:25/656353 
> ct=1 info=0x6)
> Jan 31 15:30:40 rds-icap kernel: NFS: (0:25/656353) revalidation complete
> Jan 31 15:30:40 rds-icap kernel: NFS: 
> nfs_lookup_revalidate(fvance/src) is valid
> Jan 31 15:30:40 rds-icap kernel: NFS: permission(0:25/656353), 
> mask=0x1, res=0
*When it fails;*
> Jan 31 15:25:31 rds-icap kernel: NFS:      
> nfs_updatepage(HISTFILES/.sh_history-rds-icap.bmc.com 8@1454)
> Jan 31 15:25:31 rds-icap kernel: NFS:      nfs_updatepage returns 0 
> (isize 1462)
> Jan 31 15:25:31 rds-icap kernel: NFS call  access
> Jan 31 15:25:31 rds-icap kernel: NFS: nfs_update_inode(0:26/8 ct=1 
> info=0x6)
> Jan 31 15:25:31 rds-icap kernel: NFS reply access: 0
> Jan 31 15:25:31 rds-icap kernel: NFS: permission(0:26/8), mask=0x1, res=0
> Jan 31 15:25:31 rds-icap kernel: NFS: 
> nfs_lookup_revalidate(fvance/src) is valid
> Jan 31 15:25:31 rds-icap kernel: NFS call  lookup src
> Jan 31 15:25:31 rds-icap kernel: NFS reply lookup: 0
> Jan 31 15:25:31 rds-icap kernel: --> nfs_xdev_get_sb()
> Jan 31 15:25:31 rds-icap kernel: --> 
> nfs_clone_server(,ffffffffcc98e21e:0,)
> Jan 31 15:25:31 rds-icap kernel: --> nfs_probe_fsinfo()
> Jan 31 15:25:31 rds-icap kernel: NFS call  fsinfo
> Jan 31 15:25:31 rds-icap kernel: NFS reply fsinfo: 0
> Jan 31 15:25:31 rds-icap kernel: NFS call  pathconf
> Jan 31 15:25:31 rds-icap kernel: NFS reply pathconf: 0
> Jan 31 15:25:31 rds-icap kernel: <-- nfs_probe_fsinfo() = 0
> Jan 31 15:25:31 rds-icap kernel: Cloned FSID: ffffffffcc98e21e:0
> Jan 31 15:25:31 rds-icap kernel: <-- nfs_clone_server() = db5db8c0
> Jan 31 15:25:31 rds-icap kernel: --> nfs_free_server()
> Jan 31 15:25:31 rds-icap kernel: --> nfs_put_client({3})
> Jan 31 15:25:31 rds-icap kernel: <-- nfs_free_server()
> Jan 31 15:25:31 rds-icap kernel: do_proc_get_root: call  fsinfo
> Jan 31 15:25:31 rds-icap kernel: do_proc_get_root: reply fsinfo: 0
> Jan 31 15:25:31 rds-icap kernel: NFS: nfs_update_inode(0:26/656353 
> ct=2 info=0x6)
> Jan 31 15:25:31 rds-icap kernel: NFS: nfs_fhget(0:26/656353 ct=2)
> Jan 31 15:25:31 rds-icap kernel: <-- nfs_xdev_get_sb() = 0
Note,
inode for parent of fvance = 2
inode for fvance is 8
inode for src is 656353

Anyone help me figure out what is going wrong here?
-Dan Goetzman


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
