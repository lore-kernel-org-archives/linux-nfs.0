Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:32083 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932794Ab2DTSsQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:48:16 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 16/25] NFS: create completion structure to pass into page_init functions
Date: Fri, 20 Apr 2012 14:47:48 -0400
Message-Id: <1334947677-28864-17-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Factors out the code that will need to change when directio
starts using these code paths.  This will allow directio to use
the generic pagein and flush routines

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/internal.h        |   11 +++++------
 fs/nfs/pagelist.c        |    3 +++
 fs/nfs/pnfs.c            |   39 +++++++++++++++++++++++++--------------
 fs/nfs/pnfs.h            |    6 ++++--
 fs/nfs/read.c            |   36 ++++++++++++++++++++++--------------
 fs/nfs/write.c           |   41 ++++++++++++++++++++++++++---------------
 include/linux/nfs_page.h |    2 ++
 include/linux/nfs_xdr.h  |    6 ++++++
 8 files changed, 93 insertions(+), 51 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index d05e352..f431e26 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -300,11 +300,10 @@ extern struct dentry *nfs4_get_root(struct super_block *, struct nfs_fh *,
 extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh);
 #endif
 
+struct nfs_pgio_completion_ops;
 /* read.c */
-extern void nfs_async_read_error(struct list_head *head);
 extern struct nfs_read_header *nfs_readhdr_alloc(void);
 extern void nfs_readhdr_free(struct nfs_pgio_header *hdr);
-extern void nfs_read_completion(struct nfs_pgio_header *hdr);
 extern struct nfs_read_data *nfs_readdata_alloc(struct nfs_pgio_header *hdr,
 						unsigned int pagecount);
 extern int nfs_initiate_read(struct rpc_clnt *clnt,
@@ -314,21 +313,21 @@ extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 extern int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
 			      struct nfs_pgio_header *hdr);
 extern void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
-		struct inode *inode);
+			struct inode *inode,
+			const struct nfs_pgio_completion_ops *compl_ops);
 extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_readdata_release(struct nfs_read_data *rdata);
 
 /* write.c */
-extern void nfs_async_write_error(struct list_head *head);
 extern struct nfs_write_header *nfs_writehdr_alloc(void);
 extern void nfs_writehdr_free(struct nfs_pgio_header *hdr);
 extern struct nfs_write_data *nfs_writedata_alloc(struct nfs_pgio_header *hdr,
 						  unsigned int pagecount);
-extern void nfs_write_completion(struct nfs_pgio_header *hdr);
 extern int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
 			     struct nfs_pgio_header *hdr);
 extern void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
-				  struct inode *inode, int ioflags);
+			struct inode *inode, int ioflags,
+			const struct nfs_pgio_completion_ops *compl_ops);
 extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_writedata_release(struct nfs_write_data *wdata);
 extern void nfs_commit_free(struct nfs_commit_data *p);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index cd4c038..4cf2a68 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -49,6 +49,7 @@ void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
 	hdr->io_start = req_offset(hdr->req);
 	hdr->good_bytes = desc->pg_count;
 	hdr->release = release;
+	hdr->completion_ops = desc->pg_completion_ops;
 }
 
 void nfs_set_pgio_error(struct nfs_pgio_header *hdr, int error, loff_t pos)
@@ -240,6 +241,7 @@ EXPORT_SYMBOL_GPL(nfs_generic_pg_test);
 void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 		     struct inode *inode,
 		     const struct nfs_pageio_ops *pg_ops,
+		     const struct nfs_pgio_completion_ops *compl_ops,
 		     size_t bsize,
 		     int io_flags)
 {
@@ -252,6 +254,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_recoalesce = 0;
 	desc->pg_inode = inode;
 	desc->pg_ops = pg_ops;
+	desc->pg_completion_ops = compl_ops;
 	desc->pg_ioflags = io_flags;
 	desc->pg_error = 0;
 	desc->pg_lseg = NULL;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2b89b54..4fa43e0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1113,26 +1113,31 @@ pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_write);
 
 bool
-pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode)
+pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode,
+		      const struct nfs_pgio_completion_ops *compl_ops)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct pnfs_layoutdriver_type *ld = server->pnfs_curr_ld;
 
 	if (ld == NULL)
 		return false;
-	nfs_pageio_init(pgio, inode, ld->pg_read_ops, server->rsize, 0);
+	nfs_pageio_init(pgio, inode, ld->pg_read_ops, compl_ops,
+			server->rsize, 0);
 	return true;
 }
 
 bool
-pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode, int ioflags)
+pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode,
+		       int ioflags,
+		       const struct nfs_pgio_completion_ops *compl_ops)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct pnfs_layoutdriver_type *ld = server->pnfs_curr_ld;
 
 	if (ld == NULL)
 		return false;
-	nfs_pageio_init(pgio, inode, ld->pg_write_ops, server->wsize, ioflags);
+	nfs_pageio_init(pgio, inode, ld->pg_write_ops, compl_ops,
+			server->wsize, ioflags);
 	return true;
 }
 
@@ -1162,13 +1167,15 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_test);
 
-static int pnfs_write_done_resend_to_mds(struct inode *inode, struct list_head *head)
+static int pnfs_write_done_resend_to_mds(struct inode *inode,
+				struct list_head *head,
+				const struct nfs_pgio_completion_ops *compl_ops)
 {
 	struct nfs_pageio_descriptor pgio;
 	LIST_HEAD(failed);
 
 	/* Resend all requests through the MDS */
-	nfs_pageio_init_write_mds(&pgio, inode, FLUSH_STABLE);
+	nfs_pageio_init_write_mds(&pgio, inode, FLUSH_STABLE, compl_ops);
 	while (!list_empty(head)) {
 		struct nfs_page *req = nfs_list_entry(head->next);
 
@@ -1201,7 +1208,8 @@ static void pnfs_ld_handle_write_error(struct nfs_write_data *data)
 	}
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags))
 		data->task.tk_status = pnfs_write_done_resend_to_mds(hdr->inode,
-								&hdr->pages);
+							&hdr->pages,
+							hdr->completion_ops);
 }
 
 /*
@@ -1292,7 +1300,7 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 
 	whdr = nfs_writehdr_alloc();
 	if (!whdr) {
-		nfs_async_write_error(&desc->pg_list);
+		desc->pg_completion_ops->error_cleanup(&hdr->pages);
 		put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
 		return -ENOMEM;
@@ -1309,18 +1317,20 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 	} else
 		pnfs_do_multiple_writes(desc, &hdr->rpc_list, desc->pg_ioflags);
 	if (atomic_dec_and_test(&hdr->refcnt))
-		nfs_write_completion(hdr);
+		hdr->completion_ops->completion(hdr);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
 
-static int pnfs_read_done_resend_to_mds(struct inode *inode, struct list_head *head)
+static int pnfs_read_done_resend_to_mds(struct inode *inode,
+				struct list_head *head,
+				const struct nfs_pgio_completion_ops *compl_ops)
 {
 	struct nfs_pageio_descriptor pgio;
 	LIST_HEAD(failed);
 
 	/* Resend all requests through the MDS */
-	nfs_pageio_init_read_mds(&pgio, inode);
+	nfs_pageio_init_read_mds(&pgio, inode, compl_ops);
 	while (!list_empty(head)) {
 		struct nfs_page *req = nfs_list_entry(head->next);
 
@@ -1349,7 +1359,8 @@ static void pnfs_ld_handle_read_error(struct nfs_read_data *data)
 	}
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags))
 		data->task.tk_status = pnfs_read_done_resend_to_mds(hdr->inode,
-								&hdr->pages);
+							&hdr->pages,
+							hdr->completion_ops);
 }
 
 /*
@@ -1443,7 +1454,7 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 
 	rhdr = nfs_readhdr_alloc();
 	if (!rhdr) {
-		nfs_async_read_error(&desc->pg_list);
+		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 		ret = -ENOMEM;
 		put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
@@ -1461,7 +1472,7 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 	} else
 		pnfs_do_multiple_reads(desc, &hdr->rpc_list);
 	if (atomic_dec_and_test(&hdr->refcnt))
-		nfs_read_completion(hdr);
+		hdr->completion_ops->completion(hdr);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_readpages);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 442ebf6..734e4ef 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -168,8 +168,10 @@ extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
 void get_layout_hdr(struct pnfs_layout_hdr *lo);
 void put_lseg(struct pnfs_layout_segment *lseg);
 
-bool pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *);
-bool pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *, int);
+bool pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
+			   const struct nfs_pgio_completion_ops *);
+bool pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *,
+			    int, const struct nfs_pgio_completion_ops *);
 
 void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32);
 void unset_pnfs_layoutdriver(struct nfs_server *);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index c9633b2..5e78af1 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -31,6 +31,7 @@
 
 static const struct nfs_pageio_ops nfs_pageio_read_ops;
 static const struct rpc_call_ops nfs_read_common_ops;
+static const struct nfs_pgio_completion_ops nfs_async_read_completion_ops;
 
 static struct kmem_cache *nfs_rdata_cachep;
 
@@ -95,7 +96,7 @@ void nfs_readdata_release(struct nfs_read_data *rdata)
 	else
 		rdata->header = NULL;
 	if (atomic_dec_and_test(&hdr->refcnt))
-		nfs_read_completion(hdr);
+		hdr->completion_ops->completion(hdr);
 }
 
 static
@@ -108,9 +109,10 @@ int nfs_return_empty_page(struct page *page)
 }
 
 void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
-		struct inode *inode)
+			      struct inode *inode,
+			      const struct nfs_pgio_completion_ops *compl_ops)
 {
-	nfs_pageio_init(pgio, inode, &nfs_pageio_read_ops,
+	nfs_pageio_init(pgio, inode, &nfs_pageio_read_ops, compl_ops,
 			NFS_SERVER(inode)->rsize, 0);
 }
 
@@ -122,10 +124,11 @@ void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio)
 EXPORT_SYMBOL_GPL(nfs_pageio_reset_read_mds);
 
 static void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
-		struct inode *inode)
+				struct inode *inode,
+				const struct nfs_pgio_completion_ops *compl_ops)
 {
-	if (!pnfs_pageio_init_read(pgio, inode))
-		nfs_pageio_init_read_mds(pgio, inode);
+	if (!pnfs_pageio_init_read(pgio, inode, compl_ops))
+		nfs_pageio_init_read_mds(pgio, inode, compl_ops);
 }
 
 int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
@@ -146,7 +149,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	if (len < PAGE_CACHE_SIZE)
 		zero_user_segment(page, len, PAGE_CACHE_SIZE);
 
-	nfs_pageio_init_read(&pgio, inode);
+	nfs_pageio_init_read(&pgio, inode, &nfs_async_read_completion_ops);
 	nfs_pageio_add_request(&pgio, new);
 	nfs_pageio_complete(&pgio);
 	return 0;
@@ -170,7 +173,7 @@ static void nfs_readpage_release(struct nfs_page *req)
 }
 
 /* Note io was page aligned */
-void nfs_read_completion(struct nfs_pgio_header *hdr)
+static void nfs_read_completion(struct nfs_pgio_header *hdr)
 {
 	unsigned long bytes = 0;
 
@@ -300,7 +303,7 @@ nfs_do_multiple_reads(struct list_head *head,
 	return ret;
 }
 
-void
+static void
 nfs_async_read_error(struct list_head *head)
 {
 	struct nfs_page	*req;
@@ -312,6 +315,11 @@ nfs_async_read_error(struct list_head *head)
 	}
 }
 
+static const struct nfs_pgio_completion_ops nfs_async_read_completion_ops = {
+	.error_cleanup = nfs_async_read_error,
+	.completion = nfs_read_completion,
+};
+
 /*
  * Generate multiple requests to fill a single page.
  *
@@ -362,7 +370,7 @@ out_bad:
 		list_del(&data->list);
 		nfs_readdata_release(data);
 	}
-	nfs_async_read_error(&hdr->pages);
+	desc->pg_completion_ops->error_cleanup(&hdr->pages);
 	return -ENOMEM;
 }
 
@@ -378,7 +386,7 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc,
 	data = nfs_readdata_alloc(hdr, nfs_page_array_len(desc->pg_base,
 							  desc->pg_count));
 	if (!data) {
-		nfs_async_read_error(head);
+		desc->pg_completion_ops->error_cleanup(head);
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -414,7 +422,7 @@ static int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 
 	rhdr = nfs_readhdr_alloc();
 	if (!rhdr) {
-		nfs_async_read_error(&desc->pg_list);
+		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 		return -ENOMEM;
 	}
 	hdr = &rhdr->header;
@@ -427,7 +435,7 @@ static int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 	else
 		set_bit(NFS_IOHDR_REDO, &hdr->flags);
 	if (atomic_dec_and_test(&hdr->refcnt))
-		nfs_read_completion(hdr);
+		hdr->completion_ops->completion(hdr);
 	return ret;
 }
 
@@ -652,7 +660,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		goto read_complete; /* all pages were read */
 
-	nfs_pageio_init_read(&pgio, inode);
+	nfs_pageio_init_read(&pgio, inode, &nfs_async_read_completion_ops);
 
 	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 076075e..1503972 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -40,10 +40,12 @@
  * Local function declarations
  */
 static void nfs_pageio_init_write(struct nfs_pageio_descriptor *desc,
-				  struct inode *inode, int ioflags);
+			struct inode *inode, int ioflags,
+			const struct nfs_pgio_completion_ops *compl_ops);
 static void nfs_redirty_request(struct nfs_page *req);
 static const struct rpc_call_ops nfs_write_common_ops;
 static const struct rpc_call_ops nfs_commit_ops;
+static const struct nfs_pgio_completion_ops nfs_async_write_completion_ops;
 
 static struct kmem_cache *nfs_wdata_cachep;
 static mempool_t *nfs_wdata_mempool;
@@ -128,7 +130,7 @@ void nfs_writedata_release(struct nfs_write_data *wdata)
 	else
 		wdata->header = NULL;
 	if (atomic_dec_and_test(&hdr->refcnt))
-		nfs_write_completion(hdr);
+		hdr->completion_ops->completion(hdr);
 }
 
 static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
@@ -337,7 +339,8 @@ static int nfs_writepage_locked(struct page *page, struct writeback_control *wbc
 	struct nfs_pageio_descriptor pgio;
 	int err;
 
-	nfs_pageio_init_write(&pgio, page->mapping->host, wb_priority(wbc));
+	nfs_pageio_init_write(&pgio, page->mapping->host, wb_priority(wbc),
+			      &nfs_async_write_completion_ops);
 	err = nfs_do_writepage(page, wbc, &pgio);
 	nfs_pageio_complete(&pgio);
 	if (err < 0)
@@ -380,7 +383,8 @@ int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGES);
 
-	nfs_pageio_init_write(&pgio, inode, wb_priority(wbc));
+	nfs_pageio_init_write(&pgio, inode, wb_priority(wbc),
+			      &nfs_async_write_completion_ops);
 	err = write_cache_pages(mapping, wbc, nfs_writepages_callback, &pgio);
 	nfs_pageio_complete(&pgio);
 
@@ -558,7 +562,7 @@ int nfs_write_need_commit(struct nfs_write_data *data)
 
 #endif
 
-void nfs_write_completion(struct nfs_pgio_header *hdr)
+static void nfs_write_completion(struct nfs_pgio_header *hdr)
 {
 	unsigned long bytes = 0;
 
@@ -1000,7 +1004,7 @@ static void nfs_redirty_request(struct nfs_page *req)
 	nfs_end_page_writeback(page);
 }
 
-void nfs_async_write_error(struct list_head *head)
+static void nfs_async_write_error(struct list_head *head)
 {
 	struct nfs_page	*req;
 
@@ -1011,6 +1015,11 @@ void nfs_async_write_error(struct list_head *head)
 	}
 }
 
+static const struct nfs_pgio_completion_ops nfs_async_write_completion_ops = {
+	.error_cleanup = nfs_async_write_error,
+	.completion = nfs_write_completion,
+};
+
 /*
  * Generate multiple small requests to write out a single
  * contiguous dirty area on one page.
@@ -1060,7 +1069,7 @@ out_bad:
 		list_del(&data->list);
 		nfs_writedata_release(data);
 	}
-	nfs_async_write_error(&hdr->pages);
+	desc->pg_completion_ops->error_cleanup(&hdr->pages);
 	return -ENOMEM;
 }
 
@@ -1084,7 +1093,7 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc,
 	data = nfs_writedata_alloc(hdr, nfs_page_array_len(desc->pg_base,
 							   desc->pg_count));
 	if (!data) {
-		nfs_async_write_error(head);
+		desc->pg_completion_ops->error_cleanup(head);
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -1125,7 +1134,7 @@ static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 
 	whdr = nfs_writehdr_alloc();
 	if (!whdr) {
-		nfs_async_write_error(&desc->pg_list);
+		desc->pg_completion_ops->error_cleanup(&hdr->pages);
 		return -ENOMEM;
 	}
 	hdr = &whdr->header;
@@ -1139,7 +1148,7 @@ static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 	else
 		set_bit(NFS_IOHDR_REDO, &hdr->flags);
 	if (atomic_dec_and_test(&hdr->refcnt))
-		nfs_write_completion(hdr);
+		hdr->completion_ops->completion(hdr);
 	return ret;
 }
 
@@ -1149,9 +1158,10 @@ static const struct nfs_pageio_ops nfs_pageio_write_ops = {
 };
 
 void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
-				  struct inode *inode, int ioflags)
+			       struct inode *inode, int ioflags,
+			       const struct nfs_pgio_completion_ops *compl_ops)
 {
-	nfs_pageio_init(pgio, inode, &nfs_pageio_write_ops,
+	nfs_pageio_init(pgio, inode, &nfs_pageio_write_ops, compl_ops,
 				NFS_SERVER(inode)->wsize, ioflags);
 }
 
@@ -1163,10 +1173,11 @@ void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio)
 EXPORT_SYMBOL_GPL(nfs_pageio_reset_write_mds);
 
 static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
-				  struct inode *inode, int ioflags)
+				struct inode *inode, int ioflags,
+				const struct nfs_pgio_completion_ops *compl_ops)
 {
-	if (!pnfs_pageio_init_write(pgio, inode, ioflags))
-		nfs_pageio_init_write_mds(pgio, inode, ioflags);
+	if (!pnfs_pageio_init_write(pgio, inode, ioflags, compl_ops))
+		nfs_pageio_init_write_mds(pgio, inode, ioflags, compl_ops);
 }
 
 void nfs_write_prepare(struct rpc_task *task, void *calldata)
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 5c52034..bc5b7a5 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -67,6 +67,7 @@ struct nfs_pageio_descriptor {
 	int 			pg_ioflags;
 	int			pg_error;
 	const struct rpc_call_ops *pg_rpc_callops;
+	const struct nfs_pgio_completion_ops *pg_completion_ops;
 	struct pnfs_layout_segment *pg_lseg;
 };
 
@@ -83,6 +84,7 @@ extern	void nfs_release_request(struct nfs_page *req);
 extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 			     struct inode *inode,
 			     const struct nfs_pageio_ops *pg_ops,
+			     const struct nfs_pgio_completion_ops *compl_ops,
 			     size_t bsize,
 			     int how);
 extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 694cfa4..2597f90 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1202,6 +1202,7 @@ struct nfs_pgio_header {
 	loff_t			io_start;
 	const struct rpc_call_ops *mds_ops;
 	void (*release) (struct nfs_pgio_header *hdr);
+	const struct nfs_pgio_completion_ops *completion_ops;
 	spinlock_t		lock;
 	/* fields protected by lock */
 	int			pnfs_error;
@@ -1256,6 +1257,11 @@ struct nfs_commit_data {
 	int (*commit_done_cb) (struct rpc_task *task, struct nfs_commit_data *data);
 };
 
+struct nfs_pgio_completion_ops {
+	void	(*error_cleanup)(struct list_head *head);
+	void	(*completion)(struct nfs_pgio_header *hdr);
+};
+
 struct nfs_unlinkdata {
 	struct hlist_node list;
 	struct nfs_removeargs args;
-- 
1.7.2.1

