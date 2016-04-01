Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41635 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751845AbcDAPew (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Apr 2016 11:34:52 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFSv4: use OFD lock owners in lock state lookup
Date: Fri,  1 Apr 2016 11:34:50 -0400
Message-Id: <1ee3ea73d822cf3d5cc6f8c4e7f71a55a686cf9f.1459512820.git.bcodding@redhat.com>
In-Reply-To: <cover.1459512819.git.bcodding@redhat.com>
References: <cover.1459512819.git.bcodding@redhat.com>
In-Reply-To: <cover.1459512819.git.bcodding@redhat.com>
References: <cover.1459512819.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that our lock context contains owners for OFD locks we can use those
owners to reference an appropriate nfs4_lock_state.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4state.c |   21 ++++++++++++---------
 fs/nfs/pagelist.c  |    1 +
 fs/nfs/write.c     |    1 +
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index b7f4509..c602e8f 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -800,14 +800,16 @@ void nfs4_close_sync(struct nfs4_state *state, fmode_t fmode)
  * that is compatible with current->files
  */
 static struct nfs4_lock_state *
-__nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner)
+__nfs4_find_lock_state(struct nfs4_state *state,
+		const struct nfs_lockowner *lockowner)
 {
 	struct nfs4_lock_state *pos;
 	list_for_each_entry(pos, &state->lock_states, ls_locks) {
-		if (pos->ls_owner != fl_owner)
-			continue;
-		atomic_inc(&pos->ls_count);
-		return pos;
+		if (pos->ls_owner == lockowner->l_owner_posix ||
+			pos->ls_owner == lockowner->l_owner_ofd) {
+			atomic_inc(&pos->ls_count);
+			return pos;
+		}
 	}
 	return NULL;
 }
@@ -854,10 +856,13 @@ void nfs4_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp
 static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, fl_owner_t owner)
 {
 	struct nfs4_lock_state *lsp, *new = NULL;
+	const struct nfs_lockowner lockowner = {
+		.l_owner_posix = owner,
+	};
 	
 	for(;;) {
 		spin_lock(&state->state_lock);
-		lsp = __nfs4_find_lock_state(state, owner);
+		lsp = __nfs4_find_lock_state(state, &lockowner);
 		if (lsp != NULL)
 			break;
 		if (new != NULL) {
@@ -942,7 +947,6 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 		const struct nfs_lockowner *lockowner)
 {
 	struct nfs4_lock_state *lsp;
-	fl_owner_t fl_owner;
 	int ret = -ENOENT;
 
 
@@ -952,9 +956,8 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 	if (test_bit(LK_STATE_IN_USE, &state->flags) == 0)
 		goto out;
 
-	fl_owner = lockowner->l_owner_posix;
 	spin_lock(&state->state_lock);
-	lsp = __nfs4_find_lock_state(state, fl_owner);
+	lsp = __nfs4_find_lock_state(state, lockowner);
 	if (lsp && test_bit(NFS_LOCK_LOST, &lsp->ls_flags))
 		ret = -EIO;
 	else if (lsp != NULL && test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) != 0) {
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 2b28dff..3579638 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -859,6 +859,7 @@ static bool nfs_match_lock_context(const struct nfs_lock_context *l1,
 		const struct nfs_lock_context *l2)
 {
 	return l1->lockowner.l_owner_posix == l2->lockowner.l_owner_posix
+		&& l1->lockowner.l_owner_ofd == l2->lockowner.l_owner_ofd
 		&& l1->lockowner.l_pid == l2->lockowner.l_pid;
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 935244c..2d01d6c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1162,6 +1162,7 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 		    !(list_empty_careful(&flctx->flc_posix) &&
 		      list_empty_careful(&flctx->flc_flock))) {
 			do_flush |= l_ctx->lockowner.l_owner_posix != current->files
+				|| l_ctx->lockowner.l_owner_ofd != file
 				|| l_ctx->lockowner.l_pid != current->tgid;
 		}
 		nfs_release_request(req);
-- 
1.7.1

