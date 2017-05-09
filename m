Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:45460 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752770AbdEIJU2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:20:28 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 05/32] nfsd: fix encoder callback prototypes
Date: Tue,  9 May 2017 11:19:43 +0200
Message-Id: <20170509092010.30752-6-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Declare the p_encode callbacks with the proper prototype instead of
casting to kxdreproc_t and losing all type safety.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4callback.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 0274db6e65d0..bede418237ee 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -468,7 +468,7 @@ static int decode_cb_sequence4res(struct xdr_stream *xdr,
  * NB: Without this zero space reservation, callbacks over krb5p fail
  */
 static void nfs4_xdr_enc_cb_null(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 void *__unused)
+				 const void *__unused)
 {
 	xdr_reserve_space(xdr, 0);
 }
@@ -477,8 +477,9 @@ static void nfs4_xdr_enc_cb_null(struct rpc_rqst *req, struct xdr_stream *xdr,
  * 20.2. Operation 4: CB_RECALL - Recall a Delegation
  */
 static void nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, struct xdr_stream *xdr,
-				   const struct nfsd4_callback *cb)
+				   const void *data)
 {
+	const struct nfsd4_callback *cb = data;
 	const struct nfs4_delegation *dp = cb_to_delegation(cb);
 	struct nfs4_cb_compound_hdr hdr = {
 		.ident = cb->cb_clp->cl_cb_ident,
@@ -585,8 +586,9 @@ static void encode_cb_layout4args(struct xdr_stream *xdr,
 
 static void nfs4_xdr_enc_cb_layout(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   const struct nfsd4_callback *cb)
+				   const void *data)
 {
+	const struct nfsd4_callback *cb = data;
 	const struct nfs4_layout_stateid *ls =
 		container_of(cb, struct nfs4_layout_stateid, ls_recall);
 	struct nfs4_cb_compound_hdr hdr = {
@@ -631,8 +633,9 @@ static void encode_stateowner(struct xdr_stream *xdr, struct nfs4_stateowner *so
 
 static void nfs4_xdr_enc_cb_notify_lock(struct rpc_rqst *req,
 					struct xdr_stream *xdr,
-					const struct nfsd4_callback *cb)
+					const void *data)
 {
+	const struct nfsd4_callback *cb = data;
 	const struct nfsd4_blocked_lock *nbl =
 		container_of(cb, struct nfsd4_blocked_lock, nbl_cb);
 	struct nfs4_lockowner *lo = (struct nfs4_lockowner *)nbl->nbl_lock.fl_owner;
@@ -682,7 +685,7 @@ static int nfs4_xdr_dec_cb_notify_lock(struct rpc_rqst *rqstp,
 #define PROC(proc, call, argtype, restype)				\
 [NFSPROC4_CLNT_##proc] = {						\
 	.p_proc    = NFSPROC4_CB_##call,				\
-	.p_encode  = (kxdreproc_t)nfs4_xdr_enc_##argtype,		\
+	.p_encode  = nfs4_xdr_enc_##argtype,		\
 	.p_decode  = (kxdrdproc_t)nfs4_xdr_dec_##restype,		\
 	.p_arglen  = NFS4_enc_##argtype##_sz,				\
 	.p_replen  = NFS4_dec_##restype##_sz,				\
-- 
2.11.0

