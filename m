Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:60682 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755379AbaHZCqc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Aug 2014 22:46:32 -0400
Received: by mail-ig0-f178.google.com with SMTP id uq10so3806062igb.17
        for <linux-nfs@vger.kernel.org>; Mon, 25 Aug 2014 19:46:31 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4: Don't clear the open state when we just did an OPEN_DOWNGRADE
Date: Mon, 25 Aug 2014 22:46:32 -0400
Message-Id: <1409021192-12706-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1409021192-12706-1-git-send-email-trond.myklebust@primarydata.com>
References: <1409021192-12706-1-git-send-email-trond.myklebust@primarydata.com>
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
 fs/nfs/nfs4proc.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index caf838b4edbd..742a8327a7b6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2560,6 +2560,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	struct nfs4_closedata *calldata = data;
 	struct nfs4_state *state = calldata->state;
 	struct nfs_server *server = NFS_SERVER(calldata->inode);
+	nfs4_stateid *res_stateid = NULL;
 
 	dprintk("%s: begin!\n", __func__);
 	if (!nfs4_sequence_done(task, &calldata->res.seq_res))
@@ -2570,11 +2571,13 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	 */
 	switch (task->tk_status) {
 		case 0:
+			res_stateid = &calldata->res.stateid;
+			renew_lease(server, calldata->timestamp);
+			if (calldata->arg.fmode != 0)
+				break;
 			if (calldata->roc)
 				pnfs_roc_set_barrier(state->inode,
 						     calldata->roc_barrier);
-			nfs_clear_open_stateid(state, &calldata->res.stateid, 0);
-			renew_lease(server, calldata->timestamp);
 			goto out_release;
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_STALE_STATEID:
@@ -2589,7 +2592,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
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

