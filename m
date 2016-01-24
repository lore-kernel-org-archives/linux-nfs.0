Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:38144 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263AbcAXNQ5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:16:57 -0500
Subject: [PATCH 2/26] ppp_mppe: Use skcipher and ahash
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
Message-Id: <E1aNKWe-0008AE-HM@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:16:16 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of blkcipher with skcipher, and the long
obsolete hash interface with ahash.  This is a bug-for-bug conversion
and no attempt has been made to fix bugs such as the ignored return
values of the crypto operations.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/ppp/ppp_mppe.c |   99 ++++++++++++++++++++++++++-------------------
 1 file changed, 58 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
index 05005c6..f60f766 100644
--- a/drivers/net/ppp/ppp_mppe.c
+++ b/drivers/net/ppp/ppp_mppe.c
@@ -42,6 +42,8 @@
  *                    deprecated in 2.6
  */
 
+#include <crypto/hash.h>
+#include <crypto/skcipher.h>
 #include <linux/err.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -49,7 +51,6 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/string.h>
-#include <linux/crypto.h>
 #include <linux/mm.h>
 #include <linux/ppp_defs.h>
 #include <linux/ppp-comp.h>
@@ -94,8 +95,8 @@ static inline void sha_pad_init(struct sha_pad *shapad)
  * State for an MPPE (de)compressor.
  */
 struct ppp_mppe_state {
-	struct crypto_blkcipher *arc4;
-	struct crypto_hash *sha1;
+	struct crypto_skcipher *arc4;
+	struct crypto_ahash *sha1;
 	unsigned char *sha1_digest;
 	unsigned char master_key[MPPE_MAX_KEY_LEN];
 	unsigned char session_key[MPPE_MAX_KEY_LEN];
@@ -135,7 +136,7 @@ struct ppp_mppe_state {
  */
 static void get_new_key_from_sha(struct ppp_mppe_state * state)
 {
-	struct hash_desc desc;
+	AHASH_REQUEST_ON_STACK(req, state->sha1);
 	struct scatterlist sg[4];
 	unsigned int nbytes;
 
@@ -148,10 +149,12 @@ static void get_new_key_from_sha(struct ppp_mppe_state * state)
 	nbytes += setup_sg(&sg[3], sha_pad->sha_pad2,
 			   sizeof(sha_pad->sha_pad2));
 
-	desc.tfm = state->sha1;
-	desc.flags = 0;
+	ahash_request_set_tfm(req, state->sha1);
+	ahash_request_set_callback(req, 0, NULL, NULL);
+	ahash_request_set_crypt(req, sg, state->sha1_digest, nbytes);
 
-	crypto_hash_digest(&desc, sg, nbytes, state->sha1_digest);
+	crypto_ahash_digest(req);
+	ahash_request_zero(req);
 }
 
 /*
@@ -161,20 +164,23 @@ static void get_new_key_from_sha(struct ppp_mppe_state * state)
 static void mppe_rekey(struct ppp_mppe_state * state, int initial_key)
 {
 	struct scatterlist sg_in[1], sg_out[1];
-	struct blkcipher_desc desc = { .tfm = state->arc4 };
+	SKCIPHER_REQUEST_ON_STACK(req, state->arc4);
+
+	skcipher_request_set_tfm(req, state->arc4);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
 
 	get_new_key_from_sha(state);
 	if (!initial_key) {
-		crypto_blkcipher_setkey(state->arc4, state->sha1_digest,
-					state->keylen);
+		crypto_skcipher_setkey(state->arc4, state->sha1_digest,
+				       state->keylen);
 		sg_init_table(sg_in, 1);
 		sg_init_table(sg_out, 1);
 		setup_sg(sg_in, state->sha1_digest, state->keylen);
 		setup_sg(sg_out, state->session_key, state->keylen);
-		if (crypto_blkcipher_encrypt(&desc, sg_out, sg_in,
-					     state->keylen) != 0) {
+		skcipher_request_set_crypt(req, sg_in, sg_out, state->keylen,
+					   NULL);
+		if (crypto_skcipher_encrypt(req))
     		    printk(KERN_WARNING "mppe_rekey: cipher_encrypt failed\n");
-		}
 	} else {
 		memcpy(state->session_key, state->sha1_digest, state->keylen);
 	}
@@ -184,7 +190,8 @@ static void mppe_rekey(struct ppp_mppe_state * state, int initial_key)
 		state->session_key[1] = 0x26;
 		state->session_key[2] = 0x9e;
 	}
-	crypto_blkcipher_setkey(state->arc4, state->session_key, state->keylen);
+	crypto_skcipher_setkey(state->arc4, state->session_key, state->keylen);
+	skcipher_request_zero(req);
 }
 
 /*
@@ -204,19 +211,19 @@ static void *mppe_alloc(unsigned char *options, int optlen)
 		goto out;
 
 
-	state->arc4 = crypto_alloc_blkcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
+	state->arc4 = crypto_alloc_skcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(state->arc4)) {
 		state->arc4 = NULL;
 		goto out_free;
 	}
 
-	state->sha1 = crypto_alloc_hash("sha1", 0, CRYPTO_ALG_ASYNC);
+	state->sha1 = crypto_alloc_ahash("sha1", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(state->sha1)) {
 		state->sha1 = NULL;
 		goto out_free;
 	}
 
-	digestsize = crypto_hash_digestsize(state->sha1);
+	digestsize = crypto_ahash_digestsize(state->sha1);
 	if (digestsize < MPPE_MAX_KEY_LEN)
 		goto out_free;
 
@@ -237,15 +244,12 @@ static void *mppe_alloc(unsigned char *options, int optlen)
 
 	return (void *)state;
 
-	out_free:
-	    if (state->sha1_digest)
-		kfree(state->sha1_digest);
-	    if (state->sha1)
-		crypto_free_hash(state->sha1);
-	    if (state->arc4)
-		crypto_free_blkcipher(state->arc4);
-	    kfree(state);
-	out:
+out_free:
+	kfree(state->sha1_digest);
+	crypto_free_ahash(state->sha1);
+	crypto_free_skcipher(state->arc4);
+	kfree(state);
+out:
 	return NULL;
 }
 
@@ -256,13 +260,10 @@ static void mppe_free(void *arg)
 {
 	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
 	if (state) {
-	    if (state->sha1_digest)
 		kfree(state->sha1_digest);
-	    if (state->sha1)
-		crypto_free_hash(state->sha1);
-	    if (state->arc4)
-		crypto_free_blkcipher(state->arc4);
-	    kfree(state);
+		crypto_free_ahash(state->sha1);
+		crypto_free_skcipher(state->arc4);
+		kfree(state);
 	}
 }
 
@@ -368,8 +369,9 @@ mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
 	      int isize, int osize)
 {
 	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
-	struct blkcipher_desc desc = { .tfm = state->arc4 };
+	SKCIPHER_REQUEST_ON_STACK(req, state->arc4);
 	int proto;
+	int err;
 	struct scatterlist sg_in[1], sg_out[1];
 
 	/*
@@ -426,7 +428,13 @@ mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
 	sg_init_table(sg_out, 1);
 	setup_sg(sg_in, ibuf, isize);
 	setup_sg(sg_out, obuf, osize);
-	if (crypto_blkcipher_encrypt(&desc, sg_out, sg_in, isize) != 0) {
+
+	skcipher_request_set_tfm(req, state->arc4);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, sg_in, sg_out, isize, NULL);
+	err = crypto_skcipher_encrypt(req);
+	skcipher_request_zero(req);
+	if (err) {
 		printk(KERN_DEBUG "crypto_cypher_encrypt failed\n");
 		return -1;
 	}
@@ -475,7 +483,7 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 		int osize)
 {
 	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
-	struct blkcipher_desc desc = { .tfm = state->arc4 };
+	SKCIPHER_REQUEST_ON_STACK(req, state->arc4);
 	unsigned ccount;
 	int flushed = MPPE_BITS(ibuf) & MPPE_BIT_FLUSHED;
 	struct scatterlist sg_in[1], sg_out[1];
@@ -609,9 +617,14 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 	sg_init_table(sg_out, 1);
 	setup_sg(sg_in, ibuf, 1);
 	setup_sg(sg_out, obuf, 1);
-	if (crypto_blkcipher_decrypt(&desc, sg_out, sg_in, 1) != 0) {
+
+	skcipher_request_set_tfm(req, state->arc4);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, sg_in, sg_out, 1, NULL);
+	if (crypto_skcipher_decrypt(req)) {
 		printk(KERN_DEBUG "crypto_cypher_decrypt failed\n");
-		return DECOMP_ERROR;
+		osize = DECOMP_ERROR;
+		goto out_zap_req;
 	}
 
 	/*
@@ -629,9 +642,11 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 	/* And finally, decrypt the rest of the packet. */
 	setup_sg(sg_in, ibuf + 1, isize - 1);
 	setup_sg(sg_out, obuf + 1, osize - 1);
-	if (crypto_blkcipher_decrypt(&desc, sg_out, sg_in, isize - 1)) {
+	skcipher_request_set_crypt(req, sg_in, sg_out, isize - 1, NULL);
+	if (crypto_skcipher_decrypt(req)) {
 		printk(KERN_DEBUG "crypto_cypher_decrypt failed\n");
-		return DECOMP_ERROR;
+		osize = DECOMP_ERROR;
+		goto out_zap_req;
 	}
 
 	state->stats.unc_bytes += osize;
@@ -642,6 +657,8 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 	/* good packet credit */
 	state->sanity_errors >>= 1;
 
+out_zap_req:
+	skcipher_request_zero(req);
 	return osize;
 
 sanity_error:
@@ -714,8 +731,8 @@ static struct compressor ppp_mppe = {
 static int __init ppp_mppe_init(void)
 {
 	int answer;
-	if (!(crypto_has_blkcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC) &&
-	      crypto_has_hash("sha1", 0, CRYPTO_ALG_ASYNC)))
+	if (!(crypto_has_skcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC) &&
+	      crypto_has_ahash("sha1", 0, CRYPTO_ALG_ASYNC)))
 		return -ENODEV;
 
 	sha_pad = kmalloc(sizeof(struct sha_pad), GFP_KERNEL);
