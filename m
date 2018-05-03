Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56090 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750947AbeECLM7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 May 2018 07:12:59 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Don't add a new lock on an interrupted wait for LOCK
Date: Thu,  3 May 2018 07:12:57 -0400
Message-Id: <1e2732518f990acac47ef20d936ac8a1200d7a79.1525345895.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the wait for a LOCK operation is interrupted, and then the file is
closed, the locks cleanup code will assume that no new locks will be added
to the inode after it has completed.  We already have a mechanism to detect
if there was signal, so let's use that to avoid recreating the local lock
once the RPC completes.  Also skip re-sending the LOCK operation for the
various error cases if we were signaled.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4proc.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 47f3c273245e..1aba009a5ef8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6345,32 +6345,36 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 	case 0:
 		renew_lease(NFS_SERVER(d_inode(data->ctx->dentry)),
 				data->timestamp);
-		if (data->arg.new_lock) {
+		if (data->arg.new_lock && !data->cancelled) {
 			data->fl.fl_flags &= ~(FL_SLEEP | FL_ACCESS);
-			if (locks_lock_inode_wait(lsp->ls_state->inode, &data->fl) < 0) {
-				rpc_restart_call_prepare(task);
+			if (locks_lock_inode_wait(lsp->ls_state->inode, &data->fl) > 0)
 				break;
-			}
 		}
+
 		if (data->arg.new_lock_owner != 0) {
 			nfs_confirm_seqid(&lsp->ls_seqid, 0);
 			nfs4_stateid_copy(&lsp->ls_stateid, &data->res.stateid);
 			set_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
-		} else if (!nfs4_update_lock_stateid(lsp, &data->res.stateid))
-			rpc_restart_call_prepare(task);
+			goto out_done;
+		} else if (nfs4_update_lock_stateid(lsp, &data->res.stateid))
+			goto out_done;
+
 		break;
 	case -NFS4ERR_BAD_STATEID:
 	case -NFS4ERR_OLD_STATEID:
 	case -NFS4ERR_STALE_STATEID:
 	case -NFS4ERR_EXPIRED:
 		if (data->arg.new_lock_owner != 0) {
-			if (!nfs4_stateid_match(&data->arg.open_stateid,
+			if (nfs4_stateid_match(&data->arg.open_stateid,
 						&lsp->ls_state->open_stateid))
-				rpc_restart_call_prepare(task);
-		} else if (!nfs4_stateid_match(&data->arg.lock_stateid,
+				goto out_done;
+		} else if (nfs4_stateid_match(&data->arg.lock_stateid,
 						&lsp->ls_stateid))
-				rpc_restart_call_prepare(task);
+				goto out_done;
 	}
+	if (!data->cancelled)
+		rpc_restart_call_prepare(task);
+out_done:
 	dprintk("%s: done, ret = %d!\n", __func__, data->rpc_status);
 }
 
-- 
2.14.3

