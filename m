Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:33628 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933924Ab1KJP0z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 10:26:55 -0500
Received: by eye27 with SMTP id 27so2496648eye.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2011 07:26:53 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, bhalevy@tonian.com
Subject: [PATCH-v2 5/7] pnfsblock: remove rpc_call_ops from struct parallel_io
Date: Thu, 10 Nov 2011 07:25:26 -0800
Message-Id: <1320938728-3715-6-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1320938728-3715-1-git-send-email-bergwolf@gmail.com>
References: <1320938728-3715-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

block layout can just make use of generic read/write_done.

Signed-off-by: Peng Tao <bergwolf@gmail.com>
---
 fs/nfs/blocklayout/blocklayout.c |   13 -------------
 1 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 8ad8014..3eaea2b 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -90,7 +90,6 @@ static int is_writable(struct pnfs_block_extent *be, sector_t isect)
  */
 struct parallel_io {
 	struct kref refcnt;
-	struct rpc_call_ops call_ops;
 	void (*pnfs_callback) (void *data);
 	void *data;
 };
@@ -221,14 +220,6 @@ bl_end_par_io_read(void *data)
 	schedule_work(&rdata->task.u.tk_work);
 }
 
-/* We don't want normal .rpc_call_done callback used, so we replace it
- * with this stub.
- */
-static void bl_rpc_do_nothing(struct rpc_task *task, void *calldata)
-{
-	return;
-}
-
 static enum pnfs_try_status
 bl_read_pagelist(struct nfs_read_data *rdata)
 {
@@ -248,8 +239,6 @@ bl_read_pagelist(struct nfs_read_data *rdata)
 	par = alloc_parallel(rdata);
 	if (!par)
 		goto use_mds;
-	par->call_ops = *rdata->mds_ops;
-	par->call_ops.rpc_call_done = bl_rpc_do_nothing;
 	par->pnfs_callback = bl_end_par_io_read;
 	/* At this point, we can no longer jump to use_mds */
 
@@ -559,8 +548,6 @@ bl_write_pagelist(struct nfs_write_data *wdata, int sync)
 	par = alloc_parallel(wdata);
 	if (!par)
 		return PNFS_NOT_ATTEMPTED;
-	par->call_ops = *wdata->mds_ops;
-	par->call_ops.rpc_call_done = bl_rpc_do_nothing;
 	par->pnfs_callback = bl_end_par_io_write;
 	/* At this point, have to be more careful with error handling */
 
-- 
1.7.1.262.g5ef3d

