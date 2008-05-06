From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 3: PATCH 20/24] gss_krb5: add "raw" session key to
	context to be used for deriving keys
Date: Tue, 06 May 2008 17:05:14 -0400
Message-ID: <20080506210514.3770.68017.stgit@jazz.citi.umich.edu>
References: <20080506210156.3770.95914.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:34990 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764339AbYEFVFP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 17:05:15 -0400
In-Reply-To: <20080506210156.3770.95914.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
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
index ddadc3a..9753485 100644
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
index f626e4b..5564d6b 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -343,7 +343,7 @@ set_cdata(u8 cdata[GSS_KRB5_K5CLENGTH], u32 usage, u8 seed)
 }
 
 static int
-context_derive_keys_des3(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
+context_derive_keys_des3(struct krb5_ctx *ctx)
 {
 	struct xdr_netobj c, keyin, keyout;
 	u8 cdata[GSS_KRB5_K5CLENGTH];
@@ -352,18 +352,18 @@ context_derive_keys_des3(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
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
 
@@ -388,7 +388,7 @@ out_err:
 }
 
 static int
-context_derive_keys_new(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
+context_derive_keys_new(struct krb5_ctx *ctx)
 {
 	struct xdr_netobj c, keyin, keyout;
 	u8 cdata[GSS_KRB5_K5CLENGTH];
@@ -397,9 +397,9 @@ context_derive_keys_new(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
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
@@ -501,7 +501,6 @@ out_err:
 static int
 gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
 {
-	u8 rawkey[GSS_KRB5_MAX_KEYLEN];
 	int keylen;
 
 	p = simple_get_bytes(p, end, &ctx->flags, sizeof(ctx->flags));
@@ -537,7 +536,7 @@ gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
 	}
 	keylen = ctx->gk5e->keylength;
 
-	p = simple_get_bytes(p, end, rawkey, keylen);
+	p = simple_get_bytes(p, end, ctx->Ksess, keylen);
 	if (IS_ERR(p))
 		goto out_err;
 
@@ -556,10 +555,10 @@ gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
 
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

