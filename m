From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 11/22] gss_krb5: add support for triple-des encryption
Date: Wed, 14 Apr 2010 13:36:47 -0400
Message-ID: <1271266618-26016-12-git-send-email-Trond.Myklebust@netapp.com>
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
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57513 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756562Ab0DNRhU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Apr 2010 13:37:20 -0400
Received: from localhost.localdomain (pd07336a.hq.netapp.com [10.58.61.110] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3EHawK7021574
	for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2010 10:37:05 -0700 (PDT)
In-Reply-To: <1271266618-26016-11-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

Add the final pieces to support the triple-des encryption type.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/gss_krb5.h       |    5 +++
 net/sunrpc/auth_gss/gss_krb5_crypto.c |    3 ++
 net/sunrpc/auth_gss/gss_krb5_keys.c   |   53 +++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/gss_krb5_mech.c   |   23 ++++++++++++++
 net/sunrpc/auth_gss/gss_krb5_seal.c   |    1 +
 net/sunrpc/auth_gss/gss_krb5_unseal.c |    1 +
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |    2 +
 7 files changed, 88 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 04d5279..db0522b 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -261,3 +261,8 @@ krb5_derive_key(const struct gss_krb5_enctype *gk5e,
 		const struct xdr_netobj *inkey,
 		struct xdr_netobj *outkey,
 		const struct xdr_netobj *in_constant);
+
+u32
+gss_krb5_des3_make_key(const struct gss_krb5_enctype *gk5e,
+		       struct xdr_netobj *randombits,
+		       struct xdr_netobj *key);
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index cae04d7..bb76873 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -184,6 +184,9 @@ make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
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
index 253b414..d546687 100644
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
+u32 gss_krb5_des3_make_key(const struct gss_krb5_enctype *gk5e,
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
+	return ret;
+}
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index d96d824..75a6567 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -71,6 +71,26 @@ static const struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
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
 
 static const int num_supported_enctypes =
@@ -440,6 +460,9 @@ gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
 	p = simple_get_bytes(p, end, &ctx->enctype, sizeof(ctx->enctype));
 	if (IS_ERR(p))
 		goto out_err;
+	/* Map ENCTYPE_DES3_CBC_SHA1 to ENCTYPE_DES3_CBC_RAW */
+	if (ctx->enctype == ENCTYPE_DES3_CBC_SHA1)
+		ctx->enctype = ENCTYPE_DES3_CBC_RAW;
 	ctx->gk5e = get_gss_krb5_enctype(ctx->enctype);
 	if (ctx->gk5e == NULL) {
 		dprintk("gss_kerberos_mech: unsupported krb5 enctype %u\n",
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index cd51271..7ede900 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -142,6 +142,7 @@ gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
 	default:
 		BUG();
 	case ENCTYPE_DES_CBC_RAW:
+	case ENCTYPE_DES3_CBC_RAW:
 		return gss_get_mic_v1(ctx, text, token);
 	}
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index 7515bff..3e15bdb 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -152,6 +152,7 @@ gss_verify_mic_kerberos(struct gss_ctx *gss_ctx,
 	default:
 		BUG();
 	case ENCTYPE_DES_CBC_RAW:
+	case ENCTYPE_DES3_CBC_RAW:
 		return gss_verify_mic_v1(ctx, message_buffer, read_token);
 	}
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 2eb3046..1c8ebd3 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -350,6 +350,7 @@ gss_wrap_kerberos(struct gss_ctx *gctx, int offset,
 	default:
 		BUG();
 	case ENCTYPE_DES_CBC_RAW:
+	case ENCTYPE_DES3_CBC_RAW:
 		return gss_wrap_kerberos_v1(kctx, offset, buf, pages);
 	}
 }
@@ -363,6 +364,7 @@ gss_unwrap_kerberos(struct gss_ctx *gctx, int offset, struct xdr_buf *buf)
 	default:
 		BUG();
 	case ENCTYPE_DES_CBC_RAW:
+	case ENCTYPE_DES3_CBC_RAW:
 		return gss_unwrap_kerberos_v1(kctx, offset, buf);
 	}
 }
-- 
1.6.6.1

