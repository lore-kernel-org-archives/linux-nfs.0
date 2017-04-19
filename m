Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64824 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934699AbdDSOLh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Apr 2017 10:11:37 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/3] NFS: move rw_mode to nfs_pageio_header
Date: Wed, 19 Apr 2017 10:11:35 -0400
Message-Id: <000b541461e81618201955e799f55c94bfca4dc2.1492611057.git.bcodding@redhat.com>
In-Reply-To: <01bf89b13b51faa8b9adcd3a5e09eea55b8d9827.1492611057.git.bcodding@redhat.com>
References: <01bf89b13b51faa8b9adcd3a5e09eea55b8d9827.1492611057.git.bcodding@redhat.com>
In-Reply-To: <677652bb558c5b4925547af558d89583564720e5.1492529938.git.bcodding@redhat.com>
References: <677652bb558c5b4925547af558d89583564720e5.1492529938.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Let's try to have it in a cacheline in nfs4_proc_pgio_rpc_prepare().

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4proc.c        | 2 +-
 fs/nfs/pagelist.c        | 8 +++-----
 fs/nfs/read.c            | 9 ++++++---
 fs/nfs/write.c           | 7 ++++---
 include/linux/nfs_page.h | 4 ++--
 include/linux/nfs_xdr.h  | 1 +
 6 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 201ca3f2c4ba..a725de5b7a08 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4610,7 +4610,7 @@ static int nfs4_proc_pgio_rpc_prepare(struct rpc_task *task,
 		return 0;
 	if (nfs4_set_rw_stateid(&hdr->args.stateid, hdr->args.context,
 				hdr->args.lock_context,
-				hdr->rw_ops->rw_mode) == -EIO)
+				hdr->rw_mode) == -EIO)
 		return -EIO;
 	if (unlikely(test_bit(NFS_CONTEXT_BAD, &hdr->args.context->flags)))
 		return -EIO;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index fa2924ce5a78..fac370bc0d6e 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -664,11 +664,11 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 		     const struct nfs_pgio_completion_ops *compl_ops,
 		     const struct nfs_rw_ops *rw_ops,
 		     size_t bsize,
-		     int io_flags)
+		     int io_flags,
+		     gfp_t gfp_flags)
 {
 	struct nfs_pgio_mirror *new;
 	int i;
-	gfp_t gfp_flags = GFP_KERNEL;
 
 	desc->pg_moreio = 0;
 	desc->pg_inode = inode;
@@ -688,8 +688,6 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	if (pg_ops->pg_get_mirror_count) {
 		/* until we have a request, we don't have an lseg and no
 		 * idea how many mirrors there will be */
-		if (desc->pg_rw_ops->rw_mode == FMODE_WRITE)
-			gfp_flags = GFP_NOIO;
 		new = kcalloc(NFS_PAGEIO_DESCRIPTOR_MIRROR_MAX,
 			      sizeof(struct nfs_pgio_mirror), gfp_flags);
 		desc->pg_mirrors_dynamic = new;
@@ -753,7 +751,7 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 	if (pagecount <= ARRAY_SIZE(pg_array->page_array))
 		pg_array->pagevec = pg_array->page_array;
 	else {
-		if (desc->pg_rw_ops->rw_mode == FMODE_WRITE)
+		if (hdr->rw_mode == FMODE_WRITE)
 			gfp_flags = GFP_NOIO;
 		pg_array->pagevec = kcalloc(pagecount, sizeof(struct page *), gfp_flags);
 		if (!pg_array->pagevec) {
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index defc9233e985..a8421d9dab6a 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -35,7 +35,11 @@ static struct kmem_cache *nfs_rdata_cachep;
 
 static struct nfs_pgio_header *nfs_readhdr_alloc(void)
 {
-	return kmem_cache_zalloc(nfs_rdata_cachep, GFP_KERNEL);
+	struct nfs_pgio_header *p = kmem_cache_zalloc(nfs_rdata_cachep, GFP_KERNEL);
+
+	if (p)
+		p->rw_mode = FMODE_READ;
+	return p;
 }
 
 static void nfs_readhdr_free(struct nfs_pgio_header *rhdr)
@@ -64,7 +68,7 @@ void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 		pg_ops = server->pnfs_curr_ld->pg_read_ops;
 #endif
 	nfs_pageio_init(pgio, inode, pg_ops, compl_ops, &nfs_rw_read_ops,
-			server->rsize, 0);
+			server->rsize, 0, GFP_KERNEL);
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_init_read);
 
@@ -451,7 +455,6 @@ void nfs_destroy_readpagecache(void)
 }
 
 static const struct nfs_rw_ops nfs_rw_read_ops = {
-	.rw_mode		= FMODE_READ,
 	.rw_alloc_header	= nfs_readhdr_alloc,
 	.rw_free_header		= nfs_readhdr_free,
 	.rw_done		= nfs_readpage_done,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index abb2c8a3be42..859a95b67abe 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -82,8 +82,10 @@ static struct nfs_pgio_header *nfs_writehdr_alloc(void)
 {
 	struct nfs_pgio_header *p = mempool_alloc(nfs_wdata_mempool, GFP_NOIO);
 
-	if (p)
+	if (p) {
 		memset(p, 0, sizeof(*p));
+		p->rw_mode = FMODE_WRITE;
+	}
 	return p;
 }
 
@@ -1368,7 +1370,7 @@ void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 		pg_ops = server->pnfs_curr_ld->pg_write_ops;
 #endif
 	nfs_pageio_init(pgio, inode, pg_ops, compl_ops, &nfs_rw_write_ops,
-			server->wsize, ioflags);
+			server->wsize, ioflags, GFP_NOIO);
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_init_write);
 
@@ -2108,7 +2110,6 @@ void nfs_destroy_writepagecache(void)
 }
 
 static const struct nfs_rw_ops nfs_rw_write_ops = {
-	.rw_mode		= FMODE_WRITE,
 	.rw_alloc_header	= nfs_writehdr_alloc,
 	.rw_free_header		= nfs_writehdr_free,
 	.rw_done		= nfs_writeback_done,
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 957049f72290..6f01e28bba27 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -64,7 +64,6 @@ struct nfs_pageio_ops {
 };
 
 struct nfs_rw_ops {
-	const fmode_t rw_mode;
 	struct nfs_pgio_header *(*rw_alloc_header)(void);
 	void (*rw_free_header)(struct nfs_pgio_header *);
 	int  (*rw_done)(struct rpc_task *, struct nfs_pgio_header *,
@@ -124,7 +123,8 @@ extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 			     const struct nfs_pgio_completion_ops *compl_ops,
 			     const struct nfs_rw_ops *rw_ops,
 			     size_t bsize,
-			     int how);
+			     int how,
+			     gfp_t gfp_flags);
 extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
 				   struct nfs_page *);
 extern  int nfs_pageio_resend(struct nfs_pageio_descriptor *,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 348f7c158084..51e27f9746ee 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1427,6 +1427,7 @@ struct nfs_pgio_header {
 	struct list_head	pages;
 	struct nfs_page		*req;
 	struct nfs_writeverf	verf;		/* Used for writes */
+	fmode_t			rw_mode;
 	struct pnfs_layout_segment *lseg;
 	loff_t			io_start;
 	const struct rpc_call_ops *mds_ops;
-- 
2.9.3

