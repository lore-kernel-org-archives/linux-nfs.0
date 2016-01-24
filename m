Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:53753 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078AbcAXNRR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:17:17 -0500
Subject: [PATCH 4/26] dm crypt: Use skcipher and ahash
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
Message-Id: <E1aNKWy-0008Ah-UM@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:16:36 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of ablkcipher with skcipher, and the long
obsolete hash interface with ahash.
    
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/md/dm-crypt.c |   93 +++++++++++++++++++++++++-------------------------
 1 file changed, 48 insertions(+), 45 deletions(-)

diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index 3147c8d..06a4e3c 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -28,6 +28,7 @@
 #include <crypto/hash.h>
 #include <crypto/md5.h>
 #include <crypto/algapi.h>
+#include <crypto/skcipher.h>
 
 #include <linux/device-mapper.h>
 
@@ -44,7 +45,7 @@ struct convert_context {
 	struct bvec_iter iter_out;
 	sector_t cc_sector;
 	atomic_t cc_pending;
-	struct ablkcipher_request *req;
+	struct skcipher_request *req;
 };
 
 /*
@@ -86,7 +87,7 @@ struct crypt_iv_operations {
 };
 
 struct iv_essiv_private {
-	struct crypto_hash *hash_tfm;
+	struct crypto_ahash *hash_tfm;
 	u8 *salt;
 };
 
@@ -153,13 +154,13 @@ struct crypt_config {
 
 	/* ESSIV: struct crypto_cipher *essiv_tfm */
 	void *iv_private;
-	struct crypto_ablkcipher **tfms;
+	struct crypto_skcipher **tfms;
 	unsigned tfms_count;
 
 	/*
 	 * Layout of each crypto request:
 	 *
-	 *   struct ablkcipher_request
+	 *   struct skcipher_request
 	 *      context
 	 *      padding
 	 *   struct dm_crypt_request
@@ -189,7 +190,7 @@ static u8 *iv_of_dmreq(struct crypt_config *cc, struct dm_crypt_request *dmreq);
 /*
  * Use this to access cipher attributes that are the same for each CPU.
  */
-static struct crypto_ablkcipher *any_tfm(struct crypt_config *cc)
+static struct crypto_skcipher *any_tfm(struct crypt_config *cc)
 {
 	return cc->tfms[0];
 }
@@ -263,23 +264,25 @@ static int crypt_iv_plain64_gen(struct crypt_config *cc, u8 *iv,
 static int crypt_iv_essiv_init(struct crypt_config *cc)
 {
 	struct iv_essiv_private *essiv = &cc->iv_gen_private.essiv;
-	struct hash_desc desc;
+	AHASH_REQUEST_ON_STACK(req, essiv->hash_tfm);
 	struct scatterlist sg;
 	struct crypto_cipher *essiv_tfm;
 	int err;
 
 	sg_init_one(&sg, cc->key, cc->key_size);
-	desc.tfm = essiv->hash_tfm;
-	desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
+	ahash_request_set_tfm(req, essiv->hash_tfm);
+	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
+	ahash_request_set_crypt(req, &sg, essiv->salt, cc->key_size);
 
-	err = crypto_hash_digest(&desc, &sg, cc->key_size, essiv->salt);
+	err = crypto_ahash_digest(req);
+	ahash_request_zero(req);
 	if (err)
 		return err;
 
 	essiv_tfm = cc->iv_private;
 
 	err = crypto_cipher_setkey(essiv_tfm, essiv->salt,
-			    crypto_hash_digestsize(essiv->hash_tfm));
+			    crypto_ahash_digestsize(essiv->hash_tfm));
 	if (err)
 		return err;
 
@@ -290,7 +293,7 @@ static int crypt_iv_essiv_init(struct crypt_config *cc)
 static int crypt_iv_essiv_wipe(struct crypt_config *cc)
 {
 	struct iv_essiv_private *essiv = &cc->iv_gen_private.essiv;
-	unsigned salt_size = crypto_hash_digestsize(essiv->hash_tfm);
+	unsigned salt_size = crypto_ahash_digestsize(essiv->hash_tfm);
 	struct crypto_cipher *essiv_tfm;
 	int r, err = 0;
 
@@ -320,7 +323,7 @@ static struct crypto_cipher *setup_essiv_cpu(struct crypt_config *cc,
 	}
 
 	if (crypto_cipher_blocksize(essiv_tfm) !=
-	    crypto_ablkcipher_ivsize(any_tfm(cc))) {
+	    crypto_skcipher_ivsize(any_tfm(cc))) {
 		ti->error = "Block size of ESSIV cipher does "
 			    "not match IV size of block cipher";
 		crypto_free_cipher(essiv_tfm);
@@ -342,7 +345,7 @@ static void crypt_iv_essiv_dtr(struct crypt_config *cc)
 	struct crypto_cipher *essiv_tfm;
 	struct iv_essiv_private *essiv = &cc->iv_gen_private.essiv;
 
-	crypto_free_hash(essiv->hash_tfm);
+	crypto_free_ahash(essiv->hash_tfm);
 	essiv->hash_tfm = NULL;
 
 	kzfree(essiv->salt);
@@ -360,7 +363,7 @@ static int crypt_iv_essiv_ctr(struct crypt_config *cc, struct dm_target *ti,
 			      const char *opts)
 {
 	struct crypto_cipher *essiv_tfm = NULL;
-	struct crypto_hash *hash_tfm = NULL;
+	struct crypto_ahash *hash_tfm = NULL;
 	u8 *salt = NULL;
 	int err;
 
@@ -370,14 +373,14 @@ static int crypt_iv_essiv_ctr(struct crypt_config *cc, struct dm_target *ti,
 	}
 
 	/* Allocate hash algorithm */
-	hash_tfm = crypto_alloc_hash(opts, 0, CRYPTO_ALG_ASYNC);
+	hash_tfm = crypto_alloc_ahash(opts, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(hash_tfm)) {
 		ti->error = "Error initializing ESSIV hash";
 		err = PTR_ERR(hash_tfm);
 		goto bad;
 	}
 
-	salt = kzalloc(crypto_hash_digestsize(hash_tfm), GFP_KERNEL);
+	salt = kzalloc(crypto_ahash_digestsize(hash_tfm), GFP_KERNEL);
 	if (!salt) {
 		ti->error = "Error kmallocing salt storage in ESSIV";
 		err = -ENOMEM;
@@ -388,7 +391,7 @@ static int crypt_iv_essiv_ctr(struct crypt_config *cc, struct dm_target *ti,
 	cc->iv_gen_private.essiv.hash_tfm = hash_tfm;
 
 	essiv_tfm = setup_essiv_cpu(cc, ti, salt,
-				crypto_hash_digestsize(hash_tfm));
+				crypto_ahash_digestsize(hash_tfm));
 	if (IS_ERR(essiv_tfm)) {
 		crypt_iv_essiv_dtr(cc);
 		return PTR_ERR(essiv_tfm);
@@ -399,7 +402,7 @@ static int crypt_iv_essiv_ctr(struct crypt_config *cc, struct dm_target *ti,
 
 bad:
 	if (hash_tfm && !IS_ERR(hash_tfm))
-		crypto_free_hash(hash_tfm);
+		crypto_free_ahash(hash_tfm);
 	kfree(salt);
 	return err;
 }
@@ -419,7 +422,7 @@ static int crypt_iv_essiv_gen(struct crypt_config *cc, u8 *iv,
 static int crypt_iv_benbi_ctr(struct crypt_config *cc, struct dm_target *ti,
 			      const char *opts)
 {
-	unsigned bs = crypto_ablkcipher_blocksize(any_tfm(cc));
+	unsigned bs = crypto_skcipher_blocksize(any_tfm(cc));
 	int log = ilog2(bs);
 
 	/* we need to calculate how far we must shift the sector count
@@ -816,27 +819,27 @@ static void crypt_convert_init(struct crypt_config *cc,
 }
 
 static struct dm_crypt_request *dmreq_of_req(struct crypt_config *cc,
-					     struct ablkcipher_request *req)
+					     struct skcipher_request *req)
 {
 	return (struct dm_crypt_request *)((char *)req + cc->dmreq_start);
 }
 
-static struct ablkcipher_request *req_of_dmreq(struct crypt_config *cc,
+static struct skcipher_request *req_of_dmreq(struct crypt_config *cc,
 					       struct dm_crypt_request *dmreq)
 {
-	return (struct ablkcipher_request *)((char *)dmreq - cc->dmreq_start);
+	return (struct skcipher_request *)((char *)dmreq - cc->dmreq_start);
 }
 
 static u8 *iv_of_dmreq(struct crypt_config *cc,
 		       struct dm_crypt_request *dmreq)
 {
 	return (u8 *)ALIGN((unsigned long)(dmreq + 1),
-		crypto_ablkcipher_alignmask(any_tfm(cc)) + 1);
+		crypto_skcipher_alignmask(any_tfm(cc)) + 1);
 }
 
 static int crypt_convert_block(struct crypt_config *cc,
 			       struct convert_context *ctx,
-			       struct ablkcipher_request *req)
+			       struct skcipher_request *req)
 {
 	struct bio_vec bv_in = bio_iter_iovec(ctx->bio_in, ctx->iter_in);
 	struct bio_vec bv_out = bio_iter_iovec(ctx->bio_out, ctx->iter_out);
@@ -866,13 +869,13 @@ static int crypt_convert_block(struct crypt_config *cc,
 			return r;
 	}
 
-	ablkcipher_request_set_crypt(req, &dmreq->sg_in, &dmreq->sg_out,
-				     1 << SECTOR_SHIFT, iv);
+	skcipher_request_set_crypt(req, &dmreq->sg_in, &dmreq->sg_out,
+				   1 << SECTOR_SHIFT, iv);
 
 	if (bio_data_dir(ctx->bio_in) == WRITE)
-		r = crypto_ablkcipher_encrypt(req);
+		r = crypto_skcipher_encrypt(req);
 	else
-		r = crypto_ablkcipher_decrypt(req);
+		r = crypto_skcipher_decrypt(req);
 
 	if (!r && cc->iv_gen_ops && cc->iv_gen_ops->post)
 		r = cc->iv_gen_ops->post(cc, iv, dmreq);
@@ -891,23 +894,23 @@ static void crypt_alloc_req(struct crypt_config *cc,
 	if (!ctx->req)
 		ctx->req = mempool_alloc(cc->req_pool, GFP_NOIO);
 
-	ablkcipher_request_set_tfm(ctx->req, cc->tfms[key_index]);
+	skcipher_request_set_tfm(ctx->req, cc->tfms[key_index]);
 
 	/*
 	 * Use REQ_MAY_BACKLOG so a cipher driver internally backlogs
 	 * requests if driver request queue is full.
 	 */
-	ablkcipher_request_set_callback(ctx->req,
+	skcipher_request_set_callback(ctx->req,
 	    CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
 	    kcryptd_async_done, dmreq_of_req(cc, ctx->req));
 }
 
 static void crypt_free_req(struct crypt_config *cc,
-			   struct ablkcipher_request *req, struct bio *base_bio)
+			   struct skcipher_request *req, struct bio *base_bio)
 {
 	struct dm_crypt_io *io = dm_per_bio_data(base_bio, cc->per_bio_data_size);
 
-	if ((struct ablkcipher_request *)(io + 1) != req)
+	if ((struct skcipher_request *)(io + 1) != req)
 		mempool_free(req, cc->req_pool);
 }
 
@@ -1437,7 +1440,7 @@ static void crypt_free_tfms(struct crypt_config *cc)
 
 	for (i = 0; i < cc->tfms_count; i++)
 		if (cc->tfms[i] && !IS_ERR(cc->tfms[i])) {
-			crypto_free_ablkcipher(cc->tfms[i]);
+			crypto_free_skcipher(cc->tfms[i]);
 			cc->tfms[i] = NULL;
 		}
 
@@ -1450,13 +1453,13 @@ static int crypt_alloc_tfms(struct crypt_config *cc, char *ciphermode)
 	unsigned i;
 	int err;
 
-	cc->tfms = kmalloc(cc->tfms_count * sizeof(struct crypto_ablkcipher *),
+	cc->tfms = kmalloc(cc->tfms_count * sizeof(struct crypto_skcipher *),
 			   GFP_KERNEL);
 	if (!cc->tfms)
 		return -ENOMEM;
 
 	for (i = 0; i < cc->tfms_count; i++) {
-		cc->tfms[i] = crypto_alloc_ablkcipher(ciphermode, 0, 0);
+		cc->tfms[i] = crypto_alloc_skcipher(ciphermode, 0, 0);
 		if (IS_ERR(cc->tfms[i])) {
 			err = PTR_ERR(cc->tfms[i]);
 			crypt_free_tfms(cc);
@@ -1476,9 +1479,9 @@ static int crypt_setkey_allcpus(struct crypt_config *cc)
 	subkey_size = (cc->key_size - cc->key_extra_size) >> ilog2(cc->tfms_count);
 
 	for (i = 0; i < cc->tfms_count; i++) {
-		r = crypto_ablkcipher_setkey(cc->tfms[i],
-					     cc->key + (i * subkey_size),
-					     subkey_size);
+		r = crypto_skcipher_setkey(cc->tfms[i],
+					   cc->key + (i * subkey_size),
+					   subkey_size);
 		if (r)
 			err = r;
 	}
@@ -1645,7 +1648,7 @@ static int crypt_ctr_cipher(struct dm_target *ti,
 	}
 
 	/* Initialize IV */
-	cc->iv_size = crypto_ablkcipher_ivsize(any_tfm(cc));
+	cc->iv_size = crypto_skcipher_ivsize(any_tfm(cc));
 	if (cc->iv_size)
 		/* at least a 64 bit sector number should fit in our buffer */
 		cc->iv_size = max(cc->iv_size,
@@ -1763,21 +1766,21 @@ static int crypt_ctr(struct dm_target *ti, unsigned int argc, char **argv)
 	if (ret < 0)
 		goto bad;
 
-	cc->dmreq_start = sizeof(struct ablkcipher_request);
-	cc->dmreq_start += crypto_ablkcipher_reqsize(any_tfm(cc));
+	cc->dmreq_start = sizeof(struct skcipher_request);
+	cc->dmreq_start += crypto_skcipher_reqsize(any_tfm(cc));
 	cc->dmreq_start = ALIGN(cc->dmreq_start, __alignof__(struct dm_crypt_request));
 
-	if (crypto_ablkcipher_alignmask(any_tfm(cc)) < CRYPTO_MINALIGN) {
+	if (crypto_skcipher_alignmask(any_tfm(cc)) < CRYPTO_MINALIGN) {
 		/* Allocate the padding exactly */
 		iv_size_padding = -(cc->dmreq_start + sizeof(struct dm_crypt_request))
-				& crypto_ablkcipher_alignmask(any_tfm(cc));
+				& crypto_skcipher_alignmask(any_tfm(cc));
 	} else {
 		/*
 		 * If the cipher requires greater alignment than kmalloc
 		 * alignment, we don't know the exact position of the
 		 * initialization vector. We must assume worst case.
 		 */
-		iv_size_padding = crypto_ablkcipher_alignmask(any_tfm(cc));
+		iv_size_padding = crypto_skcipher_alignmask(any_tfm(cc));
 	}
 
 	ret = -ENOMEM;
@@ -1922,7 +1925,7 @@ static int crypt_map(struct dm_target *ti, struct bio *bio)
 
 	io = dm_per_bio_data(bio, cc->per_bio_data_size);
 	crypt_io_init(io, cc, bio, dm_target_offset(ti, bio->bi_iter.bi_sector));
-	io->ctx.req = (struct ablkcipher_request *)(io + 1);
+	io->ctx.req = (struct skcipher_request *)(io + 1);
 
 	if (bio_data_dir(io->base_bio) == READ) {
 		if (kcryptd_io_read(io, GFP_NOWAIT))
