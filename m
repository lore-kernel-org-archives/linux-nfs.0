Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:65133 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750797AbaDYVFp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2014 17:05:45 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [PATCH v2 07/17] NFS: Create a common rw_header_alloc and rw_header_free function
Date: Fri, 25 Apr 2014 16:55:50 -0400
Message-ID: <1398459360-2093-8-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1398459360-2093-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1398459360-2093-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

I create a new struct nfs_rw_ops to decide the differences between reads
and writes.  This struct will be set when initializing a new
nfs_pgio_descriptor, and then passed on to the nfs_rw_header when a new
header is allocated.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/internal.h        |  6 ++----
 fs/nfs/pageio.c          | 24 ++++++++++++++++++++++++
 fs/nfs/pagelist.c        |  2 ++
 fs/nfs/pnfs.c            |  8 ++++----
 fs/nfs/read.c            | 34 +++++++++++++---------------------
 fs/nfs/write.c           | 28 ++++++++++++----------------
 include/linux/nfs_page.h |  7 +++++++
 include/linux/nfs_xdr.h  |  1 +
 8 files changed, 65 insertions(+), 45 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7f9d3c4..7e8d311 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -396,12 +396,12 @@ extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh, bool
 struct nfs_pgio_completion_ops;
 
 /* pageio.c */
+extern struct nfs_rw_header *nfs_rw_header_alloc(const struct nfs_rw_ops *);
+extern void nfs_rw_header_free(struct nfs_pgio_header *);
 extern struct nfs_pgio_data *nfs_pgio_data_alloc(struct nfs_pgio_header *, unsigned int);
 extern void nfs_pgio_data_release(struct nfs_pgio_data *);
 
 /* read.c */
-extern struct nfs_rw_header *nfs_readhdr_alloc(void);
-extern void nfs_readhdr_free(struct nfs_pgio_header *hdr);
 extern void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 			struct inode *inode, bool force_mds,
 			const struct nfs_pgio_completion_ops *compl_ops);
@@ -428,8 +428,6 @@ int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
 extern void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 			struct inode *inode, int ioflags, bool force_mds,
 			const struct nfs_pgio_completion_ops *compl_ops);
-extern struct nfs_rw_header *nfs_writehdr_alloc(void);
-extern void nfs_writehdr_free(struct nfs_pgio_header *hdr);
 extern int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
 			     struct nfs_pgio_header *hdr);
 extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
diff --git a/fs/nfs/pageio.c b/fs/nfs/pageio.c
index 895bb37..b4d6fe4 100644
--- a/fs/nfs/pageio.c
+++ b/fs/nfs/pageio.c
@@ -6,6 +6,7 @@
  * Copyright (c) 2014 Anna Schumaker <anna.schumaker@netapp.com>
  */
 #include <linux/nfs_fs.h>
+#include <linux/nfs_page.h>
 #include <linux/nfs_xdr.h>
 
 #include "internal.h"
@@ -16,6 +17,29 @@ static inline struct nfs_rw_header *NFS_RW_HEADER(struct nfs_pgio_header *hdr)
 	return container_of(hdr, struct nfs_rw_header, header);
 }
 
+struct nfs_rw_header *nfs_rw_header_alloc(const struct nfs_rw_ops *ops)
+{
+	struct nfs_rw_header *header = ops->rw_alloc_header();
+
+	if (header) {
+		struct nfs_pgio_header *hdr = &header->header;
+
+		INIT_LIST_HEAD(&hdr->pages);
+		INIT_LIST_HEAD(&hdr->rpc_list);
+		spin_lock_init(&hdr->lock);
+		atomic_set(&hdr->refcnt, 0);
+		hdr->rw_ops = ops;
+	}
+	return header;
+}
+EXPORT_SYMBOL_GPL(nfs_rw_header_alloc);
+
+void nfs_rw_header_free(struct nfs_pgio_header *hdr)
+{
+	hdr->rw_ops->rw_free_header(NFS_RW_HEADER(hdr));
+}
+EXPORT_SYMBOL_GPL(nfs_rw_header_free);
+
 struct nfs_pgio_data *nfs_pgio_data_alloc(struct nfs_pgio_header *hdr,
 					  unsigned int pagecount)
 {
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 2ffebf2..8221706 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -307,6 +307,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 		     struct inode *inode,
 		     const struct nfs_pageio_ops *pg_ops,
 		     const struct nfs_pgio_completion_ops *compl_ops,
+		     const struct nfs_rw_ops *rw_ops,
 		     size_t bsize,
 		     int io_flags)
 {
@@ -320,6 +321,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_inode = inode;
 	desc->pg_ops = pg_ops;
 	desc->pg_completion_ops = compl_ops;
+	desc->pg_rw_ops = rw_ops;
 	desc->pg_ioflags = io_flags;
 	desc->pg_error = 0;
 	desc->pg_lseg = NULL;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e192ba6..54c84c1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1585,7 +1585,7 @@ pnfs_do_multiple_writes(struct nfs_pageio_descriptor *desc, struct list_head *he
 static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
 {
 	pnfs_put_lseg(hdr->lseg);
-	nfs_writehdr_free(hdr);
+	nfs_rw_header_free(hdr);
 }
 EXPORT_SYMBOL_GPL(pnfs_writehdr_free);
 
@@ -1596,7 +1596,7 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 	struct nfs_pgio_header *hdr;
 	int ret;
 
-	whdr = nfs_writehdr_alloc();
+	whdr = nfs_rw_header_alloc(desc->pg_rw_ops);
 	if (!whdr) {
 		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 		pnfs_put_lseg(desc->pg_lseg);
@@ -1743,7 +1743,7 @@ pnfs_do_multiple_reads(struct nfs_pageio_descriptor *desc, struct list_head *hea
 static void pnfs_readhdr_free(struct nfs_pgio_header *hdr)
 {
 	pnfs_put_lseg(hdr->lseg);
-	nfs_readhdr_free(hdr);
+	nfs_rw_header_free(hdr);
 }
 EXPORT_SYMBOL_GPL(pnfs_readhdr_free);
 
@@ -1754,7 +1754,7 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 	struct nfs_pgio_header *hdr;
 	int ret;
 
-	rhdr = nfs_readhdr_alloc();
+	rhdr = nfs_rw_header_alloc(desc->pg_rw_ops);
 	if (!rhdr) {
 		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 		ret = -ENOMEM;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index ab4c1a5..4cf3577 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -31,33 +31,19 @@
 static const struct nfs_pageio_ops nfs_pageio_read_ops;
 static const struct rpc_call_ops nfs_read_common_ops;
 static const struct nfs_pgio_completion_ops nfs_async_read_completion_ops;
+static const struct nfs_rw_ops nfs_rw_read_ops;
 
 static struct kmem_cache *nfs_rdata_cachep;
 
-struct nfs_rw_header *nfs_readhdr_alloc(void)
+static struct nfs_rw_header *nfs_readhdr_alloc(void)
 {
-	struct nfs_rw_header *rhdr;
-
-	rhdr = kmem_cache_zalloc(nfs_rdata_cachep, GFP_KERNEL);
-	if (rhdr) {
-		struct nfs_pgio_header *hdr = &rhdr->header;
-
-		INIT_LIST_HEAD(&hdr->pages);
-		INIT_LIST_HEAD(&hdr->rpc_list);
-		spin_lock_init(&hdr->lock);
-		atomic_set(&hdr->refcnt, 0);
-	}
-	return rhdr;
+	return kmem_cache_zalloc(nfs_rdata_cachep, GFP_KERNEL);
 }
-EXPORT_SYMBOL_GPL(nfs_readhdr_alloc);
 
-void nfs_readhdr_free(struct nfs_pgio_header *hdr)
+static void nfs_readhdr_free(struct nfs_rw_header *rhdr)
 {
-	struct nfs_rw_header *rhdr = container_of(hdr, struct nfs_rw_header, header);
-
 	kmem_cache_free(nfs_rdata_cachep, rhdr);
 }
-EXPORT_SYMBOL_GPL(nfs_readhdr_free);
 
 static
 int nfs_return_empty_page(struct page *page)
@@ -79,7 +65,8 @@ void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	if (server->pnfs_curr_ld && !force_mds)
 		pg_ops = server->pnfs_curr_ld->pg_read_ops;
 #endif
-	nfs_pageio_init(pgio, inode, pg_ops, compl_ops, server->rsize, 0);
+	nfs_pageio_init(pgio, inode, pg_ops, compl_ops, &nfs_rw_read_ops,
+			server->rsize, 0);
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_init_read);
 
@@ -375,13 +362,13 @@ static int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 	struct nfs_pgio_header *hdr;
 	int ret;
 
-	rhdr = nfs_readhdr_alloc();
+	rhdr = nfs_rw_header_alloc(desc->pg_rw_ops);
 	if (!rhdr) {
 		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 		return -ENOMEM;
 	}
 	hdr = &rhdr->header;
-	nfs_pgheader_init(desc, hdr, nfs_readhdr_free);
+	nfs_pgheader_init(desc, hdr, nfs_rw_header_free);
 	atomic_inc(&hdr->refcnt);
 	ret = nfs_generic_pagein(desc, hdr);
 	if (ret == 0)
@@ -647,3 +634,8 @@ void nfs_destroy_readpagecache(void)
 {
 	kmem_cache_destroy(nfs_rdata_cachep);
 }
+
+static const struct nfs_rw_ops nfs_rw_read_ops = {
+	.rw_alloc_header	= nfs_readhdr_alloc,
+	.rw_free_header		= nfs_readhdr_free,
+};
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0dc4d6a..9c5cde3 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -46,6 +46,7 @@ static const struct rpc_call_ops nfs_write_common_ops;
 static const struct rpc_call_ops nfs_commit_ops;
 static const struct nfs_pgio_completion_ops nfs_async_write_completion_ops;
 static const struct nfs_commit_completion_ops nfs_commit_completion_ops;
+static const struct nfs_rw_ops nfs_rw_write_ops;
 
 static struct kmem_cache *nfs_wdata_cachep;
 static mempool_t *nfs_wdata_mempool;
@@ -70,29 +71,19 @@ void nfs_commit_free(struct nfs_commit_data *p)
 }
 EXPORT_SYMBOL_GPL(nfs_commit_free);
 
-struct nfs_rw_header *nfs_writehdr_alloc(void)
+static struct nfs_rw_header *nfs_writehdr_alloc(void)
 {
 	struct nfs_rw_header *p = mempool_alloc(nfs_wdata_mempool, GFP_NOIO);
 
-	if (p) {
-		struct nfs_pgio_header *hdr = &p->header;
-
+	if (p)
 		memset(p, 0, sizeof(*p));
-		INIT_LIST_HEAD(&hdr->pages);
-		INIT_LIST_HEAD(&hdr->rpc_list);
-		spin_lock_init(&hdr->lock);
-		atomic_set(&hdr->refcnt, 0);
-	}
 	return p;
 }
-EXPORT_SYMBOL_GPL(nfs_writehdr_alloc);
 
-void nfs_writehdr_free(struct nfs_pgio_header *hdr)
+static void nfs_writehdr_free(struct nfs_rw_header *whdr)
 {
-	struct nfs_rw_header *whdr = container_of(hdr, struct nfs_rw_header, header);
 	mempool_free(whdr, nfs_wdata_mempool);
 }
-EXPORT_SYMBOL_GPL(nfs_writehdr_free);
 
 static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
 {
@@ -1210,13 +1201,13 @@ static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 	struct nfs_pgio_header *hdr;
 	int ret;
 
-	whdr = nfs_writehdr_alloc();
+	whdr = nfs_rw_header_alloc(desc->pg_rw_ops);
 	if (!whdr) {
 		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 		return -ENOMEM;
 	}
 	hdr = &whdr->header;
-	nfs_pgheader_init(desc, hdr, nfs_writehdr_free);
+	nfs_pgheader_init(desc, hdr, nfs_rw_header_free);
 	atomic_inc(&hdr->refcnt);
 	ret = nfs_generic_flush(desc, hdr);
 	if (ret == 0)
@@ -1244,7 +1235,8 @@ void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 	if (server->pnfs_curr_ld && !force_mds)
 		pg_ops = server->pnfs_curr_ld->pg_write_ops;
 #endif
-	nfs_pageio_init(pgio, inode, pg_ops, compl_ops, server->wsize, ioflags);
+	nfs_pageio_init(pgio, inode, pg_ops, compl_ops, &nfs_rw_write_ops,
+			server->wsize, ioflags);
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_init_write);
 
@@ -1925,3 +1917,7 @@ void nfs_destroy_writepagecache(void)
 	kmem_cache_destroy(nfs_wdata_cachep);
 }
 
+static const struct nfs_rw_ops nfs_rw_write_ops = {
+	.rw_alloc_header	= nfs_writehdr_alloc,
+	.rw_free_header		= nfs_writehdr_free,
+};
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 92ce578..5948125 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -52,6 +52,11 @@ struct nfs_pageio_ops {
 	int	(*pg_doio)(struct nfs_pageio_descriptor *);
 };
 
+struct nfs_rw_ops {
+	struct nfs_rw_header *(*rw_alloc_header)(void);
+	void (*rw_free_header)(struct nfs_rw_header *);
+};
+
 struct nfs_pageio_descriptor {
 	struct list_head	pg_list;
 	unsigned long		pg_bytes_written;
@@ -63,6 +68,7 @@ struct nfs_pageio_descriptor {
 
 	struct inode		*pg_inode;
 	const struct nfs_pageio_ops *pg_ops;
+	const struct nfs_rw_ops *pg_rw_ops;
 	int 			pg_ioflags;
 	int			pg_error;
 	const struct rpc_call_ops *pg_rpc_callops;
@@ -86,6 +92,7 @@ extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 			     struct inode *inode,
 			     const struct nfs_pageio_ops *pg_ops,
 			     const struct nfs_pgio_completion_ops *compl_ops,
+			     const struct nfs_rw_ops *rw_ops,
 			     size_t bsize,
 			     int how);
 extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 965c2aa..a1b91b6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1269,6 +1269,7 @@ struct nfs_pgio_header {
 	const struct rpc_call_ops *mds_ops;
 	void (*release) (struct nfs_pgio_header *hdr);
 	const struct nfs_pgio_completion_ops *completion_ops;
+	const struct nfs_rw_ops	*rw_ops;
 	struct nfs_direct_req	*dreq;
 	void			*layout_private;
 	spinlock_t		lock;
-- 
1.9.2

