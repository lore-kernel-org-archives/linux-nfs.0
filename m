Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:64037 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbaEATOj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 15:14:39 -0400
Received: by mail-ie0-f181.google.com with SMTP id y20so3942903ier.40
        for <linux-nfs@vger.kernel.org>; Thu, 01 May 2014 12:14:38 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 1/3] nfs: move nfs_pgio_data and remove nfs_rw_header
Date: Thu,  1 May 2014 15:14:51 -0400
Message-Id: <1398971693-82399-2-git-send-email-dros@primarydata.com>
In-Reply-To: <1398971693-82399-1-git-send-email-dros@primarydata.com>
References: <1398971693-82399-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_rw_header was used to allocate an nfs_pgio_header along with an
nfs_pgio_data, because a _header would need at least one _data.

Now there is only ever one nfs_pgio_data for each nfs_pgio_header -- move
it to nfs_pgio_header and get rid of nfs_rw_header.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/direct.c          |  8 ++---
 fs/nfs/internal.h        |  6 ++--
 fs/nfs/pageio.c          | 85 +++++++++++++++---------------------------------
 fs/nfs/pnfs.c            | 24 ++++++--------
 fs/nfs/read.c            |  6 ++--
 fs/nfs/write.c           | 10 +++---
 include/linux/nfs_page.h |  4 +--
 include/linux/nfs_xdr.h  | 38 +++++++++-------------
 8 files changed, 69 insertions(+), 112 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 4ad7bc3..8a55f59 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -148,8 +148,8 @@ static void nfs_direct_set_hdr_verf(struct nfs_direct_req *dreq,
 {
 	struct nfs_writeverf *verfp;
 
-	verfp = nfs_direct_select_verf(dreq, hdr->data->ds_clp,
-				      hdr->data->ds_idx);
+	verfp = nfs_direct_select_verf(dreq, hdr->data.ds_clp,
+				      hdr->data.ds_idx);
 	WARN_ON_ONCE(verfp->committed >= 0);
 	memcpy(verfp, &hdr->verf, sizeof(struct nfs_writeverf));
 	WARN_ON_ONCE(verfp->committed < 0);
@@ -169,8 +169,8 @@ static int nfs_direct_set_or_cmp_hdr_verf(struct nfs_direct_req *dreq,
 {
 	struct nfs_writeverf *verfp;
 
-	verfp = nfs_direct_select_verf(dreq, hdr->data->ds_clp,
-					 hdr->data->ds_idx);
+	verfp = nfs_direct_select_verf(dreq, hdr->data.ds_clp,
+					 hdr->data.ds_idx);
 	if (verfp->committed < 0) {
 		nfs_direct_set_hdr_verf(dreq, hdr);
 		return 0;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0c22142..08df643 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -397,9 +397,9 @@ struct nfs_pgio_completion_ops;
 
 /* pageio.c */
 extern const struct nfs_pageio_ops nfs_pgio_rw_ops;
-extern struct nfs_rw_header *nfs_rw_header_alloc(const struct nfs_rw_ops *);
-extern void nfs_rw_header_free(struct nfs_pgio_header *);
-extern void nfs_pgio_data_release(struct nfs_pgio_data *);
+extern struct nfs_pgio_header *nfs_pgio_header_alloc(const struct nfs_rw_ops *);
+extern void nfs_pgio_header_free(struct nfs_pgio_header *);
+extern void nfs_pgio_data_destroy(struct nfs_pgio_data *);
 extern int nfs_generic_pgio(struct nfs_pageio_descriptor *, struct nfs_pgio_header *);
 extern int nfs_initiate_pgio(struct rpc_clnt *, struct nfs_pgio_data *,
 			     const struct rpc_call_ops *, int, int);
diff --git a/fs/nfs/pageio.c b/fs/nfs/pageio.c
index f578cc9..de8bcb4 100644
--- a/fs/nfs/pageio.c
+++ b/fs/nfs/pageio.c
@@ -16,78 +16,49 @@
 static const struct rpc_call_ops nfs_pgio_common_ops;
 
 
-static inline struct nfs_rw_header *NFS_RW_HEADER(struct nfs_pgio_header *hdr)
+struct nfs_pgio_header *nfs_pgio_header_alloc(const struct nfs_rw_ops *ops)
 {
-	return container_of(hdr, struct nfs_rw_header, header);
-}
-
-struct nfs_rw_header *nfs_rw_header_alloc(const struct nfs_rw_ops *ops)
-{
-	struct nfs_rw_header *header = ops->rw_alloc_header();
-
-	if (header) {
-		struct nfs_pgio_header *hdr = &header->header;
+	struct nfs_pgio_header *hdr = ops->rw_alloc_header();
 
+	if (hdr) {
 		INIT_LIST_HEAD(&hdr->pages);
 		spin_lock_init(&hdr->lock);
 		atomic_set(&hdr->refcnt, 0);
 		hdr->rw_ops = ops;
 	}
-	return header;
+	return hdr;
 }
-EXPORT_SYMBOL_GPL(nfs_rw_header_alloc);
+EXPORT_SYMBOL_GPL(nfs_pgio_header_alloc);
 
-void nfs_rw_header_free(struct nfs_pgio_header *hdr)
+void nfs_pgio_header_free(struct nfs_pgio_header *hdr)
 {
-	hdr->rw_ops->rw_free_header(NFS_RW_HEADER(hdr));
+	hdr->rw_ops->rw_free_header(hdr);
 }
-EXPORT_SYMBOL_GPL(nfs_rw_header_free);
+EXPORT_SYMBOL_GPL(nfs_pgio_header_free);
 
-static struct nfs_pgio_data *nfs_pgio_data_alloc(struct nfs_pgio_header *hdr,
-						 unsigned int pagecount)
+static bool nfs_pgio_data_init(struct nfs_pgio_header *hdr,
+			       unsigned int pagecount)
 {
-	struct nfs_pgio_data *data, *prealloc;
-
-	prealloc = &NFS_RW_HEADER(hdr)->rpc_data;
-	if (prealloc->header == NULL)
-		data = prealloc;
-	else
-		data = kzalloc(sizeof(*data), GFP_KERNEL);
-	if (!data)
-		goto out;
-
-	if (nfs_pgarray_set(&data->pages, pagecount)) {
-		data->header = hdr;
+	if (nfs_pgarray_set(&hdr->data.pages, pagecount)) {
+		hdr->data.header = hdr;
 		atomic_inc(&hdr->refcnt);
-	} else {
-		if (data != prealloc)
-			kfree(data);
-		data = NULL;
+		return true;
 	}
-out:
-	return data;
+
+	return false;
 }
 
-void nfs_pgio_data_release(struct nfs_pgio_data *data)
+void nfs_pgio_data_destroy(struct nfs_pgio_data *data)
 {
 	struct nfs_pgio_header *hdr = data->header;
-	struct nfs_rw_header *pageio_header = NFS_RW_HEADER(hdr);
 
 	put_nfs_open_context(data->args.context);
 	if (data->pages.pagevec != data->pages.page_array)
 		kfree(data->pages.pagevec);
-	if (data == &pageio_header->rpc_data) {
-		data->header = NULL;
-		data = NULL;
-	}
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
-	/* Note: we only free the rpc_task after callbacks are done.
-	 * See the comment in rpc_free_task() for why
-	 */
-	kfree(data);
 }
-EXPORT_SYMBOL_GPL(nfs_pgio_data_release);
+EXPORT_SYMBOL_GPL(nfs_pgio_data_destroy);
 
 static void nfs_pgio_rpcsetup(struct nfs_pgio_data *data,
 			      unsigned int count, unsigned int offset,
@@ -185,8 +156,7 @@ static int nfs_pgio_error(struct nfs_pageio_descriptor *desc,
 			  struct nfs_pgio_header *hdr)
 {
 	set_bit(NFS_IOHDR_REDO, &hdr->flags);
-	nfs_pgio_data_release(hdr->data);
-	hdr->data = NULL;
+	nfs_pgio_data_destroy(&hdr->data);
 	desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 	return -ENOMEM;
 }
@@ -208,11 +178,11 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 	struct list_head *head = &desc->pg_list;
 	struct nfs_commit_info cinfo;
 
-	data = nfs_pgio_data_alloc(hdr, nfs_page_array_len(desc->pg_base,
-							   desc->pg_count));
-	if (!data)
+	if (!nfs_pgio_data_init(hdr, nfs_page_array_len(desc->pg_base,
+			   desc->pg_count)))
 		return nfs_pgio_error(desc, hdr);
 
+	data = &hdr->data;
 	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
 	pages = data->pages.pagevec;
 	while (!list_empty(head)) {
@@ -228,7 +198,6 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 
 	/* Set up the argument struct */
 	nfs_pgio_rpcsetup(data, desc->pg_count, 0, desc->pg_ioflags, &cinfo);
-	hdr->data = data;
 	desc->pg_rpc_callops = &nfs_pgio_common_ops;
 	return 0;
 }
@@ -236,21 +205,19 @@ EXPORT_SYMBOL_GPL(nfs_generic_pgio);
 
 static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
 {
-	struct nfs_rw_header *rw_hdr;
 	struct nfs_pgio_header *hdr;
 	int ret;
 
-	rw_hdr = nfs_rw_header_alloc(desc->pg_rw_ops);
-	if (!rw_hdr) {
+	hdr = nfs_pgio_header_alloc(desc->pg_rw_ops);
+	if (!hdr) {
 		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 		return -ENOMEM;
 	}
-	hdr = &rw_hdr->header;
-	nfs_pgheader_init(desc, hdr, nfs_rw_header_free);
+	nfs_pgheader_init(desc, hdr, nfs_pgio_header_free);
 	atomic_inc(&hdr->refcnt);
 	ret = nfs_generic_pgio(desc, hdr);
 	if (ret == 0)
-		ret = nfs_do_pgio(hdr->data, desc->pg_rpc_callops, 0);
+		ret = nfs_do_pgio(&hdr->data, desc->pg_rpc_callops, 0);
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
 	return ret;
@@ -270,7 +237,7 @@ void nfs_pgio_release_common(void *calldata)
 	struct nfs_pgio_data *data = calldata;
 	if (data->header->rw_ops->rw_release)
 		data->header->rw_ops->rw_release(data);
-	nfs_pgio_data_release(data);
+	nfs_pgio_data_destroy(data);
 }
 
 static int nfs_pgio_result(struct rpc_task *task, struct nfs_pgio_data *data)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ce46a41..46ecf47 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1542,7 +1542,7 @@ pnfs_write_through_mds(struct nfs_pageio_descriptor *desc,
 		nfs_pageio_reset_write_mds(desc);
 		desc->pg_recoalesce = 1;
 	}
-	nfs_pgio_data_release(data);
+	nfs_pgio_data_destroy(data);
 }
 
 static enum pnfs_try_status
@@ -1571,7 +1571,7 @@ static void
 pnfs_do_write(struct nfs_pageio_descriptor *desc,
 	      struct nfs_pgio_header *hdr, int how)
 {
-	struct nfs_pgio_data *data = hdr->data;
+	struct nfs_pgio_data *data = &hdr->data;
 	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
 	struct pnfs_layout_segment *lseg = desc->pg_lseg;
 	enum pnfs_try_status trypnfs;
@@ -1586,25 +1586,23 @@ pnfs_do_write(struct nfs_pageio_descriptor *desc,
 static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
 {
 	pnfs_put_lseg(hdr->lseg);
-	nfs_rw_header_free(hdr);
+	nfs_pgio_header_free(hdr);
 }
 EXPORT_SYMBOL_GPL(pnfs_writehdr_free);
 
 int
 pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 {
-	struct nfs_rw_header *whdr;
 	struct nfs_pgio_header *hdr;
 	int ret;
 
-	whdr = nfs_rw_header_alloc(desc->pg_rw_ops);
-	if (!whdr) {
+	hdr = nfs_pgio_header_alloc(desc->pg_rw_ops);
+	if (!hdr) {
 		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 		pnfs_put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
 		return -ENOMEM;
 	}
-	hdr = &whdr->header;
 	nfs_pgheader_init(desc, hdr, pnfs_writehdr_free);
 	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
 	atomic_inc(&hdr->refcnt);
@@ -1692,7 +1690,7 @@ pnfs_read_through_mds(struct nfs_pageio_descriptor *desc,
 		nfs_pageio_reset_read_mds(desc);
 		desc->pg_recoalesce = 1;
 	}
-	nfs_pgio_data_release(data);
+	nfs_pgio_data_destroy(data);
 }
 
 /*
@@ -1723,7 +1721,7 @@ pnfs_try_to_read_data(struct nfs_pgio_data *rdata,
 static void
 pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 {
-	struct nfs_pgio_data *data = hdr->data;
+	struct nfs_pgio_data *data = &hdr->data;
 	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
 	struct pnfs_layout_segment *lseg = desc->pg_lseg;
 	enum pnfs_try_status trypnfs;
@@ -1738,26 +1736,24 @@ pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 static void pnfs_readhdr_free(struct nfs_pgio_header *hdr)
 {
 	pnfs_put_lseg(hdr->lseg);
-	nfs_rw_header_free(hdr);
+	nfs_pgio_header_free(hdr);
 }
 EXPORT_SYMBOL_GPL(pnfs_readhdr_free);
 
 int
 pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 {
-	struct nfs_rw_header *rhdr;
 	struct nfs_pgio_header *hdr;
 	int ret;
 
-	rhdr = nfs_rw_header_alloc(desc->pg_rw_ops);
-	if (!rhdr) {
+	hdr = nfs_pgio_header_alloc(desc->pg_rw_ops);
+	if (!hdr) {
 		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 		ret = -ENOMEM;
 		pnfs_put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
 		return ret;
 	}
-	hdr = &rhdr->header;
 	nfs_pgheader_init(desc, hdr, pnfs_readhdr_free);
 	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
 	atomic_inc(&hdr->refcnt);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 3ea06f0..33037a0 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -33,12 +33,12 @@ static const struct nfs_rw_ops nfs_rw_read_ops;
 
 static struct kmem_cache *nfs_rdata_cachep;
 
-static struct nfs_rw_header *nfs_readhdr_alloc(void)
+static struct nfs_pgio_header *nfs_readhdr_alloc(void)
 {
 	return kmem_cache_zalloc(nfs_rdata_cachep, GFP_KERNEL);
 }
 
-static void nfs_readhdr_free(struct nfs_rw_header *rhdr)
+static void nfs_readhdr_free(struct nfs_pgio_header *rhdr)
 {
 	kmem_cache_free(nfs_rdata_cachep, rhdr);
 }
@@ -404,7 +404,7 @@ out:
 int __init nfs_init_readpagecache(void)
 {
 	nfs_rdata_cachep = kmem_cache_create("nfs_read_data",
-					     sizeof(struct nfs_rw_header),
+					     sizeof(struct nfs_pgio_header),
 					     0, SLAB_HWCACHE_ALIGN,
 					     NULL);
 	if (nfs_rdata_cachep == NULL)
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index eb1ab6a..ffcbb2d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -70,18 +70,18 @@ void nfs_commit_free(struct nfs_commit_data *p)
 }
 EXPORT_SYMBOL_GPL(nfs_commit_free);
 
-static struct nfs_rw_header *nfs_writehdr_alloc(void)
+static struct nfs_pgio_header *nfs_writehdr_alloc(void)
 {
-	struct nfs_rw_header *p = mempool_alloc(nfs_wdata_mempool, GFP_NOIO);
+	struct nfs_pgio_header *p = mempool_alloc(nfs_wdata_mempool, GFP_NOIO);
 
 	if (p)
 		memset(p, 0, sizeof(*p));
 	return p;
 }
 
-static void nfs_writehdr_free(struct nfs_rw_header *whdr)
+static void nfs_writehdr_free(struct nfs_pgio_header *hdr)
 {
-	mempool_free(whdr, nfs_wdata_mempool);
+	mempool_free(hdr, nfs_wdata_mempool);
 }
 
 static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
@@ -1653,7 +1653,7 @@ int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
 int __init nfs_init_writepagecache(void)
 {
 	nfs_wdata_cachep = kmem_cache_create("nfs_write_data",
-					     sizeof(struct nfs_rw_header),
+					     sizeof(struct nfs_pgio_header),
 					     0, SLAB_HWCACHE_ALIGN,
 					     NULL);
 	if (nfs_wdata_cachep == NULL)
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 6500b85..b2e5a8a 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -62,8 +62,8 @@ struct nfs_pageio_ops {
 
 struct nfs_rw_ops {
 	const fmode_t rw_mode;
-	struct nfs_rw_header *(*rw_alloc_header)(void);
-	void (*rw_free_header)(struct nfs_rw_header *);
+	struct nfs_pgio_header *(*rw_alloc_header)(void);
+	void (*rw_free_header)(struct nfs_pgio_header *);
 	void (*rw_release)(struct nfs_pgio_data *);
 	int  (*rw_result)(struct rpc_task *, struct nfs_pgio_data *, struct inode *);
 	void (*rw_result_common)(struct rpc_task *, struct nfs_pgio_data *);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 5a0b322..a7ccc8c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1256,13 +1256,27 @@ enum {
 	NFS_IOHDR_NEED_RESCHED,
 };
 
-struct nfs_pgio_data;
+struct nfs_pgio_data {
+	struct nfs_pgio_header	*header;
+	struct list_head	list;
+	struct rpc_task		task;
+	struct nfs_fattr	fattr;
+	struct nfs_writeverf	verf;		/* Used for writes */
+	struct nfs_pgio_args	args;		/* argument struct */
+	struct nfs_pgio_res	res;		/* result struct */
+	unsigned long		timestamp;	/* For lease renewal */
+	int (*pgio_done_cb)(struct rpc_task *task, struct nfs_pgio_data *data);
+	__u64			mds_offset;	/* Filelayout dense stripe */
+	struct nfs_page_array	pages;
+	struct nfs_client	*ds_clp;	/* pNFS data server */
+	int			ds_idx;		/* ds index if ds_clp is set */
+};
 
 struct nfs_pgio_header {
 	struct inode		*inode;
 	struct rpc_cred		*cred;
 	struct list_head	pages;
-	struct nfs_pgio_data	*data;
+	struct nfs_pgio_data	data;
 	atomic_t		refcnt;
 	struct nfs_page		*req;
 	struct nfs_writeverf	verf;		/* Used for writes */
@@ -1282,26 +1296,6 @@ struct nfs_pgio_header {
 	unsigned long		flags;
 };
 
-struct nfs_pgio_data {
-	struct nfs_pgio_header	*header;
-	struct rpc_task		task;
-	struct nfs_fattr	fattr;
-	struct nfs_writeverf	verf;		/* Used for writes */
-	struct nfs_pgio_args	args;		/* argument struct */
-	struct nfs_pgio_res	res;		/* result struct */
-	unsigned long		timestamp;	/* For lease renewal */
-	int (*pgio_done_cb) (struct rpc_task *task, struct nfs_pgio_data *data);
-	__u64			mds_offset;	/* Filelayout dense stripe */
-	struct nfs_page_array	pages;
-	struct nfs_client	*ds_clp;	/* pNFS data server */
-	int			ds_idx;		/* ds index if ds_clp is set */
-};
-
-struct nfs_rw_header {
-	struct nfs_pgio_header	header;
-	struct nfs_pgio_data	rpc_data;
-};
-
 struct nfs_mds_commit_info {
 	atomic_t rpcs_out;
 	unsigned long		ncommit;
-- 
1.8.5.2 (Apple Git-48)

