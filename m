From: steved@redhat.com
Subject: [PATCH 07/23] gss_krb5: add ability to have a keyed checksum (hmac)
Date: Wed, 17 Mar 2010 13:02:52 -0400
Message-ID: <1268845388-9516-8-git-send-email-steved@redhat.com>
References: <1268845388-9516-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:55133 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753423Ab0CQRDM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 13:03:12 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1NrweE-0003fC-RL
	for linux-nfs@vger.kernel.org; Wed, 17 Mar 2010 13:03:11 -0400
In-Reply-To: <1268845388-9516-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

Encryption types besides DES may use a keyed checksum (hmac).
Modify the make_checksum() function to allow for a key
and take care of enctype-specific processing such as truncating
the resulting hash.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 include/linux/sunrpc/gss_krb5.h       |   11 +++++--
 net/sunrpc/auth_gss/gss_krb5_crypto.c |   54 ++++++++++++++++++++++++++++-----
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    1 +
 net/sunrpc/auth_gss/gss_krb5_seal.c   |   13 ++++----
 net/sunrpc/auth_gss/gss_krb5_unseal.c |   13 +++++---
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |   30 +++++++++++-------
 6 files changed, 88 insertions(+), 34 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 6f863fa..bf8bdbb 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -41,6 +41,9 @@
 #include <linux/sunrpc/gss_err.h>
 #include <linux/sunrpc/gss_asn1.h>
 
+/* Maximum key length (in bytes) for the supported crypto algorithms*/
+#define GSS_KRB5_MAX_KEYLEN (32)
+
 /* Maximum checksum function output for the supported crypto algorithms */
 #define GSS_KRB5_MAX_CKSUM_LEN  (20)
 
@@ -74,6 +77,7 @@ struct krb5_ctx {
 	const struct gss_krb5_enctype *gk5e; /* enctype-specific info */
 	struct crypto_blkcipher	*enc;
 	struct crypto_blkcipher	*seq;
+	u8			cksum[GSS_KRB5_MAX_KEYLEN];
 	s32			endtime;
 	u32			seq_send;
 	struct xdr_netobj	mech_used;
@@ -159,9 +163,10 @@ enum seal_alg {
 	+ GSS_KRB5_TOK_HDR_LEN                                   \
 	+ GSS_KRB5_MAX_CKSUM_LEN
 
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
index 98c5065..fda8e37 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -124,21 +124,42 @@ checksummer(struct scatterlist *sg, void *data)
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
@@ -150,8 +171,25 @@ make_checksum(char *cksumname, char *header, int hdrlen, struct xdr_buf *body,
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
index 1480883..2873550 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -66,6 +66,7 @@ static const struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
 	  .keylength = 8,
 	  .blocksize = 8,
 	  .cksumlength = 8,
+	  .keyed_cksum = 0,
 	},
 };
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index f0e9a65..c4df7af 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -102,6 +102,7 @@ gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
 	void			*ptr;
 	s32			now;
 	u32			seq_send;
+	u8			*cksumkey;
 
 	dprintk("RPC:       %s\n", __func__);
 	BUG_ON(ctx == NULL);
@@ -110,15 +111,15 @@ gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
 
 	ptr = setup_token(ctx, token);
 
-	if (make_checksum((char *)ctx->gk5e->cksum_name, ptr, 8,
-						text, 0, &md5cksum))
-		return GSS_S_FAILURE;
+	if (ctx->gk5e->keyed_cksum)
+		cksumkey = ctx->cksum;
+	else
+		cksumkey = NULL;
 
-	if (krb5_encrypt(ctx->seq, NULL, md5cksum.data,
-			  md5cksum.data, md5cksum.len))
+	if (make_checksum(ctx, ptr, 8, text, 0, cksumkey, &md5cksum))
 		return GSS_S_FAILURE;
 
-	memcpy(ptr + GSS_KRB5_TOK_HDR_LEN, md5cksum.data + md5cksum.len - 8, 8);
+	memcpy(ptr + GSS_KRB5_TOK_HDR_LEN, md5cksum.data, md5cksum.len);
 
 	spin_lock(&krb5_seq_lock);
 	seq_send = ctx->seq_send++;
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index ffba3a9..aff3fce 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -85,6 +85,7 @@ gss_verify_mic_v1(struct krb5_ctx *ctx,
 	u32			seqnum;
 	unsigned char		*ptr = (unsigned char *)read_token->data;
 	int			bodysize;
+	u8			*cksumkey;
 
 	dprintk("RPC:       krb5_read_token\n");
 
@@ -109,14 +110,16 @@ gss_verify_mic_v1(struct krb5_ctx *ctx,
 	if ((ptr[6] != 0xff) || (ptr[7] != 0xff))
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	if (make_checksum((char *)ctx->gk5e->cksum_name, ptr, 8,
-					message_buffer, 0, &md5cksum))
-		return GSS_S_FAILURE;
+	if (ctx->gk5e->keyed_cksum)
+		cksumkey = ctx->cksum;
+	else
+		cksumkey = NULL;
 
-	if (krb5_encrypt(ctx->seq, NULL, md5cksum.data, md5cksum.data, 16))
+	if (make_checksum(ctx, ptr, 8, message_buffer, 0,
+			  cksumkey, &md5cksum))
 		return GSS_S_FAILURE;
 
-	if (memcmp(md5cksum.data + 8, ptr + GSS_KRB5_TOK_HDR_LEN,
+	if (memcmp(md5cksum.data, ptr + GSS_KRB5_TOK_HDR_LEN,
 					ctx->gk5e->cksumlength))
 		return GSS_S_BAD_SIG;
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index aee77a3..ff4edcd 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -168,6 +168,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	int			headlen;
 	struct page		**tmp_pages;
 	u32			seq_send;
+	u8			*cksumkey;
 
 	dprintk("RPC:       %s\n", __func__);
 
@@ -206,18 +207,20 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 
 	make_confounder(msg_start, blocksize);
 
+	if (kctx->gk5e->keyed_cksum)
+		cksumkey = kctx->cksum;
+	else
+		cksumkey = NULL;
+
 	/* XXXJBF: UGH!: */
 	tmp_pages = buf->pages;
 	buf->pages = pages;
-	if (make_checksum((char *)kctx->gk5e->cksum_name, ptr, 8, buf,
-				offset + headlen - blocksize, &md5cksum))
+	if (make_checksum(kctx, ptr, 8, buf, offset + headlen - blocksize,
+					cksumkey, &md5cksum))
 		return GSS_S_FAILURE;
 	buf->pages = tmp_pages;
 
-	if (krb5_encrypt(kctx->seq, NULL, md5cksum.data,
-			  md5cksum.data, md5cksum.len))
-		return GSS_S_FAILURE;
-	memcpy(ptr + GSS_KRB5_TOK_HDR_LEN, md5cksum.data + md5cksum.len - 8, 8);
+	memcpy(ptr + GSS_KRB5_TOK_HDR_LEN, md5cksum.data, md5cksum.len);
 
 	spin_lock(&krb5_seq_lock);
 	seq_send = kctx->seq_send++;
@@ -253,6 +256,7 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	int			data_len;
 	int			blocksize;
 	int			crypt_offset;
+	u8			*cksumkey;
 
 	dprintk("RPC:       gss_unwrap_kerberos\n");
 
@@ -289,15 +293,17 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	if (gss_decrypt_xdr_buf(kctx->enc, buf, crypt_offset))
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	if (make_checksum((char *)kctx->gk5e->cksum_name, ptr, 8, buf,
-						crypt_offset, &md5cksum))
-		return GSS_S_FAILURE;
+	if (kctx->gk5e->keyed_cksum)
+		cksumkey = kctx->cksum;
+	else
+		cksumkey = NULL;
 
-	if (krb5_encrypt(kctx->seq, NULL, md5cksum.data,
-			   md5cksum.data, md5cksum.len))
+	if (make_checksum(kctx, ptr, 8, buf, crypt_offset,
+						cksumkey, &md5cksum))
 		return GSS_S_FAILURE;
 
-	if (memcmp(md5cksum.data + 8, ptr + GSS_KRB5_TOK_HDR_LEN, 8))
+	if (memcmp(md5cksum.data, ptr + GSS_KRB5_TOK_HDR_LEN,
+						kctx->gk5e->cksumlength))
 		return GSS_S_BAD_SIG;
 
 	/* it got through unscathed.  Make sure the context is unexpired */
-- 
1.6.6.1

