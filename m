Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:46678 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932177Ab2AIQE0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 11:04:26 -0500
Received: by mail-tul01m020-f174.google.com with SMTP id wo16so4262986obc.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jan 2012 08:04:26 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, mdw@umich.edu, honey@citi.umich.edu,
        Peng Tao <bergwolf@emc.com>, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 5/9] pnfsblock: remove rpc_call_ops from struct parallel_io
Date: Tue, 10 Jan 2012 00:02:15 +0800
Message-Id: <1326124939-2152-6-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1326124939-2152-1-git-send-email-bergwolf@gmail.com>
References: <1326124939-2152-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

block layout can just make use of generic read/write_done.

Signed-off-by: Peng Tao <bergwolf@emc.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/blocklayout/blocklayout.c |   13 -------------
 1 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 883bb27..7fc69c9 100644
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

