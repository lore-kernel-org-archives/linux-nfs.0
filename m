From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/22] gss_krb5: handle new context format from gssd
Date: Wed, 14 Apr 2010 13:36:45 -0400
Message-ID: <1271266618-26016-10-git-send-email-Trond.Myklebust@netapp.com>
References: <1271266618-26016-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-6-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-7-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-8-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-9-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28110 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756543Ab0DNRhT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Apr 2010 13:37:19 -0400
Received: from localhost.localdomain (pd07336a.hq.netapp.com [10.58.61.110] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3EHawK5021574
	for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2010 10:37:04 -0700 (PDT)
In-Reply-To: <1271266618-26016-9-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

For encryption types other than DES, gssd sends down context information
in a new format.  This new format includes the information needed to
support the new Kerberos GSS-API tokens defined in rfc4121.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/gss_krb5.h     |   23 +++-
 net/sunrpc/auth_gss/gss_krb5_keys.c |    2 +-
 net/sunrpc/auth_gss/gss_krb5_mech.c |  237 ++++++++++++++++++++++++++++++++++-
 3 files changed, 258 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index d31ba03..04d5279 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -72,21 +72,36 @@ struct gss_krb5_enctype {
 	u32 (*decrypt) (struct crypto_blkcipher *tfm,
 			void *iv, void *in, void *out,
 			int length);		/* decryption function */
-	u32 (*mk_key) (struct gss_krb5_enctype *gk5e,
+	u32 (*mk_key) (const struct gss_krb5_enctype *gk5e,
 		       struct xdr_netobj *in,
 		       struct xdr_netobj *out);	/* complete key generation */
 };
 
+/* krb5_ctx flags definitions */
+#define KRB5_CTX_FLAG_INITIATOR         0x00000001
+#define KRB5_CTX_FLAG_CFX               0x00000002
+#define KRB5_CTX_FLAG_ACCEPTOR_SUBKEY   0x00000004
+
 struct krb5_ctx {
 	int			initiate; /* 1 = initiating, 0 = accepting */
 	u32			enctype;
+	u32			flags;
 	const struct gss_krb5_enctype *gk5e; /* enctype-specific info */
 	struct crypto_blkcipher	*enc;
 	struct crypto_blkcipher	*seq;
+	struct crypto_blkcipher *acceptor_enc;
+	struct crypto_blkcipher *initiator_enc;
 	u8			cksum[GSS_KRB5_MAX_KEYLEN];
 	s32			endtime;
 	u32			seq_send;
+	u64			seq_send64;
 	struct xdr_netobj	mech_used;
+	u8			initiator_sign[GSS_KRB5_MAX_KEYLEN];
+	u8			acceptor_sign[GSS_KRB5_MAX_KEYLEN];
+	u8			initiator_seal[GSS_KRB5_MAX_KEYLEN];
+	u8			acceptor_seal[GSS_KRB5_MAX_KEYLEN];
+	u8			initiator_integ[GSS_KRB5_MAX_KEYLEN];
+	u8			acceptor_integ[GSS_KRB5_MAX_KEYLEN];
 };
 
 extern spinlock_t krb5_seq_lock;
@@ -151,6 +166,10 @@ enum seal_alg {
 #define ENCTYPE_DES3_CBC_RAW    0x0006	/* DES-3 cbc mode raw */
 #define ENCTYPE_DES_HMAC_SHA1   0x0008
 #define ENCTYPE_DES3_CBC_SHA1   0x0010
+#define ENCTYPE_AES128_CTS_HMAC_SHA1_96 0x0011
+#define ENCTYPE_AES256_CTS_HMAC_SHA1_96 0x0012
+#define ENCTYPE_ARCFOUR_HMAC            0x0017
+#define ENCTYPE_ARCFOUR_HMAC_EXP        0x0018
 #define ENCTYPE_UNKNOWN         0x01ff
 
 /*
@@ -238,7 +257,7 @@ int
 xdr_extend_head(struct xdr_buf *buf, unsigned int base, unsigned int shiftlen);
 
 u32
-krb5_derive_key(struct gss_krb5_enctype *gk5e,
+krb5_derive_key(const struct gss_krb5_enctype *gk5e,
 		const struct xdr_netobj *inkey,
 		struct xdr_netobj *outkey,
 		const struct xdr_netobj *in_constant);
diff --git a/net/sunrpc/auth_gss/gss_krb5_keys.c b/net/sunrpc/auth_gss/gss_krb5_keys.c
index 832ce90..253b414 100644
--- a/net/sunrpc/auth_gss/gss_krb5_keys.c
+++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
@@ -147,7 +147,7 @@ static void krb5_nfold(u32 inbits, const u8 *in,
  * Taken from MIT Kerberos and modified.
  */
 
-u32 krb5_derive_key(struct gss_krb5_enctype *gk5e,
+u32 krb5_derive_key(const struct gss_krb5_enctype *gk5e,
 		    const struct xdr_netobj *inkey,
 		    struct xdr_netobj *outkey,
 		    const struct xdr_netobj *in_constant)
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index fdf0eb2..8b612e7 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -48,6 +48,8 @@
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
 
+static struct gss_api_mech gss_kerberos_mech;	/* forward declaration */
+
 static const struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
 	/*
 	 * DES (All DES enctypes are mapped to the same gss functionality)
@@ -247,6 +249,237 @@ out_err:
 	return PTR_ERR(p);
 }
 
+struct crypto_blkcipher *
+context_v2_alloc_cipher(struct krb5_ctx *ctx, u8 *key)
+{
+	struct crypto_blkcipher *cp;
+
+	cp = crypto_alloc_blkcipher(ctx->gk5e->encrypt_name,
+					0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(cp)) {
+		dprintk("gss_kerberos_mech: unable to initialize "
+			"crypto algorithm %s\n", ctx->gk5e->encrypt_name);
+		return NULL;
+	}
+	if (crypto_blkcipher_setkey(cp, key, ctx->gk5e->keylength)) {
+		dprintk("gss_kerberos_mech: error setting key for "
+			"crypto algorithm %s\n", ctx->gk5e->encrypt_name);
+		crypto_free_blkcipher(cp);
+		return NULL;
+	}
+	return cp;
+}
+
+static inline void
+set_cdata(u8 cdata[GSS_KRB5_K5CLENGTH], u32 usage, u8 seed)
+{
+	cdata[0] = (usage>>24)&0xff;
+	cdata[1] = (usage>>16)&0xff;
+	cdata[2] = (usage>>8)&0xff;
+	cdata[3] = usage&0xff;
+	cdata[4] = seed;
+}
+
+static int
+context_derive_keys_des3(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
+{
+	struct xdr_netobj c, keyin, keyout;
+	u8 cdata[GSS_KRB5_K5CLENGTH];
+	u32 err;
+
+	c.len = GSS_KRB5_K5CLENGTH;
+	c.data = cdata;
+
+	keyin.data = rawkey;
+	keyin.len = keylen;
+	keyout.len = keylen;
+
+	/* seq uses the raw key */
+	ctx->seq = context_v2_alloc_cipher(ctx, rawkey);
+	if (ctx->seq == NULL)
+		goto out_err;
+
+	ctx->enc = context_v2_alloc_cipher(ctx, rawkey);
+	if (ctx->enc == NULL)
+		goto out_free_seq;
+
+	/* derive cksum */
+	set_cdata(cdata, KG_USAGE_SIGN, KEY_USAGE_SEED_CHECKSUM);
+	keyout.data = ctx->cksum;
+	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c);
+	if (err) {
+		dprintk("%s: Error %d deriving cksum key\n",
+			__func__, err);
+		goto out_free_enc;
+	}
+
+	return 0;
+
+out_free_enc:
+	crypto_free_blkcipher(ctx->enc);
+out_free_seq:
+	crypto_free_blkcipher(ctx->seq);
+out_err:
+	return -EINVAL;
+}
+
+static int
+context_derive_keys_new(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
+{
+	struct xdr_netobj c, keyin, keyout;
+	u8 cdata[GSS_KRB5_K5CLENGTH];
+	u32 err;
+
+	c.len = GSS_KRB5_K5CLENGTH;
+	c.data = cdata;
+
+	keyin.data = rawkey;
+	keyin.len = keylen;
+	keyout.len = keylen;
+
+	/* initiator seal encryption */
+	set_cdata(cdata, KG_USAGE_INITIATOR_SEAL, KEY_USAGE_SEED_ENCRYPTION);
+	keyout.data = ctx->initiator_seal;
+	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c);
+	if (err) {
+		dprintk("%s: Error %d deriving initiator_seal key\n",
+			__func__, err);
+		goto out_err;
+	}
+	ctx->initiator_enc = context_v2_alloc_cipher(ctx, ctx->initiator_seal);
+	if (ctx->initiator_enc == NULL)
+		goto out_err;
+
+	/* acceptor seal encryption */
+	set_cdata(cdata, KG_USAGE_ACCEPTOR_SEAL, KEY_USAGE_SEED_ENCRYPTION);
+	keyout.data = ctx->acceptor_seal;
+	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c);
+	if (err) {
+		dprintk("%s: Error %d deriving acceptor_seal key\n",
+			__func__, err);
+		goto out_free_initiator_enc;
+	}
+	ctx->acceptor_enc = context_v2_alloc_cipher(ctx, ctx->acceptor_seal);
+	if (ctx->acceptor_enc == NULL)
+		goto out_free_initiator_enc;
+
+	/* initiator sign checksum */
+	set_cdata(cdata, KG_USAGE_INITIATOR_SIGN, KEY_USAGE_SEED_CHECKSUM);
+	keyout.data = ctx->initiator_sign;
+	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c);
+	if (err) {
+		dprintk("%s: Error %d deriving initiator_sign key\n",
+			__func__, err);
+		goto out_free_acceptor_enc;
+	}
+
+	/* acceptor sign checksum */
+	set_cdata(cdata, KG_USAGE_ACCEPTOR_SIGN, KEY_USAGE_SEED_CHECKSUM);
+	keyout.data = ctx->acceptor_sign;
+	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c);
+	if (err) {
+		dprintk("%s: Error %d deriving acceptor_sign key\n",
+			__func__, err);
+		goto out_free_acceptor_enc;
+	}
+
+	/* initiator seal integrity */
+	set_cdata(cdata, KG_USAGE_INITIATOR_SEAL, KEY_USAGE_SEED_INTEGRITY);
+	keyout.data = ctx->initiator_integ;
+	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c);
+	if (err) {
+		dprintk("%s: Error %d deriving initiator_integ key\n",
+			__func__, err);
+		goto out_free_acceptor_enc;
+	}
+
+	/* acceptor seal integrity */
+	set_cdata(cdata, KG_USAGE_ACCEPTOR_SEAL, KEY_USAGE_SEED_INTEGRITY);
+	keyout.data = ctx->acceptor_integ;
+	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c);
+	if (err) {
+		dprintk("%s: Error %d deriving acceptor_integ key\n",
+			__func__, err);
+		goto out_free_acceptor_enc;
+	}
+
+	return 0;
+
+out_free_acceptor_enc:
+	crypto_free_blkcipher(ctx->acceptor_enc);
+out_free_initiator_enc:
+	crypto_free_blkcipher(ctx->initiator_enc);
+out_err:
+	return -EINVAL;
+}
+
+static int
+gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
+{
+	u8 rawkey[GSS_KRB5_MAX_KEYLEN];
+	int keylen;
+
+	p = simple_get_bytes(p, end, &ctx->flags, sizeof(ctx->flags));
+	if (IS_ERR(p))
+		goto out_err;
+	ctx->initiate = ctx->flags & KRB5_CTX_FLAG_INITIATOR;
+
+	p = simple_get_bytes(p, end, &ctx->endtime, sizeof(ctx->endtime));
+	if (IS_ERR(p))
+		goto out_err;
+	p = simple_get_bytes(p, end, &ctx->seq_send64, sizeof(ctx->seq_send64));
+	if (IS_ERR(p))
+		goto out_err;
+	/* set seq_send for use by "older" enctypes */
+	ctx->seq_send = ctx->seq_send64;
+	if (ctx->seq_send64 != ctx->seq_send) {
+		dprintk("%s: seq_send64 %lx, seq_send %x overflow?\n", __func__,
+			(long unsigned)ctx->seq_send64, ctx->seq_send);
+		goto out_err;
+	}
+	p = simple_get_bytes(p, end, &ctx->enctype, sizeof(ctx->enctype));
+	if (IS_ERR(p))
+		goto out_err;
+	ctx->gk5e = get_gss_krb5_enctype(ctx->enctype);
+	if (ctx->gk5e == NULL) {
+		dprintk("gss_kerberos_mech: unsupported krb5 enctype %u\n",
+			ctx->enctype);
+		p = ERR_PTR(-EINVAL);
+		goto out_err;
+	}
+	keylen = ctx->gk5e->keylength;
+
+	p = simple_get_bytes(p, end, rawkey, keylen);
+	if (IS_ERR(p))
+		goto out_err;
+
+	if (p != end) {
+		p = ERR_PTR(-EINVAL);
+		goto out_err;
+	}
+
+	ctx->mech_used.data = kmemdup(gss_kerberos_mech.gm_oid.data,
+				      gss_kerberos_mech.gm_oid.len, GFP_KERNEL);
+	if (unlikely(ctx->mech_used.data == NULL)) {
+		p = ERR_PTR(-ENOMEM);
+		goto out_err;
+	}
+	ctx->mech_used.len = gss_kerberos_mech.gm_oid.len;
+
+	switch (ctx->enctype) {
+	case ENCTYPE_DES3_CBC_RAW:
+		return context_derive_keys_des3(ctx, rawkey, keylen);
+	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
+	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
+		return context_derive_keys_new(ctx, rawkey, keylen);
+	default:
+		return -EINVAL;
+	}
+
+out_err:
+	return PTR_ERR(p);
+}
+
 static int
 gss_import_sec_context_kerberos(const void *p, size_t len,
 				struct gss_ctx *ctx_id)
@@ -262,7 +495,7 @@ gss_import_sec_context_kerberos(const void *p, size_t len,
 	if (len == 85)
 		ret = gss_import_v1_context(p, end, ctx);
 	else
-		ret = -EINVAL;
+		ret = gss_import_v2_context(p, end, ctx);
 
 	if (ret == 0)
 		ctx_id->internal_ctx_id = ctx;
@@ -279,6 +512,8 @@ gss_delete_sec_context_kerberos(void *internal_ctx) {
 
 	crypto_free_blkcipher(kctx->seq);
 	crypto_free_blkcipher(kctx->enc);
+	crypto_free_blkcipher(kctx->acceptor_enc);
+	crypto_free_blkcipher(kctx->initiator_enc);
 	kfree(kctx->mech_used.data);
 	kfree(kctx);
 }
-- 
1.6.6.1

