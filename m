Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63979 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750849AbdCNHHv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 03:07:51 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
Subject: [PATCH 09/12] fs, nfs: convert nfs4_lock_state.ls_count from atomic_t to refcount_t
Date: Tue, 14 Mar 2017 09:07:17 +0200
Message-Id: <1489475240-6594-10-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
References: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 fs/nfs/nfs4_fs.h   | 2 +-
 fs/nfs/nfs4proc.c  | 6 +++---
 fs/nfs/nfs4state.c | 8 ++++----
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 6651658..e62ed94 100644
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
index 0a0eaec..2c85c9f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2597,7 +2597,7 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
 		if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
 			struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
 
-			atomic_inc(&lsp->ls_count);
+			refcount_inc(&lsp->ls_count);
 			spin_unlock(&state->state_lock);
 
 			nfs4_put_lock_state(prev);
@@ -5927,7 +5927,7 @@ static struct nfs4_unlockdata *nfs4_alloc_unlockdata(struct file_lock *fl,
 	p->arg.seqid = seqid;
 	p->res.seqid = seqid;
 	p->lsp = lsp;
-	atomic_inc(&lsp->ls_count);
+	refcount_inc(&lsp->ls_count);
 	/* Ensure we don't close file until we're done freeing locks! */
 	p->ctx = get_nfs_open_context(ctx);
 	memcpy(&p->fl, fl, sizeof(p->fl));
@@ -6135,7 +6135,7 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 	p->res.lock_seqid = p->arg.lock_seqid;
 	p->lsp = lsp;
 	p->server = server;
-	atomic_inc(&lsp->ls_count);
+	refcount_inc(&lsp->ls_count);
 	p->ctx = get_nfs_open_context(ctx);
 	memcpy(&p->fl, fl, sizeof(p->fl));
 	return p;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index daeb94e..347cb18 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -819,7 +819,7 @@ __nfs4_find_lock_state(struct nfs4_state *state,
 			ret = pos;
 	}
 	if (ret)
-		atomic_inc(&ret->ls_count);
+		refcount_inc(&ret->ls_count);
 	return ret;
 }
 
@@ -837,7 +837,7 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
 	if (lsp == NULL)
 		return NULL;
 	nfs4_init_seqid_counter(&lsp->ls_seqid);
-	atomic_set(&lsp->ls_count, 1);
+	refcount_set(&lsp->ls_count, 1);
 	lsp->ls_state = state;
 	lsp->ls_owner = fl_owner;
 	lsp->ls_seqid.owner_id = ida_simple_get(&server->lockowner_id, 0, 0, GFP_NOFS);
@@ -901,7 +901,7 @@ void nfs4_put_lock_state(struct nfs4_lock_state *lsp)
 	if (lsp == NULL)
 		return;
 	state = lsp->ls_state;
-	if (!atomic_dec_and_lock(&lsp->ls_count, &state->state_lock))
+	if (!refcount_dec_and_lock(&lsp->ls_count, &state->state_lock))
 		return;
 	list_del(&lsp->ls_locks);
 	if (list_empty(&state->lock_states))
@@ -921,7 +921,7 @@ static void nfs4_fl_copy_lock(struct file_lock *dst, struct file_lock *src)
 	struct nfs4_lock_state *lsp = src->fl_u.nfs4_fl.owner;
 
 	dst->fl_u.nfs4_fl.owner = lsp;
-	atomic_inc(&lsp->ls_count);
+	refcount_inc(&lsp->ls_count);
 }
 
 static void nfs4_fl_release_lock(struct file_lock *fl)
-- 
2.7.4

