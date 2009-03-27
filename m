From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 42/47] nfsd41: cb_recall callback
Date: Fri, 27 Mar 2009 06:20:18 +0300
Message-ID: <1238124018-8227-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:27064 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755343AbZC0DUZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:20:25 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Implement the cb_recall callback conforming to
http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[Share v4.0 and v4.1 back channel xdr]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |   25 +++++++++++++++++++------
 1 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index dd3b739..0be75e0 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -298,9 +298,11 @@ nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
 }
 
 static int
-nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p, struct nfs4_cb_recall *args)
+nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p,
+		       struct nfs4_rpc_args *rpc_args)
 {
 	struct xdr_stream xdr;
+	struct nfs4_cb_recall *args = rpc_args->args_op;
 	struct nfs4_callback *cb =
 		(struct nfs4_callback *)req->rq_task->tk_client->cl_private;
 	struct nfs4_cb_compound_hdr hdr = {
@@ -310,6 +312,7 @@ nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p, struct nfs4_cb_recall *a
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_cb_compound_hdr(&xdr, &hdr);
+	encode_cb_sequence(&xdr, rpc_args->args_seq, &hdr);
 	encode_cb_recall(&xdr, args, &hdr);
 	encode_cb_nops(&hdr);
 	return 0;
@@ -421,7 +424,8 @@ nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p)
 }
 
 static int
-nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p)
+nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p,
+		       struct nfs4_rpc_res *rpc_res)
 {
 	struct xdr_stream xdr;
 	struct nfs4_cb_compound_hdr hdr;
@@ -431,6 +435,9 @@ nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p)
 	status = decode_cb_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_cb_sequence(&xdr, rpc_res->res_seq, rqstp);
+	if (status)
+		goto out;
 	status = decode_cb_op_hdr(&xdr, OP_CB_RECALL);
 out:
 	return status;
@@ -678,19 +685,23 @@ void
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
+	status = nfsd4_cb_sync(clp, &msg, RPC_TASK_SOFT);
 	while (retries--) {
 		switch (status) {
 			case -EIO:
@@ -705,13 +716,15 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 				goto out_put_cred;
 		}
 		ssleep(2);
-		status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT);
+		status = nfsd4_cb_sync(clp, &msg, RPC_TASK_SOFT);
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
1.6.2.1

