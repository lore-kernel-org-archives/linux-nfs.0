Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753230Ab1BDVes (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:48 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 29/40] pnfs-submit: wave3 rewrite read lseg refcounting
Date: Fri,  4 Feb 2011 16:33:51 -0500
Message-Id: <1296855242-2592-30-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-29-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
 <1296855242-2592-10-git-send-email-andros@netapp.com>
 <1296855242-2592-11-git-send-email-andros@netapp.com>
 <1296855242-2592-12-git-send-email-andros@netapp.com>
 <1296855242-2592-13-git-send-email-andros@netapp.com>
 <1296855242-2592-14-git-send-email-andros@netapp.com>
 <1296855242-2592-15-git-send-email-andros@netapp.com>
 <1296855242-2592-16-git-send-email-andros@netapp.com>
 <1296855242-2592-17-git-send-email-andros@netapp.com>
 <1296855242-2592-18-git-send-email-andros@netapp.com>
 <1296855242-2592-19-git-send-email-andros@netapp.com>
 <1296855242-2592-20-git-send-email-andros@netapp.com>
 <1296855242-2592-21-git-send-email-andros@netapp.com>
 <1296855242-2592-22-git-send-email-andros@netapp.com>
 <1296855242-2592-23-git-send-email-andros@netapp.com>
 <1296855242-2592-24-git-send-email-andros@netapp.com>
 <1296855242-2592-25-git-send-email-andros@netapp.com>
 <1296855242-2592-26-git-send-email-andros@netapp.com>
 <1296855242-2592-27-git-send-email-andros@netapp.com>
 <1296855242-2592-28-git-send-email-andros@netapp.com>
 <1296855242-2592-29-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

Shift lseg refcounting from nfs_page to nfs_read_data.

Note this will cause all writes to get a READ layout, but since
we don't actually use the layout at all for write yet, that's OK.

Also note that this and my prior patch change how the drivers need
to implement pg_test.  There are no longer two lsegs to compare, one
for each nfs_page.  Instead, there is (potentially) one attached to the
pageio_desc, which if exists we know includes the first page.

Remove unused pages from pnfs_pageio_init_read

Signed-off-by: Fred Isaman <iisaman@netapp.com>
Acked-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c  |   10 ++------
 fs/nfs/pagelist.c        |   29 +++++++++++++------------
 fs/nfs/pnfs.c            |   52 ++++++---------------------------------------
 fs/nfs/pnfs.h            |   21 ++++++++++--------
 fs/nfs/read.c            |   35 ++++++++++++++++---------------
 fs/nfs/write.c           |    6 ++--
 include/linux/nfs_page.h |    8 ++----
 include/linux/nfs_xdr.h  |    2 +-
 8 files changed, 62 insertions(+), 101 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 9b9a81c..c7ba5bc 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -118,8 +118,6 @@ static void filelayout_read_release(void *data)
 {
 	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
 
-	put_lseg(rdata->pdata.lseg);
-	rdata->pdata.lseg = NULL;
 	rdata->pdata.call_ops->rpc_release(data);
 }
 
@@ -132,7 +130,7 @@ struct rpc_call_ops filelayout_read_call_ops = {
 static enum pnfs_try_status
 filelayout_read_pagelist(struct nfs_read_data *data)
 {
-	struct pnfs_layout_segment *lseg = data->pdata.lseg;
+	struct pnfs_layout_segment *lseg = data->lseg;
 	struct nfs4_pnfs_ds *ds;
 	loff_t offset = data->args.offset;
 	u32 idx;
@@ -360,8 +358,6 @@ filelayout_free_lseg(struct pnfs_layout_segment *lseg)
  *
  * return 1 :  coalesce page
  * return 0 :  don't coalesce page
- *
- * By the time this is called, we know req->wb_lseg == prev->wb_lseg
  */
 int
 filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
@@ -370,11 +366,11 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	u64 p_stripe, r_stripe;
 	u32 stripe_unit;
 
-	if (!req->wb_lseg)
+	if (!pgio->pg_lseg)
 		return 1;
 	p_stripe = (u64)prev->wb_index << PAGE_CACHE_SHIFT;
 	r_stripe = (u64)req->wb_index << PAGE_CACHE_SHIFT;
-	stripe_unit = FILELAYOUT_LSEG(req->wb_lseg)->stripe_unit;
+	stripe_unit = FILELAYOUT_LSEG(pgio->pg_lseg)->stripe_unit;
 
 	do_div(p_stripe, stripe_unit);
 	do_div(r_stripe, stripe_unit);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 9a27592..ea3b7f8 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -54,8 +54,7 @@ nfs_page_free(struct nfs_page *p)
 struct nfs_page *
 nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 		   struct page *page,
-		   unsigned int offset, unsigned int count,
-		   struct pnfs_layout_segment *lseg)
+		   unsigned int offset, unsigned int count)
 {
 	struct nfs_page		*req;
 
@@ -86,9 +85,6 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	req->wb_bytes   = count;
 	req->wb_context = get_nfs_open_context(ctx);
 	kref_init(&req->wb_kref);
-	req->wb_lseg    = lseg;
-	if (lseg)
-		get_lseg(lseg);
 	return req;
 }
 
@@ -164,10 +160,6 @@ void nfs_clear_request(struct nfs_page *req)
 		put_nfs_open_context(ctx);
 		req->wb_context = NULL;
 	}
-	if (req->wb_lseg != NULL) {
-		put_lseg(req->wb_lseg);
-		req->wb_lseg = NULL;
-	}
 }
 
 /**
@@ -221,7 +213,7 @@ nfs_wait_on_request(struct nfs_page *req)
  */
 void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 		     struct inode *inode,
-		     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int),
+		     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *),
 		     size_t bsize,
 		     int io_flags)
 {
@@ -234,6 +226,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_doio = doio;
 	desc->pg_ioflags = io_flags;
 	desc->pg_error = 0;
+	desc->pg_lseg = NULL;
 }
 
 /**
@@ -263,8 +256,9 @@ static int nfs_can_coalesce_requests(struct nfs_page *prev,
 		return 0;
 	if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
 		return 0;
-	if (req->wb_lseg != prev->wb_lseg)
-		return 0;
+	/* For non-whole file layouts, need to check that req is inside of
+	 * pgio->pg_test.
+	 */
 #ifdef CONFIG_NFS_V4_1
 	if (pgio->pg_test && !pgio->pg_test(pgio, prev, req))
 		return 0;
@@ -303,8 +297,13 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
 		prev = nfs_list_entry(desc->pg_list.prev);
 		if (!nfs_can_coalesce_requests(prev, req, desc))
 			return 0;
-	} else
+	} else {
+		put_lseg(desc->pg_lseg);
 		desc->pg_base = req->wb_pgbase;
+		desc->pg_lseg = pnfs_update_layout(desc->pg_inode,
+						   req->wb_context,
+						   IOMODE_READ);
+	}
 	nfs_list_remove_request(req);
 	nfs_list_add_request(req, &desc->pg_list);
 	desc->pg_count = newlen;
@@ -322,7 +321,8 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
 					  nfs_page_array_len(desc->pg_base,
 							     desc->pg_count),
 					  desc->pg_count,
-					  desc->pg_ioflags);
+					  desc->pg_ioflags,
+					  desc->pg_lseg);
 		if (error < 0)
 			desc->pg_error = error;
 		else
@@ -360,6 +360,7 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
 {
 	nfs_pageio_doio(desc);
+	put_lseg(desc->pg_lseg);
 }
 
 /**
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 72786ec..76a5e00 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -716,8 +716,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo, u32 iomode)
 	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
 		    is_matching_lseg(lseg, iomode)) {
-			get_lseg(lseg);
-			ret = lseg;
+			ret = get_lseg(lseg);
 			break;
 		}
 		if (cmp_layout(iomode, lseg->pls_range.iomode) > 0)
@@ -850,8 +849,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	}
 	init_lseg(lo, lseg);
 	lseg->pls_range = res->range;
-	get_lseg(lseg);
-	*lgp->lsegpp = lseg;
+	*lgp->lsegpp = get_lseg(lseg);
 	pnfs_insert_layout(lo, lseg);
 
 	if (res->return_on_close) {
@@ -872,20 +870,13 @@ out_forget_reply:
 	goto out;
 }
 
-void
+static void
 pnfs_set_pg_test(struct inode *inode, struct nfs_pageio_descriptor *pgio)
 {
-	struct pnfs_layout_hdr *lo;
 	struct pnfs_layoutdriver_type *ld;
 
-	pgio->pg_test = NULL;
-
-	lo = NFS_I(inode)->layout;
 	ld = NFS_SERVER(inode)->pnfs_curr_ld;
-	if (!ld || !lo)
-		return;
-
-	pgio->pg_test = ld->pg_test;
+	pgio->pg_test = (ld ? ld->pg_test : NULL);
 }
 
 /*
@@ -893,35 +884,11 @@ pnfs_set_pg_test(struct inode *inode, struct nfs_pageio_descriptor *pgio)
  */
 void
 pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
-		  struct inode *inode,
-		  struct nfs_open_context *ctx,
-		  struct list_head *pages)
+		  struct inode *inode)
 {
-	struct nfs_server *nfss = NFS_SERVER(inode);
-
-	pgio->pg_test = NULL;
-	pgio->pg_lseg = NULL;
-
-	if (!pnfs_enabled_sb(nfss))
-		return;
-
-	pgio->pg_lseg = pnfs_update_layout(inode, ctx, IOMODE_READ);
-	if (!pgio->pg_lseg)
-		return;
-
 	pnfs_set_pg_test(inode, pgio);
 }
 
-static void _pnfs_clear_lseg_from_pages(struct list_head *head)
-{
-	struct nfs_page *req;
-
-	list_for_each_entry(req, head, wb_list) {
-		put_lseg(req->wb_lseg);
-		req->wb_lseg = NULL;
-	}
-}
-
 /*
  * Call the appropriate parallel I/O subsystem read function.
  * If no I/O device driver exists, or one does match the returned
@@ -933,7 +900,6 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 {
 	struct inode *inode = rdata->inode;
 	struct nfs_server *nfss = NFS_SERVER(inode);
-	struct pnfs_layout_segment *lseg = rdata->req->wb_lseg;
 	enum pnfs_try_status trypnfs;
 
 	rdata->pdata.call_ops = call_ops;
@@ -941,14 +907,10 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 	dprintk("%s: Reading ino:%lu %u@%llu\n",
 		__func__, inode->i_ino, rdata->args.count, rdata->args.offset);
 
-	get_lseg(lseg);
-
-	rdata->pdata.lseg = lseg;
 	trypnfs = nfss->pnfs_curr_ld->read_pagelist(rdata);
 	if (trypnfs == PNFS_NOT_ATTEMPTED) {
-		rdata->pdata.lseg = NULL;
-		put_lseg(lseg);
-		_pnfs_clear_lseg_from_pages(&rdata->pages);
+		put_lseg(rdata->lseg);
+		rdata->lseg = NULL;
 	} else {
 		nfs_inc_stats(inode, NFSIOS_PNFS_READ);
 	}
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 25a4e25..6a99c33 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -178,8 +178,7 @@ void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
 					    const struct rpc_call_ops *);
-void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
-			   struct nfs_open_context *, struct list_head *);
+void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
@@ -206,10 +205,14 @@ static inline int lo_fail_bit(u32 iomode)
 			 NFS_LAYOUT_RW_FAILED : NFS_LAYOUT_RO_FAILED;
 }
 
-static inline void get_lseg(struct pnfs_layout_segment *lseg)
+static inline struct pnfs_layout_segment *
+get_lseg(struct pnfs_layout_segment *lseg)
 {
-	atomic_inc(&lseg->pls_refcount);
-	smp_mb__after_atomic_inc();
+	if (lseg) {
+		atomic_inc(&lseg->pls_refcount);
+		smp_mb__after_atomic_inc();
+	}
+	return lseg;
 }
 
 /* Return true if a layout driver is being used for this mountpoint */
@@ -228,8 +231,10 @@ static inline void pnfs_destroy_layout(struct nfs_inode *nfsi)
 {
 }
 
-static inline void get_lseg(struct pnfs_layout_segment *lseg)
+static inline struct pnfs_layout_segment *
+get_lseg(struct pnfs_layout_segment *lseg)
 {
+	return NULL;
 }
 
 static inline void put_lseg(struct pnfs_layout_segment *lseg)
@@ -281,10 +286,8 @@ static inline void unset_pnfs_layoutdriver(struct nfs_server *s)
 }
 
 static inline void
-pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *ino,
-		      struct nfs_open_context *ctx, struct list_head *pages)
+pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *ino)
 {
-	pgio->pg_lseg = NULL;
 }
 
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 43eb6a2..0db6203 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -32,8 +32,8 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
-static int nfs_pagein_multi(struct inode *, struct list_head *, unsigned int, size_t, int);
-static int nfs_pagein_one(struct inode *, struct list_head *, unsigned int, size_t, int);
+static int nfs_pagein_multi(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *);
+static int nfs_pagein_one(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *);
 static const struct rpc_call_ops nfs_read_partial_ops;
 static const struct rpc_call_ops nfs_read_full_ops;
 
@@ -73,6 +73,7 @@ void nfs_readdata_free(struct nfs_read_data *p)
 static void nfs_readdata_release(struct nfs_read_data *rdata)
 {
 	put_nfs_open_context(rdata->args.context);
+	put_lseg(rdata->lseg);
 	nfs_readdata_free(rdata);
 }
 
@@ -125,9 +126,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
-	lseg = pnfs_update_layout(inode, ctx, IOMODE_READ);
-	new = nfs_create_request(ctx, inode, page, 0, len, lseg);
-	put_lseg(lseg);
+	new = nfs_create_request(ctx, inode, page, 0, len);
 	if (IS_ERR(new)) {
 		unlock_page(page);
 		return PTR_ERR(new);
@@ -136,10 +135,12 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 		zero_user_segment(page, len, PAGE_CACHE_SIZE);
 
 	nfs_list_add_request(new, &one_request);
+	lseg = pnfs_update_layout(inode, ctx, IOMODE_READ);
 	if (NFS_SERVER(inode)->rsize < PAGE_CACHE_SIZE)
-		nfs_pagein_multi(inode, &one_request, 1, len, 0);
+		nfs_pagein_multi(inode, &one_request, 1, len, 0, lseg);
 	else
-		nfs_pagein_one(inode, &one_request, 1, len, 0);
+		nfs_pagein_one(inode, &one_request, 1, len, 0, lseg);
+	put_lseg(lseg);
 	return 0;
 }
 
@@ -202,7 +203,7 @@ EXPORT_SYMBOL(nfs_initiate_read);
 static int pnfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
 		       const struct rpc_call_ops *call_ops)
 {
-	if (data->req->wb_lseg &&
+	if (data->lseg &&
 	    (pnfs_try_to_read_data(data, call_ops) == PNFS_ATTEMPTED))
 		return 0;
 
@@ -214,13 +215,15 @@ static int pnfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
  */
 static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 		const struct rpc_call_ops *call_ops,
-		unsigned int count, unsigned int offset)
+		unsigned int count, unsigned int offset,
+		struct pnfs_layout_segment *lseg)
 {
 	struct inode *inode = req->wb_context->path.dentry->d_inode;
 
 	data->req	  = req;
 	data->inode	  = inode;
 	data->cred	  = req->wb_context->cred;
+	data->lseg	  = get_lseg(lseg);
 
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req) + offset;
@@ -264,7 +267,7 @@ nfs_async_read_error(struct list_head *head)
  * won't see the new data until our attribute cache is updated.  This is more
  * or less conventional NFS client behavior.
  */
-static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags)
+static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags, struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page *req = nfs_list_entry(head->next);
 	struct page *page = req->wb_page;
@@ -304,7 +307,7 @@ static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigne
 		if (nbytes < rsize)
 			rsize = nbytes;
 		ret2 = nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
-				  rsize, offset);
+					 rsize, offset, lseg);
 		if (ret == 0)
 			ret = ret2;
 		offset += rsize;
@@ -324,7 +327,7 @@ out_bad:
 	return -ENOMEM;
 }
 
-static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags)
+static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags, struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
@@ -345,7 +348,7 @@ static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned
 	}
 	req = nfs_list_entry(data->pages.next);
 
-	return nfs_read_rpcsetup(req, data, &nfs_read_full_ops, count, 0);
+	return nfs_read_rpcsetup(req, data, &nfs_read_full_ops, count, 0, lseg);
 out_bad:
 	nfs_async_read_error(head);
 	return ret;
@@ -606,8 +609,7 @@ readpage_async_filler(void *data, struct page *page)
 	if (len == 0)
 		return nfs_return_empty_page(page);
 
-	new = nfs_create_request(desc->ctx, inode, page, 0, len,
-				 desc->pgio->pg_lseg);
+	new = nfs_create_request(desc->ctx, inode, page, 0, len);
 	if (IS_ERR(new))
 		goto out_error;
 
@@ -663,7 +665,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		goto read_complete; /* all pages were read */
 
-	pnfs_pageio_init_read(&pgio, inode, desc.ctx, pages);
+	pnfs_pageio_init_read(&pgio, inode);
 	if (rsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
 	else
@@ -672,7 +674,6 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);
 
 	nfs_pageio_complete(&pgio);
-	put_lseg(pgio.pg_lseg);
 	npages = (pgio.pg_bytes_written + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	nfs_add_stats(inode, NFSIOS_READPAGES, npages);
 read_complete:
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 6b87b03..004c28b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -651,7 +651,7 @@ static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
 	req = nfs_try_to_update_request(inode, page, offset, bytes);
 	if (req != NULL)
 		goto out;
-	req = nfs_create_request(ctx, inode, page, offset, bytes, NULL);
+	req = nfs_create_request(ctx, inode, page, offset, bytes);
 	if (IS_ERR(req))
 		goto out;
 	error = nfs_inode_add_request(inode, req);
@@ -879,7 +879,7 @@ static void nfs_redirty_request(struct nfs_page *req)
  * Generate multiple small requests to write out a single
  * contiguous dirty area on one page.
  */
-static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how)
+static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how, struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page *req = nfs_list_entry(head->next);
 	struct page *page = req->wb_page;
@@ -946,7 +946,7 @@ out_bad:
  * This is the case if nfs_updatepage detects a conflicting request
  * that has been written but not committed.
  */
-static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how)
+static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how, struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 484c5b9..488f27b 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -49,7 +49,6 @@ struct nfs_page {
 	struct kref		wb_kref;	/* reference count */
 	unsigned long		wb_flags;
 	struct nfs_writeverf	wb_verf;	/* Commit cookie */
-	struct pnfs_layout_segment *wb_lseg;	/* Pnfs layout info */
 };
 
 struct nfs_pageio_descriptor {
@@ -60,7 +59,7 @@ struct nfs_pageio_descriptor {
 	unsigned int		pg_base;
 
 	struct inode		*pg_inode;
-	int			(*pg_doio)(struct inode *, struct list_head *, unsigned int, size_t, int);
+	int			(*pg_doio)(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *);
 	int 			pg_ioflags;
 	int			pg_error;
 	struct pnfs_layout_segment *pg_lseg;
@@ -75,8 +74,7 @@ extern	struct nfs_page *nfs_create_request(struct nfs_open_context *ctx,
 					    struct inode *inode,
 					    struct page *page,
 					    unsigned int offset,
-					    unsigned int count,
-					    struct pnfs_layout_segment *lseg);
+					    unsigned int count);
 extern	void nfs_clear_request(struct nfs_page *req);
 extern	void nfs_release_request(struct nfs_page *req);
 
@@ -85,7 +83,7 @@ extern	int nfs_scan_list(struct nfs_inode *nfsi, struct list_head *dst,
 			  pgoff_t idx_start, unsigned int npages, int tag);
 extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 			     struct inode *inode,
-			     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int),
+			     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *),
 			     size_t bsize,
 			     int how);
 extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index bd84684..887aff3 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1008,7 +1008,6 @@ struct nfs_page;
 
 /* pnfs-specific data needed for read, write, and commit calls */
 struct pnfs_call_data {
-	struct pnfs_layout_segment *lseg;
 	const struct rpc_call_ops *call_ops;
 	u32			orig_count;	/* for retry via MDS */
 	u8			how;		/* for FLUSH_STABLE */
@@ -1033,6 +1032,7 @@ struct nfs_read_data {
 	unsigned int		npages;	/* Max length of pagevec */
 	struct nfs_readargs args;
 	struct nfs_readres  res;
+	struct pnfs_layout_segment *lseg;
 #ifdef CONFIG_NFS_V4
 	unsigned long		timestamp;	/* For lease renewal */
 #endif
-- 
1.6.6

