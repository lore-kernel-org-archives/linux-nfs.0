Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51253 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755437Ab1FGRby (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:31:54 -0400
Date: Tue, 7 Jun 2011 13:31:52 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 48/88] SQUASHME: pnfs-block: fix compile breakage
Message-ID: <2cbda7e91a7b1e248465dade22369480cb716c61.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@fieldses.org>

fs/nfs/blocklayout/built-in.o: In function `bl_rpc_do_nothing':
/home/bfields/local/build-2.6/fs/nfs/blocklayout/blocklayout.c:219: multiple definition of `pnfs_callback_ops'
fs/nfs/nfslayoutdriver.o:/home/bfields/local/build-2.6/fs/nfs/nfs4filelayout.c:160: first defined here

The variable in the block case never seems to be used outside the one
file; so change the name and declare it static.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 65cf104..768d8fa 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -44,7 +44,7 @@ MODULE_AUTHOR("Andy Adamson <andros@citi.umich.edu>");
 MODULE_DESCRIPTION("The NFSv4.1 pNFS Block layout driver");
 
 /* Callback operations to the pNFS client */
-struct pnfs_client_operations *pnfs_callback_ops;
+static struct pnfs_client_operations *pnfs_block_callback_ops;
 
 static void print_page(struct page *page)
 {
@@ -200,7 +200,7 @@ static void bl_read_cleanup(struct work_struct *work)
 	dprintk("%s enter\n", __func__);
 	task = container_of(work, struct rpc_task, u.tk_work);
 	rdata = container_of(task, struct nfs_read_data, task);
-	pnfs_callback_ops->nfs_readlist_complete(rdata);
+	pnfs_block_callback_ops->nfs_readlist_complete(rdata);
 }
 
 static void
@@ -414,7 +414,7 @@ static void bl_write_cleanup(struct work_struct *work)
 		mark_extents_written(BLK_LSEG2EXT(wdata->pdata.lseg),
 				     wdata->args.offset, wdata->args.count);
 	}
-	pnfs_callback_ops->nfs_writelist_complete(wdata);
+	pnfs_block_callback_ops->nfs_writelist_complete(wdata);
 }
 
 /* Called when last of bios associated with a bl_write_pagelist call finishes */
@@ -739,7 +739,7 @@ nfs4_blk_get_deviceinfo(struct super_block *sb, struct nfs_fh *fh,
 	dev->pglen = PAGE_SIZE * max_pages;
 	dev->mincount = 0;
 
-	rc = pnfs_callback_ops->nfs_getdeviceinfo(sb, dev);
+	rc = pnfs_block_callback_ops->nfs_getdeviceinfo(sb, dev);
 	dprintk("%s getdevice info returns %d\n", __func__, rc);
 	if (rc)
 		goto out_free;
@@ -799,7 +799,7 @@ bl_initialize_mountpoint(struct super_block *sb, struct nfs_fh *fh)
 		goto out_error;
 	dlist->eof = 0;
 	while (!dlist->eof) {
-		status = pnfs_callback_ops->nfs_getdevicelist(sb, fh, dlist);
+		status = pnfs_block_callback_ops->nfs_getdevicelist(sb, fh, dlist);
 		if (status)
 			goto out_error;
 		dprintk("%s GETDEVICELIST numdevs=%i, eof=%i\n",
@@ -1186,7 +1186,7 @@ static int __init nfs4blocklayout_init(void)
 {
 	dprintk("%s: NFSv4 Block Layout Driver Registering...\n", __func__);
 
-	pnfs_callback_ops = pnfs_register_layoutdriver(&blocklayout_type);
+	pnfs_block_callback_ops = pnfs_register_layoutdriver(&blocklayout_type);
 	return 0;
 }
 
-- 
1.7.4.1

