From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/2] nfsd: use vfs_fsync for non-directories
Date: Fri, 25 Dec 2009 17:45:13 +0100
Message-ID: <20091225164513.GB4578@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: bfields@fieldses.org, viro@zeniv.linux.org.uk, jack@suse.cz
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of opencoding the fsync calling sequence use vfs_fsync.  This also
gets rid of the useless i_mutex over the data writeout.

Consolidate the remaining special code for syncing directories and document
it's quirks.

Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/nfsd/vfs.c
===================================================================
--- linux-2.6.orig/fs/nfsd/vfs.c	2009-12-25 17:31:50.760254239 +0100
+++ linux-2.6/fs/nfsd/vfs.c	2009-12-25 17:39:17.244005992 +0100
@@ -769,40 +769,25 @@ nfsd_close(struct file *filp)
 }
 
 /*
- * Sync a file
- * As this calls fsync (not fdatasync) there is no need for a write_inode
- * after it.
+ * Sync a directory to disk.
+ *
+ * We can't just call vfs_fsync because our requirements are slightly odd:
+ *
+ *  a) we do not have a file struct available
+ *  b) we expect to have i_mutex already held by the caller
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
+int
+nfsd_sync_dir(struct dentry *dentry)
 {
-        int err;
-	struct inode *inode = filp->f_path.dentry->d_inode;
-	dprintk("nfsd: sync file %s\n", filp->f_path.dentry->d_name.name);
-	mutex_lock(&inode->i_mutex);
-	err=nfsd_dosync(filp, filp->f_path.dentry, filp->f_op);
-	mutex_unlock(&inode->i_mutex);
+	struct inode *inode = dentry->d_inode;
+	int error;
 
-	return err;
-}
+	WARN_ON(!mutex_is_locked(&inode->i_mutex));
 
-int
-nfsd_sync_dir(struct dentry *dp)
-{
-	return nfsd_dosync(NULL, dp, dp->d_inode->i_fop);
+	error = filemap_write_and_wait(inode->i_mapping);
+	if (!error && inode->i_fop->fsync)
+		error = inode->i_fop->fsync(NULL, dentry, 0);
+	return error;
 }
 
 /*
@@ -1008,7 +993,7 @@ static int wait_for_concurrent_writes(st
 
 	if (inode->i_state & I_DIRTY) {
 		dprintk("nfsd: write sync %d\n", task_pid_nr(current));
-		err = nfsd_sync(file);
+		err = vfs_fsync(file, file->f_path.dentry, 0);
 	}
 	last_ino = inode->i_ino;
 	last_dev = inode->i_sb->s_dev;
@@ -1177,7 +1162,7 @@ nfsd_commit(struct svc_rqst *rqstp, stru
 		return err;
 	if (EX_ISSYNC(fhp->fh_export)) {
 		if (file->f_op && file->f_op->fsync) {
-			err = nfserrno(nfsd_sync(file));
+			err = nfserrno(vfs_fsync(file, file->f_path.dentry, 0));
 		} else {
 			err = nfserr_notsupp;
 		}
