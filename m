From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 16/19] gss_krb5: add support for triple-des encryption
Date: Thu, 21 Feb 2008 13:45:08 -0500
Message-ID: <20080221184507.19195.11460.stgit@jazz.citi.umich.edu>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:9902 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755011AbYBUSpI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 13:45:08 -0500
Received: from jazz.citi.umich.edu (jazz.citi.umich.edu [141.211.133.62])
	by citi.umich.edu (Postfix) with ESMTP id 08F184602
	for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 13:45:08 -0500 (EST)
In-Reply-To: <20080221184208.19195.94518.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add the final pieces to support the triple-des encryption type.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 include/linux/sunrpc/gss_krb5.h       |    4 ++
 net/sunrpc/auth_gss/gss_krb5_crypto.c |    3 ++
 net/sunrpc/auth_gss/gss_krb5_keys.c   |   53 +++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/gss_krb5_mech.c   |   23 ++++++++++++++
 net/sunrpc/auth_gss/gss_krb5_seal.c   |    1 +
 net/sunrpc/auth_gss/gss_krb5_unseal.c |    1 +
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |    2 +
 net/sunrpc/rpc_pipe.c                 |    2 +
 8 files changed, 88 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index e828e98..bf58284 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -240,3 +240,7 @@ u32 krb5_derive_key(struct gss_krb5_enctype *gk5e,
 		    const struct xdr_netobj *inkey,
 		    struct xdr_netobj *outkey,
 		    const struct xdr_netobj *in_constant);
+
+u32 gss_krb5_des3_make_key(struct gss_krb5_enctype *gk5e,
+			   struct xdr_netobj *randombits,
+			   struct xdr_netobj *key);
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 8b12f34..4f963c2 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -189,6 +189,9 @@ make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
 		       checksumdata + checksumlen - kctx->gk5e->cksumlength,
 		       kctx->gk5e->cksumlength);
 		break;
+	case CKSUMTYPE_HMAC_SHA1_DES3:
+		memcpy(cksumout->data, checksumdata, kctx->gk5e->cksumlength);
+		break;
 	default:
 		BUG();
 		break;
diff --git a/net/sunrpc/auth_gss/gss_krb5_keys.c b/net/sunrpc/auth_gss/gss_krb5_keys.c
index 97ec67d..a722fba 100644
--- a/net/sunrpc/auth_gss/gss_krb5_keys.c
+++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
@@ -253,3 +253,56 @@ err_return:
 	return ret;
 }
 EXPORT_SYMBOL(krb5_derive_key);
+
+#define smask(step) ((1<<step)-1)
+#define pstep(x, step) (((x)&smask(step))^(((x)>>step)&smask(step)))
+#define parity_char(x) pstep(pstep(pstep((x), 4), 2), 1)
+
+static void mit_des_fixup_key_parity(u8 key[8])
+{
+	int i;
+	for (i = 0; i < 8; i++) {
+		key[i] &= 0xfe;
+		key[i] |= 1^parity_char(key[i]);
+	}
+}
+
+/*
+ * This is the des3 key derivation postprocess function
+ */
+u32 gss_krb5_des3_make_key(struct gss_krb5_enctype *gk5e,
+			   struct xdr_netobj *randombits,
+			   struct xdr_netobj *key)
+{
+	int i;
+	u32 ret = EINVAL;
+
+	if (key->len != 24) {
+		dprintk("%s: key->len is %d\n", __func__, key->len);
+		goto err_out;
+	}
+	if (randombits->len != 21) {
+		dprintk("%s: randombits->len is %d\n",
+			__func__, randombits->len);
+		goto err_out;
+	}
+
+	/* take the seven bytes, move them around into the top 7 bits of the
+	   8 key bytes, then compute the parity bits.  Do this three times. */
+
+	for (i = 0; i < 3; i++) {
+		memcpy(key->data + i*8, randombits->data + i*7, 7);
+		key->data[i*8+7] = (((key->data[i*8]&1)<<1) |
+				    ((key->data[i*8+1]&1)<<2) |
+				    ((key->data[i*8+2]&1)<<3) |
+				    ((key->data[i*8+3]&1)<<4) |
+				    ((key->data[i*8+4]&1)<<5) |
+				    ((key->data[i*8+5]&1)<<6) |
+				    ((key->data[i*8+6]&1)<<7));
+
+		mit_des_fixup_key_parity(key->data + i*8);
+	}
+	ret = 0;
+err_out:
+	return(ret);
+}
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index fc30538..2edf28e 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -69,6 +69,26 @@ static struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
 	  .cksumlength = 8,
 	  .keyed_cksum = 0,
 	},
+	/*
+	 * 3DES
+	 */
+	{
+	  .etype = ENCTYPE_DES3_CBC_RAW,
+	  .ctype = CKSUMTYPE_HMAC_SHA1_DES3,
+	  .name = "des3-hmac-sha1",
+	  .encrypt_name = "cbc(des3_ede)",
+	  .cksum_name = "hmac(sha1)",
+	  .encrypt = krb5_encrypt,
+	  .decrypt = krb5_decrypt,
+	  .mk_key = gss_krb5_des3_make_key,
+	  .signalg = SGN_ALG_HMAC_SHA1_DES3_KD,
+	  .sealalg = SEAL_ALG_DES3KD,
+	  .keybytes = 21,
+	  .keylength = 24,
+	  .blocksize = 8,
+	  .cksumlength = 20,
+	  .keyed_cksum = 1,
+	},
 };
 
 static int num_supported_enctypes =
@@ -447,6 +467,9 @@ gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
 	p = simple_get_bytes(p, end, &ctx->enctype, sizeof(ctx->enctype));
 	if (IS_ERR(p))
 		goto out_err;
+	/* Map ENCTYPE_DES3_CBC_SHA1 to ENCTYPE_DES3_CBC_RAW */
+	if (ctx->enctype == ENCTYPE_DES3_CBC_SHA1)
+		ctx->enctype = ENCTYPE_DES3_CBC_RAW;
 	ctx->gk5e = get_gss_krb5_enctype(ctx->enctype);
 	if (ctx->gk5e == NULL) {
 		printk("gss_kerberos_mech: unsupported krb5 enctype %u\n",
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index 285188d..b1d9436 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -140,6 +140,7 @@ gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
 
 	switch (ctx->enctype) {
 	case ENCTYPE_DES_CBC_RAW:
+	case ENCTYPE_DES3_CBC_RAW:
 		return gss_get_mic_v1(ctx, text, token);
 	default:
 		BUG();
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index c9adcfc..7ba63ae 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -150,6 +150,7 @@ gss_verify_mic_kerberos(struct gss_ctx *gss_ctx,
 
 	switch (ctx->enctype) {
 	case ENCTYPE_DES_CBC_RAW:
+	case ENCTYPE_DES3_CBC_RAW:
 		return gss_verify_mic_v1(ctx, message_buffer, read_token);
 	default:
 		BUG();
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index a68677c..d59e9b2 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -291,6 +291,7 @@ gss_wrap_kerberos(struct gss_ctx *gctx, int offset,
 
 	switch (kctx->enctype) {
 	case ENCTYPE_DES_CBC_RAW:
+	case ENCTYPE_DES3_CBC_RAW:
 		return gss_wrap_kerberos_v1(kctx, offset, buf, pages);
 		break;
 	default:
@@ -307,6 +308,7 @@ gss_unwrap_kerberos(struct gss_ctx *gctx, int offset, struct xdr_buf *buf)
 
 	switch (kctx->enctype) {
 	case ENCTYPE_DES_CBC_RAW:
+	case ENCTYPE_DES3_CBC_RAW:
 		return gss_unwrap_kerberos_v1(kctx, offset, buf);
 		break;
 	default:
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 5781862..d84632a 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -392,7 +392,7 @@ static const struct file_operations rpc_info_operations = {
 static int
 rpc_show_krb5_info(struct seq_file *m, void *v)
 {
-	seq_printf(m, "enctypes: 3,1,2\n");
+	seq_printf(m, "enctypes: 16,3,1,2\n");
 	return 0;
 }
 

