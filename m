Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35604 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932422AbcGFWa4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 18:30:56 -0400
Received: by mail-it0-f66.google.com with SMTP id g4so900487ith.2
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 15:30:56 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 19/28] NFS: Do not serialise O_DIRECT reads and writes
Date: Wed,  6 Jul 2016 18:29:56 -0400
Message-Id: <1467844205-76852-20-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1467844205-76852-19-git-send-email-trond.myklebust@primarydata.com>
References: <1467844205-76852-1-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-2-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-3-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-4-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-5-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-6-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-7-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-8-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-9-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-10-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-11-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-12-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-13-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-14-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-15-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-16-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-17-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-18-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-19-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow dio requests to be scheduled in parallel, but ensuring that they
do not conflict with buffered I/O.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/Makefile        |   2 +-
 fs/nfs/direct.c        |  41 +++-----------
 fs/nfs/file.c          |  12 ++--
 fs/nfs/internal.h      |   8 +++
 fs/nfs/io.c            | 147 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs.h |   1 +
 6 files changed, 174 insertions(+), 37 deletions(-)
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
index 0169eca8eb42..6d0e88096440 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -578,17 +578,12 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter)
 	if (!count)
 		goto out;
 
-	inode_lock(inode);
-	result = nfs_sync_mapping(mapping);
-	if (result)
-		goto out_unlock;
-
 	task_io_account_read(count);
 
 	result = -ENOMEM;
 	dreq = nfs_direct_req_alloc();
 	if (dreq == NULL)
-		goto out_unlock;
+		goto out;
 
 	dreq->inode = inode;
 	dreq->bytes_left = dreq->max_count = count;
@@ -603,10 +598,12 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter)
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
+	nfs_start_io_direct(inode);
+
 	NFS_I(inode)->read_io += count;
 	result = nfs_direct_read_schedule_iovec(dreq, iter, iocb->ki_pos);
 
-	inode_unlock(inode);
+	nfs_end_io_direct(inode);
 
 	if (!result) {
 		result = nfs_direct_wait(dreq);
@@ -614,13 +611,8 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter)
 			iocb->ki_pos += result;
 	}
 
-	nfs_direct_req_release(dreq);
-	return result;
-
 out_release:
 	nfs_direct_req_release(dreq);
-out_unlock:
-	inode_unlock(inode);
 out:
 	return result;
 }
@@ -1008,25 +1000,12 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 	pos = iocb->ki_pos;
 	end = (pos + iov_iter_count(iter) - 1) >> PAGE_SHIFT;
 
-	inode_lock(inode);
-
-	result = nfs_sync_mapping(mapping);
-	if (result)
-		goto out_unlock;
-
-	if (mapping->nrpages) {
-		result = invalidate_inode_pages2_range(mapping,
-					pos >> PAGE_SHIFT, end);
-		if (result)
-			goto out_unlock;
-	}
-
 	task_io_account_write(count);
 
 	result = -ENOMEM;
 	dreq = nfs_direct_req_alloc();
 	if (!dreq)
-		goto out_unlock;
+		goto out;
 
 	dreq->inode = inode;
 	dreq->bytes_left = dreq->max_count = count;
@@ -1041,6 +1020,8 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
+	nfs_start_io_direct(inode);
+
 	result = nfs_direct_write_schedule_iovec(dreq, iter, pos);
 
 	if (mapping->nrpages) {
@@ -1048,7 +1029,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 					      pos >> PAGE_SHIFT, end);
 	}
 
-	inode_unlock(inode);
+	nfs_end_io_direct(inode);
 
 	if (!result) {
 		result = nfs_direct_wait(dreq);
@@ -1058,13 +1039,9 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 			generic_write_sync(iocb, result);
 		}
 	}
-	nfs_direct_req_release(dreq);
-	return result;
-
 out_release:
 	nfs_direct_req_release(dreq);
-out_unlock:
-	inode_unlock(inode);
+out:
 	return result;
 }
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 46cf0afe3c0f..9f8da9e1b23f 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -170,12 +170,14 @@ nfs_file_read(struct kiocb *iocb, struct iov_iter *to)
 		iocb->ki_filp,
 		iov_iter_count(to), (unsigned long) iocb->ki_pos);
 
-	result = nfs_revalidate_mapping_protected(inode, iocb->ki_filp->f_mapping);
+	nfs_start_io_read(inode);
+	result = nfs_revalidate_mapping(inode, iocb->ki_filp->f_mapping);
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
 
-	res = nfs_revalidate_mapping_protected(inode, filp->f_mapping);
+	nfs_start_io_read(inode);
+	res = nfs_revalidate_mapping(inode, filp->f_mapping);
 	if (!res) {
 		res = generic_file_splice_read(filp, ppos, pipe, count, flags);
 		if (res > 0)
 			nfs_add_stats(inode, NFSIOS_NORMALREADBYTES, res);
 	}
+	nfs_end_io_read(inode);
 	return res;
 }
 EXPORT_SYMBOL_GPL(nfs_file_splice_read);
@@ -645,14 +649,14 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 			goto out;
 	}
 
-	inode_lock(inode);
+	nfs_start_io_write(inode);
 	result = generic_write_checks(iocb, from);
 	if (result > 0) {
 		current->backing_dev_info = inode_to_bdi(inode);
 		result = generic_perform_write(file, from, iocb->ki_pos);
 		current->backing_dev_info = NULL;
 	}
-	inode_unlock(inode);
+	nfs_end_io_write(inode);
 	if (result <= 0)
 		goto out;
 
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
index 000000000000..1fc5d1ce327e
--- /dev/null
+++ b/fs/nfs/io.c
@@ -0,0 +1,147 @@
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
+/* Call with exclusively locked inode->i_rwsem */
+static void nfs_block_o_direct(struct nfs_inode *nfsi, struct inode *inode)
+{
+	if (test_bit(NFS_INO_ODIRECT, &nfsi->flags)) {
+		clear_bit(NFS_INO_ODIRECT, &nfsi->flags);
+		inode_dio_wait(inode);
+	}
+}
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
+	nfs_block_o_direct(nfsi, inode);
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
+	nfs_block_o_direct(NFS_I(inode), inode);
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
+/* Call with exclusively locked inode->i_rwsem */
+static void nfs_block_buffered(struct nfs_inode *nfsi, struct inode *inode)
+{
+	if (!test_bit(NFS_INO_ODIRECT, &nfsi->flags)) {
+		set_bit(NFS_INO_ODIRECT, &nfsi->flags);
+		nfs_wb_all(inode);
+	}
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
+	nfs_block_buffered(nfsi, inode);
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
2.7.4

