Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:43981 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751295AbdEIJUl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:20:41 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 10/32] nfsd: fix decoder callback prototypes
Date: Tue,  9 May 2017 11:19:48 +0200
Message-Id: <20170509092010.30752-11-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Declare the p_decode callbacks with the proper prototype instead of
casting to kxdrdproc_t and losing all type safety.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4callback.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index bede418237ee..a2bedbd05b2b 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -513,8 +513,9 @@ static int nfs4_xdr_dec_cb_null(struct rpc_rqst *req, struct xdr_stream *xdr,
  */
 static int nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp,
 				  struct xdr_stream *xdr,
-				  struct nfsd4_callback *cb)
+				  void *data)
 {
+	struct nfsd4_callback *cb = data;
 	struct nfs4_cb_compound_hdr hdr;
 	int status;
 
@@ -604,8 +605,9 @@ static void nfs4_xdr_enc_cb_layout(struct rpc_rqst *req,
 
 static int nfs4_xdr_dec_cb_layout(struct rpc_rqst *rqstp,
 				  struct xdr_stream *xdr,
-				  struct nfsd4_callback *cb)
+				  void *data)
 {
+	struct nfsd4_callback *cb = data;
 	struct nfs4_cb_compound_hdr hdr;
 	int status;
 
@@ -662,8 +664,9 @@ static void nfs4_xdr_enc_cb_notify_lock(struct rpc_rqst *req,
 
 static int nfs4_xdr_dec_cb_notify_lock(struct rpc_rqst *rqstp,
 					struct xdr_stream *xdr,
-					struct nfsd4_callback *cb)
+					void *data)
 {
+	struct nfsd4_callback *cb = data;
 	struct nfs4_cb_compound_hdr hdr;
 	int status;
 
@@ -686,7 +689,7 @@ static int nfs4_xdr_dec_cb_notify_lock(struct rpc_rqst *rqstp,
 [NFSPROC4_CLNT_##proc] = {						\
 	.p_proc    = NFSPROC4_CB_##call,				\
 	.p_encode  = nfs4_xdr_enc_##argtype,		\
-	.p_decode  = (kxdrdproc_t)nfs4_xdr_dec_##restype,		\
+	.p_decode  = nfs4_xdr_dec_##restype,				\
 	.p_arglen  = NFS4_enc_##argtype##_sz,				\
 	.p_replen  = NFS4_dec_##restype##_sz,				\
 	.p_statidx = NFSPROC4_CB_##call,				\
-- 
2.11.0

