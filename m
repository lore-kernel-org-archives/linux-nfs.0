From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: nfsd: Replace nfsd_sync() with vfs_fsync() and vfs_fsync_range()
Date: Fri, 29 Jan 2010 15:19:13 -0500
Message-ID: <1264796353.3644.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: "Dr. J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5249 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751857Ab0A2UTW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jan 2010 15:19:22 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Currently, the nfs server holds the inode->i_mutex across both the
filemap_write_and_wait() call and the fsync() call itself. However we know
that filemap_write_and_wait() is already safe against livelocks, so we only
need to hold the mutex across the fsync() call.

Fix this by reusing vfs_fsync(), which already does the right thing.
Also make sure that we use vfs_fsync_range() in the COMMIT operation, to
improve the efficiency for clients that do specify a range.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfsd/vfs.c |   58 +++++++++++++++++++++------------------------------------
 1 files changed, 21 insertions(+), 37 deletions(-)


diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index c194793..e4568d6 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -769,40 +769,17 @@ nfsd_close(struct file *filp)
 }
 
 /*
- * Sync a file
- * As this calls fsync (not fdatasync) there is no need for a write_inode
- * after it.
+ * Sync a directory
+ * returns 0 if the directory had no fsync method
  */
-static inline int nfsd_dosync(struct file *filp, struct dentry *dp,
-			      const struct file_operations *fop)
-{
-	struct inode *inode = dp->d_inode;
-	int (*fsync) (struct file *, struct dentry *, int);
-	int err;
-
-	err = filemap_write_and_wait(inode->i_mapping);
-	if (err == 0 && fop && (fsync = fop->fsync))
-		err = fsync(filp, dp, 0);
-	return err;
-}
-
-static int
-nfsd_sync(struct file *filp)
-{
-        int err;
-	struct inode *inode = filp->f_path.dentry->d_inode;
-	dprintk("nfsd: sync file %s\n", filp->f_path.dentry->d_name.name);
-	mutex_lock(&inode->i_mutex);
-	err=nfsd_dosync(filp, filp->f_path.dentry, filp->f_op);
-	mutex_unlock(&inode->i_mutex);
-
-	return err;
-}
-
 int
 nfsd_sync_dir(struct dentry *dp)
 {
-	return nfsd_dosync(NULL, dp, dp->d_inode->i_fop);
+	int err;
+
+	dprintk("nfsd: sync directory %s\n", dp->d_name.name);
+	err = vfs_fsync(NULL, dp, 0);
+	return (err != -EINVAL) ? err : 0;
 }
 
 /*
@@ -1008,7 +985,9 @@ static int wait_for_concurrent_writes(struct file *file)
 
 	if (inode->i_state & I_DIRTY) {
 		dprintk("nfsd: write sync %d\n", task_pid_nr(current));
-		err = nfsd_sync(file);
+		err = vfs_fsync(file, file->f_path.dentry, 0);
+		if (err == -EINVAL)
+			err = 0;
 	}
 	last_ino = inode->i_ino;
 	last_dev = inode->i_sb->s_dev;
@@ -1156,8 +1135,6 @@ out:
 #ifdef CONFIG_NFSD_V3
 /*
  * Commit all pending writes to stable storage.
- * Strictly speaking, we could sync just the indicated file region here,
- * but there's currently no way we can ask the VFS to do so.
  *
  * Unfortunately we cannot lock the file to make sure we return full WCC
  * data to the client, as locking happens lower down in the filesystem.
@@ -1176,11 +1153,18 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (err)
 		return err;
 	if (EX_ISSYNC(fhp->fh_export)) {
-		if (file->f_op && file->f_op->fsync) {
-			err = nfserrno(nfsd_sync(file));
-		} else {
+		loff_t end = LLONG_MAX;
+		int err2;
+		
+		if (count != 0)
+			end = offset + count;
+		err2 = vfs_fsync_range(file, file->f_path.dentry,
+				offset, end, 0);
+
+		if (err2 != -EINVAL)
+			err = nfserrno(err2);
+		else
 			err = nfserr_notsupp;
-		}
 	}
 
 	nfsd_close(file);

