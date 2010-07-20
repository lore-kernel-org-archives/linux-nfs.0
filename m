From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/3] SQUASHME: pnfs-block: use new read_pagelist api
Date: Tue, 20 Jul 2010 08:58:11 +0300
Message-ID: <1279605491-7453-1-git-send-email-bhalevy@panasas.com>
References: <4C453A50.7070009@panasas.com>
Cc: andros@netapp.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:58306 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754632Ab0GTF6O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 01:58:14 -0400
In-Reply-To: <4C453A50.7070009@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index e2ee90a..80d2576 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -220,20 +220,18 @@ static void bl_rpc_do_nothing(struct rpc_task *task, void *calldata)
 }
 
 static enum pnfs_try_status
-bl_read_pagelist(struct pnfs_layout_type *lo,
-		struct page **pages,
-		unsigned int pgbase,
-		unsigned nr_pages,
-		loff_t f_offset,
-		size_t count,
-		struct nfs_read_data *rdata)
+bl_read_pagelist(struct nfs_read_data *rdata,
+		 unsigned nr_pages)
 {
 	int i, hole;
 	struct bio *bio = NULL;
 	struct pnfs_block_extent *be = NULL, *cow_read = NULL;
 	sector_t isect, extent_length = 0;
 	struct parallel_io *par;
-	int pg_index = pgbase >> PAGE_CACHE_SHIFT;
+	loff_t f_offset = rdata->args.offset;
+	size_t count = rdata->args.count;
+	struct page **pages = rdata->args.pages;
+	int pg_index = rdata->args.pgbase >> PAGE_CACHE_SHIFT;
 
 	dprintk("%s enter nr_pages %u offset %lld count %Zd\n", __func__,
 	       nr_pages, f_offset, count);
-- 
1.7.1.1

