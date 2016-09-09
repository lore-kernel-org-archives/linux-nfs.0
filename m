Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60560 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753226AbcIISrx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 14:47:53 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, Anna.Schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 02/10] nfs: eliminate pointless and confusing do_vfs_lock wrappers
Date: Fri,  9 Sep 2016 14:47:43 -0400
Message-Id: <1473446870-1831-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1473446870-1831-1-git-send-email-jlayton@redhat.com>
References: <1473446870-1831-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/file.c     |  9 ++-------
 fs/nfs/nfs4proc.c | 15 +++++----------
 2 files changed, 7 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 7d620970f2e1..a3332a78a0e5 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -705,11 +705,6 @@ out_noconflict:
 	goto out;
 }
 
-static int do_vfs_lock(struct file *file, struct file_lock *fl)
-{
-	return locks_lock_file_wait(file, fl);
-}
-
 static int
 do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 {
@@ -742,7 +737,7 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	if (!is_local)
 		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
 	else
-		status = do_vfs_lock(filp, fl);
+		status = locks_lock_file_wait(filp, fl);
 	return status;
 }
 
@@ -767,7 +762,7 @@ do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	if (!is_local)
 		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
 	else
-		status = do_vfs_lock(filp, fl);
+		status = locks_lock_file_wait(filp, fl);
 	if (status < 0)
 		goto out;
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f5aecaabcb7c..85817e4103ea 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5600,11 +5600,6 @@ static int nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock *
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
@@ -5657,7 +5652,7 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 	switch (task->tk_status) {
 		case 0:
 			renew_lease(calldata->server, calldata->timestamp);
-			do_vfs_lock(calldata->lsp->ls_state->inode, &calldata->fl);
+			locks_lock_inode_wait(calldata->lsp->ls_state->inode, &calldata->fl);
 			if (nfs4_update_lock_stateid(calldata->lsp,
 					&calldata->res.stateid))
 				break;
@@ -5765,7 +5760,7 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	mutex_lock(&sp->so_delegreturn_mutex);
 	/* Exclude nfs4_reclaim_open_stateid() - note nesting! */
 	down_read(&nfsi->rwsem);
-	if (do_vfs_lock(inode, request) == -ENOENT) {
+	if (locks_lock_inode_wait(inode, request) == -ENOENT) {
 		up_read(&nfsi->rwsem);
 		mutex_unlock(&sp->so_delegreturn_mutex);
 		goto out;
@@ -5906,7 +5901,7 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 				data->timestamp);
 		if (data->arg.new_lock) {
 			data->fl.fl_flags &= ~(FL_SLEEP | FL_ACCESS);
-			if (do_vfs_lock(lsp->ls_state->inode, &data->fl) < 0) {
+			if (locks_lock_inode_wait(lsp->ls_state->inode, &data->fl) < 0) {
 				rpc_restart_call_prepare(task);
 				break;
 			}
@@ -6148,7 +6143,7 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 	if (status != 0)
 		goto out;
 	request->fl_flags |= FL_ACCESS;
-	status = do_vfs_lock(state->inode, request);
+	status = locks_lock_inode_wait(state->inode, request);
 	if (status < 0)
 		goto out;
 	mutex_lock(&sp->so_delegreturn_mutex);
@@ -6157,7 +6152,7 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 		/* Yes: cache locks! */
 		/* ...but avoid races with delegation recall... */
 		request->fl_flags = fl_flags & ~FL_SLEEP;
-		status = do_vfs_lock(state->inode, request);
+		status = locks_lock_inode_wait(state->inode, request);
 		up_read(&nfsi->rwsem);
 		mutex_unlock(&sp->so_delegreturn_mutex);
 		goto out;
-- 
2.7.4

