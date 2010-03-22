From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/2] sanitize vfs_fsync calling conventions
Date: Mon, 22 Mar 2010 17:32:25 +0100
Message-ID: <20100322163225.GB1307@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: viro@zeniv.linux.org.uk
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:52014 "EHLO verein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755169Ab0CVQc1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Mar 2010 12:32:27 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the last user passing a NULL file pointer is gone we can remove
the redundant dentry argument and associated hacks inside vfs_fsynmc_range.

The next step will be removig the dentry argument from ->fsync, but given
the luck with the last round of method prototype changes I'd rather
defer this until after the main merge window.

Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/drivers/block/loop.c
===================================================================
--- linux-2.6.orig/drivers/block/loop.c	2010-03-22 15:12:51.254003683 +0100
+++ linux-2.6/drivers/block/loop.c	2010-03-22 15:34:58.570004102 +0100
@@ -484,7 +484,7 @@ static int do_bio_filebacked(struct loop
 				goto out;
 			}
 
-			ret = vfs_fsync(file, file->f_path.dentry, 0);
+			ret = vfs_fsync(file, 0);
 			if (unlikely(ret)) {
 				ret = -EIO;
 				goto out;
@@ -494,7 +494,7 @@ static int do_bio_filebacked(struct loop
 		ret = lo_send(lo, bio, pos);
 
 		if (barrier && !ret) {
-			ret = vfs_fsync(file, file->f_path.dentry, 0);
+			ret = vfs_fsync(file, 0);
 			if (unlikely(ret))
 				ret = -EIO;
 		}
Index: linux-2.6/drivers/md/bitmap.c
===================================================================
--- linux-2.6.orig/drivers/md/bitmap.c	2010-03-22 15:12:51.265004591 +0100
+++ linux-2.6/drivers/md/bitmap.c	2010-03-22 15:34:58.571004102 +0100
@@ -1692,7 +1692,7 @@ int bitmap_create(mddev_t *mddev)
 		 * and bypass the page cache, we must sync the file
 		 * first.
 		 */
-		vfs_fsync(file, file->f_dentry, 1);
+		vfs_fsync(file, 1);
 	}
 	/* read superblock from bitmap file (this sets mddev->bitmap_info.chunksize) */
 	if (!mddev->bitmap_info.external)
Index: linux-2.6/drivers/usb/gadget/storage_common.c
===================================================================
--- linux-2.6.orig/drivers/usb/gadget/storage_common.c	2010-03-22 15:12:51.283023099 +0100
+++ linux-2.6/drivers/usb/gadget/storage_common.c	2010-03-22 15:34:58.582003962 +0100
@@ -654,7 +654,7 @@ static int fsg_lun_fsync_sub(struct fsg_
 
 	if (curlun->ro || !filp)
 		return 0;
-	return vfs_fsync(filp, filp->f_path.dentry, 1);
+	return vfs_fsync(filp, 1);
 }
 
 static void store_cdrom_address(u8 *dest, int msf, u32 addr)
Index: linux-2.6/fs/coda/file.c
===================================================================
--- linux-2.6.orig/fs/coda/file.c	2010-03-22 15:12:51.292004381 +0100
+++ linux-2.6/fs/coda/file.c	2010-03-22 15:34:58.588006337 +0100
@@ -216,7 +216,7 @@ int coda_fsync(struct file *coda_file, s
 	BUG_ON(!cfi || cfi->cfi_magic != CODA_MAGIC);
 	host_file = cfi->cfi_container;
 
-	err = vfs_fsync(host_file, host_file->f_path.dentry, datasync);
+	err = vfs_fsync(host_file, datasync);
 	if ( !err && !datasync ) {
 		lock_kernel();
 		err = venus_fsync(coda_inode->i_sb, coda_i2f(coda_inode));
Index: linux-2.6/fs/ecryptfs/file.c
===================================================================
--- linux-2.6.orig/fs/ecryptfs/file.c	2010-03-22 15:12:51.307254486 +0100
+++ linux-2.6/fs/ecryptfs/file.c	2010-03-22 15:34:58.591067379 +0100
@@ -275,9 +275,7 @@ static int ecryptfs_release(struct inode
 static int
 ecryptfs_fsync(struct file *file, struct dentry *dentry, int datasync)
 {
-	return vfs_fsync(ecryptfs_file_to_lower(file),
-			 ecryptfs_dentry_to_lower(dentry),
-			 datasync);
+	return vfs_fsync(ecryptfs_file_to_lower(file), datasync);
 }
 
 static int ecryptfs_fasync(int fd, struct file *file, int flag)
Index: linux-2.6/fs/nfsd/nfs4recover.c
===================================================================
--- linux-2.6.orig/fs/nfsd/nfs4recover.c	2010-03-22 15:33:24.520253578 +0100
+++ linux-2.6/fs/nfsd/nfs4recover.c	2010-03-22 15:34:58.594005918 +0100
@@ -156,7 +156,7 @@ out_unlock:
 	mutex_unlock(&rec_file->f_path.dentry->d_inode->i_mutex);
 	if (status == 0) {
 		clp->cl_firststate = 1;
-		vfs_fsync(rec_file, rec_file->f_path.dentry, 0);
+		vfs_fsync(rec_file, 0);
 	}
 	nfs4_reset_creds(original_cred);
 	dprintk("NFSD: nfsd4_create_clid_dir returns %d\n", status);
@@ -285,7 +285,7 @@ nfsd4_remove_clid_dir(struct nfs4_client
 	status = nfsd4_unlink_clid_dir(clp->cl_recdir, HEXDIR_LEN-1);
 	nfs4_reset_creds(original_cred);
 	if (status == 0)
-		vfs_fsync(rec_file, rec_file->f_path.dentry, 0);
+		vfs_fsync(rec_file, 0);
 	mnt_drop_write(rec_file->f_path.mnt);
 out:
 	if (status)
@@ -322,7 +322,7 @@ nfsd4_recdir_purge_old(void) {
 		goto out;
 	status = nfsd4_list_rec_dir(rec_file->f_path.dentry, purge_old);
 	if (status == 0)
-		vfs_fsync(rec_file, rec_file->f_path.dentry, 0);
+		vfs_fsync(rec_file, 0);
 	mnt_drop_write(rec_file->f_path.mnt);
 out:
 	if (status)
Index: linux-2.6/fs/nfsd/vfs.c
===================================================================
--- linux-2.6.orig/fs/nfsd/vfs.c	2010-03-22 15:12:51.330254416 +0100
+++ linux-2.6/fs/nfsd/vfs.c	2010-03-22 15:34:58.597006267 +0100
@@ -997,7 +997,7 @@ static int wait_for_concurrent_writes(st
 
 	if (inode->i_state & I_DIRTY) {
 		dprintk("nfsd: write sync %d\n", task_pid_nr(current));
-		err = vfs_fsync(file, file->f_path.dentry, 0);
+		err = vfs_fsync(file, 0);
 	}
 	last_ino = inode->i_ino;
 	last_dev = inode->i_sb->s_dev;
@@ -1172,8 +1172,7 @@ nfsd_commit(struct svc_rqst *rqstp, stru
 	if (err)
 		goto out;
 	if (EX_ISSYNC(fhp->fh_export)) {
-		int err2 = vfs_fsync_range(file, file->f_path.dentry,
-				offset, end, 0);
+		int err2 = vfs_fsync_range(file, offset, end, 0);
 
 		if (err2 != -EINVAL)
 			err = nfserrno(err2);
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h	2010-03-22 15:12:51.350004521 +0100
+++ linux-2.6/include/linux/fs.h	2010-03-22 15:34:58.604005918 +0100
@@ -2087,9 +2087,9 @@ extern int __filemap_fdatawrite_range(st
 extern int filemap_fdatawrite_range(struct address_space *mapping,
 				loff_t start, loff_t end);
 
-extern int vfs_fsync_range(struct file *file, struct dentry *dentry,
-			   loff_t start, loff_t end, int datasync);
-extern int vfs_fsync(struct file *file, struct dentry *dentry, int datasync);
+extern int vfs_fsync_range(struct file *file, loff_t start, loff_t end,
+			   int datasync);
+extern int vfs_fsync(struct file *file, int datasync);
 extern int generic_write_sync(struct file *file, loff_t pos, loff_t count);
 extern void sync_supers(void);
 extern void emergency_sync(void);
Index: linux-2.6/mm/msync.c
===================================================================
--- linux-2.6.orig/mm/msync.c	2010-03-22 15:12:51.364004661 +0100
+++ linux-2.6/mm/msync.c	2010-03-22 15:34:58.609005639 +0100
@@ -82,7 +82,7 @@ SYSCALL_DEFINE3(msync, unsigned long, st
 				(vma->vm_flags & VM_SHARED)) {
 			get_file(file);
 			up_read(&mm->mmap_sem);
-			error = vfs_fsync(file, file->f_path.dentry, 0);
+			error = vfs_fsync(file, 0);
 			fput(file);
 			if (error || start >= end)
 				goto out;
Index: linux-2.6/fs/sync.c
===================================================================
--- linux-2.6.orig/fs/sync.c	2010-03-22 15:12:51.340010737 +0100
+++ linux-2.6/fs/sync.c	2010-03-22 15:34:58.611005499 +0100
@@ -188,7 +188,6 @@ EXPORT_SYMBOL(file_fsync);
 /**
  * vfs_fsync_range - helper to sync a range of data & metadata to disk
  * @file:		file to sync
- * @dentry:		dentry of @file
  * @start:		offset in bytes of the beginning of data range to sync
  * @end:		offset in bytes of the end of data range (inclusive)
  * @datasync:		perform only datasync
@@ -196,32 +195,13 @@ EXPORT_SYMBOL(file_fsync);
  * Write back data in range @start..@end and metadata for @file to disk.  If
  * @datasync is set only metadata needed to access modified file data is
  * written.
- *
- * In case this function is called from nfsd @file may be %NULL and
- * only @dentry is set.  This can only happen when the filesystem
- * implements the export_operations API.
  */
-int vfs_fsync_range(struct file *file, struct dentry *dentry, loff_t start,
-		    loff_t end, int datasync)
+int vfs_fsync_range(struct file *file, loff_t start, loff_t end, int datasync)
 {
-	const struct file_operations *fop;
-	struct address_space *mapping;
+	struct address_space *mapping = file->f_mapping;
 	int err, ret;
 
-	/*
-	 * Get mapping and operations from the file in case we have
-	 * as file, or get the default values for them in case we
-	 * don't have a struct file available.  Damn nfsd..
-	 */
-	if (file) {
-		mapping = file->f_mapping;
-		fop = file->f_op;
-	} else {
-		mapping = dentry->d_inode->i_mapping;
-		fop = dentry->d_inode->i_fop;
-	}
-
-	if (!fop || !fop->fsync) {
+	if (!file->f_op || !file->f_op->fsync) {
 		ret = -EINVAL;
 		goto out;
 	}
@@ -233,7 +213,7 @@ int vfs_fsync_range(struct file *file, s
 	 * livelocks in fsync_buffers_list().
 	 */
 	mutex_lock(&mapping->host->i_mutex);
-	err = fop->fsync(file, dentry, datasync);
+	err = file->f_op->fsync(file, file->f_path.dentry, datasync);
 	if (!ret)
 		ret = err;
 	mutex_unlock(&mapping->host->i_mutex);
@@ -246,19 +226,14 @@ EXPORT_SYMBOL(vfs_fsync_range);
 /**
  * vfs_fsync - perform a fsync or fdatasync on a file
  * @file:		file to sync
- * @dentry:		dentry of @file
  * @datasync:		only perform a fdatasync operation
  *
  * Write back data and metadata for @file to disk.  If @datasync is
  * set only metadata needed to access modified file data is written.
- *
- * In case this function is called from nfsd @file may be %NULL and
- * only @dentry is set.  This can only happen when the filesystem
- * implements the export_operations API.
  */
-int vfs_fsync(struct file *file, struct dentry *dentry, int datasync)
+int vfs_fsync(struct file *file, int datasync)
 {
-	return vfs_fsync_range(file, dentry, 0, LLONG_MAX, datasync);
+	return vfs_fsync_range(file, 0, LLONG_MAX, datasync);
 }
 EXPORT_SYMBOL(vfs_fsync);
 
@@ -269,7 +244,7 @@ static int do_fsync(unsigned int fd, int
 
 	file = fget(fd);
 	if (file) {
-		ret = vfs_fsync(file, file->f_path.dentry, datasync);
+		ret = vfs_fsync(file, datasync);
 		fput(file);
 	}
 	return ret;
@@ -297,8 +272,7 @@ int generic_write_sync(struct file *file
 {
 	if (!(file->f_flags & O_DSYNC) && !IS_SYNC(file->f_mapping->host))
 		return 0;
-	return vfs_fsync_range(file, file->f_path.dentry, pos,
-			       pos + count - 1,
+	return vfs_fsync_range(file, pos, pos + count - 1,
 			       (file->f_flags & __O_SYNC) ? 0 : 1);
 }
 EXPORT_SYMBOL(generic_write_sync);
