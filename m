From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 12/19] gss_krb5: add ability to have a keyed checksum (hmac)
Date: Thu, 21 Feb 2008 13:44:47 -0500
Message-ID: <20080221184447.19195.88952.stgit@jazz.citi.umich.edu>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:24219 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754755AbYBUSos (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 13:44:48 -0500
Received: from jazz.citi.umich.edu (jazz.citi.umich.edu [141.211.133.62])
	by citi.umich.edu (Postfix) with ESMTP id C603C460B
	for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 13:44:47 -0500 (EST)
In-Reply-To: <20080221184208.19195.94518.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Encryption types besides DES may use a keyed checksum (hmac).
Modify the make_checksum() function to allow for a key
and take care of enctype-specific processing such as truncating
the resulting hash.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 include/linux/sunrpc/gss_krb5.h       |   11 +++++--
 net/sunrpc/auth_gss/gss_krb5_crypto.c |   54 ++++++++++++++++++++++++++++-----
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    1 +
 net/sunrpc/auth_gss/gss_krb5_seal.c   |   13 ++++----
 net/sunrpc/auth_gss/gss_krb5_unseal.c |   13 +++++---
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |   29 ++++++++++--------
 6 files changed, 87 insertions(+), 34 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index d10d8ce..c33a657 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -41,6 +41,9 @@
 #include <linux/sunrpc/gss_err.h>
 #include <linux/sunrpc/gss_asn1.h>
 
+/* Maximum key length (in bytes) for the supported crypto algorithms*/
+#define GSS_KRB5_MAX_KEYLEN 32
+
 /* Maximum checksum function output for the supported crypto algorithms */
 #define GSS_KRB5_MAX_CKSUM_LEN  20
 
@@ -74,6 +77,7 @@ struct krb5_ctx {
 	struct gss_krb5_enctype *gk5e;		/* enctype-specific info */
 	struct crypto_blkcipher	*enc;
 	struct crypto_blkcipher	*seq;
+	u8			cksum[GSS_KRB5_MAX_KEYLEN];
 	s32			endtime;
 	u32			seq_send;
 	struct xdr_netobj	mech_used;
@@ -142,9 +146,10 @@ extern struct xdr_netobj krb5_oid;
 #define ENCTYPE_DES3_CBC_SHA1   0x0010
 #define ENCTYPE_UNKNOWN         0x01ff
 
-s32
-make_checksum(char *, char *header, int hdrlen, struct xdr_buf *body,
-		   int body_offset, struct xdr_netobj *cksum);
+u32
+make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
+		struct xdr_buf *body, int body_offset, u8 *cksumkey,
+		struct xdr_netobj *cksumout);
 
 u32 gss_get_mic_kerberos(struct gss_ctx *, struct xdr_buf *,
 		struct xdr_netobj *);
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 39643a7..8b12f34 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -128,21 +128,42 @@ checksummer(struct scatterlist *sg, void *data)
 	return crypto_hash_update(desc, sg, sg->length);
 }
 
-/* checksum the plaintext data and hdrlen bytes of the token header */
-s32
-make_checksum(char *cksumname, char *header, int hdrlen, struct xdr_buf *body,
-		   int body_offset, struct xdr_netobj *cksum)
+/*
+ * checksum the plaintext data and hdrlen bytes of the token header
+ * The checksum is performed over the first 8 bytes of the
+ * gss token header and then over the data body
+ */
+u32
+make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
+	      struct xdr_buf *body, int body_offset, u8 *cksumkey,
+	      struct xdr_netobj *cksumout)
 {
-	struct hash_desc                desc; /* XXX add to ctx? */
+	struct hash_desc                desc;
 	struct scatterlist              sg[1];
 	int err;
+	u8 checksumdata[GSS_KRB5_MAX_CKSUM_LEN];
+	unsigned int checksumlen;
+
+	if (cksumout->len < kctx->gk5e->cksumlength) {
+		dprintk("%s: checksum buffer length, %u, too small for %s\n",
+			__func__, cksumout->len, kctx->gk5e->name);
+		return GSS_S_FAILURE;
+	}
 
-	desc.tfm = crypto_alloc_hash(cksumname, 0, CRYPTO_ALG_ASYNC);
+	desc.tfm = crypto_alloc_hash(kctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(desc.tfm))
 		return GSS_S_FAILURE;
-	cksum->len = crypto_hash_digestsize(desc.tfm);
 	desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
 
+	checksumlen = crypto_hash_digestsize(desc.tfm);
+
+	if (cksumkey != NULL) {
+		err = crypto_hash_setkey(desc.tfm, cksumkey,
+					 kctx->gk5e->keylength);
+		if (err)
+			goto out;
+	}
+
 	err = crypto_hash_init(&desc);
 	if (err)
 		goto out;
@@ -154,8 +175,25 @@ make_checksum(char *cksumname, char *header, int hdrlen, struct xdr_buf *body,
 			      checksummer, &desc);
 	if (err)
 		goto out;
-	err = crypto_hash_final(&desc, cksum->data);
+	err = crypto_hash_final(&desc, checksumdata);
+	if (err)
+		goto out;
 
+	switch (kctx->gk5e->ctype) {
+	case CKSUMTYPE_RSA_MD5:
+		err = kctx->gk5e->encrypt(kctx->seq, NULL, checksumdata,
+					  checksumdata, checksumlen);
+		if (err)
+			goto out;
+		memcpy(cksumout->data,
+		       checksumdata + checksumlen - kctx->gk5e->cksumlength,
+		       kctx->gk5e->cksumlength);
+		break;
+	default:
+		BUG();
+		break;
+	}
+	cksumout->len = kctx->gk5e->cksumlength;
 out:
 	crypto_free_hash(desc.tfm);
 	return err ? GSS_S_FAILURE : 0;
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index fe88266..28335cc 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -66,6 +66,7 @@ static struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
 	  .keylength = 8,
 	  .blocksize = 8,
 	  .cksumlength = 8,
+	  .keyed_cksum = 0,
 	},
 };
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index 64cabf2..f5badc7 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -102,6 +102,7 @@ gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
 	void			*krb5_hdr;
 	s32			now;
 	u32			seq_send;
+	u8			*cksumkey;
 
 	dprintk("RPC:       %s\n", __func__);
 	BUG_ON(ctx == NULL);
@@ -110,15 +111,15 @@ gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
 
 	krb5_hdr = setup_token(ctx, token);
 
-	if (make_checksum((char *)ctx->gk5e->cksum_name, krb5_hdr, 8,
-						text, 0, &md5cksum))
-		return GSS_S_FAILURE;
+	if (ctx->gk5e->keyed_cksum)
+		cksumkey = ctx->cksum;
+	else
+		cksumkey = NULL;
 
-	if (krb5_encrypt(ctx->seq, NULL, md5cksum.data,
-			  md5cksum.data, md5cksum.len))
+	if (make_checksum(ctx, krb5_hdr, 8, text, 0, cksumkey, &md5cksum))
 		return GSS_S_FAILURE;
 
-	memcpy(krb5_hdr + 16, md5cksum.data + md5cksum.len - 8, 8);
+	memcpy(krb5_hdr + 16, md5cksum.data, md5cksum.len);
 
 	spin_lock(&krb5_seq_lock);
 	seq_send = ctx->seq_send++;
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index 43bd213..5494ba4 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -85,6 +85,7 @@ gss_verify_mic_v1(struct krb5_ctx *ctx,
 	s32			seqnum;
 	unsigned char		*ptr = (unsigned char *)read_token->data;
 	int			bodysize;
+	u8			*cksumkey;
 
 	dprintk("RPC:       krb5_read_token\n");
 
@@ -109,14 +110,16 @@ gss_verify_mic_v1(struct krb5_ctx *ctx,
 	if ((ptr[4] != 0xff) || (ptr[5] != 0xff))
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	if (make_checksum((char *)ctx->gk5e->cksum_name, ptr - 2, 8,
-					message_buffer, 0, &md5cksum))
-		return GSS_S_FAILURE;
+	if (ctx->gk5e->keyed_cksum)
+		cksumkey = ctx->cksum;
+	else
+		cksumkey = NULL;
 
-	if (krb5_encrypt(ctx->seq, NULL, md5cksum.data, md5cksum.data, 16))
+	if (make_checksum(ctx, ptr - 2, 8, message_buffer, 0,
+			  cksumkey, &md5cksum))
 		return GSS_S_FAILURE;
 
-	if (memcmp(md5cksum.data + 8, ptr + 14, ctx->gk5e->cksumlength))
+	if (memcmp(md5cksum.data, ptr + 14, ctx->gk5e->cksumlength))
 		return GSS_S_BAD_SIG;
 
 	/* it got through unscathed.  Make sure the context is unexpired */
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index e369696..dd6caf3 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -111,6 +111,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	int			headlen;
 	struct page		**tmp_pages;
 	u32			seq_send;
+	u8			*cksumkey;
 
 	dprintk("RPC:       %s\n", __func__);
 
@@ -150,18 +151,20 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 
 	make_confounder(msg_start, blocksize);
 
+	if (kctx->gk5e->keyed_cksum)
+		cksumkey = kctx->cksum;
+	else
+		cksumkey = NULL;
+
 	/* XXXJBF: UGH!: */
 	tmp_pages = buf->pages;
 	buf->pages = pages;
-	if (make_checksum((char *)kctx->gk5e->cksum_name, krb5_hdr, 8, buf,
-				offset + headlen - blocksize, &md5cksum))
+	if (make_checksum(kctx, krb5_hdr, 8, buf, offset + headlen - blocksize,
+					cksumkey, &md5cksum))
 		return GSS_S_FAILURE;
 	buf->pages = tmp_pages;
 
-	if (krb5_encrypt(kctx->seq, NULL, md5cksum.data,
-			  md5cksum.data, md5cksum.len))
-		return GSS_S_FAILURE;
-	memcpy(krb5_hdr + 16, md5cksum.data + md5cksum.len - 8, 8);
+	memcpy(krb5_hdr + 16, md5cksum.data, md5cksum.len);
 
 	spin_lock(&krb5_seq_lock);
 	seq_send = kctx->seq_send++;
@@ -197,6 +200,7 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	int			data_len;
 	int			blocksize;
 	int			crypt_offset;
+	u8			*cksumkey;
 
 	dprintk("RPC:       gss_unwrap_kerberos\n");
 
@@ -233,15 +237,16 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	if (gss_decrypt_xdr_buf(kctx->enc, buf, crypt_offset))
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	if (make_checksum((char *)kctx->gk5e->cksum_name, ptr - 2, 8, buf,
-						crypt_offset, &md5cksum))
-		return GSS_S_FAILURE;
+	if (kctx->gk5e->keyed_cksum)
+		cksumkey = kctx->cksum;
+	else
+		cksumkey = NULL;
 
-	if (krb5_encrypt(kctx->seq, NULL, md5cksum.data,
-			   md5cksum.data, md5cksum.len))
+	if (make_checksum(kctx, ptr - 2, 8, buf, crypt_offset,
+						cksumkey, &md5cksum))
 		return GSS_S_FAILURE;
 
-	if (memcmp(md5cksum.data + 8, ptr + 14, 8))/* this is still DES-aware */
+	if (memcmp(md5cksum.data, ptr + 14, kctx->gk5e->cksumlength))
 		return GSS_S_BAD_SIG;
 
 	/* it got through unscathed.  Make sure the context is unexpired */

