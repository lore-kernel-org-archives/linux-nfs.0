Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>
Date: Thu, 13 Oct 2016 15:26:47 +1100
Subject: [PATCH 4/6] NFSv4: change nfs4_select_rw_stateid to take a
 lock_context inplace of lock_owner
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <147633280750.766.16214787133000729977.stgit@noble>
In-Reply-To: <147633263771.766.17853370901003798934.stgit@noble>
References: <147633263771.766.17853370901003798934.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
List-ID: <linux-nfs.vger.kernel.org>

The only time that a lock_context is not immediately available is in
setattr, and now that it has an open_context, it can easily find one
with nfs_get_lock_context.
This removes the need for the on-stack nfs_lockowner.

This change is preparation for correctly support flock stateids.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/nfs4_fs.h   |    2 +-
 fs/nfs/nfs4proc.c  |   15 ++++++---------
 fs/nfs/nfs4state.c |   11 +++++------
 3 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9b3a82abab07..7784b79915e1 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -457,7 +457,7 @@ extern void nfs41_handle_server_scope(struct nfs_client *,
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
 extern int nfs4_select_rw_stateid(struct nfs4_state *, fmode_t,
-		const struct nfs_lockowner *, nfs4_stateid *,
+		const struct nfs_lock_context *, nfs4_stateid *,
 		struct rpc_cred **);
 
 extern struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_mask);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 950b25413bb4..3c2f11189794 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2926,12 +2926,13 @@ static int _nfs4_do_setattr(struct inode *inode,
 	if (nfs4_copy_delegation_stateid(inode, fmode, &arg->stateid, &delegation_cred)) {
 		/* Use that stateid */
 	} else if (truncate && ctx != NULL) {
-		struct nfs_lockowner lockowner = {
-			.l_owner = current->files,
-		};
+		struct nfs_lock_context *l_ctx;
 		if (!nfs4_valid_open_stateid(ctx->state))
 			return -EBADF;
-		if (nfs4_select_rw_stateid(ctx->state, FMODE_WRITE, &lockowner,
+		l_ctx = nfs_get_lock_context(ctx);
+		if (IS_ERR(l_ctx))
+			return PTR_ERR(l_ctx);
+		if (nfs4_select_rw_stateid(ctx->state, FMODE_WRITE, l_ctx,
 				&arg->stateid, &delegation_cred) == -EIO)
 			return -EBADF;
 	} else
@@ -4525,11 +4526,7 @@ int nfs4_set_rw_stateid(nfs4_stateid *stateid,
 		const struct nfs_lock_context *l_ctx,
 		fmode_t fmode)
 {
-	const struct nfs_lockowner *lockowner = NULL;
-
-	if (l_ctx != NULL)
-		lockowner = &l_ctx->lockowner;
-	return nfs4_select_rw_stateid(ctx->state, fmode, lockowner, stateid, NULL);
+	return nfs4_select_rw_stateid(ctx->state, fmode, l_ctx, stateid, NULL);
 }
 EXPORT_SYMBOL_GPL(nfs4_set_rw_stateid);
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5f4281ec5f72..f25eee8202bf 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -939,20 +939,19 @@ int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl)
 
 static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 		struct nfs4_state *state,
-		const struct nfs_lockowner *lockowner)
+		const struct nfs_lock_context *l_ctx)
 {
 	struct nfs4_lock_state *lsp;
 	fl_owner_t fl_owner;
 	int ret = -ENOENT;
 
-
-	if (lockowner == NULL)
+	if (l_ctx == NULL)
 		goto out;
 
 	if (test_bit(LK_STATE_IN_USE, &state->flags) == 0)
 		goto out;
 
-	fl_owner = lockowner->l_owner;
+	fl_owner = l_ctx->lockowner.l_owner;
 	spin_lock(&state->state_lock);
 	lsp = __nfs4_find_lock_state(state, fl_owner);
 	if (lsp && test_bit(NFS_LOCK_LOST, &lsp->ls_flags))
@@ -986,7 +985,7 @@ static void nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
  * requests.
  */
 int nfs4_select_rw_stateid(struct nfs4_state *state,
-		fmode_t fmode, const struct nfs_lockowner *lockowner,
+		fmode_t fmode, const struct nfs_lock_context *l_ctx,
 		nfs4_stateid *dst, struct rpc_cred **cred)
 {
 	int ret;
@@ -995,7 +994,7 @@ int nfs4_select_rw_stateid(struct nfs4_state *state,
 		return -EIO;
 	if (cred != NULL)
 		*cred = NULL;
-	ret = nfs4_copy_lock_stateid(dst, state, lockowner);
+	ret = nfs4_copy_lock_stateid(dst, state, l_ctx);
 	if (ret == -EIO)
 		/* A lost lock - don't even consider delegations */
 		goto out;
