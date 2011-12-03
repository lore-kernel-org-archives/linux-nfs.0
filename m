Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f46.google.com ([209.85.216.46]:65230 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754758Ab1K2QEW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 11:04:22 -0500
Received: by mail-qw0-f46.google.com with SMTP id c14so2131121qad.19
        for <linux-nfs@vger.kernel.org>; Tue, 29 Nov 2011 08:04:22 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Peng Tao <peng_tao@emc.com>
Subject: [PATCH 4/9] pnfsblock: set read/write tk_status to pnfs_error
Date: Fri,  2 Dec 2011 20:46:18 -0800
Message-Id: <1322887583-2719-5-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1322887583-2719-1-git-send-email-bergwolf@gmail.com>
References: <1322887583-2719-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To pass the IO status to upper layer.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index c83ad70..883bb27 100644
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

