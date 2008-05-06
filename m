From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 3: PATCH 23/24] gss_krb5: Add support for rc4-hmac
	encryption type described in rfc4757
Date: Tue, 06 May 2008 17:05:30 -0400
Message-ID: <20080506210529.3770.57889.stgit@jazz.citi.umich.edu>
References: <20080506210156.3770.95914.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:27614 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932437AbYEFVFa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 17:05:30 -0400
In-Reply-To: <20080506210156.3770.95914.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add necessary changes to add kernel support for the rc4-hmac Kerberos
encryption type used by Microsoft and described in rfc4757.


Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 fs/Kconfig                            |    2 
 include/linux/sunrpc/gss_krb5.h       |    9 +
 net/sunrpc/auth_gss/gss_krb5_crypto.c |  255 +++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/gss_krb5_mech.c   |   96 ++++++++++++
 net/sunrpc/auth_gss/gss_krb5_seal.c   |    1 
 net/sunrpc/auth_gss/gss_krb5_seqnum.c |   77 ++++++++++
 net/sunrpc/auth_gss/gss_krb5_unseal.c |    1 
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |   66 +++++++--
 8 files changed, 494 insertions(+), 13 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 08be92c..3220459 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1833,6 +1833,8 @@ config RPCSEC_GSS_KRB5
 	select CRYPTO_SHA1
 	select CRYPTO_AES
 	select CRYPTO_CTS
+	select CRYPTO_ECB
+	select CRYPTO_ARC4
 	help
 	  Choose Y here to enable Secure RPC using the Kerberos version 5
 	  GSS-API mechanism (RFC 1964).
diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index d9f3834..1b18c8a 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -318,5 +318,14 @@ gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset,
 		     struct xdr_buf *buf, u32 *plainoffset,
 		     u32 *plainlen);
 
+int
+krb5_rc4_setup_seq_key(struct krb5_ctx *kctx,
+		       struct crypto_blkcipher *cipher,
+		       unsigned char *cksum);
+
+int
+krb5_rc4_setup_enc_key(struct krb5_ctx *kctx,
+		       struct crypto_blkcipher *cipher,
+		       s32 seqnum);
 void
 make_confounder(char *p, u32 conflen);
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 6482185..de99a5d 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -125,6 +125,114 @@ checksummer(struct scatterlist *sg, void *data)
 	return crypto_hash_update(desc, sg, sg->length);
 }
 
+static int
+arcfour_hmac_md5_usage_to_salt(unsigned int usage, u8 salt[4])
+{
+	unsigned int ms_usage;
+
+	switch (usage) {
+	case KG_USAGE_SIGN:
+		ms_usage = 15;
+		break;
+	case KG_USAGE_SEAL:
+		ms_usage = 13;
+		break;
+	default:
+		return EINVAL;;
+	}
+	salt[0] = (ms_usage >> 0) & 0xff;
+	salt[1] = (ms_usage >> 8) & 0xff;
+	salt[2] = (ms_usage >> 16) & 0xff;
+	salt[3] = (ms_usage >> 24) & 0xff;
+
+	return 0;
+}
+
+static u32
+make_checksum_hmac_md5(struct krb5_ctx *kctx, char *header, int hdrlen,
+		       struct xdr_buf *body, int body_offset, u8 *cksumkey,
+		       unsigned int usage, struct xdr_netobj *cksumout)
+{
+	struct hash_desc                desc;
+	struct scatterlist              sg[1];
+	int err;
+	u8 checksumdata[GSS_KRB5_MAX_CKSUM_LEN];
+	u8 rc4salt[4];
+	struct crypto_hash *md5;
+	struct crypto_hash *hmac_md5;
+
+	if (cksumkey == NULL)
+		return GSS_S_FAILURE;
+
+	if (cksumout->len < kctx->gk5e->cksumlength) {
+		dprintk("%s: checksum buffer length, %u, too small for %s\n",
+			__func__, cksumout->len, kctx->gk5e->name);
+		return GSS_S_FAILURE;
+	}
+
+	if (arcfour_hmac_md5_usage_to_salt(usage, rc4salt)) {
+		dprintk("%s: invalid usage value %u\n", __func__, usage);
+		return GSS_S_FAILURE;
+	}
+
+	md5 = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(md5))
+		return GSS_S_FAILURE;
+
+	hmac_md5 = crypto_alloc_hash(kctx->gk5e->cksum_name, 0,
+				     CRYPTO_ALG_ASYNC);
+	if (IS_ERR(hmac_md5)) {
+		crypto_free_hash(md5);
+		return GSS_S_FAILURE;
+	}
+
+	desc.tfm = md5;
+	desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
+
+	err = crypto_hash_init(&desc);
+	if (err)
+		goto out;
+	sg_init_one(sg, rc4salt, 4);
+	err = crypto_hash_update(&desc, sg, 4);
+	if (err)
+		goto out;
+
+	sg_init_one(sg, header, hdrlen);
+	err = crypto_hash_update(&desc, sg, hdrlen);
+	if (err)
+		goto out;
+	err = xdr_process_buf(body, body_offset, body->len - body_offset,
+			      checksummer, &desc);
+	if (err)
+		goto out;
+	err = crypto_hash_final(&desc, checksumdata);
+	if (err)
+		goto out;
+
+	desc.tfm = hmac_md5;
+	desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
+
+	err = crypto_hash_init(&desc);
+	if (err)
+		goto out;
+	err = crypto_hash_setkey(hmac_md5, cksumkey, kctx->gk5e->keylength);
+	if (err)
+		goto out;
+
+	sg_init_one(sg, checksumdata, crypto_hash_digestsize(md5));
+	err = crypto_hash_digest(&desc, sg, crypto_hash_digestsize(md5),
+				 checksumdata);
+	if (err)
+		goto out;
+
+	memcpy(cksumout->data, checksumdata, kctx->gk5e->cksumlength);
+	cksumout->len = kctx->gk5e->cksumlength;
+out:
+	crypto_free_hash(md5);
+	crypto_free_hash(hmac_md5);
+	return err ? GSS_S_FAILURE : 0;
+}
+
 /*
  * checksum the plaintext data and hdrlen bytes of the token header
  * The checksum is performed over the first 8 bytes of the
@@ -141,6 +249,11 @@ make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
 	u8 checksumdata[GSS_KRB5_MAX_CKSUM_LEN];
 	unsigned int checksumlen;
 
+	if (kctx->gk5e->ctype == CKSUMTYPE_HMAC_MD5_ARCFOUR)
+		return make_checksum_hmac_md5(kctx, header, hdrlen,
+					      body, body_offset,
+					      cksumkey, usage, cksumout);
+
 	if (cksumout->len < kctx->gk5e->cksumlength) {
 		dprintk("%s: checksum buffer length, %u, too small for %s\n",
 			__func__, cksumout->len, kctx->gk5e->name);
@@ -752,3 +865,145 @@ out_err:
 		ret = GSS_S_FAILURE;
 	return ret;
 }
+
+/*
+ * Compute Kseq given the initial session key and the checksum.
+ * Set the key of the given cipher.
+ */
+int
+krb5_rc4_setup_seq_key(struct krb5_ctx *kctx, struct crypto_blkcipher *cipher,
+		       unsigned char *cksum)
+{
+	struct crypto_hash *hmac;
+	struct hash_desc desc;
+	struct scatterlist sg[1];
+	u8 Kseq[GSS_KRB5_MAX_KEYLEN];
+	u32 zeroconstant = 0;
+	int err;
+
+	dprintk("%s: entered\n", __func__);
+
+	hmac = crypto_alloc_hash(kctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(hmac)) {
+		dprintk("%s: error %ld, allocating hash '%s'\n",
+			__func__, PTR_ERR(hmac), kctx->gk5e->cksum_name);
+		return PTR_ERR(hmac);
+	}
+
+	desc.tfm = hmac;
+	desc.flags = 0;
+
+	err = crypto_hash_init(&desc);
+	if (err)
+		goto out_err;
+
+	/* Compute intermediate Kseq from session key */
+	err = crypto_hash_setkey(hmac, kctx->Ksess, kctx->gk5e->keylength);
+	if (err)
+		goto out_err;
+
+	sg_init_table(sg, 1);
+	sg_set_buf(sg, &zeroconstant, 4);
+
+	err = crypto_hash_digest(&desc, sg, 4, Kseq);
+	if (err)
+		goto out_err;
+
+	/* Compute final Kseq from the checksum and intermediate Kseq */
+	err = crypto_hash_setkey(hmac, Kseq, kctx->gk5e->keylength);
+	if (err)
+		goto out_err;
+
+	sg_set_buf(sg, cksum, 8);
+
+	err = crypto_hash_digest(&desc, sg, 8, Kseq);
+	if (err)
+		goto out_err;
+
+	err = crypto_blkcipher_setkey(cipher, Kseq, kctx->gk5e->keylength);
+	if (err)
+		goto out_err;
+
+	err = 0;
+
+out_err:
+	crypto_free_hash(hmac);
+	dprintk("%s: returning %d\n", __func__, err);
+	return err;
+}
+
+/*
+ * Compute Kcrypt given the initial session key and the plaintext seqnum.
+ * Set the key of cipher kctx->enc.
+ */
+int
+krb5_rc4_setup_enc_key(struct krb5_ctx *kctx, struct crypto_blkcipher *cipher,
+		       s32 seqnum)
+{
+	struct crypto_hash *hmac;
+	struct hash_desc desc;
+	struct scatterlist sg[1];
+	u8 Kcrypt[GSS_KRB5_MAX_KEYLEN];
+	u8 zeroconstant[4] = {0};
+	u8 seqnumarray[4];
+	int err, i;
+
+	dprintk("%s: entered, seqnum %u\n", __func__, seqnum);
+
+	hmac = crypto_alloc_hash(kctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(hmac)) {
+		dprintk("%s: error %ld, allocating hash '%s'\n",
+			__func__, PTR_ERR(hmac), kctx->gk5e->cksum_name);
+		return PTR_ERR(hmac);
+	}
+
+	desc.tfm = hmac;
+	desc.flags = 0;
+
+	err = crypto_hash_init(&desc);
+	if (err)
+		goto out_err;
+
+	/* Compute intermediate Kcrypt from session key */
+	for (i = 0; i < kctx->gk5e->keylength; i++)
+		Kcrypt[i] = kctx->Ksess[i] ^ 0xf0;
+
+	err = crypto_hash_setkey(hmac, Kcrypt, kctx->gk5e->keylength);
+	if (err)
+		goto out_err;
+
+	sg_init_table(sg, 1);
+	sg_set_buf(sg, zeroconstant, 4);
+
+	err = crypto_hash_digest(&desc, sg, 4, Kcrypt);
+	if (err)
+		goto out_err;
+
+	/* Compute final Kcrypt from the seqnum and intermediate Kcrypt */
+	err = crypto_hash_setkey(hmac, Kcrypt, kctx->gk5e->keylength);
+	if (err)
+		goto out_err;
+
+	seqnumarray[0] = (unsigned char) ((seqnum >> 24) & 0xff);
+	seqnumarray[1] = (unsigned char) ((seqnum >> 16) & 0xff);
+	seqnumarray[2] = (unsigned char) ((seqnum >> 8) & 0xff);
+	seqnumarray[3] = (unsigned char) ((seqnum >> 0) & 0xff);
+
+	sg_set_buf(sg, seqnumarray, 4);
+
+	err = crypto_hash_digest(&desc, sg, 4, Kcrypt);
+	if (err)
+		goto out_err;
+
+	err = crypto_blkcipher_setkey(cipher, Kcrypt, kctx->gk5e->keylength);
+	if (err)
+		goto out_err;
+
+	err = 0;
+
+out_err:
+	crypto_free_hash(hmac);
+	dprintk("%s: returning %d\n", __func__, err);
+	return err;
+}
+
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index a7a91b0..4278061 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -73,6 +73,27 @@ static struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
 	  .keyed_cksum = 0,
 	},
 	/*
+	 * RC4-HMAC
+	 */
+	{
+	  .etype = ENCTYPE_ARCFOUR_HMAC,
+	  .ctype = CKSUMTYPE_HMAC_MD5_ARCFOUR,
+	  .name = "rc4-hmac",
+	  .encrypt_name = "ecb(arc4)",
+	  .cksum_name = "hmac(md5)",
+	  .encrypt = krb5_encrypt,
+	  .decrypt = krb5_decrypt,
+	  .mk_key = NULL,
+	  .signalg = SGN_ALG_HMAC_MD5,
+	  .sealalg = SEAL_ALG_MICROSOFT_RC4,
+	  .keybytes = 16,
+	  .keylength = 16,
+	  .blocksize = 1,
+	  .conflen = 8,
+	  .cksumlength = 8,
+	  .keyed_cksum = 1,
+	},
+	/*
 	 * 3DES
 	 */
 	{
@@ -391,6 +412,79 @@ out_err:
 	return -EINVAL;
 }
 
+/*
+ * Note that RC4 depends on deriving keys using the sequence
+ * number or the checksum of a token.  Therefore, the final keys
+ * cannot be calculated until the token is being constructed!
+ */
+static int
+context_derive_keys_rc4(struct krb5_ctx *ctx)
+{
+	struct crypto_hash *hmac;
+	char sigkeyconstant[] = "signaturekey";
+	int slen = strlen(sigkeyconstant) + 1;	/* include null terminator */
+	struct hash_desc desc;
+	struct scatterlist sg[1];
+	int err;
+
+	dprintk("RPC:       %s: entered\n", __func__);
+	/*
+	 * derive cksum (aka Ksign) key
+	 */
+	hmac = crypto_alloc_hash(ctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(hmac)) {
+		dprintk("%s: error %ld allocating hash '%s'\n",
+			__func__, PTR_ERR(hmac), ctx->gk5e->cksum_name);
+		err = PTR_ERR(hmac);
+		goto out_err;
+	}
+
+	err = crypto_hash_setkey(hmac, ctx->Ksess, ctx->gk5e->keylength);
+	if (err)
+		goto out_err_free_hmac;
+
+	sg_init_table(sg, 1);
+	sg_set_buf(sg, sigkeyconstant, slen);
+
+	desc.tfm = hmac;
+	desc.flags = 0;
+
+	err = crypto_hash_init(&desc);
+	if (err)
+		goto out_err_free_hmac;
+
+	err = crypto_hash_digest(&desc, sg, slen, ctx->cksum);
+	if (err)
+		goto out_err_free_hmac;
+	/*
+	 * allocate hash, and blkciphers for data and seqnum encryption
+	 */
+	ctx->enc = crypto_alloc_blkcipher(ctx->gk5e->encrypt_name, 0,
+					  CRYPTO_ALG_ASYNC);
+	if (IS_ERR(ctx->enc)) {
+		err = PTR_ERR(ctx->enc);
+		goto out_err_free_hmac;
+	}
+
+	ctx->seq = crypto_alloc_blkcipher(ctx->gk5e->encrypt_name, 0,
+					  CRYPTO_ALG_ASYNC);
+	if (IS_ERR(ctx->seq)) {
+		crypto_free_blkcipher(ctx->enc);
+		err = PTR_ERR(ctx->seq);
+		goto out_err_free_hmac;
+	}
+
+	dprintk("RPC:       %s: returning success\n", __func__);
+
+	err = 0;
+
+out_err_free_hmac:
+	crypto_free_hash(hmac);
+out_err:
+	dprintk("RPC:       %s: returning %d\n", __func__, err);
+	return err;
+}
+
 static int
 context_derive_keys_new(struct krb5_ctx *ctx)
 {
@@ -560,6 +654,8 @@ gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx)
 	switch (ctx->enctype) {
 	case ENCTYPE_DES3_CBC_RAW:
 		return context_derive_keys_des3(ctx);
+	case ENCTYPE_ARCFOUR_HMAC:
+		return context_derive_keys_rc4(ctx);
 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
 		return context_derive_keys_new(ctx);
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index 0048ed7..c1a1e45 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -215,6 +215,7 @@ gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
 		BUG();
 	case ENCTYPE_DES_CBC_RAW:
 	case ENCTYPE_DES3_CBC_RAW:
+	case ENCTYPE_ARCFOUR_HMAC:
 		return gss_get_mic_v1(ctx, text, token);
 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
diff --git a/net/sunrpc/auth_gss/gss_krb5_seqnum.c b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
index c7b196d..476a373 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seqnum.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
@@ -40,6 +40,38 @@
 # define RPCDBG_FACILITY        RPCDBG_AUTH
 #endif
 
+static s32
+krb5_make_rc4_seq_num(struct krb5_ctx *kctx, int direction, s32 seqnum,
+		      unsigned char *cksum, unsigned char *buf)
+{
+	struct crypto_blkcipher *cipher;
+	unsigned char plain[8];
+	s32 code;
+
+	dprintk("RPC:       %s:\n", __func__);
+	cipher = crypto_alloc_blkcipher(kctx->gk5e->encrypt_name, 0,
+					CRYPTO_ALG_ASYNC);
+	if (IS_ERR(cipher))
+		return PTR_ERR(cipher);
+
+	plain[0] = (unsigned char) ((seqnum >> 24) & 0xff);
+	plain[1] = (unsigned char) ((seqnum >> 16) & 0xff);
+	plain[2] = (unsigned char) ((seqnum >> 8) & 0xff);
+	plain[3] = (unsigned char) ((seqnum >> 0) & 0xff);
+	plain[4] = direction;
+	plain[5] = direction;
+	plain[6] = direction;
+	plain[7] = direction;
+
+	code = krb5_rc4_setup_seq_key(kctx, cipher, cksum);
+	if (code)
+		goto out;
+
+	code = krb5_encrypt(cipher, cksum, plain, buf, 8);
+out:
+	crypto_free_blkcipher(cipher);
+	return code;
+}
 s32
 krb5_make_seq_num(struct krb5_ctx *kctx,
 		struct crypto_blkcipher *key,
@@ -49,6 +81,10 @@ krb5_make_seq_num(struct krb5_ctx *kctx,
 {
 	unsigned char plain[8];
 
+	if (kctx->enctype == ENCTYPE_ARCFOUR_HMAC)
+		return krb5_make_rc4_seq_num(kctx, direction, seqnum,
+					     cksum, buf);
+
 	plain[0] = (unsigned char) (seqnum & 0xff);
 	plain[1] = (unsigned char) ((seqnum >> 8) & 0xff);
 	plain[2] = (unsigned char) ((seqnum >> 16) & 0xff);
@@ -62,6 +98,43 @@ krb5_make_seq_num(struct krb5_ctx *kctx,
 	return krb5_encrypt(key, cksum, plain, buf, 8);
 }
 
+static s32
+krb5_get_rc4_seq_num(struct krb5_ctx *kctx, unsigned char *cksum,
+		     unsigned char *buf, int *direction, s32 *seqnum)
+{
+	struct crypto_blkcipher *cipher;
+	unsigned char plain[8];
+	s32 code;
+
+	dprintk("RPC:       %s:\n", __func__);
+	cipher = crypto_alloc_blkcipher(kctx->gk5e->encrypt_name, 0,
+					CRYPTO_ALG_ASYNC);
+	if (IS_ERR(cipher))
+		return PTR_ERR(cipher);
+
+	code = krb5_rc4_setup_seq_key(kctx, cipher, cksum);
+	if (code)
+		goto out;
+
+	code = krb5_decrypt(cipher, cksum, buf, plain, 8);
+	if (code)
+		goto out;
+
+	if ((plain[4] != plain[5]) || (plain[4] != plain[6])
+				   || (plain[4] != plain[7])) {
+		code = (s32)KG_BAD_SEQ;
+		goto out;
+	}
+
+	*direction = plain[4];
+
+	*seqnum = ((plain[0] << 24) | (plain[1] << 16) |
+					(plain[2] << 8) | (plain[3]));
+out:
+	crypto_free_blkcipher(cipher);
+	return code;
+}
+
 s32
 krb5_get_seq_num(struct krb5_ctx *kctx,
 	       struct crypto_blkcipher *key,
@@ -74,6 +147,10 @@ krb5_get_seq_num(struct krb5_ctx *kctx,
 
 	dprintk("RPC:       krb5_get_seq_num:\n");
 
+	if (kctx->enctype == ENCTYPE_ARCFOUR_HMAC)
+		return krb5_get_rc4_seq_num(kctx, cksum, buf,
+					    direction, seqnum);
+
 	if ((code = krb5_decrypt(key, cksum, buf, plain, 8)))
 		return code;
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index 760d628..0307911 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -217,6 +217,7 @@ gss_verify_mic_kerberos(struct gss_ctx *gss_ctx,
 		BUG();
 	case ENCTYPE_DES_CBC_RAW:
 	case ENCTYPE_DES3_CBC_RAW:
+	case ENCTYPE_ARCFOUR_HMAC:
 		return gss_verify_mic_v1(ctx, message_buffer, read_token);
 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 8269f37..5a70d02 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -234,9 +234,26 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 			       seq_send, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8)))
 		return GSS_S_FAILURE;
 
-	if (gss_encrypt_xdr_buf(kctx->enc, buf, offset + headlen - conflen,
-									pages))
-		return GSS_S_FAILURE;
+	if (kctx->enctype == ENCTYPE_ARCFOUR_HMAC) {
+		struct crypto_blkcipher *cipher;
+		int err;
+		cipher = crypto_alloc_blkcipher(kctx->gk5e->encrypt_name, 0,
+						CRYPTO_ALG_ASYNC);
+		if (IS_ERR(cipher))
+			return GSS_S_FAILURE;
+
+		krb5_rc4_setup_enc_key(kctx, cipher, seq_send);
+
+		err = gss_encrypt_xdr_buf(cipher, buf,
+					  offset + headlen - conflen, pages);
+		crypto_free_blkcipher(cipher);
+		if (err)
+			return GSS_S_FAILURE;
+	} else {
+		if (gss_encrypt_xdr_buf(kctx->enc, buf,
+					offset + headlen - conflen, pages))
+			return GSS_S_FAILURE;
+	}
 
 	return (kctx->endtime < now) ? GSS_S_CONTEXT_EXPIRED : GSS_S_COMPLETE;
 }
@@ -293,8 +310,37 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	 */
 	crypt_offset = ptr + (GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength) -
 					(unsigned char *)buf->head[0].iov_base;
-	if (gss_decrypt_xdr_buf(kctx->enc, buf, crypt_offset))
-		return GSS_S_DEFECTIVE_TOKEN;
+
+	/*
+	 * Need plaintext seqnum to derive encryption key for arcfour-hmac
+	 */
+	if (krb5_get_seq_num(kctx, kctx->seq, ptr + GSS_KRB5_TOK_HDR_LEN,
+			     ptr + 8, &direction, &seqnum))
+		return GSS_S_BAD_SIG;
+
+	if ((kctx->initiate && direction != 0xff) ||
+	    (!kctx->initiate && direction != 0))
+		return GSS_S_BAD_SIG;
+
+	if (kctx->enctype == ENCTYPE_ARCFOUR_HMAC) {
+		struct crypto_blkcipher *cipher;
+		int err;
+
+		cipher = crypto_alloc_blkcipher(kctx->gk5e->encrypt_name, 0,
+						CRYPTO_ALG_ASYNC);
+		if (IS_ERR(cipher))
+			return GSS_S_FAILURE;
+
+		krb5_rc4_setup_enc_key(kctx, cipher, seqnum);
+
+		err = gss_decrypt_xdr_buf(cipher, buf, crypt_offset);
+		crypto_free_blkcipher(cipher);
+		if (err)
+			return GSS_S_DEFECTIVE_TOKEN;
+	} else {
+		if (gss_decrypt_xdr_buf(kctx->enc, buf, crypt_offset))
+			return GSS_S_DEFECTIVE_TOKEN;
+	}
 
 	if (kctx->gk5e->keyed_cksum)
 		cksumkey = kctx->cksum;
@@ -318,14 +364,6 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 
 	/* do sequencing checks */
 
-	if (krb5_get_seq_num(kctx, kctx->seq, ptr + GSS_KRB5_TOK_HDR_LEN,
-				    ptr + 8, &direction, &seqnum))
-		return GSS_S_BAD_SIG;
-
-	if ((kctx->initiate && direction != 0xff) ||
-	    (!kctx->initiate && direction != 0))
-		return GSS_S_BAD_SIG;
-
 	/* Copy the data back to the right position.  XXX: Would probably be
 	 * better to copy and encrypt at the same time. */
 
@@ -596,6 +634,7 @@ gss_wrap_kerberos(struct gss_ctx *gctx, int offset,
 		BUG();
 	case ENCTYPE_DES_CBC_RAW:
 	case ENCTYPE_DES3_CBC_RAW:
+	case ENCTYPE_ARCFOUR_HMAC:
 		return gss_wrap_kerberos_v1(kctx, offset, buf, pages);
 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
@@ -613,6 +652,7 @@ gss_unwrap_kerberos(struct gss_ctx *gctx, int offset, struct xdr_buf *buf)
 		BUG();
 	case ENCTYPE_DES_CBC_RAW:
 	case ENCTYPE_DES3_CBC_RAW:
+	case ENCTYPE_ARCFOUR_HMAC:
 		return gss_unwrap_kerberos_v1(kctx, offset, buf);
 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:

