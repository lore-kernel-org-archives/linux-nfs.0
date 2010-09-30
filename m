Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49112 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932192Ab0I3QTh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 12:19:37 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 02/16] nfsd4: combine nfs4_rpc_args and nfsd4_cb_sequence
Date: Thu, 30 Sep 2010 12:18:59 -0400
Message-Id: <1285863553-8945-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1285863553-8945-1-git-send-email-bfields@redhat.com>
References: <1285863553-8945-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

These two structs don't really need to be distinct as far as I can tell.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   30 +++++++++++++++---------------
 fs/nfsd/state.h        |   11 +++--------
 2 files changed, 18 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 30adfad..02afb71 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -247,7 +247,7 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp,
 }
 
 static void
-encode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *args,
+encode_cb_sequence(struct xdr_stream *xdr, struct nfs4_rpc_args *args,
 		   struct nfs4_cb_compound_hdr *hdr)
 {
 	__be32 *p;
@@ -258,8 +258,8 @@ encode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *args,
 	RESERVE_SPACE(1 + NFS4_MAX_SESSIONID_LEN + 20);
 
 	WRITE32(OP_CB_SEQUENCE);
-	WRITEMEM(args->cbs_clp->cl_sessionid.data, NFS4_MAX_SESSIONID_LEN);
-	WRITE32(args->cbs_clp->cl_cb_seq_nr);
+	WRITEMEM(args->args_clp->cl_sessionid.data, NFS4_MAX_SESSIONID_LEN);
+	WRITE32(args->args_clp->cl_cb_seq_nr);
 	WRITE32(0);		/* slotid, always 0 */
 	WRITE32(0);		/* highest slotid always 0 */
 	WRITE32(0);		/* cachethis always 0 */
@@ -285,12 +285,12 @@ nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p,
 	struct nfs4_delegation *args = rpc_args->args_op;
 	struct nfs4_cb_compound_hdr hdr = {
 		.ident = args->dl_ident,
-		.minorversion = rpc_args->args_seq.cbs_minorversion,
+		.minorversion = rpc_args->args_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_cb_compound_hdr(&xdr, &hdr);
-	encode_cb_sequence(&xdr, &rpc_args->args_seq, &hdr);
+	encode_cb_sequence(&xdr, rpc_args, &hdr);
 	encode_cb_recall(&xdr, args, &hdr);
 	encode_cb_nops(&hdr);
 	return 0;
@@ -338,7 +338,7 @@ decode_cb_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
  * with a single slot.
  */
 static int
-decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *res,
+decode_cb_sequence(struct xdr_stream *xdr, struct nfs4_rpc_args *res,
 		   struct rpc_rqst *rqstp)
 {
 	struct nfs4_sessionid id;
@@ -346,7 +346,7 @@ decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *res,
 	u32 dummy;
 	__be32 *p;
 
-	if (res->cbs_minorversion == 0)
+	if (res->args_minorversion == 0)
 		return 0;
 
 	status = decode_cb_op_hdr(xdr, OP_CB_SEQUENCE);
@@ -362,13 +362,13 @@ decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *res,
 	READ_BUF(NFS4_MAX_SESSIONID_LEN + 16);
 	memcpy(id.data, p, NFS4_MAX_SESSIONID_LEN);
 	p += XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN);
-	if (memcmp(id.data, res->cbs_clp->cl_sessionid.data,
+	if (memcmp(id.data, res->args_clp->cl_sessionid.data,
 		   NFS4_MAX_SESSIONID_LEN)) {
 		dprintk("%s Invalid session id\n", __func__);
 		goto out;
 	}
 	READ32(dummy);
-	if (dummy != res->cbs_clp->cl_cb_seq_nr) {
+	if (dummy != res->args_clp->cl_cb_seq_nr) {
 		dprintk("%s Invalid sequence number\n", __func__);
 		goto out;
 	}
@@ -392,7 +392,7 @@ nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p)
 
 static int
 nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p,
-		struct nfsd4_cb_sequence *seq)
+		struct nfs4_rpc_args *args)
 {
 	struct xdr_stream xdr;
 	struct nfs4_cb_compound_hdr hdr;
@@ -402,8 +402,8 @@ nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p,
 	status = decode_cb_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
-	if (seq) {
-		status = decode_cb_sequence(&xdr, seq, rqstp);
+	if (args) {
+		status = decode_cb_sequence(&xdr, args, rqstp);
 		if (status)
 			goto out;
 	}
@@ -602,8 +602,8 @@ static int nfsd41_cb_setup_sequence(struct nfs4_client *clp,
 	 * We'll need the clp during XDR encoding and decoding,
 	 * and the sequence during decoding to verify the reply
 	 */
-	args->args_seq.cbs_clp = clp;
-	task->tk_msg.rpc_resp = &args->args_seq;
+	args->args_clp = clp;
+	task->tk_msg.rpc_resp = args;
 
 out:
 	dprintk("%s status=%d\n", __func__, status);
@@ -622,7 +622,7 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 	u32 minorversion = clp->cl_cb_conn.cb_minorversion;
 	int status = 0;
 
-	args->args_seq.cbs_minorversion = minorversion;
+	args->args_minorversion = minorversion;
 	if (minorversion) {
 		status = nfsd41_cb_setup_sequence(clp, task);
 		if (status) {
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 322518c..59313f1 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -64,15 +64,10 @@ typedef struct {
 	(s)->si_fileid, \
 	(s)->si_generation
 
-struct nfsd4_cb_sequence {
-	/* args/res */
-	u32			cbs_minorversion;
-	struct nfs4_client	*cbs_clp;
-};
-
 struct nfs4_rpc_args {
-	void				*args_op;
-	struct nfsd4_cb_sequence	args_seq;
+	void			*args_op;
+	struct nfs4_client	*args_clp;
+	u32			args_minorversion;
 };
 
 struct nfsd4_callback {
-- 
1.7.0.4

