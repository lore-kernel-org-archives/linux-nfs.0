Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33401 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932401AbcFNTFr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 15:05:47 -0400
Received: by mail-io0-f195.google.com with SMTP id 5so418662ioy.0
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 12:05:47 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/12] NFS: Do not serialise O_DIRECT reads and writes
Date: Tue, 14 Jun 2016 15:05:13 -0400
Message-Id: <1465931115-30784-10-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1465931115-30784-9-git-send-email-trond.myklebust@primarydata.com>
References: <1465931115-30784-1-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-2-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-3-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-4-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-5-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-6-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-7-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-8-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-9-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow dio requests to be scheduled in parallel, but ensuring that they
do not conflict with buffered I/O.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/Makefile        |  2 +-
 fs/nfs/direct.c        | 14 +++++++------
 fs/nfs/file.c          | 13 ++++++++++--
 fs/nfs/inode.c         |  1 +
 fs/nfs/internal.h      |  6 ++++++
 fs/nfs/io.c            | 54 ++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs.h |  3 +++
 7 files changed, 84 insertions(+), 9 deletions(-)
 create mode 100644 fs/nfs/io.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 8664417955a2..6abdda209642 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -6,7 +6,7 @@ obj-$(CONFIG_NFS_FS) += nfs.o
 
 CFLAGS_nfstrace.o += -I$(src)
 nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
-			   direct.o pagelist.o read.o symlink.o unlink.o \
+			   io.o direct.o pagelist.o read.o symlink.o unlink.o \
 			   write.o namespace.o mount_clnt.o nfstrace.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_SYSCTL)	+= sysctl.o
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index fb659bb50678..81b19c0fd3a3 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -574,6 +574,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter)
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
 	struct inode *inode = mapping->host;
+	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_direct_req *dreq;
 	struct nfs_lock_context *l_ctx;
 	ssize_t result = -EINVAL;
@@ -587,7 +588,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter)
 	if (!count)
 		goto out;
 
-	inode_lock(inode);
+	nfs_lock_dio(nfsi);
 	result = nfs_sync_mapping(mapping);
 	if (result)
 		goto out_unlock;
@@ -615,7 +616,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter)
 	NFS_I(inode)->read_io += count;
 	result = nfs_direct_read_schedule_iovec(dreq, iter, iocb->ki_pos);
 
-	inode_unlock(inode);
+	nfs_unlock_dio(nfsi);
 
 	if (!result) {
 		result = nfs_direct_wait(dreq);
@@ -629,7 +630,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter)
 out_release:
 	nfs_direct_req_release(dreq);
 out_unlock:
-	inode_unlock(inode);
+	nfs_unlock_dio(nfsi);
 out:
 	return result;
 }
@@ -1000,6 +1001,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
 	struct inode *inode = mapping->host;
+	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_direct_req *dreq;
 	struct nfs_lock_context *l_ctx;
 	loff_t pos, end;
@@ -1013,7 +1015,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 	pos = iocb->ki_pos;
 	end = (pos + iov_iter_count(iter) - 1) >> PAGE_SHIFT;
 
-	inode_lock(inode);
+	nfs_lock_dio(nfsi);
 
 	result = nfs_sync_mapping(mapping);
 	if (result)
@@ -1053,7 +1055,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 					      pos >> PAGE_SHIFT, end);
 	}
 
-	inode_unlock(inode);
+	nfs_unlock_dio(nfsi);
 
 	if (!result) {
 		result = nfs_direct_wait(dreq);
@@ -1076,7 +1078,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 out_release:
 	nfs_direct_req_release(dreq);
 out_unlock:
-	inode_unlock(inode);
+	nfs_unlock_dio(nfsi);
 	return result;
 }
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index df4dd8e7e62e..7c90b6c03103 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -161,6 +161,7 @@ ssize_t
 nfs_file_read(struct kiocb *iocb, struct iov_iter *to)
 {
 	struct inode *inode = file_inode(iocb->ki_filp);
+	struct nfs_inode *nfsi = NFS_I(inode);
 	ssize_t result;
 
 	if (iocb->ki_flags & IOCB_DIRECT)
@@ -170,12 +171,14 @@ nfs_file_read(struct kiocb *iocb, struct iov_iter *to)
 		iocb->ki_filp,
 		iov_iter_count(to), (unsigned long) iocb->ki_pos);
 
+	nfs_lock_bio(nfsi);
 	result = nfs_revalidate_mapping_protected(inode, iocb->ki_filp->f_mapping);
 	if (!result) {
 		result = generic_file_read_iter(iocb, to);
 		if (result > 0)
 			nfs_add_stats(inode, NFSIOS_NORMALREADBYTES, result);
 	}
+	nfs_unlock_bio(nfsi);
 	return result;
 }
 EXPORT_SYMBOL_GPL(nfs_file_read);
@@ -186,17 +189,20 @@ nfs_file_splice_read(struct file *filp, loff_t *ppos,
 		     unsigned int flags)
 {
 	struct inode *inode = file_inode(filp);
+	struct nfs_inode *nfsi = NFS_I(inode);
 	ssize_t res;
 
 	dprintk("NFS: splice_read(%pD2, %lu@%Lu)\n",
 		filp, (unsigned long) count, (unsigned long long) *ppos);
 
+	nfs_lock_bio(nfsi);
 	res = nfs_revalidate_mapping_protected(inode, filp->f_mapping);
 	if (!res) {
 		res = generic_file_splice_read(filp, ppos, pipe, count, flags);
 		if (res > 0)
 			nfs_add_stats(inode, NFSIOS_NORMALREADBYTES, res);
 	}
+	nfs_unlock_bio(nfsi);
 	return res;
 }
 EXPORT_SYMBOL_GPL(nfs_file_splice_read);
@@ -621,6 +627,7 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 {
 	struct file *file = iocb->ki_filp;
 	struct inode *inode = file_inode(file);
+	struct nfs_inode *nfsi = NFS_I(inode);
 	unsigned long written = 0;
 	ssize_t result;
 	size_t count = iov_iter_count(from);
@@ -639,9 +646,10 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 	dprintk("NFS: write(%pD2, %zu@%Ld)\n",
 		file, count, (long long) iocb->ki_pos);
 
-	result = -EBUSY;
 	if (IS_SWAPFILE(inode))
 		goto out_swapfile;
+
+	nfs_lock_bio(nfsi);
 	/*
 	 * O_APPEND implies that we must revalidate the file length.
 	 */
@@ -668,11 +676,12 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 	if (result > 0)
 		nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, written);
 out:
+	nfs_unlock_bio(nfsi);
 	return result;
 
 out_swapfile:
 	printk(KERN_INFO "NFS: attempt to write to active swap file!\n");
-	goto out;
+	return -EBUSY;
 }
 EXPORT_SYMBOL_GPL(nfs_file_write);
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 8a808d25dbc8..8326fce028fe 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1984,6 +1984,7 @@ static void init_once(void *foo)
 	nfsi->commit_info.ncommit = 0;
 	atomic_set(&nfsi->commit_info.rpcs_out, 0);
 	init_rwsem(&nfsi->rmdir_sem);
+	init_rwsem(&nfsi->io_lock);
 	nfs4_init_once(nfsi);
 }
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0eb5c924886d..6b89fdf2c7fa 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -411,6 +411,12 @@ extern void __exit unregister_nfs_fs(void);
 extern bool nfs_sb_active(struct super_block *sb);
 extern void nfs_sb_deactive(struct super_block *sb);
 
+/* io.c */
+extern void nfs_lock_bio(struct nfs_inode *nfsi);
+extern void nfs_unlock_bio(struct nfs_inode *nfsi);
+extern void nfs_lock_dio(struct nfs_inode *nfsi);
+extern void nfs_unlock_dio(struct nfs_inode *nfsi);
+
 /* namespace.c */
 #define NFS_PATH_CANONICAL 1
 extern char *nfs_path(char **p, struct dentry *dentry,
diff --git a/fs/nfs/io.c b/fs/nfs/io.c
new file mode 100644
index 000000000000..c027d7e52d45
--- /dev/null
+++ b/fs/nfs/io.c
@@ -0,0 +1,54 @@
+/*
+ * Copyright (c) 2016 Trond Myklebust
+ *
+ * I/O and data path helper functionality.
+ */
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/bitops.h>
+#include <linux/rwsem.h>
+#include <linux/fs.h>
+#include <linux/nfs_fs.h>
+
+#include "internal.h"
+
+void
+nfs_lock_bio(struct nfs_inode *nfsi)
+{
+	/* Be an optimist! */
+	down_read(&nfsi->io_lock);
+	if (test_bit(NFS_INO_ODIRECT, &nfsi->flags) == 0)
+		return;
+	up_read(&nfsi->io_lock);
+	/* Slow path.... */
+	down_write(&nfsi->io_lock);
+	clear_bit(NFS_INO_ODIRECT, &nfsi->flags);
+	downgrade_write(&nfsi->io_lock);
+}
+
+void
+nfs_unlock_bio(struct nfs_inode *nfsi)
+{
+	up_read(&nfsi->io_lock);
+}
+
+void
+nfs_lock_dio(struct nfs_inode *nfsi)
+{
+	/* Be an optimist! */
+	down_read(&nfsi->io_lock);
+	if (test_bit(NFS_INO_ODIRECT, &nfsi->flags) != 0)
+		return;
+	up_read(&nfsi->io_lock);
+	/* Slow path.... */
+	down_write(&nfsi->io_lock);
+	set_bit(NFS_INO_ODIRECT, &nfsi->flags);
+	downgrade_write(&nfsi->io_lock);
+}
+
+void
+nfs_unlock_dio(struct nfs_inode *nfsi)
+{
+	up_read(&nfsi->io_lock);
+}
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 120dd04b553c..9ce6169be9ab 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -122,6 +122,8 @@ struct nfs_inode {
 	unsigned long		flags;			/* atomic bit ops */
 	unsigned long		cache_validity;		/* bit mask */
 
+	struct rw_semaphore	io_lock;
+
 	/*
 	 * read_cache_jiffies is when we started read-caching this inode.
 	 * attrtimeo is for how long the cached information is assumed
@@ -210,6 +212,7 @@ struct nfs_inode {
 #define NFS_INO_LAYOUTCOMMIT	(9)		/* layoutcommit required */
 #define NFS_INO_LAYOUTCOMMITTING (10)		/* layoutcommit inflight */
 #define NFS_INO_LAYOUTSTATS	(11)		/* layoutstats inflight */
+#define NFS_INO_ODIRECT		(12)		/* I/O setting is O_DIRECT */
 
 static inline struct nfs_inode *NFS_I(const struct inode *inode)
 {
-- 
2.5.5

