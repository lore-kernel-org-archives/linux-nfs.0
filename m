Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:33669 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754906Ab2B0VU3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Feb 2012 16:20:29 -0500
From: Dave Kleikamp <dave.kleikamp@oracle.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Zach Brown <zab@zabbo.net>,
        Dave Kleikamp <dave.kleikamp@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [RFC PATCH 22/22] nfs: add support for read_iter, write_iter
Date: Mon, 27 Feb 2012 15:19:36 -0600
Message-Id: <1330377576-3659-23-git-send-email-dave.kleikamp@oracle.com>
In-Reply-To: <1330377576-3659-1-git-send-email-dave.kleikamp@oracle.com>
References: <1330377576-3659-1-git-send-email-dave.kleikamp@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch implements the read_iter and write_iter file operations which
allow kernel code to initiate directIO. This allows the loop device to
read and write directly to the server, bypassing the page cache.

Signed-off-by: Dave Kleikamp <dave.kleikamp@oracle.com>
Cc: Zach Brown <zab@zabbo.net>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
---
 fs/nfs/direct.c        |  508 +++++++++++++++++++++++++++++++++++++++---------
 fs/nfs/file.c          |   80 ++++++++
 include/linux/nfs_fs.h |    4 +
 3 files changed, 497 insertions(+), 95 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 1940f1a..fc2c5c3 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -46,6 +46,7 @@
 #include <linux/kref.h>
 #include <linux/slab.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/bio.h>
 
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
@@ -87,6 +88,7 @@ struct nfs_direct_req {
 	int			flags;
 #define NFS_ODIRECT_DO_COMMIT		(1)	/* an unstable reply was received */
 #define NFS_ODIRECT_RESCHED_WRITES	(2)	/* write verification failed */
+#define NFS_ODIRECT_MARK_DIRTY		(4)	/* mark read pages dirty */
 	struct nfs_writeverf	verf;		/* unstable write verifier */
 };
 
@@ -253,9 +255,10 @@ static void nfs_direct_read_release(void *calldata)
 	} else {
 		dreq->count += data->res.count;
 		spin_unlock(&dreq->lock);
-		nfs_direct_dirty_pages(data->pagevec,
-				data->args.pgbase,
-				data->res.count);
+		if (dreq->flags & NFS_ODIRECT_MARK_DIRTY)
+			nfs_direct_dirty_pages(data->pagevec,
+					       data->args.pgbase,
+					       data->res.count);
 	}
 	nfs_direct_release_pages(data->pagevec, data->npages);
 
@@ -273,21 +276,15 @@ static const struct rpc_call_ops nfs_read_direct_ops = {
 };
 
 /*
- * For each rsize'd chunk of the user's buffer, dispatch an NFS READ
- * operation.  If nfs_readdata_alloc() or get_user_pages() fails,
- * bail and stop sending more reads.  Read length accounting is
- * handled automatically by nfs_direct_read_result().  Otherwise, if
- * no requests have been sent, just return an error.
+ * upon entry, data->pagevec contains pinned pages
  */
-static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
-						const struct iovec *iov,
-						loff_t pos)
+static ssize_t nfs_direct_read_schedule_helper(struct nfs_direct_req *dreq,
+					       struct nfs_read_data *data,
+					       size_t addr, size_t count,
+					       loff_t pos)
 {
 	struct nfs_open_context *ctx = dreq->ctx;
 	struct inode *inode = ctx->dentry->d_inode;
-	unsigned long user_addr = (unsigned long)iov->iov_base;
-	size_t count = iov->iov_len;
-	size_t rsize = NFS_SERVER(inode)->rsize;
 	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_cred = ctx->cred,
@@ -299,6 +296,61 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 	};
+	unsigned int pgbase = addr & ~PAGE_MASK;
+
+	get_dreq(dreq);
+
+	data->req = (struct nfs_page *) dreq;
+	data->inode = inode;
+	data->cred = msg.rpc_cred;
+	data->args.fh = NFS_FH(inode);
+	data->args.context = ctx;
+	data->args.lock_context = dreq->l_ctx;
+	data->args.offset = pos;
+	data->args.pgbase = pgbase;
+	data->args.pages = data->pagevec;
+	data->args.count = count;
+	data->res.fattr = &data->fattr;
+	data->res.eof = 0;
+	data->res.count = count;
+	nfs_fattr_init(&data->fattr);
+	msg.rpc_argp = &data->args;
+	msg.rpc_resp = &data->res;
+
+	task_setup_data.task = &data->task;
+	task_setup_data.callback_data = data;
+	NFS_PROTO(inode)->read_setup(data, &msg);
+
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	rpc_put_task(task);
+
+	dprintk("NFS: %5u initiated direct read call "
+		"(req %s/%Ld, %zu bytes @ offset %Lu)\n",
+		data->task.tk_pid, inode->i_sb->s_id,
+		(long long)NFS_FILEID(inode), count,
+		(unsigned long long)data->args.offset);
+
+	return count;
+}
+
+/*
+ * For each rsize'd chunk of the user's buffer, dispatch an NFS READ
+ * operation.  If nfs_readdata_alloc() or get_user_pages() fails,
+ * bail and stop sending more reads.  Read length accounting is
+ * handled automatically by nfs_direct_read_result().  Otherwise, if
+ * no requests have been sent, just return an error.
+ */
+static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
+						const struct iovec *iov,
+						loff_t pos)
+{
+	struct nfs_open_context *ctx = dreq->ctx;
+	struct inode *inode = ctx->dentry->d_inode;
+	unsigned long user_addr = (unsigned long)iov->iov_base;
+	size_t count = iov->iov_len;
+	size_t rsize = NFS_SERVER(inode)->rsize;
 	unsigned int pgbase;
 	int result;
 	ssize_t started = 0;
@@ -334,41 +386,10 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 			data->npages = result;
 		}
 
-		get_dreq(dreq);
-
-		data->req = (struct nfs_page *) dreq;
-		data->inode = inode;
-		data->cred = msg.rpc_cred;
-		data->args.fh = NFS_FH(inode);
-		data->args.context = ctx;
-		data->args.lock_context = dreq->l_ctx;
-		data->args.offset = pos;
-		data->args.pgbase = pgbase;
-		data->args.pages = data->pagevec;
-		data->args.count = bytes;
-		data->res.fattr = &data->fattr;
-		data->res.eof = 0;
-		data->res.count = bytes;
-		nfs_fattr_init(&data->fattr);
-		msg.rpc_argp = &data->args;
-		msg.rpc_resp = &data->res;
-
-		task_setup_data.task = &data->task;
-		task_setup_data.callback_data = data;
-		NFS_PROTO(inode)->read_setup(data, &msg);
-
-		task = rpc_run_task(&task_setup_data);
-		if (IS_ERR(task))
+		bytes = nfs_direct_read_schedule_helper(dreq, data, user_addr,
+							 bytes, pos);
+		if (bytes < 0)
 			break;
-		rpc_put_task(task);
-
-		dprintk("NFS: %5u initiated direct read call "
-			"(req %s/%Ld, %zu bytes @ offset %Lu)\n",
-				data->task.tk_pid,
-				inode->i_sb->s_id,
-				(long long)NFS_FILEID(inode),
-				bytes,
-				(unsigned long long)data->args.offset);
 
 		started += bytes;
 		user_addr += bytes;
@@ -440,6 +461,7 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
 		goto out_release;
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
+	dreq->flags = NFS_ODIRECT_MARK_DIRTY;
 
 	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos);
 	if (!result)
@@ -450,6 +472,90 @@ out:
 	return result;
 }
 
+static ssize_t nfs_direct_read_schedule_bvec(struct nfs_direct_req *dreq,
+					     struct bio_vec *bvec,
+					     unsigned long nr_segs,
+					     loff_t pos)
+{
+	struct nfs_open_context *ctx = dreq->ctx;
+	struct inode *inode = ctx->dentry->d_inode;
+	size_t rsize = NFS_SERVER(inode)->rsize;
+	struct nfs_read_data *data;
+	ssize_t result = 0;
+	size_t requested_bytes = 0;
+	int seg;
+	size_t addr;
+	size_t count;
+
+	get_dreq(dreq);
+
+	for (seg = 0; seg < nr_segs; seg++) {
+		data = nfs_readdata_alloc(1);
+		if (unlikely(!data)) {
+			result = -ENOMEM;
+			break;
+		}
+		page_cache_get(bvec[seg].bv_page);
+		data->pagevec[0] = bvec[seg].bv_page;
+		addr = bvec[seg].bv_offset;
+		count = bvec[seg].bv_len;
+		do {
+			size_t bytes = min(rsize, count);
+			result = nfs_direct_read_schedule_helper(dreq, data,
+								 addr, bytes,
+								 pos);
+			if (result < 0)
+				goto out;
+
+			requested_bytes += bytes;
+			addr += bytes;
+			pos += bytes;
+			count -= bytes;
+		} while (count);
+	}
+out:
+	/*
+	 * If no bytes were started, return the error, and let the
+	 * generic layer handle the completion.
+	 */
+	if (requested_bytes == 0) {
+		nfs_direct_req_release(dreq);
+		return result < 0 ? result : -EIO;
+	}
+
+	if (put_dreq(dreq))
+		nfs_direct_complete(dreq);
+	return 0;
+}
+
+static ssize_t nfs_direct_read_bvec(struct kiocb *iocb, struct bio_vec *bvec,
+				    unsigned long nr_segs, loff_t pos)
+{
+	ssize_t result = -ENOMEM;
+	struct inode *inode = iocb->ki_filp->f_mapping->host;
+	struct nfs_direct_req *dreq;
+
+	dreq = nfs_direct_req_alloc();
+	if (dreq == NULL)
+		goto out;
+
+	dreq->inode = inode;
+	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
+	dreq->l_ctx = nfs_get_lock_context(dreq->ctx);
+	if (dreq->l_ctx == NULL)
+		goto out_release;
+	if (!is_sync_kiocb(iocb))
+		dreq->iocb = iocb;
+
+	result = nfs_direct_read_schedule_bvec(dreq, bvec, nr_segs, pos);
+	if (!result)
+		result = nfs_direct_wait(dreq);
+out_release:
+	nfs_direct_req_release(dreq);
+out:
+	return result;
+}
+
 static void nfs_direct_free_writedata(struct nfs_direct_req *dreq)
 {
 	while (!list_empty(&dreq->rewrite_list)) {
@@ -704,20 +810,15 @@ static const struct rpc_call_ops nfs_write_direct_ops = {
 };
 
 /*
- * For each wsize'd chunk of the user's buffer, dispatch an NFS WRITE
- * operation.  If nfs_writedata_alloc() or get_user_pages() fails,
- * bail and stop sending more writes.  Write length accounting is
- * handled automatically by nfs_direct_write_result().  Otherwise, if
- * no requests have been sent, just return an error.
+ * upon entry, data->pagevec contains pinned pages
  */
-static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
-						 const struct iovec *iov,
-						 loff_t pos, int sync)
+static ssize_t nfs_direct_write_schedule_helper(struct nfs_direct_req *dreq,
+						struct nfs_write_data *data,
+						size_t addr, size_t count,
+						loff_t pos, int sync)
 {
 	struct nfs_open_context *ctx = dreq->ctx;
 	struct inode *inode = ctx->dentry->d_inode;
-	unsigned long user_addr = (unsigned long)iov->iov_base;
-	size_t count = iov->iov_len;
 	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_cred = ctx->cred,
@@ -729,6 +830,63 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 	};
+	unsigned int pgbase = addr & ~PAGE_MASK;
+
+	get_dreq(dreq);
+
+	list_move_tail(&data->pages, &dreq->rewrite_list);
+
+	data->req = (struct nfs_page *) dreq;
+	data->inode = inode;
+	data->cred = msg.rpc_cred;
+	data->args.fh = NFS_FH(inode);
+	data->args.context = ctx;
+	data->args.lock_context = dreq->l_ctx;
+	data->args.offset = pos;
+	data->args.pgbase = pgbase;
+	data->args.pages = data->pagevec;
+	data->args.count = count;
+	data->args.stable = sync;
+	data->res.fattr = &data->fattr;
+	data->res.count = count;
+	data->res.verf = &data->verf;
+	nfs_fattr_init(&data->fattr);
+
+	task_setup_data.task = &data->task;
+	task_setup_data.callback_data = data;
+	msg.rpc_argp = &data->args;
+	msg.rpc_resp = &data->res;
+	NFS_PROTO(inode)->write_setup(data, &msg);
+
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	rpc_put_task(task);
+
+	dprintk("NFS: %5u initiated direct write call "
+		"(req %s/%Ld, %zu bytes @ offset %Lu)\n",
+		data->task.tk_pid, inode->i_sb->s_id,
+		(long long)NFS_FILEID(inode), count,
+		(unsigned long long)data->args.offset);
+
+	return count;
+}
+
+/*
+ * For each wsize'd chunk of the user's buffer, dispatch an NFS WRITE
+ * operation.  If nfs_writedata_alloc() or get_user_pages() fails,
+ * bail and stop sending more writes.  Write length accounting is
+ * handled automatically by nfs_direct_write_result().  Otherwise, if
+ * no requests have been sent, just return an error.
+ */
+static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
+						 const struct iovec *iov,
+						 loff_t pos, int sync)
+{
+	struct nfs_open_context *ctx = dreq->ctx;
+	struct inode *inode = ctx->dentry->d_inode;
+	unsigned long user_addr = (unsigned long)iov->iov_base;
+	size_t count = iov->iov_len;
 	size_t wsize = NFS_SERVER(inode)->wsize;
 	unsigned int pgbase;
 	int result;
@@ -765,44 +923,10 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 			data->npages = result;
 		}
 
-		get_dreq(dreq);
-
-		list_move_tail(&data->pages, &dreq->rewrite_list);
-
-		data->req = (struct nfs_page *) dreq;
-		data->inode = inode;
-		data->cred = msg.rpc_cred;
-		data->args.fh = NFS_FH(inode);
-		data->args.context = ctx;
-		data->args.lock_context = dreq->l_ctx;
-		data->args.offset = pos;
-		data->args.pgbase = pgbase;
-		data->args.pages = data->pagevec;
-		data->args.count = bytes;
-		data->args.stable = sync;
-		data->res.fattr = &data->fattr;
-		data->res.count = bytes;
-		data->res.verf = &data->verf;
-		nfs_fattr_init(&data->fattr);
-
-		task_setup_data.task = &data->task;
-		task_setup_data.callback_data = data;
-		msg.rpc_argp = &data->args;
-		msg.rpc_resp = &data->res;
-		NFS_PROTO(inode)->write_setup(data, &msg);
-
-		task = rpc_run_task(&task_setup_data);
-		if (IS_ERR(task))
+		result = nfs_direct_write_schedule_helper(dreq, data, user_addr,
+							  bytes, pos, sync);
+		if (result < 0)
 			break;
-		rpc_put_task(task);
-
-		dprintk("NFS: %5u initiated direct write call "
-			"(req %s/%Ld, %zu bytes @ offset %Lu)\n",
-				data->task.tk_pid,
-				inode->i_sb->s_id,
-				(long long)NFS_FILEID(inode),
-				bytes,
-				(unsigned long long)data->args.offset);
 
 		started += bytes;
 		user_addr += bytes;
@@ -858,6 +982,98 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	return 0;
 }
 
+static ssize_t nfs_direct_write_schedule_bvec(struct nfs_direct_req *dreq,
+					      struct bio_vec *bvec,
+					      size_t nr_segs, loff_t pos,
+					      int sync)
+{
+	struct nfs_open_context *ctx = dreq->ctx;
+	struct inode *inode = ctx->dentry->d_inode;
+	size_t wsize = NFS_SERVER(inode)->wsize;
+	struct nfs_write_data *data;
+	ssize_t result = 0;
+	size_t requested_bytes = 0;
+	unsigned long seg;
+	size_t addr;
+	size_t count;
+
+	get_dreq(dreq);
+
+	for (seg = 0; seg < nr_segs; seg++) {
+		data = nfs_writedata_alloc(1);
+		if (unlikely(!data)) {
+			result = -ENOMEM;
+			break;
+		}
+
+		page_cache_get(bvec[seg].bv_page);
+		data->pagevec[0] = bvec[seg].bv_page;
+		addr = bvec[seg].bv_offset;
+		count = bvec[seg].bv_len;
+		do {
+			size_t bytes = min(wsize, count);
+			result = nfs_direct_write_schedule_helper(dreq, data,
+								  addr, bytes,
+								  pos, sync);
+			if (result < 0)
+				goto out;
+
+			requested_bytes += bytes;
+			addr += bytes;
+			pos += bytes;
+			count -= bytes;
+		} while (count);
+	}
+out:
+	/*
+	 * If no bytes were started, return the error, and let the
+	 * generic layer handle the completion.
+	 */
+	if (requested_bytes == 0) {
+		nfs_direct_req_release(dreq);
+		return result < 0 ? result : -EIO;
+	}
+
+	if (put_dreq(dreq))
+		nfs_direct_write_complete(dreq, dreq->inode);
+	return 0;
+}
+
+static ssize_t nfs_direct_write_bvec(struct kiocb *iocb, struct bio_vec *bvec,
+				     unsigned long nr_segs, loff_t pos,
+				     size_t count)
+{
+	ssize_t result = -ENOMEM;
+	struct inode *inode = iocb->ki_filp->f_mapping->host;
+	struct nfs_direct_req *dreq;
+	size_t wsize = NFS_SERVER(inode)->wsize;
+	int sync = NFS_UNSTABLE;
+
+	dreq = nfs_direct_req_alloc();
+	if (!dreq)
+		goto out;
+	nfs_alloc_commit_data(dreq);
+
+	if (dreq->commit_data == NULL || count <= wsize)
+		sync = NFS_FILE_SYNC;
+
+	dreq->inode = inode;
+	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
+	dreq->l_ctx = nfs_get_lock_context(dreq->ctx);
+	if (dreq->l_ctx == NULL)
+		goto out_release;
+	if (!is_sync_kiocb(iocb))
+		dreq->iocb = iocb;
+
+	result = nfs_direct_write_schedule_bvec(dreq, bvec, nr_segs, pos, sync);
+	if (!result)
+		result = nfs_direct_wait(dreq);
+out_release:
+	nfs_direct_req_release(dreq);
+out:
+	return result;
+}
+
 static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos,
 				size_t count)
@@ -948,6 +1164,53 @@ out:
 	return retval;
 }
 
+ssize_t nfs_file_direct_read_bvec(struct kiocb *iocb, struct bio_vec *bvec,
+				unsigned long nr_segs, loff_t pos)
+{
+	ssize_t retval = -EINVAL;
+	struct file *file = iocb->ki_filp;
+	struct address_space *mapping = file->f_mapping;
+	size_t count;
+
+	count = bvec_length(bvec, nr_segs);
+	nfs_add_stats(mapping->host, NFSIOS_DIRECTREADBYTES, count);
+
+	dfprintk(FILE, "NFS: direct read bvec(%s/%s, %zd@%Ld)\n",
+		file->f_path.dentry->d_parent->d_name.name,
+		file->f_path.dentry->d_name.name,
+		count, (long long) pos);
+
+	retval = 0;
+	if (!count)
+		goto out;
+
+	retval = nfs_sync_mapping(mapping);
+	if (retval)
+		goto out;
+
+	task_io_account_read(count);
+
+	retval = nfs_direct_read_bvec(iocb, bvec, nr_segs, pos);
+	if (retval > 0)
+		iocb->ki_pos = pos + retval;
+
+out:
+	return retval;
+}
+
+ssize_t nfs_file_direct_read_iter(struct kiocb *iocb, struct iov_iter *iter,
+				  loff_t pos)
+{
+	if (iov_iter_has_iovec(iter))
+		return nfs_file_direct_read(iocb, iov_iter_iovec(iter),
+					    iter->nr_segs, pos);
+	else if (iov_iter_has_bvec(iter))
+		return nfs_file_direct_read_bvec(iocb, iov_iter_bvec(iter),
+						 iter->nr_segs, pos);
+	else
+		BUG();
+}
+
 /**
  * nfs_file_direct_write - file direct write operation for NFS files
  * @iocb: target I/O control block
@@ -1012,6 +1275,61 @@ out:
 	return retval;
 }
 
+ssize_t nfs_file_direct_write_bvec(struct kiocb *iocb, struct bio_vec *bvec,
+				   unsigned long nr_segs, loff_t pos)
+{
+	ssize_t retval = -EINVAL;
+	struct file *file = iocb->ki_filp;
+	struct address_space *mapping = file->f_mapping;
+	size_t count;
+
+	count = bvec_length(bvec, nr_segs);
+	nfs_add_stats(mapping->host, NFSIOS_DIRECTWRITTENBYTES, count);
+
+	dfprintk(FILE, "NFS: direct write(%s/%s, %zd@%Ld)\n",
+		file->f_path.dentry->d_parent->d_name.name,
+		file->f_path.dentry->d_name.name,
+		count, (long long) pos);
+
+	retval = generic_write_checks(file, &pos, &count, 0);
+	if (retval)
+		goto out;
+
+	retval = -EINVAL;
+	if ((ssize_t) count < 0)
+		goto out;
+	retval = 0;
+	if (!count)
+		goto out;
+
+	retval = nfs_sync_mapping(mapping);
+	if (retval)
+		goto out;
+
+	task_io_account_write(count);
+
+	retval = nfs_direct_write_bvec(iocb, bvec, nr_segs, pos, count);
+
+	if (retval > 0)
+		iocb->ki_pos = pos + retval;
+
+out:
+	return retval;
+}
+
+ssize_t nfs_file_direct_write_iter(struct kiocb *iocb, struct iov_iter *iter,
+				   loff_t pos)
+{
+	if (iov_iter_has_iovec(iter))
+		return nfs_file_direct_write(iocb, iov_iter_iovec(iter),
+					     iter->nr_segs, pos);
+	else if (iov_iter_has_bvec(iter))
+		return nfs_file_direct_write_bvec(iocb, iov_iter_bvec(iter),
+						  iter->nr_segs, pos);
+	else
+		BUG();
+}
+
 /**
  * nfs_init_directcache - create a slab cache for nfs_direct_req structures
  *
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index c43a452..6fdb674 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -646,6 +646,82 @@ static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
 	return ret;
 }
 
+ssize_t nfs_file_read_iter(struct kiocb *iocb, struct iov_iter *iter,
+			   loff_t pos)
+{
+	struct dentry *dentry = iocb->ki_filp->f_path.dentry;
+	struct inode *inode = dentry->d_inode;
+	ssize_t result;
+	size_t count = iov_iter_count(iter);
+
+	if (iocb->ki_filp->f_flags & O_DIRECT)
+		return nfs_file_direct_read_iter(iocb, iter, pos);
+
+	dprintk("NFS: read_iter(%s/%s, %lu@%lu)\n",
+		dentry->d_parent->d_name.name, dentry->d_name.name,
+		(unsigned long) count, (unsigned long) pos);
+
+	result = nfs_revalidate_mapping(inode, iocb->ki_filp->f_mapping);
+	if (!result) {
+		result = generic_file_read_iter(iocb, iter, pos);
+		if (result > 0)
+			nfs_add_stats(inode, NFSIOS_NORMALREADBYTES, result);
+	}
+	return result;
+}
+
+ssize_t nfs_file_write_iter(struct kiocb *iocb, struct iov_iter *iter,
+			    loff_t pos)
+{
+	struct dentry *dentry = iocb->ki_filp->f_path.dentry;
+	struct inode *inode = dentry->d_inode;
+	unsigned long written = 0;
+	ssize_t result;
+	size_t count = iov_iter_count(iter);
+
+	if (iocb->ki_filp->f_flags & O_DIRECT)
+		return nfs_file_direct_write_iter(iocb, iter, pos);
+
+	dprintk("NFS: write_iter(%s/%s, %lu@%Ld)\n",
+		dentry->d_parent->d_name.name, dentry->d_name.name,
+		(unsigned long) count, (long long) pos);
+
+	result = -EBUSY;
+	if (IS_SWAPFILE(inode))
+		goto out_swapfile;
+	/*
+	 * O_APPEND implies that we must revalidate the file length.
+	 */
+	if (iocb->ki_filp->f_flags & O_APPEND) {
+		result = nfs_revalidate_file_size(inode, iocb->ki_filp);
+		if (result)
+			goto out;
+	}
+
+	result = count;
+	if (!count)
+		goto out;
+
+	result = generic_file_write_iter(iocb, iter, pos);
+	if (result > 0)
+		written = result;
+
+	/* Return error values for O_DSYNC and IS_SYNC() */
+	if (result >= 0 && nfs_need_sync_write(iocb->ki_filp, inode)) {
+		int err = vfs_fsync(iocb->ki_filp, 0);
+		if (err < 0)
+			result = err;
+	}
+	if (result > 0)
+		nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, written);
+out:
+	return result;
+
+out_swapfile:
+	printk(KERN_INFO "NFS: attempt to write to active swap file!\n");
+	goto out;
+}
+
 static int
 do_getlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 {
@@ -853,6 +929,8 @@ const struct file_operations nfs_file_operations = {
 	.write		= do_sync_write,
 	.aio_read	= nfs_file_read,
 	.aio_write	= nfs_file_write,
+	.read_iter	= nfs_file_read_iter,
+	.write_iter	= nfs_file_write_iter,
 	.mmap		= nfs_file_mmap,
 	.open		= nfs_file_open,
 	.flush		= nfs_file_flush,
@@ -884,6 +962,8 @@ const struct file_operations nfs4_file_operations = {
 	.write		= do_sync_write,
 	.aio_read	= nfs_file_read,
 	.aio_write	= nfs_file_write,
+	.read_iter	= nfs_file_read_iter,
+	.write_iter	= nfs_file_write_iter,
 	.mmap		= nfs_file_mmap,
 	.open		= nfs4_file_open,
 	.flush		= nfs_file_flush,
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 8c29950..6bda672 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -459,6 +459,10 @@ extern ssize_t nfs_file_direct_read(struct kiocb *iocb,
 extern ssize_t nfs_file_direct_write(struct kiocb *iocb,
 			const struct iovec *iov, unsigned long nr_segs,
 			loff_t pos);
+extern ssize_t nfs_file_direct_read_iter(struct kiocb *iocb,
+					 struct iov_iter *iter, loff_t pos);
+extern ssize_t nfs_file_direct_write_iter(struct kiocb *iocb,
+					  struct iov_iter *iter, loff_t pos);
 
 /*
  * linux/fs/nfs/dir.c
-- 
1.7.9.2

