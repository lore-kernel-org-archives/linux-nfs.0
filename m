Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:25542 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753408Ab0I2LSj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:18:39 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfs: get layout in proper segments
Date: Wed, 29 Sep 2010 13:18:30 +0200
Message-Id: <1285759110-28207-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Base the LAYOUTGET arguments on the actual required byte ranges
rather than asking for the whole file layout.

Add a check in readpage_async_filler that the layout segment
retrieved in pnfs_pageio_init_read still covers the current page
and if not, try getting a new one.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/file.c |    2 +-
 fs/nfs/pnfs.c |   15 ++++++++-------
 fs/nfs/pnfs.h |    4 ++--
 fs/nfs/read.c |   16 +++++++++++++++-
 4 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 1572817..f650ee3 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -390,7 +390,7 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 
 	lseg = pnfs_update_layout(mapping->host,
 				  nfs_file_open_context(file),
-				  IOMODE_RW);
+				  pos, len, IOMODE_RW);
 start:
 	/*
 	 * Prevent starvation issues if someone is doing a consistency
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index cf84f2c..4edab46 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -598,11 +598,9 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 		pnfs_layoutget_release(lo);
 		return NULL;
 	}
-	lgp->args.minlength = NFS4_MAX_UINT64;
+	lgp->args.minlength = PAGE_CACHE_SIZE;
 	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
-	lgp->args.range.iomode = range->iomode;
-	lgp->args.range.offset = 0;
-	lgp->args.range.length = NFS4_MAX_UINT64;
+	lgp->args.range = *range;
 	lgp->args.type = server->pnfs_curr_ld->id;
 	lgp->args.inode = ino;
 	lgp->args.ctx = get_nfs_open_context(ctx);
@@ -937,12 +935,14 @@ EXPORT_SYMBOL_GPL(pnfs_has_layout);
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino,
 		   struct nfs_open_context *ctx,
+		   loff_t pos,
+		   u64 count,
 		   enum pnfs_iomode iomode)
 {
 	struct pnfs_layout_range arg = {
 		.iomode = iomode,
-		.offset = 0,
-		.length = NFS4_MAX_UINT64,
+		.offset = pos,
+		.length = count,
 	};
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct pnfs_layout_hdr *lo;
@@ -1124,7 +1124,8 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	readahead_range(inode, pages, &loff, &count);
 
 	if (count > 0) {
-		pgio->pg_lseg = pnfs_update_layout(inode, ctx, IOMODE_READ);
+		pgio->pg_lseg = pnfs_update_layout(inode, ctx, loff, count,
+						   IOMODE_READ);
 		if (!pgio->pg_lseg)
 			return;
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index ee43489..0aac85f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -195,7 +195,7 @@ struct pnfs_layout_segment *
 pnfs_has_layout(struct pnfs_layout_hdr *lo, struct pnfs_layout_range *range);
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
-		   enum pnfs_iomode access_type);
+		   loff_t pos, u64 count, enum pnfs_iomode access_type);
 int _pnfs_return_layout(struct inode *, struct pnfs_layout_range *,
 			const nfs4_stateid *stateid, /* optional */
 			enum pnfs_layoutreturn_type, bool wait);
@@ -327,7 +327,7 @@ static inline void put_lseg_locked(struct pnfs_layout_segment *lseg)
 
 static inline struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
-		   enum pnfs_iomode access_type)
+		   loff_t pos, u64 count, enum pnfs_iomode access_type)
 {
 	return NULL;
 }
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index be29689..e4b12b5 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -122,12 +122,14 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	LIST_HEAD(one_request);
 	struct nfs_page	*new;
 	unsigned int len;
+	loff_t pgoffs;
 	struct pnfs_layout_segment *lseg;
 
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
-	lseg = pnfs_update_layout(inode, ctx, IOMODE_READ);
+	pgoffs = (loff_t)page->index << PAGE_CACHE_SHIFT;
+	lseg = pnfs_update_layout(inode, ctx, pgoffs, len, IOMODE_READ);
 	new = nfs_create_request(ctx, inode, page, 0, len, lseg);
 	put_lseg(lseg);
 	if (IS_ERR(new)) {
@@ -601,14 +603,26 @@ readpage_async_filler(void *data, struct page *page)
 {
 	struct nfs_readdesc *desc = (struct nfs_readdesc *)data;
 	struct inode *inode = page->mapping->host;
+	struct pnfs_layout_range *range;
 	struct nfs_page *new;
 	unsigned int len;
+	loff_t pgoff;
 	int error;
 
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
 
+	pgoff = (loff_t)page->index << PAGE_CACHE_SHIFT;
+	range = desc->pgio->pg_lseg ? &desc->pgio->pg_lseg->range : NULL;
+	if (!range ||
+	    (range->offset > pgoff + len) ||
+	    (range->offset + range->length < pgoff)) {
+		put_lseg(desc->pgio->pg_lseg);
+		desc->pgio->pg_lseg = pnfs_update_layout(inode, desc->ctx,
+			pgoff, len, IOMODE_READ);
+	}
+
 	new = nfs_create_request(desc->ctx, inode, page, 0, len,
 				 desc->pgio->pg_lseg);
 	if (IS_ERR(new))
-- 
1.7.2.3

