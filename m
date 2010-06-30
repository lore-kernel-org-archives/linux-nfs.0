From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 5/5] NFSv4: Ensure the lockowners are labelled using the fl_owner and/or fl_pid
Date: Wed, 30 Jun 2010 17:25:37 -0400
Message-ID: <1277933137-6955-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1277933137-6955-1-git-send-email-Trond.Myklebust@netapp.com>
 <1277933137-6955-2-git-send-email-Trond.Myklebust@netapp.com>
 <1277933137-6955-3-git-send-email-Trond.Myklebust@netapp.com>
 <1277933137-6955-4-git-send-email-Trond.Myklebust@netapp.com>
 <1277933137-6955-5-git-send-email-Trond.Myklebust@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6636 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757305Ab0F3VZ4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jun 2010 17:25:56 -0400
In-Reply-To: <1277933137-6955-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

flock locks want to be labelled using the process pid, while posix locks
want to be labelled using the fl_owner.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   |   15 +++++++++++++--
 fs/nfs/nfs4proc.c  |    2 +-
 fs/nfs/nfs4state.c |   45 +++++++++++++++++++++++++++++++++++----------
 fs/nfs/nfs4xdr.c   |    2 +-
 4 files changed, 50 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index deaf37f..311e15c 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -142,10 +142,20 @@ enum {
  * LOCK: one nfs4_state (LOCK) to hold the lock stateid nfs4_state(OPEN)
  */
 
+struct nfs4_lock_owner {
+	unsigned int lo_type;
+#define NFS4_ANY_LOCK_TYPE	(0U)
+#define NFS4_FLOCK_LOCK_TYPE	(1U << 0)
+#define NFS4_POSIX_LOCK_TYPE	(1U << 1)
+	union {
+		fl_owner_t posix_owner;
+		pid_t flock_owner;
+	} lo_u;
+};
+
 struct nfs4_lock_state {
 	struct list_head	ls_locks;	/* Other lock stateids */
 	struct nfs4_state *	ls_state;	/* Pointer to open state */
-	fl_owner_t		ls_owner;	/* POSIX lock owner */
 #define NFS_LOCK_INITIALIZED 1
 	int			ls_flags;
 	struct nfs_seqid_counter	ls_seqid;
@@ -153,6 +163,7 @@ struct nfs4_lock_state {
 	struct nfs_unique_id	ls_id;
 	nfs4_stateid		ls_stateid;
 	atomic_t		ls_count;
+	struct nfs4_lock_owner	ls_owner;
 };
 
 /* bits for nfs4_state->flags */
@@ -310,7 +321,7 @@ extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
 extern void nfs41_handle_recall_slot(struct nfs_client *clp);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
-extern void nfs4_copy_stateid(nfs4_stateid *, struct nfs4_state *, fl_owner_t);
+extern void nfs4_copy_stateid(nfs4_stateid *, struct nfs4_state *, fl_owner_t, pid_t);
 
 extern struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_mask);
 extern int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5d3e8a2..d6413b4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1767,7 +1767,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	if (nfs4_copy_delegation_stateid(&arg.stateid, inode)) {
 		/* Use that stateid */
 	} else if (state != NULL) {
-		nfs4_copy_stateid(&arg.stateid, state, current->files);
+		nfs4_copy_stateid(&arg.stateid, state, current->files, current->tgid);
 	} else
 		memcpy(&arg.stateid, &zero_stateid, sizeof(arg.stateid));
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 13a4f27..3e2f19b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -602,12 +602,21 @@ void nfs4_close_sync(struct path *path, struct nfs4_state *state, fmode_t fmode)
  * that is compatible with current->files
  */
 static struct nfs4_lock_state *
-__nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner)
+__nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner, pid_t fl_pid, unsigned int type)
 {
 	struct nfs4_lock_state *pos;
 	list_for_each_entry(pos, &state->lock_states, ls_locks) {
-		if (pos->ls_owner != fl_owner)
+		if (type != NFS4_ANY_LOCK_TYPE && pos->ls_owner.lo_type != type)
 			continue;
+		switch (pos->ls_owner.lo_type) {
+		case NFS4_POSIX_LOCK_TYPE:
+			if (pos->ls_owner.lo_u.posix_owner != fl_owner)
+				continue;
+			break;
+		case NFS4_FLOCK_LOCK_TYPE:
+			if (pos->ls_owner.lo_u.flock_owner != fl_pid)
+				continue;
+		}
 		atomic_inc(&pos->ls_count);
 		return pos;
 	}
@@ -619,7 +628,7 @@ __nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner)
  * exists, return an uninitialized one.
  *
  */
-static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, fl_owner_t fl_owner)
+static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, fl_owner_t fl_owner, pid_t fl_pid, unsigned int type)
 {
 	struct nfs4_lock_state *lsp;
 	struct nfs_client *clp = state->owner->so_server->nfs_client;
@@ -633,7 +642,18 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
 	lsp->ls_seqid.sequence = &lsp->ls_sequence;
 	atomic_set(&lsp->ls_count, 1);
 	lsp->ls_state = state;
-	lsp->ls_owner = fl_owner;
+	lsp->ls_owner.lo_type = type;
+	switch (lsp->ls_owner.lo_type) {
+	case NFS4_FLOCK_LOCK_TYPE:
+		lsp->ls_owner.lo_u.flock_owner = fl_pid;
+		break;
+	case NFS4_POSIX_LOCK_TYPE:
+		lsp->ls_owner.lo_u.posix_owner = fl_owner;
+		break;
+	default:
+		kfree(lsp);
+		return NULL;
+	}
 	spin_lock(&clp->cl_lock);
 	nfs_alloc_unique_id(&clp->cl_lockowner_id, &lsp->ls_id, 1, 64);
 	spin_unlock(&clp->cl_lock);
@@ -657,13 +677,13 @@ static void nfs4_free_lock_state(struct nfs4_lock_state *lsp)
  * exists, return an uninitialized one.
  *
  */
-static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, fl_owner_t owner)
+static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, fl_owner_t owner, pid_t pid, unsigned int type)
 {
 	struct nfs4_lock_state *lsp, *new = NULL;
 	
 	for(;;) {
 		spin_lock(&state->state_lock);
-		lsp = __nfs4_find_lock_state(state, owner);
+		lsp = __nfs4_find_lock_state(state, owner, pid, type);
 		if (lsp != NULL)
 			break;
 		if (new != NULL) {
@@ -674,7 +694,7 @@ static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, fl_
 			break;
 		}
 		spin_unlock(&state->state_lock);
-		new = nfs4_alloc_lock_state(state, owner);
+		new = nfs4_alloc_lock_state(state, owner, pid, type);
 		if (new == NULL)
 			return NULL;
 	}
@@ -730,7 +750,12 @@ int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl)
 
 	if (fl->fl_ops != NULL)
 		return 0;
-	lsp = nfs4_get_lock_state(state, fl->fl_owner);
+	if (fl->fl_flags & FL_POSIX)
+		lsp = nfs4_get_lock_state(state, fl->fl_owner, 0, NFS4_POSIX_LOCK_TYPE);
+	else if (fl->fl_flags & FL_FLOCK)
+		lsp = nfs4_get_lock_state(state, 0, fl->fl_pid, NFS4_FLOCK_LOCK_TYPE);
+	else
+		return -EINVAL;
 	if (lsp == NULL)
 		return -ENOMEM;
 	fl->fl_u.nfs4_fl.owner = lsp;
@@ -742,7 +767,7 @@ int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl)
  * Byte-range lock aware utility to initialize the stateid of read/write
  * requests.
  */
-void nfs4_copy_stateid(nfs4_stateid *dst, struct nfs4_state *state, fl_owner_t fl_owner)
+void nfs4_copy_stateid(nfs4_stateid *dst, struct nfs4_state *state, fl_owner_t fl_owner, pid_t fl_pid)
 {
 	struct nfs4_lock_state *lsp;
 	int seq;
@@ -755,7 +780,7 @@ void nfs4_copy_stateid(nfs4_stateid *dst, struct nfs4_state *state, fl_owner_t f
 		return;
 
 	spin_lock(&state->state_lock);
-	lsp = __nfs4_find_lock_state(state, fl_owner);
+	lsp = __nfs4_find_lock_state(state, fl_owner, fl_pid, NFS4_ANY_LOCK_TYPE);
 	if (lsp != NULL && (lsp->ls_flags & NFS_LOCK_INITIALIZED) != 0)
 		memcpy(dst, &lsp->ls_stateid, sizeof(*dst));
 	spin_unlock(&state->state_lock);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b3e9180..07bc8f1 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1361,7 +1361,7 @@ static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context
 
 	p = reserve_space(xdr, NFS4_STATEID_SIZE);
 	if (ctx->state != NULL) {
-		nfs4_copy_stateid(&stateid, ctx->state, l_ctx->lockowner);
+		nfs4_copy_stateid(&stateid, ctx->state, l_ctx->lockowner, l_ctx->pid);
 		xdr_encode_opaque_fixed(p, stateid.data, NFS4_STATEID_SIZE);
 	} else
 		xdr_encode_opaque_fixed(p, zero_stateid.data, NFS4_STATEID_SIZE);
-- 
1.7.0.1

