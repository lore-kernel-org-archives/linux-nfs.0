From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 2: PATCH 22/26] gss_krb5: add "raw" session key to
	context to be used for deriving keys
Date: Wed, 30 Apr 2008 12:47:40 -0400
Message-ID: <20080430164740.16010.24030.stgit@jazz.citi.umich.edu>
References: <20080430164306.16010.44650.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:21235 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757482AbYD3Qrk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2008 12:47:40 -0400
In-Reply-To: <20080430164306.16010.44650.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Save the "raw" session key in the context.  This is needed for deriving
arcfour-hmac keys "on the fly" using the sequence number or checksum.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 include/linux/sunrpc/gss_krb5.h     |    1 +
 net/sunrpc/auth_gss/gss_krb5_mech.c |   27 +++++++++++++--------------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 9fa6fec..7c20495 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -101,6 +101,7 @@ struct krb5_ctx {
 	struct crypto_blkcipher *initiator_enc;
 	struct crypto_blkcipher *acceptor_enc_aux;
 	struct crypto_blkcipher *initiator_enc_aux;
+	u8			Ksess[GSS_KRB5_MAX_KEYLEN]; /* session key */
 	u8			cksum[GSS_KRB5_MAX_KEYLEN];
 	s32			endtime;
 	u32			seq_send;
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index d59c497..70232f5 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -341,7 +341,7 @@ set_cdata(u8 cdata[GSS_KRB5_K5CLENGTH], u32 usage, u8 seed)
 }
 
 static int
-context_derive_keys_des3(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
+context_derive_keys_des3(struct krb5_ctx *ctx)
 {
 	struct xdr_netobj c, keyin, keyout;
 	u8 cdata[GSS_KRB5_K5CLENGTH];
@@ -350,18 +350,18 @@ context_derive_keys_des3(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
 	c.len = GSS_KRB5_K5CLENGTH;
 	c.data = cdata;
 
-	keyin.data = rawkey;
-	keyin.len = keylen;
-	keyout.len = keylen;
+	keyin.data = ctx->Ksess;
+	keyin.len = ctx->gk5e->keylength;
+	keyout.len = ctx->gk5e->keylength;
 
 	/* seq uses the raw key */
 	ctx->seq = context_v2_alloc_cipher(ctx, ctx->gk5e->encrypt_name,
-					   rawkey);
+					   ctx->Ksess);
 	if (ctx->seq == NULL)
 		goto out_err;
 
 	ctx->enc = context_v2_alloc_cipher(ctx, ctx->gk5e->encrypt_name,
-					   rawkey);
+					   ctx->Ksess);
 	if (ctx->enc == NULL)
 		goto out_free_seq;
 
@@ -386,7 +386,7 @@ out_err:
 }
 
 static int
-context_derive_keys_new(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
+context_derive_keys_new(struct krb5_ctx *ctx)
 {
 	struct xdr_netobj c, keyin, keyout;
 	u8 cdata[GSS_KRB5_K5CLENGTH];
@@ -395,9 +395,9 @@ context_derive_keys_new(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
 	c.len = GSS_KRB5_K5CLENGTH;
 	c.data = cdata;
 
-	keyin.data = rawkey;
-	keyin.len = keylen;
-	keyout.len = keylen;
+	keyin.data = ctx->Ksess;
+	keyin.len = ctx->gk5e->keylength;
+	keyout.len = ctx->gk5e->keylength;
 
 	/* initiator seal encryption */
 	set_cdata(cdata, KG_USAGE_INITIATOR_SEAL, KEY_USAGE_SEED_ENCRYPTION);
@@ -499,7 +499,6 @@ out_err:
 static int
 gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
 {
-	u8 rawkey[GSS_KRB5_MAX_KEYLEN];
 	int keylen;
 
 	p = simple_get_bytes(p, end, &ctx->flags, sizeof(ctx->flags));
@@ -535,7 +534,7 @@ gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
 	}
 	keylen = ctx->gk5e->keylength;
 
-	p = simple_get_bytes(p, end, rawkey, keylen);
+	p = simple_get_bytes(p, end, ctx->Ksess, keylen);
 	if (IS_ERR(p))
 		goto out_err;
 
@@ -546,10 +545,10 @@ gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
 
 	switch (ctx->enctype) {
 	case ENCTYPE_DES3_CBC_RAW:
-		return context_derive_keys_des3(ctx, rawkey, keylen);
+		return context_derive_keys_des3(ctx);
 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
-		return context_derive_keys_new(ctx, rawkey, keylen);
+		return context_derive_keys_new(ctx);
 	default:
 		return -EINVAL;
 	}

