From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] NFS client fixes for 2.6.24
Date: Mon, 26 Nov 2007 18:35:16 -0500
Message-ID: <1196120116.7716.49.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38909 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754385AbXKZXfh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2007 18:35:37 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git

This will update the following files through the appended changesets.

Apologies for the size of this patch: apart from a few trivial Oopses,
there are 2 regressions that I'd like to fix in 2.6.24 final:

      * ustat() has been broken since 2.6.18 due to the fact that the
        superblock->s_root has pointed to a dummy inode.
      * readv()/writev() have been broken on O_DIRECT since 2.6.19: any
        attempt to set iovcnt != 1 returns -EINVAL.

The latter two regression fixes explain the large changes to
fs/nfs/direct.c and fs/nfs/getroot.c.

  Cheers,
    Trond

----
 fs/nfs/dir.c                        |    1 +
 fs/nfs/direct.c                     |  142 ++++++++++++++++++++++++-----------
 fs/nfs/getroot.c                    |   81 +++++++-------------
 fs/nfs/super.c                      |   11 ++-
 fs/nfs/write.c                      |    3 +-
 include/linux/nfs_fs.h              |    1 -
 include/linux/sunrpc/debug.h        |    5 -
 include/linux/sunrpc/xprtsock.h     |    6 --
 net/sunrpc/auth_gss/auth_gss.c      |    4 +-
 net/sunrpc/auth_gss/gss_krb5_mech.c |    8 ++-
 net/sunrpc/auth_gss/gss_krb5_seal.c |    1 +
 net/sunrpc/rpc_pipe.c               |    2 +-
 net/sunrpc/xprtrdma/transport.c     |   10 +-
 net/sunrpc/xprtsock.c               |    4 +-
 14 files changed, 155 insertions(+), 124 deletions(-)

Adrian Bunk (3):
      NFS: make nfs_wb_page_priority() static
      NFS: fs/nfs/dir.c should #include "internal.h"
      SUNRPC: make sunrpc/xprtsock.c:xs_setup_{udp,tcp}() static

Chuck Lever (4):
      NFS: Introduce iovec I/O helpers to fs/nfs/direct.c
      NFS: Support multiple segment iovecs in the NFS direct I/O path
      NFS: Ensure we return zero if applications attempt to write zero bytes
      NFS: Clean up new multi-segment direct I/O changes

J. Bruce Fields (1):
      sunrpc: rpc_pipe_poll may miss available data in some cases

James Lentini (1):
      SUNRPC: remove NFS/RDMA client's binary sysctls

Joe Perches (1):
      SUNRPC: Add missing "space" to net/sunrpc/auth_gss.c

Kevin Coffman (2):
      sunrpc: gss_pipe_downcall(), don't assume all errors are transient
      sunrpc: return error if unsupported enctype or cksumtype is encountered

Neil Brown (1):
      kernel BUG at fs/nfs/namespace.c:108! - can be triggered by bad server

Russell King (1):
      NFS: mount failure causes bad page state

Trond Myklebust (1):
      NFS: Fix the ustat() regression


diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3533453..f697b5c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -38,6 +38,7 @@
 #include "nfs4_fs.h"
 #include "delegation.h"
 #include "iostat.h"
+#include "internal.h"
 
 /* #define NFS_DEBUG_VERBOSE 1 */
 
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index afcab00..5e8d82f 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -263,17 +263,19 @@ static const struct rpc_call_ops nfs_read_direct_ops = {
  * handled automatically by nfs_direct_read_result().  Otherwise, if
  * no requests have been sent, just return an error.
  */
-static ssize_t nfs_direct_read_schedule(struct nfs_direct_req *dreq, unsigned long user_addr, size_t count, loff_t pos)
+static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
+						const struct iovec *iov,
+						loff_t pos)
 {
 	struct nfs_open_context *ctx = dreq->ctx;
 	struct inode *inode = ctx->path.dentry->d_inode;
+	unsigned long user_addr = (unsigned long)iov->iov_base;
+	size_t count = iov->iov_len;
 	size_t rsize = NFS_SERVER(inode)->rsize;
 	unsigned int pgbase;
 	int result;
 	ssize_t started = 0;
 
-	get_dreq(dreq);
-
 	do {
 		struct nfs_read_data *data;
 		size_t bytes;
@@ -347,15 +349,46 @@ static ssize_t nfs_direct_read_schedule(struct nfs_direct_req *dreq, unsigned lo
 		count -= bytes;
 	} while (count != 0);
 
+	if (started)
+		return started;
+	return result < 0 ? (ssize_t) result : -EFAULT;
+}
+
+static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
+					      const struct iovec *iov,
+					      unsigned long nr_segs,
+					      loff_t pos)
+{
+	ssize_t result = -EINVAL;
+	size_t requested_bytes = 0;
+	unsigned long seg;
+
+	get_dreq(dreq);
+
+	for (seg = 0; seg < nr_segs; seg++) {
+		const struct iovec *vec = &iov[seg];
+		result = nfs_direct_read_schedule_segment(dreq, vec, pos);
+		if (result < 0)
+			break;
+		requested_bytes += result;
+		if ((size_t)result < vec->iov_len)
+			break;
+		pos += vec->iov_len;
+	}
+
 	if (put_dreq(dreq))
 		nfs_direct_complete(dreq);
 
-	if (started)
+	if (requested_bytes != 0)
 		return 0;
-	return result < 0 ? (ssize_t) result : -EFAULT;
+
+	if (result < 0)
+		return result;
+	return -EIO;
 }
 
-static ssize_t nfs_direct_read(struct kiocb *iocb, unsigned long user_addr, size_t count, loff_t pos)
+static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
+			       unsigned long nr_segs, loff_t pos)
 {
 	ssize_t result = 0;
 	sigset_t oldset;
@@ -372,9 +405,8 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, unsigned long user_addr, size
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	nfs_add_stats(inode, NFSIOS_DIRECTREADBYTES, count);
 	rpc_clnt_sigmask(clnt, &oldset);
-	result = nfs_direct_read_schedule(dreq, user_addr, count, pos);
+	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos);
 	if (!result)
 		result = nfs_direct_wait(dreq);
 	rpc_clnt_sigunmask(clnt, &oldset);
@@ -601,17 +633,19 @@ static const struct rpc_call_ops nfs_write_direct_ops = {
  * handled automatically by nfs_direct_write_result().  Otherwise, if
  * no requests have been sent, just return an error.
  */
-static ssize_t nfs_direct_write_schedule(struct nfs_direct_req *dreq, unsigned long user_addr, size_t count, loff_t pos, int sync)
+static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
+						 const struct iovec *iov,
+						 loff_t pos, int sync)
 {
 	struct nfs_open_context *ctx = dreq->ctx;
 	struct inode *inode = ctx->path.dentry->d_inode;
+	unsigned long user_addr = (unsigned long)iov->iov_base;
+	size_t count = iov->iov_len;
 	size_t wsize = NFS_SERVER(inode)->wsize;
 	unsigned int pgbase;
 	int result;
 	ssize_t started = 0;
 
-	get_dreq(dreq);
-
 	do {
 		struct nfs_write_data *data;
 		size_t bytes;
@@ -689,15 +723,48 @@ static ssize_t nfs_direct_write_schedule(struct nfs_direct_req *dreq, unsigned l
 		count -= bytes;
 	} while (count != 0);
 
+	if (started)
+		return started;
+	return result < 0 ? (ssize_t) result : -EFAULT;
+}
+
+static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
+					       const struct iovec *iov,
+					       unsigned long nr_segs,
+					       loff_t pos, int sync)
+{
+	ssize_t result = 0;
+	size_t requested_bytes = 0;
+	unsigned long seg;
+
+	get_dreq(dreq);
+
+	for (seg = 0; seg < nr_segs; seg++) {
+		const struct iovec *vec = &iov[seg];
+		result = nfs_direct_write_schedule_segment(dreq, vec,
+							   pos, sync);
+		if (result < 0)
+			break;
+		requested_bytes += result;
+		if ((size_t)result < vec->iov_len)
+			break;
+		pos += vec->iov_len;
+	}
+
 	if (put_dreq(dreq))
-		nfs_direct_write_complete(dreq, inode);
+		nfs_direct_write_complete(dreq, dreq->inode);
 
-	if (started)
+	if (requested_bytes != 0)
 		return 0;
-	return result < 0 ? (ssize_t) result : -EFAULT;
+
+	if (result < 0)
+		return result;
+	return -EIO;
 }
 
-static ssize_t nfs_direct_write(struct kiocb *iocb, unsigned long user_addr, size_t count, loff_t pos)
+static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
+				unsigned long nr_segs, loff_t pos,
+				size_t count)
 {
 	ssize_t result = 0;
 	sigset_t oldset;
@@ -720,10 +787,8 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, unsigned long user_addr, siz
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	nfs_add_stats(inode, NFSIOS_DIRECTWRITTENBYTES, count);
-
 	rpc_clnt_sigmask(clnt, &oldset);
-	result = nfs_direct_write_schedule(dreq, user_addr, count, pos, sync);
+	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos, sync);
 	if (!result)
 		result = nfs_direct_wait(dreq);
 	rpc_clnt_sigunmask(clnt, &oldset);
@@ -759,21 +824,16 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
 	ssize_t retval = -EINVAL;
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
-	/* XXX: temporary */
-	const char __user *buf = iov[0].iov_base;
-	size_t count = iov[0].iov_len;
+	size_t count;
+
+	count = iov_length(iov, nr_segs);
+	nfs_add_stats(mapping->host, NFSIOS_DIRECTREADBYTES, count);
 
-	dprintk("nfs: direct read(%s/%s, %lu@%Ld)\n",
+	dprintk("nfs: direct read(%s/%s, %zd@%Ld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name,
-		(unsigned long) count, (long long) pos);
-
-	if (nr_segs != 1)
-		goto out;
+		count, (long long) pos);
 
-	retval = -EFAULT;
-	if (!access_ok(VERIFY_WRITE, buf, count))
-		goto out;
 	retval = 0;
 	if (!count)
 		goto out;
@@ -782,7 +842,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
 	if (retval)
 		goto out;
 
-	retval = nfs_direct_read(iocb, (unsigned long) buf, count, pos);
+	retval = nfs_direct_read(iocb, iov, nr_segs, pos);
 	if (retval > 0)
 		iocb->ki_pos = pos + retval;
 
@@ -821,21 +881,21 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	ssize_t retval = -EINVAL;
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
-	/* XXX: temporary */
-	const char __user *buf = iov[0].iov_base;
-	size_t count = iov[0].iov_len;
+	size_t count;
+
+	count = iov_length(iov, nr_segs);
+	nfs_add_stats(mapping->host, NFSIOS_DIRECTWRITTENBYTES, count);
 
-	dprintk("nfs: direct write(%s/%s, %lu@%Ld)\n",
+	dfprintk(VFS, "nfs: direct write(%s/%s, %zd@%Ld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name,
-		(unsigned long) count, (long long) pos);
-
-	if (nr_segs != 1)
-		goto out;
+		count, (long long) pos);
 
 	retval = generic_write_checks(file, &pos, &count, 0);
 	if (retval)
 		goto out;
+	if (!count)
+		goto out;	/* return 0 */
 
 	retval = -EINVAL;
 	if ((ssize_t) count < 0)
@@ -844,15 +904,11 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	if (!count)
 		goto out;
 
-	retval = -EFAULT;
-	if (!access_ok(VERIFY_READ, buf, count))
-		goto out;
-
 	retval = nfs_sync_mapping(mapping);
 	if (retval)
 		goto out;
 
-	retval = nfs_direct_write(iocb, (unsigned long) buf, count, pos);
+	retval = nfs_direct_write(iocb, iov, nr_segs, pos, count);
 
 	if (retval > 0)
 		iocb->ki_pos = pos + retval;
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index 522e5ad..0ee4384 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -43,6 +43,25 @@
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
 /*
+ * Set the superblock root dentry.
+ * Note that this function frees the inode in case of error.
+ */
+static int nfs_superblock_set_dummy_root(struct super_block *sb, struct inode *inode)
+{
+	/* The mntroot acts as the dummy root dentry for this superblock */
+	if (sb->s_root == NULL) {
+		sb->s_root = d_alloc_root(inode);
+		if (sb->s_root == NULL) {
+			iput(inode);
+			return -ENOMEM;
+		}
+		/* Circumvent igrab(): we know the inode is not being freed */
+		atomic_inc(&inode->i_count);
+	}
+	return 0;
+}
+
+/*
  * get an NFS2/NFS3 root dentry from the root filehandle
  */
 struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh)
@@ -54,33 +73,6 @@ struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh)
 	struct inode *inode;
 	int error;
 
-	/* create a dummy root dentry with dummy inode for this superblock */
-	if (!sb->s_root) {
-		struct nfs_fh dummyfh;
-		struct dentry *root;
-		struct inode *iroot;
-
-		memset(&dummyfh, 0, sizeof(dummyfh));
-		memset(&fattr, 0, sizeof(fattr));
-		nfs_fattr_init(&fattr);
-		fattr.valid = NFS_ATTR_FATTR;
-		fattr.type = NFDIR;
-		fattr.mode = S_IFDIR | S_IRUSR | S_IWUSR;
-		fattr.nlink = 2;
-
-		iroot = nfs_fhget(sb, &dummyfh, &fattr);
-		if (IS_ERR(iroot))
-			return ERR_PTR(PTR_ERR(iroot));
-
-		root = d_alloc_root(iroot);
-		if (!root) {
-			iput(iroot);
-			return ERR_PTR(-ENOMEM);
-		}
-
-		sb->s_root = root;
-	}
-
 	/* get the actual root for this mount */
 	fsinfo.fattr = &fattr;
 
@@ -96,6 +88,10 @@ struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh)
 		return ERR_PTR(PTR_ERR(inode));
 	}
 
+	error = nfs_superblock_set_dummy_root(sb, inode);
+	if (error != 0)
+		return ERR_PTR(error);
+
 	/* root dentries normally start off anonymous and get spliced in later
 	 * if the dentry tree reaches them; however if the dentry already
 	 * exists, we'll pick it up at this point and use it as the root
@@ -241,33 +237,6 @@ struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh)
 
 	dprintk("--> nfs4_get_root()\n");
 
-	/* create a dummy root dentry with dummy inode for this superblock */
-	if (!sb->s_root) {
-		struct nfs_fh dummyfh;
-		struct dentry *root;
-		struct inode *iroot;
-
-		memset(&dummyfh, 0, sizeof(dummyfh));
-		memset(&fattr, 0, sizeof(fattr));
-		nfs_fattr_init(&fattr);
-		fattr.valid = NFS_ATTR_FATTR;
-		fattr.type = NFDIR;
-		fattr.mode = S_IFDIR | S_IRUSR | S_IWUSR;
-		fattr.nlink = 2;
-
-		iroot = nfs_fhget(sb, &dummyfh, &fattr);
-		if (IS_ERR(iroot))
-			return ERR_PTR(PTR_ERR(iroot));
-
-		root = d_alloc_root(iroot);
-		if (!root) {
-			iput(iroot);
-			return ERR_PTR(-ENOMEM);
-		}
-
-		sb->s_root = root;
-	}
-
 	/* get the info about the server and filesystem */
 	error = nfs4_server_capabilities(server, mntfh);
 	if (error < 0) {
@@ -289,6 +258,10 @@ struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh)
 		return ERR_PTR(PTR_ERR(inode));
 	}
 
+	error = nfs_superblock_set_dummy_root(sb, inode);
+	if (error != 0)
+		return ERR_PTR(error);
+
 	/* root dentries normally start off anonymous and get spliced in later
 	 * if the dentry tree reaches them; however if the dentry already
 	 * exists, we'll pick it up at this point and use it as the root
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index fa517ae..2426e71 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1054,10 +1054,11 @@ static int nfs_validate_mount_data(void *options,
 {
 	struct nfs_mount_data *data = (struct nfs_mount_data *)options;
 
+	memset(args, 0, sizeof(*args));
+
 	if (data == NULL)
 		goto out_no_data;
 
-	memset(args, 0, sizeof(*args));
 	args->flags		= (NFS_MOUNT_VER3 | NFS_MOUNT_TCP);
 	args->rsize		= NFS_MAX_FILE_IO_SIZE;
 	args->wsize		= NFS_MAX_FILE_IO_SIZE;
@@ -1474,6 +1475,11 @@ static int nfs_xdev_get_sb(struct file_system_type *fs_type, int flags,
 		error = PTR_ERR(mntroot);
 		goto error_splat_super;
 	}
+	if (mntroot->d_inode->i_op != &nfs_dir_inode_operations) {
+		dput(mntroot);
+		error = -ESTALE;
+		goto error_splat_super;
+	}
 
 	s->s_flags |= MS_ACTIVE;
 	mnt->mnt_sb = s;
@@ -1531,10 +1537,11 @@ static int nfs4_validate_mount_data(void *options,
 	struct nfs4_mount_data *data = (struct nfs4_mount_data *)options;
 	char *c;
 
+	memset(args, 0, sizeof(*args));
+
 	if (data == NULL)
 		goto out_no_data;
 
-	memset(args, 0, sizeof(*args));
 	args->rsize		= NFS_MAX_FILE_IO_SIZE;
 	args->wsize		= NFS_MAX_FILE_IO_SIZE;
 	args->timeo		= 600;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 89527a4..51cc1bd 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1436,7 +1436,8 @@ out:
 	return ret;
 }
 
-int nfs_wb_page_priority(struct inode *inode, struct page *page, int how)
+static int nfs_wb_page_priority(struct inode *inode, struct page *page,
+				int how)
 {
 	loff_t range_start = page_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index e82a6eb..2d15d4a 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -422,7 +422,6 @@ extern long nfs_sync_mapping_wait(struct address_space *, struct writeback_contr
 extern int nfs_wb_all(struct inode *inode);
 extern int nfs_wb_nocommit(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
-extern int nfs_wb_page_priority(struct inode *inode, struct page* page, int how);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 extern int  nfs_commit_inode(struct inode *, int);
diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 3347c72..3912cf1 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -88,11 +88,6 @@ enum {
 	CTL_SLOTTABLE_TCP,
 	CTL_MIN_RESVPORT,
 	CTL_MAX_RESVPORT,
-	CTL_SLOTTABLE_RDMA,
-	CTL_RDMA_MAXINLINEREAD,
-	CTL_RDMA_MAXINLINEWRITE,
-	CTL_RDMA_WRITEPADDING,
-	CTL_RDMA_MEMREG,
 };
 
 #endif /* _LINUX_SUNRPC_DEBUG_H_ */
diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index 2c6c2c2..c2a46c4 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -9,12 +9,6 @@
 
 #ifdef __KERNEL__
 
-/*
- * Socket transport setup operations
- */
-struct rpc_xprt *xs_setup_udp(struct xprt_create *args);
-struct rpc_xprt *xs_setup_tcp(struct xprt_create *args);
-
 int		init_socket_xprt(void);
 void		cleanup_socket_xprt(void);
 
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 53995af..a6e57d1 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -540,7 +540,7 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	p = gss_fill_context(p, end, ctx, gss_msg->auth->mech);
 	if (IS_ERR(p)) {
 		err = PTR_ERR(p);
-		gss_msg->msg.errno = (err == -EACCES) ? -EACCES : -EAGAIN;
+		gss_msg->msg.errno = (err == -EAGAIN) ? -EAGAIN : -EACCES;
 		goto err_release_msg;
 	}
 	gss_msg->ctx = gss_get_ctx(ctx);
@@ -967,7 +967,7 @@ gss_validate(struct rpc_task *task, __be32 *p)
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	if (maj_stat) {
-		dprintk("RPC: %5u gss_validate: gss_verify_mic returned"
+		dprintk("RPC: %5u gss_validate: gss_verify_mic returned "
 				"error 0x%08x\n", task->tk_pid, maj_stat);
 		goto out_bad;
 	}
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 9843eac..60c3dba 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -147,13 +147,17 @@ gss_import_sec_context_kerberos(const void *p,
 	p = simple_get_bytes(p, end, &tmp, sizeof(tmp));
 	if (IS_ERR(p))
 		goto out_err_free_ctx;
-	if (tmp != SGN_ALG_DES_MAC_MD5)
+	if (tmp != SGN_ALG_DES_MAC_MD5) {
+		p = ERR_PTR(-ENOSYS);
 		goto out_err_free_ctx;
+	}
 	p = simple_get_bytes(p, end, &tmp, sizeof(tmp));
 	if (IS_ERR(p))
 		goto out_err_free_ctx;
-	if (tmp != SEAL_ALG_DES)
+	if (tmp != SEAL_ALG_DES) {
+		p = ERR_PTR(-ENOSYS);
 		goto out_err_free_ctx;
+	}
 	p = simple_get_bytes(p, end, &ctx->endtime, sizeof(ctx->endtime));
 	if (IS_ERR(p))
 		goto out_err_free_ctx;
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index 1c6eda5..dedcbd6 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -83,6 +83,7 @@ gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
 	u32			seq_send;
 
 	dprintk("RPC:       gss_krb5_seal\n");
+	BUG_ON(ctx == NULL);
 
 	now = get_seconds();
 
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 18f0a8d..c59f3ca 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -280,7 +280,7 @@ rpc_pipe_poll(struct file *filp, struct poll_table_struct *wait)
 	mask = POLLOUT | POLLWRNORM;
 	if (rpci->ops == NULL)
 		mask |= POLLERR | POLLHUP;
-	if (!list_empty(&rpci->pipe))
+	if (filp->private_data || !list_empty(&rpci->pipe))
 		mask |= POLLIN | POLLRDNORM;
 	return mask;
 }
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 1afeb3e..6f2112d 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -89,7 +89,7 @@ static struct ctl_table_header *sunrpc_table_header;
 
 static ctl_table xr_tunables_table[] = {
 	{
-		.ctl_name	= CTL_SLOTTABLE_RDMA,
+		.ctl_name       = CTL_UNNUMBERED,
 		.procname	= "rdma_slot_table_entries",
 		.data		= &xprt_rdma_slot_table_entries,
 		.maxlen		= sizeof(unsigned int),
@@ -100,7 +100,7 @@ static ctl_table xr_tunables_table[] = {
 		.extra2		= &max_slot_table_size
 	},
 	{
-		.ctl_name	= CTL_RDMA_MAXINLINEREAD,
+		.ctl_name       = CTL_UNNUMBERED,
 		.procname	= "rdma_max_inline_read",
 		.data		= &xprt_rdma_max_inline_read,
 		.maxlen		= sizeof(unsigned int),
@@ -109,7 +109,7 @@ static ctl_table xr_tunables_table[] = {
 		.strategy	= &sysctl_intvec,
 	},
 	{
-		.ctl_name	= CTL_RDMA_MAXINLINEWRITE,
+		.ctl_name       = CTL_UNNUMBERED,
 		.procname	= "rdma_max_inline_write",
 		.data		= &xprt_rdma_max_inline_write,
 		.maxlen		= sizeof(unsigned int),
@@ -118,7 +118,7 @@ static ctl_table xr_tunables_table[] = {
 		.strategy	= &sysctl_intvec,
 	},
 	{
-		.ctl_name	= CTL_RDMA_WRITEPADDING,
+		.ctl_name       = CTL_UNNUMBERED,
 		.procname	= "rdma_inline_write_padding",
 		.data		= &xprt_rdma_inline_write_padding,
 		.maxlen		= sizeof(unsigned int),
@@ -129,7 +129,7 @@ static ctl_table xr_tunables_table[] = {
 		.extra2		= &max_padding,
 	},
 	{
-		.ctl_name	= CTL_RDMA_MEMREG,
+		.ctl_name       = CTL_UNNUMBERED,
 		.procname	= "rdma_memreg_strategy",
 		.data		= &xprt_rdma_memreg_strategy,
 		.maxlen		= sizeof(unsigned int),
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 02298f5..2f630a5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1828,7 +1828,7 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
  * @args: rpc transport creation arguments
  *
  */
-struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
+static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 {
 	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;
@@ -1894,7 +1894,7 @@ struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
  * @args: rpc transport creation arguments
  *
  */
-struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
+static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 {
 	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;
