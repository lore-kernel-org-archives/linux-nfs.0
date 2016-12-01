Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35105 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759828AbcLAWTl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:41 -0500
Received: by mail-io0-f194.google.com with SMTP id h133so4681224ioe.2
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:40 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 16/26] NFSv4: Add encode/decode of the layoutreturn op in CLOSE
Date: Thu,  1 Dec 2016 17:19:12 -0500
Message-Id: <20161201221922.15657-17-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-16-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
 <20161201221922.15657-5-trond.myklebust@primarydata.com>
 <20161201221922.15657-6-trond.myklebust@primarydata.com>
 <20161201221922.15657-7-trond.myklebust@primarydata.com>
 <20161201221922.15657-8-trond.myklebust@primarydata.com>
 <20161201221922.15657-9-trond.myklebust@primarydata.com>
 <20161201221922.15657-10-trond.myklebust@primarydata.com>
 <20161201221922.15657-11-trond.myklebust@primarydata.com>
 <20161201221922.15657-12-trond.myklebust@primarydata.com>
 <20161201221922.15657-13-trond.myklebust@primarydata.com>
 <20161201221922.15657-14-trond.myklebust@primarydata.com>
 <20161201221922.15657-15-trond.myklebust@primarydata.com>
 <20161201221922.15657-16-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add XDR encoding for the layoutreturn op, and storage for the layoutreturn
arguments to the CLOSE compound.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 49 ++++++++++++++++++++++++++++++++++++++++---------
 fs/nfs/nfs4xdr.c        | 26 ++++++++++++++++++++++++++
 include/linux/nfs_xdr.h |  3 +++
 3 files changed, 69 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 87972cfa62bc..9b9b0eabef9b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3035,10 +3035,14 @@ struct nfs4_closedata {
 	struct nfs4_state *state;
 	struct nfs_closeargs arg;
 	struct nfs_closeres res;
+	struct {
+		struct nfs4_layoutreturn_args arg;
+		struct nfs4_layoutreturn_res res;
+		u32 roc_barrier;
+		bool roc;
+	} lr;
 	struct nfs_fattr fattr;
 	unsigned long timestamp;
-	bool roc;
-	u32 roc_barrier;
 };
 
 static void nfs4_free_closedata(void *data)
@@ -3047,7 +3051,7 @@ static void nfs4_free_closedata(void *data)
 	struct nfs4_state_owner *sp = calldata->state->owner;
 	struct super_block *sb = calldata->state->inode->i_sb;
 
-	if (calldata->roc)
+	if (calldata->lr.roc)
 		pnfs_roc_release(calldata->state->inode);
 	nfs4_put_open_state(calldata->state);
 	nfs_free_seqid(calldata->arg.seqid);
@@ -3067,15 +3071,41 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	if (!nfs4_sequence_done(task, &calldata->res.seq_res))
 		return;
 	trace_nfs4_close(state, &calldata->arg, &calldata->res, task->tk_status);
+
+	/* Handle Layoutreturn errors */
+	if (calldata->arg.lr_args && task->tk_status != 0) {
+		switch (calldata->res.lr_ret) {
+		default:
+			calldata->res.lr_ret = -NFS4ERR_NOMATCHING_LAYOUT;
+			break;
+		case 0:
+			calldata->arg.lr_args = NULL;
+			calldata->res.lr_res = NULL;
+			break;
+		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_DELEG_REVOKED:
+		case -NFS4ERR_EXPIRED:
+		case -NFS4ERR_BAD_STATEID:
+		case -NFS4ERR_OLD_STATEID:
+		case -NFS4ERR_UNKNOWN_LAYOUTTYPE:
+		case -NFS4ERR_WRONG_CRED:
+			calldata->arg.lr_args = NULL;
+			calldata->res.lr_res = NULL;
+			calldata->res.lr_ret = 0;
+			rpc_restart_call_prepare(task);
+			return;
+		}
+	}
+
         /* hmm. we are done with the inode, and in the process of freeing
 	 * the state_owner. we keep this around to process errors
 	 */
 	switch (task->tk_status) {
 		case 0:
 			res_stateid = &calldata->res.stateid;
-			if (calldata->roc)
+			if (calldata->lr.roc)
 				pnfs_roc_set_barrier(state->inode,
-						     calldata->roc_barrier);
+						     calldata->lr.roc_barrier);
 			renew_lease(server, calldata->timestamp);
 			break;
 		case -NFS4ERR_ADMIN_REVOKED:
@@ -3151,7 +3181,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		goto out_no_action;
 	}
 
-	if (nfs4_wait_on_layoutreturn(inode, task)) {
+	if (!calldata->arg.lr_args && nfs4_wait_on_layoutreturn(inode, task)) {
 		nfs_release_seqid(calldata->arg.seqid);
 		goto out_wait;
 	}
@@ -3165,8 +3195,8 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		else
 			calldata->arg.bitmask = NULL;
 	}
-	if (calldata->roc)
-		pnfs_roc_get_barrier(inode, &calldata->roc_barrier);
+	if (calldata->lr.roc)
+		pnfs_roc_get_barrier(inode, &calldata->lr.roc_barrier);
 
 	calldata->arg.share_access =
 		nfs4_map_atomic_open_share(NFS_SERVER(inode),
@@ -3250,7 +3280,8 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
-	calldata->roc = nfs4_roc(state->inode);
+	calldata->res.lr_ret = -NFS4ERR_NOMATCHING_LAYOUT;
+	calldata->lr.roc = nfs4_roc(state->inode);
 	nfs_sb_active(calldata->inode->i_sb);
 
 	msg.rpc_argp = &calldata->arg;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 0a82b3fb2d27..73d2a68f0698 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -415,6 +415,8 @@ static int nfs4_stat_to_errno(int);
 #else /* CONFIG_NFS_V4_1 */
 #define encode_sequence_maxsz	0
 #define decode_sequence_maxsz	0
+#define encode_layoutreturn_maxsz 0
+#define decode_layoutreturn_maxsz 0
 #endif /* CONFIG_NFS_V4_1 */
 
 #define NFS4_enc_compound_sz	(1024)  /* XXX: large enough? */
@@ -508,11 +510,13 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_enc_close_sz	(compound_encode_hdr_maxsz + \
 				 encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
+				 encode_layoutreturn_maxsz + \
 				 encode_close_maxsz + \
 				 encode_getattr_maxsz)
 #define NFS4_dec_close_sz	(compound_decode_hdr_maxsz + \
 				 decode_sequence_maxsz + \
 				 decode_putfh_maxsz + \
+				 decode_layoutreturn_maxsz + \
 				 decode_close_maxsz + \
 				 decode_getattr_maxsz)
 #define NFS4_enc_setattr_sz	(compound_encode_hdr_maxsz + \
@@ -2061,6 +2065,13 @@ static void encode_free_stateid(struct xdr_stream *xdr,
 	encode_op_hdr(xdr, OP_FREE_STATEID, decode_free_stateid_maxsz, hdr);
 	encode_nfs4_stateid(xdr, &args->stateid);
 }
+#else
+static inline void
+encode_layoutreturn(struct xdr_stream *xdr,
+		    const struct nfs4_layoutreturn_args *args,
+		    struct compound_hdr *hdr)
+{
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -2248,6 +2259,8 @@ static void nfs4_xdr_enc_close(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
+	if (args->lr_args)
+		encode_layoutreturn(xdr, args->lr_args, &hdr);
 	encode_close(xdr, args, &hdr);
 	if (args->bitmask != NULL)
 		encode_getfattr(xdr, args->bitmask, &hdr);
@@ -6088,6 +6101,13 @@ static int decode_free_stateid(struct xdr_stream *xdr,
 	res->status = decode_op_hdr(xdr, OP_FREE_STATEID);
 	return res->status;
 }
+#else
+static inline
+int decode_layoutreturn(struct xdr_stream *xdr,
+			       struct nfs4_layoutreturn_res *res)
+{
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -6440,6 +6460,12 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_putfh(xdr);
 	if (status)
 		goto out;
+	if (res->lr_res) {
+		status = decode_layoutreturn(xdr, res->lr_res);
+		res->lr_ret = status;
+		if (status)
+			goto out;
+	}
 	status = decode_close(xdr, res);
 	if (status != 0)
 		goto out;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index beb1e10f446e..44ed64bb66ae 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -469,6 +469,7 @@ struct nfs_closeargs {
 	fmode_t			fmode;
 	u32			share_access;
 	const u32 *		bitmask;
+	struct nfs4_layoutreturn_args *lr_args;
 };
 
 struct nfs_closeres {
@@ -477,6 +478,8 @@ struct nfs_closeres {
 	struct nfs_fattr *	fattr;
 	struct nfs_seqid *	seqid;
 	const struct nfs_server *server;
+	struct nfs4_layoutreturn_res *lr_res;
+	int lr_ret;
 };
 /*
  *  * Arguments to the lock,lockt, and locku call.
-- 
2.9.3

