From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 2: PATCH 07/26] gss_krb5: split up functions in
	preparation of adding new enctypes
Date: Wed, 30 Apr 2008 12:46:24 -0400
Message-ID: <20080430164624.16010.92034.stgit@jazz.citi.umich.edu>
References: <20080430164306.16010.44650.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:39519 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757217AbYD3QqY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2008 12:46:24 -0400
In-Reply-To: <20080430164306.16010.44650.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add encryption type to the krb5 context structure and use it to switch
to the correct functions depending on the encryption type.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 include/linux/sunrpc/gss_krb5.h       |    1 +
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    1 +
 net/sunrpc/auth_gss/gss_krb5_seal.c   |   20 +++++++++++++++--
 net/sunrpc/auth_gss/gss_krb5_unseal.c |   21 ++++++++++++++++--
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |   38 ++++++++++++++++++++++++++++-----
 5 files changed, 69 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 65003b2..aa99e57 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -48,6 +48,7 @@
 
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
index b8f42ef..6319b33 100644
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
 	unsigned char		*ptr, *msg_start;
@@ -121,3 +120,18 @@ gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
 
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
+	default:
+		BUG();
+	case ENCTYPE_DES_CBC_RAW:
+		return gss_get_mic_v1(ctx, text, token);
+	}
+}
+
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index 066ec73..945609a 100644
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
@@ -136,3 +135,19 @@ gss_verify_mic_kerberos(struct gss_ctx *gss_ctx,
 
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
+	default:
+		BUG();
+	case ENCTYPE_DES_CBC_RAW:
+		return gss_verify_mic_v1(ctx, message_buffer, read_token);
+	}
+}
+
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 4c14b0a..743fa92 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -125,11 +125,10 @@ make_confounder(char *p, u32 conflen)
 
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
@@ -205,10 +204,9 @@ gss_wrap_kerberos(struct gss_ctx *ctx, int offset,
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
@@ -296,3 +294,31 @@ gss_unwrap_kerberos(struct gss_ctx *ctx, int offset, struct xdr_buf *buf)
 
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
+	default:
+		BUG();
+	case ENCTYPE_DES_CBC_RAW:
+		return gss_wrap_kerberos_v1(kctx, offset, buf, pages);
+	}
+}
+
+u32
+gss_unwrap_kerberos(struct gss_ctx *gctx, int offset, struct xdr_buf *buf)
+{
+	struct krb5_ctx	*kctx = gctx->internal_ctx_id;
+
+	switch (kctx->enctype) {
+	default:
+		BUG();
+	case ENCTYPE_DES_CBC_RAW:
+		return gss_unwrap_kerberos_v1(kctx, offset, buf);
+	}
+}
+

