Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50307 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751082Ab2CJRWZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 10 Mar 2012 12:22:25 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/2] NFSv4: Clean up nfs4_select_rw_stateid()
Date: Sat, 10 Mar 2012 12:21:45 -0500
Message-Id: <1331400105-17204-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1331400105-17204-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1331400105-17204-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we select delegation stateids first, then
lock stateids and then open stateids.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
v2: Simplify the mode arguments. Use either FMODE_READ or FMODE_WRITE
    depending on whether we're reading or writing.

 fs/nfs/nfs4_fs.h   |    3 ++-
 fs/nfs/nfs4proc.c  |    8 +++++---
 fs/nfs/nfs4state.c |   45 +++++++++++++++++++++++++++++++++------------
 fs/nfs/nfs4xdr.c   |   13 +++++++++----
 4 files changed, 49 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index d1989e3..b47bdb9 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -330,7 +330,8 @@ extern void nfs41_handle_server_scope(struct nfs_client *,
 				      struct server_scope **);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
-extern void nfs4_select_rw_stateid(nfs4_stateid *, struct nfs4_state *, fl_owner_t, pid_t);
+extern void nfs4_select_rw_stateid(nfs4_stateid *, struct nfs4_state *,
+		fmode_t, fl_owner_t, pid_t);
 
 extern struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_mask);
 extern int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3578ad3..3bf5593 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1929,10 +1929,12 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 
 	nfs_fattr_init(fattr);
 
-	if (nfs4_copy_delegation_stateid(&arg.stateid, inode, FMODE_WRITE)) {
+	if (state != NULL) {
+		nfs4_select_rw_stateid(&arg.stateid, state, FMODE_WRITE,
+				current->files, current->tgid);
+	} else if (nfs4_copy_delegation_stateid(&arg.stateid, inode,
+				FMODE_WRITE)) {
 		/* Use that stateid */
-	} else if (state != NULL) {
-		nfs4_select_rw_stateid(&arg.stateid, state, current->files, current->tgid);
 	} else
 		nfs4_stateid_copy(&arg.stateid, &zero_stateid);
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 7adc46b..de44804 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -886,28 +886,49 @@ int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl)
 	return 0;
 }
 
-/*
- * Byte-range lock aware utility to initialize the stateid of read/write
- * requests.
- */
-void nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state, fl_owner_t fl_owner, pid_t fl_pid)
+static bool nfs4_copy_lock_stateid(nfs4_stateid *dst, struct nfs4_state *state,
+		fl_owner_t fl_owner, pid_t fl_pid)
 {
 	struct nfs4_lock_state *lsp;
-	int seq;
+	bool ret = false;
 
-	do {
-		seq = read_seqbegin(&state->seqlock);
-		nfs4_stateid_copy(dst, &state->stateid);
-	} while (read_seqretry(&state->seqlock, seq));
 	if (test_bit(LK_STATE_IN_USE, &state->flags) == 0)
-		return;
+		goto out;
 
 	spin_lock(&state->state_lock);
 	lsp = __nfs4_find_lock_state(state, fl_owner, fl_pid, NFS4_ANY_LOCK_TYPE);
-	if (lsp != NULL && (lsp->ls_flags & NFS_LOCK_INITIALIZED) != 0)
+	if (lsp != NULL && (lsp->ls_flags & NFS_LOCK_INITIALIZED) != 0) {
 		nfs4_stateid_copy(dst, &lsp->ls_stateid);
+		ret = true;
+	}
 	spin_unlock(&state->state_lock);
 	nfs4_put_lock_state(lsp);
+out:
+	return ret;
+}
+
+static void nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
+{
+	int seq;
+
+	do {
+		seq = read_seqbegin(&state->seqlock);
+		nfs4_stateid_copy(dst, &state->stateid);
+	} while (read_seqretry(&state->seqlock, seq));
+}
+
+/*
+ * Byte-range lock aware utility to initialize the stateid of read/write
+ * requests.
+ */
+void nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state,
+		fmode_t fmode, fl_owner_t fl_owner, pid_t fl_pid)
+{
+	if (nfs4_copy_delegation_stateid(dst, state->inode, fmode))
+		return;
+	if (nfs4_copy_lock_stateid(dst, state, fl_owner, fl_pid))
+		return;
+	nfs4_copy_open_stateid(dst, state);
 }
 
 struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_mask)
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e4bb8e6..f7e064d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1491,12 +1491,17 @@ static void encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	encode_op_hdr(xdr, OP_PUTROOTFH, decode_putrootfh_maxsz, hdr);
 }
 
-static void encode_open_stateid(struct xdr_stream *xdr, const struct nfs_open_context *ctx, const struct nfs_lock_context *l_ctx, int zero_seqid)
+static void encode_open_stateid(struct xdr_stream *xdr,
+		const struct nfs_open_context *ctx,
+		const struct nfs_lock_context *l_ctx,
+		fmode_t fmode,
+		int zero_seqid)
 {
 	nfs4_stateid stateid;
 
 	if (ctx->state != NULL) {
-		nfs4_select_rw_stateid(&stateid, ctx->state, l_ctx->lockowner, l_ctx->pid);
+		nfs4_select_rw_stateid(&stateid, ctx->state,
+				fmode, l_ctx->lockowner, l_ctx->pid);
 		if (zero_seqid)
 			stateid.seqid = 0;
 		encode_nfs4_stateid(xdr, &stateid);
@@ -1510,7 +1515,7 @@ static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args,
 
 	encode_op_hdr(xdr, OP_READ, decode_read_maxsz, hdr);
 	encode_open_stateid(xdr, args->context, args->lock_context,
-		       hdr->minorversion);
+			FMODE_READ, hdr->minorversion);
 
 	p = reserve_space(xdr, 12);
 	p = xdr_encode_hyper(p, args->offset);
@@ -1648,7 +1653,7 @@ static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 
 	encode_op_hdr(xdr, OP_WRITE, decode_write_maxsz, hdr);
 	encode_open_stateid(xdr, args->context, args->lock_context,
-		       hdr->minorversion);
+			FMODE_WRITE, hdr->minorversion);
 
 	p = reserve_space(xdr, 16);
 	p = xdr_encode_hyper(p, args->offset);
-- 
1.7.7.6

