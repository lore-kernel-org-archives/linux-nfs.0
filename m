From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 15/22] gss_krb5: add remaining pieces to enable AES encryption support
Date: Wed, 14 Apr 2010 13:36:51 -0400
Message-ID: <1271266618-26016-16-git-send-email-Trond.Myklebust@netapp.com>
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
 <1271266618-26016-12-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-13-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-14-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-15-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28110 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756544Ab0DNRhV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Apr 2010 13:37:21 -0400
Received: from localhost.localdomain (pd07336a.hq.netapp.com [10.58.61.110] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3EHawKB021574
	for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2010 10:37:07 -0700 (PDT)
In-Reply-To: <1271266618-26016-15-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

Add the remaining pieces to enable support for Kerberos AES
encryption types.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/gss_krb5.h       |   20 +++
 net/sunrpc/auth_gss/gss_krb5_crypto.c |  248 +++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/gss_krb5_keys.c   |   30 ++++
 net/sunrpc/auth_gss/gss_krb5_mech.c   |   86 ++++++++++--
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |    6 +-
 5 files changed, 378 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 0085a30..43148ec 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -99,6 +99,8 @@ struct krb5_ctx {
 	struct crypto_blkcipher	*seq;
 	struct crypto_blkcipher *acceptor_enc;
 	struct crypto_blkcipher *initiator_enc;
+	struct crypto_blkcipher *acceptor_enc_aux;
+	struct crypto_blkcipher *initiator_enc_aux;
 	u8			cksum[GSS_KRB5_MAX_KEYLEN];
 	s32			endtime;
 	u32			seq_send;
@@ -294,3 +296,21 @@ u32
 gss_krb5_des3_make_key(const struct gss_krb5_enctype *gk5e,
 		       struct xdr_netobj *randombits,
 		       struct xdr_netobj *key);
+
+u32
+gss_krb5_aes_make_key(const struct gss_krb5_enctype *gk5e,
+		      struct xdr_netobj *randombits,
+		      struct xdr_netobj *key);
+
+u32
+gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
+		     struct xdr_buf *buf, int ec,
+		     struct page **pages);
+
+u32
+gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset,
+		     struct xdr_buf *buf, u32 *plainoffset,
+		     u32 *plainlen);
+
+void
+gss_krb5_make_confounder(char *p, u32 conflen);
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index ca52ac2..967484a 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -41,6 +41,7 @@
 #include <linux/crypto.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
+#include <linux/random.h>
 #include <linux/sunrpc/gss_krb5.h>
 #include <linux/sunrpc/xdr.h>
 
@@ -478,3 +479,250 @@ xdr_extend_head(struct xdr_buf *buf, unsigned int base, unsigned int shiftlen)
 
 	return 0;
 }
+
+static u32
+gss_krb5_cts_crypt(struct crypto_blkcipher *cipher, struct xdr_buf *buf,
+		   u32 offset, u8 *iv, struct page **pages, int encrypt)
+{
+	u32 ret;
+	struct scatterlist sg[1];
+	struct blkcipher_desc desc = { .tfm = cipher, .info = iv };
+	u8 data[crypto_blkcipher_blocksize(cipher) * 2];
+	struct page **save_pages;
+	u32 len = buf->len - offset;
+
+	BUG_ON(len > crypto_blkcipher_blocksize(cipher) * 2);
+
+	/*
+	 * For encryption, we want to read from the cleartext
+	 * page cache pages, and write the encrypted data to
+	 * the supplied xdr_buf pages.
+	 */
+	save_pages = buf->pages;
+	if (encrypt)
+		buf->pages = pages;
+
+	ret = read_bytes_from_xdr_buf(buf, offset, data, len);
+	buf->pages = save_pages;
+	if (ret)
+		goto out;
+
+	sg_init_one(sg, data, len);
+
+	if (encrypt)
+		ret = crypto_blkcipher_encrypt_iv(&desc, sg, sg, len);
+	else
+		ret = crypto_blkcipher_decrypt_iv(&desc, sg, sg, len);
+
+	if (ret)
+		goto out;
+
+	ret = write_bytes_to_xdr_buf(buf, offset, data, len);
+
+out:
+	return ret;
+}
+
+u32
+gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
+		     struct xdr_buf *buf, int ec, struct page **pages)
+{
+	u32 err;
+	struct xdr_netobj hmac;
+	u8 *cksumkey;
+	u8 *ecptr;
+	struct crypto_blkcipher *cipher, *aux_cipher;
+	int blocksize;
+	struct page **save_pages;
+	int nblocks, nbytes;
+	struct encryptor_desc desc;
+	u32 cbcbytes;
+
+	if (kctx->initiate) {
+		cipher = kctx->initiator_enc;
+		aux_cipher = kctx->initiator_enc_aux;
+		cksumkey = kctx->initiator_integ;
+	} else {
+		cipher = kctx->acceptor_enc;
+		aux_cipher = kctx->acceptor_enc_aux;
+		cksumkey = kctx->acceptor_integ;
+	}
+	blocksize = crypto_blkcipher_blocksize(cipher);
+
+	/* hide the gss token header and insert the confounder */
+	offset += GSS_KRB5_TOK_HDR_LEN;
+	if (xdr_extend_head(buf, offset, blocksize))
+		return GSS_S_FAILURE;
+	gss_krb5_make_confounder(buf->head[0].iov_base + offset, blocksize);
+	offset -= GSS_KRB5_TOK_HDR_LEN;
+
+	if (buf->tail[0].iov_base != NULL) {
+		ecptr = buf->tail[0].iov_base + buf->tail[0].iov_len;
+	} else {
+		buf->tail[0].iov_base = buf->head[0].iov_base
+							+ buf->head[0].iov_len;
+		buf->tail[0].iov_len = 0;
+		ecptr = buf->tail[0].iov_base;
+	}
+
+	memset(ecptr, 'X', ec);
+	buf->tail[0].iov_len += ec;
+	buf->len += ec;
+
+	/* copy plaintext gss token header after filler (if any) */
+	memcpy(ecptr + ec, buf->head[0].iov_base + offset,
+						GSS_KRB5_TOK_HDR_LEN);
+	buf->tail[0].iov_len += GSS_KRB5_TOK_HDR_LEN;
+	buf->len += GSS_KRB5_TOK_HDR_LEN;
+
+	/* Do the HMAC */
+	hmac.len = GSS_KRB5_MAX_CKSUM_LEN;
+	hmac.data = buf->tail[0].iov_base + buf->tail[0].iov_len;
+
+	/*
+	 * When we are called, pages points to the real page cache
+	 * data -- which we can't go and encrypt!  buf->pages points
+	 * to scratch pages which we are going to send off to the
+	 * client/server.  Swap in the plaintext pages to calculate
+	 * the hmac.
+	 */
+	save_pages = buf->pages;
+	buf->pages = pages;
+
+	err = make_checksum_v2(kctx, NULL, 0, buf,
+			       offset + GSS_KRB5_TOK_HDR_LEN, cksumkey, &hmac);
+	buf->pages = save_pages;
+	if (err)
+		return GSS_S_FAILURE;
+
+	nbytes = buf->len - offset - GSS_KRB5_TOK_HDR_LEN;
+	nblocks = (nbytes + blocksize - 1) / blocksize;
+	cbcbytes = 0;
+	if (nblocks > 2)
+		cbcbytes = (nblocks - 2) * blocksize;
+
+	memset(desc.iv, 0, sizeof(desc.iv));
+
+	if (cbcbytes) {
+		desc.pos = offset + GSS_KRB5_TOK_HDR_LEN;
+		desc.fragno = 0;
+		desc.fraglen = 0;
+		desc.pages = pages;
+		desc.outbuf = buf;
+		desc.desc.info = desc.iv;
+		desc.desc.flags = 0;
+		desc.desc.tfm = aux_cipher;
+
+		sg_init_table(desc.infrags, 4);
+		sg_init_table(desc.outfrags, 4);
+
+		err = xdr_process_buf(buf, offset + GSS_KRB5_TOK_HDR_LEN,
+				      cbcbytes, encryptor, &desc);
+		if (err)
+			goto out_err;
+	}
+
+	/* Make sure IV carries forward from any CBC results. */
+	err = gss_krb5_cts_crypt(cipher, buf,
+				 offset + GSS_KRB5_TOK_HDR_LEN + cbcbytes,
+				 desc.iv, pages, 1);
+	if (err) {
+		err = GSS_S_FAILURE;
+		goto out_err;
+	}
+
+	/* Now update buf to account for HMAC */
+	buf->tail[0].iov_len += kctx->gk5e->cksumlength;
+	buf->len += kctx->gk5e->cksumlength;
+
+out_err:
+	if (err)
+		err = GSS_S_FAILURE;
+	return err;
+}
+
+u32
+gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf,
+		     u32 *headskip, u32 *tailskip)
+{
+	struct xdr_buf subbuf;
+	u32 ret = 0;
+	u8 *cksum_key;
+	struct crypto_blkcipher *cipher, *aux_cipher;
+	struct xdr_netobj our_hmac_obj;
+	u8 our_hmac[GSS_KRB5_MAX_CKSUM_LEN];
+	u8 pkt_hmac[GSS_KRB5_MAX_CKSUM_LEN];
+	int nblocks, blocksize, cbcbytes;
+	struct decryptor_desc desc;
+
+	if (kctx->initiate) {
+		cipher = kctx->acceptor_enc;
+		aux_cipher = kctx->acceptor_enc_aux;
+		cksum_key = kctx->acceptor_integ;
+	} else {
+		cipher = kctx->initiator_enc;
+		aux_cipher = kctx->initiator_enc_aux;
+		cksum_key = kctx->initiator_integ;
+	}
+	blocksize = crypto_blkcipher_blocksize(cipher);
+
+
+	/* create a segment skipping the header and leaving out the checksum */
+	xdr_buf_subsegment(buf, &subbuf, offset + GSS_KRB5_TOK_HDR_LEN,
+				    (buf->len - offset - GSS_KRB5_TOK_HDR_LEN -
+				     kctx->gk5e->cksumlength));
+
+	nblocks = (subbuf.len + blocksize - 1) / blocksize;
+
+	cbcbytes = 0;
+	if (nblocks > 2)
+		cbcbytes = (nblocks - 2) * blocksize;
+
+	memset(desc.iv, 0, sizeof(desc.iv));
+
+	if (cbcbytes) {
+		desc.fragno = 0;
+		desc.fraglen = 0;
+		desc.desc.info = desc.iv;
+		desc.desc.flags = 0;
+		desc.desc.tfm = aux_cipher;
+
+		sg_init_table(desc.frags, 4);
+
+		ret = xdr_process_buf(&subbuf, 0, cbcbytes, decryptor, &desc);
+		if (ret)
+			goto out_err;
+	}
+
+	/* Make sure IV carries forward from any CBC results. */
+	ret = gss_krb5_cts_crypt(cipher, &subbuf, cbcbytes, desc.iv, NULL, 0);
+	if (ret)
+		goto out_err;
+
+
+	/* Calculate our hmac over the plaintext data */
+	our_hmac_obj.len = sizeof(our_hmac);
+	our_hmac_obj.data = our_hmac;
+
+	ret = make_checksum_v2(kctx, NULL, 0, &subbuf, 0,
+			       cksum_key, &our_hmac_obj);
+	if (ret)
+		goto out_err;
+
+	/* Get the packet's hmac value */
+	ret = read_bytes_from_xdr_buf(buf, buf->len - kctx->gk5e->cksumlength,
+				      pkt_hmac, kctx->gk5e->cksumlength);
+	if (ret)
+		goto out_err;
+
+	if (memcmp(pkt_hmac, our_hmac, kctx->gk5e->cksumlength) != 0) {
+		ret = GSS_S_BAD_SIG;
+		goto out_err;
+	}
+	*headskip = crypto_blkcipher_blocksize(cipher);
+	*tailskip = kctx->gk5e->cksumlength;
+out_err:
+	if (ret && ret != GSS_S_BAD_SIG)
+		ret = GSS_S_FAILURE;
+	return ret;
+}
diff --git a/net/sunrpc/auth_gss/gss_krb5_keys.c b/net/sunrpc/auth_gss/gss_krb5_keys.c
index d546687..33b87f0 100644
--- a/net/sunrpc/auth_gss/gss_krb5_keys.c
+++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
@@ -303,3 +303,33 @@ u32 gss_krb5_des3_make_key(const struct gss_krb5_enctype *gk5e,
 err_out:
 	return ret;
 }
+
+/*
+ * This is the aes key derivation postprocess function
+ */
+u32 gss_krb5_aes_make_key(const struct gss_krb5_enctype *gk5e,
+			  struct xdr_netobj *randombits,
+			  struct xdr_netobj *key)
+{
+	u32 ret = EINVAL;
+
+	if (key->len != 16 && key->len != 32) {
+		dprintk("%s: key->len is %d\n", __func__, key->len);
+		goto err_out;
+	}
+	if (randombits->len != 16 && randombits->len != 32) {
+		dprintk("%s: randombits->len is %d\n",
+			__func__, randombits->len);
+		goto err_out;
+	}
+	if (randombits->len != key->len) {
+		dprintk("%s: randombits->len is %d, key->len is %d\n",
+			__func__, randombits->len, key->len);
+		goto err_out;
+	}
+	memcpy(key->data, randombits->data, key->len);
+	ret = 0;
+err_out:
+	return ret;
+}
+
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 7b6db82..fd2c976 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -91,6 +91,50 @@ static const struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
 	  .cksumlength = 20,
 	  .keyed_cksum = 1,
 	},
+	/*
+	 * AES128
+	 */
+	{
+	  .etype = ENCTYPE_AES128_CTS_HMAC_SHA1_96,
+	  .ctype = CKSUMTYPE_HMAC_SHA1_96_AES128,
+	  .name = "aes128-cts",
+	  .encrypt_name = "cts(cbc(aes))",
+	  .cksum_name = "hmac(sha1)",
+	  .encrypt = krb5_encrypt,
+	  .decrypt = krb5_decrypt,
+	  .mk_key = gss_krb5_aes_make_key,
+	  .encrypt_v2 = gss_krb5_aes_encrypt,
+	  .decrypt_v2 = gss_krb5_aes_decrypt,
+	  .signalg = -1,
+	  .sealalg = -1,
+	  .keybytes = 16,
+	  .keylength = 16,
+	  .blocksize = 16,
+	  .cksumlength = 12,
+	  .keyed_cksum = 1,
+	},
+	/*
+	 * AES256
+	 */
+	{
+	  .etype = ENCTYPE_AES256_CTS_HMAC_SHA1_96,
+	  .ctype = CKSUMTYPE_HMAC_SHA1_96_AES256,
+	  .name = "aes256-cts",
+	  .encrypt_name = "cts(cbc(aes))",
+	  .cksum_name = "hmac(sha1)",
+	  .encrypt = krb5_encrypt,
+	  .decrypt = krb5_decrypt,
+	  .mk_key = gss_krb5_aes_make_key,
+	  .encrypt_v2 = gss_krb5_aes_encrypt,
+	  .decrypt_v2 = gss_krb5_aes_decrypt,
+	  .signalg = -1,
+	  .sealalg = -1,
+	  .keybytes = 32,
+	  .keylength = 32,
+	  .blocksize = 16,
+	  .cksumlength = 12,
+	  .keyed_cksum = 1,
+	},
 };
 
 static const int num_supported_enctypes =
@@ -270,20 +314,19 @@ out_err:
 }
 
 struct crypto_blkcipher *
-context_v2_alloc_cipher(struct krb5_ctx *ctx, u8 *key)
+context_v2_alloc_cipher(struct krb5_ctx *ctx, const char *cname, u8 *key)
 {
 	struct crypto_blkcipher *cp;
 
-	cp = crypto_alloc_blkcipher(ctx->gk5e->encrypt_name,
-					0, CRYPTO_ALG_ASYNC);
+	cp = crypto_alloc_blkcipher(cname, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(cp)) {
 		dprintk("gss_kerberos_mech: unable to initialize "
-			"crypto algorithm %s\n", ctx->gk5e->encrypt_name);
+			"crypto algorithm %s\n", cname);
 		return NULL;
 	}
 	if (crypto_blkcipher_setkey(cp, key, ctx->gk5e->keylength)) {
 		dprintk("gss_kerberos_mech: error setting key for "
-			"crypto algorithm %s\n", ctx->gk5e->encrypt_name);
+			"crypto algorithm %s\n", cname);
 		crypto_free_blkcipher(cp);
 		return NULL;
 	}
@@ -315,11 +358,13 @@ context_derive_keys_des3(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
 	keyout.len = keylen;
 
 	/* seq uses the raw key */
-	ctx->seq = context_v2_alloc_cipher(ctx, rawkey);
+	ctx->seq = context_v2_alloc_cipher(ctx, ctx->gk5e->encrypt_name,
+					   rawkey);
 	if (ctx->seq == NULL)
 		goto out_err;
 
-	ctx->enc = context_v2_alloc_cipher(ctx, rawkey);
+	ctx->enc = context_v2_alloc_cipher(ctx, ctx->gk5e->encrypt_name,
+					   rawkey);
 	if (ctx->enc == NULL)
 		goto out_free_seq;
 
@@ -366,7 +411,9 @@ context_derive_keys_new(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
 			__func__, err);
 		goto out_err;
 	}
-	ctx->initiator_enc = context_v2_alloc_cipher(ctx, ctx->initiator_seal);
+	ctx->initiator_enc = context_v2_alloc_cipher(ctx,
+						     ctx->gk5e->encrypt_name,
+						     ctx->initiator_seal);
 	if (ctx->initiator_enc == NULL)
 		goto out_err;
 
@@ -379,7 +426,9 @@ context_derive_keys_new(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
 			__func__, err);
 		goto out_free_initiator_enc;
 	}
-	ctx->acceptor_enc = context_v2_alloc_cipher(ctx, ctx->acceptor_seal);
+	ctx->acceptor_enc = context_v2_alloc_cipher(ctx,
+						    ctx->gk5e->encrypt_name,
+						    ctx->acceptor_seal);
 	if (ctx->acceptor_enc == NULL)
 		goto out_free_initiator_enc;
 
@@ -423,6 +472,23 @@ context_derive_keys_new(struct krb5_ctx *ctx, u8 *rawkey, u32 keylen)
 		goto out_free_acceptor_enc;
 	}
 
+	switch (ctx->enctype) {
+	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
+	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
+		ctx->initiator_enc_aux =
+			context_v2_alloc_cipher(ctx, "cbc(aes)",
+						ctx->initiator_seal);
+		if (ctx->initiator_enc_aux == NULL)
+			goto out_free_acceptor_enc;
+		ctx->acceptor_enc_aux =
+			context_v2_alloc_cipher(ctx, "cbc(aes)",
+						ctx->acceptor_seal);
+		if (ctx->acceptor_enc_aux == NULL) {
+			crypto_free_blkcipher(ctx->initiator_enc_aux);
+			goto out_free_acceptor_enc;
+		}
+	}
+
 	return 0;
 
 out_free_acceptor_enc:
@@ -537,6 +603,8 @@ gss_delete_sec_context_kerberos(void *internal_ctx) {
 	crypto_free_blkcipher(kctx->enc);
 	crypto_free_blkcipher(kctx->acceptor_enc);
 	crypto_free_blkcipher(kctx->initiator_enc);
+	crypto_free_blkcipher(kctx->acceptor_enc_aux);
+	crypto_free_blkcipher(kctx->initiator_enc_aux);
 	kfree(kctx->mech_used.data);
 	kfree(kctx);
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 4aa46b2..a1a3585 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -113,8 +113,8 @@ out:
 	return 0;
 }
 
-static void
-make_confounder(char *p, u32 conflen)
+void
+gss_krb5_make_confounder(char *p, u32 conflen)
 {
 	static u64 i = 0;
 	u64 *q = (u64 *)p;
@@ -204,7 +204,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	memset(ptr + 4, 0xff, 4);
 	*(__be16 *)(ptr + 4) = cpu_to_le16(kctx->gk5e->sealalg);
 
-	make_confounder(msg_start, blocksize);
+	gss_krb5_make_confounder(msg_start, blocksize);
 
 	if (kctx->gk5e->keyed_cksum)
 		cksumkey = kctx->cksum;
-- 
1.6.6.1

