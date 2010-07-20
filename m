From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/3] SQUASHME: pnfs-block: use new write_pagelist api
Date: Tue, 20 Jul 2010 08:58:19 +0300
Message-ID: <1279605499-7509-1-git-send-email-bhalevy@panasas.com>
References: <4C453A50.7070009@panasas.com>
Cc: andros@netapp.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:17800 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754693Ab0GTF6V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 01:58:21 -0400
In-Reply-To: <4C453A50.7070009@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 80d2576..bfcef54 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -428,21 +428,19 @@ bl_end_par_io_write(void *data)
 }
 
 static enum pnfs_try_status
-bl_write_pagelist(struct pnfs_layout_type *lo,
-		struct page **pages,
-		unsigned int pgbase,
-		unsigned nr_pages,
-		loff_t offset,
-		size_t count,
-		int sync,
-		struct nfs_write_data *wdata)
+bl_write_pagelist(struct nfs_write_data *wdata,
+		  unsigned nr_pages,
+		  int sync)
 {
 	int i;
 	struct bio *bio = NULL;
 	struct pnfs_block_extent *be = NULL;
 	sector_t isect, extent_length = 0;
 	struct parallel_io *par;
-	int pg_index = pgbase >> PAGE_CACHE_SHIFT;
+	loff_t offset = wdata->args.offset;
+	size_t count = wdata->args.count;
+	struct page **pages = wdata->args.pages;
+	int pg_index = wdata->args.pgbase >> PAGE_CACHE_SHIFT;
 
 	dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
 	if (!wdata->req->wb_lseg) {
-- 
1.7.1.1

