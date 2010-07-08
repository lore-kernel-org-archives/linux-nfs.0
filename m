From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 2/4] pnfs-submit: Remove readahead_range
Date: Thu,  8 Jul 2010 15:25:20 -0400
Message-ID: <1278617122-24164-3-git-send-email-iisaman@netapp.com>
References: <1278617122-24164-1-git-send-email-iisaman@netapp.com>
 <1278617122-24164-2-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22871 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758512Ab0GHTZ1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jul 2010 15:25:27 -0400
Received: from localhost.localdomain (khang-lxp.hq.netapp.com [10.58.60.105] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o68JPOdM010802
	for <linux-nfs@vger.kernel.org>; Thu, 8 Jul 2010 12:25:26 -0700 (PDT)
In-Reply-To: <1278617122-24164-2-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is not needed if we always use full file layout.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   47 +++++++----------------------------------------
 1 files changed, 7 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5b0c4ec..a3b934d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1196,32 +1196,6 @@ out:
 }
 
 void
-readahead_range(struct inode *inode, struct list_head *pages, loff_t *offset,
-		size_t *count)
-{
-	struct page *first, *last;
-	loff_t foff, i_size = i_size_read(inode);
-	pgoff_t end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
-	size_t range;
-
-
-	first = list_entry((pages)->prev, struct page, lru);
-	last = list_entry((pages)->next, struct page, lru);
-
-	foff = (loff_t)first->index << PAGE_CACHE_SHIFT;
-
-	range = (last->index - first->index) * PAGE_CACHE_SIZE;
-	if (last->index == end_index)
-		range += ((i_size - 1) & ~PAGE_CACHE_MASK) + 1;
-	else
-		range += PAGE_CACHE_SIZE;
-	dprintk("%s foff %lu, range %Zu\n", __func__, (unsigned long)foff,
-		range);
-	*offset = foff;
-	*count = range;
-}
-
-void
 pnfs_set_pg_test(struct inode *inode, struct nfs_pageio_descriptor *pgio)
 {
 	struct pnfs_layout_type *laytype;
@@ -1280,8 +1254,6 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 		  struct list_head *pages)
 {
 	struct nfs_server *nfss = NFS_SERVER(inode);
-	size_t count = 0;
-	loff_t loff;
 
 	pgio->pg_iswrite = 0;
 	pgio->pg_boundary = 0;
@@ -1291,19 +1263,14 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	if (!pnfs_enabled_sb(nfss))
 		return;
 
-	/* Calculate the total read-ahead count */
-	readahead_range(inode, pages, &loff, &count);
-
-	if (count > 0) {
-		_pnfs_update_layout(inode, ctx, loff, count, IOMODE_READ,
-				    &pgio->pg_lseg);
-		if (!pgio->pg_lseg)
-			return;
+	_pnfs_update_layout(inode, ctx, 0, NFS4_MAX_UINT64, IOMODE_READ,
+			    &pgio->pg_lseg);
+	if (!pgio->pg_lseg)
+		return;
 
-		pgio->pg_boundary = pnfs_getboundary(inode);
-		if (pgio->pg_boundary)
-			pnfs_set_pg_test(inode, pgio);
-	}
+	pgio->pg_boundary = pnfs_getboundary(inode);
+	if (pgio->pg_boundary)
+		pnfs_set_pg_test(inode, pgio);
 }
 
 void
-- 
1.6.6.1

