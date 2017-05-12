Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:35476 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932610AbdELQRc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 12:17:32 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 08/33] sunrpc: fix decoder callback prototypes
Date: Fri, 12 May 2017 18:16:36 +0200
Message-Id: <20170512161701.22468-9-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Declare the p_decode callbacks with the proper prototype instead of
casting to kxdrdproc_t and losing all type safety.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/rpcb_clnt.c | 27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index d0269a39afdf..f67b9e2897b4 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -861,8 +861,9 @@ static void rpcb_enc_mapping(struct rpc_rqst *req, struct xdr_stream *xdr,
 }
 
 static int rpcb_dec_getport(struct rpc_rqst *req, struct xdr_stream *xdr,
-			    struct rpcbind_args *rpcb)
+			    void *data)
 {
+	struct rpcbind_args *rpcb = data;
 	unsigned long port;
 	__be32 *p;
 
@@ -883,8 +884,9 @@ static int rpcb_dec_getport(struct rpc_rqst *req, struct xdr_stream *xdr,
 }
 
 static int rpcb_dec_set(struct rpc_rqst *req, struct xdr_stream *xdr,
-			unsigned int *boolp)
+			void *data)
 {
+	unsigned int *boolp = data;
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, 4);
@@ -939,8 +941,9 @@ static void rpcb_enc_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
 }
 
 static int rpcb_dec_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
-			    struct rpcbind_args *rpcb)
+			    void *data)
 {
+	struct rpcbind_args *rpcb = data;
 	struct sockaddr_storage address;
 	struct sockaddr *sap = (struct sockaddr *)&address;
 	__be32 *p;
@@ -995,7 +998,7 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
 		.p_encode	= rpcb_enc_mapping,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
+		.p_decode	= rpcb_dec_set,
 		.p_arglen	= RPCB_mappingargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_SET,
@@ -1005,7 +1008,7 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 	[RPCBPROC_UNSET] = {
 		.p_proc		= RPCBPROC_UNSET,
 		.p_encode	= rpcb_enc_mapping,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
+		.p_decode	= rpcb_dec_set,
 		.p_arglen	= RPCB_mappingargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_UNSET,
@@ -1015,7 +1018,7 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 	[RPCBPROC_GETPORT] = {
 		.p_proc		= RPCBPROC_GETPORT,
 		.p_encode	= rpcb_enc_mapping,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_getport,
+		.p_decode	= rpcb_dec_getport,
 		.p_arglen	= RPCB_mappingargs_sz,
 		.p_replen	= RPCB_getportres_sz,
 		.p_statidx	= RPCBPROC_GETPORT,
@@ -1028,7 +1031,7 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
 		.p_encode	= rpcb_enc_getaddr,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
+		.p_decode	= rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_SET,
@@ -1038,7 +1041,7 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 	[RPCBPROC_UNSET] = {
 		.p_proc		= RPCBPROC_UNSET,
 		.p_encode	= rpcb_enc_getaddr,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
+		.p_decode	= rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_UNSET,
@@ -1048,7 +1051,7 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 	[RPCBPROC_GETADDR] = {
 		.p_proc		= RPCBPROC_GETADDR,
 		.p_encode	= rpcb_enc_getaddr,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_getaddr,
+		.p_decode	= rpcb_dec_getaddr,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_getaddrres_sz,
 		.p_statidx	= RPCBPROC_GETADDR,
@@ -1061,7 +1064,7 @@ static struct rpc_procinfo rpcb_procedures4[] = {
 	[RPCBPROC_SET] = {
 		.p_proc		= RPCBPROC_SET,
 		.p_encode	= rpcb_enc_getaddr,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
+		.p_decode	= rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_SET,
@@ -1071,7 +1074,7 @@ static struct rpc_procinfo rpcb_procedures4[] = {
 	[RPCBPROC_UNSET] = {
 		.p_proc		= RPCBPROC_UNSET,
 		.p_encode	= rpcb_enc_getaddr,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_set,
+		.p_decode	= rpcb_dec_set,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_setres_sz,
 		.p_statidx	= RPCBPROC_UNSET,
@@ -1081,7 +1084,7 @@ static struct rpc_procinfo rpcb_procedures4[] = {
 	[RPCBPROC_GETADDR] = {
 		.p_proc		= RPCBPROC_GETADDR,
 		.p_encode	= rpcb_enc_getaddr,
-		.p_decode	= (kxdrdproc_t)rpcb_dec_getaddr,
+		.p_decode	= rpcb_dec_getaddr,
 		.p_arglen	= RPCB_getaddrargs_sz,
 		.p_replen	= RPCB_getaddrres_sz,
 		.p_statidx	= RPCBPROC_GETADDR,
-- 
2.11.0

