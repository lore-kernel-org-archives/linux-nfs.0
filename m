Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49119 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932205Ab0I3QTj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 12:19:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 03/16] nfsd4: rename nfs4_rpc_args->nfsd4_cb_args
Date: Thu, 30 Sep 2010 12:19:00 -0400
Message-Id: <1285863553-8945-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1285863553-8945-1-git-send-email-bfields@redhat.com>
References: <1285863553-8945-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

With apologies for the gratuitous rename, the new name seems more
helpful to me.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   14 +++++++-------
 fs/nfsd/state.h        |    4 ++--
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 02afb71..ae63f69 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -247,7 +247,7 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp,
 }
 
 static void
-encode_cb_sequence(struct xdr_stream *xdr, struct nfs4_rpc_args *args,
+encode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_args *args,
 		   struct nfs4_cb_compound_hdr *hdr)
 {
 	__be32 *p;
@@ -279,7 +279,7 @@ nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
 
 static int
 nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p,
-		struct nfs4_rpc_args *rpc_args)
+		struct nfsd4_cb_args *rpc_args)
 {
 	struct xdr_stream xdr;
 	struct nfs4_delegation *args = rpc_args->args_op;
@@ -338,7 +338,7 @@ decode_cb_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
  * with a single slot.
  */
 static int
-decode_cb_sequence(struct xdr_stream *xdr, struct nfs4_rpc_args *res,
+decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_args *res,
 		   struct rpc_rqst *rqstp)
 {
 	struct nfs4_sessionid id;
@@ -392,7 +392,7 @@ nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p)
 
 static int
 nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p,
-		struct nfs4_rpc_args *args)
+		struct nfsd4_cb_args *args)
 {
 	struct xdr_stream xdr;
 	struct nfs4_cb_compound_hdr hdr;
@@ -584,7 +584,7 @@ void nfsd4_probe_callback(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
 static int nfsd41_cb_setup_sequence(struct nfs4_client *clp,
 		struct rpc_task *task)
 {
-	struct nfs4_rpc_args *args = task->tk_msg.rpc_argp;
+	struct nfsd4_cb_args *args = task->tk_msg.rpc_argp;
 	u32 *ptr = (u32 *)clp->cl_sessionid.data;
 	int status = 0;
 
@@ -618,7 +618,7 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_delegation *dp = calldata;
 	struct nfs4_client *clp = dp->dl_client;
-	struct nfs4_rpc_args *args = task->tk_msg.rpc_argp;
+	struct nfsd4_cb_args *args = task->tk_msg.rpc_argp;
 	u32 minorversion = clp->cl_cb_conn.cb_minorversion;
 	int status = 0;
 
@@ -755,7 +755,7 @@ static void _nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfs4_client *clp = dp->dl_client;
 	struct rpc_clnt *clnt = clp->cl_cb_client;
-	struct nfs4_rpc_args *args = &dp->dl_recall.cb_args;
+	struct nfsd4_cb_args *args = &dp->dl_recall.cb_args;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL],
 		.rpc_cred = callback_cred
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 59313f1..f988b90 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -64,14 +64,14 @@ typedef struct {
 	(s)->si_fileid, \
 	(s)->si_generation
 
-struct nfs4_rpc_args {
+struct nfsd4_cb_args {
 	void			*args_op;
 	struct nfs4_client	*args_clp;
 	u32			args_minorversion;
 };
 
 struct nfsd4_callback {
-	struct nfs4_rpc_args cb_args;
+	struct nfsd4_cb_args cb_args;
 	struct work_struct cb_work;
 };
 
-- 
1.7.0.4

