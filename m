From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 36/51] nfsd41: cb_recall callback
Date: Mon, 10 Nov 2008 22:53:02 +0200
Message-ID: <1226350382-11461-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57421 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011AbYKJUxP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:53:15 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <ricardo.labiaga@netapp.com>

Implement the cb_recall callback conforming to
http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |   49 +++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 42 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 5b17397..53ffc56 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -306,9 +306,11 @@ nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
 }
 
 static int
-nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p, struct nfs4_cb_recall *args)
+nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p,
+		       struct nfs4_rpc_args *rpc_args)
 {
 	struct xdr_stream xdr;
+	struct nfs4_cb_recall *args = rpc_args->args_op;
 	struct nfs4_cb_compound_hdr hdr = {
 		.ident = args->cbr_ident,
 		.nops   = 1,
@@ -339,7 +341,16 @@ static int
 nfs41_xdr_enc_cb_recall(struct rpc_rqst *req, u32 *p,
 			struct nfs4_rpc_args *rpc_args)
 {
-	return -1;	/* stub */
+	struct xdr_stream xdr;
+	struct nfs4_cb_recall *args = rpc_args->args_op;
+	struct nfs4_cb_compound_hdr hdr = {
+		.nops   = 2,
+	};
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_cb_compound41_hdr(&xdr, &hdr);
+	encode_cb_sequence(&xdr, rpc_args->args_seq);
+	return encode_cb_recall(&xdr, args);
 }
 #endif /* defined(CONFIG_NFSD_V4_1) */
 
@@ -423,7 +434,20 @@ static int
 nfs41_xdr_dec_cb_recall(struct rpc_rqst *rqstp, u32 *p,
 			struct nfs4_rpc_res *rpc_res)
 {
-	return -1;	/* stub */
+	struct xdr_stream xdr;
+	struct nfs4_cb_compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_cb_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_cb_sequence(&xdr, rpc_res->res_seq);
+	if (status)
+		goto out;
+	status = decode_cb_op_hdr(&xdr, OP_CB_RECALL);
+out:
+	return status;
 }
 #endif /* defined(CONFIG_NFSD_V4_1) */
 
@@ -695,19 +719,28 @@ void
 nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfs4_client *clp = dp->dl_client;
-	struct rpc_clnt *clnt = clp->cl_callback.cb_client;
 	struct nfs4_cb_recall *cbr = &dp->dl_recall;
+	struct nfs4_rpc_args args = {
+		.args_op = cbr,
+	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL],
-		.rpc_argp = cbr,
+		.rpc_argp = &args,
 	};
 	int retries = 1;
 	int status = 0;
 
+	dprintk("%s: dp %p\n", __func__, dp);
+
 	cbr->cbr_trunc = 0; /* XXX need to implement truncate optimization */
 	cbr->cbr_dp = dp;
 
-	status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT);
+#if defined(CONFIG_NFSD_V4_1)
+	if (clp->cl_callback.cb_minorversion)
+		msg.rpc_proc = &nfs41_cb_procedures[NFSPROC4_CLNT_CB_RECALL];
+#endif /* CONFIG_NFSD_V4_1 */
+
+	status = nfs4_cb_sync(clp, &msg, RPC_TASK_SOFT);
 	while (retries--) {
 		switch (status) {
 			case -EIO:
@@ -722,13 +755,15 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 				goto out_put_cred;
 		}
 		ssleep(2);
-		status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT);
+		status = nfs4_cb_sync(clp, &msg, RPC_TASK_SOFT);
 	}
 out_put_cred:
 	/*
 	 * Success or failure, now we're either waiting for lease expiration
 	 * or deleg_return.
 	 */
+	dprintk("%s: dp %p dl_flock %p dl_count %d\n",
+		__func__, dp, dp->dl_flock, atomic_read(&dp->dl_count));
 	put_nfs4_client(clp);
 	nfs4_put_delegation(dp);
 	return;
-- 
1.6.0.2

