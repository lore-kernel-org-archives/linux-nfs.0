Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:29399 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754290AbdFWOga (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Jun 2017 10:36:30 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] PNFS fix EACCESS on commit to DS handling
Date: Fri, 23 Jun 2017 10:26:58 -0400
Message-ID: <20170623142659.81480-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit fabbbee0eb0f "PNFS fix fallback to MDS if got error on
commit to DS" moved the pnfs_set_lo_fail() to unhandled errors
which was not correct and lead to a kernel oops on umount.

Instead, fix the original EACCESS on commit to DS error by
getting the new layout and re-doing the IO.

Fixes: fabbbee0eb0f ("PNFS fix fallback to MDS if got error on commit to DS")
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/filelayout/filelayout.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 61dcb4b..8075efe 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -153,6 +153,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 	case -NFS4ERR_RETRY_UNCACHED_REP:
 		break;
 	/* Invalidate Layout errors */
+	case -NFS4ERR_ACCESS:
 	case -NFS4ERR_PNFS_NO_LAYOUT:
 	case -ESTALE:           /* mapped NFS4ERR_STALE */
 	case -EBADHANDLE:       /* mapped NFS4ERR_BADHANDLE */
@@ -183,10 +184,10 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 			task->tk_status);
 		nfs4_mark_deviceid_unavailable(devid);
 		pnfs_error_mark_layout_for_return(inode, lseg);
+		pnfs_set_lo_fail(lseg);
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		/* fall through */
 	default:
-		pnfs_set_lo_fail(lseg);
 reset:
 		dprintk("%s Retry through MDS. Error %d\n", __func__,
 			task->tk_status);
-- 
1.8.3.1

