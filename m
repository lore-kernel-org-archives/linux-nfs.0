Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:42770 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754680AbcAXNSj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:18:39 -0500
Subject: [PATCH 12/26] sunrpc: Use skcipher and ahash/shash
References: <20160124131021.GA31153@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        dm-devel@redhat.com, linux-wireless@vger.kernel.org,
        linux-cifs@vger.kernel.org, ecryptfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
        linux-bluetooth@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-wpan@vger.kernel.org, linux-afs@lists.infradead.org,
        drbd-dev@lists.linbit.com, open-iscsi@googlegroups.com
Message-Id: <E1aNKYJ-0008Cz-B1@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:17:59 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of blkcipher with skcipher and the long
obsolete hash interface with either shash (for non-SG users) and
ahash.
   
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/sunrpc/gss_krb5.h       |   32 +--
 net/sunrpc/auth_gss/gss_krb5_crypto.c |  350 ++++++++++++++++++++--------------
 net/sunrpc/auth_gss/gss_krb5_keys.c   |   12 -
 net/sunrpc/auth_gss/gss_krb5_mech.c   |   89 ++++----
 net/sunrpc/auth_gss/gss_krb5_seqnum.c |   22 +-
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |   24 +-
 6 files changed, 306 insertions(+), 223 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index df02a41..7df625d 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -36,7 +36,7 @@
  *
  */
 
-#include <linux/crypto.h>
+#include <crypto/skcipher.h>
 #include <linux/sunrpc/auth_gss.h>
 #include <linux/sunrpc/gss_err.h>
 #include <linux/sunrpc/gss_asn1.h>
@@ -71,10 +71,10 @@ struct gss_krb5_enctype {
 	const u32		keyed_cksum;	/* is it a keyed cksum? */
 	const u32		keybytes;	/* raw key len, in bytes */
 	const u32		keylength;	/* final key len, in bytes */
-	u32 (*encrypt) (struct crypto_blkcipher *tfm,
+	u32 (*encrypt) (struct crypto_skcipher *tfm,
 			void *iv, void *in, void *out,
 			int length);		/* encryption function */
-	u32 (*decrypt) (struct crypto_blkcipher *tfm,
+	u32 (*decrypt) (struct crypto_skcipher *tfm,
 			void *iv, void *in, void *out,
 			int length);		/* decryption function */
 	u32 (*mk_key) (const struct gss_krb5_enctype *gk5e,
@@ -98,12 +98,12 @@ struct krb5_ctx {
 	u32			enctype;
 	u32			flags;
 	const struct gss_krb5_enctype *gk5e; /* enctype-specific info */
-	struct crypto_blkcipher	*enc;
-	struct crypto_blkcipher	*seq;
-	struct crypto_blkcipher *acceptor_enc;
-	struct crypto_blkcipher *initiator_enc;
-	struct crypto_blkcipher *acceptor_enc_aux;
-	struct crypto_blkcipher *initiator_enc_aux;
+	struct crypto_skcipher	*enc;
+	struct crypto_skcipher	*seq;
+	struct crypto_skcipher *acceptor_enc;
+	struct crypto_skcipher *initiator_enc;
+	struct crypto_skcipher *acceptor_enc_aux;
+	struct crypto_skcipher *initiator_enc_aux;
 	u8			Ksess[GSS_KRB5_MAX_KEYLEN]; /* session key */
 	u8			cksum[GSS_KRB5_MAX_KEYLEN];
 	s32			endtime;
@@ -262,24 +262,24 @@ gss_unwrap_kerberos(struct gss_ctx *ctx_id, int offset,
 
 
 u32
-krb5_encrypt(struct crypto_blkcipher *key,
+krb5_encrypt(struct crypto_skcipher *key,
 	     void *iv, void *in, void *out, int length);
 
 u32
-krb5_decrypt(struct crypto_blkcipher *key,
+krb5_decrypt(struct crypto_skcipher *key,
 	     void *iv, void *in, void *out, int length); 
 
 int
-gss_encrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *outbuf,
+gss_encrypt_xdr_buf(struct crypto_skcipher *tfm, struct xdr_buf *outbuf,
 		    int offset, struct page **pages);
 
 int
-gss_decrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *inbuf,
+gss_decrypt_xdr_buf(struct crypto_skcipher *tfm, struct xdr_buf *inbuf,
 		    int offset);
 
 s32
 krb5_make_seq_num(struct krb5_ctx *kctx,
-		struct crypto_blkcipher *key,
+		struct crypto_skcipher *key,
 		int direction,
 		u32 seqnum, unsigned char *cksum, unsigned char *buf);
 
@@ -320,12 +320,12 @@ gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset,
 
 int
 krb5_rc4_setup_seq_key(struct krb5_ctx *kctx,
-		       struct crypto_blkcipher *cipher,
+		       struct crypto_skcipher *cipher,
 		       unsigned char *cksum);
 
 int
 krb5_rc4_setup_enc_key(struct krb5_ctx *kctx,
-		       struct crypto_blkcipher *cipher,
+		       struct crypto_skcipher *cipher,
 		       s32 seqnum);
 void
 gss_krb5_make_confounder(char *p, u32 conflen);
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index fee3c15..d94a8e1 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -34,11 +34,12 @@
  * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
  */
 
+#include <crypto/hash.h>
+#include <crypto/skcipher.h>
 #include <linux/err.h>
 #include <linux/types.h>
 #include <linux/mm.h>
 #include <linux/scatterlist.h>
-#include <linux/crypto.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
 #include <linux/random.h>
@@ -51,7 +52,7 @@
 
 u32
 krb5_encrypt(
-	struct crypto_blkcipher *tfm,
+	struct crypto_skcipher *tfm,
 	void * iv,
 	void * in,
 	void * out,
@@ -60,24 +61,28 @@ krb5_encrypt(
 	u32 ret = -EINVAL;
 	struct scatterlist sg[1];
 	u8 local_iv[GSS_KRB5_MAX_BLOCKSIZE] = {0};
-	struct blkcipher_desc desc = { .tfm = tfm, .info = local_iv };
+	SKCIPHER_REQUEST_ON_STACK(req, tfm);
 
-	if (length % crypto_blkcipher_blocksize(tfm) != 0)
+	if (length % crypto_skcipher_blocksize(tfm) != 0)
 		goto out;
 
-	if (crypto_blkcipher_ivsize(tfm) > GSS_KRB5_MAX_BLOCKSIZE) {
+	if (crypto_skcipher_ivsize(tfm) > GSS_KRB5_MAX_BLOCKSIZE) {
 		dprintk("RPC:       gss_k5encrypt: tfm iv size too large %d\n",
-			crypto_blkcipher_ivsize(tfm));
+			crypto_skcipher_ivsize(tfm));
 		goto out;
 	}
 
 	if (iv)
-		memcpy(local_iv, iv, crypto_blkcipher_ivsize(tfm));
+		memcpy(local_iv, iv, crypto_skcipher_ivsize(tfm));
 
 	memcpy(out, in, length);
 	sg_init_one(sg, out, length);
 
-	ret = crypto_blkcipher_encrypt_iv(&desc, sg, sg, length);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, sg, sg, length, local_iv);
+
+	ret = crypto_skcipher_encrypt(req);
+	skcipher_request_zero(req);
 out:
 	dprintk("RPC:       krb5_encrypt returns %d\n", ret);
 	return ret;
@@ -85,7 +90,7 @@ out:
 
 u32
 krb5_decrypt(
-     struct crypto_blkcipher *tfm,
+     struct crypto_skcipher *tfm,
      void * iv,
      void * in,
      void * out,
@@ -94,23 +99,27 @@ krb5_decrypt(
 	u32 ret = -EINVAL;
 	struct scatterlist sg[1];
 	u8 local_iv[GSS_KRB5_MAX_BLOCKSIZE] = {0};
-	struct blkcipher_desc desc = { .tfm = tfm, .info = local_iv };
+	SKCIPHER_REQUEST_ON_STACK(req, tfm);
 
-	if (length % crypto_blkcipher_blocksize(tfm) != 0)
+	if (length % crypto_skcipher_blocksize(tfm) != 0)
 		goto out;
 
-	if (crypto_blkcipher_ivsize(tfm) > GSS_KRB5_MAX_BLOCKSIZE) {
+	if (crypto_skcipher_ivsize(tfm) > GSS_KRB5_MAX_BLOCKSIZE) {
 		dprintk("RPC:       gss_k5decrypt: tfm iv size too large %d\n",
-			crypto_blkcipher_ivsize(tfm));
+			crypto_skcipher_ivsize(tfm));
 		goto out;
 	}
 	if (iv)
-		memcpy(local_iv,iv, crypto_blkcipher_ivsize(tfm));
+		memcpy(local_iv,iv, crypto_skcipher_ivsize(tfm));
 
 	memcpy(out, in, length);
 	sg_init_one(sg, out, length);
 
-	ret = crypto_blkcipher_decrypt_iv(&desc, sg, sg, length);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, sg, sg, length, local_iv);
+
+	ret = crypto_skcipher_decrypt(req);
+	skcipher_request_zero(req);
 out:
 	dprintk("RPC:       gss_k5decrypt returns %d\n",ret);
 	return ret;
@@ -119,9 +128,11 @@ out:
 static int
 checksummer(struct scatterlist *sg, void *data)
 {
-	struct hash_desc *desc = data;
+	struct ahash_request *req = data;
+
+	ahash_request_set_crypt(req, sg, NULL, sg->length);
 
-	return crypto_hash_update(desc, sg, sg->length);
+	return crypto_ahash_update(req);
 }
 
 static int
@@ -152,13 +163,13 @@ make_checksum_hmac_md5(struct krb5_ctx *kctx, char *header, int hdrlen,
 		       struct xdr_buf *body, int body_offset, u8 *cksumkey,
 		       unsigned int usage, struct xdr_netobj *cksumout)
 {
-	struct hash_desc                desc;
 	struct scatterlist              sg[1];
 	int err;
 	u8 checksumdata[GSS_KRB5_MAX_CKSUM_LEN];
 	u8 rc4salt[4];
-	struct crypto_hash *md5;
-	struct crypto_hash *hmac_md5;
+	struct crypto_ahash *md5;
+	struct crypto_ahash *hmac_md5;
+	struct ahash_request *req;
 
 	if (cksumkey == NULL)
 		return GSS_S_FAILURE;
@@ -174,61 +185,79 @@ make_checksum_hmac_md5(struct krb5_ctx *kctx, char *header, int hdrlen,
 		return GSS_S_FAILURE;
 	}
 
-	md5 = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
+	md5 = crypto_alloc_ahash("md5", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(md5))
 		return GSS_S_FAILURE;
 
-	hmac_md5 = crypto_alloc_hash(kctx->gk5e->cksum_name, 0,
-				     CRYPTO_ALG_ASYNC);
+	hmac_md5 = crypto_alloc_ahash(kctx->gk5e->cksum_name, 0,
+				      CRYPTO_ALG_ASYNC);
 	if (IS_ERR(hmac_md5)) {
-		crypto_free_hash(md5);
+		crypto_free_ahash(md5);
+		return GSS_S_FAILURE;
+	}
+
+	req = ahash_request_alloc(md5, GFP_KERNEL);
+	if (!req) {
+		crypto_free_ahash(hmac_md5);
+		crypto_free_ahash(md5);
 		return GSS_S_FAILURE;
 	}
 
-	desc.tfm = md5;
-	desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
+	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
 
-	err = crypto_hash_init(&desc);
+	err = crypto_ahash_init(req);
 	if (err)
 		goto out;
 	sg_init_one(sg, rc4salt, 4);
-	err = crypto_hash_update(&desc, sg, 4);
+	ahash_request_set_crypt(req, sg, NULL, 4);
+	err = crypto_ahash_update(req);
 	if (err)
 		goto out;
 
 	sg_init_one(sg, header, hdrlen);
-	err = crypto_hash_update(&desc, sg, hdrlen);
+	ahash_request_set_crypt(req, sg, NULL, hdrlen);
+	err = crypto_ahash_update(req);
 	if (err)
 		goto out;
 	err = xdr_process_buf(body, body_offset, body->len - body_offset,
-			      checksummer, &desc);
+			      checksummer, req);
 	if (err)
 		goto out;
-	err = crypto_hash_final(&desc, checksumdata);
+	ahash_request_set_crypt(req, NULL, checksumdata, 0);
+	err = crypto_ahash_final(req);
 	if (err)
 		goto out;
 
-	desc.tfm = hmac_md5;
-	desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
+	ahash_request_free(req);
+	req = ahash_request_alloc(hmac_md5, GFP_KERNEL);
+	if (!req) {
+		crypto_free_ahash(hmac_md5);
+		crypto_free_ahash(md5);
+		return GSS_S_FAILURE;
+	}
+
+	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
 
-	err = crypto_hash_init(&desc);
+	err = crypto_ahash_init(req);
 	if (err)
 		goto out;
-	err = crypto_hash_setkey(hmac_md5, cksumkey, kctx->gk5e->keylength);
+	err = crypto_ahash_setkey(hmac_md5, cksumkey, kctx->gk5e->keylength);
 	if (err)
 		goto out;
 
-	sg_init_one(sg, checksumdata, crypto_hash_digestsize(md5));
-	err = crypto_hash_digest(&desc, sg, crypto_hash_digestsize(md5),
-				 checksumdata);
+	sg_init_one(sg, checksumdata, crypto_ahash_digestsize(md5));
+	ahash_request_set_crypt(req, sg, checksumdata,
+				crypto_ahash_digestsize(md5));
+	err = crypto_ahash_digest(req);
 	if (err)
 		goto out;
 
 	memcpy(cksumout->data, checksumdata, kctx->gk5e->cksumlength);
 	cksumout->len = kctx->gk5e->cksumlength;
 out:
-	crypto_free_hash(md5);
-	crypto_free_hash(hmac_md5);
+	ahash_request_free(req);
+	crypto_free_ahash(md5);
+	crypto_free_ahash(hmac_md5);
 	return err ? GSS_S_FAILURE : 0;
 }
 
@@ -242,7 +271,8 @@ make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
 	      struct xdr_buf *body, int body_offset, u8 *cksumkey,
 	      unsigned int usage, struct xdr_netobj *cksumout)
 {
-	struct hash_desc                desc;
+	struct crypto_ahash *tfm;
+	struct ahash_request *req;
 	struct scatterlist              sg[1];
 	int err;
 	u8 checksumdata[GSS_KRB5_MAX_CKSUM_LEN];
@@ -259,32 +289,41 @@ make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
 		return GSS_S_FAILURE;
 	}
 
-	desc.tfm = crypto_alloc_hash(kctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
-	if (IS_ERR(desc.tfm))
+	tfm = crypto_alloc_ahash(kctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(tfm))
 		return GSS_S_FAILURE;
-	desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
 
-	checksumlen = crypto_hash_digestsize(desc.tfm);
+	req = ahash_request_alloc(tfm, GFP_KERNEL);
+	if (!req) {
+		crypto_free_ahash(tfm);
+		return GSS_S_FAILURE;
+	}
+
+	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
+
+	checksumlen = crypto_ahash_digestsize(tfm);
 
 	if (cksumkey != NULL) {
-		err = crypto_hash_setkey(desc.tfm, cksumkey,
-					 kctx->gk5e->keylength);
+		err = crypto_ahash_setkey(tfm, cksumkey,
+					  kctx->gk5e->keylength);
 		if (err)
 			goto out;
 	}
 
-	err = crypto_hash_init(&desc);
+	err = crypto_ahash_init(req);
 	if (err)
 		goto out;
 	sg_init_one(sg, header, hdrlen);
-	err = crypto_hash_update(&desc, sg, hdrlen);
+	ahash_request_set_crypt(req, sg, NULL, hdrlen);
+	err = crypto_ahash_update(req);
 	if (err)
 		goto out;
 	err = xdr_process_buf(body, body_offset, body->len - body_offset,
-			      checksummer, &desc);
+			      checksummer, req);
 	if (err)
 		goto out;
-	err = crypto_hash_final(&desc, checksumdata);
+	ahash_request_set_crypt(req, NULL, checksumdata, 0);
+	err = crypto_ahash_final(req);
 	if (err)
 		goto out;
 
@@ -307,7 +346,8 @@ make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
 	}
 	cksumout->len = kctx->gk5e->cksumlength;
 out:
-	crypto_free_hash(desc.tfm);
+	ahash_request_free(req);
+	crypto_free_ahash(tfm);
 	return err ? GSS_S_FAILURE : 0;
 }
 
@@ -323,7 +363,8 @@ make_checksum_v2(struct krb5_ctx *kctx, char *header, int hdrlen,
 		 struct xdr_buf *body, int body_offset, u8 *cksumkey,
 		 unsigned int usage, struct xdr_netobj *cksumout)
 {
-	struct hash_desc desc;
+	struct crypto_ahash *tfm;
+	struct ahash_request *req;
 	struct scatterlist sg[1];
 	int err;
 	u8 checksumdata[GSS_KRB5_MAX_CKSUM_LEN];
@@ -340,31 +381,39 @@ make_checksum_v2(struct krb5_ctx *kctx, char *header, int hdrlen,
 		return GSS_S_FAILURE;
 	}
 
-	desc.tfm = crypto_alloc_hash(kctx->gk5e->cksum_name, 0,
-							CRYPTO_ALG_ASYNC);
-	if (IS_ERR(desc.tfm))
+	tfm = crypto_alloc_ahash(kctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(tfm))
 		return GSS_S_FAILURE;
-	checksumlen = crypto_hash_digestsize(desc.tfm);
-	desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
+	checksumlen = crypto_ahash_digestsize(tfm);
+
+	req = ahash_request_alloc(tfm, GFP_KERNEL);
+	if (!req) {
+		crypto_free_ahash(tfm);
+		return GSS_S_FAILURE;
+	}
 
-	err = crypto_hash_setkey(desc.tfm, cksumkey, kctx->gk5e->keylength);
+	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
+
+	err = crypto_ahash_setkey(tfm, cksumkey, kctx->gk5e->keylength);
 	if (err)
 		goto out;
 
-	err = crypto_hash_init(&desc);
+	err = crypto_ahash_init(req);
 	if (err)
 		goto out;
 	err = xdr_process_buf(body, body_offset, body->len - body_offset,
-			      checksummer, &desc);
+			      checksummer, req);
 	if (err)
 		goto out;
 	if (header != NULL) {
 		sg_init_one(sg, header, hdrlen);
-		err = crypto_hash_update(&desc, sg, hdrlen);
+		ahash_request_set_crypt(req, sg, NULL, hdrlen);
+		err = crypto_ahash_update(req);
 		if (err)
 			goto out;
 	}
-	err = crypto_hash_final(&desc, checksumdata);
+	ahash_request_set_crypt(req, NULL, checksumdata, 0);
+	err = crypto_ahash_final(req);
 	if (err)
 		goto out;
 
@@ -381,13 +430,14 @@ make_checksum_v2(struct krb5_ctx *kctx, char *header, int hdrlen,
 		break;
 	}
 out:
-	crypto_free_hash(desc.tfm);
+	ahash_request_free(req);
+	crypto_free_ahash(tfm);
 	return err ? GSS_S_FAILURE : 0;
 }
 
 struct encryptor_desc {
 	u8 iv[GSS_KRB5_MAX_BLOCKSIZE];
-	struct blkcipher_desc desc;
+	struct skcipher_request *req;
 	int pos;
 	struct xdr_buf *outbuf;
 	struct page **pages;
@@ -402,6 +452,7 @@ encryptor(struct scatterlist *sg, void *data)
 {
 	struct encryptor_desc *desc = data;
 	struct xdr_buf *outbuf = desc->outbuf;
+	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(desc->req);
 	struct page *in_page;
 	int thislen = desc->fraglen + sg->length;
 	int fraglen, ret;
@@ -427,7 +478,7 @@ encryptor(struct scatterlist *sg, void *data)
 	desc->fraglen += sg->length;
 	desc->pos += sg->length;
 
-	fraglen = thislen & (crypto_blkcipher_blocksize(desc->desc.tfm) - 1);
+	fraglen = thislen & (crypto_skcipher_blocksize(tfm) - 1);
 	thislen -= fraglen;
 
 	if (thislen == 0)
@@ -436,8 +487,10 @@ encryptor(struct scatterlist *sg, void *data)
 	sg_mark_end(&desc->infrags[desc->fragno - 1]);
 	sg_mark_end(&desc->outfrags[desc->fragno - 1]);
 
-	ret = crypto_blkcipher_encrypt_iv(&desc->desc, desc->outfrags,
-					  desc->infrags, thislen);
+	skcipher_request_set_crypt(desc->req, desc->infrags, desc->outfrags,
+				   thislen, desc->iv);
+
+	ret = crypto_skcipher_encrypt(desc->req);
 	if (ret)
 		return ret;
 
@@ -459,18 +512,20 @@ encryptor(struct scatterlist *sg, void *data)
 }
 
 int
-gss_encrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *buf,
+gss_encrypt_xdr_buf(struct crypto_skcipher *tfm, struct xdr_buf *buf,
 		    int offset, struct page **pages)
 {
 	int ret;
 	struct encryptor_desc desc;
+	SKCIPHER_REQUEST_ON_STACK(req, tfm);
+
+	BUG_ON((buf->len - offset) % crypto_skcipher_blocksize(tfm) != 0);
 
-	BUG_ON((buf->len - offset) % crypto_blkcipher_blocksize(tfm) != 0);
+	skcipher_request_set_tfm(req, tfm);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
 
 	memset(desc.iv, 0, sizeof(desc.iv));
-	desc.desc.tfm = tfm;
-	desc.desc.info = desc.iv;
-	desc.desc.flags = 0;
+	desc.req = req;
 	desc.pos = offset;
 	desc.outbuf = buf;
 	desc.pages = pages;
@@ -481,12 +536,13 @@ gss_encrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *buf,
 	sg_init_table(desc.outfrags, 4);
 
 	ret = xdr_process_buf(buf, offset, buf->len - offset, encryptor, &desc);
+	skcipher_request_zero(req);
 	return ret;
 }
 
 struct decryptor_desc {
 	u8 iv[GSS_KRB5_MAX_BLOCKSIZE];
-	struct blkcipher_desc desc;
+	struct skcipher_request *req;
 	struct scatterlist frags[4];
 	int fragno;
 	int fraglen;
@@ -497,6 +553,7 @@ decryptor(struct scatterlist *sg, void *data)
 {
 	struct decryptor_desc *desc = data;
 	int thislen = desc->fraglen + sg->length;
+	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(desc->req);
 	int fraglen, ret;
 
 	/* Worst case is 4 fragments: head, end of page 1, start
@@ -507,7 +564,7 @@ decryptor(struct scatterlist *sg, void *data)
 	desc->fragno++;
 	desc->fraglen += sg->length;
 
-	fraglen = thislen & (crypto_blkcipher_blocksize(desc->desc.tfm) - 1);
+	fraglen = thislen & (crypto_skcipher_blocksize(tfm) - 1);
 	thislen -= fraglen;
 
 	if (thislen == 0)
@@ -515,8 +572,10 @@ decryptor(struct scatterlist *sg, void *data)
 
 	sg_mark_end(&desc->frags[desc->fragno - 1]);
 
-	ret = crypto_blkcipher_decrypt_iv(&desc->desc, desc->frags,
-					  desc->frags, thislen);
+	skcipher_request_set_crypt(desc->req, desc->frags, desc->frags,
+				   thislen, desc->iv);
+
+	ret = crypto_skcipher_decrypt(desc->req);
 	if (ret)
 		return ret;
 
@@ -535,24 +594,29 @@ decryptor(struct scatterlist *sg, void *data)
 }
 
 int
-gss_decrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *buf,
+gss_decrypt_xdr_buf(struct crypto_skcipher *tfm, struct xdr_buf *buf,
 		    int offset)
 {
+	int ret;
 	struct decryptor_desc desc;
+	SKCIPHER_REQUEST_ON_STACK(req, tfm);
 
 	/* XXXJBF: */
-	BUG_ON((buf->len - offset) % crypto_blkcipher_blocksize(tfm) != 0);
+	BUG_ON((buf->len - offset) % crypto_skcipher_blocksize(tfm) != 0);
+
+	skcipher_request_set_tfm(req, tfm);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
 
 	memset(desc.iv, 0, sizeof(desc.iv));
-	desc.desc.tfm = tfm;
-	desc.desc.info = desc.iv;
-	desc.desc.flags = 0;
+	desc.req = req;
 	desc.fragno = 0;
 	desc.fraglen = 0;
 
 	sg_init_table(desc.frags, 4);
 
-	return xdr_process_buf(buf, offset, buf->len - offset, decryptor, &desc);
+	ret = xdr_process_buf(buf, offset, buf->len - offset, decryptor, &desc);
+	skcipher_request_zero(req);
+	return ret;
 }
 
 /*
@@ -594,12 +658,12 @@ xdr_extend_head(struct xdr_buf *buf, unsigned int base, unsigned int shiftlen)
 }
 
 static u32
-gss_krb5_cts_crypt(struct crypto_blkcipher *cipher, struct xdr_buf *buf,
+gss_krb5_cts_crypt(struct crypto_skcipher *cipher, struct xdr_buf *buf,
 		   u32 offset, u8 *iv, struct page **pages, int encrypt)
 {
 	u32 ret;
 	struct scatterlist sg[1];
-	struct blkcipher_desc desc = { .tfm = cipher, .info = iv };
+	SKCIPHER_REQUEST_ON_STACK(req, cipher);
 	u8 data[GSS_KRB5_MAX_BLOCKSIZE * 2];
 	struct page **save_pages;
 	u32 len = buf->len - offset;
@@ -625,10 +689,16 @@ gss_krb5_cts_crypt(struct crypto_blkcipher *cipher, struct xdr_buf *buf,
 
 	sg_init_one(sg, data, len);
 
+	skcipher_request_set_tfm(req, cipher);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, sg, sg, len, iv);
+
 	if (encrypt)
-		ret = crypto_blkcipher_encrypt_iv(&desc, sg, sg, len);
+		ret = crypto_skcipher_encrypt(req);
 	else
-		ret = crypto_blkcipher_decrypt_iv(&desc, sg, sg, len);
+		ret = crypto_skcipher_decrypt(req);
+
+	skcipher_request_zero(req);
 
 	if (ret)
 		goto out;
@@ -647,7 +717,7 @@ gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
 	struct xdr_netobj hmac;
 	u8 *cksumkey;
 	u8 *ecptr;
-	struct crypto_blkcipher *cipher, *aux_cipher;
+	struct crypto_skcipher *cipher, *aux_cipher;
 	int blocksize;
 	struct page **save_pages;
 	int nblocks, nbytes;
@@ -666,7 +736,7 @@ gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
 		cksumkey = kctx->acceptor_integ;
 		usage = KG_USAGE_ACCEPTOR_SEAL;
 	}
-	blocksize = crypto_blkcipher_blocksize(cipher);
+	blocksize = crypto_skcipher_blocksize(cipher);
 
 	/* hide the gss token header and insert the confounder */
 	offset += GSS_KRB5_TOK_HDR_LEN;
@@ -719,20 +789,24 @@ gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
 	memset(desc.iv, 0, sizeof(desc.iv));
 
 	if (cbcbytes) {
+		SKCIPHER_REQUEST_ON_STACK(req, aux_cipher);
+
 		desc.pos = offset + GSS_KRB5_TOK_HDR_LEN;
 		desc.fragno = 0;
 		desc.fraglen = 0;
 		desc.pages = pages;
 		desc.outbuf = buf;
-		desc.desc.info = desc.iv;
-		desc.desc.flags = 0;
-		desc.desc.tfm = aux_cipher;
+		desc.req = req;
+
+		skcipher_request_set_tfm(req, aux_cipher);
+		skcipher_request_set_callback(req, 0, NULL, NULL);
 
 		sg_init_table(desc.infrags, 4);
 		sg_init_table(desc.outfrags, 4);
 
 		err = xdr_process_buf(buf, offset + GSS_KRB5_TOK_HDR_LEN,
 				      cbcbytes, encryptor, &desc);
+		skcipher_request_zero(req);
 		if (err)
 			goto out_err;
 	}
@@ -763,7 +837,7 @@ gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf,
 	struct xdr_buf subbuf;
 	u32 ret = 0;
 	u8 *cksum_key;
-	struct crypto_blkcipher *cipher, *aux_cipher;
+	struct crypto_skcipher *cipher, *aux_cipher;
 	struct xdr_netobj our_hmac_obj;
 	u8 our_hmac[GSS_KRB5_MAX_CKSUM_LEN];
 	u8 pkt_hmac[GSS_KRB5_MAX_CKSUM_LEN];
@@ -782,7 +856,7 @@ gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf,
 		cksum_key = kctx->initiator_integ;
 		usage = KG_USAGE_INITIATOR_SEAL;
 	}
-	blocksize = crypto_blkcipher_blocksize(cipher);
+	blocksize = crypto_skcipher_blocksize(cipher);
 
 
 	/* create a segment skipping the header and leaving out the checksum */
@@ -799,15 +873,19 @@ gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf,
 	memset(desc.iv, 0, sizeof(desc.iv));
 
 	if (cbcbytes) {
+		SKCIPHER_REQUEST_ON_STACK(req, aux_cipher);
+
 		desc.fragno = 0;
 		desc.fraglen = 0;
-		desc.desc.info = desc.iv;
-		desc.desc.flags = 0;
-		desc.desc.tfm = aux_cipher;
+		desc.req = req;
+
+		skcipher_request_set_tfm(req, aux_cipher);
+		skcipher_request_set_callback(req, 0, NULL, NULL);
 
 		sg_init_table(desc.frags, 4);
 
 		ret = xdr_process_buf(&subbuf, 0, cbcbytes, decryptor, &desc);
+		skcipher_request_zero(req);
 		if (ret)
 			goto out_err;
 	}
@@ -850,61 +928,62 @@ out_err:
  * Set the key of the given cipher.
  */
 int
-krb5_rc4_setup_seq_key(struct krb5_ctx *kctx, struct crypto_blkcipher *cipher,
+krb5_rc4_setup_seq_key(struct krb5_ctx *kctx, struct crypto_skcipher *cipher,
 		       unsigned char *cksum)
 {
-	struct crypto_hash *hmac;
-	struct hash_desc desc;
-	struct scatterlist sg[1];
+	struct crypto_shash *hmac;
+	struct shash_desc *desc;
 	u8 Kseq[GSS_KRB5_MAX_KEYLEN];
 	u32 zeroconstant = 0;
 	int err;
 
 	dprintk("%s: entered\n", __func__);
 
-	hmac = crypto_alloc_hash(kctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
+	hmac = crypto_alloc_shash(kctx->gk5e->cksum_name, 0, 0);
 	if (IS_ERR(hmac)) {
 		dprintk("%s: error %ld, allocating hash '%s'\n",
 			__func__, PTR_ERR(hmac), kctx->gk5e->cksum_name);
 		return PTR_ERR(hmac);
 	}
 
-	desc.tfm = hmac;
-	desc.flags = 0;
+	desc = kmalloc(sizeof(*desc), GFP_KERNEL);
+	if (!desc) {
+		dprintk("%s: failed to allocate shash descriptor for '%s'\n",
+			__func__, kctx->gk5e->cksum_name);
+		crypto_free_shash(hmac);
+		return -ENOMEM;
+	}
 
-	err = crypto_hash_init(&desc);
-	if (err)
-		goto out_err;
+	desc->tfm = hmac;
+	desc->flags = 0;
 
 	/* Compute intermediate Kseq from session key */
-	err = crypto_hash_setkey(hmac, kctx->Ksess, kctx->gk5e->keylength);
+	err = crypto_shash_setkey(hmac, kctx->Ksess, kctx->gk5e->keylength);
 	if (err)
 		goto out_err;
 
-	sg_init_one(sg, &zeroconstant, 4);
-	err = crypto_hash_digest(&desc, sg, 4, Kseq);
+	err = crypto_shash_digest(desc, (u8 *)&zeroconstant, 4, Kseq);
 	if (err)
 		goto out_err;
 
 	/* Compute final Kseq from the checksum and intermediate Kseq */
-	err = crypto_hash_setkey(hmac, Kseq, kctx->gk5e->keylength);
+	err = crypto_shash_setkey(hmac, Kseq, kctx->gk5e->keylength);
 	if (err)
 		goto out_err;
 
-	sg_set_buf(sg, cksum, 8);
-
-	err = crypto_hash_digest(&desc, sg, 8, Kseq);
+	err = crypto_shash_digest(desc, cksum, 8, Kseq);
 	if (err)
 		goto out_err;
 
-	err = crypto_blkcipher_setkey(cipher, Kseq, kctx->gk5e->keylength);
+	err = crypto_skcipher_setkey(cipher, Kseq, kctx->gk5e->keylength);
 	if (err)
 		goto out_err;
 
 	err = 0;
 
 out_err:
-	crypto_free_hash(hmac);
+	kzfree(desc);
+	crypto_free_shash(hmac);
 	dprintk("%s: returning %d\n", __func__, err);
 	return err;
 }
@@ -914,12 +993,11 @@ out_err:
  * Set the key of cipher kctx->enc.
  */
 int
-krb5_rc4_setup_enc_key(struct krb5_ctx *kctx, struct crypto_blkcipher *cipher,
+krb5_rc4_setup_enc_key(struct krb5_ctx *kctx, struct crypto_skcipher *cipher,
 		       s32 seqnum)
 {
-	struct crypto_hash *hmac;
-	struct hash_desc desc;
-	struct scatterlist sg[1];
+	struct crypto_shash *hmac;
+	struct shash_desc *desc;
 	u8 Kcrypt[GSS_KRB5_MAX_KEYLEN];
 	u8 zeroconstant[4] = {0};
 	u8 seqnumarray[4];
@@ -927,35 +1005,38 @@ krb5_rc4_setup_enc_key(struct krb5_ctx *kctx, struct crypto_blkcipher *cipher,
 
 	dprintk("%s: entered, seqnum %u\n", __func__, seqnum);
 
-	hmac = crypto_alloc_hash(kctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
+	hmac = crypto_alloc_shash(kctx->gk5e->cksum_name, 0, 0);
 	if (IS_ERR(hmac)) {
 		dprintk("%s: error %ld, allocating hash '%s'\n",
 			__func__, PTR_ERR(hmac), kctx->gk5e->cksum_name);
 		return PTR_ERR(hmac);
 	}
 
-	desc.tfm = hmac;
-	desc.flags = 0;
+	desc = kmalloc(sizeof(*desc), GFP_KERNEL);
+	if (!desc) {
+		dprintk("%s: failed to allocate shash descriptor for '%s'\n",
+			__func__, kctx->gk5e->cksum_name);
+		crypto_free_shash(hmac);
+		return -ENOMEM;
+	}
 
-	err = crypto_hash_init(&desc);
-	if (err)
-		goto out_err;
+	desc->tfm = hmac;
+	desc->flags = 0;
 
 	/* Compute intermediate Kcrypt from session key */
 	for (i = 0; i < kctx->gk5e->keylength; i++)
 		Kcrypt[i] = kctx->Ksess[i] ^ 0xf0;
 
-	err = crypto_hash_setkey(hmac, Kcrypt, kctx->gk5e->keylength);
+	err = crypto_shash_setkey(hmac, Kcrypt, kctx->gk5e->keylength);
 	if (err)
 		goto out_err;
 
-	sg_init_one(sg, zeroconstant, 4);
-	err = crypto_hash_digest(&desc, sg, 4, Kcrypt);
+	err = crypto_shash_digest(desc, zeroconstant, 4, Kcrypt);
 	if (err)
 		goto out_err;
 
 	/* Compute final Kcrypt from the seqnum and intermediate Kcrypt */
-	err = crypto_hash_setkey(hmac, Kcrypt, kctx->gk5e->keylength);
+	err = crypto_shash_setkey(hmac, Kcrypt, kctx->gk5e->keylength);
 	if (err)
 		goto out_err;
 
@@ -964,20 +1045,19 @@ krb5_rc4_setup_enc_key(struct krb5_ctx *kctx, struct crypto_blkcipher *cipher,
 	seqnumarray[2] = (unsigned char) ((seqnum >> 8) & 0xff);
 	seqnumarray[3] = (unsigned char) ((seqnum >> 0) & 0xff);
 
-	sg_set_buf(sg, seqnumarray, 4);
-
-	err = crypto_hash_digest(&desc, sg, 4, Kcrypt);
+	err = crypto_shash_digest(desc, seqnumarray, 4, Kcrypt);
 	if (err)
 		goto out_err;
 
-	err = crypto_blkcipher_setkey(cipher, Kcrypt, kctx->gk5e->keylength);
+	err = crypto_skcipher_setkey(cipher, Kcrypt, kctx->gk5e->keylength);
 	if (err)
 		goto out_err;
 
 	err = 0;
 
 out_err:
-	crypto_free_hash(hmac);
+	kzfree(desc);
+	crypto_free_shash(hmac);
 	dprintk("%s: returning %d\n", __func__, err);
 	return err;
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_keys.c b/net/sunrpc/auth_gss/gss_krb5_keys.c
index 234fa8d..8701331 100644
--- a/net/sunrpc/auth_gss/gss_krb5_keys.c
+++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
@@ -54,9 +54,9 @@
  * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
  */
 
+#include <crypto/skcipher.h>
 #include <linux/err.h>
 #include <linux/types.h>
-#include <linux/crypto.h>
 #include <linux/sunrpc/gss_krb5.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/lcm.h>
@@ -147,7 +147,7 @@ u32 krb5_derive_key(const struct gss_krb5_enctype *gk5e,
 	size_t blocksize, keybytes, keylength, n;
 	unsigned char *inblockdata, *outblockdata, *rawkey;
 	struct xdr_netobj inblock, outblock;
-	struct crypto_blkcipher *cipher;
+	struct crypto_skcipher *cipher;
 	u32 ret = EINVAL;
 
 	blocksize = gk5e->blocksize;
@@ -157,11 +157,11 @@ u32 krb5_derive_key(const struct gss_krb5_enctype *gk5e,
 	if ((inkey->len != keylength) || (outkey->len != keylength))
 		goto err_return;
 
-	cipher = crypto_alloc_blkcipher(gk5e->encrypt_name, 0,
-					CRYPTO_ALG_ASYNC);
+	cipher = crypto_alloc_skcipher(gk5e->encrypt_name, 0,
+				       CRYPTO_ALG_ASYNC);
 	if (IS_ERR(cipher))
 		goto err_return;
-	if (crypto_blkcipher_setkey(cipher, inkey->data, inkey->len))
+	if (crypto_skcipher_setkey(cipher, inkey->data, inkey->len))
 		goto err_return;
 
 	/* allocate and set up buffers */
@@ -238,7 +238,7 @@ err_free_in:
 	memset(inblockdata, 0, blocksize);
 	kfree(inblockdata);
 err_free_cipher:
-	crypto_free_blkcipher(cipher);
+	crypto_free_skcipher(cipher);
 err_return:
 	return ret;
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 28db442..71341cc 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -34,6 +34,8 @@
  *
  */
 
+#include <crypto/hash.h>
+#include <crypto/skcipher.h>
 #include <linux/err.h>
 #include <linux/module.h>
 #include <linux/init.h>
@@ -42,7 +44,6 @@
 #include <linux/sunrpc/auth.h>
 #include <linux/sunrpc/gss_krb5.h>
 #include <linux/sunrpc/xdr.h>
-#include <linux/crypto.h>
 #include <linux/sunrpc/gss_krb5_enctypes.h>
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
@@ -217,7 +218,7 @@ simple_get_netobj(const void *p, const void *end, struct xdr_netobj *res)
 
 static inline const void *
 get_key(const void *p, const void *end,
-	struct krb5_ctx *ctx, struct crypto_blkcipher **res)
+	struct krb5_ctx *ctx, struct crypto_skcipher **res)
 {
 	struct xdr_netobj	key;
 	int			alg;
@@ -245,7 +246,7 @@ get_key(const void *p, const void *end,
 	if (IS_ERR(p))
 		goto out_err;
 
-	*res = crypto_alloc_blkcipher(ctx->gk5e->encrypt_name, 0,
+	*res = crypto_alloc_skcipher(ctx->gk5e->encrypt_name, 0,
 							CRYPTO_ALG_ASYNC);
 	if (IS_ERR(*res)) {
 		printk(KERN_WARNING "gss_kerberos_mech: unable to initialize "
@@ -253,7 +254,7 @@ get_key(const void *p, const void *end,
 		*res = NULL;
 		goto out_err_free_key;
 	}
-	if (crypto_blkcipher_setkey(*res, key.data, key.len)) {
+	if (crypto_skcipher_setkey(*res, key.data, key.len)) {
 		printk(KERN_WARNING "gss_kerberos_mech: error setting key for "
 			"crypto algorithm %s\n", ctx->gk5e->encrypt_name);
 		goto out_err_free_tfm;
@@ -263,7 +264,7 @@ get_key(const void *p, const void *end,
 	return p;
 
 out_err_free_tfm:
-	crypto_free_blkcipher(*res);
+	crypto_free_skcipher(*res);
 out_err_free_key:
 	kfree(key.data);
 	p = ERR_PTR(-EINVAL);
@@ -335,30 +336,30 @@ gss_import_v1_context(const void *p, const void *end, struct krb5_ctx *ctx)
 	return 0;
 
 out_err_free_key2:
-	crypto_free_blkcipher(ctx->seq);
+	crypto_free_skcipher(ctx->seq);
 out_err_free_key1:
-	crypto_free_blkcipher(ctx->enc);
+	crypto_free_skcipher(ctx->enc);
 out_err_free_mech:
 	kfree(ctx->mech_used.data);
 out_err:
 	return PTR_ERR(p);
 }
 
-static struct crypto_blkcipher *
+static struct crypto_skcipher *
 context_v2_alloc_cipher(struct krb5_ctx *ctx, const char *cname, u8 *key)
 {
-	struct crypto_blkcipher *cp;
+	struct crypto_skcipher *cp;
 
-	cp = crypto_alloc_blkcipher(cname, 0, CRYPTO_ALG_ASYNC);
+	cp = crypto_alloc_skcipher(cname, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(cp)) {
 		dprintk("gss_kerberos_mech: unable to initialize "
 			"crypto algorithm %s\n", cname);
 		return NULL;
 	}
-	if (crypto_blkcipher_setkey(cp, key, ctx->gk5e->keylength)) {
+	if (crypto_skcipher_setkey(cp, key, ctx->gk5e->keylength)) {
 		dprintk("gss_kerberos_mech: error setting key for "
 			"crypto algorithm %s\n", cname);
-		crypto_free_blkcipher(cp);
+		crypto_free_skcipher(cp);
 		return NULL;
 	}
 	return cp;
@@ -412,9 +413,9 @@ context_derive_keys_des3(struct krb5_ctx *ctx, gfp_t gfp_mask)
 	return 0;
 
 out_free_enc:
-	crypto_free_blkcipher(ctx->enc);
+	crypto_free_skcipher(ctx->enc);
 out_free_seq:
-	crypto_free_blkcipher(ctx->seq);
+	crypto_free_skcipher(ctx->seq);
 out_err:
 	return -EINVAL;
 }
@@ -427,18 +428,17 @@ out_err:
 static int
 context_derive_keys_rc4(struct krb5_ctx *ctx)
 {
-	struct crypto_hash *hmac;
+	struct crypto_shash *hmac;
 	char sigkeyconstant[] = "signaturekey";
 	int slen = strlen(sigkeyconstant) + 1;	/* include null terminator */
-	struct hash_desc desc;
-	struct scatterlist sg[1];
+	struct shash_desc *desc;
 	int err;
 
 	dprintk("RPC:       %s: entered\n", __func__);
 	/*
 	 * derive cksum (aka Ksign) key
 	 */
-	hmac = crypto_alloc_hash(ctx->gk5e->cksum_name, 0, CRYPTO_ALG_ASYNC);
+	hmac = crypto_alloc_shash(ctx->gk5e->cksum_name, 0, 0);
 	if (IS_ERR(hmac)) {
 		dprintk("%s: error %ld allocating hash '%s'\n",
 			__func__, PTR_ERR(hmac), ctx->gk5e->cksum_name);
@@ -446,37 +446,40 @@ context_derive_keys_rc4(struct krb5_ctx *ctx)
 		goto out_err;
 	}
 
-	err = crypto_hash_setkey(hmac, ctx->Ksess, ctx->gk5e->keylength);
+	err = crypto_shash_setkey(hmac, ctx->Ksess, ctx->gk5e->keylength);
 	if (err)
 		goto out_err_free_hmac;
 
-	sg_init_table(sg, 1);
-	sg_set_buf(sg, sigkeyconstant, slen);
 
-	desc.tfm = hmac;
-	desc.flags = 0;
-
-	err = crypto_hash_init(&desc);
-	if (err)
+	desc = kmalloc(sizeof(*desc), GFP_KERNEL);
+	if (!desc) {
+		dprintk("%s: failed to allocate hash descriptor for '%s'\n",
+			__func__, ctx->gk5e->cksum_name);
+		err = -ENOMEM;
 		goto out_err_free_hmac;
+	}
+
+	desc->tfm = hmac;
+	desc->flags = 0;
 
-	err = crypto_hash_digest(&desc, sg, slen, ctx->cksum);
+	err = crypto_shash_digest(desc, sigkeyconstant, slen, ctx->cksum);
+	kzfree(desc);
 	if (err)
 		goto out_err_free_hmac;
 	/*
-	 * allocate hash, and blkciphers for data and seqnum encryption
+	 * allocate hash, and skciphers for data and seqnum encryption
 	 */
-	ctx->enc = crypto_alloc_blkcipher(ctx->gk5e->encrypt_name, 0,
-					  CRYPTO_ALG_ASYNC);
+	ctx->enc = crypto_alloc_skcipher(ctx->gk5e->encrypt_name, 0,
+					 CRYPTO_ALG_ASYNC);
 	if (IS_ERR(ctx->enc)) {
 		err = PTR_ERR(ctx->enc);
 		goto out_err_free_hmac;
 	}
 
-	ctx->seq = crypto_alloc_blkcipher(ctx->gk5e->encrypt_name, 0,
-					  CRYPTO_ALG_ASYNC);
+	ctx->seq = crypto_alloc_skcipher(ctx->gk5e->encrypt_name, 0,
+					 CRYPTO_ALG_ASYNC);
 	if (IS_ERR(ctx->seq)) {
-		crypto_free_blkcipher(ctx->enc);
+		crypto_free_skcipher(ctx->enc);
 		err = PTR_ERR(ctx->seq);
 		goto out_err_free_hmac;
 	}
@@ -486,7 +489,7 @@ context_derive_keys_rc4(struct krb5_ctx *ctx)
 	err = 0;
 
 out_err_free_hmac:
-	crypto_free_hash(hmac);
+	crypto_free_shash(hmac);
 out_err:
 	dprintk("RPC:       %s: returning %d\n", __func__, err);
 	return err;
@@ -588,7 +591,7 @@ context_derive_keys_new(struct krb5_ctx *ctx, gfp_t gfp_mask)
 			context_v2_alloc_cipher(ctx, "cbc(aes)",
 						ctx->acceptor_seal);
 		if (ctx->acceptor_enc_aux == NULL) {
-			crypto_free_blkcipher(ctx->initiator_enc_aux);
+			crypto_free_skcipher(ctx->initiator_enc_aux);
 			goto out_free_acceptor_enc;
 		}
 	}
@@ -596,9 +599,9 @@ context_derive_keys_new(struct krb5_ctx *ctx, gfp_t gfp_mask)
 	return 0;
 
 out_free_acceptor_enc:
-	crypto_free_blkcipher(ctx->acceptor_enc);
+	crypto_free_skcipher(ctx->acceptor_enc);
 out_free_initiator_enc:
-	crypto_free_blkcipher(ctx->initiator_enc);
+	crypto_free_skcipher(ctx->initiator_enc);
 out_err:
 	return -EINVAL;
 }
@@ -710,12 +713,12 @@ static void
 gss_delete_sec_context_kerberos(void *internal_ctx) {
 	struct krb5_ctx *kctx = internal_ctx;
 
-	crypto_free_blkcipher(kctx->seq);
-	crypto_free_blkcipher(kctx->enc);
-	crypto_free_blkcipher(kctx->acceptor_enc);
-	crypto_free_blkcipher(kctx->initiator_enc);
-	crypto_free_blkcipher(kctx->acceptor_enc_aux);
-	crypto_free_blkcipher(kctx->initiator_enc_aux);
+	crypto_free_skcipher(kctx->seq);
+	crypto_free_skcipher(kctx->enc);
+	crypto_free_skcipher(kctx->acceptor_enc);
+	crypto_free_skcipher(kctx->initiator_enc);
+	crypto_free_skcipher(kctx->acceptor_enc_aux);
+	crypto_free_skcipher(kctx->initiator_enc_aux);
 	kfree(kctx->mech_used.data);
 	kfree(kctx);
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_seqnum.c b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
index 20d55c7..c8b9082 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seqnum.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
@@ -31,9 +31,9 @@
  * PERFORMANCE OF THIS SOFTWARE.
  */
 
+#include <crypto/skcipher.h>
 #include <linux/types.h>
 #include <linux/sunrpc/gss_krb5.h>
-#include <linux/crypto.h>
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 # define RPCDBG_FACILITY        RPCDBG_AUTH
@@ -43,13 +43,13 @@ static s32
 krb5_make_rc4_seq_num(struct krb5_ctx *kctx, int direction, s32 seqnum,
 		      unsigned char *cksum, unsigned char *buf)
 {
-	struct crypto_blkcipher *cipher;
+	struct crypto_skcipher *cipher;
 	unsigned char plain[8];
 	s32 code;
 
 	dprintk("RPC:       %s:\n", __func__);
-	cipher = crypto_alloc_blkcipher(kctx->gk5e->encrypt_name, 0,
-					CRYPTO_ALG_ASYNC);
+	cipher = crypto_alloc_skcipher(kctx->gk5e->encrypt_name, 0,
+				       CRYPTO_ALG_ASYNC);
 	if (IS_ERR(cipher))
 		return PTR_ERR(cipher);
 
@@ -68,12 +68,12 @@ krb5_make_rc4_seq_num(struct krb5_ctx *kctx, int direction, s32 seqnum,
 
 	code = krb5_encrypt(cipher, cksum, plain, buf, 8);
 out:
-	crypto_free_blkcipher(cipher);
+	crypto_free_skcipher(cipher);
 	return code;
 }
 s32
 krb5_make_seq_num(struct krb5_ctx *kctx,
-		struct crypto_blkcipher *key,
+		struct crypto_skcipher *key,
 		int direction,
 		u32 seqnum,
 		unsigned char *cksum, unsigned char *buf)
@@ -101,13 +101,13 @@ static s32
 krb5_get_rc4_seq_num(struct krb5_ctx *kctx, unsigned char *cksum,
 		     unsigned char *buf, int *direction, s32 *seqnum)
 {
-	struct crypto_blkcipher *cipher;
+	struct crypto_skcipher *cipher;
 	unsigned char plain[8];
 	s32 code;
 
 	dprintk("RPC:       %s:\n", __func__);
-	cipher = crypto_alloc_blkcipher(kctx->gk5e->encrypt_name, 0,
-					CRYPTO_ALG_ASYNC);
+	cipher = crypto_alloc_skcipher(kctx->gk5e->encrypt_name, 0,
+				       CRYPTO_ALG_ASYNC);
 	if (IS_ERR(cipher))
 		return PTR_ERR(cipher);
 
@@ -130,7 +130,7 @@ krb5_get_rc4_seq_num(struct krb5_ctx *kctx, unsigned char *cksum,
 	*seqnum = ((plain[0] << 24) | (plain[1] << 16) |
 					(plain[2] << 8) | (plain[3]));
 out:
-	crypto_free_blkcipher(cipher);
+	crypto_free_skcipher(cipher);
 	return code;
 }
 
@@ -142,7 +142,7 @@ krb5_get_seq_num(struct krb5_ctx *kctx,
 {
 	s32 code;
 	unsigned char plain[8];
-	struct crypto_blkcipher *key = kctx->seq;
+	struct crypto_skcipher *key = kctx->seq;
 
 	dprintk("RPC:       krb5_get_seq_num:\n");
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index ca7e92a..765088e4 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -28,12 +28,12 @@
  * SUCH DAMAGES.
  */
 
+#include <crypto/skcipher.h>
 #include <linux/types.h>
 #include <linux/jiffies.h>
 #include <linux/sunrpc/gss_krb5.h>
 #include <linux/random.h>
 #include <linux/pagemap.h>
-#include <linux/crypto.h>
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 # define RPCDBG_FACILITY	RPCDBG_AUTH
@@ -174,7 +174,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 
 	now = get_seconds();
 
-	blocksize = crypto_blkcipher_blocksize(kctx->enc);
+	blocksize = crypto_skcipher_blocksize(kctx->enc);
 	gss_krb5_add_padding(buf, offset, blocksize);
 	BUG_ON((buf->len - offset) % blocksize);
 	plainlen = conflen + buf->len - offset;
@@ -239,10 +239,10 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 		return GSS_S_FAILURE;
 
 	if (kctx->enctype == ENCTYPE_ARCFOUR_HMAC) {
-		struct crypto_blkcipher *cipher;
+		struct crypto_skcipher *cipher;
 		int err;
-		cipher = crypto_alloc_blkcipher(kctx->gk5e->encrypt_name, 0,
-						CRYPTO_ALG_ASYNC);
+		cipher = crypto_alloc_skcipher(kctx->gk5e->encrypt_name, 0,
+					       CRYPTO_ALG_ASYNC);
 		if (IS_ERR(cipher))
 			return GSS_S_FAILURE;
 
@@ -250,7 +250,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 
 		err = gss_encrypt_xdr_buf(cipher, buf,
 					  offset + headlen - conflen, pages);
-		crypto_free_blkcipher(cipher);
+		crypto_free_skcipher(cipher);
 		if (err)
 			return GSS_S_FAILURE;
 	} else {
@@ -327,18 +327,18 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 		return GSS_S_BAD_SIG;
 
 	if (kctx->enctype == ENCTYPE_ARCFOUR_HMAC) {
-		struct crypto_blkcipher *cipher;
+		struct crypto_skcipher *cipher;
 		int err;
 
-		cipher = crypto_alloc_blkcipher(kctx->gk5e->encrypt_name, 0,
-						CRYPTO_ALG_ASYNC);
+		cipher = crypto_alloc_skcipher(kctx->gk5e->encrypt_name, 0,
+					       CRYPTO_ALG_ASYNC);
 		if (IS_ERR(cipher))
 			return GSS_S_FAILURE;
 
 		krb5_rc4_setup_enc_key(kctx, cipher, seqnum);
 
 		err = gss_decrypt_xdr_buf(cipher, buf, crypt_offset);
-		crypto_free_blkcipher(cipher);
+		crypto_free_skcipher(cipher);
 		if (err)
 			return GSS_S_DEFECTIVE_TOKEN;
 	} else {
@@ -371,7 +371,7 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	/* Copy the data back to the right position.  XXX: Would probably be
 	 * better to copy and encrypt at the same time. */
 
-	blocksize = crypto_blkcipher_blocksize(kctx->enc);
+	blocksize = crypto_skcipher_blocksize(kctx->enc);
 	data_start = ptr + (GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength) +
 					conflen;
 	orig_start = buf->head[0].iov_base + offset;
@@ -473,7 +473,7 @@ gss_wrap_kerberos_v2(struct krb5_ctx *kctx, u32 offset,
 	*ptr++ = 0xff;
 	be16ptr = (__be16 *)ptr;
 
-	blocksize = crypto_blkcipher_blocksize(kctx->acceptor_enc);
+	blocksize = crypto_skcipher_blocksize(kctx->acceptor_enc);
 	*be16ptr++ = 0;
 	/* "inner" token header always uses 0 for RRC */
 	*be16ptr++ = 0;
