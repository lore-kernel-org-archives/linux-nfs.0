Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og110.obsmtp.com ([64.18.0.20]:34734 "HELO
	exprod5og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754760Ab0J0SYQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 14:24:16 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] pnfs: mark page with error in readpage_async_filler when crossing lsegs
Date: Wed, 27 Oct 2010 20:24:13 +0200
Message-Id: <1288203853-26883-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CC86D96.8020803@panasas.com>
References: <4CC86D96.8020803@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@compute-1-5.palab.panasas.com>

Signed-off-by: Benny Halevy <bhalevy@compute-1-5.palab.panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/read.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index e1e1a65..1df536a 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -605,24 +605,24 @@ readpage_async_filler(void *data, struct page *page)
 {
 	struct nfs_readdesc *desc = (struct nfs_readdesc *)data;
 	struct inode *inode = page->mapping->host;
-	struct pnfs_layout_range *range;
 	struct nfs_page *new;
 	unsigned int len;
-	loff_t pgoff;
 	int error;
 
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
 
-	pgoff = (loff_t)page->index << PAGE_CACHE_SHIFT;
-	range = desc->pgio->pg_lseg ? &desc->pgio->pg_lseg->range : NULL;
-	if (!range ||
-	    (range->offset > pgoff + len) ||
-	    (range->offset + range->length < pgoff)) {
-		put_lseg(desc->pgio->pg_lseg);
-		desc->pgio->pg_lseg = pnfs_update_layout(inode, desc->ctx,
-			pgoff, len, IOMODE_READ);
+	if (desc->pgio->pg_lseg) {
+		loff_t pgoff = (loff_t)page->index << PAGE_CACHE_SHIFT;
+		struct pnfs_layout_range *range = &desc->pgio->pg_lseg->range;
+
+		/* retry later with the right lseg? */
+		if (range->offset > pgoff + len ||
+		    range->offset + range->length < pgoff) {
+			new = ERR_PTR(-EAGAIN);
+			goto out_error;
+		}
 	}
 
 	new = nfs_create_request(desc->ctx, inode, page, 0, len,
-- 
1.7.2.3

