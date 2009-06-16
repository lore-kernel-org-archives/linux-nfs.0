From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 43/44] nfsd41: Backchannel: Implement cb_recall over NFSv4.1
Date: Tue, 16 Jun 2009 04:21:16 +0300
Message-ID: <1245115276-8221-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:15231
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757897AbZFPBVQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:21:16 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
[nfsd41: cb_recall callback]
[Share v4.0 and v4.1 back channel xdr]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[Share v4.0 and v4.1 back channel xdr]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: use nfsd4_cb_sequence for callback minorversion]
[nfsd41: conditionally decode_sequence in nfs4_xdr_dec_cb_recall]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: Backchannel: Add sequence arguments to callback RPC arguments]
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |   31 +++++++++++++++++++++++++++----
 1 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 22e5455..9142ff9 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -288,15 +288,19 @@ nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
 }
 
 static int
-nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p, struct nfs4_delegation *args)
+nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p,
+		struct nfs4_rpc_args *rpc_args)
 {
 	struct xdr_stream xdr;
+	struct nfs4_delegation *args = rpc_args->args_op;
 	struct nfs4_cb_compound_hdr hdr = {
 		.ident = args->dl_ident,
+		.minorversion = rpc_args->args_seq.cbs_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_cb_compound_hdr(&xdr, &hdr);
+	encode_cb_sequence(&xdr, &rpc_args->args_seq, &hdr);
 	encode_cb_recall(&xdr, args, &hdr);
 	encode_cb_nops(&hdr);
 	return 0;
@@ -396,7 +400,8 @@ nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p)
 }
 
 static int
-nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p)
+nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p,
+		struct nfsd4_cb_sequence *seq)
 {
 	struct xdr_stream xdr;
 	struct nfs4_cb_compound_hdr hdr;
@@ -406,6 +411,11 @@ nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p)
 	status = decode_cb_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	if (seq) {
+		status = decode_cb_sequence(&xdr, seq, rqstp);
+		if (status)
+			goto out;
+	}
 	status = decode_cb_op_hdr(&xdr, OP_CB_RECALL);
 out:
 	return status;
@@ -688,6 +698,8 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 	struct nfs4_delegation *dp = calldata;
 	struct nfs4_client *clp = dp->dl_client;
 
+	nfsd4_cb_done(task, calldata);
+
 	switch (task->tk_status) {
 	case -EIO:
 		/* Network partition? */
@@ -700,16 +712,19 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 		break;
 	default:
 		/* success, or error we can't handle */
-		return;
+		goto done;
 	}
 	if (dp->dl_retries--) {
 		rpc_delay(task, 2*HZ);
 		task->tk_status = 0;
 		rpc_restart_call(task);
+		return;
 	} else {
 		atomic_set(&clp->cl_cb_conn.cb_set, 0);
 		warn_no_callback_path(clp, task->tk_status);
 	}
+done:
+	kfree(task->tk_msg.rpc_argp);
 }
 
 static void nfsd4_cb_recall_release(void *calldata)
@@ -735,16 +750,24 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfs4_client *clp = dp->dl_client;
 	struct rpc_clnt *clnt = clp->cl_cb_conn.cb_client;
+	struct nfs4_rpc_args *args;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL],
-		.rpc_argp = dp,
 		.rpc_cred = clp->cl_cb_conn.cb_cred
 	};
 	int status;
 
+	args = kzalloc(sizeof(*args), GFP_KERNEL);
+	if (!args) {
+		status = -ENOMEM;
+		goto out;
+	}
+	args->args_op = dp;
+	msg.rpc_argp = args;
 	dp->dl_retries = 1;
 	status = rpc_call_async(clnt, &msg, RPC_TASK_SOFT,
 				&nfsd4_cb_recall_ops, dp);
+out:
 	if (status) {
 		put_nfs4_client(clp);
 		nfs4_put_delegation(dp);
-- 
1.6.3

