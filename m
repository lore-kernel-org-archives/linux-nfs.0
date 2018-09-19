Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pl1-f196.google.com ([209.85.214.196]:36967 "EHLO
        mail-pl1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726771AbeISHqe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Sep 2018 03:46:34 -0400
Received: by mail-pl1-f196.google.com with SMTP id f1-v6so1864111plt.4
        for <linux-nfs@vger.kernel.org>; Tue, 18 Sep 2018 19:11:07 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Kees Cook <keescook@chromium.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        YueHaibing <yuehaibing@huawei.com>, linux-nfs@vger.kernel.org,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Eric Biggers <ebiggers@google.com>,
        linux-crypto <linux-crypto@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: [PATCH crypto-next 02/23] gss_krb5: Remove VLA usage of skcipher
Date: Tue, 18 Sep 2018 19:10:39 -0700
Message-Id: <20180919021100.3380-3-keescook@chromium.org>
In-Reply-To: <20180919021100.3380-1-keescook@chromium.org>
References: <20180919021100.3380-1-keescook@chromium.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the quest to remove all stack VLA usage from the kernel[1], this
replaces struct crypto_skcipher and SKCIPHER_REQUEST_ON_STACK() usage
with struct crypto_sync_skcipher and SYNC_SKCIPHER_REQUEST_ON_STACK(),
which uses a fixed stack size.

[1] https://lkml.kernel.org/r/CA+55aFzCG-zNmZwX4A2FQpadafLfEzK6CC=qPXydAacU1RqZWA@mail.gmail.com

Cc: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@kernel.org>
Cc: YueHaibing <yuehaibing@huawei.com>
Cc: linux-nfs@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/sunrpc/gss_krb5.h       | 30 ++++-----
 net/sunrpc/auth_gss/gss_krb5_crypto.c | 87 ++++++++++++++-------------
 net/sunrpc/auth_gss/gss_krb5_keys.c   |  9 ++-
 net/sunrpc/auth_gss/gss_krb5_mech.c   | 53 ++++++++--------
 net/sunrpc/auth_gss/gss_krb5_seqnum.c | 18 +++---
 net/sunrpc/auth_gss/gss_krb5_wrap.c   | 20 +++---
 6 files changed, 108 insertions(+), 109 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 7df625d41e35..f6e8ceafafd8 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -71,10 +71,10 @@ struct gss_krb5_enctype {
 	const u32		keyed_cksum;	/* is it a keyed cksum? */
 	const u32		keybytes;	/* raw key len, in bytes */
 	const u32		keylength;	/* final key len, in bytes */
-	u32 (*encrypt) (struct crypto_skcipher *tfm,
+	u32 (*encrypt) (struct crypto_sync_skcipher *tfm,
 			void *iv, void *in, void *out,
 			int length);		/* encryption function */
-	u32 (*decrypt) (struct crypto_skcipher *tfm,
+	u32 (*decrypt) (struct crypto_sync_skcipher *tfm,
 			void *iv, void *in, void *out,
 			int length);		/* decryption function */
 	u32 (*mk_key) (const struct gss_krb5_enctype *gk5e,
@@ -98,12 +98,12 @@ struct krb5_ctx {
 	u32			enctype;
 	u32			flags;
 	const struct gss_krb5_enctype *gk5e; /* enctype-specific info */
-	struct crypto_skcipher	*enc;
-	struct crypto_skcipher	*seq;
-	struct crypto_skcipher *acceptor_enc;
-	struct crypto_skcipher *initiator_enc;
-	struct crypto_skcipher *acceptor_enc_aux;
-	struct crypto_skcipher *initiator_enc_aux;
+	struct crypto_sync_skcipher *enc;
+	struct crypto_sync_skcipher *seq;
+	struct crypto_sync_skcipher *acceptor_enc;
+	struct crypto_sync_skcipher *initiator_enc;
+	struct crypto_sync_skcipher *acceptor_enc_aux;
+	struct crypto_sync_skcipher *initiator_enc_aux;
 	u8			Ksess[GSS_KRB5_MAX_KEYLEN]; /* session key */
 	u8			cksum[GSS_KRB5_MAX_KEYLEN];
 	s32			endtime;
@@ -262,24 +262,24 @@ gss_unwrap_kerberos(struct gss_ctx *ctx_id, int offset,
 
 
 u32
-krb5_encrypt(struct crypto_skcipher *key,
+krb5_encrypt(struct crypto_sync_skcipher *key,
 	     void *iv, void *in, void *out, int length);
 
 u32
-krb5_decrypt(struct crypto_skcipher *key,
+krb5_decrypt(struct crypto_sync_skcipher *key,
 	     void *iv, void *in, void *out, int length); 
 
 int
-gss_encrypt_xdr_buf(struct crypto_skcipher *tfm, struct xdr_buf *outbuf,
+gss_encrypt_xdr_buf(struct crypto_sync_skcipher *tfm, struct xdr_buf *outbuf,
 		    int offset, struct page **pages);
 
 int
-gss_decrypt_xdr_buf(struct crypto_skcipher *tfm, struct xdr_buf *inbuf,
+gss_decrypt_xdr_buf(struct crypto_sync_skcipher *tfm, struct xdr_buf *inbuf,
 		    int offset);
 
 s32
 krb5_make_seq_num(struct krb5_ctx *kctx,
-		struct crypto_skcipher *key,
+		struct crypto_sync_skcipher *key,
 		int direction,
 		u32 seqnum, unsigned char *cksum, unsigned char *buf);
 
@@ -320,12 +320,12 @@ gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset,
 
 int
 krb5_rc4_setup_seq_key(struct krb5_ctx *kctx,
-		       struct crypto_skcipher *cipher,
+		       struct crypto_sync_skcipher *cipher,
 		       unsigned char *cksum);
 
 int
 krb5_rc4_setup_enc_key(struct krb5_ctx *kctx,
-		       struct crypto_skcipher *cipher,
+		       struct crypto_sync_skcipher *cipher,
 		       s32 seqnum);
 void
 gss_krb5_make_confounder(char *p, u32 conflen);
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 0220e1ca5280..4f43383971ba 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -53,7 +53,7 @@
 
 u32
 krb5_encrypt(
-	struct crypto_skcipher *tfm,
+	struct crypto_sync_skcipher *tfm,
 	void * iv,
 	void * in,
 	void * out,
@@ -62,24 +62,24 @@ krb5_encrypt(
 	u32 ret = -EINVAL;
 	struct scatterlist sg[1];
 	u8 local_iv[GSS_KRB5_MAX_BLOCKSIZE] = {0};
-	SKCIPHER_REQUEST_ON_STACK(req, tfm);
+	SYNC_SKCIPHER_REQUEST_ON_STACK(req, tfm);
 
-	if (length % crypto_skcipher_blocksize(tfm) != 0)
+	if (length % crypto_sync_skcipher_blocksize(tfm) != 0)
 		goto out;
 
-	if (crypto_skcipher_ivsize(tfm) > GSS_KRB5_MAX_BLOCKSIZE) {
+	if (crypto_sync_skcipher_ivsize(tfm) > GSS_KRB5_MAX_BLOCKSIZE) {
 		dprintk("RPC:       gss_k5encrypt: tfm iv size too large %d\n",
-			crypto_skcipher_ivsize(tfm));
+			crypto_sync_skcipher_ivsize(tfm));
 		goto out;
 	}
 
 	if (iv)
-		memcpy(local_iv, iv, crypto_skcipher_ivsize(tfm));
+		memcpy(local_iv, iv, crypto_sync_skcipher_ivsize(tfm));
 
 	memcpy(out, in, length);
 	sg_init_one(sg, out, length);
 
-	skcipher_request_set_tfm(req, tfm);
+	skcipher_request_set_sync_tfm(req, tfm);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
 	skcipher_request_set_crypt(req, sg, sg, length, local_iv);
 
@@ -92,7 +92,7 @@ krb5_encrypt(
 
 u32
 krb5_decrypt(
-     struct crypto_skcipher *tfm,
+     struct crypto_sync_skcipher *tfm,
      void * iv,
      void * in,
      void * out,
@@ -101,23 +101,23 @@ krb5_decrypt(
 	u32 ret = -EINVAL;
 	struct scatterlist sg[1];
 	u8 local_iv[GSS_KRB5_MAX_BLOCKSIZE] = {0};
-	SKCIPHER_REQUEST_ON_STACK(req, tfm);
+	SYNC_SKCIPHER_REQUEST_ON_STACK(req, tfm);
 
-	if (length % crypto_skcipher_blocksize(tfm) != 0)
+	if (length % crypto_sync_skcipher_blocksize(tfm) != 0)
 		goto out;
 
-	if (crypto_skcipher_ivsize(tfm) > GSS_KRB5_MAX_BLOCKSIZE) {
+	if (crypto_sync_skcipher_ivsize(tfm) > GSS_KRB5_MAX_BLOCKSIZE) {
 		dprintk("RPC:       gss_k5decrypt: tfm iv size too large %d\n",
-			crypto_skcipher_ivsize(tfm));
+			crypto_sync_skcipher_ivsize(tfm));
 		goto out;
 	}
 	if (iv)
-		memcpy(local_iv,iv, crypto_skcipher_ivsize(tfm));
+		memcpy(local_iv, iv, crypto_sync_skcipher_ivsize(tfm));
 
 	memcpy(out, in, length);
 	sg_init_one(sg, out, length);
 
-	skcipher_request_set_tfm(req, tfm);
+	skcipher_request_set_sync_tfm(req, tfm);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
 	skcipher_request_set_crypt(req, sg, sg, length, local_iv);
 
@@ -466,7 +466,8 @@ encryptor(struct scatterlist *sg, void *data)
 {
 	struct encryptor_desc *desc = data;
 	struct xdr_buf *outbuf = desc->outbuf;
-	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(desc->req);
+	struct crypto_sync_skcipher *tfm =
+		crypto_sync_skcipher_reqtfm(desc->req);
 	struct page *in_page;
 	int thislen = desc->fraglen + sg->length;
 	int fraglen, ret;
@@ -492,7 +493,7 @@ encryptor(struct scatterlist *sg, void *data)
 	desc->fraglen += sg->length;
 	desc->pos += sg->length;
 
-	fraglen = thislen & (crypto_skcipher_blocksize(tfm) - 1);
+	fraglen = thislen & (crypto_sync_skcipher_blocksize(tfm) - 1);
 	thislen -= fraglen;
 
 	if (thislen == 0)
@@ -526,16 +527,16 @@ encryptor(struct scatterlist *sg, void *data)
 }
 
 int
-gss_encrypt_xdr_buf(struct crypto_skcipher *tfm, struct xdr_buf *buf,
+gss_encrypt_xdr_buf(struct crypto_sync_skcipher *tfm, struct xdr_buf *buf,
 		    int offset, struct page **pages)
 {
 	int ret;
 	struct encryptor_desc desc;
-	SKCIPHER_REQUEST_ON_STACK(req, tfm);
+	SYNC_SKCIPHER_REQUEST_ON_STACK(req, tfm);
 
-	BUG_ON((buf->len - offset) % crypto_skcipher_blocksize(tfm) != 0);
+	BUG_ON((buf->len - offset) % crypto_sync_skcipher_blocksize(tfm) != 0);
 
-	skcipher_request_set_tfm(req, tfm);
+	skcipher_request_set_sync_tfm(req, tfm);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
 
 	memset(desc.iv, 0, sizeof(desc.iv));
@@ -567,7 +568,8 @@ decryptor(struct scatterlist *sg, void *data)
 {
 	struct decryptor_desc *desc = data;
 	int thislen = desc->fraglen + sg->length;
-	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(desc->req);
+	struct crypto_sync_skcipher *tfm =
+		crypto_sync_skcipher_reqtfm(desc->req);
 	int fraglen, ret;
 
 	/* Worst case is 4 fragments: head, end of page 1, start
@@ -578,7 +580,7 @@ decryptor(struct scatterlist *sg, void *data)
 	desc->fragno++;
 	desc->fraglen += sg->length;
 
-	fraglen = thislen & (crypto_skcipher_blocksize(tfm) - 1);
+	fraglen = thislen & (crypto_sync_skcipher_blocksize(tfm) - 1);
 	thislen -= fraglen;
 
 	if (thislen == 0)
@@ -608,17 +610,17 @@ decryptor(struct scatterlist *sg, void *data)
 }
 
 int
-gss_decrypt_xdr_buf(struct crypto_skcipher *tfm, struct xdr_buf *buf,
+gss_decrypt_xdr_buf(struct crypto_sync_skcipher *tfm, struct xdr_buf *buf,
 		    int offset)
 {
 	int ret;
 	struct decryptor_desc desc;
-	SKCIPHER_REQUEST_ON_STACK(req, tfm);
+	SYNC_SKCIPHER_REQUEST_ON_STACK(req, tfm);
 
 	/* XXXJBF: */
-	BUG_ON((buf->len - offset) % crypto_skcipher_blocksize(tfm) != 0);
+	BUG_ON((buf->len - offset) % crypto_sync_skcipher_blocksize(tfm) != 0);
 
-	skcipher_request_set_tfm(req, tfm);
+	skcipher_request_set_sync_tfm(req, tfm);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
 
 	memset(desc.iv, 0, sizeof(desc.iv));
@@ -672,12 +674,12 @@ xdr_extend_head(struct xdr_buf *buf, unsigned int base, unsigned int shiftlen)
 }
 
 static u32
-gss_krb5_cts_crypt(struct crypto_skcipher *cipher, struct xdr_buf *buf,
+gss_krb5_cts_crypt(struct crypto_sync_skcipher *cipher, struct xdr_buf *buf,
 		   u32 offset, u8 *iv, struct page **pages, int encrypt)
 {
 	u32 ret;
 	struct scatterlist sg[1];
-	SKCIPHER_REQUEST_ON_STACK(req, cipher);
+	SYNC_SKCIPHER_REQUEST_ON_STACK(req, cipher);
 	u8 *data;
 	struct page **save_pages;
 	u32 len = buf->len - offset;
@@ -706,7 +708,7 @@ gss_krb5_cts_crypt(struct crypto_skcipher *cipher, struct xdr_buf *buf,
 
 	sg_init_one(sg, data, len);
 
-	skcipher_request_set_tfm(req, cipher);
+	skcipher_request_set_sync_tfm(req, cipher);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
 	skcipher_request_set_crypt(req, sg, sg, len, iv);
 
@@ -735,7 +737,7 @@ gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
 	struct xdr_netobj hmac;
 	u8 *cksumkey;
 	u8 *ecptr;
-	struct crypto_skcipher *cipher, *aux_cipher;
+	struct crypto_sync_skcipher *cipher, *aux_cipher;
 	int blocksize;
 	struct page **save_pages;
 	int nblocks, nbytes;
@@ -754,7 +756,7 @@ gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
 		cksumkey = kctx->acceptor_integ;
 		usage = KG_USAGE_ACCEPTOR_SEAL;
 	}
-	blocksize = crypto_skcipher_blocksize(cipher);
+	blocksize = crypto_sync_skcipher_blocksize(cipher);
 
 	/* hide the gss token header and insert the confounder */
 	offset += GSS_KRB5_TOK_HDR_LEN;
@@ -807,7 +809,7 @@ gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
 	memset(desc.iv, 0, sizeof(desc.iv));
 
 	if (cbcbytes) {
-		SKCIPHER_REQUEST_ON_STACK(req, aux_cipher);
+		SYNC_SKCIPHER_REQUEST_ON_STACK(req, aux_cipher);
 
 		desc.pos = offset + GSS_KRB5_TOK_HDR_LEN;
 		desc.fragno = 0;
@@ -816,7 +818,7 @@ gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
 		desc.outbuf = buf;
 		desc.req = req;
 
-		skcipher_request_set_tfm(req, aux_cipher);
+		skcipher_request_set_sync_tfm(req, aux_cipher);
 		skcipher_request_set_callback(req, 0, NULL, NULL);
 
 		sg_init_table(desc.infrags, 4);
@@ -855,7 +857,7 @@ gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf,
 	struct xdr_buf subbuf;
 	u32 ret = 0;
 	u8 *cksum_key;
-	struct crypto_skcipher *cipher, *aux_cipher;
+	struct crypto_sync_skcipher *cipher, *aux_cipher;
 	struct xdr_netobj our_hmac_obj;
 	u8 our_hmac[GSS_KRB5_MAX_CKSUM_LEN];
 	u8 pkt_hmac[GSS_KRB5_MAX_CKSUM_LEN];
@@ -874,7 +876,7 @@ gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf,
 		cksum_key = kctx->initiator_integ;
 		usage = KG_USAGE_INITIATOR_SEAL;
 	}
-	blocksize = crypto_skcipher_blocksize(cipher);
+	blocksize = crypto_sync_skcipher_blocksize(cipher);
 
 
 	/* create a segment skipping the header and leaving out the checksum */
@@ -891,13 +893,13 @@ gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf,
 	memset(desc.iv, 0, sizeof(desc.iv));
 
 	if (cbcbytes) {
-		SKCIPHER_REQUEST_ON_STACK(req, aux_cipher);
+		SYNC_SKCIPHER_REQUEST_ON_STACK(req, aux_cipher);
 
 		desc.fragno = 0;
 		desc.fraglen = 0;
 		desc.req = req;
 
-		skcipher_request_set_tfm(req, aux_cipher);
+		skcipher_request_set_sync_tfm(req, aux_cipher);
 		skcipher_request_set_callback(req, 0, NULL, NULL);
 
 		sg_init_table(desc.frags, 4);
@@ -946,7 +948,8 @@ gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf,
  * Set the key of the given cipher.
  */
 int
-krb5_rc4_setup_seq_key(struct krb5_ctx *kctx, struct crypto_skcipher *cipher,
+krb5_rc4_setup_seq_key(struct krb5_ctx *kctx,
+		       struct crypto_sync_skcipher *cipher,
 		       unsigned char *cksum)
 {
 	struct crypto_shash *hmac;
@@ -994,7 +997,7 @@ krb5_rc4_setup_seq_key(struct krb5_ctx *kctx, struct crypto_skcipher *cipher,
 	if (err)
 		goto out_err;
 
-	err = crypto_skcipher_setkey(cipher, Kseq, kctx->gk5e->keylength);
+	err = crypto_sync_skcipher_setkey(cipher, Kseq, kctx->gk5e->keylength);
 	if (err)
 		goto out_err;
 
@@ -1012,7 +1015,8 @@ krb5_rc4_setup_seq_key(struct krb5_ctx *kctx, struct crypto_skcipher *cipher,
  * Set the key of cipher kctx->enc.
  */
 int
-krb5_rc4_setup_enc_key(struct krb5_ctx *kctx, struct crypto_skcipher *cipher,
+krb5_rc4_setup_enc_key(struct krb5_ctx *kctx,
+		       struct crypto_sync_skcipher *cipher,
 		       s32 seqnum)
 {
 	struct crypto_shash *hmac;
@@ -1069,7 +1073,8 @@ krb5_rc4_setup_enc_key(struct krb5_ctx *kctx, struct crypto_skcipher *cipher,
 	if (err)
 		goto out_err;
 
-	err = crypto_skcipher_setkey(cipher, Kcrypt, kctx->gk5e->keylength);
+	err = crypto_sync_skcipher_setkey(cipher, Kcrypt,
+					  kctx->gk5e->keylength);
 	if (err)
 		goto out_err;
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_keys.c b/net/sunrpc/auth_gss/gss_krb5_keys.c
index f7fe2d2b851f..550fdf18d3b3 100644
--- a/net/sunrpc/auth_gss/gss_krb5_keys.c
+++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
@@ -147,7 +147,7 @@ u32 krb5_derive_key(const struct gss_krb5_enctype *gk5e,
 	size_t blocksize, keybytes, keylength, n;
 	unsigned char *inblockdata, *outblockdata, *rawkey;
 	struct xdr_netobj inblock, outblock;
-	struct crypto_skcipher *cipher;
+	struct crypto_sync_skcipher *cipher;
 	u32 ret = EINVAL;
 
 	blocksize = gk5e->blocksize;
@@ -157,11 +157,10 @@ u32 krb5_derive_key(const struct gss_krb5_enctype *gk5e,
 	if ((inkey->len != keylength) || (outkey->len != keylength))
 		goto err_return;
 
-	cipher = crypto_alloc_skcipher(gk5e->encrypt_name, 0,
-				       CRYPTO_ALG_ASYNC);
+	cipher = crypto_alloc_sync_skcipher(gk5e->encrypt_name, 0, 0);
 	if (IS_ERR(cipher))
 		goto err_return;
-	if (crypto_skcipher_setkey(cipher, inkey->data, inkey->len))
+	if (crypto_sync_skcipher_setkey(cipher, inkey->data, inkey->len))
 		goto err_return;
 
 	/* allocate and set up buffers */
@@ -238,7 +237,7 @@ u32 krb5_derive_key(const struct gss_krb5_enctype *gk5e,
 	memset(inblockdata, 0, blocksize);
 	kfree(inblockdata);
 err_free_cipher:
-	crypto_free_skcipher(cipher);
+	crypto_free_sync_skcipher(cipher);
 err_return:
 	return ret;
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 7bb2514aadd9..7f0424dfa8f6 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -218,7 +218,7 @@ simple_get_netobj(const void *p, const void *end, struct xdr_netobj *res)
 
 static inline const void *
 get_key(const void *p, const void *end,
-	struct krb5_ctx *ctx, struct crypto_skcipher **res)
+	struct krb5_ctx *ctx, struct crypto_sync_skcipher **res)
 {
 	struct xdr_netobj	key;
 	int			alg;
@@ -246,15 +246,14 @@ get_key(const void *p, const void *end,
 	if (IS_ERR(p))
 		goto out_err;
 
-	*res = crypto_alloc_skcipher(ctx->gk5e->encrypt_name, 0,
-							CRYPTO_ALG_ASYNC);
+	*res = crypto_alloc_sync_skcipher(ctx->gk5e->encrypt_name, 0, 0);
 	if (IS_ERR(*res)) {
 		printk(KERN_WARNING "gss_kerberos_mech: unable to initialize "
 			"crypto algorithm %s\n", ctx->gk5e->encrypt_name);
 		*res = NULL;
 		goto out_err_free_key;
 	}
-	if (crypto_skcipher_setkey(*res, key.data, key.len)) {
+	if (crypto_sync_skcipher_setkey(*res, key.data, key.len)) {
 		printk(KERN_WARNING "gss_kerberos_mech: error setting key for "
 			"crypto algorithm %s\n", ctx->gk5e->encrypt_name);
 		goto out_err_free_tfm;
@@ -264,7 +263,7 @@ get_key(const void *p, const void *end,
 	return p;
 
 out_err_free_tfm:
-	crypto_free_skcipher(*res);
+	crypto_free_sync_skcipher(*res);
 out_err_free_key:
 	kfree(key.data);
 	p = ERR_PTR(-EINVAL);
@@ -336,30 +335,30 @@ gss_import_v1_context(const void *p, const void *end, struct krb5_ctx *ctx)
 	return 0;
 
 out_err_free_key2:
-	crypto_free_skcipher(ctx->seq);
+	crypto_free_sync_skcipher(ctx->seq);
 out_err_free_key1:
-	crypto_free_skcipher(ctx->enc);
+	crypto_free_sync_skcipher(ctx->enc);
 out_err_free_mech:
 	kfree(ctx->mech_used.data);
 out_err:
 	return PTR_ERR(p);
 }
 
-static struct crypto_skcipher *
+static struct crypto_sync_skcipher *
 context_v2_alloc_cipher(struct krb5_ctx *ctx, const char *cname, u8 *key)
 {
-	struct crypto_skcipher *cp;
+	struct crypto_sync_skcipher *cp;
 
-	cp = crypto_alloc_skcipher(cname, 0, CRYPTO_ALG_ASYNC);
+	cp = crypto_alloc_sync_skcipher(cname, 0, 0);
 	if (IS_ERR(cp)) {
 		dprintk("gss_kerberos_mech: unable to initialize "
 			"crypto algorithm %s\n", cname);
 		return NULL;
 	}
-	if (crypto_skcipher_setkey(cp, key, ctx->gk5e->keylength)) {
+	if (crypto_sync_skcipher_setkey(cp, key, ctx->gk5e->keylength)) {
 		dprintk("gss_kerberos_mech: error setting key for "
 			"crypto algorithm %s\n", cname);
-		crypto_free_skcipher(cp);
+		crypto_free_sync_skcipher(cp);
 		return NULL;
 	}
 	return cp;
@@ -413,9 +412,9 @@ context_derive_keys_des3(struct krb5_ctx *ctx, gfp_t gfp_mask)
 	return 0;
 
 out_free_enc:
-	crypto_free_skcipher(ctx->enc);
+	crypto_free_sync_skcipher(ctx->enc);
 out_free_seq:
-	crypto_free_skcipher(ctx->seq);
+	crypto_free_sync_skcipher(ctx->seq);
 out_err:
 	return -EINVAL;
 }
@@ -469,17 +468,15 @@ context_derive_keys_rc4(struct krb5_ctx *ctx)
 	/*
 	 * allocate hash, and skciphers for data and seqnum encryption
 	 */
-	ctx->enc = crypto_alloc_skcipher(ctx->gk5e->encrypt_name, 0,
-					 CRYPTO_ALG_ASYNC);
+	ctx->enc = crypto_alloc_sync_skcipher(ctx->gk5e->encrypt_name, 0, 0);
 	if (IS_ERR(ctx->enc)) {
 		err = PTR_ERR(ctx->enc);
 		goto out_err_free_hmac;
 	}
 
-	ctx->seq = crypto_alloc_skcipher(ctx->gk5e->encrypt_name, 0,
-					 CRYPTO_ALG_ASYNC);
+	ctx->seq = crypto_alloc_sync_skcipher(ctx->gk5e->encrypt_name, 0, 0);
 	if (IS_ERR(ctx->seq)) {
-		crypto_free_skcipher(ctx->enc);
+		crypto_free_sync_skcipher(ctx->enc);
 		err = PTR_ERR(ctx->seq);
 		goto out_err_free_hmac;
 	}
@@ -591,7 +588,7 @@ context_derive_keys_new(struct krb5_ctx *ctx, gfp_t gfp_mask)
 			context_v2_alloc_cipher(ctx, "cbc(aes)",
 						ctx->acceptor_seal);
 		if (ctx->acceptor_enc_aux == NULL) {
-			crypto_free_skcipher(ctx->initiator_enc_aux);
+			crypto_free_sync_skcipher(ctx->initiator_enc_aux);
 			goto out_free_acceptor_enc;
 		}
 	}
@@ -599,9 +596,9 @@ context_derive_keys_new(struct krb5_ctx *ctx, gfp_t gfp_mask)
 	return 0;
 
 out_free_acceptor_enc:
-	crypto_free_skcipher(ctx->acceptor_enc);
+	crypto_free_sync_skcipher(ctx->acceptor_enc);
 out_free_initiator_enc:
-	crypto_free_skcipher(ctx->initiator_enc);
+	crypto_free_sync_skcipher(ctx->initiator_enc);
 out_err:
 	return -EINVAL;
 }
@@ -713,12 +710,12 @@ static void
 gss_delete_sec_context_kerberos(void *internal_ctx) {
 	struct krb5_ctx *kctx = internal_ctx;
 
-	crypto_free_skcipher(kctx->seq);
-	crypto_free_skcipher(kctx->enc);
-	crypto_free_skcipher(kctx->acceptor_enc);
-	crypto_free_skcipher(kctx->initiator_enc);
-	crypto_free_skcipher(kctx->acceptor_enc_aux);
-	crypto_free_skcipher(kctx->initiator_enc_aux);
+	crypto_free_sync_skcipher(kctx->seq);
+	crypto_free_sync_skcipher(kctx->enc);
+	crypto_free_sync_skcipher(kctx->acceptor_enc);
+	crypto_free_sync_skcipher(kctx->initiator_enc);
+	crypto_free_sync_skcipher(kctx->acceptor_enc_aux);
+	crypto_free_sync_skcipher(kctx->initiator_enc_aux);
 	kfree(kctx->mech_used.data);
 	kfree(kctx);
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_seqnum.c b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
index c8b9082f4a9d..fb6656295204 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seqnum.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
@@ -43,13 +43,12 @@ static s32
 krb5_make_rc4_seq_num(struct krb5_ctx *kctx, int direction, s32 seqnum,
 		      unsigned char *cksum, unsigned char *buf)
 {
-	struct crypto_skcipher *cipher;
+	struct crypto_sync_skcipher *cipher;
 	unsigned char plain[8];
 	s32 code;
 
 	dprintk("RPC:       %s:\n", __func__);
-	cipher = crypto_alloc_skcipher(kctx->gk5e->encrypt_name, 0,
-				       CRYPTO_ALG_ASYNC);
+	cipher = crypto_alloc_sync_skcipher(kctx->gk5e->encrypt_name, 0, 0);
 	if (IS_ERR(cipher))
 		return PTR_ERR(cipher);
 
@@ -68,12 +67,12 @@ krb5_make_rc4_seq_num(struct krb5_ctx *kctx, int direction, s32 seqnum,
 
 	code = krb5_encrypt(cipher, cksum, plain, buf, 8);
 out:
-	crypto_free_skcipher(cipher);
+	crypto_free_sync_skcipher(cipher);
 	return code;
 }
 s32
 krb5_make_seq_num(struct krb5_ctx *kctx,
-		struct crypto_skcipher *key,
+		struct crypto_sync_skcipher *key,
 		int direction,
 		u32 seqnum,
 		unsigned char *cksum, unsigned char *buf)
@@ -101,13 +100,12 @@ static s32
 krb5_get_rc4_seq_num(struct krb5_ctx *kctx, unsigned char *cksum,
 		     unsigned char *buf, int *direction, s32 *seqnum)
 {
-	struct crypto_skcipher *cipher;
+	struct crypto_sync_skcipher *cipher;
 	unsigned char plain[8];
 	s32 code;
 
 	dprintk("RPC:       %s:\n", __func__);
-	cipher = crypto_alloc_skcipher(kctx->gk5e->encrypt_name, 0,
-				       CRYPTO_ALG_ASYNC);
+	cipher = crypto_alloc_sync_skcipher(kctx->gk5e->encrypt_name, 0, 0);
 	if (IS_ERR(cipher))
 		return PTR_ERR(cipher);
 
@@ -130,7 +128,7 @@ krb5_get_rc4_seq_num(struct krb5_ctx *kctx, unsigned char *cksum,
 	*seqnum = ((plain[0] << 24) | (plain[1] << 16) |
 					(plain[2] << 8) | (plain[3]));
 out:
-	crypto_free_skcipher(cipher);
+	crypto_free_sync_skcipher(cipher);
 	return code;
 }
 
@@ -142,7 +140,7 @@ krb5_get_seq_num(struct krb5_ctx *kctx,
 {
 	s32 code;
 	unsigned char plain[8];
-	struct crypto_skcipher *key = kctx->seq;
+	struct crypto_sync_skcipher *key = kctx->seq;
 
 	dprintk("RPC:       krb5_get_seq_num:\n");
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 39a2e672900b..3d975a4013d2 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -174,7 +174,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 
 	now = get_seconds();
 
-	blocksize = crypto_skcipher_blocksize(kctx->enc);
+	blocksize = crypto_sync_skcipher_blocksize(kctx->enc);
 	gss_krb5_add_padding(buf, offset, blocksize);
 	BUG_ON((buf->len - offset) % blocksize);
 	plainlen = conflen + buf->len - offset;
@@ -239,10 +239,10 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 		return GSS_S_FAILURE;
 
 	if (kctx->enctype == ENCTYPE_ARCFOUR_HMAC) {
-		struct crypto_skcipher *cipher;
+		struct crypto_sync_skcipher *cipher;
 		int err;
-		cipher = crypto_alloc_skcipher(kctx->gk5e->encrypt_name, 0,
-					       CRYPTO_ALG_ASYNC);
+		cipher = crypto_alloc_sync_skcipher(kctx->gk5e->encrypt_name,
+						    0, 0);
 		if (IS_ERR(cipher))
 			return GSS_S_FAILURE;
 
@@ -250,7 +250,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 
 		err = gss_encrypt_xdr_buf(cipher, buf,
 					  offset + headlen - conflen, pages);
-		crypto_free_skcipher(cipher);
+		crypto_free_sync_skcipher(cipher);
 		if (err)
 			return GSS_S_FAILURE;
 	} else {
@@ -327,18 +327,18 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 		return GSS_S_BAD_SIG;
 
 	if (kctx->enctype == ENCTYPE_ARCFOUR_HMAC) {
-		struct crypto_skcipher *cipher;
+		struct crypto_sync_skcipher *cipher;
 		int err;
 
-		cipher = crypto_alloc_skcipher(kctx->gk5e->encrypt_name, 0,
-					       CRYPTO_ALG_ASYNC);
+		cipher = crypto_alloc_sync_skcipher(kctx->gk5e->encrypt_name,
+						    0, 0);
 		if (IS_ERR(cipher))
 			return GSS_S_FAILURE;
 
 		krb5_rc4_setup_enc_key(kctx, cipher, seqnum);
 
 		err = gss_decrypt_xdr_buf(cipher, buf, crypt_offset);
-		crypto_free_skcipher(cipher);
+		crypto_free_sync_skcipher(cipher);
 		if (err)
 			return GSS_S_DEFECTIVE_TOKEN;
 	} else {
@@ -371,7 +371,7 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	/* Copy the data back to the right position.  XXX: Would probably be
 	 * better to copy and encrypt at the same time. */
 
-	blocksize = crypto_skcipher_blocksize(kctx->enc);
+	blocksize = crypto_sync_skcipher_blocksize(kctx->enc);
 	data_start = ptr + (GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength) +
 					conflen;
 	orig_start = buf->head[0].iov_base + offset;
-- 
2.17.1
