Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:59939 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932106Ab3BKTal (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2013 14:30:41 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] NFSv4: Ensure delegation recall and byte range lock removal don't conflict
Date: Mon, 11 Feb 2013 14:29:25 -0500
Message-Id: <1360610966-15398-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1360610966-15398-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1360610966-15398-1-git-send-email-Trond.Myklebust@netapp.com>
 <1360610966-15398-2-git-send-email-Trond.Myklebust@netapp.com>
 <1360610966-15398-3-git-send-email-Trond.Myklebust@netapp.com>
 <1360610966-15398-4-git-send-email-Trond.Myklebust@netapp.com>
 <1360610966-15398-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a mutex to the struct nfs4_state_owner to ensure that delegation
recall doesn't conflict with byte range lock removal.

Note that we nest the new mutex _outside_ the state manager reclaim
protection (nfsi->rwsem) in order to avoid deadlocks.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/delegation.c | 7 ++++++-
 fs/nfs/nfs4_fs.h    | 1 +
 fs/nfs/nfs4proc.c   | 9 ++++++++-
 fs/nfs/nfs4state.c  | 1 +
 4 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 2542cda..6390a4b 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -71,8 +71,10 @@ static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_
 	int status = 0;
 
 	if (inode->i_flock == NULL)
-		goto out;
+		return 0;
 
+	if (inode->i_flock == NULL)
+		goto out;
 	/* Protect inode->i_flock using the file locks lock */
 	lock_flocks();
 	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
@@ -113,12 +115,15 @@ again:
 		get_nfs_open_context(ctx);
 		spin_unlock(&inode->i_lock);
 		sp = state->owner;
+		/* Block nfs4_proc_unlck */
+		mutex_lock(&sp->so_delegreturn_mutex);
 		seq = raw_seqcount_begin(&sp->so_reclaim_seqcount);
 		err = nfs4_open_delegation_recall(ctx, state, stateid);
 		if (!err)
 			err = nfs_delegation_claim_locks(ctx, state);
 		if (!err && read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
 			err = -EAGAIN;
+		mutex_unlock(&sp->so_delegreturn_mutex);
 		put_nfs_open_context(ctx);
 		if (err != 0)
 			return err;
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b12b734..944c9a5 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -93,6 +93,7 @@ struct nfs4_state_owner {
 	struct list_head     so_states;
 	struct nfs_seqid_counter so_seqid;
 	seqcount_t	     so_reclaim_seqcount;
+	struct mutex	     so_delegreturn_mutex;
 };
 
 enum {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f7e05ad..d512273 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4485,7 +4485,9 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 
 static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
-	struct nfs_inode *nfsi = NFS_I(state->inode);
+	struct inode *inode = state->inode;
+	struct nfs4_state_owner *sp = state->owner;
+	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_seqid *seqid;
 	struct nfs4_lock_state *lsp;
 	struct rpc_task *task;
@@ -4495,12 +4497,17 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	status = nfs4_set_lock_state(state, request);
 	/* Unlock _before_ we do the RPC call */
 	request->fl_flags |= FL_EXISTS;
+	/* Exclude nfs_delegation_claim_locks() */
+	mutex_lock(&sp->so_delegreturn_mutex);
+	/* Exclude nfs4_reclaim_open_stateid() - note nesting! */
 	down_read(&nfsi->rwsem);
 	if (do_vfs_lock(request->fl_file, request) == -ENOENT) {
 		up_read(&nfsi->rwsem);
+		mutex_unlock(&sp->so_delegreturn_mutex);
 		goto out;
 	}
 	up_read(&nfsi->rwsem);
+	mutex_unlock(&sp->so_delegreturn_mutex);
 	if (status != 0)
 		goto out;
 	/* Is this a delegated lock? */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 77ba619..c96754b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -519,6 +519,7 @@ nfs4_alloc_state_owner(struct nfs_server *server,
 	atomic_set(&sp->so_count, 1);
 	INIT_LIST_HEAD(&sp->so_lru);
 	seqcount_init(&sp->so_reclaim_seqcount);
+	mutex_init(&sp->so_delegreturn_mutex);
 	return sp;
 }
 
-- 
1.8.1.2

