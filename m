Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4083 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932786Ab2DTSsQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:48:16 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 15/25] NFS: merge _full and _partial write rpc_ops
Date: Fri, 20 Apr 2012 14:47:47 -0400
Message-Id: <1334947677-28864-16-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Decouple nfs_pgio_header and nfs_write_data, and have (possibly
multiple) nfs_write_datas each take a refcount on nfs_pgio_header.

For the moment keeps nfs_write_header as a way to preallocate a single
nfs_write_data with the nfs_pgio_header.  The code doesn't need this,
and would be prettier without, but given the amount of churn I am
already introducing I didn't want to play with tuning new mempools.

This also fixes bug in pnfs_ld_handle_write_error.  In the case of
desc->pg_bsize < PAGE_CACHE_SIZE, the pages list was empty, causing
replay attempt to do nothing.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c         |   10 +-
 fs/nfs/internal.h       |    8 +-
 fs/nfs/nfs4filelayout.c |    1 -
 fs/nfs/nfs4proc.c       |    4 +-
 fs/nfs/pnfs.c           |   58 +++++---
 fs/nfs/write.c          |  383 +++++++++++++++++++++--------------------------
 include/linux/nfs_xdr.h |    2 +
 7 files changed, 227 insertions(+), 239 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 90b00ce..22a40c4 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -768,11 +768,17 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		bytes = min(wsize,count);
 
 		result = -ENOMEM;
-		whdr = nfs_writehdr_alloc(nfs_page_array_len(pgbase, bytes));
+		whdr = nfs_writehdr_alloc();
 		if (unlikely(!whdr))
 			break;
 
-		data = &whdr->rpc_data;
+		data = nfs_writedata_alloc(&whdr->header, nfs_page_array_len(pgbase, bytes));
+		if (!data) {
+			nfs_writehdr_free(&whdr->header);
+			break;
+		}
+		data->header = &whdr->header;
+		atomic_inc(&data->header->refcnt);
 		pages = &data->pages;
 
 		down_read(&current->mm->mmap_sem);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ae550f5..d05e352 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -319,10 +319,14 @@ extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_readdata_release(struct nfs_read_data *rdata);
 
 /* write.c */
-extern struct nfs_write_header *nfs_writehdr_alloc(unsigned int npages);
+extern void nfs_async_write_error(struct list_head *head);
+extern struct nfs_write_header *nfs_writehdr_alloc(void);
 extern void nfs_writehdr_free(struct nfs_pgio_header *hdr);
+extern struct nfs_write_data *nfs_writedata_alloc(struct nfs_pgio_header *hdr,
+						  unsigned int pagecount);
+extern void nfs_write_completion(struct nfs_pgio_header *hdr);
 extern int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
-		struct list_head *head);
+			     struct nfs_pgio_header *hdr);
 extern void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
 				  struct inode *inode, int ioflags);
 extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 333e765..02d8170 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -314,7 +314,6 @@ static void filelayout_write_release(void *data)
 {
 	struct nfs_write_data *wdata = data;
 
-	put_lseg(wdata->header->lseg);
 	wdata->header->mds_ops->rpc_release(data);
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 16a3877..6365b02 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3376,8 +3376,6 @@ void nfs4_reset_write(struct rpc_task *task, struct nfs_write_data *data)
 	struct inode *inode = hdr->inode;
 
 	dprintk("%s Reset task for i/o through\n", __func__);
-	put_lseg(hdr->lseg);
-	hdr->lseg        = NULL;
 	data->ds_clp     = NULL;
 	data->write_done_cb = nfs4_write_done_cb;
 	data->args.fh       = NFS_FH(inode);
@@ -3393,7 +3391,7 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 {
 	struct nfs_server *server = NFS_SERVER(data->header->inode);
 
-	if (data->header->lseg) {
+	if (data->ds_clp) {
 		data->args.bitmask = NULL;
 		data->res.fattr = NULL;
 	} else
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5947a90..2b89b54 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1199,7 +1199,9 @@ static void pnfs_ld_handle_write_error(struct nfs_write_data *data)
 		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(hdr->inode)->flags);
 		pnfs_return_layout(hdr->inode);
 	}
-	data->task.tk_status = pnfs_write_done_resend_to_mds(hdr->inode, &hdr->pages);
+	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags))
+		data->task.tk_status = pnfs_write_done_resend_to_mds(hdr->inode,
+								&hdr->pages);
 }
 
 /*
@@ -1214,7 +1216,6 @@ void pnfs_ld_write_done(struct nfs_write_data *data)
 		hdr->mds_ops->rpc_call_done(&data->task, data);
 	} else
 		pnfs_ld_handle_write_error(data);
-	put_lseg(hdr->lseg);
 	hdr->mds_ops->rpc_release(data);
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_write_done);
@@ -1225,12 +1226,11 @@ pnfs_write_through_mds(struct nfs_pageio_descriptor *desc,
 {
 	struct nfs_pgio_header *hdr = data->header;
 
-	list_splice_tail_init(&hdr->pages, &desc->pg_list);
-	if (hdr->req && list_empty(&hdr->req->wb_list))
-		nfs_list_add_request(hdr->req, &desc->pg_list);
-	nfs_pageio_reset_write_mds(desc);
-	desc->pg_recoalesce = 1;
-	put_lseg(hdr->lseg);
+	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
+		list_splice_tail_init(&hdr->pages, &desc->pg_list);
+		nfs_pageio_reset_write_mds(desc);
+		desc->pg_recoalesce = 1;
+	}
 	nfs_writedata_release(data);
 }
 
@@ -1246,18 +1246,12 @@ pnfs_try_to_write_data(struct nfs_write_data *wdata,
 	struct nfs_server *nfss = NFS_SERVER(inode);
 
 	hdr->mds_ops = call_ops;
-	hdr->lseg = get_lseg(lseg);
 
 	dprintk("%s: Writing ino:%lu %u@%llu (how %d)\n", __func__,
 		inode->i_ino, wdata->args.count, wdata->args.offset, how);
-
 	trypnfs = nfss->pnfs_curr_ld->write_pagelist(wdata, how);
-	if (trypnfs == PNFS_NOT_ATTEMPTED) {
-		put_lseg(hdr->lseg);
-		hdr->lseg = NULL;
-	} else
+	if (trypnfs != PNFS_NOT_ATTEMPTED)
 		nfs_inc_stats(inode, NFSIOS_PNFS_WRITE);
-
 	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
 	return trypnfs;
 }
@@ -1273,7 +1267,7 @@ pnfs_do_multiple_writes(struct nfs_pageio_descriptor *desc, struct list_head *he
 	while (!list_empty(head)) {
 		enum pnfs_try_status trypnfs;
 
-		data = list_entry(head->next, struct nfs_write_data, list);
+		data = list_first_entry(head, struct nfs_write_data, list);
 		list_del_init(&data->list);
 
 		trypnfs = pnfs_try_to_write_data(data, call_ops, lseg, how);
@@ -1283,20 +1277,40 @@ pnfs_do_multiple_writes(struct nfs_pageio_descriptor *desc, struct list_head *he
 	put_lseg(lseg);
 }
 
+static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
+{
+	put_lseg(hdr->lseg);
+	nfs_writehdr_free(hdr);
+}
+
 int
 pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 {
-	LIST_HEAD(head);
+	struct nfs_write_header *whdr;
+	struct nfs_pgio_header *hdr;
 	int ret;
 
-	ret = nfs_generic_flush(desc, &head);
-	if (ret != 0) {
+	whdr = nfs_writehdr_alloc();
+	if (!whdr) {
+		nfs_async_write_error(&desc->pg_list);
 		put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
-		return ret;
+		return -ENOMEM;
 	}
-	pnfs_do_multiple_writes(desc, &head, desc->pg_ioflags);
-	return 0;
+	hdr = &whdr->header;
+	nfs_pgheader_init(desc, hdr, pnfs_writehdr_free);
+	hdr->lseg = get_lseg(desc->pg_lseg);
+	atomic_inc(&hdr->refcnt);
+	ret = nfs_generic_flush(desc, hdr);
+	if (ret != 0) {
+		put_lseg(desc->pg_lseg);
+		desc->pg_lseg = NULL;
+		set_bit(NFS_IOHDR_REDO, &hdr->flags);
+	} else
+		pnfs_do_multiple_writes(desc, &hdr->rpc_list, desc->pg_ioflags);
+	if (atomic_dec_and_test(&hdr->refcnt))
+		nfs_write_completion(hdr);
+	return ret;
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2efae04..076075e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -42,8 +42,7 @@
 static void nfs_pageio_init_write(struct nfs_pageio_descriptor *desc,
 				  struct inode *inode, int ioflags);
 static void nfs_redirty_request(struct nfs_page *req);
-static const struct rpc_call_ops nfs_write_partial_ops;
-static const struct rpc_call_ops nfs_write_full_ops;
+static const struct rpc_call_ops nfs_write_common_ops;
 static const struct rpc_call_ops nfs_commit_ops;
 
 static struct kmem_cache *nfs_wdata_cachep;
@@ -69,26 +68,47 @@ void nfs_commit_free(struct nfs_commit_data *p)
 }
 EXPORT_SYMBOL_GPL(nfs_commit_free);
 
-struct nfs_write_header *nfs_writehdr_alloc(unsigned int pagecount)
+struct nfs_write_header *nfs_writehdr_alloc(void)
 {
 	struct nfs_write_header *p = mempool_alloc(nfs_wdata_mempool, GFP_NOFS);
 
 	if (p) {
 		struct nfs_pgio_header *hdr = &p->header;
-		struct nfs_write_data *data = &p->rpc_data;
 
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&hdr->pages);
-		INIT_LIST_HEAD(&data->list);
-		data->header = hdr;
-		if (!nfs_pgarray_set(&data->pages, pagecount)) {
-			mempool_free(p, nfs_wdata_mempool);
-			p = NULL;
-		}
+		INIT_LIST_HEAD(&hdr->rpc_list);
+		spin_lock_init(&hdr->lock);
+		atomic_set(&hdr->refcnt, 0);
 	}
 	return p;
 }
 
+struct nfs_write_data *nfs_writedata_alloc(struct nfs_pgio_header *hdr,
+					   unsigned int pagecount)
+{
+	struct nfs_write_data *data, *prealloc;
+
+	prealloc = &container_of(hdr, struct nfs_write_header, header)->rpc_data;
+	if (prealloc->header == NULL)
+		data = prealloc;
+	else
+		data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (!data)
+		goto out;
+
+	if (nfs_pgarray_set(&data->pages, pagecount)) {
+		data->header = hdr;
+		atomic_inc(&hdr->refcnt);
+	} else {
+		if (data != prealloc)
+			kfree(data);
+		data = NULL;
+	}
+out:
+	return data;
+}
+
 void nfs_writehdr_free(struct nfs_pgio_header *hdr)
 {
 	struct nfs_write_header *whdr = container_of(hdr, struct nfs_write_header, header);
@@ -97,10 +117,18 @@ void nfs_writehdr_free(struct nfs_pgio_header *hdr)
 
 void nfs_writedata_release(struct nfs_write_data *wdata)
 {
+	struct nfs_pgio_header *hdr = wdata->header;
+	struct nfs_write_header *write_header = container_of(hdr, struct nfs_write_header, header);
+
 	put_nfs_open_context(wdata->args.context);
 	if (wdata->pages.pagevec != wdata->pages.page_array)
 		kfree(wdata->pages.pagevec);
-	nfs_writehdr_free(wdata->header);
+	if (wdata != &write_header->rpc_data)
+		kfree(wdata);
+	else
+		wdata->header = NULL;
+	if (atomic_dec_and_test(&hdr->refcnt))
+		nfs_write_completion(hdr);
 }
 
 static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
@@ -511,20 +539,6 @@ int nfs_write_need_commit(struct nfs_write_data *data)
 	return data->verf.committed != NFS_FILE_SYNC;
 }
 
-static inline
-int nfs_reschedule_unstable_write(struct nfs_page *req,
-				  struct nfs_write_data *data)
-{
-	if (test_and_clear_bit(PG_NEED_COMMIT, &req->wb_flags)) {
-		nfs_mark_request_commit(req, data->header->lseg);
-		return 1;
-	}
-	if (test_and_clear_bit(PG_NEED_RESCHED, &req->wb_flags)) {
-		nfs_mark_request_dirty(req);
-		return 1;
-	}
-	return 0;
-}
 #else
 static void
 nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
@@ -542,13 +556,43 @@ int nfs_write_need_commit(struct nfs_write_data *data)
 	return 0;
 }
 
-static inline
-int nfs_reschedule_unstable_write(struct nfs_page *req,
-				  struct nfs_write_data *data)
+#endif
+
+void nfs_write_completion(struct nfs_pgio_header *hdr)
 {
-	return 0;
+	unsigned long bytes = 0;
+
+	if (test_bit(NFS_IOHDR_REDO, &hdr->flags))
+		goto out;
+	while (!list_empty(&hdr->pages)) {
+		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
+		struct page *page = req->wb_page;
+
+		bytes += req->wb_bytes;
+		nfs_list_remove_request(req);
+		if (test_bit(NFS_IOHDR_ERROR, &hdr->flags) &&
+		    (hdr->good_bytes < bytes)) {
+			nfs_set_pageerror(page);
+			nfs_context_set_write_error(req->wb_context, hdr->error);
+			goto remove_req;
+		}
+		if (test_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags)) {
+			nfs_mark_request_dirty(req);
+			goto next;
+		}
+		if (test_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags)) {
+			nfs_mark_request_commit(req, hdr->lseg);
+			goto next;
+		}
+remove_req:
+		nfs_inode_remove_request(req);
+next:
+		nfs_unlock_request(req);
+		nfs_end_page_writeback(page);
+	}
+out:
+	hdr->release(hdr);
 }
-#endif
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 static int
@@ -813,17 +857,6 @@ int nfs_updatepage(struct file *file, struct page *page,
 	return status;
 }
 
-static void nfs_writepage_release(struct nfs_page *req,
-				  struct nfs_write_data *data)
-{
-	struct page *page = req->wb_page;
-
-	if (PageError(req->wb_page) || !nfs_reschedule_unstable_write(req, data))
-		nfs_inode_remove_request(req);
-	nfs_unlock_request(req);
-	nfs_end_page_writeback(page);
-}
-
 static int flush_task_priority(int how)
 {
 	switch (how & (FLUSH_HIGHPRI|FLUSH_LOWPRI)) {
@@ -890,22 +923,16 @@ EXPORT_SYMBOL_GPL(nfs_initiate_write);
 /*
  * Set up the argument/result storage required for the RPC call.
  */
-static void nfs_write_rpcsetup(struct nfs_page *req,
-		struct nfs_write_data *data,
+static void nfs_write_rpcsetup(struct nfs_write_data *data,
 		unsigned int count, unsigned int offset,
 		int how)
 {
-	struct nfs_pgio_header *hdr = data->header;
-	struct inode *inode = req->wb_context->dentry->d_inode;
+	struct nfs_page *req = data->header->req;
 
 	/* Set up the RPC argument and reply structs
 	 * NB: take care not to mess about with data->commit et al. */
 
-	hdr->req = req;
-	hdr->inode = inode = req->wb_context->dentry->d_inode;
-	hdr->cred = req->wb_context->cred;
-
-	data->args.fh     = NFS_FH(inode);
+	data->args.fh     = NFS_FH(data->header->inode);
 	data->args.offset = req_offset(req) + offset;
 	/* pnfs_set_layoutcommit needs this */
 	data->mds_offset = data->args.offset;
@@ -919,7 +946,7 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 	case 0:
 		break;
 	case FLUSH_COND_STABLE:
-		if (nfs_need_commit(NFS_I(inode)))
+		if (nfs_need_commit(NFS_I(data->header->inode)))
 			break;
 	default:
 		data->args.stable = NFS_FILE_SYNC;
@@ -950,7 +977,7 @@ static int nfs_do_multiple_writes(struct list_head *head,
 	while (!list_empty(head)) {
 		int ret2;
 
-		data = list_entry(head->next, struct nfs_write_data, list);
+		data = list_first_entry(head, struct nfs_write_data, list);
 		list_del_init(&data->list);
 		
 		ret2 = nfs_do_write(data, call_ops, how);
@@ -973,15 +1000,26 @@ static void nfs_redirty_request(struct nfs_page *req)
 	nfs_end_page_writeback(page);
 }
 
+void nfs_async_write_error(struct list_head *head)
+{
+	struct nfs_page	*req;
+
+	while (!list_empty(head)) {
+		req = nfs_list_entry(head->next);
+		nfs_list_remove_request(req);
+		nfs_redirty_request(req);
+	}
+}
+
 /*
  * Generate multiple small requests to write out a single
  * contiguous dirty area on one page.
  */
-static int nfs_flush_multi(struct nfs_pageio_descriptor *desc, struct list_head *res)
+static int nfs_flush_multi(struct nfs_pageio_descriptor *desc,
+			   struct nfs_pgio_header *hdr)
 {
-	struct nfs_page *req = nfs_list_entry(desc->pg_list.next);
+	struct nfs_page *req = hdr->req;
 	struct page *page = req->wb_page;
-	struct nfs_write_header *whdr;
 	struct nfs_write_data *data;
 	size_t wsize = desc->pg_bsize, nbytes;
 	unsigned int offset;
@@ -989,6 +1027,7 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc, struct list_head
 	int ret = 0;
 
 	nfs_list_remove_request(req);
+	nfs_list_add_request(req, &hdr->pages);
 
 	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
 	    (desc->pg_moreio || NFS_I(desc->pg_inode)->ncommit ||
@@ -1001,28 +1040,27 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc, struct list_head
 	do {
 		size_t len = min(nbytes, wsize);
 
-		whdr = nfs_writehdr_alloc(1);
-		if (!whdr)
+		data = nfs_writedata_alloc(hdr, 1);
+		if (!data)
 			goto out_bad;
-		data = &whdr->rpc_data;
 		data->pages.pagevec[0] = page;
-		nfs_write_rpcsetup(req, data, len, offset, desc->pg_ioflags);
-		list_add(&data->list, res);
+		nfs_write_rpcsetup(data, len, offset, desc->pg_ioflags);
+		list_add(&data->list, &hdr->rpc_list);
 		requests++;
 		nbytes -= len;
 		offset += len;
 	} while (nbytes != 0);
 	atomic_set(&req->wb_complete, requests);
-	desc->pg_rpc_callops = &nfs_write_partial_ops;
+	desc->pg_rpc_callops = &nfs_write_common_ops;
 	return ret;
 
 out_bad:
-	while (!list_empty(res)) {
-		data = list_entry(res->next, struct nfs_write_data, list);
+	while (!list_empty(&hdr->rpc_list)) {
+		data = list_first_entry(&hdr->rpc_list, struct nfs_write_data, list);
 		list_del(&data->list);
 		nfs_writedata_release(data);
 	}
-	nfs_redirty_request(req);
+	nfs_async_write_error(&hdr->pages);
 	return -ENOMEM;
 }
 
@@ -1034,64 +1072,74 @@ out_bad:
  * This is the case if nfs_updatepage detects a conflicting request
  * that has been written but not committed.
  */
-static int nfs_flush_one(struct nfs_pageio_descriptor *desc, struct list_head *res)
+static int nfs_flush_one(struct nfs_pageio_descriptor *desc,
+			 struct nfs_pgio_header *hdr)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
-	struct nfs_write_header	*whdr;
 	struct nfs_write_data	*data;
 	struct list_head *head = &desc->pg_list;
 	int ret = 0;
 
-	whdr = nfs_writehdr_alloc(nfs_page_array_len(desc->pg_base,
-						     desc->pg_count));
-	if (!whdr) {
-		while (!list_empty(head)) {
-			req = nfs_list_entry(head->next);
-			nfs_list_remove_request(req);
-			nfs_redirty_request(req);
-		}
+	data = nfs_writedata_alloc(hdr, nfs_page_array_len(desc->pg_base,
+							   desc->pg_count));
+	if (!data) {
+		nfs_async_write_error(head);
 		ret = -ENOMEM;
 		goto out;
 	}
-	data = &whdr->rpc_data;
+
 	pages = data->pages.pagevec;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
-		nfs_list_add_request(req, &whdr->header.pages);
+		nfs_list_add_request(req, &hdr->pages);
 		*pages++ = req->wb_page;
 	}
-	req = nfs_list_entry(whdr->header.pages.next);
 
 	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
 	    (desc->pg_moreio || NFS_I(desc->pg_inode)->ncommit))
 		desc->pg_ioflags &= ~FLUSH_COND_STABLE;
 
 	/* Set up the argument struct */
-	nfs_write_rpcsetup(req, data, desc->pg_count, 0, desc->pg_ioflags);
-	list_add(&data->list, res);
-	desc->pg_rpc_callops = &nfs_write_full_ops;
+	nfs_write_rpcsetup(data, desc->pg_count, 0, desc->pg_ioflags);
+	list_add(&data->list, &hdr->rpc_list);
+	desc->pg_rpc_callops = &nfs_write_common_ops;
 out:
 	return ret;
 }
 
-int nfs_generic_flush(struct nfs_pageio_descriptor *desc, struct list_head *head)
+int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
+		      struct nfs_pgio_header *hdr)
 {
 	if (desc->pg_bsize < PAGE_CACHE_SIZE)
-		return nfs_flush_multi(desc, head);
-	return nfs_flush_one(desc, head);
+		return nfs_flush_multi(desc, hdr);
+	return nfs_flush_one(desc, hdr);
 }
 
 static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 {
-	LIST_HEAD(head);
+	struct nfs_write_header *whdr;
+	struct nfs_pgio_header *hdr;
 	int ret;
 
-	ret = nfs_generic_flush(desc, &head);
+	whdr = nfs_writehdr_alloc();
+	if (!whdr) {
+		nfs_async_write_error(&desc->pg_list);
+		return -ENOMEM;
+	}
+	hdr = &whdr->header;
+	nfs_pgheader_init(desc, hdr, nfs_writehdr_free);
+	atomic_inc(&hdr->refcnt);
+	ret = nfs_generic_flush(desc, hdr);
 	if (ret == 0)
-		ret = nfs_do_multiple_writes(&head, desc->pg_rpc_callops,
-				desc->pg_ioflags);
+		ret = nfs_do_multiple_writes(&hdr->rpc_list,
+					     desc->pg_rpc_callops,
+					     desc->pg_ioflags);
+	else
+		set_bit(NFS_IOHDR_REDO, &hdr->flags);
+	if (atomic_dec_and_test(&hdr->refcnt))
+		nfs_write_completion(hdr);
 	return ret;
 }
 
@@ -1121,62 +1169,6 @@ static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 		nfs_pageio_init_write_mds(pgio, inode, ioflags);
 }
 
-/*
- * Handle a write reply that flushed part of a page.
- */
-static void nfs_writeback_done_partial(struct rpc_task *task, void *calldata)
-{
-	struct nfs_write_data	*data = calldata;
-
-	dprintk("NFS: %5u write(%s/%lld %d@%lld)",
-		task->tk_pid,
-		data->header->inode->i_sb->s_id,
-		(long long)
-		  NFS_FILEID(data->header->inode),
-		data->header->req->wb_bytes,
-		(long long)req_offset(data->header->req));
-
-	nfs_writeback_done(task, data);
-}
-
-static void nfs_writeback_release_partial(void *calldata)
-{
-	struct nfs_write_data	*data = calldata;
-	struct nfs_page		*req = data->header->req;
-	struct page		*page = req->wb_page;
-	int status = data->task.tk_status;
-
-	if (status < 0) {
-		nfs_set_pageerror(page);
-		nfs_context_set_write_error(req->wb_context, status);
-		dprintk(", error = %d\n", status);
-		goto out;
-	}
-
-	if (nfs_write_need_commit(data)) {
-		struct inode *inode = page->mapping->host;
-
-		spin_lock(&inode->i_lock);
-		if (test_bit(PG_NEED_RESCHED, &req->wb_flags)) {
-			/* Do nothing we need to resend the writes */
-		} else if (!test_and_set_bit(PG_NEED_COMMIT, &req->wb_flags)) {
-			memcpy(&req->wb_verf, &data->verf, sizeof(req->wb_verf));
-			dprintk(" defer commit\n");
-		} else if (memcmp(&req->wb_verf, &data->verf, sizeof(req->wb_verf))) {
-			set_bit(PG_NEED_RESCHED, &req->wb_flags);
-			clear_bit(PG_NEED_COMMIT, &req->wb_flags);
-			dprintk(" server reboot detected\n");
-		}
-		spin_unlock(&inode->i_lock);
-	} else
-		dprintk(" OK\n");
-
-out:
-	if (atomic_dec_and_test(&req->wb_complete))
-		nfs_writepage_release(req, data);
-	nfs_writedata_release(data);
-}
-
 void nfs_write_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data *data = calldata;
@@ -1190,12 +1182,6 @@ void nfs_commit_prepare(struct rpc_task *task, void *calldata)
 	NFS_PROTO(data->inode)->commit_rpc_prepare(task, data);
 }
 
-static const struct rpc_call_ops nfs_write_partial_ops = {
-	.rpc_call_prepare = nfs_write_prepare,
-	.rpc_call_done = nfs_writeback_done_partial,
-	.rpc_release = nfs_writeback_release_partial,
-};
-
 /*
  * Handle a write reply that flushes a whole page.
  *
@@ -1203,60 +1189,37 @@ static const struct rpc_call_ops nfs_write_partial_ops = {
  *	  writebacks since the page->count is kept > 1 for as long
  *	  as the page has a write request pending.
  */
-static void nfs_writeback_done_full(struct rpc_task *task, void *calldata)
+static void nfs_writeback_done_common(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data	*data = calldata;
 
 	nfs_writeback_done(task, data);
 }
 
-static void nfs_writeback_release_full(void *calldata)
+static void nfs_writeback_release_common(void *calldata)
 {
 	struct nfs_write_data	*data = calldata;
 	struct nfs_pgio_header *hdr = data->header;
 	int status = data->task.tk_status;
+	struct nfs_page *req = hdr->req;
 
-	/* Update attributes as result of writeback. */
-	while (!list_empty(&hdr->pages)) {
-		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
-		struct page *page = req->wb_page;
-
-		nfs_list_remove_request(req);
-
-		dprintk("NFS: %5u write (%s/%lld %d@%lld)",
-			data->task.tk_pid,
-			req->wb_context->dentry->d_inode->i_sb->s_id,
-			(long long)NFS_FILEID(req->wb_context->dentry->d_inode),
-			req->wb_bytes,
-			(long long)req_offset(req));
-
-		if (status < 0) {
-			nfs_set_pageerror(page);
-			nfs_context_set_write_error(req->wb_context, status);
-			dprintk(", error = %d\n", status);
-			goto remove_request;
-		}
-
-		if (nfs_write_need_commit(data)) {
+	if ((status >= 0) && nfs_write_need_commit(data)) {
+		spin_lock(&hdr->lock);
+		if (test_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags))
+			; /* Do nothing */
+		else if (!test_and_set_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags))
 			memcpy(&req->wb_verf, &data->verf, sizeof(req->wb_verf));
-			nfs_mark_request_commit(req, hdr->lseg);
-			dprintk(" marked for commit\n");
-			goto next;
-		}
-		dprintk(" OK\n");
-remove_request:
-		nfs_inode_remove_request(req);
-	next:
-		nfs_unlock_request(req);
-		nfs_end_page_writeback(page);
+		else if (memcmp(&req->wb_verf, &data->verf, sizeof(req->wb_verf)))
+			set_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags);
+		spin_unlock(&hdr->lock);
 	}
 	nfs_writedata_release(data);
 }
 
-static const struct rpc_call_ops nfs_write_full_ops = {
+static const struct rpc_call_ops nfs_write_common_ops = {
 	.rpc_call_prepare = nfs_write_prepare,
-	.rpc_call_done = nfs_writeback_done_full,
-	.rpc_release = nfs_writeback_release_full,
+	.rpc_call_done = nfs_writeback_done_common,
+	.rpc_release = nfs_writeback_release_common,
 };
 
 
@@ -1307,38 +1270,40 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		}
 	}
 #endif
-	/* Is this a short write? */
-	if (task->tk_status >= 0 && resp->count < argp->count) {
+	if (task->tk_status < 0)
+		nfs_set_pgio_error(data->header, task->tk_status, argp->offset);
+	else if (resp->count < argp->count) {
 		static unsigned long    complain;
 
+		/* This a short write! */
 		nfs_inc_stats(inode, NFSIOS_SHORTWRITE);
 
 		/* Has the server at least made some progress? */
-		if (resp->count != 0) {
-			/* Was this an NFSv2 write or an NFSv3 stable write? */
-			if (resp->verf->committed != NFS_UNSTABLE) {
-				/* Resend from where the server left off */
-				data->mds_offset += resp->count;
-				argp->offset += resp->count;
-				argp->pgbase += resp->count;
-				argp->count -= resp->count;
-			} else {
-				/* Resend as a stable write in order to avoid
-				 * headaches in the case of a server crash.
-				 */
-				argp->stable = NFS_FILE_SYNC;
+		if (resp->count == 0) {
+			if (time_before(complain, jiffies)) {
+				printk(KERN_WARNING
+				       "NFS: Server wrote zero bytes, expected %u.\n",
+				       argp->count);
+				complain = jiffies + 300 * HZ;
 			}
-			rpc_restart_call_prepare(task);
+			nfs_set_pgio_error(data->header, -EIO, argp->offset);
+			task->tk_status = -EIO;
 			return;
 		}
-		if (time_before(complain, jiffies)) {
-			printk(KERN_WARNING
-			       "NFS: Server wrote zero bytes, expected %u.\n",
-					argp->count);
-			complain = jiffies + 300 * HZ;
+		/* Was this an NFSv2 write or an NFSv3 stable write? */
+		if (resp->verf->committed != NFS_UNSTABLE) {
+			/* Resend from where the server left off */
+			data->mds_offset += resp->count;
+			argp->offset += resp->count;
+			argp->pgbase += resp->count;
+			argp->count -= resp->count;
+		} else {
+			/* Resend as a stable write in order to avoid
+			 * headaches in the case of a server crash.
+			 */
+			argp->stable = NFS_FILE_SYNC;
 		}
-		/* Can't do anything about it except throw an error. */
-		task->tk_status = -EIO;
+		rpc_restart_call_prepare(task);
 	}
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index bf8fc99..694cfa4 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1187,6 +1187,8 @@ enum {
 	NFS_IOHDR_ERROR = 0,
 	NFS_IOHDR_EOF,
 	NFS_IOHDR_REDO,
+	NFS_IOHDR_NEED_COMMIT,
+	NFS_IOHDR_NEED_RESCHED,
 };
 
 struct nfs_pgio_header {
-- 
1.7.2.1

