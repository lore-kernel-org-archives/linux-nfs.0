From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 8 - switch knfsd to vfs_read/vfs_write
Date: Wed, 16 Oct 2002 16:03:15 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E181hH1-0000JL-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181hHD-0002mo-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 23:03:27 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 16 Oct 2002 16:03:17 +1000
To: Linus Torvalds <torvalds@transmeta.com>
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


### Comments for ChangeSet

From: Christoph Hellwig <hch@sgi.com>

Switch knfsd to vfs_read/vfs_write to work on aio-only filesystems.
This also gets stuff like the LSM checks and mandatory lock checking
for free.



 ----------- Diffstat output ------------
 ./fs/nfsd/vfs.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

--- ./fs/nfsd/vfs.c	2002/10/16 04:47:13	1.2
+++ ./fs/nfsd/vfs.c	2002/10/16 04:47:20	1.3
@@ -589,8 +589,6 @@ nfsd_read(struct svc_rqst *rqstp, struct
 	if (err)
 		goto out;
 	err = nfserr_perm;
-	if (!file.f_op->read)
-		goto out_close;
 	inode = file.f_dentry->d_inode;
 #ifdef MSNFS
 	if ((fhp->fh_export->ex_flags & NFSEXP_MSNFS) &&
@@ -602,11 +600,10 @@ nfsd_read(struct svc_rqst *rqstp, struct
 	ra = nfsd_get_raparms(inode->i_dev, inode->i_ino);
 	if (ra)
 		file.f_ra = ra->p_ra;
-	file.f_pos = offset;
 
 	oldfs = get_fs();
 	set_fs(KERNEL_DS);
-	err = file.f_op->read(&file, buf, *count, &file.f_pos);
+	err = vfs_read(&file, buf, *count, &offset);
 	set_fs(oldfs);
 
 	/* Write back readahead params */
@@ -648,8 +645,7 @@ nfsd_write(struct svc_rqst *rqstp, struc
 	if (!cnt)
 		goto out_close;
 	err = nfserr_perm;
-	if (!file.f_op->write)
-		goto out_close;
+
 #ifdef MSNFS
 	if ((fhp->fh_export->ex_flags & NFSEXP_MSNFS) &&
 		(!lock_may_write(file.f_dentry->d_inode, offset, cnt)))
@@ -679,11 +675,9 @@ nfsd_write(struct svc_rqst *rqstp, struc
 	if (stable && !EX_WGATHER(exp))
 		file.f_flags |= O_SYNC;
 
-	file.f_pos = offset;		/* set write offset */
-
 	/* Write the data. */
 	oldfs = get_fs(); set_fs(KERNEL_DS);
-	err = file.f_op->write(&file, buf, cnt, &file.f_pos);
+	err = vfs_write(&file, buf, cnt, &offset);
 	if (err >= 0)
 		nfsdstats.io_write += cnt;
 	set_fs(oldfs);


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
