Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:32083 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932532Ab2DTSsO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:48:14 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 13/25] NFS: create struct nfs_page_array
Date: Fri, 20 Apr 2012 14:47:45 -0400
Message-Id: <1334947677-28864-14-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both nfs_read_data and nfs_write_data devote several fields which
can be combined into a single shared struct.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/blocklayout/blocklayout.c |   11 +++++----
 fs/nfs/direct.c                  |   40 +++++++++++++++++++++----------------
 fs/nfs/internal.h                |    1 +
 fs/nfs/pagelist.c                |   13 ++++++++++++
 fs/nfs/read.c                    |   22 +++++++-------------
 fs/nfs/write.c                   |   22 +++++++-------------
 include/linux/nfs_xdr.h          |   14 +++++++-----
 7 files changed, 67 insertions(+), 56 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 192e16a..3f58832 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -240,7 +240,7 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 	int pg_index = rdata->args.pgbase >> PAGE_CACHE_SHIFT;
 
 	dprintk("%s enter nr_pages %u offset %lld count %u\n", __func__,
-	       rdata->npages, f_offset, (unsigned int)rdata->args.count);
+	       rdata->pages.npages, f_offset, (unsigned int)rdata->args.count);
 
 	par = alloc_parallel(rdata);
 	if (!par)
@@ -250,7 +250,7 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 
 	isect = (sector_t) (f_offset >> SECTOR_SHIFT);
 	/* Code assumes extents are page-aligned */
-	for (i = pg_index; i < rdata->npages; i++) {
+	for (i = pg_index; i < rdata->pages.npages; i++) {
 		if (!extent_length) {
 			/* We've used up the previous extent */
 			bl_put_extent(be);
@@ -283,7 +283,8 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 			struct pnfs_block_extent *be_read;
 
 			be_read = (hole && cow_read) ? cow_read : be;
-			bio = bl_add_page_to_bio(bio, rdata->npages - i, READ,
+			bio = bl_add_page_to_bio(bio, rdata->pages.npages - i,
+						 READ,
 						 isect, pages[i], be_read,
 						 bl_end_io_read, par);
 			if (IS_ERR(bio)) {
@@ -652,7 +653,7 @@ next_page:
 
 	/* Middle pages */
 	pg_index = wdata->args.pgbase >> PAGE_CACHE_SHIFT;
-	for (i = pg_index; i < wdata->npages; i++) {
+	for (i = pg_index; i < wdata->pages.npages; i++) {
 		if (!extent_length) {
 			/* We've used up the previous extent */
 			bl_put_extent(be);
@@ -686,7 +687,7 @@ next_page:
 				goto out;
 			}
 		}
-		bio = bl_add_page_to_bio(bio, wdata->npages - i, WRITE,
+		bio = bl_add_page_to_bio(bio, wdata->pages.npages - i, WRITE,
 					 isect, pages[i], be,
 					 bl_end_io_write, par);
 		if (IS_ERR(bio)) {
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 56176af..0faba4c 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -252,11 +252,11 @@ static void nfs_direct_read_release(void *calldata)
 	} else {
 		dreq->count += data->res.count;
 		spin_unlock(&dreq->lock);
-		nfs_direct_dirty_pages(data->pagevec,
+		nfs_direct_dirty_pages(data->pages.pagevec,
 				data->args.pgbase,
 				data->res.count);
 	}
-	nfs_direct_release_pages(data->pagevec, data->npages);
+	nfs_direct_release_pages(data->pages.pagevec, data->pages.npages);
 
 	if (put_dreq(dreq))
 		nfs_direct_complete(dreq);
@@ -273,8 +273,8 @@ static void nfs_direct_readhdr_release(struct nfs_read_header *rhdr)
 {
 	struct nfs_read_data *data = &rhdr->rpc_data;
 
-	if (data->pagevec != data->page_array)
-		kfree(data->pagevec);
+	if (data->pages.pagevec != data->pages.page_array)
+		kfree(data->pages.pagevec);
 	nfs_readhdr_free(&rhdr->header);
 }
 
@@ -312,6 +312,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 	do {
 		struct nfs_read_header *rhdr;
 		struct nfs_read_data *data;
+		struct nfs_page_array *pages;
 		size_t bytes;
 
 		pgbase = user_addr & ~PAGE_MASK;
@@ -322,24 +323,25 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		if (unlikely(!rhdr))
 			break;
 		data = &rhdr->rpc_data;
+		pages = &data->pages;
 
 		down_read(&current->mm->mmap_sem);
 		result = get_user_pages(current, current->mm, user_addr,
-					data->npages, 1, 0, data->pagevec, NULL);
+					pages->npages, 1, 0, pages->pagevec, NULL);
 		up_read(&current->mm->mmap_sem);
 		if (result < 0) {
 			nfs_direct_readhdr_release(rhdr);
 			break;
 		}
-		if ((unsigned)result < data->npages) {
+		if ((unsigned)result < pages->npages) {
 			bytes = result * PAGE_SIZE;
 			if (bytes <= pgbase) {
-				nfs_direct_release_pages(data->pagevec, result);
+				nfs_direct_release_pages(pages->pagevec, result);
 				nfs_direct_readhdr_release(rhdr);
 				break;
 			}
 			bytes -= pgbase;
-			data->npages = result;
+			pages->npages = result;
 		}
 
 		get_dreq(dreq);
@@ -352,7 +354,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		data->args.lock_context = dreq->l_ctx;
 		data->args.offset = pos;
 		data->args.pgbase = pgbase;
-		data->args.pages = data->pagevec;
+		data->args.pages = pages->pagevec;
 		data->args.count = bytes;
 		data->res.fattr = &data->fattr;
 		data->res.eof = 0;
@@ -462,8 +464,8 @@ static void nfs_direct_writehdr_release(struct nfs_write_header *whdr)
 {
 	struct nfs_write_data *data = &whdr->rpc_data;
 
-	if (data->pagevec != data->page_array)
-		kfree(data->pagevec);
+	if (data->pages.pagevec != data->pages.page_array)
+		kfree(data->pages.pagevec);
 	nfs_writehdr_free(&whdr->header);
 }
 
@@ -472,8 +474,10 @@ static void nfs_direct_free_writedata(struct nfs_direct_req *dreq)
 	while (!list_empty(&dreq->rewrite_list)) {
 		struct nfs_pgio_header *hdr = list_entry(dreq->rewrite_list.next, struct nfs_pgio_header, pages);
 		struct nfs_write_header *whdr = container_of(hdr, struct nfs_write_header, header);
+		struct nfs_page_array *p = &whdr->rpc_data.pages;
+
 		list_del(&hdr->pages);
-		nfs_direct_release_pages(whdr->rpc_data.pagevec, whdr->rpc_data.npages);
+		nfs_direct_release_pages(p->pagevec, p->npages);
 		nfs_direct_writehdr_release(whdr);
 	}
 }
@@ -751,6 +755,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 	do {
 		struct nfs_write_header *whdr;
 		struct nfs_write_data *data;
+		struct nfs_page_array *pages;
 		size_t bytes;
 
 		pgbase = user_addr & ~PAGE_MASK;
@@ -762,24 +767,25 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 			break;
 
 		data = &whdr->rpc_data;
+		pages = &data->pages;
 
 		down_read(&current->mm->mmap_sem);
 		result = get_user_pages(current, current->mm, user_addr,
-					data->npages, 0, 0, data->pagevec, NULL);
+					pages->npages, 0, 0, pages->pagevec, NULL);
 		up_read(&current->mm->mmap_sem);
 		if (result < 0) {
 			nfs_direct_writehdr_release(whdr);
 			break;
 		}
-		if ((unsigned)result < data->npages) {
+		if ((unsigned)result < pages->npages) {
 			bytes = result * PAGE_SIZE;
 			if (bytes <= pgbase) {
-				nfs_direct_release_pages(data->pagevec, result);
+				nfs_direct_release_pages(pages->pagevec, result);
 				nfs_direct_writehdr_release(whdr);
 				break;
 			}
 			bytes -= pgbase;
-			data->npages = result;
+			pages->npages = result;
 		}
 
 		get_dreq(dreq);
@@ -794,7 +800,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		data->args.lock_context = dreq->l_ctx;
 		data->args.offset = pos;
 		data->args.pgbase = pgbase;
-		data->args.pages = data->pagevec;
+		data->args.pages = pages->pagevec;
 		data->args.count = bytes;
 		data->args.stable = sync;
 		data->res.fattr = &data->fattr;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9b2b8bf..0818e66 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -209,6 +209,7 @@ extern void nfs_destroy_writepagecache(void);
 
 extern int __init nfs_init_directcache(void);
 extern void nfs_destroy_directcache(void);
+extern bool nfs_pgarray_set(struct nfs_page_array *p, unsigned int pagecount);
 
 /* nfs2xdr.c */
 extern int nfs_stat_to_errno(enum nfs_stat);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index d21fcea..d349bd4 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -26,6 +26,19 @@
 
 static struct kmem_cache *nfs_page_cachep;
 
+bool nfs_pgarray_set(struct nfs_page_array *p, unsigned int pagecount)
+{
+	p->npages = pagecount;
+	if (pagecount <= ARRAY_SIZE(p->page_array))
+		p->pagevec = p->page_array;
+	else {
+		p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_KERNEL);
+		if (!p->pagevec)
+			p->npages = 0;
+	}
+	return p->pagevec != NULL;
+}
+
 static inline struct nfs_page *
 nfs_page_alloc(void)
 {
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index d6d4682..f6ab30b 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -46,16 +46,10 @@ struct nfs_read_header *nfs_readhdr_alloc(unsigned int pagecount)
 
 		INIT_LIST_HEAD(&hdr->pages);
 		INIT_LIST_HEAD(&data->list);
-		data->npages = pagecount;
 		data->header = hdr;
-		if (pagecount <= ARRAY_SIZE(data->page_array))
-			data->pagevec = data->page_array;
-		else {
-			data->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_KERNEL);
-			if (!data->pagevec) {
-				kmem_cache_free(nfs_rdata_cachep, p);
-				p = NULL;
-			}
+		if (!nfs_pgarray_set(&data->pages, pagecount)) {
+			kmem_cache_free(nfs_rdata_cachep, p);
+			p = NULL;
 		}
 	}
 	return p;
@@ -71,8 +65,8 @@ void nfs_readhdr_free(struct nfs_pgio_header *hdr)
 void nfs_readdata_release(struct nfs_read_data *rdata)
 {
 	put_nfs_open_context(rdata->args.context);
-	if (rdata->pagevec != rdata->page_array)
-		kfree(rdata->pagevec);
+	if (rdata->pages.pagevec != rdata->pages.page_array)
+		kfree(rdata->pages.pagevec);
 	nfs_readhdr_free(rdata->header);
 }
 
@@ -232,7 +226,7 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req) + offset;
 	data->args.pgbase = req->wb_pgbase + offset;
-	data->args.pages  = data->pagevec;
+	data->args.pages  = data->pages.pagevec;
 	data->args.count  = count;
 	data->args.context = get_nfs_open_context(req->wb_context);
 	data->args.lock_context = req->wb_lock_context;
@@ -318,7 +312,7 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc, struct list_head
 		if (!rhdr)
 			goto out_bad;
 		data = &rhdr->rpc_data;
-		data->pagevec[0] = page;
+		data->pages.pagevec[0] = page;
 		nfs_read_rpcsetup(req, data, len, offset);
 		list_add(&data->list, res);
 		requests++;
@@ -356,7 +350,7 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc, struct list_head *
 	}
 
 	data = &rhdr->rpc_data;
-	pages = data->pagevec;
+	pages = data->pages.pagevec;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index dbb5c0a..2efae04 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -80,16 +80,10 @@ struct nfs_write_header *nfs_writehdr_alloc(unsigned int pagecount)
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&hdr->pages);
 		INIT_LIST_HEAD(&data->list);
-		data->npages = pagecount;
 		data->header = hdr;
-		if (pagecount <= ARRAY_SIZE(data->page_array))
-			data->pagevec = data->page_array;
-		else {
-			data->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_NOFS);
-			if (!data->pagevec) {
-				mempool_free(p, nfs_wdata_mempool);
-				p = NULL;
-			}
+		if (!nfs_pgarray_set(&data->pages, pagecount)) {
+			mempool_free(p, nfs_wdata_mempool);
+			p = NULL;
 		}
 	}
 	return p;
@@ -104,8 +98,8 @@ void nfs_writehdr_free(struct nfs_pgio_header *hdr)
 void nfs_writedata_release(struct nfs_write_data *wdata)
 {
 	put_nfs_open_context(wdata->args.context);
-	if (wdata->pagevec != wdata->page_array)
-		kfree(wdata->pagevec);
+	if (wdata->pages.pagevec != wdata->pages.page_array)
+		kfree(wdata->pages.pagevec);
 	nfs_writehdr_free(wdata->header);
 }
 
@@ -916,7 +910,7 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 	/* pnfs_set_layoutcommit needs this */
 	data->mds_offset = data->args.offset;
 	data->args.pgbase = req->wb_pgbase + offset;
-	data->args.pages  = data->pagevec;
+	data->args.pages  = data->pages.pagevec;
 	data->args.count  = count;
 	data->args.context = get_nfs_open_context(req->wb_context);
 	data->args.lock_context = req->wb_lock_context;
@@ -1011,7 +1005,7 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc, struct list_head
 		if (!whdr)
 			goto out_bad;
 		data = &whdr->rpc_data;
-		data->pagevec[0] = page;
+		data->pages.pagevec[0] = page;
 		nfs_write_rpcsetup(req, data, len, offset, desc->pg_ioflags);
 		list_add(&data->list, res);
 		requests++;
@@ -1061,7 +1055,7 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc, struct list_head *r
 		goto out;
 	}
 	data = &whdr->rpc_data;
-	pages = data->pagevec;
+	pages = data->pages.pagevec;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 0e31c44..060896f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1162,19 +1162,23 @@ struct nfs_page;
 
 #define NFS_PAGEVEC_SIZE	(8U)
 
+struct nfs_page_array {
+	struct page		**pagevec;
+	unsigned int		npages;		/* Max length of pagevec */
+	struct page		*page_array[NFS_PAGEVEC_SIZE];
+};
+
 struct nfs_read_data {
 	struct nfs_pgio_header	*header;
 	struct list_head	list;
 	struct rpc_task		task;
 	struct nfs_fattr	fattr;	/* fattr storage */
-	struct page		**pagevec;
-	unsigned int		npages;	/* Max length of pagevec */
 	struct nfs_readargs args;
 	struct nfs_readres  res;
 	unsigned long		timestamp;	/* For lease renewal */
 	int (*read_done_cb) (struct rpc_task *task, struct nfs_read_data *data);
 	__u64			mds_offset;
-	struct page		*page_array[NFS_PAGEVEC_SIZE];
+	struct nfs_page_array	pages;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
 };
 
@@ -1201,14 +1205,12 @@ struct nfs_write_data {
 	struct rpc_task		task;
 	struct nfs_fattr	fattr;
 	struct nfs_writeverf	verf;
-	struct page		**pagevec;
-	unsigned int		npages;		/* Max length of pagevec */
 	struct nfs_writeargs	args;		/* argument struct */
 	struct nfs_writeres	res;		/* result struct */
 	unsigned long		timestamp;	/* For lease renewal */
 	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
 	__u64			mds_offset;	/* Filelayout dense stripe */
-	struct page		*page_array[NFS_PAGEVEC_SIZE];
+	struct nfs_page_array	pages;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
 };
 
-- 
1.7.2.1

