Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34932 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbcFUVf2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jun 2016 17:35:28 -0400
Received: by mail-it0-f65.google.com with SMTP id g127so4004133ith.2
        for <linux-nfs@vger.kernel.org>; Tue, 21 Jun 2016 14:35:28 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 10/12] NFS: Do not serialise O_DIRECT reads and writes
Date: Tue, 21 Jun 2016 17:34:51 -0400
Message-Id: <1466544893-12058-10-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466544893-12058-9-git-send-email-trond.myklebust@primarydata.com>
References: <1466544893-12058-1-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-2-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-3-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-4-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-5-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-6-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-7-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-8-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-9-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow dio requests to be scheduled in parallel, but ensuring that they
do not conflict with buffered I/O.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/Makefile        |   2 +-
 fs/nfs/direct.c        |  12 ++---
 fs/nfs/file.c          |  21 ++++++--
 fs/nfs/internal.h      |   8 ++++
 fs/nfs/io.c            | 128 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs.h |   1 +
 6 files changed, 161 insertions(+), 11 deletions(-)
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
index fb659bb50678..2333e9973802 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -587,7 +587,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter)
 	if (!count)
 		goto out;
 
-	inode_lock(inode);
+	nfs_start_io_direct(inode);
 	result = nfs_sync_mapping(mapping);
 	if (result)
 		goto out_unlock;
@@ -615,7 +615,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter)
 	NFS_I(inode)->read_io += count;
 	result = nfs_direct_read_schedule_iovec(dreq, iter, iocb->ki_pos);
 
-	inode_unlock(inode);
+	nfs_end_io_direct(inode);
 
 	if (!result) {
 		result = nfs_direct_wait(dreq);
@@ -629,7 +629,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter)
 out_release:
 	nfs_direct_req_release(dreq);
 out_unlock:
-	inode_unlock(inode);
+	nfs_end_io_direct(inode);
 out:
 	return result;
 }
@@ -1013,7 +1013,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 	pos = iocb->ki_pos;
 	end = (pos + iov_iter_count(iter) - 1) >> PAGE_SHIFT;
 
-	inode_lock(inode);
+	nfs_start_io_direct(inode);
 
 	result = nfs_sync_mapping(mapping);
 	if (result)
@@ -1053,7 +1053,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 					      pos >> PAGE_SHIFT, end);
 	}
 
-	inode_unlock(inode);
+	nfs_end_io_direct(inode);
 
 	if (!result) {
 		result = nfs_direct_wait(dreq);
@@ -1076,7 +1076,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 out_release:
 	nfs_direct_req_release(dreq);
 out_unlock:
-	inode_unlock(inode);
+	nfs_end_io_direct(inode);
 	return result;
 }
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index df4dd8e7e62e..b1dd7f2c64f4 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -170,12 +170,14 @@ nfs_file_read(struct kiocb *iocb, struct iov_iter *to)
 		iocb->ki_filp,
 		iov_iter_count(to), (unsigned long) iocb->ki_pos);
 
+	nfs_start_io_read(inode);
 	result = nfs_revalidate_mapping_protected(inode, iocb->ki_filp->f_mapping);
 	if (!result) {
 		result = generic_file_read_iter(iocb, to);
 		if (result > 0)
 			nfs_add_stats(inode, NFSIOS_NORMALREADBYTES, result);
 	}
+	nfs_end_io_read(inode);
 	return result;
 }
 EXPORT_SYMBOL_GPL(nfs_file_read);
@@ -191,12 +193,14 @@ nfs_file_splice_read(struct file *filp, loff_t *ppos,
 	dprintk("NFS: splice_read(%pD2, %lu@%Lu)\n",
 		filp, (unsigned long) count, (unsigned long long) *ppos);
 
+	nfs_start_io_read(inode);
 	res = nfs_revalidate_mapping_protected(inode, filp->f_mapping);
 	if (!res) {
 		res = generic_file_splice_read(filp, ppos, pipe, count, flags);
 		if (res > 0)
 			nfs_add_stats(inode, NFSIOS_NORMALREADBYTES, res);
 	}
+	nfs_end_io_read(inode);
 	return res;
 }
 EXPORT_SYMBOL_GPL(nfs_file_splice_read);
@@ -639,9 +643,13 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 	dprintk("NFS: write(%pD2, %zu@%Ld)\n",
 		file, count, (long long) iocb->ki_pos);
 
-	result = -EBUSY;
 	if (IS_SWAPFILE(inode))
 		goto out_swapfile;
+
+	nfs_start_io_write(inode);
+	result = generic_write_checks(iocb, from);
+	if (result <= 0)
+		goto out;
 	/*
 	 * O_APPEND implies that we must revalidate the file length.
 	 */
@@ -655,9 +663,13 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 	if (!count)
 		goto out;
 
-	result = generic_file_write_iter(iocb, from);
-	if (result > 0)
+	current->backing_dev_info = inode_to_bdi(inode);
+	result = generic_perform_write(file, from, iocb->ki_pos);
+	current->backing_dev_info = NULL;
+	if (result > 0) {
+		iocb->ki_pos += written;
 		written = result;
+	}
 
 	/* Return error values */
 	if (result >= 0 && nfs_need_check_write(file, inode)) {
@@ -668,11 +680,12 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 	if (result > 0)
 		nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, written);
 out:
+	nfs_end_io_write(inode);
 	return result;
 
 out_swapfile:
 	printk(KERN_INFO "NFS: attempt to write to active swap file!\n");
-	goto out;
+	return -EBUSY;
 }
 EXPORT_SYMBOL_GPL(nfs_file_write);
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0eb5c924886d..159b64ede82a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -411,6 +411,14 @@ extern void __exit unregister_nfs_fs(void);
 extern bool nfs_sb_active(struct super_block *sb);
 extern void nfs_sb_deactive(struct super_block *sb);
 
+/* io.c */
+extern void nfs_start_io_read(struct inode *inode);
+extern void nfs_end_io_read(struct inode *inode);
+extern void nfs_start_io_write(struct inode *inode);
+extern void nfs_end_io_write(struct inode *inode);
+extern void nfs_start_io_direct(struct inode *inode);
+extern void nfs_end_io_direct(struct inode *inode);
+
 /* namespace.c */
 #define NFS_PATH_CANONICAL 1
 extern char *nfs_path(char **p, struct dentry *dentry,
diff --git a/fs/nfs/io.c b/fs/nfs/io.c
new file mode 100644
index 000000000000..013ccb67c106
--- /dev/null
+++ b/fs/nfs/io.c
@@ -0,0 +1,128 @@
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
+/**
+ * nfs_start_io_read - declare the file is being used for buffered reads
+ * @inode - file inode
+ *
+ * Declare that a buffered read operation is about to start, and ensure
+ * that we block all direct I/O.
+ * On exit, the function ensures that the NFS_INO_ODIRECT flag is unset,
+ * and holds a shared lock on inode->i_rwsem to ensure that the flag
+ * cannot be changed.
+ * In practice, this means that buffered read operations are allowed to
+ * execute in parallel, thanks to the shared lock, whereas direct I/O
+ * operations need to wait to grab an exclusive lock in order to set
+ * NFS_INO_ODIRECT.
+ * Note that buffered writes and truncates both take a write lock on
+ * inode->i_rwsem, meaning that those are serialised w.r.t. the reads.
+ */
+void
+nfs_start_io_read(struct inode *inode)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+	/* Be an optimist! */
+	down_read(&inode->i_rwsem);
+	if (test_bit(NFS_INO_ODIRECT, &nfsi->flags) == 0)
+		return;
+	up_read(&inode->i_rwsem);
+	/* Slow path.... */
+	down_write(&inode->i_rwsem);
+	clear_bit(NFS_INO_ODIRECT, &nfsi->flags);
+	downgrade_write(&inode->i_rwsem);
+}
+
+/**
+ * nfs_end_io_read - declare that the buffered read operation is done
+ * @inode - file inode
+ *
+ * Declare that a buffered read operation is done, and release the shared
+ * lock on inode->i_rwsem.
+ */
+void
+nfs_end_io_read(struct inode *inode)
+{
+	up_read(&inode->i_rwsem);
+}
+
+/**
+ * nfs_start_io_write - declare the file is being used for buffered writes
+ * @inode - file inode
+ *
+ * Declare that a buffered read operation is about to start, and ensure
+ * that we block all direct I/O.
+ */
+void
+nfs_start_io_write(struct inode *inode)
+{
+	down_write(&inode->i_rwsem);
+}
+
+/**
+ * nfs_end_io_write - declare that the buffered write operation is done
+ * @inode - file inode
+ *
+ * Declare that a buffered write operation is done, and release the
+ * lock on inode->i_rwsem.
+ */
+void
+nfs_end_io_write(struct inode *inode)
+{
+	up_write(&inode->i_rwsem);
+}
+
+/**
+ * nfs_end_io_direct - declare the file is being used for direct i/o
+ * @inode - file inode
+ *
+ * Declare that a direct I/O operation is about to start, and ensure
+ * that we block all buffered I/O.
+ * On exit, the function ensures that the NFS_INO_ODIRECT flag is set,
+ * and holds a shared lock on inode->i_rwsem to ensure that the flag
+ * cannot be changed.
+ * In practice, this means that direct I/O operations are allowed to
+ * execute in parallel, thanks to the shared lock, whereas buffered I/O
+ * operations need to wait to grab an exclusive lock in order to clear
+ * NFS_INO_ODIRECT.
+ * Note that buffered writes and truncates both take a write lock on
+ * inode->i_rwsem, meaning that those are serialised w.r.t. O_DIRECT.
+ */
+void
+nfs_start_io_direct(struct inode *inode)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+	/* Be an optimist! */
+	down_read(&inode->i_rwsem);
+	if (test_bit(NFS_INO_ODIRECT, &nfsi->flags) != 0)
+		return;
+	up_read(&inode->i_rwsem);
+	/* Slow path.... */
+	down_write(&inode->i_rwsem);
+	set_bit(NFS_INO_ODIRECT, &nfsi->flags);
+	downgrade_write(&inode->i_rwsem);
+}
+
+/**
+ * nfs_end_io_direct - declare that the direct i/o operation is done
+ * @inode - file inode
+ *
+ * Declare that a direct I/O operation is done, and release the shared
+ * lock on inode->i_rwsem.
+ */
+void
+nfs_end_io_direct(struct inode *inode)
+{
+	up_read(&inode->i_rwsem);
+}
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 120dd04b553c..225d17d35277 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -210,6 +210,7 @@ struct nfs_inode {
 #define NFS_INO_LAYOUTCOMMIT	(9)		/* layoutcommit required */
 #define NFS_INO_LAYOUTCOMMITTING (10)		/* layoutcommit inflight */
 #define NFS_INO_LAYOUTSTATS	(11)		/* layoutstats inflight */
+#define NFS_INO_ODIRECT		(12)		/* I/O setting is O_DIRECT */
 
 static inline struct nfs_inode *NFS_I(const struct inode *inode)
 {
-- 
2.5.5

