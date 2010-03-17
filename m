From: steved@redhat.com
Subject: [PATCH 18/23] gss_krb5: Save the raw session key in the context
Date: Wed, 17 Mar 2010 13:03:03 -0400
Message-ID: <1268845388-9516-19-git-send-email-steved@redhat.com>
References: <1268845388-9516-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:43422 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755268Ab0CQR0J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 13:26:09 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1NrweJ-0003fC-2W
	for linux-nfs@vger.kernel.org; Wed, 17 Mar 2010 13:03:15 -0400
In-Reply-To: <1268845388-9516-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

This is needed for deriving arcfour-hmac keys "on the fly"
using the sequence number or checksu

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 include/linux/sunrpc/gss_krb5.h     |    1 +
 net/sunrpc/auth_gss/gss_krb5_mech.c |   27 +++++++++++++--------------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index b00725e..14c9b0c 100644
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
index fab8010..41549e5 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -344,7 +344,7 @@ set_cdata(u8 cdata[GSS_KRB5_K5CLENGTH], u32 usage, u8 seed)
 }
 
 static int
-context_derive_keys_des3(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
+context_derive_keys_des3(struct krb5_ctx *ctx)
 {
 	struct xdr_netobj c, keyin, keyout;
 	u8 cdata[GSS_KRB5_K5CLENGTH];
@@ -353,18 +353,18 @@ context_derive_keys_des3(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
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
 
@@ -389,7 +389,7 @@ out_err:
 }
 
 static int
-context_derive_keys_new(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
+context_derive_keys_new(struct krb5_ctx *ctx)
 {
 	struct xdr_netobj c, keyin, keyout;
 	u8 cdata[GSS_KRB5_K5CLENGTH];
@@ -398,9 +398,9 @@ context_derive_keys_new(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
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
@@ -502,7 +502,6 @@ out_err:
 static int
 gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
 {
-	u8 rawkey[GSS_KRB5_MAX_KEYLEN];
 	int keylen;
 
 	p = simple_get_bytes(p, end, &ctx->flags, sizeof(ctx->flags));
@@ -538,7 +537,7 @@ gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
 	}
 	keylen = ctx->gk5e->keylength;
 
-	p = simple_get_bytes(p, end, rawkey, keylen);
+	p = simple_get_bytes(p, end, ctx->Ksess, keylen);
 	if (IS_ERR(p))
 		goto out_err;
 
@@ -557,10 +556,10 @@ gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
 
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
-- 
1.6.6.1

