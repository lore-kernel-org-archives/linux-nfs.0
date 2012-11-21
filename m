Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1050.oracle.com ([141.146.126.70]:35507 "EHLO
	aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052Ab2KVS0f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Nov 2012 13:26:35 -0500
From: Dave Kleikamp <dave.kleikamp@oracle.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Zach Brown <zab@zabbo.net>,
        "Maxim V. Patlasov" <mpatlasov@parallels.com>,
        Dave Kleikamp <dave.kleikamp@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH v4 22/31] nfs: add support for read_iter, write_iter
Date: Wed, 21 Nov 2012 16:41:02 -0600
Message-Id: <1353537671-26284-23-git-send-email-dave.kleikamp@oracle.com>
In-Reply-To: <1353537671-26284-1-git-send-email-dave.kleikamp@oracle.com>
References: <1353537671-26284-1-git-send-email-dave.kleikamp@oracle.com>
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
 fs/nfs/direct.c        | 239 +++++++++++++++++++++++++++++++++++++------------
 fs/nfs/file.c          |  33 ++++---
 fs/nfs/internal.h      |   4 +-
 fs/nfs/nfs4file.c      |   4 +-
 include/linux/nfs_fs.h |   6 +-
 5 files changed, 202 insertions(+), 84 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 4532781..6754588 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -90,6 +90,7 @@ struct nfs_direct_req {
 	int			flags;
 #define NFS_ODIRECT_DO_COMMIT		(1)	/* an unstable reply was received */
 #define NFS_ODIRECT_RESCHED_WRITES	(2)	/* write verification failed */
+#define NFS_ODIRECT_MARK_DIRTY		(4)	/* mark read pages dirty */
 	struct nfs_writeverf	verf;		/* unstable write verifier */
 };
 
@@ -131,15 +132,13 @@ ssize_t nfs_direct_IO(int rw, struct kiocb *iocb, struct iov_iter *iter,
 
 	return -EINVAL;
 #else
-	const struct iovec *iov = iov_iter_iovec(iter);
-
 	VM_BUG_ON(iocb->ki_left != PAGE_SIZE);
 	VM_BUG_ON(iocb->ki_nbytes != PAGE_SIZE);
 
 	if (rw == READ || rw == KERNEL_READ)
-		return nfs_file_direct_read(iocb, iov, iter->nr_segs, pos,
+		return nfs_file_direct_read(iocb, iter, pos,
 				rw == READ ? true : false);
-	return nfs_file_direct_write(iocb, iov, iter->nr_segs, pos,
+	return nfs_file_direct_write(iocb, iter, pos,
 				rw == WRITE ? true : false);
 #endif /* CONFIG_NFS_SWAP */
 }
@@ -277,7 +276,8 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 					hdr->good_bytes & ~PAGE_MASK,
 					PAGE_SIZE);
 		}
-		if (!PageCompound(page)) {
+		if ((dreq->flags & NFS_ODIRECT_MARK_DIRTY) &&
+		    !PageCompound(page)) {
 			if (test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
 				if (bytes < hdr->good_bytes)
 					set_page_dirty(page);
@@ -414,24 +414,17 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
 	return result < 0 ? (ssize_t) result : -EFAULT;
 }
 
-static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
-					      const struct iovec *iov,
-					      unsigned long nr_segs,
-					      loff_t pos, bool uio)
+static ssize_t nfs_direct_do_schedule_read_iovec(
+		struct nfs_pageio_descriptor *desc, const struct iovec *iov,
+		unsigned long nr_segs, loff_t pos, bool uio)
 {
-	struct nfs_pageio_descriptor desc;
 	ssize_t result = -EINVAL;
 	size_t requested_bytes = 0;
 	unsigned long seg;
 
-	NFS_PROTO(dreq->inode)->read_pageio_init(&desc, dreq->inode,
-			     &nfs_direct_read_completion_ops);
-	get_dreq(dreq);
-	desc.pg_dreq = dreq;
-
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];
-		result = nfs_direct_read_schedule_segment(&desc, vec, pos, uio);
+		result = nfs_direct_read_schedule_segment(desc, vec, pos, uio);
 		if (result < 0)
 			break;
 		requested_bytes += result;
@@ -439,6 +432,74 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			break;
 		pos += vec->iov_len;
 	}
+	if (requested_bytes)
+		return requested_bytes;
+
+	return result < 0 ? result : -EIO;
+}
+
+static ssize_t nfs_direct_do_schedule_read_bvec(
+		struct nfs_pageio_descriptor *desc,
+		struct bio_vec *bvec, unsigned long nr_segs, loff_t pos)
+{
+	struct nfs_direct_req *dreq = desc->pg_dreq;
+	struct nfs_open_context *ctx = dreq->ctx;
+	struct inode *inode = ctx->dentry->d_inode;
+	ssize_t result = -EINVAL;
+	size_t requested_bytes = 0;
+	unsigned long seg;
+	struct nfs_page *req;
+	unsigned int req_len;
+
+	for (seg = 0; seg < nr_segs; seg++) {
+		result = -EIO;
+		req_len = bvec[seg].bv_len;
+		req = nfs_create_request(ctx, inode,
+					 bvec[seg].bv_page,
+					 bvec[seg].bv_offset, req_len);
+		if (IS_ERR(req)) {
+			result = PTR_ERR(req);
+			break;
+		}
+		req->wb_index = pos >> PAGE_SHIFT;
+		req->wb_offset = pos & ~PAGE_MASK;
+		if (!nfs_pageio_add_request(desc, req)) {
+			result = desc->pg_error;
+			nfs_release_request(req);
+			break;
+		}
+		requested_bytes += req_len;
+		pos += req_len;
+	}
+
+	if (requested_bytes)
+		return requested_bytes;
+
+	return result < 0 ? result : -EIO;
+}
+
+static ssize_t nfs_direct_read_schedule(struct nfs_direct_req *dreq,
+					struct iov_iter *iter, loff_t pos,
+					bool uio)
+{
+	struct nfs_pageio_descriptor desc;
+	ssize_t result;
+
+	NFS_PROTO(dreq->inode)->read_pageio_init(&desc, dreq->inode,
+			     &nfs_direct_read_completion_ops);
+	get_dreq(dreq);
+	desc.pg_dreq = dreq;
+
+	if (iov_iter_has_iovec(iter)) {
+		if (uio)
+			dreq->flags = NFS_ODIRECT_MARK_DIRTY;
+		result = nfs_direct_do_schedule_read_iovec(&desc,
+				iov_iter_iovec(iter), iter->nr_segs, pos, uio);
+	} else if (iov_iter_has_bvec(iter)) {
+		result = nfs_direct_do_schedule_read_bvec(&desc,
+				iov_iter_bvec(iter), iter->nr_segs, pos);
+	} else
+		BUG();
 
 	nfs_pageio_complete(&desc);
 
@@ -446,9 +507,9 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	 * If no bytes were started, return the error, and let the
 	 * generic layer handle the completion.
 	 */
-	if (requested_bytes == 0) {
+	if (result < 0) {
 		nfs_direct_req_release(dreq);
-		return result < 0 ? result : -EIO;
+		return result;
 	}
 
 	if (put_dreq(dreq))
@@ -456,8 +517,8 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	return 0;
 }
 
-static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
-			       unsigned long nr_segs, loff_t pos, bool uio)
+static ssize_t nfs_direct_read(struct kiocb *iocb, struct iov_iter *iter,
+			       loff_t pos, bool uio)
 {
 	ssize_t result = -ENOMEM;
 	struct inode *inode = iocb->ki_filp->f_mapping->host;
@@ -469,7 +530,7 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
 		goto out;
 
 	dreq->inode = inode;
-	dreq->bytes_left = iov_length(iov, nr_segs);
+	dreq->bytes_left = iov_iter_count(iter);
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
 	l_ctx = nfs_get_lock_context(dreq->ctx);
 	if (IS_ERR(l_ctx)) {
@@ -480,8 +541,8 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	NFS_I(inode)->read_io += iov_length(iov, nr_segs);
-	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos, uio);
+	NFS_I(inode)->read_io += iov_iter_count(iter);
+	result = nfs_direct_read_schedule(dreq, iter, pos, uio);
 	if (!result)
 		result = nfs_direct_wait(dreq);
 out_release:
@@ -815,27 +876,18 @@ static const struct nfs_pgio_completion_ops nfs_direct_write_completion_ops = {
 	.completion = nfs_direct_write_completion,
 };
 
-static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
-					       const struct iovec *iov,
-					       unsigned long nr_segs,
-					       loff_t pos, bool uio)
+static ssize_t nfs_direct_do_schedule_write_iovec(
+		struct nfs_pageio_descriptor *desc, const struct iovec *iov,
+		unsigned long nr_segs, loff_t pos, bool uio)
 {
-	struct nfs_pageio_descriptor desc;
-	struct inode *inode = dreq->inode;
-	ssize_t result = 0;
+	ssize_t result = -EINVAL;
 	size_t requested_bytes = 0;
 	unsigned long seg;
 
-	NFS_PROTO(inode)->write_pageio_init(&desc, inode, FLUSH_COND_STABLE,
-			      &nfs_direct_write_completion_ops);
-	desc.pg_dreq = dreq;
-	get_dreq(dreq);
-	atomic_inc(&inode->i_dio_count);
-
-	NFS_I(dreq->inode)->write_io += iov_length(iov, nr_segs);
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];
-		result = nfs_direct_write_schedule_segment(&desc, vec, pos, uio);
+		result = nfs_direct_write_schedule_segment(desc, vec,
+							   pos, uio);
 		if (result < 0)
 			break;
 		requested_bytes += result;
@@ -843,16 +895,88 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			break;
 		pos += vec->iov_len;
 	}
+
+	if (requested_bytes)
+		return requested_bytes;
+
+	return result < 0 ? result : -EIO;
+}
+
+static ssize_t nfs_direct_do_schedule_write_bvec(
+		struct nfs_pageio_descriptor *desc,
+		struct bio_vec *bvec, unsigned long nr_segs, loff_t pos)
+{
+	struct nfs_direct_req *dreq = desc->pg_dreq;
+	struct nfs_open_context *ctx = dreq->ctx;
+	struct inode *inode = dreq->inode;
+	ssize_t result = 0;
+	size_t requested_bytes = 0;
+	unsigned long seg;
+	struct nfs_page *req;
+	unsigned int req_len;
+
+	for (seg = 0; seg < nr_segs; seg++) {
+		req_len = bvec[seg].bv_len;
+
+		req = nfs_create_request(ctx, inode, bvec[seg].bv_page,
+					 bvec[seg].bv_offset, req_len);
+		if (IS_ERR(req)) {
+			result = PTR_ERR(req);
+			break;
+		}
+		nfs_lock_request(req);
+		req->wb_index = pos >> PAGE_SHIFT;
+		req->wb_offset = pos & ~PAGE_MASK;
+		if (!nfs_pageio_add_request(desc, req)) {
+			result = desc->pg_error;
+			nfs_unlock_and_release_request(req);
+			break;
+		}
+		requested_bytes += req_len;
+		pos += req_len;
+	}
+
+	if (requested_bytes)
+		return requested_bytes;
+
+	return result < 0 ? result : -EIO;
+}
+
+static ssize_t nfs_direct_write_schedule(struct nfs_direct_req *dreq,
+					 struct iov_iter *iter, loff_t pos,
+					 bool uio)
+{
+	struct nfs_pageio_descriptor desc;
+	struct inode *inode = dreq->inode;
+	ssize_t result = 0;
+
+	NFS_PROTO(inode)->write_pageio_init(&desc, inode, FLUSH_COND_STABLE,
+			      &nfs_direct_write_completion_ops);
+	desc.pg_dreq = dreq;
+	get_dreq(dreq);
+	atomic_inc(&inode->i_dio_count);
+
+	NFS_I(dreq->inode)->write_io += iov_iter_count(iter);
+
+	if (iov_iter_has_iovec(iter)) {
+		result = nfs_direct_do_schedule_write_iovec(&desc,
+				iov_iter_iovec(iter), iter->nr_segs, pos, uio);
+	} else if (iov_iter_has_bvec(iter)) {
+		result = nfs_direct_do_schedule_write_bvec(&desc,
+				iov_iter_bvec(iter), iter->nr_segs, pos);
+	} else
+		BUG();
+
 	nfs_pageio_complete(&desc);
 
 	/*
 	 * If no bytes were started, return the error, and let the
 	 * generic layer handle the completion.
 	 */
-	if (requested_bytes == 0) {
+	if (result < 0) {
 		inode_dio_done(inode);
 		nfs_direct_req_release(dreq);
-		return result < 0 ? result : -EIO;
+		return result;
 	}
 
 	if (put_dreq(dreq))
@@ -860,9 +984,8 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	return 0;
 }
 
-static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos,
-				size_t count, bool uio)
+static ssize_t nfs_direct_write(struct kiocb *iocb, struct iov_iter *iter,
+				loff_t pos, bool uio)
 {
 	ssize_t result = -ENOMEM;
 	struct inode *inode = iocb->ki_filp->f_mapping->host;
@@ -874,7 +997,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 		goto out;
 
 	dreq->inode = inode;
-	dreq->bytes_left = count;
+	dreq->bytes_left = iov_iter_count(iter);
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
 	l_ctx = nfs_get_lock_context(dreq->ctx);
 	if (IS_ERR(l_ctx)) {
@@ -885,7 +1008,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos, uio);
+	result = nfs_direct_write_schedule(dreq, iter, pos, uio);
 	if (!result)
 		result = nfs_direct_wait(dreq);
 out_release:
@@ -897,12 +1020,11 @@ out:
 /**
  * nfs_file_direct_read - file direct read operation for NFS files
  * @iocb: target I/O control block
- * @iov: vector of user buffers into which to read data
- * @nr_segs: size of iov vector
+ * @iter: vector of buffers into which to read data
  * @pos: byte offset in file where reading starts
  *
  * We use this function for direct reads instead of calling
- * generic_file_aio_read() in order to avoid gfar's check to see if
+ * generic_file_read_iter() in order to avoid gfar's check to see if
  * the request starts before the end of the file.  For that check
  * to work, we must generate a GETATTR before each direct read, and
  * even then there is a window between the GETATTR and the subsequent
@@ -915,15 +1037,15 @@ out:
  * client must read the updated atime from the server back into its
  * cache.
  */
-ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos, bool uio)
+ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter,
+			     loff_t pos, bool uio)
 {
 	ssize_t retval = -EINVAL;
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
 	size_t count;
 
-	count = iov_length(iov, nr_segs);
+	count = iov_iter_count(iter);
 	nfs_add_stats(mapping->host, NFSIOS_DIRECTREADBYTES, count);
 
 	dfprintk(FILE, "NFS: direct read(%s/%s, %zd@%Ld)\n",
@@ -941,7 +1063,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
 
 	task_io_account_read(count);
 
-	retval = nfs_direct_read(iocb, iov, nr_segs, pos, uio);
+	retval = nfs_direct_read(iocb, iter, pos, uio);
 	if (retval > 0)
 		iocb->ki_pos = pos + retval;
 
@@ -952,12 +1074,11 @@ out:
 /**
  * nfs_file_direct_write - file direct write operation for NFS files
  * @iocb: target I/O control block
- * @iov: vector of user buffers from which to write data
- * @nr_segs: size of iov vector
+ * @iter: vector of buffers from which to write data
  * @pos: byte offset in file where writing starts
  *
  * We use this function for direct writes instead of calling
- * generic_file_aio_write() in order to avoid taking the inode
+ * generic_file_write_iter() in order to avoid taking the inode
  * semaphore and updating the i_size.  The NFS server will set
  * the new i_size and this client must read the updated size
  * back into its cache.  We let the server do generic write
@@ -971,15 +1092,15 @@ out:
  * Note that O_APPEND is not supported for NFS direct writes, as there
  * is no atomic O_APPEND write facility in the NFS protocol.
  */
-ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos, bool uio)
+ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
+			      loff_t pos, bool uio)
 {
 	ssize_t retval = -EINVAL;
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
 	size_t count;
 
-	count = iov_length(iov, nr_segs);
+	count = iov_iter_count(iter);
 	nfs_add_stats(mapping->host, NFSIOS_DIRECTWRITTENBYTES, count);
 
 	dfprintk(FILE, "NFS: direct write(%s/%s, %zd@%Ld)\n",
@@ -1004,7 +1125,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 
 	task_io_account_write(count);
 
-	retval = nfs_direct_write(iocb, iov, nr_segs, pos, count, uio);
+	retval = nfs_direct_write(iocb, iter, pos, uio);
 	if (retval > 0) {
 		struct inode *inode = mapping->host;
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 582bb88..1b7d325 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -172,29 +172,28 @@ nfs_file_flush(struct file *file, fl_owner_t id)
 EXPORT_SYMBOL_GPL(nfs_file_flush);
 
 ssize_t
-nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
-		unsigned long nr_segs, loff_t pos)
+nfs_file_read_iter(struct kiocb *iocb, struct iov_iter *iter, loff_t pos)
 {
 	struct dentry * dentry = iocb->ki_filp->f_path.dentry;
 	struct inode * inode = dentry->d_inode;
 	ssize_t result;
 
 	if (iocb->ki_filp->f_flags & O_DIRECT)
-		return nfs_file_direct_read(iocb, iov, nr_segs, pos, true);
+		return nfs_file_direct_read(iocb, iter, pos, true);
 
-	dprintk("NFS: read(%s/%s, %lu@%lu)\n",
+	dprintk("NFS: read_iter(%s/%s, %lu@%lu)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		(unsigned long) iov_length(iov, nr_segs), (unsigned long) pos);
+		(unsigned long) iov_iter_count(iter), (unsigned long) pos);
 
 	result = nfs_revalidate_mapping(inode, iocb->ki_filp->f_mapping);
 	if (!result) {
-		result = generic_file_aio_read(iocb, iov, nr_segs, pos);
+		result = generic_file_read_iter(iocb, iter, pos);
 		if (result > 0)
 			nfs_add_stats(inode, NFSIOS_NORMALREADBYTES, result);
 	}
 	return result;
 }
-EXPORT_SYMBOL_GPL(nfs_file_read);
+EXPORT_SYMBOL_GPL(nfs_file_read_iter);
 
 ssize_t
 nfs_file_splice_read(struct file *filp, loff_t *ppos,
@@ -250,7 +249,7 @@ EXPORT_SYMBOL_GPL(nfs_file_mmap);
  * disk, but it retrieves and clears ctx->error after synching, despite
  * the two being set at the same time in nfs_context_set_write_error().
  * This is because the former is used to notify the _next_ call to
- * nfs_file_write() that a write error occurred, and hence cause it to
+ * nfs_file_write_iter() that a write error occurred, and hence cause it to
  * fall back to doing a synchronous write.
  */
 int
@@ -610,19 +609,19 @@ static int nfs_need_sync_write(struct file *filp, struct inode *inode)
 	return 0;
 }
 
-ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
-		       unsigned long nr_segs, loff_t pos)
+ssize_t nfs_file_write_iter(struct kiocb *iocb, struct iov_iter *iter,
+				   loff_t pos)
 {
 	struct dentry * dentry = iocb->ki_filp->f_path.dentry;
 	struct inode * inode = dentry->d_inode;
 	unsigned long written = 0;
 	ssize_t result;
-	size_t count = iov_length(iov, nr_segs);
+	size_t count = iov_iter_count(iter);
 
 	if (iocb->ki_filp->f_flags & O_DIRECT)
-		return nfs_file_direct_write(iocb, iov, nr_segs, pos, true);
+		return nfs_file_direct_write(iocb, iter, pos, true);
 
-	dprintk("NFS: write(%s/%s, %lu@%Ld)\n",
+	dprintk("NFS: write_iter(%s/%s, %lu@%lld)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
 		(unsigned long) count, (long long) pos);
 
@@ -642,7 +641,7 @@ ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
 	if (!count)
 		goto out;
 
-	result = generic_file_aio_write(iocb, iov, nr_segs, pos);
+	result = generic_file_write_iter(iocb, iter, pos);
 	if (result > 0)
 		written = result;
 
@@ -661,7 +660,7 @@ out_swapfile:
 	printk(KERN_INFO "NFS: attempt to write to active swap file!\n");
 	goto out;
 }
-EXPORT_SYMBOL_GPL(nfs_file_write);
+EXPORT_SYMBOL_GPL(nfs_file_write_iter);
 
 ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
 			      struct file *filp, loff_t *ppos,
@@ -912,8 +911,8 @@ const struct file_operations nfs_file_operations = {
 	.llseek		= nfs_file_llseek,
 	.read		= do_sync_read,
 	.write		= do_sync_write,
-	.aio_read	= nfs_file_read,
-	.aio_write	= nfs_file_write,
+	.read_iter	= nfs_file_read_iter,
+	.write_iter	= nfs_file_write_iter,
 	.mmap		= nfs_file_mmap,
 	.open		= nfs_file_open,
 	.flush		= nfs_file_flush,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 05521ca..51c5f52 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -301,11 +301,11 @@ int nfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *)
 int nfs_file_fsync_commit(struct file *, loff_t, loff_t, int);
 loff_t nfs_file_llseek(struct file *, loff_t, int);
 int nfs_file_flush(struct file *, fl_owner_t);
-ssize_t nfs_file_read(struct kiocb *, const struct iovec *, unsigned long, loff_t);
+ssize_t nfs_file_read_iter(struct kiocb *, struct iov_iter *, loff_t);
 ssize_t nfs_file_splice_read(struct file *, loff_t *, struct pipe_inode_info *,
 			     size_t, unsigned int);
 int nfs_file_mmap(struct file *, struct vm_area_struct *);
-ssize_t nfs_file_write(struct kiocb *, const struct iovec *, unsigned long, loff_t);
+ssize_t nfs_file_write_iter(struct kiocb *, struct iov_iter *, loff_t);
 int nfs_file_release(struct inode *, struct file *);
 int nfs_lock(struct file *, int, struct file_lock *);
 int nfs_flock(struct file *, int, struct file_lock *);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index afddd66..de6f644 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -121,8 +121,8 @@ const struct file_operations nfs4_file_operations = {
 	.llseek		= nfs_file_llseek,
 	.read		= do_sync_read,
 	.write		= do_sync_write,
-	.aio_read	= nfs_file_read,
-	.aio_write	= nfs_file_write,
+	.read_iter	= nfs_file_read_iter,
+	.write_iter	= nfs_file_write_iter,
 	.mmap		= nfs_file_mmap,
 	.open		= nfs4_file_open,
 	.flush		= nfs_file_flush,
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 4913e3c..9f8e8a9 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -445,11 +445,9 @@ extern int nfs3_removexattr (struct dentry *, const char *name);
  * linux/fs/nfs/direct.c
  */
 extern ssize_t nfs_direct_IO(int, struct kiocb *, struct iov_iter *, loff_t);
-extern ssize_t nfs_file_direct_read(struct kiocb *iocb,
-			const struct iovec *iov, unsigned long nr_segs,
+extern ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter,
 			loff_t pos, bool uio);
-extern ssize_t nfs_file_direct_write(struct kiocb *iocb,
-			const struct iovec *iov, unsigned long nr_segs,
+extern ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
 			loff_t pos, bool uio);
 
 /*
-- 
1.8.0

