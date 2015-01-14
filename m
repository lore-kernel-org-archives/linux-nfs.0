Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f178.google.com ([209.85.192.178]:54210 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753206AbbANOJU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 09:09:20 -0500
Received: by mail-pd0-f178.google.com with SMTP id r10so9947669pdi.9
        for <linux-nfs@vger.kernel.org>; Wed, 14 Jan 2015 06:09:20 -0800 (PST)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH] nfs: fix dio deadlock when O_DIRECT flag is flipped
Date: Wed, 14 Jan 2015 22:09:03 +0800
Message-Id: <1421244543-32539-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Running xfstest generic/036, we'll get following VM_BUG_ON in
nfs_direct_IO(). 036 toggles O_DIRECT flag while IO is going on.
So the VM_BUG_ON should not exist there. However, we have a deadlock
in the code path as well, because inode->i_mutex is taken when calling
into ->direct_IO. And nfs_file_direct_write() would grab inode->i_mutex
again.

Meanwhile, nfs_file_direct_write() does a lot of things that is already
done by vfs before ->direct_IO is called. So skip those duplicates. One
exception is i_size_write. vfs does not take i_lock when setting i_size.
But nfs appears to need i_lock when setting i_size.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/direct.c | 92 ++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 65 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index bfd9d49..9f88b13 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -105,6 +105,8 @@ static const struct nfs_pgio_completion_ops nfs_direct_write_completion_ops;
 static const struct nfs_commit_completion_ops nfs_direct_commit_completion_ops;
 static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode);
 static void nfs_direct_write_schedule_work(struct work_struct *work);
+static ssize_t nfs_direct_write(struct kiocb *iocb, struct iov_iter *iter,
+				loff_t pos);
 
 static inline void get_dreq(struct nfs_direct_req *dreq)
 {
@@ -257,11 +259,9 @@ ssize_t nfs_direct_IO(int rw, struct kiocb *iocb, struct iov_iter *iter, loff_t
 
 	return -EINVAL;
 #else
-	VM_BUG_ON(iocb->ki_nbytes != PAGE_SIZE);
-
 	if (rw == READ)
 		return nfs_file_direct_read(iocb, iter, pos);
-	return nfs_file_direct_write(iocb, iter, pos);
+	return nfs_direct_write(iocb, iter, pos);
 #endif /* CONFIG_NFS_SWAP */
 }
 
@@ -919,6 +919,66 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	return 0;
 }
 
+static ssize_t _nfs_direct_write(struct kiocb *iocb, struct iov_iter *iter,
+				   struct inode *inode, struct nfs_direct_req **dreqp,
+				   size_t count, loff_t pos)
+{
+	ssize_t result;
+	struct nfs_direct_req *dreq;
+	struct nfs_lock_context *l_ctx;
+
+	task_io_account_write(count);
+
+	result = -ENOMEM;
+	dreq = nfs_direct_req_alloc();
+	if (!dreq)
+		goto out;
+
+	dreq->inode = inode;
+	dreq->bytes_left = count;
+	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
+	l_ctx = nfs_get_lock_context(dreq->ctx);
+	if (IS_ERR(l_ctx)) {
+		result = PTR_ERR(l_ctx);
+		nfs_direct_req_release(dreq);
+		goto out;
+	}
+	dreq->l_ctx = l_ctx;
+	if (!is_sync_kiocb(iocb))
+		dreq->iocb = iocb;
+
+	result = nfs_direct_write_schedule_iovec(dreq, iter, pos);
+	*dreqp = dreq;
+
+out:
+	return result;
+}
+
+static ssize_t nfs_direct_write(struct kiocb *iocb, struct iov_iter *iter,
+				loff_t pos)
+{
+	struct file *file = iocb->ki_filp;
+	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = mapping->host;
+	struct nfs_direct_req *uninitialized_var(dreq);
+	size_t count = iov_iter_count(iter);
+	ssize_t result;
+
+	result = _nfs_direct_write(iocb, iter, inode, &dreq, count, pos);
+	if (!result) {
+		result = nfs_direct_wait(dreq);
+		if (result > 0) {
+			iocb->ki_pos = pos + result;
+			spin_lock(&inode->i_lock);
+			if (i_size_read(inode) < iocb->ki_pos)
+				i_size_write(inode, iocb->ki_pos);
+			spin_unlock(&inode->i_lock);
+		}
+	}
+	nfs_direct_req_release(dreq);
+	return result;
+}
+
 /**
  * nfs_file_direct_write - file direct write operation for NFS files
  * @iocb: target I/O control block
@@ -947,8 +1007,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
 	struct inode *inode = mapping->host;
-	struct nfs_direct_req *dreq;
-	struct nfs_lock_context *l_ctx;
+	struct nfs_direct_req *uninitialized_var(dreq);
 	loff_t end;
 	size_t count = iov_iter_count(iter);
 	end = (pos + count - 1) >> PAGE_CACHE_SHIFT;
@@ -982,26 +1041,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
 			goto out_unlock;
 	}
 
-	task_io_account_write(count);
-
-	result = -ENOMEM;
-	dreq = nfs_direct_req_alloc();
-	if (!dreq)
-		goto out_unlock;
-
-	dreq->inode = inode;
-	dreq->bytes_left = count;
-	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
-	l_ctx = nfs_get_lock_context(dreq->ctx);
-	if (IS_ERR(l_ctx)) {
-		result = PTR_ERR(l_ctx);
-		goto out_release;
-	}
-	dreq->l_ctx = l_ctx;
-	if (!is_sync_kiocb(iocb))
-		dreq->iocb = iocb;
-
-	result = nfs_direct_write_schedule_iovec(dreq, iter, pos);
+	result = _nfs_direct_write(iocb, iter, inode, &dreq, count, pos);
 
 	if (mapping->nrpages) {
 		invalidate_inode_pages2_range(mapping,
@@ -1025,8 +1065,6 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
 	nfs_direct_req_release(dreq);
 	return result;
 
-out_release:
-	nfs_direct_req_release(dreq);
 out_unlock:
 	mutex_unlock(&inode->i_mutex);
 out:
-- 
1.9.1

