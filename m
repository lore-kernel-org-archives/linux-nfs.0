From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/22] gss_krb5: split up functions in preparation of adding new enctypes
Date: Wed, 14 Apr 2010 13:36:40 -0400
Message-ID: <1271266618-26016-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1271266618-26016-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-4-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28110 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756544Ab0DNRhS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Apr 2010 13:37:18 -0400
Received: from localhost.localdomain (pd07336a.hq.netapp.com [10.58.61.110] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3EHawK0021574
	for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2010 10:37:01 -0700 (PDT)
In-Reply-To: <1271266618-26016-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

Add encryption type to the krb5 context structure and use it to switch
to the correct functions depending on the encryption type.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/gss_krb5.h       |    1 +
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    1 +
 net/sunrpc/auth_gss/gss_krb5_seal.c   |   20 ++++++++++++++--
 net/sunrpc/auth_gss/gss_krb5_unseal.c |   21 +++++++++++++++--
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |   38 +++++++++++++++++++++++++++-----
 5 files changed, 69 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 31bb8a5..5378e45 100644
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
index 88fe6e7..71c2014 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -70,11 +70,10 @@
 
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
@@ -120,3 +119,18 @@ gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
 
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
index ce6c247..069d4b5 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -70,11 +70,10 @@
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
@@ -135,3 +134,19 @@ gss_verify_mic_kerberos(struct gss_ctx *gss_ctx,
 
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
index 5d6c3b1..b45b59b 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -124,11 +124,10 @@ make_confounder(char *p, u32 conflen)
 
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
@@ -203,10 +202,9 @@ gss_wrap_kerberos(struct gss_ctx *ctx, int offset,
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
@@ -294,3 +292,31 @@ gss_unwrap_kerberos(struct gss_ctx *ctx, int offset, struct xdr_buf *buf)
 
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

