Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:33983 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbcEPVnS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2016 17:43:18 -0400
Received: by mail-qg0-f51.google.com with SMTP id 90so96469061qgz.1
        for <linux-nfs@vger.kernel.org>; Mon, 16 May 2016 14:43:17 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/4] NFSv4: Use the right stateid for delegations in setattr, read and write
Date: Mon, 16 May 2016 17:42:44 -0400
Message-Id: <1463434965-44877-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1463434965-44877-2-git-send-email-trond.myklebust@primarydata.com>
References: <1463434965-44877-1-git-send-email-trond.myklebust@primarydata.com>
 <1463434965-44877-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we're using a delegation to represent our open state, we should
ensure that we use the stateid that was used to create that delegation.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c |  9 ++++++---
 fs/nfs/delegation.h |  2 +-
 fs/nfs/nfs4_fs.h    |  5 +++--
 fs/nfs/nfs4proc.c   | 13 +++++++++----
 fs/nfs/nfs4state.c  | 13 +++++++++----
 5 files changed, 28 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 5166adcfc0fb..322c2585bc34 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -875,15 +875,16 @@ int nfs_delegations_present(struct nfs_client *clp)
 
 /**
  * nfs4_copy_delegation_stateid - Copy inode's state ID information
- * @dst: stateid data structure to fill in
  * @inode: inode to check
  * @flags: delegation type requirement
+ * @dst: stateid data structure to fill in
+ * @cred: optional argument to retrieve credential
  *
  * Returns "true" and fills in "dst->data" * if inode had a delegation,
  * otherwise "false" is returned.
  */
-bool nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode,
-		fmode_t flags)
+bool nfs4_copy_delegation_stateid(struct inode *inode, fmode_t flags,
+		nfs4_stateid *dst, struct rpc_cred **cred)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_delegation *delegation;
@@ -896,6 +897,8 @@ bool nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode,
 	if (ret) {
 		nfs4_stateid_copy(dst, &delegation->stateid);
 		nfs_mark_delegation_referenced(delegation);
+		if (cred)
+			*cred = get_rpccred(delegation->cred);
 	}
 	rcu_read_unlock();
 	return ret;
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 333063e032f0..64724d252a79 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -56,7 +56,7 @@ void nfs_delegation_reap_unclaimed(struct nfs_client *clp);
 int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid, int issync);
 int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid, fmode_t type);
 int nfs4_lock_delegation_recall(struct file_lock *fl, struct nfs4_state *state, const nfs4_stateid *stateid);
-bool nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode, fmode_t flags);
+bool nfs4_copy_delegation_stateid(struct inode *inode, fmode_t flags, nfs4_stateid *dst, struct rpc_cred **cred);
 
 void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
 int nfs4_have_delegation(struct inode *inode, fmode_t flags);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b5d9f345c9f2..768456fa1b17 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -438,8 +438,9 @@ extern void nfs41_handle_server_scope(struct nfs_client *,
 				      struct nfs41_server_scope **);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
-extern int nfs4_select_rw_stateid(nfs4_stateid *, struct nfs4_state *,
-		fmode_t, const struct nfs_lockowner *);
+extern int nfs4_select_rw_stateid(struct nfs4_state *, fmode_t,
+		const struct nfs_lockowner *, nfs4_stateid *,
+		struct rpc_cred **);
 
 extern struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_mask);
 extern int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9cc6d28101ac..eba6a2e8677c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2676,6 +2676,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 		.rpc_resp	= &res,
 		.rpc_cred	= cred,
         };
+	struct rpc_cred *delegation_cred = NULL;
 	unsigned long timestamp = jiffies;
 	fmode_t fmode;
 	bool truncate;
@@ -2691,7 +2692,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	truncate = (sattr->ia_valid & ATTR_SIZE) ? true : false;
 	fmode = truncate ? FMODE_WRITE : FMODE_READ;
 
-	if (nfs4_copy_delegation_stateid(&arg.stateid, inode, fmode)) {
+	if (nfs4_copy_delegation_stateid(inode, fmode, &arg.stateid, &delegation_cred)) {
 		/* Use that stateid */
 	} else if (truncate && state != NULL) {
 		struct nfs_lockowner lockowner = {
@@ -2700,13 +2701,17 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 		};
 		if (!nfs4_valid_open_stateid(state))
 			return -EBADF;
-		if (nfs4_select_rw_stateid(&arg.stateid, state, FMODE_WRITE,
-				&lockowner) == -EIO)
+		if (nfs4_select_rw_stateid(state, FMODE_WRITE, &lockowner,
+				&arg.stateid, &delegation_cred) == -EIO)
 			return -EBADF;
 	} else
 		nfs4_stateid_copy(&arg.stateid, &zero_stateid);
+	if (delegation_cred)
+		msg.rpc_cred = delegation_cred;
 
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
+
+	put_rpccred(delegation_cred);
 	if (status == 0 && state != NULL)
 		renew_lease(server, timestamp);
 	trace_nfs4_setattr(inode, &arg.stateid, status);
@@ -4285,7 +4290,7 @@ int nfs4_set_rw_stateid(nfs4_stateid *stateid,
 
 	if (l_ctx != NULL)
 		lockowner = &l_ctx->lockowner;
-	return nfs4_select_rw_stateid(stateid, ctx->state, fmode, lockowner);
+	return nfs4_select_rw_stateid(ctx->state, fmode, lockowner, stateid, NULL);
 }
 EXPORT_SYMBOL_GPL(nfs4_set_rw_stateid);
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index d630f9cca0f1..5075592df145 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -988,15 +988,20 @@ static void nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
  * Byte-range lock aware utility to initialize the stateid of read/write
  * requests.
  */
-int nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state,
-		fmode_t fmode, const struct nfs_lockowner *lockowner)
+int nfs4_select_rw_stateid(struct nfs4_state *state,
+		fmode_t fmode, const struct nfs_lockowner *lockowner,
+		nfs4_stateid *dst, struct rpc_cred **cred)
 {
-	int ret = nfs4_copy_lock_stateid(dst, state, lockowner);
+	int ret;
+
+	if (cred != NULL)
+		*cred = NULL;
+	ret = nfs4_copy_lock_stateid(dst, state, lockowner);
 	if (ret == -EIO)
 		/* A lost lock - don't even consider delegations */
 		goto out;
 	/* returns true if delegation stateid found and copied */
-	if (nfs4_copy_delegation_stateid(dst, state->inode, fmode)) {
+	if (nfs4_copy_delegation_stateid(state->inode, fmode, dst, cred)) {
 		ret = 0;
 		goto out;
 	}
-- 
2.5.5

