Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:45388 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754880AbcAXNS4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:18:56 -0500
Subject: [PATCH 14/26] KEYS: Use skcipher
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
Message-Id: <E1aNKYd-0008DY-R0@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:18:19 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of blkcipher with skcipher.
   
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 security/keys/encrypted-keys/encrypted.c |   82 ++++++++++++++++++-------------
 1 file changed, 50 insertions(+), 32 deletions(-)

diff --git a/security/keys/encrypted-keys/encrypted.c b/security/keys/encrypted-keys/encrypted.c
index 696ccfa..5adbfc3 100644
--- a/security/keys/encrypted-keys/encrypted.c
+++ b/security/keys/encrypted-keys/encrypted.c
@@ -28,11 +28,10 @@
 #include <linux/random.h>
 #include <linux/rcupdate.h>
 #include <linux/scatterlist.h>
-#include <linux/crypto.h>
 #include <linux/ctype.h>
 #include <crypto/hash.h>
 #include <crypto/sha.h>
-#include <crypto/aes.h>
+#include <crypto/skcipher.h>
 
 #include "encrypted.h"
 #include "ecryptfs_format.h"
@@ -85,17 +84,17 @@ static const match_table_t key_tokens = {
 
 static int aes_get_sizes(void)
 {
-	struct crypto_blkcipher *tfm;
+	struct crypto_skcipher *tfm;
 
-	tfm = crypto_alloc_blkcipher(blkcipher_alg, 0, CRYPTO_ALG_ASYNC);
+	tfm = crypto_alloc_skcipher(blkcipher_alg, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm)) {
 		pr_err("encrypted_key: failed to alloc_cipher (%ld)\n",
 		       PTR_ERR(tfm));
 		return PTR_ERR(tfm);
 	}
-	ivsize = crypto_blkcipher_ivsize(tfm);
-	blksize = crypto_blkcipher_blocksize(tfm);
-	crypto_free_blkcipher(tfm);
+	ivsize = crypto_skcipher_ivsize(tfm);
+	blksize = crypto_skcipher_blocksize(tfm);
+	crypto_free_skcipher(tfm);
 	return 0;
 }
 
@@ -401,28 +400,37 @@ static int get_derived_key(u8 *derived_key, enum derived_key_type key_type,
 	return ret;
 }
 
-static int init_blkcipher_desc(struct blkcipher_desc *desc, const u8 *key,
-			       unsigned int key_len, const u8 *iv,
-			       unsigned int ivsize)
+static struct skcipher_request *init_skcipher_req(const u8 *key,
+						  unsigned int key_len)
 {
+	struct skcipher_request *req;
+	struct crypto_skcipher *tfm;
 	int ret;
 
-	desc->tfm = crypto_alloc_blkcipher(blkcipher_alg, 0, CRYPTO_ALG_ASYNC);
-	if (IS_ERR(desc->tfm)) {
+	tfm = crypto_alloc_skcipher(blkcipher_alg, 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(tfm)) {
 		pr_err("encrypted_key: failed to load %s transform (%ld)\n",
-		       blkcipher_alg, PTR_ERR(desc->tfm));
-		return PTR_ERR(desc->tfm);
+		       blkcipher_alg, PTR_ERR(tfm));
+		return ERR_CAST(tfm);
 	}
-	desc->flags = 0;
 
-	ret = crypto_blkcipher_setkey(desc->tfm, key, key_len);
+	ret = crypto_skcipher_setkey(tfm, key, key_len);
 	if (ret < 0) {
 		pr_err("encrypted_key: failed to setkey (%d)\n", ret);
-		crypto_free_blkcipher(desc->tfm);
-		return ret;
+		crypto_free_skcipher(tfm);
+		return ERR_PTR(ret);
 	}
-	crypto_blkcipher_set_iv(desc->tfm, iv, ivsize);
-	return 0;
+
+	req = skcipher_request_alloc(tfm, GFP_KERNEL);
+	if (!req) {
+		pr_err("encrypted_key: failed to allocate request for %s\n",
+		       blkcipher_alg);
+		crypto_free_skcipher(tfm);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	return req;
 }
 
 static struct key *request_master_key(struct encrypted_key_payload *epayload,
@@ -467,7 +475,8 @@ static int derived_key_encrypt(struct encrypted_key_payload *epayload,
 {
 	struct scatterlist sg_in[2];
 	struct scatterlist sg_out[1];
-	struct blkcipher_desc desc;
+	struct crypto_skcipher *tfm;
+	struct skcipher_request *req;
 	unsigned int encrypted_datalen;
 	unsigned int padlen;
 	char pad[16];
@@ -476,9 +485,9 @@ static int derived_key_encrypt(struct encrypted_key_payload *epayload,
 	encrypted_datalen = roundup(epayload->decrypted_datalen, blksize);
 	padlen = encrypted_datalen - epayload->decrypted_datalen;
 
-	ret = init_blkcipher_desc(&desc, derived_key, derived_keylen,
-				  epayload->iv, ivsize);
-	if (ret < 0)
+	req = init_skcipher_req(derived_key, derived_keylen);
+	ret = PTR_ERR(req);
+	if (IS_ERR(req))
 		goto out;
 	dump_decrypted_data(epayload);
 
@@ -491,8 +500,12 @@ static int derived_key_encrypt(struct encrypted_key_payload *epayload,
 	sg_init_table(sg_out, 1);
 	sg_set_buf(sg_out, epayload->encrypted_data, encrypted_datalen);
 
-	ret = crypto_blkcipher_encrypt(&desc, sg_out, sg_in, encrypted_datalen);
-	crypto_free_blkcipher(desc.tfm);
+	skcipher_request_set_crypt(req, sg_in, sg_out, encrypted_datalen,
+				   epayload->iv);
+	ret = crypto_skcipher_encrypt(req);
+	tfm = crypto_skcipher_reqtfm(req);
+	skcipher_request_free(req);
+	crypto_free_skcipher(tfm);
 	if (ret < 0)
 		pr_err("encrypted_key: failed to encrypt (%d)\n", ret);
 	else
@@ -565,15 +578,16 @@ static int derived_key_decrypt(struct encrypted_key_payload *epayload,
 {
 	struct scatterlist sg_in[1];
 	struct scatterlist sg_out[2];
-	struct blkcipher_desc desc;
+	struct crypto_skcipher *tfm;
+	struct skcipher_request *req;
 	unsigned int encrypted_datalen;
 	char pad[16];
 	int ret;
 
 	encrypted_datalen = roundup(epayload->decrypted_datalen, blksize);
-	ret = init_blkcipher_desc(&desc, derived_key, derived_keylen,
-				  epayload->iv, ivsize);
-	if (ret < 0)
+	req = init_skcipher_req(derived_key, derived_keylen);
+	ret = PTR_ERR(req);
+	if (IS_ERR(req))
 		goto out;
 	dump_encrypted_data(epayload, encrypted_datalen);
 
@@ -585,8 +599,12 @@ static int derived_key_decrypt(struct encrypted_key_payload *epayload,
 		   epayload->decrypted_datalen);
 	sg_set_buf(&sg_out[1], pad, sizeof pad);
 
-	ret = crypto_blkcipher_decrypt(&desc, sg_out, sg_in, encrypted_datalen);
-	crypto_free_blkcipher(desc.tfm);
+	skcipher_request_set_crypt(req, sg_in, sg_out, encrypted_datalen,
+				   epayload->iv);
+	ret = crypto_skcipher_decrypt(req);
+	tfm = crypto_skcipher_reqtfm(req);
+	skcipher_request_free(req);
+	crypto_free_skcipher(tfm);
 	if (ret < 0)
 		goto out;
 	dump_decrypted_data(epayload);
