Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57514 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758230Ab2DIUxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 16:53:00 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 19/26] NFS: rewrite directio read to use async coalesce code
Date: Mon,  9 Apr 2012 16:52:17 -0400
Message-Id: <1334004744-31842-20-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This also has the advantage that it allows directio to use pnfs.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c          |  247 +++++++++++++++++++++------------------------
 fs/nfs/internal.h        |    3 +
 fs/nfs/pagelist.c        |    6 +-
 fs/nfs/read.c            |    6 +-
 include/linux/nfs_page.h |    1 +
 include/linux/nfs_xdr.h  |    4 +-
 6 files changed, 128 insertions(+), 139 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 22a40c4..409a9a0 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -124,22 +124,6 @@ ssize_t nfs_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov, loff_
 	return -EINVAL;
 }
 
-static void nfs_direct_dirty_pages(struct page **pages, unsigned int pgbase, size_t count)
-{
-	unsigned int npages;
-	unsigned int i;
-
-	if (count == 0)
-		return;
-	pages += (pgbase >> PAGE_SHIFT);
-	npages = (count + (pgbase & ~PAGE_MASK) + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	for (i = 0; i < npages; i++) {
-		struct page *page = pages[i];
-		if (!PageCompound(page))
-			set_page_dirty(page);
-	}
-}
-
 static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
 {
 	unsigned int i;
@@ -226,58 +210,85 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq)
 	nfs_direct_req_release(dreq);
 }
 
-/*
- * We must hold a reference to all the pages in this direct read request
- * until the RPCs complete.  This could be long *after* we are woken up in
- * nfs_direct_wait (for instance, if someone hits ^C on a slow server).
- */
-static void nfs_direct_read_result(struct rpc_task *task, void *calldata)
+void nfs_direct_readpage_release(struct nfs_page *req)
 {
-	struct nfs_read_data *data = calldata;
-
-	nfs_readpage_result(task, data);
+	dprintk("NFS: direct read done (%s/%lld %d@%lld)\n",
+		req->wb_context->dentry->d_inode->i_sb->s_id,
+		(long long)NFS_FILEID(req->wb_context->dentry->d_inode),
+		req->wb_bytes,
+		(long long)req_offset(req));
+	nfs_release_request(req);
 }
 
-static void nfs_direct_read_release(void *calldata)
+static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 {
+	unsigned long pos = req_offset(hdr->req);
+	struct nfs_direct_req *dreq = hdr->dreq;
 
-	struct nfs_read_data *data = calldata;
-	struct nfs_direct_req *dreq = (struct nfs_direct_req *)data->header->req;
-	int status = data->task.tk_status;
+	if (test_bit(NFS_IOHDR_REDO, &hdr->flags))
+		goto out_put;
 
 	spin_lock(&dreq->lock);
-	if (unlikely(status < 0)) {
-		dreq->error = status;
-		spin_unlock(&dreq->lock);
+	if (test_bit(NFS_IOHDR_ERROR, &hdr->flags) &&
+	    (hdr->first_error == pos))
+		dreq->error = hdr->error;
+	else
+		dreq->count += (hdr->first_error - pos);
+	spin_unlock(&dreq->lock);
+
+	if (!test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
+		while (!list_empty(&hdr->pages)) {
+			struct nfs_page *req = nfs_list_entry(hdr->pages.next);
+			struct page *page = req->wb_page;
+
+			nfs_list_remove_request(req);
+			nfs_direct_readpage_release(req);
+			if (!PageCompound(page))
+				set_page_dirty(page);
+			page_cache_release(page);
+		}
 	} else {
-		dreq->count += data->res.count;
-		spin_unlock(&dreq->lock);
-		nfs_direct_dirty_pages(data->pages.pagevec,
-				data->args.pgbase,
-				data->res.count);
+		pos &= PAGE_MASK;
+		while (!list_empty(&hdr->pages)) {
+			struct nfs_page *req = nfs_list_entry(hdr->pages.next);
+
+			if (pos < (hdr->first_error & PAGE_MASK))
+				if (!PageCompound(req->wb_page))
+					set_page_dirty(req->wb_page);
+			page_cache_release(req->wb_page);
+			nfs_list_remove_request(req);
+			nfs_direct_readpage_release(req);
+			pos += PAGE_SIZE;
+		}
 	}
-	nfs_direct_release_pages(data->pages.pagevec, data->pages.npages);
-
+out_put:
 	if (put_dreq(dreq))
 		nfs_direct_complete(dreq);
-	nfs_readdata_release(data);
+	hdr->release(hdr);
 }
 
-static const struct rpc_call_ops nfs_read_direct_ops = {
-	.rpc_call_prepare = nfs_read_prepare,
-	.rpc_call_done = nfs_direct_read_result,
-	.rpc_release = nfs_direct_read_release,
-};
-
-static void nfs_direct_readhdr_release(struct nfs_read_header *rhdr)
+static void nfs_sync_pgio_error(struct list_head *head)
 {
-	struct nfs_read_data *data = &rhdr->rpc_data;
+	struct nfs_page *req;
 
-	if (data->pages.pagevec != data->pages.page_array)
-		kfree(data->pages.pagevec);
-	nfs_readhdr_free(&rhdr->header);
+	while (!list_empty(head)) {
+		req = nfs_list_entry(head->next);
+		nfs_list_remove_request(req);
+		nfs_release_request(req);
+	}
 }
 
+static void nfs_direct_pgio_init(struct nfs_pgio_header *hdr)
+{
+	get_dreq(hdr->dreq);
+}
+
+static const struct nfs_io_completion_ops nfs_direct_read_compl_ops = {
+	.error_cleanup = nfs_sync_pgio_error,
+	.init_hdr = nfs_direct_pgio_init,
+	.completion = nfs_direct_read_completion,
+};
+
 /*
  * For each rsize'd chunk of the user's buffer, dispatch an NFS READ
  * operation.  If nfs_readdata_alloc() or get_user_pages() fails,
@@ -285,118 +296,85 @@ static void nfs_direct_readhdr_release(struct nfs_read_header *rhdr)
  * handled automatically by nfs_direct_read_result().  Otherwise, if
  * no requests have been sent, just return an error.
  */
-static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
+static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *desc,
 						const struct iovec *iov,
 						loff_t pos)
 {
+	struct nfs_direct_req *dreq = desc->pg_dreq;
 	struct nfs_open_context *ctx = dreq->ctx;
 	struct inode *inode = ctx->dentry->d_inode;
 	unsigned long user_addr = (unsigned long)iov->iov_base;
 	size_t count = iov->iov_len;
 	size_t rsize = NFS_SERVER(inode)->rsize;
-	struct rpc_task *task;
-	struct rpc_message msg = {
-		.rpc_cred = ctx->cred,
-	};
-	struct rpc_task_setup task_setup_data = {
-		.rpc_client = NFS_CLIENT(inode),
-		.rpc_message = &msg,
-		.callback_ops = &nfs_read_direct_ops,
-		.workqueue = nfsiod_workqueue,
-		.flags = RPC_TASK_ASYNC,
-	};
 	unsigned int pgbase;
 	int result;
 	ssize_t started = 0;
+	struct page **pagevec = NULL;
+	unsigned int npages;
 
 	do {
-		struct nfs_read_header *rhdr;
-		struct nfs_read_data *data;
-		struct nfs_page_array *pages;
 		size_t bytes;
+		int i;
 
 		pgbase = user_addr & ~PAGE_MASK;
-		bytes = min(rsize,count);
+		bytes = min(max(rsize, PAGE_SIZE), count);
 
 		result = -ENOMEM;
-		rhdr = nfs_readhdr_alloc();
-		if (unlikely(!rhdr))
-			break;
-		data = nfs_readdata_alloc(&rhdr->header, nfs_page_array_len(pgbase, bytes));
-		if (!data) {
-			nfs_readhdr_free(&rhdr->header);
+		npages = nfs_page_array_len(pgbase, bytes);
+		if (!pagevec)
+			pagevec = kmalloc(npages * sizeof(struct page *),
+					  GFP_KERNEL);
+		if (!pagevec)
 			break;
-		}
-		data->header = &rhdr->header;
-		atomic_inc(&data->header->refcnt);
-		pages = &data->pages;
-
 		down_read(&current->mm->mmap_sem);
 		result = get_user_pages(current, current->mm, user_addr,
-					pages->npages, 1, 0, pages->pagevec, NULL);
+					npages, 1, 0, pagevec, NULL);
 		up_read(&current->mm->mmap_sem);
-		if (result < 0) {
-			nfs_direct_readhdr_release(rhdr);
+		if (result < 0)
 			break;
-		}
-		if ((unsigned)result < pages->npages) {
+		if ((unsigned)result < npages) {
 			bytes = result * PAGE_SIZE;
 			if (bytes <= pgbase) {
-				nfs_direct_release_pages(pages->pagevec, result);
-				nfs_direct_readhdr_release(rhdr);
+				nfs_direct_release_pages(pagevec, result);
 				break;
 			}
 			bytes -= pgbase;
-			pages->npages = result;
+			npages = result;
 		}
 
-		get_dreq(dreq);
-
-		rhdr->header.req = (struct nfs_page *) dreq;
-		rhdr->header.inode = inode;
-		rhdr->header.cred = msg.rpc_cred;
-		data->args.fh = NFS_FH(inode);
-		data->args.context = get_nfs_open_context(ctx);
-		data->args.lock_context = dreq->l_ctx;
-		data->args.offset = pos;
-		data->args.pgbase = pgbase;
-		data->args.pages = pages->pagevec;
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
-			break;
-
-		dprintk("NFS: %5u initiated direct read call "
-			"(req %s/%Ld, %zu bytes @ offset %Lu)\n",
-				task->tk_pid,
-				inode->i_sb->s_id,
-				(long long)NFS_FILEID(inode),
-				bytes,
-				(unsigned long long)data->args.offset);
-		rpc_put_task(task);
-
-		started += bytes;
-		user_addr += bytes;
-		pos += bytes;
-		/* FIXME: Remove this unnecessary math from final patch */
-		pgbase += bytes;
-		pgbase &= ~PAGE_MASK;
-		BUG_ON(pgbase != (user_addr & ~PAGE_MASK));
-
-		count -= bytes;
+		for (i = 0; i < npages; i++) {
+			struct nfs_page *req;
+			unsigned int req_len = min(bytes, PAGE_SIZE - pgbase);
+			/* XXX do we need to do the eof zeroing found in async_filler? */
+			req = nfs_create_request(dreq->ctx, dreq->inode,
+						 pagevec[i],
+						 pgbase, req_len);
+			if (IS_ERR(req)) {
+				nfs_direct_release_pages(pagevec + i,
+							 npages - i);
+				result = PTR_ERR(req);
+				break;
+			}
+			req->wb_index = pos >> PAGE_SHIFT;
+			req->wb_offset = pos & ~PAGE_MASK;
+			if (!nfs_pageio_add_request(desc, req)) {
+				result = desc->pg_error;
+				nfs_release_request(req);
+				nfs_direct_release_pages(pagevec + i,
+							 npages - i);
+				break;
+			}
+			pgbase = 0;
+			bytes -= req_len;
+			started += req_len;
+			user_addr += req_len;
+			pos += req_len;
+			count -= req_len;
+		}
 	} while (count != 0);
 
+	kfree(pagevec);
+
 	if (started)
 		return started;
 	return result < 0 ? (ssize_t) result : -EFAULT;
@@ -407,15 +385,18 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 					      unsigned long nr_segs,
 					      loff_t pos)
 {
+	struct nfs_pageio_descriptor desc;
 	ssize_t result = -EINVAL;
 	size_t requested_bytes = 0;
 	unsigned long seg;
 
+	nfs_pageio_init_read(&desc, dreq->inode, &nfs_direct_read_compl_ops);
 	get_dreq(dreq);
+	desc.pg_dreq = dreq;
 
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];
-		result = nfs_direct_read_schedule_segment(dreq, vec, pos);
+		result = nfs_direct_read_schedule_segment(&desc, vec, pos);
 		if (result < 0)
 			break;
 		requested_bytes += result;
@@ -424,6 +405,8 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 		pos += vec->iov_len;
 	}
 
+	nfs_pageio_complete(&desc);
+
 	/*
 	 * If no bytes were started, return the error, and let the
 	 * generic layer handle the completion.
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index efa5124..63fff81 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -307,6 +307,9 @@ extern struct nfs_read_header *nfs_readhdr_alloc(void);
 extern void nfs_readhdr_free(struct nfs_pgio_header *hdr);
 extern struct nfs_read_data *nfs_readdata_alloc(struct nfs_pgio_header *hdr,
 						unsigned int pagecount);
+extern void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
+				 struct inode *inode,
+				 const struct nfs_io_completion_ops *compl_ops);
 extern int nfs_initiate_read(struct rpc_clnt *clnt,
 			     struct nfs_read_data *data,
 			     const struct rpc_call_ops *call_ops);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index bd201d1..1a73f01 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -47,8 +47,11 @@ void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
 	hdr->inode = desc->pg_inode;
 	hdr->cred = hdr->req->wb_context->cred;
 	hdr->first_error = req_offset(hdr->req) + desc->pg_count;
+	hdr->dreq = desc->pg_dreq;
 	hdr->release = release;
 	hdr->compl_ops = desc->pg_compl_ops;
+	if (hdr->compl_ops->init_hdr)
+		hdr->compl_ops->init_hdr(hdr);
 }
 
 void nfs_set_pgio_error(struct nfs_pgio_header *hdr, int error,
@@ -115,8 +118,6 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	req->wb_index	= page->index;
 	page_cache_get(page);
 	BUG_ON(PagePrivate(page));
-	BUG_ON(!PageLocked(page));
-	BUG_ON(page->mapping->host != inode);
 	req->wb_offset  = offset;
 	req->wb_pgbase	= offset;
 	req->wb_bytes   = count;
@@ -255,6 +256,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_ioflags = io_flags;
 	desc->pg_error = 0;
 	desc->pg_lseg = NULL;
+	desc->pg_dreq = NULL;
 }
 
 /**
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 4704f120..3c09e4b 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -117,9 +117,9 @@ void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio)
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_reset_read_mds);
 
-static void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
-				 struct inode *inode,
-				 const struct nfs_io_completion_ops *compl_ops)
+void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
+			  struct inode *inode,
+			  const struct nfs_io_completion_ops *compl_ops)
 {
 	if (!pnfs_pageio_init_read(pgio, inode, compl_ops))
 		nfs_pageio_init_read_mds(pgio, inode, compl_ops);
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 1198f18..1809b52 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -68,6 +68,7 @@ struct nfs_pageio_descriptor {
 	const struct rpc_call_ops *pg_rpc_callops;
 	const struct nfs_io_completion_ops *pg_compl_ops;
 	struct pnfs_layout_segment *pg_lseg;
+	struct nfs_direct_req	*pg_dreq;
 };
 
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b38950c..61fd160 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1202,6 +1202,7 @@ struct nfs_pgio_header {
 	const struct rpc_call_ops *mds_ops;
 	void (*release) (struct nfs_pgio_header *hdr);
 	const struct nfs_io_completion_ops *compl_ops;
+	struct nfs_direct_req	*dreq;
 	spinlock_t		lock;
 	/* fields protected by lock */
 	int			pnfs_error;
@@ -1216,8 +1217,6 @@ struct nfs_read_header {
 	struct nfs_read_data	rpc_data;
 };
 
-struct nfs_direct_req;
-
 struct nfs_write_data {
 	struct nfs_pgio_header	*header;
 	struct list_head	list;
@@ -1259,6 +1258,7 @@ struct nfs_commit_data {
 
 struct nfs_io_completion_ops {
 	void	(*error_cleanup)(struct list_head *head);
+	void	(*init_hdr)(struct nfs_pgio_header *hdr);
 	void	(*completion)(struct nfs_pgio_header *hdr);
 };
 
-- 
1.7.2.1

