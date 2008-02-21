From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 09/19] gss_krb5: split up functions in preparation of adding
	new enctypes
Date: Thu, 21 Feb 2008 13:44:32 -0500
Message-ID: <20080221184432.19195.72324.stgit@jazz.citi.umich.edu>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:31131 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753997AbYBUSod (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 13:44:33 -0500
Received: from jazz.citi.umich.edu (jazz.citi.umich.edu [141.211.133.62])
	by citi.umich.edu (Postfix) with ESMTP id 904CB4602
	for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 13:44:32 -0500 (EST)
In-Reply-To: <20080221184208.19195.94518.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add encryption type to the krb5 context structure and use it to switch
to the correct functions depending on the encryption type.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 include/linux/sunrpc/gss_krb5.h       |    1 +
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    1 +
 net/sunrpc/auth_gss/gss_krb5_seal.c   |   21 ++++++++++++++--
 net/sunrpc/auth_gss/gss_krb5_unseal.c |   22 ++++++++++++++---
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |   44 +++++++++++++++++++++++++++++----
 5 files changed, 77 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 47d2110..dfe382a 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -42,6 +42,7 @@
 
 struct krb5_ctx {
 	int			initiate; /* 1 = initiating, 0 = accepting */
+	u32			enctype;
 	struct crypto_blkcipher	*enc;
 	struct crypto_blkcipher	*seq;
 	s32			endtime;
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 3c070d0..477cf07 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -137,6 +137,7 @@ gss_import_sec_context_kerberos(const void *p,
 	p = simple_get_bytes(p, end, &ctx->initiate, sizeof(ctx->initiate));
 	if (IS_ERR(p))
 		goto out_err_free_ctx;
+	ctx->enctype = ENCTYPE_DES_CBC_RAW;
 	/* The downcall format was designed before we completely understood
 	 * the uses of the context fields; so it includes some stuff we
 	 * just give some minimal sanity-checking, and some we ignore
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index e7b2a52..3b9cc47 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -71,11 +71,10 @@
 
 DEFINE_SPINLOCK(krb5_seq_lock);
 
-u32
-gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
+static u32
+gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
 		struct xdr_netobj *token)
 {
-	struct krb5_ctx		*ctx = gss_ctx->internal_ctx_id;
 	char			cksumdata[16];
 	struct xdr_netobj	md5cksum = {.len = 0, .data = cksumdata};
 	unsigned char		*ptr, *krb5_hdr, *msg_start;
@@ -121,3 +120,19 @@ gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
 
 	return (ctx->endtime < now) ? GSS_S_CONTEXT_EXPIRED : GSS_S_COMPLETE;
 }
+
+u32
+gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
+		     struct xdr_netobj *token)
+{
+	struct krb5_ctx		*ctx = gss_ctx->internal_ctx_id;
+
+	switch (ctx->enctype) {
+	case ENCTYPE_DES_CBC_RAW:
+		return gss_get_mic_v1(ctx, text, token);
+	default:
+		BUG();
+	}
+	return 0;
+}
+
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index e30a993..211eca4 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -71,11 +71,10 @@
 /* read_token is a mic token, and message_buffer is the data that the mic was
  * supposedly taken over. */
 
-u32
-gss_verify_mic_kerberos(struct gss_ctx *gss_ctx,
+static u32
+gss_verify_mic_v1(struct krb5_ctx *ctx,
 		struct xdr_buf *message_buffer, struct xdr_netobj *read_token)
 {
-	struct krb5_ctx		*ctx = gss_ctx->internal_ctx_id;
 	int			signalg;
 	int			sealalg;
 	char			cksumdata[16];
@@ -136,3 +135,20 @@ gss_verify_mic_kerberos(struct gss_ctx *gss_ctx,
 
 	return GSS_S_COMPLETE;
 }
+
+u32
+gss_verify_mic_kerberos(struct gss_ctx *gss_ctx,
+			struct xdr_buf *message_buffer,
+			struct xdr_netobj *read_token)
+{
+	struct krb5_ctx *ctx = gss_ctx->internal_ctx_id;
+
+	switch (ctx->enctype) {
+	case ENCTYPE_DES_CBC_RAW:
+		return gss_verify_mic_v1(ctx, message_buffer, read_token);
+	default:
+		BUG();
+	}
+	return 0;
+}
+
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 9763bf1..9f13411 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -98,11 +98,10 @@ make_confounder(char *p, int blocksize)
 
 /* XXX factor out common code with seal/unseal. */
 
-u32
-gss_wrap_kerberos(struct gss_ctx *ctx, int offset,
+static u32
+gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 		struct xdr_buf *buf, struct page **pages)
 {
-	struct krb5_ctx		*kctx = ctx->internal_ctx_id;
 	char			cksumdata[16];
 	struct xdr_netobj	md5cksum = {.len = 0, .data = cksumdata};
 	int			blocksize = 0, plainlen;
@@ -179,10 +178,9 @@ gss_wrap_kerberos(struct gss_ctx *ctx, int offset,
 	return (kctx->endtime < now) ? GSS_S_CONTEXT_EXPIRED : GSS_S_COMPLETE;
 }
 
-u32
-gss_unwrap_kerberos(struct gss_ctx *ctx, int offset, struct xdr_buf *buf)
+static u32
+gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 {
-	struct krb5_ctx		*kctx = ctx->internal_ctx_id;
 	int			signalg;
 	int			sealalg;
 	char			cksumdata[16];
@@ -270,3 +268,37 @@ gss_unwrap_kerberos(struct gss_ctx *ctx, int offset, struct xdr_buf *buf)
 
 	return GSS_S_COMPLETE;
 }
+
+u32
+gss_wrap_kerberos(struct gss_ctx *gctx, int offset,
+		  struct xdr_buf *buf, struct page **pages)
+{
+	struct krb5_ctx	*kctx = gctx->internal_ctx_id;
+
+	switch (kctx->enctype) {
+	case ENCTYPE_DES_CBC_RAW:
+		return gss_wrap_kerberos_v1(kctx, offset, buf, pages);
+		break;
+	default:
+		BUG();
+		break;
+	}
+	return 0;
+}
+
+u32
+gss_unwrap_kerberos(struct gss_ctx *gctx, int offset, struct xdr_buf *buf)
+{
+	struct krb5_ctx	*kctx = gctx->internal_ctx_id;
+
+	switch (kctx->enctype) {
+	case ENCTYPE_DES_CBC_RAW:
+		return gss_unwrap_kerberos_v1(kctx, offset, buf);
+		break;
+	default:
+		BUG();
+		break;
+	}
+	return 0;
+}
+

