Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40608 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754771AbbL3NOI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Dec 2015 08:14:08 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 10/10] NFS: cleanup do_vfs_lock()
Date: Wed, 30 Dec 2015 08:14:06 -0500
Message-Id: <5622df2492ef437a67f7246f724a2d705e21cc1e.1451480826.git.bcodding@redhat.com>
In-Reply-To: <cover.1451480826.git.bcodding@redhat.com>
References: <cover.1451480826.git.bcodding@redhat.com>
In-Reply-To: <cover.1451480826.git.bcodding@redhat.com>
References: <cover.1451480826.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The three versions of do_vfs_lock() only called locks_lock_inode_wait(), so
just call that directly.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/lockd/clntproc.c |   13 ++++---------
 fs/nfs/file.c       |    9 ++-------
 fs/nfs/nfs4proc.c   |   17 +++++++----------
 3 files changed, 13 insertions(+), 26 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index fa1d83b..58145db 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -476,11 +476,6 @@ static void nlmclnt_locks_init_private(struct file_lock *fl, struct nlm_host *ho
 	fl->fl_ops = &nlmclnt_lock_ops;
 }
 
-static int do_vfs_lock(struct inode *inode, struct file_lock *fl)
-{
-	return locks_lock_inode_wait(inode, fl);
-}
-
 /*
  * LOCK: Try to create a lock
  *
@@ -518,7 +513,7 @@ nlmclnt_lock(struct nlm_rqst *req, struct file_lock *fl)
 	req->a_args.state = nsm_local_state;
 
 	fl->fl_flags |= FL_ACCESS;
-	status = do_vfs_lock(inode, fl);
+	status = locks_lock_inode_wait(inode, fl);
 	fl->fl_flags = fl_flags;
 	if (status < 0)
 		goto out;
@@ -568,7 +563,7 @@ again:
 		}
 		/* Ensure the resulting lock will get added to granted list */
 		fl->fl_flags |= FL_SLEEP;
-		if (do_vfs_lock(inode, fl) < 0)
+		if (locks_lock_inode_wait(inode, fl) < 0)
 			printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n", __func__);
 		up_read(&host->h_rwsem);
 		fl->fl_flags = fl_flags;
@@ -598,7 +593,7 @@ out_unlock:
 	fl_type = fl->fl_type;
 	fl->fl_type = F_UNLCK;
 	down_read(&host->h_rwsem);
-	do_vfs_lock(inode, fl);
+	locks_lock_inode_wait(inode, fl);
 	up_read(&host->h_rwsem);
 	fl->fl_type = fl_type;
 	fl->fl_flags = fl_flags;
@@ -666,7 +661,7 @@ nlmclnt_unlock(struct nfs_open_context *ctx,
 	 */
 	fl->fl_flags |= FL_EXISTS;
 	down_read(&host->h_rwsem);
-	status = do_vfs_lock(d_inode(ctx->dentry), fl);
+	status = locks_lock_inode_wait(d_inode(ctx->dentry), fl);
 	up_read(&host->h_rwsem);
 	fl->fl_flags = fl_flags;
 	if (status == -ENOENT) {
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 3644fed..5842d0f 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -737,11 +737,6 @@ out_noconflict:
 	goto out;
 }
 
-static int do_vfs_lock(struct file *file, struct file_lock *fl)
-{
-	return locks_lock_file_wait(file, fl);
-}
-
 static int
 defer_close_unlk(struct inode *inode, struct nfs_lock_context *l_ctx)
 {
@@ -791,7 +786,7 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	if (!is_local)
 		status = NFS_PROTO(inode)->lock(ctx, cmd, fl);
 	else
-		status = do_vfs_lock(filp, fl);
+		status = locks_lock_file_wait(filp, fl);
 	return status;
 }
 
@@ -822,7 +817,7 @@ do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	if (!is_local)
 		status = NFS_PROTO(inode)->lock(ctx, cmd, fl);
 	else
-		status = do_vfs_lock(filp, fl);
+		status = locks_lock_file_wait(filp, fl);
 	if (status < 0)
 		goto out;
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 279c8b3..02c246f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5510,11 +5510,6 @@ static int nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock *
 	return err;
 }
 
-static int do_vfs_lock(struct inode *inode, struct file_lock *fl)
-{
-	return locks_lock_inode_wait(inode, fl);
-}
-
 struct nfs4_unlockdata {
 	struct nfs_locku_args arg;
 	struct nfs_locku_res res;
@@ -5567,7 +5562,8 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 	switch (task->tk_status) {
 		case 0:
 			renew_lease(calldata->server, calldata->timestamp);
-			do_vfs_lock(calldata->lsp->ls_state->inode, &calldata->fl);
+			locks_lock_inode_wait(calldata->lsp->ls_state->inode,
+				&calldata->fl);
 			if (nfs4_update_lock_stateid(calldata->lsp,
 					&calldata->res.stateid))
 				break;
@@ -5677,7 +5673,7 @@ static int nfs4_proc_unlck(struct nfs_open_context *ctx,
 	mutex_lock(&sp->so_delegreturn_mutex);
 	/* Exclude nfs4_reclaim_open_stateid() - note nesting! */
 	down_read(&nfsi->rwsem);
-	if (do_vfs_lock(inode, request) == -ENOENT) {
+	if (locks_lock_inode_wait(inode, request) == -ENOENT) {
 		up_read(&nfsi->rwsem);
 		mutex_unlock(&sp->so_delegreturn_mutex);
 		goto out;
@@ -5818,7 +5814,8 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 				data->timestamp);
 		if (data->arg.new_lock) {
 			data->fl.fl_flags &= ~(FL_SLEEP | FL_ACCESS);
-			if (do_vfs_lock(lsp->ls_state->inode, &data->fl) < 0) {
+			if (locks_lock_inode_wait(lsp->ls_state->inode,
+						&data->fl) < 0) {
 				rpc_restart_call_prepare(task);
 				break;
 			}
@@ -6060,7 +6057,7 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 	if (status != 0)
 		goto out;
 	request->fl_flags |= FL_ACCESS;
-	status = do_vfs_lock(state->inode, request);
+	status = locks_lock_inode_wait(state->inode, request);
 	if (status < 0)
 		goto out;
 	down_read(&nfsi->rwsem);
@@ -6068,7 +6065,7 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 		/* Yes: cache locks! */
 		/* ...but avoid races with delegation recall... */
 		request->fl_flags = fl_flags & ~FL_SLEEP;
-		status = do_vfs_lock(state->inode, request);
+		status = locks_lock_inode_wait(state->inode, request);
 		up_read(&nfsi->rwsem);
 		goto out;
 	}
-- 
1.7.1

