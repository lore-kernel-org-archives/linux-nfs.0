Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f42.google.com ([209.85.210.42]:49461 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933924Ab1KJP0s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 10:26:48 -0500
Received: by mail-pz0-f42.google.com with SMTP id 36so1483528pzk.1
        for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2011 07:26:48 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, bhalevy@tonian.com,
        Peng Tao <peng_tao@emc.com>
Subject: [PATCH-v2 4/7] pnfsblock: set read/write tk_status to pnfs_error
Date: Thu, 10 Nov 2011 07:25:25 -0800
Message-Id: <1320938728-3715-5-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1320938728-3715-1-git-send-email-bergwolf@gmail.com>
References: <1320938728-3715-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To pass the IO status to upper layer.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index e84bd9e..8ad8014 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -216,6 +216,7 @@ bl_end_par_io_read(void *data)
 {
 	struct nfs_read_data *rdata = data;
 
+	rdata->task.tk_status = rdata->pnfs_error;
 	INIT_WORK(&rdata->task.u.tk_work, bl_read_cleanup);
 	schedule_work(&rdata->task.u.tk_work);
 }
@@ -405,7 +406,7 @@ static void bl_end_par_io_write(void *data)
 {
 	struct nfs_write_data *wdata = data;
 
-	wdata->task.tk_status = 0;
+	wdata->task.tk_status = wdata->pnfs_error;
 	wdata->verf.committed = NFS_FILE_SYNC;
 	INIT_WORK(&wdata->task.u.tk_work, bl_write_cleanup);
 	schedule_work(&wdata->task.u.tk_work);
-- 
1.7.1.262.g5ef3d

