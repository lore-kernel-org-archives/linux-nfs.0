From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 27/69] NFSv4: Ensure that file unlock requests don't
 conflict with state recovery
Date: Tue, 23 Dec 2008 18:02:13 -0500
Message-ID: <20081223230213.13743.58777.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752394AbYLWXXp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:45 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNa7Y021304
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:40 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The unlock path is currently failing to take the nfs_client->cl_sem read
lock, and hence the recovery path may see locks disappear from underneath
it.
Also ensure that it takes the nfs_inode->rwsem read lock so that it there
is no conflict with delegation recalls.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c  |   26 ++++++++++++++++----------
 fs/nfs/nfs4state.c |    4 ++++
 2 files changed, 20 insertions(+), 10 deletions(-)


diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 660c5dc..aec4e47 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3273,6 +3273,8 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 
 static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
+	struct nfs_client *clp = state->owner->so_client;
+	struct nfs_inode *nfsi = NFS_I(state->inode);
 	struct nfs_seqid *seqid;
 	struct nfs4_lock_state *lsp;
 	struct rpc_task *task;
@@ -3282,8 +3284,15 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	status = nfs4_set_lock_state(state, request);
 	/* Unlock _before_ we do the RPC call */
 	request->fl_flags |= FL_EXISTS;
-	if (do_vfs_lock(request->fl_file, request) == -ENOENT)
+	down_read(&clp->cl_sem);
+	down_read(&nfsi->rwsem);
+	if (do_vfs_lock(request->fl_file, request) == -ENOENT) {
+		up_read(&nfsi->rwsem);
+		up_read(&clp->cl_sem);
 		goto out;
+	}
+	up_read(&nfsi->rwsem);
+	up_read(&clp->cl_sem);
 	if (status != 0)
 		goto out;
 	/* Is this a delegated lock? */
@@ -3510,6 +3519,7 @@ static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request
 static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
 	struct nfs_client *clp = state->owner->so_client;
+	struct nfs_inode *nfsi = NFS_I(state->inode);
 	unsigned char fl_flags = request->fl_flags;
 	int status;
 
@@ -3522,18 +3532,13 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 	if (status < 0)
 		goto out;
 	down_read(&clp->cl_sem);
+	down_read(&nfsi->rwsem);
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags)) {
-		struct nfs_inode *nfsi = NFS_I(state->inode);
 		/* Yes: cache locks! */
-		down_read(&nfsi->rwsem);
 		/* ...but avoid races with delegation recall... */
-		if (test_bit(NFS_DELEGATED_STATE, &state->flags)) {
-			request->fl_flags = fl_flags & ~FL_SLEEP;
-			status = do_vfs_lock(request->fl_file, request);
-			up_read(&nfsi->rwsem);
-			goto out_unlock;
-		}
-		up_read(&nfsi->rwsem);
+		request->fl_flags = fl_flags & ~FL_SLEEP;
+		status = do_vfs_lock(request->fl_file, request);
+		goto out_unlock;
 	}
 	status = _nfs4_do_setlk(state, cmd, request, 0);
 	if (status != 0)
@@ -3543,6 +3548,7 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 	if (do_vfs_lock(request->fl_file, request) < 0)
 		printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n", __func__);
 out_unlock:
+	up_read(&nfsi->rwsem);
 	up_read(&clp->cl_sem);
 out:
 	request->fl_flags = fl_flags;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index beade55..16c9fbd 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -849,9 +849,11 @@ static int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_s
 static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_recovery_ops *ops)
 {
 	struct inode *inode = state->inode;
+	struct nfs_inode *nfsi = NFS_I(inode);
 	struct file_lock *fl;
 	int status = 0;
 
+	down_write(&nfsi->rwsem);
 	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
 		if (!(fl->fl_flags & (FL_POSIX|FL_FLOCK)))
 			continue;
@@ -874,8 +876,10 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
 				goto out_err;
 		}
 	}
+	up_write(&nfsi->rwsem);
 	return 0;
 out_err:
+	up_write(&nfsi->rwsem);
 	return status;
 }
 

