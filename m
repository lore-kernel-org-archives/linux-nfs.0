Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:34893 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933516AbbGJUds (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 16:33:48 -0400
Received: by ykee186 with SMTP id e186so72313857yke.2
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2015 13:33:47 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, william@gandi.net, bfields@fieldses.org
Subject: [RFC PATCH 4/4] nfs4: have do_vfs_lock take an inode pointer
Date: Fri, 10 Jul 2015 16:33:34 -0400
Message-Id: <1436560414-26306-5-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1436560414-26306-1-git-send-email-jeff.layton@primarydata.com>
References: <1436560414-26306-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we have file locking helpers that can deal with an inode
instead of a filp, we can change the NFSv4 locking code to use that
instead.

This should fix the case where we have a filp that is closed while flock
or OFD locks are set on it, and the task is signaled so that it doesn't
wait for the LOCKU reply to come in before the filp is freed. At that
point we can end up with a use-after-free with the current code, which
relies on dereferencing the fl_file in the lock request.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/nfs4proc.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 60be01f69b84..8bee93469617 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5439,15 +5439,15 @@ static int nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock *
 	return err;
 }
 
-static int do_vfs_lock(struct file *file, struct file_lock *fl)
+static int do_vfs_lock(struct inode *inode, struct file_lock *fl)
 {
 	int res = 0;
 	switch (fl->fl_flags & (FL_POSIX|FL_FLOCK)) {
 		case FL_POSIX:
-			res = posix_lock_file_wait(file, fl);
+			res = posix_lock_inode_wait(inode, fl);
 			break;
 		case FL_FLOCK:
-			res = flock_lock_file_wait(file, fl);
+			res = flock_lock_inode_wait(inode, fl);
 			break;
 		default:
 			BUG();
@@ -5507,7 +5507,7 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 	switch (task->tk_status) {
 		case 0:
 			renew_lease(calldata->server, calldata->timestamp);
-			do_vfs_lock(calldata->fl.fl_file, &calldata->fl);
+			do_vfs_lock(calldata->lsp->ls_state->inode, &calldata->fl);
 			if (nfs4_update_lock_stateid(calldata->lsp,
 					&calldata->res.stateid))
 				break;
@@ -5615,7 +5615,7 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	mutex_lock(&sp->so_delegreturn_mutex);
 	/* Exclude nfs4_reclaim_open_stateid() - note nesting! */
 	down_read(&nfsi->rwsem);
-	if (do_vfs_lock(request->fl_file, request) == -ENOENT) {
+	if (do_vfs_lock(inode, request) == -ENOENT) {
 		up_read(&nfsi->rwsem);
 		mutex_unlock(&sp->so_delegreturn_mutex);
 		goto out;
@@ -5756,7 +5756,7 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 				data->timestamp);
 		if (data->arg.new_lock) {
 			data->fl.fl_flags &= ~(FL_SLEEP | FL_ACCESS);
-			if (do_vfs_lock(data->fl.fl_file, &data->fl) < 0) {
+			if (do_vfs_lock(lsp->ls_state->inode, &data->fl) < 0) {
 				rpc_restart_call_prepare(task);
 				break;
 			}
@@ -5998,7 +5998,7 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 	if (status != 0)
 		goto out;
 	request->fl_flags |= FL_ACCESS;
-	status = do_vfs_lock(request->fl_file, request);
+	status = do_vfs_lock(state->inode, request);
 	if (status < 0)
 		goto out;
 	down_read(&nfsi->rwsem);
@@ -6006,7 +6006,7 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 		/* Yes: cache locks! */
 		/* ...but avoid races with delegation recall... */
 		request->fl_flags = fl_flags & ~FL_SLEEP;
-		status = do_vfs_lock(request->fl_file, request);
+		status = do_vfs_lock(state->inode, request);
 		up_read(&nfsi->rwsem);
 		goto out;
 	}
-- 
2.4.3

