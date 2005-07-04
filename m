From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 002 of 19] nfsd4: fix sync'ing of recovery directory
Date: Mon, 04 Jul 2005 11:01:41 +1000
Message-ID: <E1DpFLB-0007G8-Q9@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFM9-0001lS-OU
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:41 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DpFM9-0006N6-2f
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:41 -0700
To: Andrew Morton <akpm@osdl.org>
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


We need to fsync the recovery directory after writing to it, but we weren't
doing this correctly.  (For example, we weren't taking the i_sem when calling
->fsync().)

Just reuse the existing nfsd fsync code instead.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4recover.c     |   29 ++++++++---------------------
 ./fs/nfsd/vfs.c             |    2 +-
 ./include/linux/nfsd/nfsd.h |    1 +
 3 files changed, 10 insertions(+), 22 deletions(-)

diff ./fs/nfsd/nfs4recover.c~current~ ./fs/nfsd/nfs4recover.c
--- ./fs/nfsd/nfs4recover.c~current~	2005-07-04 10:57:51.000000000 +1000
+++ ./fs/nfsd/nfs4recover.c	2005-07-04 10:57:51.000000000 +1000
@@ -119,25 +119,12 @@ out:
 	return status;
 }
 
-static int
-nfsd4_rec_fsync(struct dentry *dentry)
+static void
+nfsd4_sync_rec_dir(void)
 {
-	struct file *filp;
-	int status = nfs_ok;
-
-	dprintk("NFSD: nfs4_fsync_rec_dir\n");
-	filp = dentry_open(dget(dentry), mntget(rec_dir.mnt), O_RDWR);
-	if (IS_ERR(filp)) {
-		status = PTR_ERR(filp);
-		goto out;
-	}
-	if (filp->f_op && filp->f_op->fsync)
-		status = filp->f_op->fsync(filp, filp->f_dentry, 0);
-	fput(filp);
-out:
-	if (status)
-		printk("nfsd4: unable to sync recovery directory\n");
-	return status;
+	down(&rec_dir.dentry->d_inode->i_sem);
+	nfsd_sync_dir(rec_dir.dentry);
+	up(&rec_dir.dentry->d_inode->i_sem);
 }
 
 int
@@ -176,7 +163,7 @@ out_unlock:
 	up(&rec_dir.dentry->d_inode->i_sem);
 	if (status == 0) {
 		clp->cl_firststate = 1;
-		status = nfsd4_rec_fsync(rec_dir.dentry);
+		nfsd4_sync_rec_dir();
 	}
 	nfs4_reset_user(uid, gid);
 	dprintk("NFSD: nfsd4_create_clid_dir returns %d\n", status);
@@ -331,7 +318,7 @@ nfsd4_remove_clid_dir(struct nfs4_client
 	status = nfsd4_unlink_clid_dir(clp->cl_recdir, HEXDIR_LEN-1);
 	nfs4_reset_user(uid, gid);
 	if (status == 0)
-		status = nfsd4_rec_fsync(rec_dir.dentry);
+		nfsd4_sync_rec_dir();
 	if (status)
 		printk("NFSD: Failed to remove expired client state directory"
 				" %.*s\n", HEXDIR_LEN, clp->cl_recdir);
@@ -362,7 +349,7 @@ nfsd4_recdir_purge_old(void) {
 		return;
 	status = nfsd4_list_rec_dir(rec_dir.dentry, purge_old);
 	if (status == 0)
-		status = nfsd4_rec_fsync(rec_dir.dentry);
+		nfsd4_sync_rec_dir();
 	if (status)
 		printk("nfsd4: failed to purge old clients from recovery"
 			" directory %s\n", rec_dir.dentry->d_name.name);

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2005-07-04 10:57:51.000000000 +1000
+++ ./fs/nfsd/vfs.c	2005-07-04 10:57:51.000000000 +1000
@@ -733,7 +733,7 @@ nfsd_sync(struct file *filp)
 	up(&inode->i_sem);
 }
 
-static void
+void
 nfsd_sync_dir(struct dentry *dp)
 {
 	nfsd_dosync(NULL, dp, dp->d_inode->i_fop);

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2005-07-04 10:57:51.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2005-07-04 10:57:51.000000000 +1000
@@ -124,6 +124,7 @@ int		nfsd_statfs(struct svc_rqst *, stru
 
 int		nfsd_notify_change(struct inode *, struct iattr *);
 int		nfsd_permission(struct svc_export *, struct dentry *, int);
+void		nfsd_sync_dir(struct dentry *dp);
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 #ifdef CONFIG_NFSD_V2_ACL


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
