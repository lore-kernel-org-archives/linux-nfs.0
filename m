Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:65006 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbbAYAR1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 19:17:27 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so3174966igj.4
        for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2015 16:17:24 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFSv4: Fix atomicity problems with lock stateid updates
Date: Sat, 24 Jan 2015 19:17:17 -0500
Message-Id: <1422145041-81669-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1422145041-81669-1-git-send-email-trond.myklebust@primarydata.com>
References: <1422145041-81669-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we update the lock stateid, we really do need to ensure that this is
done under the state->state_lock, and that we are indeed only updating
confirmed locks with a newer version of the same stateid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 42 +++++++++++++++++++++++++++++-------------
 1 file changed, 29 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0a279ad5421f..db9d98eda07b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1297,6 +1297,23 @@ no_delegation:
 	return ret;
 }
 
+static bool nfs4_update_lock_stateid(struct nfs4_lock_state *lsp,
+		const nfs4_stateid *stateid)
+{
+	struct nfs4_state *state = lsp->ls_state;
+	bool ret = false;
+
+	spin_lock(&state->state_lock);
+	if (!nfs4_stateid_match_other(stateid, &lsp->ls_stateid))
+		goto out_noupdate;
+	if (!nfs4_stateid_is_newer(stateid, &lsp->ls_stateid))
+		goto out_noupdate;
+	nfs4_stateid_copy(&lsp->ls_stateid, stateid);
+	ret = true;
+out_noupdate:
+	spin_unlock(&state->state_lock);
+	return ret;
+}
 
 static void nfs4_return_incompatible_delegation(struct inode *inode, fmode_t fmode)
 {
@@ -5403,9 +5420,9 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 		return;
 	switch (task->tk_status) {
 		case 0:
-			nfs4_stateid_copy(&calldata->lsp->ls_stateid,
-					&calldata->res.stateid);
 			renew_lease(calldata->server, calldata->timestamp);
+			nfs4_update_lock_stateid(calldata->lsp,
+					&calldata->res.stateid);
 			break;
 		case -NFS4ERR_BAD_STATEID:
 		case -NFS4ERR_OLD_STATEID:
@@ -5626,6 +5643,7 @@ out_wait:
 static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_lockdata *data = calldata;
+	struct nfs4_lock_state *lsp = data->lsp;
 
 	dprintk("%s: begin!\n", __func__);
 
@@ -5633,18 +5651,16 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 		return;
 
 	data->rpc_status = task->tk_status;
-	if (data->arg.new_lock_owner != 0) {
-		if (data->rpc_status == 0)
-			nfs_confirm_seqid(&data->lsp->ls_seqid, 0);
-		else
-			goto out;
-	}
-	if (data->rpc_status == 0) {
-		nfs4_stateid_copy(&data->lsp->ls_stateid, &data->res.stateid);
-		set_bit(NFS_LOCK_INITIALIZED, &data->lsp->ls_flags);
-		renew_lease(NFS_SERVER(data->ctx->dentry->d_inode), data->timestamp);
+	if (task->tk_status == 0) {
+		renew_lease(NFS_SERVER(data->ctx->dentry->d_inode),
+				data->timestamp);
+		if (data->arg.new_lock_owner != 0) {
+			nfs_confirm_seqid(&lsp->ls_seqid, 0);
+			nfs4_stateid_copy(&lsp->ls_stateid, &data->res.stateid);
+			set_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags);
+		} else if (!nfs4_update_lock_stateid(lsp, &data->res.stateid))
+			rpc_restart_call_prepare(task);
 	}
-out:
 	dprintk("%s: done, ret = %d!\n", __func__, data->rpc_status);
 }
 
-- 
2.1.0

