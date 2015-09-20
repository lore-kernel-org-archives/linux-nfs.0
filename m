Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:36015 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753410AbbITRrr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Sep 2015 13:47:47 -0400
Received: by ykdt18 with SMTP id t18so85374323ykd.3
        for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2015 10:47:46 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.x/pnfs: Don't try to recover stateids twice in layoutget
Date: Sun, 20 Sep 2015 13:47:44 -0400
Message-Id: <1442771264-49991-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the current open or layout stateid doesn't match the stateid used
in the layoutget RPC call, then don't try to recover it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e129347b656f..ef6b46e08ac6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7813,20 +7813,23 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 			dprintk("%s: NFS4ERR_RECALLCONFLICT waiting %lu\n",
 				__func__, delay);
 			rpc_delay(task, delay);
-			task->tk_status = 0;
-			rpc_restart_call_prepare(task);
-			goto out; /* Do not call nfs4_async_handle_error() */
+			/* Do not call nfs4_async_handle_error() */
+			goto out_restart;
 		}
 		break;
 	case -NFS4ERR_EXPIRED:
 	case -NFS4ERR_BAD_STATEID:
 		spin_lock(&inode->i_lock);
-		lo = NFS_I(inode)->layout;
-		if (!lo || list_empty(&lo->plh_segs)) {
+		if (nfs4_stateid_match(&lgp->args.stateid,
+					&lgp->args.ctx->state->stateid)) {
 			spin_unlock(&inode->i_lock);
 			/* If the open stateid was bad, then recover it. */
 			state = lgp->args.ctx->state;
-		} else {
+			break;
+		}
+		lo = NFS_I(inode)->layout;
+		if (lo && nfs4_stateid_match(&lgp->args.stateid,
+					&lo->plh_stateid)) {
 			LIST_HEAD(head);
 
 			/*
@@ -7837,16 +7840,19 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 			pnfs_mark_matching_lsegs_invalid(lo, &head, NULL);
 			spin_unlock(&inode->i_lock);
 			pnfs_free_lseg_list(&head);
-	
-			task->tk_status = 0;
-			rpc_restart_call_prepare(task);
-		}
+		} else
+			spin_unlock(&inode->i_lock);
+		goto out_restart;
 	}
 	if (nfs4_async_handle_error(task, server, state, NULL) == -EAGAIN)
-		rpc_restart_call_prepare(task);
+		goto out_restart;
 out:
 	dprintk("<-- %s\n", __func__);
 	return;
+out_restart:
+	task->tk_status = 0;
+	rpc_restart_call_prepare(task);
+	return;
 out_overflow:
 	task->tk_status = -EOVERFLOW;
 	goto out;
-- 
2.4.3

