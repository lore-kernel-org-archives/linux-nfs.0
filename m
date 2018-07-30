Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:38853 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725814AbeG3EOB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jul 2018 00:14:01 -0400
Received: by mail-it0-f66.google.com with SMTP id v71-v6so14814326itb.3
        for <linux-nfs@vger.kernel.org>; Sun, 29 Jul 2018 19:41:15 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Kenneth Johansson <ken@kenjo.org>,
        Benjamin Coddington <bcodding@redhat.com>,
        Jeff Layton <jlayton@kernel.org>
Subject: [PATCH] NFSv4: Fix _nfs4_do_setlk()
Date: Sun, 29 Jul 2018 22:40:52 -0400
Message-Id: <20180730024052.28026-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The patch to fix the case where a lock request was interrupted ended up
changing default handling of errors such as NFS4ERR_DENIED and caused the
client to immediately resend the lock request. Let's do a partial revert
of that request so that the default is now to exit, but change the way
we handle resends to take into account the fact that the user may have
interrupted the request.

Reported-by: Kenneth Johansson <ken@kenjo.org>
Fixes: a3cf9bca2ace ("NFSv4: Don't add a new lock on an interrupted wait..")
Cc: Benjamin Coddington <bcodding@redhat.com>
Cc: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f73a8315933f..8e482f634d60 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6501,34 +6501,34 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 		if (data->arg.new_lock && !data->cancelled) {
 			data->fl.fl_flags &= ~(FL_SLEEP | FL_ACCESS);
 			if (locks_lock_inode_wait(lsp->ls_state->inode, &data->fl) < 0)
-				break;
+				goto out_restart;
 		}
-
 		if (data->arg.new_lock_owner != 0) {
 			nfs_confirm_seqid(&lsp->ls_seqid, 0);
 			nfs4_stateid_copy(&lsp->ls_stateid, &data->res.stateid);
 			set_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
-			goto out_done;
-		} else if (nfs4_update_lock_stateid(lsp, &data->res.stateid))
-			goto out_done;
-
+		} else if (!nfs4_update_lock_stateid(lsp, &data->res.stateid))
+			goto out_restart;
 		break;
 	case -NFS4ERR_BAD_STATEID:
 	case -NFS4ERR_OLD_STATEID:
 	case -NFS4ERR_STALE_STATEID:
 	case -NFS4ERR_EXPIRED:
 		if (data->arg.new_lock_owner != 0) {
-			if (nfs4_stateid_match(&data->arg.open_stateid,
+			if (!nfs4_stateid_match(&data->arg.open_stateid,
 						&lsp->ls_state->open_stateid))
-				goto out_done;
-		} else if (nfs4_stateid_match(&data->arg.lock_stateid,
+				goto out_restart;
+		} else if (!nfs4_stateid_match(&data->arg.lock_stateid,
 						&lsp->ls_stateid))
-				goto out_done;
+				goto out_restart;
 	}
-	if (!data->cancelled)
-		rpc_restart_call_prepare(task);
 out_done:
 	dprintk("%s: done, ret = %d!\n", __func__, data->rpc_status);
+	return;
+out_restart:
+	if (!data->cancelled)
+		rpc_restart_call_prepare(task);
+	goto out_done;
 }
 
 static void nfs4_lock_release(void *calldata)
@@ -6537,7 +6537,7 @@ static void nfs4_lock_release(void *calldata)
 
 	dprintk("%s: begin!\n", __func__);
 	nfs_free_seqid(data->arg.open_seqid);
-	if (data->cancelled) {
+	if (data->cancelled && data->rpc_status == 0) {
 		struct rpc_task *task;
 		task = nfs4_do_unlck(&data->fl, data->ctx, data->lsp,
 				data->arg.lock_seqid);
-- 
2.17.1

