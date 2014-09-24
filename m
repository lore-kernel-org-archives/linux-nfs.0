Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:39524 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932AbaIXKQ6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 06:16:58 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] nfsd: remove nfsd4_callback.cb_op
Date: Wed, 24 Sep 2014 12:19:16 +0200
Message-Id: <1411553959-5280-2-git-send-email-hch@lst.de>
In-Reply-To: <1411553959-5280-1-git-send-email-hch@lst.de>
References: <1411553959-5280-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We can always get at the private data by using container_of, no need for
a void pointer.  Also introduce a little to_delegation helper to avoid
opencoding the container_of everywhere.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4callback.c | 17 +++++++++--------
 fs/nfsd/state.h        |  1 -
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index fc07084..06e07e1 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -55,6 +55,9 @@ enum {
 	NFSPROC4_CLNT_CB_SEQUENCE,
 };
 
+#define to_delegation(cb) \
+	container_of(cb, struct nfs4_delegation, dl_recall)
+
 struct nfs4_cb_compound_hdr {
 	/* args */
 	u32		ident;	/* minorversion 0 only */
@@ -494,7 +497,7 @@ static void nfs4_xdr_enc_cb_null(struct rpc_rqst *req, struct xdr_stream *xdr,
 static void nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, struct xdr_stream *xdr,
 				   const struct nfsd4_callback *cb)
 {
-	const struct nfs4_delegation *args = cb->cb_op;
+	const struct nfs4_delegation *dp = to_delegation(cb);
 	struct nfs4_cb_compound_hdr hdr = {
 		.ident = cb->cb_clp->cl_cb_ident,
 		.minorversion = cb->cb_minorversion,
@@ -502,7 +505,7 @@ static void nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, struct xdr_stream *xdr,
 
 	encode_cb_compound4args(xdr, &hdr);
 	encode_cb_sequence4args(xdr, cb, &hdr);
-	encode_cb_recall4args(xdr, args, &hdr);
+	encode_cb_recall4args(xdr, dp, &hdr);
 	encode_cb_nops(&hdr);
 }
 
@@ -755,7 +758,6 @@ static void do_probe_callback(struct nfs4_client *clp)
 {
 	struct nfsd4_callback *cb = &clp->cl_cb_null;
 
-	cb->cb_op = NULL;
 	cb->cb_clp = clp;
 
 	cb->cb_msg.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL];
@@ -850,11 +852,10 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 	}
 }
 
-
 static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 {
 	struct nfsd4_callback *cb = calldata;
-	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
+	struct nfs4_delegation *dp = to_delegation(cb);
 	struct nfs4_client *clp = cb->cb_clp;
 	struct rpc_clnt *current_rpc_client = clp->cl_cb_client;
 
@@ -893,9 +894,10 @@ static void nfsd4_cb_recall_release(void *calldata)
 {
 	struct nfsd4_callback *cb = calldata;
 	struct nfs4_client *clp = cb->cb_clp;
-	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
 
 	if (cb->cb_done) {
+		struct nfs4_delegation *dp = to_delegation(cb);
+
 		spin_lock(&clp->cl_lock);
 		list_del(&cb->cb_per_client);
 		spin_unlock(&clp->cl_lock);
@@ -1040,7 +1042,7 @@ nfsd4_run_cb_recall(struct work_struct *w)
 	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback,
 							cb_work);
 
-	nfsd4_prepare_cb_recall(cb->cb_op);
+	nfsd4_prepare_cb_recall(to_delegation(cb));
 	nfsd4_run_callback_rpc(cb);
 }
 
@@ -1050,7 +1052,6 @@ void nfsd4_cb_recall(struct nfs4_delegation *dp)
 	struct nfs4_client *clp = dp->dl_stid.sc_client;
 
 	dp->dl_retries = 1;
-	cb->cb_op = dp;
 	cb->cb_clp = clp;
 	cb->cb_msg.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL];
 	cb->cb_msg.rpc_argp = cb;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 64f291a..74b0700 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -62,7 +62,6 @@ typedef struct {
 	(s)->si_generation
 
 struct nfsd4_callback {
-	void *cb_op;
 	struct nfs4_client *cb_clp;
 	struct list_head cb_per_client;
 	u32 cb_minorversion;
-- 
1.9.1

