From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 2: PATCH 12/26] gss_krb5: use a global static OID
	value for krb5
Date: Wed, 30 Apr 2008 12:46:49 -0400
Message-ID: <20080430164649.16010.13286.stgit@jazz.citi.umich.edu>
References: <20080430164306.16010.44650.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:46145 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757482AbYD3Qqt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2008 12:46:49 -0400
In-Reply-To: <20080430164306.16010.44650.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
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
index c4df7af..58563be 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -77,10 +77,10 @@ setup_token(struct krb5_ctx *ctx, struct xdr_netobj *token)
 	__be16 *ptr, *krb5_hdr;
 	int body_size = GSS_KRB5_TOK_HDR_LEN + ctx->gk5e->cksumlength;
 
-	token->len = g_token_size(&ctx->mech_used, body_size);
+	token->len = g_token_size(&krb5_oid, body_size);
 
 	ptr = (__be16 *)token->data;
-	g_make_token_header(&ctx->mech_used, body_size, (unsigned char **)&ptr);
+	g_make_token_header(&krb5_oid, body_size, (unsigned char **)&ptr);
 
 	/* ptr now at start of header described in rfc 1964, section 1.2.1: */
 	krb5_hdr = ptr;
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index aff3fce..d405943 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -89,7 +89,7 @@ gss_verify_mic_v1(struct krb5_ctx *ctx,
 
 	dprintk("RPC:       krb5_read_token\n");
 
-	if (g_verify_token_header(&ctx->mech_used, &bodysize, &ptr,
+	if (g_verify_token_header(&krb5_oid, &bodysize, &ptr,
 					read_token->len))
 		return GSS_S_DEFECTIVE_TOKEN;
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index f034af3..2e4ab81 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -180,7 +180,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	BUG_ON((buf->len - offset) % blocksize);
 	plainlen = blocksize + buf->len - offset;
 
-	headlen = g_token_size(&kctx->mech_used,
+	headlen = g_token_size(&krb5_oid,
 		GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength + plainlen) -
 		(buf->len - offset);
 
@@ -191,7 +191,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	/* XXX Would be cleverer to encrypt while copying. */
 	BUG_ON((buf->len - offset - headlen) % blocksize);
 
-	g_make_token_header(&kctx->mech_used,
+	g_make_token_header(&krb5_oid,
 				GSS_KRB5_TOK_HDR_LEN +
 				kctx->gk5e->cksumlength + plainlen, &ptr);
 
@@ -262,7 +262,7 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	dprintk("RPC:       gss_unwrap_kerberos\n");
 
 	ptr = (u8 *)buf->head[0].iov_base + offset;
-	if (g_verify_token_header(&kctx->mech_used, &bodysize, &ptr,
+	if (g_verify_token_header(&krb5_oid, &bodysize, &ptr,
 					buf->len - offset))
 		return GSS_S_DEFECTIVE_TOKEN;
 

