Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63543 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751326Ab0EMVIY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 17:08:24 -0400
Received: from localhost.localdomain (heimdal.trondhjem.org [10.58.49.73] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4DL8MCM021257
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 14:08:23 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/15] NFS: Don't use GFP_KERNEL in rpcsec_gss downcalls
Date: Thu, 13 May 2010 17:08:09 -0400
Message-Id: <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Again, we can deadlock if the memory reclaim triggers a writeback that
requires a rpcsec_gss credential lookup.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/gss_api.h        |    6 +++-
 include/linux/sunrpc/gss_krb5.h       |    3 +-
 net/sunrpc/auth_gss/auth_gss.c        |    2 +-
 net/sunrpc/auth_gss/gss_krb5_keys.c   |    9 ++++---
 net/sunrpc/auth_gss/gss_krb5_mech.c   |   34 +++++++++++++++++---------------
 net/sunrpc/auth_gss/gss_mech_switch.c |    7 +++--
 net/sunrpc/auth_gss/gss_spkm3_mech.c  |    5 ++-
 net/sunrpc/auth_gss/svcauth_gss.c     |    2 +-
 8 files changed, 38 insertions(+), 30 deletions(-)

diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index b22d7f1..5d8048b 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -35,7 +35,8 @@ int gss_import_sec_context(
 		const void*		input_token,
 		size_t			bufsize,
 		struct gss_api_mech	*mech,
-		struct gss_ctx		**ctx_id);
+		struct gss_ctx		**ctx_id,
+		gfp_t			gfp_mask);
 u32 gss_get_mic(
 		struct gss_ctx		*ctx_id,
 		struct xdr_buf		*message,
@@ -89,7 +90,8 @@ struct gss_api_ops {
 	int (*gss_import_sec_context)(
 			const void		*input_token,
 			size_t			bufsize,
-			struct gss_ctx		*ctx_id);
+			struct gss_ctx		*ctx_id,
+			gfp_t			gfp_mask);
 	u32 (*gss_get_mic)(
 			struct gss_ctx		*ctx_id,
 			struct xdr_buf		*message,
diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 5e774a5..5af2931 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -295,7 +295,8 @@ u32
 krb5_derive_key(const struct gss_krb5_enctype *gk5e,
 		const struct xdr_netobj *inkey,
 		struct xdr_netobj *outkey,
-		const struct xdr_netobj *in_constant);
+		const struct xdr_netobj *in_constant,
+		gfp_t gfp_mask);
 
 u32
 gss_krb5_des3_make_key(const struct gss_krb5_enctype *gk5e,
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 6654c85..48a7939 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -229,7 +229,7 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
 		p = ERR_PTR(-EFAULT);
 		goto err;
 	}
-	ret = gss_import_sec_context(p, seclen, gm, &ctx->gc_gss_ctx);
+	ret = gss_import_sec_context(p, seclen, gm, &ctx->gc_gss_ctx, GFP_NOFS);
 	if (ret < 0) {
 		p = ERR_PTR(ret);
 		goto err;
diff --git a/net/sunrpc/auth_gss/gss_krb5_keys.c b/net/sunrpc/auth_gss/gss_krb5_keys.c
index 33b87f0..76e42e6 100644
--- a/net/sunrpc/auth_gss/gss_krb5_keys.c
+++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
@@ -150,7 +150,8 @@ static void krb5_nfold(u32 inbits, const u8 *in,
 u32 krb5_derive_key(const struct gss_krb5_enctype *gk5e,
 		    const struct xdr_netobj *inkey,
 		    struct xdr_netobj *outkey,
-		    const struct xdr_netobj *in_constant)
+		    const struct xdr_netobj *in_constant,
+		    gfp_t gfp_mask)
 {
 	size_t blocksize, keybytes, keylength, n;
 	unsigned char *inblockdata, *outblockdata, *rawkey;
@@ -175,15 +176,15 @@ u32 krb5_derive_key(const struct gss_krb5_enctype *gk5e,
 	/* allocate and set up buffers */
 
 	ret = ENOMEM;
-	inblockdata = kmalloc(blocksize, GFP_KERNEL);
+	inblockdata = kmalloc(blocksize, gfp_mask);
 	if (inblockdata == NULL)
 		goto err_free_cipher;
 
-	outblockdata = kmalloc(blocksize, GFP_KERNEL);
+	outblockdata = kmalloc(blocksize, gfp_mask);
 	if (outblockdata == NULL)
 		goto err_free_in;
 
-	rawkey = kmalloc(keybytes, GFP_KERNEL);
+	rawkey = kmalloc(keybytes, gfp_mask);
 	if (rawkey == NULL)
 		goto err_free_out;
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 7c249a3..0326446 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -369,7 +369,7 @@ set_cdata(u8 cdata[GSS_KRB5_K5CLENGTH], u32 usage, u8 seed)
 }
 
 static int
-context_derive_keys_des3(struct krb5_ctx *ctx)
+context_derive_keys_des3(struct krb5_ctx *ctx, gfp_t gfp_mask)
 {
 	struct xdr_netobj c, keyin, keyout;
 	u8 cdata[GSS_KRB5_K5CLENGTH];
@@ -396,7 +396,7 @@ context_derive_keys_des3(struct krb5_ctx *ctx)
 	/* derive cksum */
 	set_cdata(cdata, KG_USAGE_SIGN, KEY_USAGE_SEED_CHECKSUM);
 	keyout.data = ctx->cksum;
-	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c);
+	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c, gfp_mask);
 	if (err) {
 		dprintk("%s: Error %d deriving cksum key\n",
 			__func__, err);
@@ -487,7 +487,7 @@ out_err:
 }
 
 static int
-context_derive_keys_new(struct krb5_ctx *ctx)
+context_derive_keys_new(struct krb5_ctx *ctx, gfp_t gfp_mask)
 {
 	struct xdr_netobj c, keyin, keyout;
 	u8 cdata[GSS_KRB5_K5CLENGTH];
@@ -503,7 +503,7 @@ context_derive_keys_new(struct krb5_ctx *ctx)
 	/* initiator seal encryption */
 	set_cdata(cdata, KG_USAGE_INITIATOR_SEAL, KEY_USAGE_SEED_ENCRYPTION);
 	keyout.data = ctx->initiator_seal;
-	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c);
+	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c, gfp_mask);
 	if (err) {
 		dprintk("%s: Error %d deriving initiator_seal key\n",
 			__func__, err);
@@ -518,7 +518,7 @@ context_derive_keys_new(struct krb5_ctx *ctx)
 	/* acceptor seal encryption */
 	set_cdata(cdata, KG_USAGE_ACCEPTOR_SEAL, KEY_USAGE_SEED_ENCRYPTION);
 	keyout.data = ctx->acceptor_seal;
-	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c);
+	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c, gfp_mask);
 	if (err) {
 		dprintk("%s: Error %d deriving acceptor_seal key\n",
 			__func__, err);
@@ -533,7 +533,7 @@ context_derive_keys_new(struct krb5_ctx *ctx)
 	/* initiator sign checksum */
 	set_cdata(cdata, KG_USAGE_INITIATOR_SIGN, KEY_USAGE_SEED_CHECKSUM);
 	keyout.data = ctx->initiator_sign;
-	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c);
+	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c, gfp_mask);
 	if (err) {
 		dprintk("%s: Error %d deriving initiator_sign key\n",
 			__func__, err);
@@ -543,7 +543,7 @@ context_derive_keys_new(struct krb5_ctx *ctx)
 	/* acceptor sign checksum */
 	set_cdata(cdata, KG_USAGE_ACCEPTOR_SIGN, KEY_USAGE_SEED_CHECKSUM);
 	keyout.data = ctx->acceptor_sign;
-	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c);
+	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c, gfp_mask);
 	if (err) {
 		dprintk("%s: Error %d deriving acceptor_sign key\n",
 			__func__, err);
@@ -553,7 +553,7 @@ context_derive_keys_new(struct krb5_ctx *ctx)
 	/* initiator seal integrity */
 	set_cdata(cdata, KG_USAGE_INITIATOR_SEAL, KEY_USAGE_SEED_INTEGRITY);
 	keyout.data = ctx->initiator_integ;
-	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c);
+	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c, gfp_mask);
 	if (err) {
 		dprintk("%s: Error %d deriving initiator_integ key\n",
 			__func__, err);
@@ -563,7 +563,7 @@ context_derive_keys_new(struct krb5_ctx *ctx)
 	/* acceptor seal integrity */
 	set_cdata(cdata, KG_USAGE_ACCEPTOR_SEAL, KEY_USAGE_SEED_INTEGRITY);
 	keyout.data = ctx->acceptor_integ;
-	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c);
+	err = krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c, gfp_mask);
 	if (err) {
 		dprintk("%s: Error %d deriving acceptor_integ key\n",
 			__func__, err);
@@ -598,7 +598,8 @@ out_err:
 }
 
 static int
-gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
+gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx,
+		gfp_t gfp_mask)
 {
 	int keylen;
 
@@ -645,7 +646,7 @@ gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
 	}
 
 	ctx->mech_used.data = kmemdup(gss_kerberos_mech.gm_oid.data,
-				      gss_kerberos_mech.gm_oid.len, GFP_KERNEL);
+				      gss_kerberos_mech.gm_oid.len, gfp_mask);
 	if (unlikely(ctx->mech_used.data == NULL)) {
 		p = ERR_PTR(-ENOMEM);
 		goto out_err;
@@ -654,12 +655,12 @@ gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
 
 	switch (ctx->enctype) {
 	case ENCTYPE_DES3_CBC_RAW:
-		return context_derive_keys_des3(ctx);
+		return context_derive_keys_des3(ctx, gfp_mask);
 	case ENCTYPE_ARCFOUR_HMAC:
 		return context_derive_keys_rc4(ctx);
 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
-		return context_derive_keys_new(ctx);
+		return context_derive_keys_new(ctx, gfp_mask);
 	default:
 		return -EINVAL;
 	}
@@ -670,20 +671,21 @@ out_err:
 
 static int
 gss_import_sec_context_kerberos(const void *p, size_t len,
-				struct gss_ctx *ctx_id)
+				struct gss_ctx *ctx_id,
+				gfp_t gfp_mask)
 {
 	const void *end = (const void *)((const char *)p + len);
 	struct  krb5_ctx *ctx;
 	int ret;
 
-	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
+	ctx = kzalloc(sizeof(*ctx), gfp_mask);
 	if (ctx == NULL)
 		return -ENOMEM;
 
 	if (len == 85)
 		ret = gss_import_v1_context(p, end, ctx);
 	else
-		ret = gss_import_v2_context(p, end, ctx);
+		ret = gss_import_v2_context(p, end, ctx, gfp_mask);
 
 	if (ret == 0)
 		ctx_id->internal_ctx_id = ctx;
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 28a84ef..2689de3 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -249,14 +249,15 @@ EXPORT_SYMBOL_GPL(gss_mech_put);
 int
 gss_import_sec_context(const void *input_token, size_t bufsize,
 		       struct gss_api_mech	*mech,
-		       struct gss_ctx		**ctx_id)
+		       struct gss_ctx		**ctx_id,
+		       gfp_t gfp_mask)
 {
-	if (!(*ctx_id = kzalloc(sizeof(**ctx_id), GFP_KERNEL)))
+	if (!(*ctx_id = kzalloc(sizeof(**ctx_id), gfp_mask)))
 		return -ENOMEM;
 	(*ctx_id)->mech_type = gss_mech_get(mech);
 
 	return mech->gm_ops
-		->gss_import_sec_context(input_token, bufsize, *ctx_id);
+		->gss_import_sec_context(input_token, bufsize, *ctx_id, gfp_mask);
 }
 
 /* gss_get_mic: compute a mic over message and return mic_token. */
diff --git a/net/sunrpc/auth_gss/gss_spkm3_mech.c b/net/sunrpc/auth_gss/gss_spkm3_mech.c
index 035e1dd..dc3f1f5 100644
--- a/net/sunrpc/auth_gss/gss_spkm3_mech.c
+++ b/net/sunrpc/auth_gss/gss_spkm3_mech.c
@@ -84,13 +84,14 @@ simple_get_netobj(const void *p, const void *end, struct xdr_netobj *res)
 
 static int
 gss_import_sec_context_spkm3(const void *p, size_t len,
-				struct gss_ctx *ctx_id)
+				struct gss_ctx *ctx_id,
+				gfp_t gfp_mask)
 {
 	const void *end = (const void *)((const char *)p + len);
 	struct	spkm3_ctx *ctx;
 	int	version;
 
-	if (!(ctx = kzalloc(sizeof(*ctx), GFP_NOFS)))
+	if (!(ctx = kzalloc(sizeof(*ctx), gfp_mask)))
 		goto out_err;
 
 	p = simple_get_bytes(p, end, &version, sizeof(version));
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 1d9ac4a..cc385b3 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -494,7 +494,7 @@ static int rsc_parse(struct cache_detail *cd,
 		len = qword_get(&mesg, buf, mlen);
 		if (len < 0)
 			goto out;
-		status = gss_import_sec_context(buf, len, gm, &rsci.mechctx);
+		status = gss_import_sec_context(buf, len, gm, &rsci.mechctx, GFP_KERNEL);
 		if (status)
 			goto out;
 
-- 
1.6.6.1

