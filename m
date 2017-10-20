Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:1670 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752813AbdJTJ4D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Oct 2017 05:56:03 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@poochiereds.net, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 09/11] fs, nfs: convert nfs4_lock_state.ls_count from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 12:53:36 +0300
Message-Id: <1508493218-27760-10-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1508493218-27760-1-git-send-email-elena.reshetova@intel.com>
References: <1508493218-27760-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable nfs4_lock_state.ls_count  is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 fs/nfs/nfs4_fs.h   | 2 +-
 fs/nfs/nfs4proc.c  | 6 +++---
 fs/nfs/nfs4state.c | 8 ++++----
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ac4f10b..29409a8 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -144,7 +144,7 @@ struct nfs4_lock_state {
 	unsigned long		ls_flags;
 	struct nfs_seqid_counter	ls_seqid;
 	nfs4_stateid		ls_stateid;
-	atomic_t		ls_count;
+	refcount_t		ls_count;
 	fl_owner_t		ls_owner;
 };
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f90090e..57c38ea 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2518,7 +2518,7 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
 		if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
 			struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
 
-			atomic_inc(&lsp->ls_count);
+			refcount_inc(&lsp->ls_count);
 			spin_unlock(&state->state_lock);
 
 			nfs4_put_lock_state(prev);
@@ -5896,7 +5896,7 @@ static struct nfs4_unlockdata *nfs4_alloc_unlockdata(struct file_lock *fl,
 	p->arg.seqid = seqid;
 	p->res.seqid = seqid;
 	p->lsp = lsp;
-	atomic_inc(&lsp->ls_count);
+	refcount_inc(&lsp->ls_count);
 	/* Ensure we don't close file until we're done freeing locks! */
 	p->ctx = get_nfs_open_context(ctx);
 	p->l_ctx = nfs_get_lock_context(ctx);
@@ -6112,7 +6112,7 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 	p->res.lock_seqid = p->arg.lock_seqid;
 	p->lsp = lsp;
 	p->server = server;
-	atomic_inc(&lsp->ls_count);
+	refcount_inc(&lsp->ls_count);
 	p->ctx = get_nfs_open_context(ctx);
 	memcpy(&p->fl, fl, sizeof(p->fl));
 	return p;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 0378e225..1887134 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -825,7 +825,7 @@ __nfs4_find_lock_state(struct nfs4_state *state,
 			ret = pos;
 	}
 	if (ret)
-		atomic_inc(&ret->ls_count);
+		refcount_inc(&ret->ls_count);
 	return ret;
 }
 
@@ -843,7 +843,7 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
 	if (lsp == NULL)
 		return NULL;
 	nfs4_init_seqid_counter(&lsp->ls_seqid);
-	atomic_set(&lsp->ls_count, 1);
+	refcount_set(&lsp->ls_count, 1);
 	lsp->ls_state = state;
 	lsp->ls_owner = fl_owner;
 	lsp->ls_seqid.owner_id = ida_simple_get(&server->lockowner_id, 0, 0, GFP_NOFS);
@@ -907,7 +907,7 @@ void nfs4_put_lock_state(struct nfs4_lock_state *lsp)
 	if (lsp == NULL)
 		return;
 	state = lsp->ls_state;
-	if (!atomic_dec_and_lock(&lsp->ls_count, &state->state_lock))
+	if (!refcount_dec_and_lock(&lsp->ls_count, &state->state_lock))
 		return;
 	list_del(&lsp->ls_locks);
 	if (list_empty(&state->lock_states))
@@ -927,7 +927,7 @@ static void nfs4_fl_copy_lock(struct file_lock *dst, struct file_lock *src)
 	struct nfs4_lock_state *lsp = src->fl_u.nfs4_fl.owner;
 
 	dst->fl_u.nfs4_fl.owner = lsp;
-	atomic_inc(&lsp->ls_count);
+	refcount_inc(&lsp->ls_count);
 }
 
 static void nfs4_fl_release_lock(struct file_lock *fl)
-- 
2.7.4

