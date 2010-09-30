Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49121 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754737Ab0I3QTj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 12:19:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 06/16] nfsd4: remove separate cb_args struct
Date: Thu, 30 Sep 2010 12:19:03 -0400
Message-Id: <1285863553-8945-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1285863553-8945-1-git-send-email-bfields@redhat.com>
References: <1285863553-8945-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

I don't see the point of the separate struct.  It seems to just be
getting in the way.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   45 ++++++++++++++++++++++-----------------------
 fs/nfsd/state.h        |   10 +++-------
 2 files changed, 25 insertions(+), 30 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 3b06212..384a990 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -247,7 +247,7 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp,
 }
 
 static void
-encode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_args *args,
+encode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_callback *cb,
 		   struct nfs4_cb_compound_hdr *hdr)
 {
 	__be32 *p;
@@ -258,8 +258,8 @@ encode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_args *args,
 	RESERVE_SPACE(1 + NFS4_MAX_SESSIONID_LEN + 20);
 
 	WRITE32(OP_CB_SEQUENCE);
-	WRITEMEM(args->args_clp->cl_sessionid.data, NFS4_MAX_SESSIONID_LEN);
-	WRITE32(args->args_clp->cl_cb_seq_nr);
+	WRITEMEM(cb->cb_clp->cl_sessionid.data, NFS4_MAX_SESSIONID_LEN);
+	WRITE32(cb->cb_clp->cl_cb_seq_nr);
 	WRITE32(0);		/* slotid, always 0 */
 	WRITE32(0);		/* highest slotid always 0 */
 	WRITE32(0);		/* cachethis always 0 */
@@ -279,18 +279,18 @@ nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
 
 static int
 nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p,
-		struct nfsd4_cb_args *rpc_args)
+		struct nfsd4_callback *cb)
 {
 	struct xdr_stream xdr;
-	struct nfs4_delegation *args = rpc_args->args_op;
+	struct nfs4_delegation *args = cb->cb_op;
 	struct nfs4_cb_compound_hdr hdr = {
 		.ident = args->dl_ident,
-		.minorversion = rpc_args->args_minorversion,
+		.minorversion = cb->cb_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_cb_compound_hdr(&xdr, &hdr);
-	encode_cb_sequence(&xdr, rpc_args, &hdr);
+	encode_cb_sequence(&xdr, cb, &hdr);
 	encode_cb_recall(&xdr, args, &hdr);
 	encode_cb_nops(&hdr);
 	return 0;
@@ -338,7 +338,7 @@ decode_cb_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
  * with a single slot.
  */
 static int
-decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_args *res,
+decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_callback *cb,
 		   struct rpc_rqst *rqstp)
 {
 	struct nfs4_sessionid id;
@@ -346,7 +346,7 @@ decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_args *res,
 	u32 dummy;
 	__be32 *p;
 
-	if (res->args_minorversion == 0)
+	if (cb->cb_minorversion == 0)
 		return 0;
 
 	status = decode_cb_op_hdr(xdr, OP_CB_SEQUENCE);
@@ -362,13 +362,13 @@ decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_args *res,
 	READ_BUF(NFS4_MAX_SESSIONID_LEN + 16);
 	memcpy(id.data, p, NFS4_MAX_SESSIONID_LEN);
 	p += XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN);
-	if (memcmp(id.data, res->args_clp->cl_sessionid.data,
+	if (memcmp(id.data, cb->cb_clp->cl_sessionid.data,
 		   NFS4_MAX_SESSIONID_LEN)) {
 		dprintk("%s Invalid session id\n", __func__);
 		goto out;
 	}
 	READ32(dummy);
-	if (dummy != res->args_clp->cl_cb_seq_nr) {
+	if (dummy != cb->cb_clp->cl_cb_seq_nr) {
 		dprintk("%s Invalid sequence number\n", __func__);
 		goto out;
 	}
@@ -392,7 +392,7 @@ nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p)
 
 static int
 nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p,
-		struct nfsd4_cb_args *args)
+		struct nfsd4_callback *cb)
 {
 	struct xdr_stream xdr;
 	struct nfs4_cb_compound_hdr hdr;
@@ -402,8 +402,8 @@ nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p,
 	status = decode_cb_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
-	if (args) {
-		status = decode_cb_sequence(&xdr, args, rqstp);
+	if (cb) {
+		status = decode_cb_sequence(&xdr, cb, rqstp);
 		if (status)
 			goto out;
 	}
@@ -550,8 +550,8 @@ void do_probe_callback(struct nfs4_client *clp)
 {
 	struct nfsd4_callback *cb = &clp->cl_cb_null;
 
-	cb->cb_args.args_op = NULL;
-	cb->cb_args.args_clp = clp;
+	cb->cb_op = NULL;
+	cb->cb_clp = clp;
 
 	cb->cb_msg.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL];
 	cb->cb_msg.rpc_argp = NULL;
@@ -614,11 +614,10 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 	struct nfsd4_callback *cb = calldata;
 	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
 	struct nfs4_client *clp = dp->dl_client;
-	struct nfsd4_cb_args *args = task->tk_msg.rpc_argp;
 	u32 minorversion = clp->cl_cb_conn.cb_minorversion;
 	int status = 0;
 
-	args->args_minorversion = minorversion;
+	cb->cb_minorversion = minorversion;
 	if (minorversion) {
 		status = nfsd41_cb_setup_sequence(clp, task);
 		if (status) {
@@ -754,7 +753,7 @@ void nfsd4_release_cb(struct nfsd4_callback *cb)
 void nfsd4_do_callback_rpc(struct work_struct *w)
 {
 	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback, cb_work);
-	struct nfs4_client *clp = cb->cb_args.args_clp;
+	struct nfs4_client *clp = cb->cb_clp;
 	struct rpc_clnt *clnt = clp->cl_cb_client;
 
 	if (clnt == NULL) {
@@ -770,11 +769,11 @@ void nfsd4_cb_recall(struct nfs4_delegation *dp)
 	struct nfsd4_callback *cb = &dp->dl_recall;
 
 	dp->dl_retries = 1;
-	cb->cb_args.args_op = dp;
-	cb->cb_args.args_clp = dp->dl_client;
+	cb->cb_op = dp;
+	cb->cb_clp = dp->dl_client;
 	cb->cb_msg.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL];
-	cb->cb_msg.rpc_argp = &cb->cb_args;
-	cb->cb_msg.rpc_resp = &cb->cb_args;
+	cb->cb_msg.rpc_argp = cb;
+	cb->cb_msg.rpc_resp = cb;
 	cb->cb_msg.rpc_cred = callback_cred;
 
 	cb->cb_ops = &nfsd4_cb_recall_ops;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 19732d5..2ece6be 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -64,14 +64,10 @@ typedef struct {
 	(s)->si_fileid, \
 	(s)->si_generation
 
-struct nfsd4_cb_args {
-	void			*args_op;
-	struct nfs4_client	*args_clp;
-	u32			args_minorversion;
-};
-
 struct nfsd4_callback {
-	struct nfsd4_cb_args cb_args;
+	void *cb_op;
+	struct nfs4_client *cb_clp;
+	u32 cb_minorversion;
 	struct rpc_message cb_msg;
 	const struct rpc_call_ops *cb_ops;
 	struct work_struct cb_work;
-- 
1.7.0.4

