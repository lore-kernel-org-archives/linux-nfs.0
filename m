Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:43871 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933981Ab2C3Poc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Mar 2012 11:44:32 -0400
From: Dave Kleikamp <dave.kleikamp@oracle.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Zach Brown <zab@zabbo.net>,
        Dave Kleikamp <dave.kleikamp@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [RFC PATCH v2 19/21] nfs: add support for read_iter, write_iter
Date: Fri, 30 Mar 2012 10:43:46 -0500
Message-Id: <1333122228-13633-20-git-send-email-dave.kleikamp@oracle.com>
In-Reply-To: <1333122228-13633-1-git-send-email-dave.kleikamp@oracle.com>
References: <1333122228-13633-1-git-send-email-dave.kleikamp@oracle.com>
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
 fs/nfs/direct.c        |  446 ++++++++++++++++++++++++++++++++++++------------
 fs/nfs/file.c          |   51 ++++--
 include/linux/nfs_fs.h |    6 +-
 3 files changed, 376 insertions(+), 127 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 9d0f3c2..27f436d 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -87,6 +87,7 @@ struct nfs_direct_req {
 	int			flags;
 #define NFS_ODIRECT_DO_COMMIT		(1)	/* an unstable reply was received */
 #define NFS_ODIRECT_RESCHED_WRITES	(2)	/* write verification failed */
+#define NFS_ODIRECT_MARK_DIRTY		(4)	/* mark read pages dirty */
 	struct nfs_writeverf	verf;		/* unstable write verifier */
 };
 
@@ -253,9 +254,10 @@ static void nfs_direct_read_release(void *calldata)
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
 
@@ -273,21 +275,15 @@ static const struct rpc_call_ops nfs_read_direct_ops = {
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
@@ -299,6 +295,61 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
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
@@ -336,39 +387,11 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 
 		get_dreq(dreq);
 
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
+		bytes = nfs_direct_read_schedule_helper(dreq, data, user_addr,
+							bytes, pos);
 
-		task = rpc_run_task(&task_setup_data);
-		if (IS_ERR(task))
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
@@ -422,8 +445,98 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	return 0;
 }
 
-static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
-			       unsigned long nr_segs, loff_t pos)
+/*
+ * verify that next biovec page (if any) is contiguous.
+ */
+static int next_bv_page_contiguous(struct bio_vec *bvec,
+				   unsigned long bvec_len, int i)
+{
+	if (i == bvec_len - 1)
+		return 0;
+	if (bvec[i+1].bv_offset)
+		return 0;
+	if ((page_address(bvec[i].bv_page) + bvec[i].bv_offset + bvec[i].bv_len)
+			!= page_address(bvec[i + 1].bv_page))
+		return 0;
+	return 1;
+}
+
+static ssize_t nfs_direct_read_schedule_bvec(struct nfs_direct_req *dreq,
+					     struct bio_vec *bvec,
+					     unsigned long bvec_len,
+					     loff_t pos)
+{
+	struct nfs_open_context *ctx = dreq->ctx;
+	struct inode *inode = ctx->dentry->d_inode;
+	size_t rsize = NFS_SERVER(inode)->rsize;
+	struct nfs_read_data *data = NULL;
+	ssize_t result = 0;
+	size_t requested_bytes = 0;
+	int i = 0;
+	int pages = 0;
+	size_t addr = bvec[0].bv_offset;
+	size_t count = bvec[0].bv_len;
+
+	get_dreq(dreq);
+
+	do {
+		if (pages == 0) {
+			data = nfs_readdata_alloc(bvec_len - i);
+			if (unlikely(!data)) {
+				result = -ENOMEM;
+				break;
+			}
+		}
+		page_cache_get(bvec[i].bv_page);
+		data->pagevec[pages++] = bvec[i].bv_page;
+		if ((count >= rsize) ||
+		    !next_bv_page_contiguous(bvec, bvec_len, i)) {
+			size_t bytes = min(rsize, count);
+
+			data->npages = pages;
+			result = nfs_direct_read_schedule_helper(dreq, data,
+								 addr, bytes,
+								 pos);
+			if (result < 0)
+				break;
+
+			requested_bytes += bytes;
+			addr += bytes;
+			pos += bytes;
+			count -= bytes;
+			pages = 0;
+
+			if ((count == 0) && (i < bvec_len - 1)) {
+				/*
+				 * exhausted page, but more pages remain.
+				 * restart at next page.
+				 */
+				i++;
+				addr = bvec[i].bv_offset;
+				count = bvec[i].bv_len;
+			}
+		} else {
+			i++;
+			count += bvec[i].bv_len;
+		}
+	} while (count);
+
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
+static ssize_t nfs_direct_read(struct kiocb *iocb, struct iov_iter *iter,
+			       loff_t pos)
 {
 	ssize_t result = -ENOMEM;
 	struct inode *inode = iocb->ki_filp->f_mapping->host;
@@ -441,7 +554,18 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos);
+	if (iov_iter_has_iovec(iter)) {
+		dreq->flags = NFS_ODIRECT_MARK_DIRTY;
+		result = nfs_direct_read_schedule_iovec(dreq,
+							iov_iter_iovec(iter),
+							iter->nr_segs, pos);
+	} else if (iov_iter_has_bvec(iter))
+		result = nfs_direct_read_schedule_bvec(dreq,
+						       iov_iter_bvec(iter),
+						       iter->nr_segs, pos);
+	else
+		BUG();
+
 	if (!result)
 		result = nfs_direct_wait(dreq);
 out_release:
@@ -704,20 +828,15 @@ static const struct rpc_call_ops nfs_write_direct_ops = {
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
@@ -729,6 +848,63 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
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
@@ -765,44 +941,11 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
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
+		result = nfs_direct_write_schedule_helper(dreq, data, user_addr,
+							  bytes, pos, sync);
 
-		task_setup_data.task = &data->task;
-		task_setup_data.callback_data = data;
-		msg.rpc_argp = &data->args;
-		msg.rpc_resp = &data->res;
-		NFS_PROTO(inode)->write_setup(data, &msg);
-
-		task = rpc_run_task(&task_setup_data);
-		if (IS_ERR(task))
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
@@ -858,9 +1001,82 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	return 0;
 }
 
-static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos,
-				size_t count)
+static ssize_t nfs_direct_write_schedule_bvec(struct nfs_direct_req *dreq,
+					      struct bio_vec *bvec,
+					      unsigned long bvec_len,
+					      loff_t pos, int sync)
+{
+	struct nfs_open_context *ctx = dreq->ctx;
+	struct inode *inode = ctx->dentry->d_inode;
+	size_t wsize = NFS_SERVER(inode)->wsize;
+	struct nfs_write_data *data = NULL;
+	ssize_t result = 0;
+	size_t requested_bytes = 0;
+	int i = 0;
+	int pages = 0;
+	size_t addr = bvec[0].bv_offset;
+	size_t count = bvec[0].bv_len;
+
+	get_dreq(dreq);
+
+	do {
+		if (pages == 0) {
+			data = nfs_writedata_alloc(bvec_len - i);
+			if (unlikely(!data)) {
+				result = -ENOMEM;
+				break;
+			}
+		}
+		page_cache_get(bvec[i].bv_page);
+		data->pagevec[pages++] = bvec[i].bv_page;
+		if ((count >= wsize) ||
+		    !next_bv_page_contiguous(bvec, bvec_len, i)) {
+			size_t bytes = min(wsize, count);
+
+			data->npages = pages;
+			result = nfs_direct_write_schedule_helper(dreq, data,
+								 addr, bytes,
+								 pos, sync);
+			if (result < 0)
+				break;
+
+			requested_bytes += bytes;
+			addr += bytes;
+			pos += bytes;
+			count -= bytes;
+			pages = 0;
+
+			if ((count == 0) && (i < bvec_len - 1)) {
+				/*
+				 * exhausted page, but more pages remain.
+				 * restart at next page.
+				 */
+				i++;
+				addr = bvec[i].bv_offset;
+				count = bvec[i].bv_len;
+			}
+		} else {
+			i++;
+			count += bvec[i].bv_len;
+		}
+	} while (count);
+
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
+static ssize_t nfs_direct_write(struct kiocb *iocb, struct iov_iter *iter,
+				loff_t pos, size_t count)
 {
 	ssize_t result = -ENOMEM;
 	struct inode *inode = iocb->ki_filp->f_mapping->host;
@@ -884,7 +1100,19 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos, sync);
+	if (iov_iter_has_iovec(iter))
+		result = nfs_direct_write_schedule_iovec(dreq,
+							 iov_iter_iovec(iter),
+							 iter->nr_segs, pos,
+							 sync);
+	else if (iov_iter_has_bvec(iter))
+		result = nfs_direct_write_schedule_bvec(dreq,
+							iov_iter_bvec(iter),
+							iter->nr_segs, pos,
+							sync);
+	else
+		BUG();
+
 	if (!result)
 		result = nfs_direct_wait(dreq);
 out_release:
@@ -896,8 +1124,7 @@ out:
 /**
  * nfs_file_direct_read - file direct read operation for NFS files
  * @iocb: target I/O control block
- * @iov: vector of user buffers into which to read data
- * @nr_segs: size of iov vector
+ * @iter: vector of user buffers into which to read data
  * @pos: byte offset in file where reading starts
  *
  * We use this function for direct reads instead of calling
@@ -914,15 +1141,15 @@ out:
  * client must read the updated atime from the server back into its
  * cache.
  */
-ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos)
+ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter,
+			     loff_t pos)
 {
 	ssize_t retval = -EINVAL;
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
 	size_t count;
 
-	count = iov_length(iov, nr_segs);
+	count = iov_iter_count(iter);
 	nfs_add_stats(mapping->host, NFSIOS_DIRECTREADBYTES, count);
 
 	dfprintk(FILE, "NFS: direct read(%s/%s, %zd@%Ld)\n",
@@ -940,7 +1167,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
 
 	task_io_account_read(count);
 
-	retval = nfs_direct_read(iocb, iov, nr_segs, pos);
+	retval = nfs_direct_read(iocb, iter, pos);
 	if (retval > 0)
 		iocb->ki_pos = pos + retval;
 
@@ -951,8 +1178,7 @@ out:
 /**
  * nfs_file_direct_write - file direct write operation for NFS files
  * @iocb: target I/O control block
- * @iov: vector of user buffers from which to write data
- * @nr_segs: size of iov vector
+ * @iter: vector of user buffers from which to write data
  * @pos: byte offset in file where writing starts
  *
  * We use this function for direct writes instead of calling
@@ -970,15 +1196,15 @@ out:
  * Note that O_APPEND is not supported for NFS direct writes, as there
  * is no atomic O_APPEND write facility in the NFS protocol.
  */
-ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos)
+ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
+			      loff_t pos)
 {
 	ssize_t retval = -EINVAL;
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
 	size_t count;
 
-	count = iov_length(iov, nr_segs);
+	count = iov_iter_count(iter);
 	nfs_add_stats(mapping->host, NFSIOS_DIRECTWRITTENBYTES, count);
 
 	dfprintk(FILE, "NFS: direct write(%s/%s, %zd@%Ld)\n",
@@ -1003,7 +1229,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 
 	task_io_account_write(count);
 
-	retval = nfs_direct_write(iocb, iov, nr_segs, pos, count);
+	retval = nfs_direct_write(iocb, iter, pos, count);
 
 	if (retval > 0)
 		iocb->ki_pos = pos + retval;
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index c43a452..a739f0d 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -179,24 +179,24 @@ nfs_file_flush(struct file *file, fl_owner_t id)
 	return vfs_fsync(file, 0);
 }
 
-static ssize_t
-nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
-		unsigned long nr_segs, loff_t pos)
+static ssize_t nfs_file_read_iter(struct kiocb *iocb, struct iov_iter *iter,
+				  loff_t pos)
 {
 	struct dentry * dentry = iocb->ki_filp->f_path.dentry;
 	struct inode * inode = dentry->d_inode;
 	ssize_t result;
+	size_t count = iov_iter_count(iter);
 
 	if (iocb->ki_filp->f_flags & O_DIRECT)
-		return nfs_file_direct_read(iocb, iov, nr_segs, pos);
+		return nfs_file_direct_read(iocb, iter, pos);
 
-	dprintk("NFS: read(%s/%s, %lu@%lu)\n",
+	dprintk("NFS: read_iter(%s/%s, %lu@%lu)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		(unsigned long) iov_length(iov, nr_segs), (unsigned long) pos);
+		(unsigned long) count, (unsigned long) pos);
 
 	result = nfs_revalidate_mapping(inode, iocb->ki_filp->f_mapping);
 	if (!result) {
-		result = generic_file_aio_read(iocb, iov, nr_segs, pos);
+		result = generic_file_read_iter(iocb, iter, pos);
 		if (result > 0)
 			nfs_add_stats(inode, NFSIOS_NORMALREADBYTES, result);
 	}
@@ -204,6 +204,17 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 }
 
 static ssize_t
+nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
+		unsigned long nr_segs, loff_t pos)
+{
+	struct iov_iter iter;
+
+	iov_iter_init(&iter, iov, nr_segs, iov_length(iov, nr_segs), 0);
+
+	return nfs_file_read_iter(iocb, &iter, pos);
+}
+
+static ssize_t
 nfs_file_splice_read(struct file *filp, loff_t *ppos,
 		     struct pipe_inode_info *pipe, size_t count,
 		     unsigned int flags)
@@ -563,19 +574,19 @@ static int nfs_need_sync_write(struct file *filp, struct inode *inode)
 	return 0;
 }
 
-static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos)
+static ssize_t nfs_file_write_iter(struct kiocb *iocb, struct iov_iter *iter,
+				   loff_t pos)
 {
 	struct dentry * dentry = iocb->ki_filp->f_path.dentry;
 	struct inode * inode = dentry->d_inode;
 	unsigned long written = 0;
 	ssize_t result;
-	size_t count = iov_length(iov, nr_segs);
+	size_t count = iov_iter_count(iter);
 
 	if (iocb->ki_filp->f_flags & O_DIRECT)
-		return nfs_file_direct_write(iocb, iov, nr_segs, pos);
+		return nfs_file_direct_write(iocb, iter, pos);
 
-	dprintk("NFS: write(%s/%s, %lu@%Ld)\n",
+	dprintk("NFS: write_iter(%s/%s, %lu@%Ld)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
 		(unsigned long) count, (long long) pos);
 
@@ -595,7 +606,7 @@ static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
 	if (!count)
 		goto out;
 
-	result = generic_file_aio_write(iocb, iov, nr_segs, pos);
+	result = generic_file_write_iter(iocb, iter, pos);
 	if (result > 0)
 		written = result;
 
@@ -615,6 +626,16 @@ out_swapfile:
 	goto out;
 }
 
+static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
+				unsigned long nr_segs, loff_t pos)
+{
+	struct iov_iter iter;
+
+	iov_iter_init(&iter, iov, nr_segs, iov_length(iov, nr_segs), 0);
+
+	return nfs_file_write_iter(iocb, &iter, pos);
+}
+
 static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
 				     struct file *filp, loff_t *ppos,
 				     size_t count, unsigned int flags)
@@ -853,6 +874,8 @@ const struct file_operations nfs_file_operations = {
 	.write		= do_sync_write,
 	.aio_read	= nfs_file_read,
 	.aio_write	= nfs_file_write,
+	.read_iter	= nfs_file_read_iter,
+	.write_iter	= nfs_file_write_iter,
 	.mmap		= nfs_file_mmap,
 	.open		= nfs_file_open,
 	.flush		= nfs_file_flush,
@@ -884,6 +907,8 @@ const struct file_operations nfs4_file_operations = {
 	.write		= do_sync_write,
 	.aio_read	= nfs_file_read,
 	.aio_write	= nfs_file_write,
+	.read_iter	= nfs_file_read_iter,
+	.write_iter	= nfs_file_write_iter,
 	.mmap		= nfs_file_mmap,
 	.open		= nfs4_file_open,
 	.flush		= nfs_file_flush,
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 50fd8ca..3c3a47e 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -453,11 +453,9 @@ extern int nfs3_removexattr (struct dentry *, const char *name);
  */
 extern ssize_t nfs_direct_IO(int, struct kiocb *, struct iov_iter *, loff_t);
 extern ssize_t nfs_file_direct_read(struct kiocb *iocb,
-			const struct iovec *iov, unsigned long nr_segs,
-			loff_t pos);
+				    struct iov_iter *iter, loff_t pos);
 extern ssize_t nfs_file_direct_write(struct kiocb *iocb,
-			const struct iovec *iov, unsigned long nr_segs,
-			loff_t pos);
+				     struct iov_iter *iter, loff_t pos);
 
 /*
  * linux/fs/nfs/dir.c
-- 
1.7.9.5

