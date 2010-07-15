From: andros@netapp.com
Subject: [PATCH 4/7] SQUASHME pnfs-submit consolidate write_pagelist parameters
Date: Thu, 15 Jul 2010 12:13:51 -0400
Message-ID: <1279210434-2772-5-git-send-email-andros@netapp.com>
References: <1279210434-2772-1-git-send-email-andros@netapp.com>
 <1279210434-2772-2-git-send-email-andros@netapp.com>
 <1279210434-2772-3-git-send-email-andros@netapp.com>
 <1279210434-2772-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8172 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933330Ab0GOQNq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 12:13:46 -0400
In-Reply-To: <1279210434-2772-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Remove the numpages calculation which is not used by the file layout driver.
Layout drivers that need the number of pages can call nfs_page_array_len in
their write_pagelist operation.

NOTE: API change.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c             |   24 +++---------------------
 include/linux/nfs4_pnfs.h |    5 +----
 2 files changed, 4 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 576946b..51bd66f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1271,39 +1271,21 @@ enum pnfs_try_status
 pnfs_try_to_write_data(struct nfs_write_data *wdata,
 			const struct rpc_call_ops *call_ops, int how)
 {
-	struct nfs_writeargs *args = &wdata->args;
 	struct inode *inode = wdata->inode;
 	enum pnfs_try_status trypnfs;
 	struct nfs_server *nfss = NFS_SERVER(inode);
-	struct nfs_inode *nfsi = NFS_I(inode);
 	struct pnfs_layout_segment *lseg = wdata->req->wb_lseg;
-	int numpages;
 
 	wdata->pdata.call_ops = call_ops;
 	wdata->pdata.how = how;
 
-	dprintk("%s: Writing ino:%lu %u@%llu\n", __func__,
-		inode->i_ino, args->count, args->offset);
+	dprintk("%s: Writing ino:%lu %u@%llu (how %d)\n", __func__,
+		inode->i_ino, wdata->args.count, wdata->args.offset, how);
 
 	get_lseg(lseg);
 
-	/* Determine number of pages
-	 */
-	numpages = nfs_page_array_len(args->pgbase, args->count);
-
-	dprintk("%s: Calling layout driver (how %d) write with %d pages\n",
-		__func__, how, numpages);
-
 	wdata->pdata.lseg = lseg;
-	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->write_pagelist(
-							nfsi->layout,
-							args->pages,
-							args->pgbase,
-							numpages,
-							(loff_t)args->offset,
-							args->count,
-							how,
-							wdata);
+	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->write_pagelist(wdata, how);
 
 	if (trypnfs == PNFS_NOT_ATTEMPTED) {
 		wdata->pdata.lseg = NULL;
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index b379225..13f71ad 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -130,10 +130,7 @@ struct layoutdriver_io_operations {
 	enum pnfs_try_status
 	(*read_pagelist) (struct nfs_read_data *nfs_data, unsigned nr_pages);
 	enum pnfs_try_status
-	(*write_pagelist) (struct pnfs_layout_type *layoutid,
-			   struct page **pages, unsigned int pgbase,
-			   unsigned nr_pages, loff_t offset, size_t count,
-			   int sync, struct nfs_write_data *nfs_data);
+	(*write_pagelist) (struct nfs_write_data *nfs_data, int how);
 
 	/* Consistency ops */
 	/* 2 problems:
-- 
1.6.6

