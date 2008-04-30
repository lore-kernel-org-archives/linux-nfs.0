From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 2: PATCH 14/26] gss_krb5: add support for triple-des
	encryption
Date: Wed, 30 Apr 2008 12:46:59 -0400
Message-ID: <20080430164659.16010.69365.stgit@jazz.citi.umich.edu>
References: <20080430164306.16010.44650.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:29895 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757743AbYD3QrA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2008 12:47:00 -0400
In-Reply-To: <20080430164306.16010.44650.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add the final pieces to support the triple-des encryption type.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 fs/Kconfig                            |    2 +
 include/linux/sunrpc/gss_krb5.h       |    5 +++
 net/sunrpc/auth_gss/gss_krb5_crypto.c |    3 ++
 net/sunrpc/auth_gss/gss_krb5_keys.c   |   53 +++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/gss_krb5_mech.c   |   23 ++++++++++++++
 net/sunrpc/auth_gss/gss_krb5_seal.c   |    1 +
 net/sunrpc/auth_gss/gss_krb5_unseal.c |    1 +
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |    2 +
 8 files changed, 90 insertions(+), 0 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 2e43d46..257939b 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1828,6 +1828,8 @@ config RPCSEC_GSS_KRB5
 	select CRYPTO_MD5
 	select CRYPTO_DES
 	select CRYPTO_CBC
+	select CRYPTO_HMAC
+	select CRYPTO_SHA1
 	help
 	  Choose Y here to enable Secure RPC using the Kerberos version 5
 	  GSS-API mechanism (RFC 1964).
diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 70241c9..a76255d 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -263,3 +263,8 @@ krb5_derive_key(struct gss_krb5_enctype *gk5e,
 		const struct xdr_netobj *inkey,
 		struct xdr_netobj *outkey,
 		const struct xdr_netobj *in_constant);
+
+u32
+gss_krb5_des3_make_key(struct gss_krb5_enctype *gk5e,
+		       struct xdr_netobj *randombits,
+		       struct xdr_netobj *key);
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 389f366..0c91186 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -185,6 +185,9 @@ make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
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
index 832ce90..29c4bc5 100644
--- a/net/sunrpc/auth_gss/gss_krb5_keys.c
+++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
@@ -250,3 +250,56 @@ err_free_cipher:
 err_return:
 	return ret;
 }
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
index f5935fa..cef534d 100644
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
 
 static int num_supported_enctypes = ARRAY_SIZE(supported_gss_krb5_enctypes);
@@ -437,6 +457,9 @@ gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
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
index 58563be..432d6e5 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -143,6 +143,7 @@ gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
 	default:
 		BUG();
 	case ENCTYPE_DES_CBC_RAW:
+	case ENCTYPE_DES3_CBC_RAW:
 		return gss_get_mic_v1(ctx, text, token);
 	}
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index d405943..404edbb 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -153,6 +153,7 @@ gss_verify_mic_kerberos(struct gss_ctx *gss_ctx,
 	default:
 		BUG();
 	case ENCTYPE_DES_CBC_RAW:
+	case ENCTYPE_DES3_CBC_RAW:
 		return gss_verify_mic_v1(ctx, message_buffer, read_token);
 	}
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 2e4ab81..c9c8cfb 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -352,6 +352,7 @@ gss_wrap_kerberos(struct gss_ctx *gctx, int offset,
 	default:
 		BUG();
 	case ENCTYPE_DES_CBC_RAW:
+	case ENCTYPE_DES3_CBC_RAW:
 		return gss_wrap_kerberos_v1(kctx, offset, buf, pages);
 	}
 }
@@ -365,6 +366,7 @@ gss_unwrap_kerberos(struct gss_ctx *gctx, int offset, struct xdr_buf *buf)
 	default:
 		BUG();
 	case ENCTYPE_DES_CBC_RAW:
+	case ENCTYPE_DES3_CBC_RAW:
 		return gss_unwrap_kerberos_v1(kctx, offset, buf);
 	}
 }

