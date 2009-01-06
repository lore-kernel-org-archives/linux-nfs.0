From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd stuckage
Date: Tue, 6 Jan 2009 18:02:44 -0500
Message-ID: <20090106230244.GB13785@fieldses.org>
References: <20090106145612.d4d9948d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Neil Brown <neilb@suse.de>, Eric Sesterhenn <snakebyte@gmx.de>,
	hch@lst.de
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:40749 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751136AbZAFXCr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2009 18:02:47 -0500
In-Reply-To: <20090106145612.d4d9948d.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2009 at 02:56:12PM -0800, Andrew Morton wrote:
> 
> I just built current mainline plus the just-sent 266 -mm patches.
> 
> The machine failed to power off when hit with `halt -pfn'.  dmesg output:

Christoph, can you live with this for now?

--b.

commit 33e3950dc2eae7484e79685083c304d93013e3ec
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Jan 6 13:37:03 2009 -0500

    nfsd: fix double-locks of directory mutex
    
    A number of nfsd operations depend on the i_mutex to cover more code
    than just the fsync, so the approach of 4c728ef583b3d8 "add a vfs_fsync
    helper" doesn't work for nfsd.  Revert the parts of those patches that
    touch nfsd, and remove the logic from vfs_nfsd that was needed only for
    the special case of nfsd.
    
    Reported-by: Eric Sesterhenn <snakebyte@gmx.de>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 44aa92a..6e50aaa 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -744,16 +744,44 @@ nfsd_close(struct file *filp)
 	fput(filp);
 }
 
+/*
+ * Sync a file
+ * As this calls fsync (not fdatasync) there is no need for a write_inode
+ * after it.
+ */
+static inline int nfsd_dosync(struct file *filp, struct dentry *dp,
+			      const struct file_operations *fop)
+{
+	struct inode *inode = dp->d_inode;
+	int (*fsync) (struct file *, struct dentry *, int);
+	int err;
+
+	err = filemap_fdatawrite(inode->i_mapping);
+	if (err == 0 && fop && (fsync = fop->fsync))
+		err = fsync(filp, dp, 0);
+	if (err == 0)
+		err = filemap_fdatawait(inode->i_mapping);
+
+	return err;
+}
+
 static int
 nfsd_sync(struct file *filp)
 {
-	return vfs_fsync(filp, filp->f_path.dentry, 0);
+        int err;
+	struct inode *inode = filp->f_path.dentry->d_inode;
+	dprintk("nfsd: sync file %s\n", filp->f_path.dentry->d_name.name);
+	mutex_lock(&inode->i_mutex);
+	err=nfsd_dosync(filp, filp->f_path.dentry, filp->f_op);
+	mutex_unlock(&inode->i_mutex);
+
+	return err;
 }
 
 int
-nfsd_sync_dir(struct dentry *dentry)
+nfsd_sync_dir(struct dentry *dp)
 {
-	return vfs_fsync(NULL, dentry, 0);
+	return nfsd_dosync(NULL, dp, dp->d_inode->i_fop);
 }
 
 /*
diff --git a/fs/sync.c b/fs/sync.c
index 0921d6d..8e0a656 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -83,10 +83,6 @@ int file_fsync(struct file *filp, struct dentry *dentry, int datasync)
  *
  * Write back data and metadata for @file to disk.  If @datasync is
  * set only metadata needed to access modified file data is written.
- *
- * In case this function is called from nfsd @file may be %NULL and
- * only @dentry is set.  This can only happen when the filesystem
- * implements the export_operations API.
  */
 int vfs_fsync(struct file *file, struct dentry *dentry, int datasync)
 {
@@ -94,18 +90,8 @@ int vfs_fsync(struct file *file, struct dentry *dentry, int datasync)
 	struct address_space *mapping;
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
+	mapping = file->f_mapping;
+	fop = file->f_op;
 
 	if (!fop || !fop->fsync) {
 		ret = -EINVAL;
