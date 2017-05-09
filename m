Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:54519 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752781AbdEIJUU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:20:20 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 02/32] sunrpc: fix encoder callback prototypes
Date: Tue,  9 May 2017 11:19:40 +0200
Message-Id: <20170509092010.30752-3-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Declare the p_encode callbacks with the proper prototype instead of
casting to kxdreproc_t and losing all type safety.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/sunrpc/rpcb_clnt.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 5b30603596d0..d0269a39afdf 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -843,8 +843,9 @@ static void rpcb_getport_done(struct rpc_task *child, void *data)
  */
 
 static void rpcb_enc_mapping(struct rpc_rqst *req, struct xdr_stream *xdr,
-			     const struct rpcbind_args *rpcb)
+			     const void *data)
 {
+	const struct rpcbind_args *rpcb = data;
 	__be32 *p;
 
 	dprintk("RPC: %5u encoding PMAP_%s call (%u, %u, %d, %u)\n",
@@ -917,8 +918,9 @@ static void encode_rpcb_string(struct xdr_stream *xdr, const char *string,
 }
 
 static void rpcb_enc_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
-			     const struct rpcbind_args *rpcb)
+			     const void *data)
 {
+	const struct rpcbind_args *rpcb = data;
 	__be32 *p;
 
 	dprintk("RPC: %5u encoding RPCB_%s call (%u, %u, '%s', '%s')\n",
@@ -992,7 +994,7 @@ static int rpcb_dec_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
 static struct rpc_procinfo rpcb_procedures2[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
-		.p_encode	= (kxdreproc_t)rpcb_enc_mapping,
+		.p_encode	= rpcb_enc_mapping,
 		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_mappingargs_sz,
 		.p_replen	= RPCB_setres_sz,
@@ -1002,7 +1004,7 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 	},
 	[RPCBPROC_UNSET] = {
 		.p_proc		= RPCBPROC_UNSET,
-		.p_encode	= (kxdreproc_t)rpcb_enc_mapping,
+		.p_encode	= rpcb_enc_mapping,
 		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_mappingargs_sz,
 		.p_replen	= RPCB_setres_sz,
@@ -1012,7 +1014,7 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 	},
 	[RPCBPROC_GETPORT] = {
 		.p_proc		= RPCBPROC_GETPORT,
-		.p_encode	= (kxdreproc_t)rpcb_enc_mapping,
+		.p_encode	= rpcb_enc_mapping,
 		.p_decode	= (kxdrdproc_t)rpcb_dec_getport,
 		.p_arglen	= RPCB_mappingargs_sz,
 		.p_replen	= RPCB_getportres_sz,
@@ -1025,7 +1027,7 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 static struct rpc_procinfo rpcb_procedures3[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
-		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
+		.p_encode	= rpcb_enc_getaddr,
 		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
@@ -1035,7 +1037,7 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 	},
 	[RPCBPROC_UNSET] = {
 		.p_proc		= RPCBPROC_UNSET,
-		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
+		.p_encode	= rpcb_enc_getaddr,
 		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
@@ -1045,7 +1047,7 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 	},
 	[RPCBPROC_GETADDR] = {
 		.p_proc		= RPCBPROC_GETADDR,
-		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
+		.p_encode	= rpcb_enc_getaddr,
 		.p_decode	= (kxdrdproc_t)rpcb_dec_getaddr,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_getaddrres_sz,
@@ -1058,7 +1060,7 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 static struct rpc_procinfo rpcb_procedures4[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
-		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
+		.p_encode	= rpcb_enc_getaddr,
 		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
@@ -1068,7 +1070,7 @@ static struct rpc_procinfo rpcb_procedures4[] = {
 	},
 	[RPCBPROC_UNSET] = {
 		.p_proc		= RPCBPROC_UNSET,
-		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
+		.p_encode	= rpcb_enc_getaddr,
 		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
@@ -1078,7 +1080,7 @@ static struct rpc_procinfo rpcb_procedures4[] = {
 	},
 	[RPCBPROC_GETADDR] = {
 		.p_proc		= RPCBPROC_GETADDR,
-		.p_encode	= (kxdreproc_t)rpcb_enc_getaddr,
+		.p_encode	= rpcb_enc_getaddr,
 		.p_decode	= (kxdrdproc_t)rpcb_dec_getaddr,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_getaddrres_sz,
-- 
2.11.0

