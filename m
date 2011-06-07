Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51817 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754744Ab1FGRdb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:33:31 -0400
Date: Tue, 7 Jun 2011 13:33:29 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 63/88] SQUASHME: pnfs-block: use new read_pagelist api
Message-ID: <a33e8b988b8ba352e3f4234efd4d7409c4f1062c.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index e2ee90a..80d25768 100644
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
1.7.4.1

