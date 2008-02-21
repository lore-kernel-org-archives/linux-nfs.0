From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 14/19] gss_krb5: use a global static OID value for krb5
Date: Thu, 21 Feb 2008 13:44:57 -0500
Message-ID: <20080221184457.19195.24574.stgit@jazz.citi.umich.edu>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:36623 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754755AbYBUSo7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 13:44:59 -0500
Received: from jazz.citi.umich.edu (jazz.citi.umich.edu [141.211.133.62])
	by citi.umich.edu (Postfix) with ESMTP id E0AE3460B
	for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 13:44:57 -0500 (EST)
In-Reply-To: <20080221184208.19195.94518.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rather than depend on the mechanism oid passed down with the context
information, use a static version.  The new context format introduced
later will not include the oid.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 net/sunrpc/auth_gss/gss_krb5_seal.c   |    4 ++--
 net/sunrpc/auth_gss/gss_krb5_unseal.c |    2 +-
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |    6 +++---
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index f5badc7..285188d 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -77,10 +77,10 @@ setup_token(struct krb5_ctx *ctx, struct xdr_netobj *token)
 	__be16 *ptr, *krb5_hdr;
 	int body_size = 16 + ctx->gk5e->cksumlength;
 
-	token->len = g_token_size(&ctx->mech_used, body_size);
+	token->len = g_token_size(&krb5_oid, body_size);
 
 	ptr = (__be16 *)token->data;
-	g_make_token_header(&ctx->mech_used, body_size, (unsigned char **)&ptr);
+	g_make_token_header(&krb5_oid, body_size, (unsigned char **)&ptr);
 
 	/* ptr now at start of header described in rfc 1964, section 1.2.1: */
 	krb5_hdr = ptr;
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index 5494ba4..c9adcfc 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -89,7 +89,7 @@ gss_verify_mic_v1(struct krb5_ctx *ctx,
 
 	dprintk("RPC:       krb5_read_token\n");
 
-	if (g_verify_token_header(&ctx->mech_used, &bodysize, &ptr,
+	if (g_verify_token_header(&krb5_oid, &bodysize, &ptr,
 					read_token->len))
 		return GSS_S_DEFECTIVE_TOKEN;
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index dd6caf3..a68677c 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -122,7 +122,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	BUG_ON((buf->len - offset) % blocksize);
 	plainlen = blocksize + buf->len - offset;
 
-	headlen = g_token_size(&kctx->mech_used,
+	headlen = g_token_size(&krb5_oid,
 		16 + kctx->gk5e->cksumlength + plainlen) - (buf->len - offset);
 
 	ptr = buf->head[0].iov_base + offset;
@@ -134,7 +134,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	buf->len += headlen;
 	BUG_ON((buf->len - offset - headlen) % blocksize);
 
-	g_make_token_header(&kctx->mech_used,
+	g_make_token_header(&krb5_oid,
 				16 + kctx->gk5e->cksumlength + plainlen, &ptr);
 
 
@@ -205,7 +205,7 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	dprintk("RPC:       gss_unwrap_kerberos\n");
 
 	ptr = (u8 *)buf->head[0].iov_base + offset;
-	if (g_verify_token_header(&kctx->mech_used, &bodysize, &ptr,
+	if (g_verify_token_header(&krb5_oid, &bodysize, &ptr,
 					buf->len - offset))
 		return GSS_S_DEFECTIVE_TOKEN;
 

