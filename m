Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:46678 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932153Ab2AIQEP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 11:04:15 -0500
Received: by obcwo16 with SMTP id wo16so4262986obc.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jan 2012 08:04:14 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, mdw@umich.edu, honey@citi.umich.edu,
        Peng Tao <peng_tao@emc.com>, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 4/9] pnfsblock: set read/write tk_status to pnfs_error
Date: Tue, 10 Jan 2012 00:02:14 +0800
Message-Id: <1326124939-2152-5-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1326124939-2152-1-git-send-email-bergwolf@gmail.com>
References: <1326124939-2152-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To pass the IO status to upper layer.

Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
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

