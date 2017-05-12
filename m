Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:59403 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932610AbdELQRg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 12:17:36 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 09/33] sunrpc/auth_gss: fix decoder callback prototypes
Date: Fri, 12 May 2017 18:16:37 +0200
Message-Id: <20170512161701.22468-10-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Declare the p_decode callbacks with the proper prototype instead of
casting to kxdrdproc_t and losing all type safety.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/auth_gss/gss_rpc_upcall.c | 2 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.c    | 3 ++-
 net/sunrpc/auth_gss/gss_rpc_xdr.h    | 2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
index 45ab924da726..a80b8e607478 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -56,7 +56,7 @@ enum {
 [GSSX_##proc] = {					\
 	.p_proc   = GSSX_##proc,			\
 	.p_encode = gssx_enc_##name,	\
-	.p_decode = (kxdrdproc_t)gssx_dec_##name,	\
+	.p_decode = gssx_dec_##name,	\
 	.p_arglen = GSSX_ARG_##name##_sz,		\
 	.p_replen = GSSX_RES_##name##_sz, 		\
 	.p_statidx = GSSX_##proc,			\
diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
index 5e54f4743092..c4778cae58ef 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
@@ -790,8 +790,9 @@ void gssx_enc_accept_sec_context(struct rpc_rqst *req,
 
 int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
 				struct xdr_stream *xdr,
-				struct gssx_res_accept_sec_context *res)
+				void *data)
 {
+	struct gssx_res_accept_sec_context *res = data;
 	u32 value_follows;
 	int err;
 	struct page *scratch;
diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.h b/net/sunrpc/auth_gss/gss_rpc_xdr.h
index 87cd719ca0ad..146c31032917 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.h
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.h
@@ -182,7 +182,7 @@ void gssx_enc_accept_sec_context(struct rpc_rqst *req,
 				 const void *data);
 int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
 				struct xdr_stream *xdr,
-				struct gssx_res_accept_sec_context *res);
+				void *data);
 #define gssx_enc_release_handle NULL
 #define gssx_dec_release_handle NULL
 #define gssx_enc_get_mic NULL
-- 
2.11.0

