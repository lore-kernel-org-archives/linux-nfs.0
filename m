From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 12/26] pnfs_submit: stash and refcount lseg in read path
Date: Fri, 11 Jun 2010 03:31:39 -0400
Message-ID: <1276241513-17942-13-git-send-email-iisaman@netapp.com>
References: <1276241513-17942-1-git-send-email-iisaman@netapp.com>
 <1276241513-17942-2-git-send-email-iisaman@netapp.com>
 <1276241513-17942-3-git-send-email-iisaman@netapp.com>
 <1276241513-17942-4-git-send-email-iisaman@netapp.com>
 <1276241513-17942-5-git-send-email-iisaman@netapp.com>
 <1276241513-17942-6-git-send-email-iisaman@netapp.com>
 <1276241513-17942-7-git-send-email-iisaman@netapp.com>
 <1276241513-17942-8-git-send-email-iisaman@netapp.com>
 <1276241513-17942-9-git-send-email-iisaman@netapp.com>
 <1276241513-17942-10-git-send-email-iisaman@netapp.com>
 <1276241513-17942-11-git-send-email-iisaman@netapp.com>
 <1276241513-17942-12-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64287 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755588Ab0FKHcV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:32:21 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7W3u5024376
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:32:19 -0700 (PDT)
In-Reply-To: <1276241513-17942-12-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Note we are not using it yet, but refcounting should be accurate.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pagelist.c        |   12 ++++++++++--
 fs/nfs/pnfs.c            |    4 +++-
 fs/nfs/read.c            |    9 +++++++--
 fs/nfs/write.c           |    2 +-
 include/linux/nfs_page.h |    5 ++++-
 5 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 8314915..b9d3baf 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -20,6 +20,7 @@
 #include <linux/nfs_mount.h>
 
 #include "internal.h"
+#include "pnfs.h"
 
 static struct kmem_cache *nfs_page_cachep;
 
@@ -56,7 +57,8 @@ nfs_page_free(struct nfs_page *p)
 struct nfs_page *
 nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 		   struct page *page,
-		   unsigned int offset, unsigned int count)
+		   unsigned int offset, unsigned int count,
+		   struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page		*req;
 
@@ -80,6 +82,9 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	req->wb_bytes   = count;
 	req->wb_context = get_nfs_open_context(ctx);
 	kref_init(&req->wb_kref);
+	req->wb_lseg    = lseg;
+	if (lseg)
+		get_lseg(lseg);
 	return req;
 }
 
@@ -150,9 +155,12 @@ void nfs_clear_request(struct nfs_page *req)
 		put_nfs_open_context(ctx);
 		req->wb_context = NULL;
 	}
+	if (req->wb_lseg != NULL) {
+		put_lseg(req->wb_lseg);
+		req->wb_lseg = NULL;
+	}
 }
 
-
 /**
  * nfs_release_request - Release the count on an NFS read/write request
  * @req: request to release
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 52dbcbe..c1eb02f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1369,6 +1369,7 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	pgio->pg_iswrite = 0;
 	pgio->pg_boundary = 0;
 	pgio->pg_test = NULL;
+	pgio->pg_lseg = NULL;
 
 	if (!pnfs_enabled_sb(nfss))
 		return;
@@ -1378,7 +1379,8 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 
 	if (count > 0) {
 		status = _pnfs_update_layout(inode, ctx, count,
-						loff, IOMODE_READ, NULL);
+					    loff, IOMODE_READ,
+					    &pgio->pg_lseg);
 		dprintk("%s virt update returned %d\n", __func__, status);
 		if (status != 0)
 			return;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 28c49f1..68b4ca8 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -121,11 +121,14 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	LIST_HEAD(one_request);
 	struct nfs_page	*new;
 	unsigned int len;
+	struct pnfs_layout_segment *lseg;
 
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
-	new = nfs_create_request(ctx, inode, page, 0, len);
+	pnfs_update_layout(inode, ctx, NFS4_MAX_UINT64, 0, IOMODE_READ, &lseg);
+	new = nfs_create_request(ctx, inode, page, 0, len, lseg);
+	put_lseg(lseg);
 	if (IS_ERR(new)) {
 		unlock_page(page);
 		return PTR_ERR(new);
@@ -606,7 +609,8 @@ readpage_async_filler(void *data, struct page *page)
 	if (len == 0)
 		return nfs_return_empty_page(page);
 
-	new = nfs_create_request(desc->ctx, inode, page, 0, len);
+	new = nfs_create_request(desc->ctx, inode, page, 0, len,
+				 desc->pgio->pg_lseg);
 	if (IS_ERR(new))
 		goto out_error;
 
@@ -673,6 +677,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);
 
 	nfs_pageio_complete(&pgio);
+	put_lseg(pgio.pg_lseg);
 	npages = (pgio.pg_bytes_written + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	nfs_add_stats(inode, NFSIOS_READPAGES, npages);
 read_complete:
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index fb3ceca..30f4c09 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -653,7 +653,7 @@ static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
 	req = nfs_try_to_update_request(inode, page, offset, bytes);
 	if (req != NULL)
 		goto out;
-	req = nfs_create_request(ctx, inode, page, offset, bytes);
+	req = nfs_create_request(ctx, inode, page, offset, bytes, NULL);
 	if (IS_ERR(req))
 		goto out;
 	error = nfs_inode_add_request(inode, req);
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index d04ebb2..18a455c 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -48,6 +48,7 @@ struct nfs_page {
 	struct kref		wb_kref;	/* reference count */
 	unsigned long		wb_flags;
 	struct nfs_writeverf	wb_verf;	/* Commit cookie */
+	struct pnfs_layout_segment *wb_lseg;	/* Pnfs layout info */
 };
 
 struct nfs_pageio_descriptor {
@@ -61,6 +62,7 @@ struct nfs_pageio_descriptor {
 	int			(*pg_doio)(struct inode *, struct list_head *, unsigned int, size_t, int);
 	int 			pg_ioflags;
 	int			pg_error;
+	struct pnfs_layout_segment *pg_lseg;
 #ifdef CONFIG_NFS_V4_1
 	int			pg_iswrite;
 	int			pg_boundary;
@@ -74,7 +76,8 @@ extern	struct nfs_page *nfs_create_request(struct nfs_open_context *ctx,
 					    struct inode *inode,
 					    struct page *page,
 					    unsigned int offset,
-					    unsigned int count);
+					    unsigned int count,
+					    struct pnfs_layout_segment *lseg);
 extern	void nfs_clear_request(struct nfs_page *req);
 extern	void nfs_release_request(struct nfs_page *req);
 
-- 
1.6.6.1

