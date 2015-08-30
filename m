Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34736 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbbH3UKm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Aug 2015 16:10:42 -0400
Received: by pabzx8 with SMTP id zx8so115744448pab.1
        for <linux-nfs@vger.kernel.org>; Sun, 30 Aug 2015 13:10:41 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1/flexfiles: Don't mark the entire deviceid as bad for file errors
Date: Sun, 30 Aug 2015 13:10:39 -0700
Message-Id: <1440965439-11746-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the file was fenced and/or has been deleted on the DS, then we want
to retry pNFS after a layoutreturn with error report. If the server
cannot fix the problem, then we rely on it to tell us so in the
response to the LAYOUTGET.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 4ec624cfcf8b..61ccf1122494 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1075,18 +1075,26 @@ static int ff_layout_async_handle_error_v3(struct rpc_task *task,
 	if (task->tk_status >= 0)
 		return 0;
 
-	if (task->tk_status != -EJUKEBOX) {
+	switch (task->tk_status) {
+	/* File access problems. Don't mark the device as unavailable */
+	case -EACCES:
+	case -ESTALE:
+	case -EISDIR:
+	case -EBADHANDLE:
+	case -ELOOP:
+	case -ENOSPC:
+		break;
+	case -EJUKEBOX:
+		nfs_inc_stats(lseg->pls_layout->plh_inode, NFSIOS_DELAY);
+		goto out_retry;
+	default:
 		dprintk("%s DS connection error %d\n", __func__,
 			task->tk_status);
 		nfs4_mark_deviceid_unavailable(devid);
-		if (ff_layout_has_available_ds(lseg))
-			return -NFS4ERR_RESET_TO_PNFS;
-		else
-			return -NFS4ERR_RESET_TO_MDS;
 	}
-
-	if (task->tk_status == -EJUKEBOX)
-		nfs_inc_stats(lseg->pls_layout->plh_inode, NFSIOS_DELAY);
+	/* FIXME: Need to prevent infinite looping here. */
+	return -NFS4ERR_RESET_TO_PNFS;
+out_retry:
 	task->tk_status = 0;
 	rpc_restart_call(task);
 	rpc_delay(task, NFS_JUKEBOX_RETRY_TIME);
-- 
2.4.3

