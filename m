Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51858 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814Ab1FGRdi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:33:38 -0400
Date: Tue, 7 Jun 2011 13:33:35 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 64/88] SQUASHME: pnfs-block: use new write_pagelist api
Message-ID: <c3f8074af65b0b14d9a90ce1bdac449151571473.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 80d25768..bfcef54 100644
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
1.7.4.1

