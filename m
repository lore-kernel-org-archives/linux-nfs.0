From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 18/22] gss_krb5: Save the raw session key in the context
Date: Wed, 14 Apr 2010 13:36:54 -0400
Message-ID: <1271266618-26016-19-git-send-email-Trond.Myklebust@netapp.com>
References: <1271266618-26016-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-6-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-7-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-8-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-9-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-10-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-11-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-12-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-13-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-14-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-15-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-16-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-17-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-18-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48907 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756572Ab0DNRhV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Apr 2010 13:37:21 -0400
Received: from localhost.localdomain (pd07336a.hq.netapp.com [10.58.61.110] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3EHawKE021574
	for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2010 10:37:09 -0700 (PDT)
In-Reply-To: <1271266618-26016-18-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

This is needed for deriving arcfour-hmac keys "on the fly"
using the sequence number or checksu

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/gss_krb5.h     |    1 +
 net/sunrpc/auth_gss/gss_krb5_mech.c |   27 +++++++++++++--------------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 633f41f..b0ab827 100644
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
index 166dd19..6908d38 100644
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

