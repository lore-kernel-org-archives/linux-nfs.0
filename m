Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:40461 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015AbbAYAR2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 19:17:28 -0500
Received: by mail-ie0-f171.google.com with SMTP id tr6so3351417ieb.2
        for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2015 16:17:27 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFSv4: Update of VFS byte range lock must be atomic with the stateid update
Date: Sat, 24 Jan 2015 19:17:20 -0500
Message-Id: <1422145041-81669-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1422145041-81669-4-git-send-email-trond.myklebust@primarydata.com>
References: <1422145041-81669-1-git-send-email-trond.myklebust@primarydata.com>
 <1422145041-81669-2-git-send-email-trond.myklebust@primarydata.com>
 <1422145041-81669-3-git-send-email-trond.myklebust@primarydata.com>
 <1422145041-81669-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we test the lock stateid remained unchanged while we were
updating the VFS tracking of the byte range lock. Have the process
replay the lock to the server if we detect that was not the case.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 37 +++++++++++++++----------------------
 include/linux/nfs_xdr.h |  1 +
 2 files changed, 16 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 41e7c2fc046e..9f6baf98942c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5420,9 +5420,10 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 	switch (task->tk_status) {
 		case 0:
 			renew_lease(calldata->server, calldata->timestamp);
-			nfs4_update_lock_stateid(calldata->lsp,
-					&calldata->res.stateid);
-			break;
+			do_vfs_lock(calldata->fl.fl_file, &calldata->fl);
+			if (nfs4_update_lock_stateid(calldata->lsp,
+					&calldata->res.stateid))
+				break;
 		case -NFS4ERR_BAD_STATEID:
 		case -NFS4ERR_OLD_STATEID:
 		case -NFS4ERR_STALE_STATEID:
@@ -5661,6 +5662,13 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 	case 0:
 		renew_lease(NFS_SERVER(data->ctx->dentry->d_inode),
 				data->timestamp);
+		if (data->arg.new_lock) {
+			data->fl.fl_flags &= ~(FL_SLEEP | FL_ACCESS);
+			if (do_vfs_lock(data->fl.fl_file, &data->fl) < 0) {
+				rpc_restart_call_prepare(task);
+				break;
+			}
+		}
 		if (data->arg.new_lock_owner != 0) {
 			nfs_confirm_seqid(&lsp->ls_seqid, 0);
 			nfs4_stateid_copy(&lsp->ls_stateid, &data->res.stateid);
@@ -5760,7 +5768,8 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 		if (recovery_type == NFS_LOCK_RECLAIM)
 			data->arg.reclaim = NFS_LOCK_RECLAIM;
 		nfs4_set_sequence_privileged(&data->arg.seq_args);
-	}
+	} else
+		data->arg.new_lock = 1;
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
@@ -5884,10 +5893,8 @@ static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *reques
 
 static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
-	struct nfs4_state_owner *sp = state->owner;
 	struct nfs_inode *nfsi = NFS_I(state->inode);
 	unsigned char fl_flags = request->fl_flags;
-	unsigned int seq;
 	int status = -ENOLCK;
 
 	if ((fl_flags & FL_POSIX) &&
@@ -5907,25 +5914,11 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 		/* ...but avoid races with delegation recall... */
 		request->fl_flags = fl_flags & ~FL_SLEEP;
 		status = do_vfs_lock(request->fl_file, request);
-		goto out_unlock;
-	}
-	seq = raw_seqcount_begin(&sp->so_reclaim_seqcount);
-	up_read(&nfsi->rwsem);
-	status = _nfs4_do_setlk(state, cmd, request, NFS_LOCK_NEW);
-	if (status != 0)
+		up_read(&nfsi->rwsem);
 		goto out;
-	down_read(&nfsi->rwsem);
-	if (read_seqcount_retry(&sp->so_reclaim_seqcount, seq)) {
-		status = -NFS4ERR_DELAY;
-		goto out_unlock;
 	}
-	/* Note: we always want to sleep here! */
-	request->fl_flags = fl_flags | FL_SLEEP;
-	if (do_vfs_lock(request->fl_file, request) < 0)
-		printk(KERN_WARNING "NFS: %s: VFS is out of sync with lock "
-			"manager!\n", __func__);
-out_unlock:
 	up_read(&nfsi->rwsem);
+	status = _nfs4_do_setlk(state, cmd, request, NFS_LOCK_NEW);
 out:
 	request->fl_flags = fl_flags;
 	return status;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b6a6953c0f09..e5c3b620a609 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -422,6 +422,7 @@ struct nfs_lock_args {
 	struct nfs_lowner	lock_owner;
 	unsigned char		block : 1;
 	unsigned char		reclaim : 1;
+	unsigned char		new_lock : 1;
 	unsigned char		new_lock_owner : 1;
 };
 
-- 
2.1.0

