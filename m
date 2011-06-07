Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52189 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755799Ab1FGReZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:34:25 -0400
Date: Tue, 7 Jun 2011 13:34:23 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 71/88] SQUASHME: pnfsblock: no callback ops
Message-ID: <aa0b9edf75dad396fc39701fec16b99a63ad8f51.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 071e7ef..5dbd9c6 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -44,7 +44,6 @@ MODULE_AUTHOR("Andy Adamson <andros@citi.umich.edu>");
 MODULE_DESCRIPTION("The NFSv4.1 pNFS Block layout driver");
 
 /* Callback operations to the pNFS client */
-static struct pnfs_client_operations *pnfs_block_callback_ops;
 
 static void print_page(struct page *page)
 {
@@ -199,7 +198,7 @@ static void bl_read_cleanup(struct work_struct *work)
 	dprintk("%s enter\n", __func__);
 	task = container_of(work, struct rpc_task, u.tk_work);
 	rdata = container_of(task, struct nfs_read_data, task);
-	pnfs_block_callback_ops->nfs_readlist_complete(rdata);
+	pnfs_read_done(rdata);
 }
 
 static void
@@ -411,7 +410,7 @@ static void bl_write_cleanup(struct work_struct *work)
 		mark_extents_written(BLK_LSEG2EXT(wdata->pdata.lseg),
 				     wdata->args.offset, wdata->args.count);
 	}
-	pnfs_block_callback_ops->nfs_writelist_complete(wdata);
+	pnfs_writeback_done(wdata);
 }
 
 /* Called when last of bios associated with a bl_write_pagelist call finishes */
@@ -733,7 +732,7 @@ nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
 	dev->mincount = 0;
 
 	dprintk("%s: dev_id: %s\n", __func__, dev->dev_id.data);
-	rc = pnfs_block_callback_ops->nfs_getdeviceinfo(server, dev);
+	rc = nfs4_proc_getdeviceinfo(server, dev);
 	dprintk("%s getdevice info returns %d\n", __func__, rc);
 	if (rc)
 		goto out_free;
@@ -783,8 +782,7 @@ bl_initialize_mountpoint(struct nfs_server *server, const struct nfs_fh *fh)
 		goto out_error;
 	dlist->eof = 0;
 	while (!dlist->eof) {
-		status = pnfs_block_callback_ops->nfs_getdevicelist(
-							server, fh, dlist);
+		status = nfs4_proc_getdevicelist(server, fh, dlist);
 		if (status)
 			goto out_error;
 		dprintk("%s GETDEVICELIST numdevs=%i, eof=%i\n",
@@ -1140,11 +1138,14 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 
 static int __init nfs4blocklayout_init(void)
 {
+	int ret;
+
 	dprintk("%s: NFSv4 Block Layout Driver Registering...\n", __func__);
 
-	pnfs_block_callback_ops = pnfs_register_layoutdriver(&blocklayout_type);
-	bl_pipe_init();
-	return 0;
+	ret = pnfs_register_layoutdriver(&blocklayout_type);
+	if (!ret)
+		bl_pipe_init();
+	return ret;
 }
 
 static void __exit nfs4blocklayout_exit(void)
-- 
1.7.4.1

