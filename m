From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/3] SQUASHME: pnfs-submit: use nfs_page_array_len in pnfs_try_to_read_data
Date: Tue, 20 Jul 2010 08:57:44 +0300
Message-ID: <1279605464-7383-1-git-send-email-bhalevy@panasas.com>
References: <4C453A50.7070009@panasas.com>
Cc: andros@netapp.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:7016 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754623Ab0GTF5q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 01:57:46 -0400
In-Reply-To: <4C453A50.7070009@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No sense in open coding the logic here.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   13 ++-----------
 1 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6ab1938..0f255f5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1296,7 +1296,6 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 	struct inode *inode = rdata->inode;
 	struct nfs_server *nfss = NFS_SERVER(inode);
 	struct pnfs_layout_segment *lseg = rdata->req->wb_lseg;
-	int numpages, pgcount, temp;
 	enum pnfs_try_status trypnfs;
 
 	rdata->pdata.call_ops = call_ops;
@@ -1306,17 +1305,9 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 
 	get_lseg(lseg);
 
-	/* Determine number of pages. */
-	pgcount = rdata->args.pgbase + rdata->args.count;
-	temp = pgcount % PAGE_CACHE_SIZE;
-	numpages = pgcount / PAGE_CACHE_SIZE;
-	if (temp != 0)
-		numpages++;
-
-	dprintk("%s: Calling layout driver read with %d pages\n",
-		__func__, numpages);
 	rdata->pdata.lseg = lseg;
-	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->read_pagelist(rdata, numpages);
+	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->read_pagelist(rdata,
+		nfs_page_array_len(rdata->args.pgbase, rdata->args.count));
 	if (trypnfs == PNFS_NOT_ATTEMPTED) {
 		rdata->pdata.lseg = NULL;
 		put_lseg(lseg);
-- 
1.7.1.1

