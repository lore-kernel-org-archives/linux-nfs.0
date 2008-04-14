From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/24] NFS: Use NFSDBG_FILE for all fops
Date: Mon, 14 Apr 2008 12:26:46 -0400
Message-ID: <20080414162646.12741.47258.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:47714 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756068AbYDNQ1J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 12:27:09 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: some fops use NFSDBG_FILE, some use NFSDBG_VFS.  Let's use
NFSDBG_FILE for all fops, and consistently report file names instead
of inode numbers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/dir.c    |   10 +++++----
 fs/nfs/direct.c |    4 ++--
 fs/nfs/file.c   |   60 +++++++++++++++++++++++++++++++++++--------------------
 3 files changed, 45 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index b9f1a72..9f52a8c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -134,7 +134,7 @@ nfs_opendir(struct inode *inode, struct file *filp)
 	struct dentry *dentry = filp->f_path.dentry;
 	int res;
 
-	dfprintk(VFS, "NFS: open dir(%s/%s)\n",
+	dfprintk(FILE, "NFS: open dir(%s/%s)\n",
 			dentry->d_parent->d_name.name,
 			dentry->d_name.name);
 
@@ -532,7 +532,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	struct nfs_fattr fattr;
 	long		res;
 
-	dfprintk(VFS, "NFS: readdir(%s/%s) starting at cookie %Lu\n",
+	dfprintk(FILE, "NFS: readdir(%s/%s) starting at cookie %Lu\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
 			(long long)filp->f_pos);
 	nfs_inc_stats(inode, NFSIOS_VFSGETDENTS);
@@ -599,7 +599,7 @@ out:
 	unlock_kernel();
 	if (res > 0)
 		res = 0;
-	dfprintk(VFS, "NFS: readdir(%s/%s) returns %ld\n",
+	dfprintk(FILE, "NFS: readdir(%s/%s) returns %ld\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
 			res);
 	return res;
@@ -610,7 +610,7 @@ static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int origin)
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = filp->f_path.dentry->d_inode;
 
-	dfprintk(VFS, "NFS: llseek dir(%s/%s, %Ld, %d)\n",
+	dfprintk(FILE, "NFS: llseek dir(%s/%s, %Ld, %d)\n",
 			dentry->d_parent->d_name.name,
 			dentry->d_name.name,
 			offset, origin);
@@ -641,7 +641,7 @@ out:
  */
 static int nfs_fsync_dir(struct file *filp, struct dentry *dentry, int datasync)
 {
-	dfprintk(VFS, "NFS: fsync dir(%s/%s) datasync %d\n",
+	dfprintk(FILE, "NFS: fsync dir(%s/%s) datasync %d\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
 			datasync);
 
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 16844f9..2724d19 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -870,7 +870,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
 	count = iov_length(iov, nr_segs);
 	nfs_add_stats(mapping->host, NFSIOS_DIRECTREADBYTES, count);
 
-	dprintk("nfs: direct read(%s/%s, %zd@%Ld)\n",
+	dfprintk(FILE, "NFS: direct read(%s/%s, %zd@%Ld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name,
 		count, (long long) pos);
@@ -927,7 +927,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	count = iov_length(iov, nr_segs);
 	nfs_add_stats(mapping->host, NFSIOS_DIRECTWRITTENBYTES, count);
 
-	dfprintk(VFS, "nfs: direct write(%s/%s, %zd@%Ld)\n",
+	dfprintk(FILE, "NFS: direct write(%s/%s, %zd@%Ld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name,
 		count, (long long) pos);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 03f00bd..a635457 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -120,7 +120,7 @@ nfs_file_open(struct inode *inode, struct file *filp)
 	struct dentry *dentry = filp->f_path.dentry;
 	int res;
 
-	dfprintk(VFS, "NFS: open file(%s/%s)\n",
+	dprintk("NFS: open file(%s/%s)\n",
 			dentry->d_parent->d_name.name,
 			dentry->d_name.name);
 
@@ -138,6 +138,12 @@ nfs_file_open(struct inode *inode, struct file *filp)
 static int
 nfs_file_release(struct inode *inode, struct file *filp)
 {
+	struct dentry *dentry = filp->f_path.dentry;
+
+	dprintk("NFS: release(%s/%s)\n",
+			dentry->d_parent->d_name.name,
+			dentry->d_name.name);
+
 	/* Ensure that dirty pages are flushed out with the right creds */
 	if (filp->f_mode & FMODE_WRITE)
 		nfs_wb_all(filp->f_path.dentry->d_inode);
@@ -177,7 +183,7 @@ static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
 {
 	struct dentry *dentry = filp->f_path.dentry;
 
-	dfprintk(VFS, "NFS: llseek file(%s/%s, %Ld, %d)\n",
+	dprintk("NFS: llseek file(%s/%s, %Ld, %d)\n",
 			dentry->d_parent->d_name.name,
 			dentry->d_name.name,
 			offset, origin);
@@ -219,16 +225,18 @@ static int nfs_do_fsync(struct nfs_open_context *ctx, struct inode *inode)
 
 /*
  * Flush all dirty pages, and check for write errors.
- *
  */
 static int
 nfs_file_flush(struct file *file, fl_owner_t id)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
-	struct inode	*inode = file->f_path.dentry->d_inode;
+	struct dentry	*dentry = file->f_path.dentry;
+	struct inode	*inode = dentry->d_inode;
 	int		status;
 
-	dfprintk(VFS, "nfs: flush(%s/%ld)\n", inode->i_sb->s_id, inode->i_ino);
+	dprintk("NFS: flush(%s/%s)\n",
+			dentry->d_parent->d_name.name,
+			dentry->d_name.name);
 
 	if ((file->f_mode & FMODE_WRITE) == 0)
 		return 0;
@@ -253,7 +261,7 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 	if (iocb->ki_filp->f_flags & O_DIRECT)
 		return nfs_file_direct_read(iocb, iov, nr_segs, pos);
 
-	dfprintk(VFS, "nfs: read(%s/%s, %lu@%lu)\n",
+	dprintk("NFS: read(%s/%s, %lu@%lu)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
 		(unsigned long) count, (unsigned long) pos);
 
@@ -273,7 +281,7 @@ nfs_file_splice_read(struct file *filp, loff_t *ppos,
 	struct inode *inode = dentry->d_inode;
 	ssize_t res;
 
-	dfprintk(VFS, "nfs: splice_read(%s/%s, %lu@%Lu)\n",
+	dprintk("NFS: splice_read(%s/%s, %lu@%Lu)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
 		(unsigned long) count, (unsigned long long) *ppos);
 
@@ -290,7 +298,7 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
 	struct inode *inode = dentry->d_inode;
 	int	status;
 
-	dfprintk(VFS, "nfs: mmap(%s/%s)\n",
+	dprintk("NFS: mmap(%s/%s)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name);
 
 	status = nfs_revalidate_mapping(inode, file->f_mapping);
@@ -313,7 +321,7 @@ nfs_file_fsync(struct file *file, struct dentry *dentry, int datasync)
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	struct inode *inode = dentry->d_inode;
 
-	dfprintk(VFS, "NFS: fsync file(%s/%s) datasync %d\n",
+	dprintk("NFS: fsync file(%s/%s) datasync %d\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
 			datasync);
 
@@ -487,9 +495,9 @@ static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
 	if (iocb->ki_filp->f_flags & O_DIRECT)
 		return nfs_file_direct_write(iocb, iov, nr_segs, pos);
 
-	dfprintk(VFS, "nfs: write(%s/%s(%ld), %lu@%Ld)\n",
+	dprintk("NFS: write(%s/%s, %lu@%Ld)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		inode->i_ino, (unsigned long) count, (long long) pos);
+		(unsigned long) count, (long long) pos);
 
 	result = -EBUSY;
 	if (IS_SWAPFILE(inode))
@@ -640,12 +648,14 @@ out:
  */
 static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
 {
-	struct inode * inode = filp->f_mapping->host;
+	struct dentry *dentry = filp->f_path.dentry;
+	struct inode *inode = filp->f_mapping->host;
 
-	dprintk("NFS: nfs_lock(f=%s/%ld, t=%x, fl=%x, r=%Ld:%Ld)\n",
-			inode->i_sb->s_id, inode->i_ino,
+	dprintk("NFS: lock(%s/%s, t=%x, fl=%x, r=%Ld:%Ld)\n",
+			dentry->d_parent->d_name.name, dentry->d_name.name,
 			fl->fl_type, fl->fl_flags,
 			(long long)fl->fl_start, (long long)fl->fl_end);
+
 	nfs_inc_stats(inode, NFSIOS_VFSLOCK);
 
 	/* No mandatory locks over NFS */
@@ -664,9 +674,10 @@ static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
  */
 static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 {
-	dprintk("NFS: nfs_flock(f=%s/%ld, t=%x, fl=%x)\n",
-			filp->f_path.dentry->d_inode->i_sb->s_id,
-			filp->f_path.dentry->d_inode->i_ino,
+	struct dentry *dentry = filp->f_path.dentry;
+
+	dprintk("NFS: flock(%s/%s, t=%x, fl=%x)\n",
+			dentry->d_parent->d_name.name, dentry->d_name.name,
 			fl->fl_type, fl->fl_flags);
 
 	/*
@@ -689,12 +700,17 @@ static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 	return do_setlk(filp, cmd, fl);
 }
 
+/*
+ * There is no protocol support for leases, so we have no way to implement
+ * them correctly in the face of opens by other clients.
+ */
 static int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
 {
-	/*
-	 * There is no protocol support for leases, so we have no way
-	 * to implement them correctly in the face of opens by other
-	 * clients.
-	 */
+	struct dentry *dentry = file->f_path.dentry;
+
+	dprintk("NFS: setlease(%s/%s, arg=%ld)\n",
+			dentry->d_parent->d_name.name,
+			dentry->d_name.name, arg);
+
 	return -EINVAL;
 }

