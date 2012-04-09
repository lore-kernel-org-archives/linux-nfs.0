Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57514 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758238Ab2DIUw4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 16:52:56 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 14/26] NFS: merge _full and _partial read rpc_ops
Date: Mon,  9 Apr 2012 16:52:12 -0400
Message-Id: <1334004744-31842-15-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Decouple nfs_pgio_header and nfs_read_data, and have (possibly
multiple) nfs_read_datas each take a refcount on nfs_pgio_header.

For the moment keeps nfs_read_header as a way to preallocate a single
nfs_read_data with the nfs_pgio_header.  The code doesn't need this,
and would be prettier without, but given the amount of churn I am
already introducing I didn't want to play with tuning new mempools.

This also fixes bug in pnfs_ld_handle_read_error.  In the case of
desc->pg_bsize < PAGE_CACHE_SIZE, the pages list was empty, causing
replay attempt to do nothing.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c          |   10 +-
 fs/nfs/internal.h        |   16 ++-
 fs/nfs/nfs4filelayout.c  |    1 -
 fs/nfs/nfs4proc.c        |    2 -
 fs/nfs/pagelist.c        |   22 +++
 fs/nfs/pnfs.c            |   55 +++++---
 fs/nfs/read.c            |  340 ++++++++++++++++++++++------------------------
 include/linux/nfs_page.h |    1 -
 include/linux/nfs_xdr.h  |   16 ++
 9 files changed, 254 insertions(+), 209 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 0faba4c..90b00ce 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -319,10 +319,16 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		bytes = min(rsize,count);
 
 		result = -ENOMEM;
-		rhdr = nfs_readhdr_alloc(nfs_page_array_len(pgbase, bytes));
+		rhdr = nfs_readhdr_alloc();
 		if (unlikely(!rhdr))
 			break;
-		data = &rhdr->rpc_data;
+		data = nfs_readdata_alloc(&rhdr->header, nfs_page_array_len(pgbase, bytes));
+		if (!data) {
+			nfs_readhdr_free(&rhdr->header);
+			break;
+		}
+		data->header = &rhdr->header;
+		atomic_inc(&data->header->refcnt);
 		pages = &data->pages;
 
 		down_read(&current->mm->mmap_sem);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0818e66..c4abe2b 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -199,6 +199,7 @@ struct vfsmount *nfs_do_refmount(struct dentry *dentry)
 extern struct svc_version nfs4_callback_version1;
 extern struct svc_version nfs4_callback_version4;
 
+struct nfs_pageio_descriptor;
 /* pagelist.c */
 extern int __init nfs_init_nfspagecache(void);
 extern void nfs_destroy_nfspagecache(void);
@@ -210,6 +211,11 @@ extern void nfs_destroy_writepagecache(void);
 extern int __init nfs_init_directcache(void);
 extern void nfs_destroy_directcache(void);
 extern bool nfs_pgarray_set(struct nfs_page_array *p, unsigned int pagecount);
+extern void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
+			      struct nfs_pgio_header *hdr,
+			      void (*release)(struct nfs_pgio_header *hdr));
+void nfs_set_pgio_error(struct nfs_pgio_header *hdr, int error,
+			unsigned long loc);
 
 /* nfs2xdr.c */
 extern int nfs_stat_to_errno(enum nfs_stat);
@@ -295,17 +301,19 @@ extern struct dentry *nfs4_get_root(struct super_block *, struct nfs_fh *,
 extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh);
 #endif
 
-struct nfs_pageio_descriptor;
 /* read.c */
-extern struct nfs_read_header *nfs_readhdr_alloc(unsigned int npages);
+extern void nfs_async_read_error(struct list_head *head);
+extern struct nfs_read_header *nfs_readhdr_alloc(void);
 extern void nfs_readhdr_free(struct nfs_pgio_header *hdr);
+extern void nfs_read_completion(struct nfs_pgio_header *hdr);
+extern struct nfs_read_data *nfs_readdata_alloc(struct nfs_pgio_header *hdr,
+						unsigned int pagecount);
 extern int nfs_initiate_read(struct rpc_clnt *clnt,
 			     struct nfs_read_data *data,
 			     const struct rpc_call_ops *call_ops);
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 extern int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
-		struct list_head *head);
-
+			      struct nfs_pgio_header *hdr);
 extern void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
 		struct inode *inode);
 extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 850ae85..d27035b 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -227,7 +227,6 @@ static void filelayout_read_release(void *data)
 {
 	struct nfs_read_data *rdata = data;
 
-	put_lseg(rdata->header->lseg);
 	rdata->header->mds_ops->rpc_release(data);
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 75d5959..16a3877 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3336,8 +3336,6 @@ void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data)
 	struct inode *inode = hdr->inode;
 
 	dprintk("%s Reset task for i/o through\n", __func__);
-	put_lseg(hdr->lseg);
-	hdr->lseg = NULL;
 	data->ds_clp = NULL;
 	/* offsets will differ in the dense stripe case */
 	data->args.offset = data->mds_offset;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index d349bd4..16b8a04 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -39,6 +39,28 @@ bool nfs_pgarray_set(struct nfs_page_array *p, unsigned int pagecount)
 	return p->pagevec != NULL;
 }
 
+void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
+		       struct nfs_pgio_header *hdr,
+		       void (*release)(struct nfs_pgio_header *hdr))
+{
+	hdr->req = nfs_list_entry(desc->pg_list.next);
+	hdr->inode = desc->pg_inode;
+	hdr->cred = hdr->req->wb_context->cred;
+	hdr->first_error = req_offset(hdr->req) + desc->pg_count;
+	hdr->release = release;
+}
+
+void nfs_set_pgio_error(struct nfs_pgio_header *hdr, int error,
+			unsigned long loc)
+{
+	spin_lock(&hdr->lock);
+	if (test_and_set_bit(NFS_IOHDR_ERROR, &hdr->flags))
+		loc = min(loc, hdr->first_error);
+	hdr->first_error = loc;
+	hdr->error = error;
+	spin_unlock(&hdr->lock);
+}
+
 static inline struct nfs_page *
 nfs_page_alloc(void)
 {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b00170a..5947a90 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1333,7 +1333,9 @@ static void pnfs_ld_handle_read_error(struct nfs_read_data *data)
 		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(hdr->inode)->flags);
 		pnfs_return_layout(hdr->inode);
 	}
-	data->task.tk_status = pnfs_read_done_resend_to_mds(hdr->inode, &hdr->pages);
+	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags))
+		data->task.tk_status = pnfs_read_done_resend_to_mds(hdr->inode,
+								&hdr->pages);
 }
 
 /*
@@ -1348,7 +1350,6 @@ void pnfs_ld_read_done(struct nfs_read_data *data)
 		hdr->mds_ops->rpc_call_done(&data->task, data);
 	} else
 		pnfs_ld_handle_read_error(data);
-	put_lseg(hdr->lseg);
 	hdr->mds_ops->rpc_release(data);
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
@@ -1359,11 +1360,11 @@ pnfs_read_through_mds(struct nfs_pageio_descriptor *desc,
 {
 	struct nfs_pgio_header *hdr = data->header;
 
-	list_splice_tail_init(&hdr->pages, &desc->pg_list);
-	if (hdr->req && list_empty(&hdr->req->wb_list))
-		nfs_list_add_request(hdr->req, &desc->pg_list);
-	nfs_pageio_reset_read_mds(desc);
-	desc->pg_recoalesce = 1;
+	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
+		list_splice_tail_init(&hdr->pages, &desc->pg_list);
+		nfs_pageio_reset_read_mds(desc);
+		desc->pg_recoalesce = 1;
+	}
 	nfs_readdata_release(data);
 }
 
@@ -1381,18 +1382,13 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 	enum pnfs_try_status trypnfs;
 
 	hdr->mds_ops = call_ops;
-	hdr->lseg = get_lseg(lseg);
 
 	dprintk("%s: Reading ino:%lu %u@%llu\n",
 		__func__, inode->i_ino, rdata->args.count, rdata->args.offset);
 
 	trypnfs = nfss->pnfs_curr_ld->read_pagelist(rdata);
-	if (trypnfs == PNFS_NOT_ATTEMPTED) {
-		put_lseg(hdr->lseg);
-		hdr->lseg = NULL;
-	} else {
+	if (trypnfs != PNFS_NOT_ATTEMPTED)
 		nfs_inc_stats(inode, NFSIOS_PNFS_READ);
-	}
 	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
 	return trypnfs;
 }
@@ -1408,7 +1404,7 @@ pnfs_do_multiple_reads(struct nfs_pageio_descriptor *desc, struct list_head *hea
 	while (!list_empty(head)) {
 		enum pnfs_try_status trypnfs;
 
-		data = list_entry(head->next, struct nfs_read_data, list);
+		data = list_first_entry(head, struct nfs_read_data, list);
 		list_del_init(&data->list);
 
 		trypnfs = pnfs_try_to_read_data(data, call_ops, lseg);
@@ -1418,20 +1414,41 @@ pnfs_do_multiple_reads(struct nfs_pageio_descriptor *desc, struct list_head *hea
 	put_lseg(lseg);
 }
 
+static void pnfs_readhdr_free(struct nfs_pgio_header *hdr)
+{
+	put_lseg(hdr->lseg);
+	nfs_readhdr_free(hdr);
+}
+
 int
 pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 {
-	LIST_HEAD(head);
+	struct nfs_read_header *rhdr;
+	struct nfs_pgio_header *hdr;
 	int ret;
 
-	ret = nfs_generic_pagein(desc, &head);
-	if (ret != 0) {
+	rhdr = nfs_readhdr_alloc();
+	if (!rhdr) {
+		nfs_async_read_error(&desc->pg_list);
+		ret = -ENOMEM;
 		put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
 		return ret;
 	}
-	pnfs_do_multiple_reads(desc, &head);
-	return 0;
+	hdr = &rhdr->header;
+	nfs_pgheader_init(desc, hdr, pnfs_readhdr_free);
+	hdr->lseg = get_lseg(desc->pg_lseg);
+	atomic_inc(&hdr->refcnt);
+	ret = nfs_generic_pagein(desc, hdr);
+	if (ret != 0) {
+		put_lseg(desc->pg_lseg);
+		desc->pg_lseg = NULL;
+		set_bit(NFS_IOHDR_REDO, &hdr->flags);
+	} else
+		pnfs_do_multiple_reads(desc, &hdr->rpc_list);
+	if (atomic_dec_and_test(&hdr->refcnt))
+		nfs_read_completion(hdr);
+	return ret;
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_readpages);
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index f6ab30b..ea844b2 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -30,29 +30,45 @@
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
 static const struct nfs_pageio_ops nfs_pageio_read_ops;
-static const struct rpc_call_ops nfs_read_partial_ops;
-static const struct rpc_call_ops nfs_read_full_ops;
+static const struct rpc_call_ops nfs_read_common_ops;
 
 static struct kmem_cache *nfs_rdata_cachep;
 
-struct nfs_read_header *nfs_readhdr_alloc(unsigned int pagecount)
+struct nfs_read_header *nfs_readhdr_alloc()
 {
-	struct nfs_read_header *p;
+	struct nfs_read_header *rhdr;
 
-	p = kmem_cache_zalloc(nfs_rdata_cachep, GFP_KERNEL);
-	if (p) {
-		struct nfs_pgio_header *hdr = &p->header;
-		struct nfs_read_data *data = &p->rpc_data;
+	rhdr = kmem_cache_zalloc(nfs_rdata_cachep, GFP_KERNEL);
+	if (rhdr) {
+		struct nfs_pgio_header *hdr = &rhdr->header;
 
 		INIT_LIST_HEAD(&hdr->pages);
-		INIT_LIST_HEAD(&data->list);
-		data->header = hdr;
+		INIT_LIST_HEAD(&hdr->rpc_list);
+		spin_lock_init(&hdr->lock);
+		atomic_set(&hdr->refcnt, 0);
+	}
+	return rhdr;
+}
+
+struct nfs_read_data *nfs_readdata_alloc(struct nfs_pgio_header *hdr,
+					 unsigned int pagecount)
+{
+	struct nfs_read_data *data;
+
+	if (hdr) {
+		/* Use data preallocated with the header */
+		data = &container_of(hdr, struct nfs_read_header, header)->rpc_data;
+	} else
+		data = kzalloc(sizeof(*data), GFP_KERNEL);
+
+	if (data) {
 		if (!nfs_pgarray_set(&data->pages, pagecount)) {
-			kmem_cache_free(nfs_rdata_cachep, p);
-			p = NULL;
+			if (!hdr)
+				kfree(data);
+			data = NULL;
 		}
 	}
-	return p;
+	return data;
 }
 
 void nfs_readhdr_free(struct nfs_pgio_header *hdr)
@@ -64,10 +80,16 @@ void nfs_readhdr_free(struct nfs_pgio_header *hdr)
 
 void nfs_readdata_release(struct nfs_read_data *rdata)
 {
+	struct nfs_pgio_header *hdr = rdata->header;
+
 	put_nfs_open_context(rdata->args.context);
 	if (rdata->pages.pagevec != rdata->pages.page_array)
 		kfree(rdata->pages.pagevec);
-	nfs_readhdr_free(rdata->header);
+	if (container_of(hdr, struct nfs_read_header, header) !=
+	    container_of(rdata, struct nfs_read_header, rpc_data))
+		kfree(rdata);
+	if (atomic_dec_and_test(&hdr->refcnt))
+		nfs_read_completion(hdr);
 }
 
 static
@@ -79,35 +101,6 @@ int nfs_return_empty_page(struct page *page)
 	return 0;
 }
 
-static void nfs_readpage_truncate_uninitialised_page(struct nfs_read_data *data)
-{
-	unsigned int remainder = data->args.count - data->res.count;
-	unsigned int base = data->args.pgbase + data->res.count;
-	unsigned int pglen;
-	struct page **pages;
-
-	if (data->res.eof == 0 || remainder == 0)
-		return;
-	/*
-	 * Note: "remainder" can never be negative, since we check for
-	 * 	this in the XDR code.
-	 */
-	pages = &data->args.pages[base >> PAGE_CACHE_SHIFT];
-	base &= ~PAGE_CACHE_MASK;
-	pglen = PAGE_CACHE_SIZE - base;
-	for (;;) {
-		if (remainder <= pglen) {
-			zero_user(*pages, base, remainder);
-			break;
-		}
-		zero_user(*pages, base, pglen);
-		pages++;
-		remainder -= pglen;
-		pglen = PAGE_CACHE_SIZE;
-		base = 0;
-	}
-}
-
 void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
 		struct inode *inode)
 {
@@ -170,6 +163,54 @@ static void nfs_readpage_release(struct nfs_page *req)
 	nfs_release_request(req);
 }
 
+/* Note io was page aligned */
+void nfs_read_completion(struct nfs_pgio_header *hdr)
+{
+	unsigned long pos = hdr->req->wb_index << PAGE_CACHE_SHIFT;
+
+	if (test_bit(NFS_IOHDR_REDO, &hdr->flags))
+		goto out;
+	if (test_bit(NFS_IOHDR_ERROR, &hdr->flags) &&
+	    test_bit(NFS_IOHDR_EOF, &hdr->flags)) {
+		/* Note they can't be equal */
+		if (hdr->eof < hdr->first_error)
+			clear_bit(NFS_IOHDR_ERROR, &hdr->flags);
+		else
+			clear_bit(NFS_IOHDR_EOF, &hdr->flags);
+	}
+
+	if (!test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
+		while (!list_empty(&hdr->pages)) {
+			struct nfs_page *req = nfs_list_entry(hdr->pages.next);
+
+			if (test_bit(NFS_IOHDR_EOF, &hdr->flags)) {
+				if (pos > hdr->eof)
+					zero_user(req->wb_page, 0, PAGE_SIZE);
+				else if (hdr->eof - pos < PAGE_SIZE)
+					zero_user_segment(req->wb_page,
+							  hdr->eof & ~PAGE_MASK,
+							  PAGE_SIZE);
+			}
+			SetPageUptodate(req->wb_page);
+			nfs_list_remove_request(req);
+			nfs_readpage_release(req);
+			pos += PAGE_SIZE;
+		}
+	} else {
+		while (!list_empty(&hdr->pages)) {
+			struct nfs_page *req = nfs_list_entry(hdr->pages.next);
+
+			if (pos < (hdr->first_error & PAGE_MASK))
+				SetPageUptodate(req->wb_page);
+			nfs_list_remove_request(req);
+			nfs_readpage_release(req);
+			pos += PAGE_SIZE;
+		}
+	}
+out:
+	hdr->release(hdr);
+}
+
 int nfs_initiate_read(struct rpc_clnt *clnt,
 		      struct nfs_read_data *data,
 		      const struct rpc_call_ops *call_ops)
@@ -214,16 +255,12 @@ EXPORT_SYMBOL_GPL(nfs_initiate_read);
 /*
  * Set up the NFS read request struct
  */
-static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
+static void nfs_read_rpcsetup(struct nfs_read_data *data,
 		unsigned int count, unsigned int offset)
 {
-	struct inode *inode = data->header->inode;
-
-	data->header->req	  = req;
-	data->header->inode	  = inode;
-	data->header->cred	  = req->wb_context->cred;
+	struct nfs_page *req = data->header->req;
 
-	data->args.fh     = NFS_FH(inode);
+	data->args.fh     = NFS_FH(data->header->inode);
 	data->args.offset = req_offset(req) + offset;
 	data->args.pgbase = req->wb_pgbase + offset;
 	data->args.pages  = data->pages.pagevec;
@@ -255,7 +292,7 @@ nfs_do_multiple_reads(struct list_head *head,
 	while (!list_empty(head)) {
 		int ret2;
 
-		data = list_entry(head->next, struct nfs_read_data, list);
+		data = list_first_entry(head, struct nfs_read_data, list);
 		list_del_init(&data->list);
 
 		ret2 = nfs_do_read(data, call_ops);
@@ -265,7 +302,7 @@ nfs_do_multiple_reads(struct list_head *head,
 	return ret;
 }
 
-static void
+void
 nfs_async_read_error(struct list_head *head)
 {
 	struct nfs_page	*req;
@@ -290,11 +327,11 @@ nfs_async_read_error(struct list_head *head)
  * won't see the new data until our attribute cache is updated.  This is more
  * or less conventional NFS client behavior.
  */
-static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc, struct list_head *res)
+static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc,
+			    struct nfs_pgio_header *hdr)
 {
-	struct nfs_page *req = nfs_list_entry(desc->pg_list.next);
+	struct nfs_page *req = hdr->req;
 	struct page *page = req->wb_page;
-	struct nfs_read_header *rhdr;
 	struct nfs_read_data *data;
 	size_t rsize = desc->pg_bsize, nbytes;
 	unsigned int offset;
@@ -302,85 +339,101 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc, struct list_head
 	int ret = 0;
 
 	nfs_list_remove_request(req);
+	nfs_list_add_request(req, &hdr->pages);
 
 	offset = 0;
 	nbytes = desc->pg_count;
 	do {
 		size_t len = min(nbytes,rsize);
 
-		rhdr = nfs_readhdr_alloc(1);
-		if (!rhdr)
+		data = nfs_readdata_alloc(NULL, 1);
+		if (!data)
 			goto out_bad;
-		data = &rhdr->rpc_data;
+		data->header = hdr;
+		atomic_inc(&hdr->refcnt);
 		data->pages.pagevec[0] = page;
-		nfs_read_rpcsetup(req, data, len, offset);
-		list_add(&data->list, res);
+		nfs_read_rpcsetup(data, len, offset);
+		list_add(&data->list, &hdr->rpc_list);
 		requests++;
 		nbytes -= len;
 		offset += len;
 	} while(nbytes != 0);
-	atomic_set(&req->wb_complete, requests);
-	desc->pg_rpc_callops = &nfs_read_partial_ops;
+	desc->pg_rpc_callops = &nfs_read_common_ops;
 	return ret;
 out_bad:
-	while (!list_empty(res)) {
-		data = list_entry(res->next, struct nfs_read_data, list);
+	while (!list_empty(&hdr->rpc_list)) {
+		data = list_first_entry(&hdr->rpc_list, struct nfs_read_data, list);
 		list_del(&data->list);
 		nfs_readdata_release(data);
 	}
-	nfs_readpage_release(req);
+	nfs_async_read_error(&hdr->pages);
 	return -ENOMEM;
 }
 
-static int nfs_pagein_one(struct nfs_pageio_descriptor *desc, struct list_head *res)
+static int nfs_pagein_one(struct nfs_pageio_descriptor *desc,
+			  struct nfs_pgio_header *hdr)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
-	struct nfs_read_header	*rhdr;
-	struct nfs_read_data	*data;
+	struct nfs_read_data    *data;
 	struct list_head *head = &desc->pg_list;
 	int ret = 0;
 
-	rhdr = nfs_readhdr_alloc(nfs_page_array_len(desc->pg_base,
-						    desc->pg_count));
-	if (!rhdr) {
+	data = nfs_readdata_alloc(hdr, nfs_page_array_len(desc->pg_base,
+							  desc->pg_count));
+	if (!data) {
 		nfs_async_read_error(head);
 		ret = -ENOMEM;
 		goto out;
 	}
+	data->header = hdr;
+	atomic_inc(&hdr->refcnt);
 
-	data = &rhdr->rpc_data;
 	pages = data->pages.pagevec;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
-		nfs_list_add_request(req, &rhdr->header.pages);
+		nfs_list_add_request(req, &hdr->pages);
 		*pages++ = req->wb_page;
 	}
-	req = nfs_list_entry(rhdr->header.pages.next);
 
-	nfs_read_rpcsetup(req, data, desc->pg_count, 0);
-	list_add(&data->list, res);
-	desc->pg_rpc_callops = &nfs_read_full_ops;
+	nfs_read_rpcsetup(data, desc->pg_count, 0);
+	list_add(&data->list, &hdr->rpc_list);
+	desc->pg_rpc_callops = &nfs_read_common_ops;
 out:
 	return ret;
 }
 
-int nfs_generic_pagein(struct nfs_pageio_descriptor *desc, struct list_head *head)
+int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
+		       struct nfs_pgio_header *hdr)
 {
 	if (desc->pg_bsize < PAGE_CACHE_SIZE)
-		return nfs_pagein_multi(desc, head);
-	return nfs_pagein_one(desc, head);
+		return nfs_pagein_multi(desc, hdr);
+	return nfs_pagein_one(desc, hdr);
 }
 
 static int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 {
-	LIST_HEAD(head);
+	struct nfs_read_header *rhdr;
+	struct nfs_pgio_header *hdr;
 	int ret;
 
-	ret = nfs_generic_pagein(desc, &head);
+	rhdr = nfs_readhdr_alloc();
+	if (!rhdr) {
+		nfs_async_read_error(&desc->pg_list);
+		return -ENOMEM;
+	}
+	hdr = &rhdr->header;
+	nfs_pgheader_init(desc, hdr, nfs_readhdr_free);
+	atomic_inc(&hdr->refcnt);
+	ret = nfs_generic_pagein(desc, hdr);
 	if (ret == 0)
-		ret = nfs_do_multiple_reads(&head, desc->pg_rpc_callops);
+		ret = nfs_do_multiple_reads(&hdr->rpc_list,
+					    desc->pg_rpc_callops);
+	else
+		set_bit(NFS_IOHDR_REDO, &hdr->flags);
+	if (atomic_dec_and_test(&hdr->refcnt))
+		nfs_read_completion(hdr);
 	return ret;
 }
 
@@ -419,15 +472,13 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 	struct nfs_readargs *argp = &data->args;
 	struct nfs_readres *resp = &data->res;
 
-	if (resp->eof || resp->count == argp->count)
-		return;
-
 	/* This is a short read! */
 	nfs_inc_stats(data->header->inode, NFSIOS_SHORTREAD);
 	/* Has the server at least made some progress? */
-	if (resp->count == 0)
+	if (resp->count == 0) {
+		nfs_set_pgio_error(data->header, -EIO, argp->offset);
 		return;
-
+	}
 	/* Yes, so retry the read at the end of the data */
 	data->mds_offset += resp->count;
 	argp->offset += resp->count;
@@ -436,38 +487,32 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 	rpc_restart_call_prepare(task);
 }
 
-/*
- * Handle a read reply that fills part of a page.
- */
-static void nfs_readpage_result_partial(struct rpc_task *task, void *calldata)
+static void nfs_readpage_result_common(struct rpc_task *task, void *calldata)
 {
 	struct nfs_read_data *data = calldata;
- 
+	struct nfs_pgio_header *hdr = data->header;
+
+	/* Note the only returns of nfs_readpage_result are 0 and -EAGAIN */
 	if (nfs_readpage_result(task, data) != 0)
 		return;
 	if (task->tk_status < 0)
-		return;
+		nfs_set_pgio_error(hdr, task->tk_status, data->args.offset);
+	else if (data->res.eof) {
+		unsigned long bound;
 
-	nfs_readpage_truncate_uninitialised_page(data);
-	nfs_readpage_retry(task, data);
+		bound = data->args.offset + data->res.count;
+		spin_lock(&hdr->lock);
+		if (test_and_set_bit(NFS_IOHDR_EOF, &hdr->flags))
+			bound = min(bound, hdr->eof);
+		hdr->eof = bound;
+		spin_unlock(&hdr->lock);
+	} else if (data->res.count != data->args.count)
+		nfs_readpage_retry(task, data);
 }
 
-static void nfs_readpage_release_partial(void *calldata)
+static void nfs_readpage_release_common(void *calldata)
 {
-	struct nfs_read_data *data = calldata;
-	struct nfs_page *req = data->header->req;
-	struct page *page = req->wb_page;
-	int status = data->task.tk_status;
-
-	if (status < 0)
-		set_bit(PG_PARTIAL_READ_FAILED, &req->wb_flags);
-
-	if (atomic_dec_and_test(&req->wb_complete)) {
-		if (!test_bit(PG_PARTIAL_READ_FAILED, &req->wb_flags))
-			SetPageUptodate(page);
-		nfs_readpage_release(req);
-	}
-	nfs_readdata_release(data);
+	nfs_readdata_release(calldata);
 }
 
 void nfs_read_prepare(struct rpc_task *task, void *calldata)
@@ -476,75 +521,10 @@ void nfs_read_prepare(struct rpc_task *task, void *calldata)
 	NFS_PROTO(data->header->inode)->read_rpc_prepare(task, data);
 }
 
-static const struct rpc_call_ops nfs_read_partial_ops = {
-	.rpc_call_prepare = nfs_read_prepare,
-	.rpc_call_done = nfs_readpage_result_partial,
-	.rpc_release = nfs_readpage_release_partial,
-};
-
-static void nfs_readpage_set_pages_uptodate(struct nfs_read_data *data)
-{
-	unsigned int count = data->res.count;
-	unsigned int base = data->args.pgbase;
-	struct page **pages;
-
-	if (data->res.eof)
-		count = data->args.count;
-	if (unlikely(count == 0))
-		return;
-	pages = &data->args.pages[base >> PAGE_CACHE_SHIFT];
-	base &= ~PAGE_CACHE_MASK;
-	count += base;
-	for (;count >= PAGE_CACHE_SIZE; count -= PAGE_CACHE_SIZE, pages++)
-		SetPageUptodate(*pages);
-	if (count == 0)
-		return;
-	/* Was this a short read? */
-	if (data->res.eof || data->res.count == data->args.count)
-		SetPageUptodate(*pages);
-}
-
-/*
- * This is the callback from RPC telling us whether a reply was
- * received or some error occurred (timeout or socket shutdown).
- */
-static void nfs_readpage_result_full(struct rpc_task *task, void *calldata)
-{
-	struct nfs_read_data *data = calldata;
-
-	if (nfs_readpage_result(task, data) != 0)
-		return;
-	if (task->tk_status < 0)
-		return;
-	/*
-	 * Note: nfs_readpage_retry may change the values of
-	 * data->args. In the multi-page case, we therefore need
-	 * to ensure that we call nfs_readpage_set_pages_uptodate()
-	 * first.
-	 */
-	nfs_readpage_truncate_uninitialised_page(data);
-	nfs_readpage_set_pages_uptodate(data);
-	nfs_readpage_retry(task, data);
-}
-
-static void nfs_readpage_release_full(void *calldata)
-{
-	struct nfs_read_data *data = calldata;
-	struct nfs_pgio_header *hdr = data->header;
-
-	while (!list_empty(&hdr->pages)) {
-		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
-
-		nfs_list_remove_request(req);
-		nfs_readpage_release(req);
-	}
-	nfs_readdata_release(calldata);
-}
-
-static const struct rpc_call_ops nfs_read_full_ops = {
+static const struct rpc_call_ops nfs_read_common_ops = {
 	.rpc_call_prepare = nfs_read_prepare,
-	.rpc_call_done = nfs_readpage_result_full,
-	.rpc_release = nfs_readpage_release_full,
+	.rpc_call_done = nfs_readpage_result_common,
+	.rpc_release = nfs_readpage_release_common,
 };
 
 /*
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index eac30d6..5c52034 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -27,7 +27,6 @@ enum {
 	PG_CLEAN,
 	PG_NEED_COMMIT,
 	PG_NEED_RESCHED,
-	PG_PARTIAL_READ_FAILED,
 	PG_COMMIT_TO_DS,
 };
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 060896f..386ebfb 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1182,14 +1182,30 @@ struct nfs_read_data {
 	struct nfs_client	*ds_clp;	/* pNFS data server */
 };
 
+/* used as flag bits in nfs_pgio_header */
+enum {
+	NFS_IOHDR_ERROR = 0,
+	NFS_IOHDR_EOF,
+	NFS_IOHDR_REDO,
+};
+
 struct nfs_pgio_header {
 	struct inode		*inode;
 	struct rpc_cred		*cred;
 	struct list_head	pages;
+	struct list_head	rpc_list;
+	atomic_t		refcnt;
 	struct nfs_page		*req;
 	struct pnfs_layout_segment *lseg;
 	const struct rpc_call_ops *mds_ops;
+	void (*release) (struct nfs_pgio_header *hdr);
+	spinlock_t		lock;
+	/* fields protected by lock */
 	int			pnfs_error;
+	int			error;		/* merge with pnfs_error */
+	unsigned long		eof;		/* where saw eof marker */
+	unsigned long		first_error;	/* boundary of good data */
+	unsigned long		flags;
 };
 
 struct nfs_read_header {
-- 
1.7.2.1

