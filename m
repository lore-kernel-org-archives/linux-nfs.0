From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/3] SQUASHME: nfsd41: use nfsd4_cb_sequence for callback minorversion
Date: Sun, 29 Mar 2009 22:11:12 +0300
Message-ID: <1238353872-3809-1-git-send-email-bhalevy@panasas.com>
References: <49CFC758.6030808@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:12561 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752227AbZC2TLZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Mar 2009 15:11:25 -0400
In-Reply-To: <49CFC758.6030808@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rather than using struct rpc_clnt.cl_private.

squash into "nfsd: minorversion support for the back channel"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c     |   20 +++++++++++++-------
 include/linux/nfsd/state.h |    1 +
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 0be75e0..02e0a61 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -297,17 +297,25 @@ nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
 	return 0;
 }
 
+static u32
+nfs4_xdr_minorversion(struct nfs4_rpc_args *rpc_args)
+{
+#if defined(CONFIG_NFSD_V4_1)
+	if (rpc_args->args_seq)
+		return rpc_args->args_seq->cbs_minorversion;
+#endif /* CONFIG_NFSD_V4_1 */
+	return 0;
+}
+
 static int
 nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p,
 		       struct nfs4_rpc_args *rpc_args)
 {
 	struct xdr_stream xdr;
 	struct nfs4_cb_recall *args = rpc_args->args_op;
-	struct nfs4_callback *cb =
-		(struct nfs4_callback *)req->rq_task->tk_client->cl_private;
 	struct nfs4_cb_compound_hdr hdr = {
 		.ident = args->cbr_ident,
-		.minorversion = cb->cb_minorversion,
+		.minorversion = nfs4_xdr_minorversion(rpc_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -362,14 +370,12 @@ static int
 decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *res,
 		   struct rpc_rqst *rqstp)
 {
-	struct nfs4_callback *cb =
-		(struct nfs4_callback *)rqstp->rq_task->tk_client->cl_private;
 	struct nfs4_sessionid id;
 	int status;
 	u32 dummy;
 	__be32 *p;
 
-	if (cb->cb_minorversion == 0)
+	if (res->cbs_minorversion == 0)
 		return 0;
 
 	status = decode_cb_op_hdr(xdr, OP_CB_SEQUENCE);
@@ -570,7 +576,6 @@ static int do_probe_callback(void *data)
 		goto out_release_client;
 
 	cb->cb_client = client;
-	client->cl_private = cb;
 	atomic_set(&cb->cb_set, 1);
 	put_nfs4_client(clp);
 	return 0;
@@ -625,6 +630,7 @@ nfs41_cb_sequence_setup(struct nfs4_client *clp, struct nfsd4_cb_sequence *args)
 		ptr[0], ptr[1], ptr[2], ptr[3]);
 
 	mutex_lock(&clp->cl_cb_mutex);
+	args->cbs_minorversion = clp->cl_callback.cb_minorversion;
 	args->cbs_clp = clp;
 	clp->cl_cb_seq_nr++;
 	return 0;
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 0ea8c89..365cc4b 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -63,6 +63,7 @@ typedef struct {
 
 struct nfsd4_cb_sequence {
 	/* args/res */
+	u32			cbs_minorversion;
 	struct nfs4_client	*cbs_clp;
 };
 
-- 
1.6.2.1

