From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 20/37] NFS: Use NFSDBG_FILE for all fops
Date: Thu, 12 Jun 2008 15:22:01 -0400
Message-ID: <20080612192201.24528.81227.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18187 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755173AbYFLTeK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:10 -0400
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: some fops use NFSDBG_FILE, some use NFSDBG_VFS.  Let's use
NFSDBG_FILE for all fops, and consistently report file names instead
of inode numbers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c    |   10 +++++----
 fs/nfs/direct.c |    4 ++--
 fs/nfs/file.c   |   59 ++++++++++++++++++++++++++++++++++---------------------
 3 files changed, 43 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 9a4fb51..ff737bf 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -133,7 +133,7 @@ nfs_opendir(struct inode *inode, struct file *filp)
 {
 	int res;
 
-	dfprintk(VFS, "NFS: open dir(%s/%s)\n",
+	dfprintk(FILE, "NFS: open dir(%s/%s)\n",
 			filp->f_path.dentry->d_parent->d_name.name,
 			filp->f_path.dentry->d_name.name);
 
@@ -531,7 +531,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	struct nfs_fattr fattr;
 	long		res;
 
-	dfprintk(VFS, "NFS: readdir(%s/%s) starting at cookie %Lu\n",
+	dfprintk(FILE, "NFS: readdir(%s/%s) starting at cookie %llu\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
 			(long long)filp->f_pos);
 	nfs_inc_stats(inode, NFSIOS_VFSGETDENTS);
@@ -598,7 +598,7 @@ out:
 	unlock_kernel();
 	if (res > 0)
 		res = 0;
-	dfprintk(VFS, "NFS: readdir(%s/%s) returns %ld\n",
+	dfprintk(FILE, "NFS: readdir(%s/%s) returns %ld\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
 			res);
 	return res;
@@ -609,7 +609,7 @@ static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int origin)
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
 
-	dfprintk(VFS, "NFS: llseek dir(%s/%s, %lld, %d)\n",
+	dfprintk(FILE, "NFS: llseek dir(%s/%s, %lld, %d)\n",
 			dentry->d_parent->d_name.name,
 			dentry->d_name.name,
 			offset, origin);
@@ -640,7 +640,7 @@ out:
  */
 static int nfs_fsync_dir(struct file *filp, struct dentry *dentry, int datasync)
 {
-	dfprintk(VFS, "NFS: fsync dir(%s/%s) datasync %d\n",
+	dfprintk(FILE, "NFS: fsync dir(%s/%s) datasync %d\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
 			datasync);
 
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 4757a2b..08f6b04 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -890,7 +890,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
 	count = iov_length(iov, nr_segs);
 	nfs_add_stats(mapping->host, NFSIOS_DIRECTREADBYTES, count);
 
-	dprintk("nfs: direct read(%s/%s, %zd@%Ld)\n",
+	dfprintk(FILE, "NFS: direct read(%s/%s, %zd@%Ld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name,
 		count, (long long) pos);
@@ -947,7 +947,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	count = iov_length(iov, nr_segs);
 	nfs_add_stats(mapping->host, NFSIOS_DIRECTWRITTENBYTES, count);
 
-	dfprintk(VFS, "nfs: direct write(%s/%s, %zd@%Ld)\n",
+	dfprintk(FILE, "NFS: direct write(%s/%s, %zd@%Ld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name,
 		count, (long long) pos);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 6c447a3..78b26f8 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -119,7 +119,7 @@ nfs_file_open(struct inode *inode, struct file *filp)
 {
 	int res;
 
-	dfprintk(VFS, "NFS: open file(%s/%s)\n",
+	dprintk("NFS: open file(%s/%s)\n",
 			filp->f_path.dentry->d_parent->d_name.name,
 			filp->f_path.dentry->d_name.name);
 
@@ -137,9 +137,15 @@ nfs_file_open(struct inode *inode, struct file *filp)
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
-		nfs_wb_all(filp->f_path.dentry->d_inode);
+		nfs_wb_all(dentry->d_inode);
 	nfs_inc_stats(inode, NFSIOS_VFSRELEASE);
 	return NFS_PROTO(inode)->file_release(inode, filp);
 }
@@ -174,7 +180,7 @@ force_reval:
 
 static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
 {
-	dfprintk(VFS, "NFS: llseek file(%s/%s, %lld, %d)\n",
+	dprintk("NFS: llseek file(%s/%s, %lld, %d)\n",
 			filp->f_path.dentry->d_parent->d_name.name,
 			filp->f_path.dentry->d_name.name,
 			offset, origin);
@@ -216,16 +222,18 @@ static int nfs_do_fsync(struct nfs_open_context *ctx, struct inode *inode)
 
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
@@ -250,7 +258,7 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 	if (iocb->ki_filp->f_flags & O_DIRECT)
 		return nfs_file_direct_read(iocb, iov, nr_segs, pos);
 
-	dfprintk(VFS, "nfs: read(%s/%s, %lu@%lu)\n",
+	dprintk("NFS: read(%s/%s, %lu@%lu)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
 		(unsigned long) count, (unsigned long) pos);
 
@@ -270,7 +278,7 @@ nfs_file_splice_read(struct file *filp, loff_t *ppos,
 	struct inode *inode = dentry->d_inode;
 	ssize_t res;
 
-	dfprintk(VFS, "nfs: splice_read(%s/%s, %lu@%Lu)\n",
+	dprintk("NFS: splice_read(%s/%s, %lu@%Lu)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
 		(unsigned long) count, (unsigned long long) *ppos);
 
@@ -287,7 +295,7 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
 	struct inode *inode = dentry->d_inode;
 	int	status;
 
-	dfprintk(VFS, "nfs: mmap(%s/%s)\n",
+	dprintk("NFS: mmap(%s/%s)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name);
 
 	status = nfs_revalidate_mapping(inode, file->f_mapping);
@@ -310,7 +318,7 @@ nfs_file_fsync(struct file *file, struct dentry *dentry, int datasync)
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	struct inode *inode = dentry->d_inode;
 
-	dfprintk(VFS, "NFS: fsync file(%s/%s) datasync %d\n",
+	dprintk("NFS: fsync file(%s/%s) datasync %d\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
 			datasync);
 
@@ -502,9 +510,9 @@ static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
 	if (iocb->ki_filp->f_flags & O_DIRECT)
 		return nfs_file_direct_write(iocb, iov, nr_segs, pos);
 
-	dfprintk(VFS, "nfs: write(%s/%s(%ld), %lu@%Ld)\n",
+	dprintk("NFS: write(%s/%s, %lu@%Ld)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		inode->i_ino, (unsigned long) count, (long long) pos);
+		(unsigned long) count, (long long) pos);
 
 	result = -EBUSY;
 	if (IS_SWAPFILE(inode))
@@ -649,13 +657,15 @@ out:
  */
 static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
 {
-	struct inode * inode = filp->f_mapping->host;
+	struct inode *inode = filp->f_mapping->host;
 	int ret = -ENOLCK;
 
-	dprintk("NFS: nfs_lock(f=%s/%ld, t=%x, fl=%x, r=%Ld:%Ld)\n",
-			inode->i_sb->s_id, inode->i_ino,
+	dprintk("NFS: lock(%s/%s, t=%x, fl=%x, r=%lld:%lld)\n",
+			filp->f_path.dentry->d_parent->d_name.name,
+			filp->f_path.dentry->d_name.name,
 			fl->fl_type, fl->fl_flags,
 			(long long)fl->fl_start, (long long)fl->fl_end);
+
 	nfs_inc_stats(inode, NFSIOS_VFSLOCK);
 
 	/* No mandatory locks over NFS */
@@ -683,9 +693,9 @@ out_err:
  */
 static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 {
-	dprintk("NFS: nfs_flock(f=%s/%ld, t=%x, fl=%x)\n",
-			filp->f_path.dentry->d_inode->i_sb->s_id,
-			filp->f_path.dentry->d_inode->i_ino,
+	dprintk("NFS: flock(%s/%s, t=%x, fl=%x)\n",
+			filp->f_path.dentry->d_parent->d_name.name,
+			filp->f_path.dentry->d_name.name,
 			fl->fl_type, fl->fl_flags);
 
 	/*
@@ -708,12 +718,15 @@ static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
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
+	dprintk("NFS: setlease(%s/%s, arg=%ld)\n",
+			file->f_path.dentry->d_parent->d_name.name,
+			file->f_path.dentry->d_name.name, arg);
+
 	return -EINVAL;
 }

