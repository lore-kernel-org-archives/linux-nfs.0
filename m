From: andros@netapp.com
Subject: [PATCH 2/7] SQUASHME pnfs-submit consolidate read_pagelist parameters
Date: Thu, 15 Jul 2010 12:13:49 -0400
Message-ID: <1279210434-2772-3-git-send-email-andros@netapp.com>
References: <1279210434-2772-1-git-send-email-andros@netapp.com>
 <1279210434-2772-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8172 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933624Ab0GOQNp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 12:13:45 -0400
In-Reply-To: <1279210434-2772-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

NOTE: API change.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c             |   17 ++++-------------
 include/linux/nfs4_pnfs.h |    5 +----
 2 files changed, 5 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 56c3af4..576946b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1325,23 +1325,21 @@ enum pnfs_try_status
 pnfs_try_to_read_data(struct nfs_read_data *rdata,
 		       const struct rpc_call_ops *call_ops)
 {
-	struct nfs_readargs *args = &rdata->args;
 	struct inode *inode = rdata->inode;
-	int numpages, pgcount, temp;
 	struct nfs_server *nfss = NFS_SERVER(inode);
-	struct nfs_inode *nfsi = NFS_I(inode);
 	struct pnfs_layout_segment *lseg = rdata->req->wb_lseg;
+	int numpages, pgcount, temp;
 	enum pnfs_try_status trypnfs;
 
 	rdata->pdata.call_ops = call_ops;
 
 	dprintk("%s: Reading ino:%lu %u@%llu\n",
-		__func__, inode->i_ino, args->count, args->offset);
+		__func__, inode->i_ino, rdata->args.count, rdata->args.offset);
 
 	get_lseg(lseg);
 
 	/* Determine number of pages. */
-	pgcount = args->pgbase + args->count;
+	pgcount = rdata->args.pgbase + rdata->args.count;
 	temp = pgcount % PAGE_CACHE_SIZE;
 	numpages = pgcount / PAGE_CACHE_SIZE;
 	if (temp != 0)
@@ -1350,14 +1348,7 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 	dprintk("%s: Calling layout driver read with %d pages\n",
 		__func__, numpages);
 	rdata->pdata.lseg = lseg;
-	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->read_pagelist(
-							nfsi->layout,
-							args->pages,
-							args->pgbase,
-							numpages,
-							(loff_t)args->offset,
-							args->count,
-							rdata);
+	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->read_pagelist(rdata, numpages);
 	if (trypnfs == PNFS_NOT_ATTEMPTED) {
 		rdata->pdata.lseg = NULL;
 		put_lseg(lseg);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index fe18143..b379225 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -128,10 +128,7 @@ struct layoutdriver_io_operations {
 	 * MUST be called.
 	 */
 	enum pnfs_try_status
-	(*read_pagelist) (struct pnfs_layout_type *layoutid,
-			  struct page **pages, unsigned int pgbase,
-			  unsigned nr_pages, loff_t offset, size_t count,
-			  struct nfs_read_data *nfs_data);
+	(*read_pagelist) (struct nfs_read_data *nfs_data, unsigned nr_pages);
 	enum pnfs_try_status
 	(*write_pagelist) (struct pnfs_layout_type *layoutid,
 			   struct page **pages, unsigned int pgbase,
-- 
1.6.6

