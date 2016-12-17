Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:32815 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751664AbcLQU2O (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Dec 2016 15:28:14 -0500
Received: by mail-it0-f66.google.com with SMTP id c20so6378175itb.0
        for <linux-nfs@vger.kernel.org>; Sat, 17 Dec 2016 12:28:13 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH] pNFS/flexfiles: delete deviceid, don't mark inactive
Date: Sat, 17 Dec 2016 15:28:09 -0500
Message-Id: <20161217202809.2759-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

Instead of marking a device inactive, remove it from the cache entirely.

Flexfiles has a way to report errors back to the server, so we don't want
to stop devices from being tried again for 120 seconds.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 6 ++++--
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 9e111d07f667..45962fe5098c 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1126,7 +1126,8 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 	case -EPIPE:
 		dprintk("%s DS connection error %d\n", __func__,
 			task->tk_status);
-		nfs4_mark_deviceid_unavailable(devid);
+		nfs4_delete_deviceid(devid->ld, devid->nfs_client,
+				&devid->deviceid);
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		/* fall through */
 	default:
@@ -1175,7 +1176,8 @@ static int ff_layout_async_handle_error_v3(struct rpc_task *task,
 	default:
 		dprintk("%s DS connection error %d\n", __func__,
 			task->tk_status);
-		nfs4_mark_deviceid_unavailable(devid);
+		nfs4_delete_deviceid(devid->ld, devid->nfs_client,
+				&devid->deviceid);
 	}
 	/* FIXME: Need to prevent infinite looping here. */
 	return -NFS4ERR_RESET_TO_PNFS;
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 3cc39d1c1206..e5a6f248697b 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -177,7 +177,7 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 static void ff_layout_mark_devid_invalid(struct pnfs_layout_segment *lseg,
 		struct nfs4_deviceid_node *devid)
 {
-	nfs4_mark_deviceid_unavailable(devid);
+	nfs4_delete_deviceid(devid->ld, devid->nfs_client, &devid->deviceid);
 	if (!ff_layout_has_available_ds(lseg))
 		pnfs_error_mark_layout_for_return(lseg->pls_layout->plh_inode,
 				lseg);
-- 
2.9.3

