Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:43931 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222AbaHZSa7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 14:30:59 -0400
Received: by mail-ig0-f172.google.com with SMTP id h15so4968399igd.17
        for <linux-nfs@vger.kernel.org>; Tue, 26 Aug 2014 11:30:58 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: James Drews <drews@engr.wisc.edu>, jrs@world.std.com
Subject: [PATCH v2 2/2] NFSv4: Don't clear the open state when we just did an OPEN_DOWNGRADE
Date: Tue, 26 Aug 2014 14:30:53 -0400
Message-Id: <1409077853-15680-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1409077853-15680-1-git-send-email-trond.myklebust@primarydata.com>
References: <1409077853-15680-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we did an OPEN_DOWNGRADE, then the right thing to do on success, is
to apply the new open mode to the struct nfs4_state. Instead, we were
unconditionally clearing the state, making it appear to our state
machinery as if we had just performed a CLOSE.

Fixes: 226056c5c312b (NFSv4: Use correct locking when updating nfs4_state...)
Cc: stable@vger.kernel.org # 3.15+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7d67d5b332d4..fe63691822bc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2560,6 +2560,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	struct nfs4_closedata *calldata = data;
 	struct nfs4_state *state = calldata->state;
 	struct nfs_server *server = NFS_SERVER(calldata->inode);
+	nfs4_stateid *res_stateid = NULL;
 
 	dprintk("%s: begin!\n", __func__);
 	if (!nfs4_sequence_done(task, &calldata->res.seq_res))
@@ -2570,12 +2571,12 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	 */
 	switch (task->tk_status) {
 		case 0:
-			if (calldata->roc)
+			res_stateid = &calldata->res.stateid;
+			if (calldata->arg.fmode == 0 && calldata->roc)
 				pnfs_roc_set_barrier(state->inode,
 						     calldata->roc_barrier);
-			nfs_clear_open_stateid(state, &calldata->res.stateid, 0);
 			renew_lease(server, calldata->timestamp);
-			goto out_release;
+			break;
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_OLD_STATEID:
@@ -2589,7 +2590,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 				goto out_release;
 			}
 	}
-	nfs_clear_open_stateid(state, NULL, calldata->arg.fmode);
+	nfs_clear_open_stateid(state, res_stateid, calldata->arg.fmode);
 out_release:
 	nfs_release_seqid(calldata->arg.seqid);
 	nfs_refresh_inode(calldata->inode, calldata->res.fattr);
-- 
1.9.3

