Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:47886 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932610AbdELQR0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 12:17:26 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 06/33] sunrpc/auth_gss: nfsd: fix encoder callback prototypes
Date: Fri, 12 May 2017 18:16:34 +0200
Message-Id: <20170512161701.22468-7-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Declare the p_encode callbacks with the proper prototype instead of
casting to kxdreproc_t and losing all type safety.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/auth_gss/gss_rpc_upcall.c |  2 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.c    | 11 ++++++-----
 net/sunrpc/auth_gss/gss_rpc_xdr.h    |  2 +-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
index f0c6a8c78a56..45ab924da726 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -55,7 +55,7 @@ enum {
 #define PROC(proc, name)				\
 [GSSX_##proc] = {					\
 	.p_proc   = GSSX_##proc,			\
-	.p_encode = (kxdreproc_t)gssx_enc_##name,	\
+	.p_encode = gssx_enc_##name,	\
 	.p_decode = (kxdrdproc_t)gssx_dec_##name,	\
 	.p_arglen = GSSX_ARG_##name##_sz,		\
 	.p_replen = GSSX_RES_##name##_sz, 		\
diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
index 25d9a9cf7b66..5e54f4743092 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
@@ -44,7 +44,7 @@ static int gssx_dec_bool(struct xdr_stream *xdr, u32 *v)
 }
 
 static int gssx_enc_buffer(struct xdr_stream *xdr,
-			   gssx_buffer *buf)
+			   const gssx_buffer *buf)
 {
 	__be32 *p;
 
@@ -56,7 +56,7 @@ static int gssx_enc_buffer(struct xdr_stream *xdr,
 }
 
 static int gssx_enc_in_token(struct xdr_stream *xdr,
-			     struct gssp_in_token *in)
+			     const struct gssp_in_token *in)
 {
 	__be32 *p;
 
@@ -130,7 +130,7 @@ static int gssx_dec_option(struct xdr_stream *xdr,
 }
 
 static int dummy_enc_opt_array(struct xdr_stream *xdr,
-				struct gssx_option_array *oa)
+				const struct gssx_option_array *oa)
 {
 	__be32 *p;
 
@@ -348,7 +348,7 @@ static int gssx_dec_status(struct xdr_stream *xdr,
 }
 
 static int gssx_enc_call_ctx(struct xdr_stream *xdr,
-			     struct gssx_call_ctx *ctx)
+			     const struct gssx_call_ctx *ctx)
 {
 	struct gssx_option opt;
 	__be32 *p;
@@ -733,8 +733,9 @@ static int gssx_enc_cb(struct xdr_stream *xdr, struct gssx_cb *cb)
 
 void gssx_enc_accept_sec_context(struct rpc_rqst *req,
 				 struct xdr_stream *xdr,
-				 struct gssx_arg_accept_sec_context *arg)
+				 const void *data)
 {
+	const struct gssx_arg_accept_sec_context *arg = data;
 	int err;
 
 	err = gssx_enc_call_ctx(xdr, &arg->call_ctx);
diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.h b/net/sunrpc/auth_gss/gss_rpc_xdr.h
index 9d88c6239f01..87cd719ca0ad 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.h
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.h
@@ -179,7 +179,7 @@ struct gssx_res_accept_sec_context {
 #define gssx_dec_init_sec_context NULL
 void gssx_enc_accept_sec_context(struct rpc_rqst *req,
 				 struct xdr_stream *xdr,
-				 struct gssx_arg_accept_sec_context *args);
+				 const void *data);
 int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
 				struct xdr_stream *xdr,
 				struct gssx_res_accept_sec_context *res);
-- 
2.11.0

