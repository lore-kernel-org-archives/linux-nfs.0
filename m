From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 19/19] gss_krb5: add remaining pieces to enable AES encryption
	support
Date: Thu, 21 Feb 2008 13:45:23 -0500
Message-ID: <20080221184523.19195.17522.stgit@jazz.citi.umich.edu>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:22077 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755032AbYBUSpX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 13:45:23 -0500
Received: from jazz.citi.umich.edu (jazz.citi.umich.edu [141.211.133.62])
	by citi.umich.edu (Postfix) with ESMTP id 3531845B5
	for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 13:45:23 -0500 (EST)
In-Reply-To: <20080221184208.19195.94518.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add the remaining pieces to enable support for Kerberos AES
encryption types.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 include/linux/sunrpc/gss_krb5.h       |   12 +
 net/sunrpc/auth_gss/gss_krb5_crypto.c |  307 +++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/gss_krb5_keys.c   |   30 +++
 net/sunrpc/auth_gss/gss_krb5_mech.c   |   44 +++++
 net/sunrpc/rpc_pipe.c                 |    2 
 5 files changed, 394 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 95b375b..2d60018 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -272,3 +272,15 @@ u32 krb5_derive_key(struct gss_krb5_enctype *gk5e,
 u32 gss_krb5_des3_make_key(struct gss_krb5_enctype *gk5e,
 			   struct xdr_netobj *randombits,
 			   struct xdr_netobj *key);
+
+u32 gss_krb5_aes_make_key(struct gss_krb5_enctype *gk5e,
+			  struct xdr_netobj *randombits,
+			  struct xdr_netobj *key);
+
+u32 gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
+			 struct xdr_buf *buf, int ec,
+			 struct page **pages);
+
+u32 gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset,
+			 struct xdr_buf *buf, u32 *plainoffset,
+			 u32 *plainlen);
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 0c52194..92c2eff 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -42,6 +42,7 @@
 #include <linux/crypto.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
+#include <linux/random.h>
 #include <linux/sunrpc/gss_krb5.h>
 #include <linux/sunrpc/xdr.h>
 
@@ -448,3 +449,309 @@ gss_decrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *buf,
 }
 
 EXPORT_SYMBOL(gss_decrypt_xdr_buf);
+
+static s32
+gss_cksum_xdr_buf(struct krb5_ctx *kctx, struct xdr_buf *body, int body_offset,
+		  const u8 *key, unsigned int keylen, struct xdr_netobj *out)
+{
+	struct hash_desc desc;
+	int err;
+
+	desc.tfm = crypto_alloc_hash(kctx->gk5e->cksum_name, 0,
+					CRYPTO_ALG_ASYNC);
+	if (IS_ERR(desc.tfm))
+		return GSS_S_FAILURE;
+	if (out->data == NULL)
+		return GSS_S_FAILURE;
+	if (out->len < crypto_hash_digestsize(desc.tfm))
+		return GSS_S_FAILURE;
+	out->len = crypto_hash_digestsize(desc.tfm);
+	desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
+
+	if (key != NULL && keylen != 0) {
+		err = crypto_hash_setkey(desc.tfm, key, keylen);
+		if (err)
+			goto out;
+	}
+
+	err = crypto_hash_init(&desc);
+	if (err)
+		goto out;
+	err = xdr_process_buf(body, body_offset, body->len - body_offset,
+			      checksummer, &desc);
+	if (err)
+		goto out;
+	err = crypto_hash_final(&desc, out->data);
+
+out:
+	crypto_free_hash(desc.tfm);
+	return err ? GSS_S_FAILURE : 0;
+}
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
+	u8 *cksumkey, *enckey;
+	u8 *ecptr;
+	struct crypto_blkcipher *cipher, *cbc = NULL;
+	int blocksize;
+	struct page **save_pages;
+	int nblocks, nbytes;
+	struct encryptor_desc desc;
+	u32 cbcbytes;
+
+	if (kctx->initiate) {
+		cipher = kctx->initiator_enc;
+		enckey = kctx->initiator_seal;
+		cksumkey = kctx->initiator_integ;
+	} else {
+		cipher = kctx->acceptor_enc;
+		enckey = kctx->acceptor_seal;
+		cksumkey = kctx->acceptor_integ;
+	}
+	blocksize = crypto_blkcipher_blocksize(cipher);
+
+	/* hide the gss token header and insert the confounder */
+	offset += 16;
+	if (xdr_shift_head_data(buf, offset, blocksize))
+		return GSS_S_FAILURE;
+	get_random_bytes(buf->head[0].iov_base + offset, blocksize);
+	offset -= 16;
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
+	memcpy(ecptr + ec, buf->head[0].iov_base + offset, 16);
+	buf->tail[0].iov_len += 16;
+	buf->len += 16;
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
+	err = gss_cksum_xdr_buf(kctx, buf, offset + 16, cksumkey,
+				kctx->gk5e->keylength, &hmac);
+	buf->pages = save_pages;
+	if (err)
+		return GSS_S_FAILURE;
+
+	nbytes = buf->len - offset - 16;
+	nblocks = (nbytes + blocksize - 1) / blocksize;
+	cbcbytes = 0;
+	if (nblocks > 2)
+		cbcbytes = (nblocks - 2) * blocksize;
+
+	memset(desc.iv, 0, sizeof(desc.iv));
+
+	if (cbcbytes) {
+		/* XXX This does a kzalloc, may need to pre-allocate this! */
+		cbc = crypto_alloc_blkcipher("cbc(aes)", 0, CRYPTO_ALG_ASYNC);
+		if (cbc == NULL)
+			return GSS_S_FAILURE;
+		err = crypto_blkcipher_setkey(cbc, enckey,
+					      kctx->gk5e->keylength);
+		if (err)
+			goto out_err;
+
+		desc.pos = offset + 16;
+		desc.fragno = 0;
+		desc.fraglen = 0;
+		desc.pages = pages;
+		desc.outbuf = buf;
+		desc.desc.info = desc.iv;
+		desc.desc.flags = 0;
+		desc.desc.tfm = cbc;
+
+		sg_init_table(desc.infrags, 4);
+		sg_init_table(desc.outfrags, 4);
+
+		err = xdr_process_buf(buf, offset + 16, cbcbytes,
+							encryptor, &desc);
+		if (err)
+			goto out_err;
+	}
+
+	/* Make sure IV carries forward from any CBC results. */
+	err = gss_krb5_cts_crypt(cipher, buf, offset + 16 + cbcbytes,
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
+	if (cbc != NULL)
+		crypto_free_blkcipher(cbc);
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
+	u8 *cksum_key, *enckey;
+	struct crypto_blkcipher *cipher, *cbc = NULL;
+	struct xdr_netobj our_hmac_obj;
+	u8 our_hmac[GSS_KRB5_MAX_CKSUM_LEN];
+	u8 pkt_hmac[GSS_KRB5_MAX_CKSUM_LEN];
+	int nblocks, blocksize, cbcbytes;
+	struct decryptor_desc desc;
+
+	if (kctx->initiate) {
+		cipher = kctx->acceptor_enc;
+		enckey = kctx->acceptor_seal;
+		cksum_key = kctx->acceptor_integ;
+	} else {
+		cipher = kctx->initiator_enc;
+		enckey = kctx->initiator_seal;
+		cksum_key = kctx->initiator_integ;
+	}
+	blocksize = crypto_blkcipher_blocksize(cipher);
+
+
+	/* create a segment skipping the header and leaving out the checksum */
+	xdr_buf_subsegment(buf, &subbuf, offset + 16,
+			(buf->len - offset - 16 - kctx->gk5e->cksumlength));
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
+		/* XXX This does a kzalloc, may need to pre-allocate this! */
+		cbc = crypto_alloc_blkcipher("cbc(aes)", 0, CRYPTO_ALG_ASYNC);
+		if (cbc == NULL) {
+			ret = GSS_S_FAILURE;
+			goto out_err;
+		}
+		ret = crypto_blkcipher_setkey(cbc, enckey,
+					      kctx->gk5e->keylength);
+		if (ret)
+			goto out_err;
+
+		desc.fragno = 0;
+		desc.fraglen = 0;
+		desc.desc.info = desc.iv;
+		desc.desc.flags = 0;
+		desc.desc.tfm = cbc;
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
+	ret = gss_cksum_xdr_buf(kctx, &subbuf, 0, cksum_key,
+					kctx->gk5e->keylength, &our_hmac_obj);
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
+	if (cbc != NULL)
+		crypto_free_blkcipher(cbc);
+	if (ret && ret != GSS_S_BAD_SIG)
+		ret = GSS_S_FAILURE;
+	return ret;
+}
diff --git a/net/sunrpc/auth_gss/gss_krb5_keys.c b/net/sunrpc/auth_gss/gss_krb5_keys.c
index a722fba..351383c 100644
--- a/net/sunrpc/auth_gss/gss_krb5_keys.c
+++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
@@ -306,3 +306,33 @@ u32 gss_krb5_des3_make_key(struct gss_krb5_enctype *gk5e,
 err_out:
 	return(ret);
 }
+
+/*
+ * This is the aes key derivation postprocess function
+ */
+u32 gss_krb5_aes_make_key(struct gss_krb5_enctype *gk5e,
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
+	return (ret);
+}
+
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 2edf28e..cfd06ca 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -89,6 +89,50 @@ static struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
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
 
 static int num_supported_enctypes =
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index d84632a..e7f0807 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -392,7 +392,7 @@ static const struct file_operations rpc_info_operations = {
 static int
 rpc_show_krb5_info(struct seq_file *m, void *v)
 {
-	seq_printf(m, "enctypes: 16,3,1,2\n");
+	seq_printf(m, "enctypes: 18,17,16,3,1,2\n");
 	return 0;
 }
 

