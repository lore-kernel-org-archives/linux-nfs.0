From: steved@redhat.com
Subject: [PATCH 03/22] gss_krb5: gss_krb5: split up functions in preparation of adding new enctypes
Date: Mon, 15 Mar 2010 08:20:08 -0400
Message-ID: <1268655627-18712-4-git-send-email-steved@redhat.com>
References: <1268655627-18712-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:41143 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964915Ab0CON0M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Mar 2010 09:26:12 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Nr9HY-00009j-Ot
	for linux-nfs@vger.kernel.org; Mon, 15 Mar 2010 08:20:28 -0400
In-Reply-To: <1268655627-18712-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

Add encryption type to the krb5 context structure and use it to switch
to the correct functions depending on the encryption type.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 include/linux/sunrpc/gss_krb5.h       |    1 +
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    1 +
 net/sunrpc/auth_gss/gss_krb5_seal.c   |   20 ++++++++++++++--
 net/sunrpc/auth_gss/gss_krb5_unseal.c |   21 +++++++++++++++--
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |   38 +++++++++++++++++++++++++++-----
 5 files changed, 69 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 5bb227e..12bd0dd 100644
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
index 2deb0ed..0cd940e 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -139,6 +139,7 @@ gss_import_sec_context_kerberos(const void *p,
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
-- 
1.6.6.1

