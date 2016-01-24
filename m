Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:53517 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755144AbcAXNTQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:19:16 -0500
Subject: [PATCH 16/26] libceph: Use skcipher
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
Message-Id: <E1aNKYy-0008E6-GI@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:18:40 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of blkcipher with skcipher.
   
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ceph/crypto.c |   97 +++++++++++++++++++++++++++++++-----------------------
 1 file changed, 56 insertions(+), 41 deletions(-)

diff --git a/net/ceph/crypto.c b/net/ceph/crypto.c
index 42e8649..fb9cb2b 100644
--- a/net/ceph/crypto.c
+++ b/net/ceph/crypto.c
@@ -4,7 +4,8 @@
 #include <linux/err.h>
 #include <linux/scatterlist.h>
 #include <linux/slab.h>
-#include <crypto/hash.h>
+#include <crypto/aes.h>
+#include <crypto/skcipher.h>
 #include <linux/key-type.h>
 
 #include <keys/ceph-type.h>
@@ -79,9 +80,9 @@ int ceph_crypto_key_unarmor(struct ceph_crypto_key *key, const char *inkey)
 	return 0;
 }
 
-static struct crypto_blkcipher *ceph_crypto_alloc_cipher(void)
+static struct crypto_skcipher *ceph_crypto_alloc_cipher(void)
 {
-	return crypto_alloc_blkcipher("cbc(aes)", 0, CRYPTO_ALG_ASYNC);
+	return crypto_alloc_skcipher("cbc(aes)", 0, CRYPTO_ALG_ASYNC);
 }
 
 static const u8 *aes_iv = (u8 *)CEPH_AES_IV;
@@ -162,11 +163,11 @@ static int ceph_aes_encrypt(const void *key, int key_len,
 {
 	struct scatterlist sg_in[2], prealloc_sg;
 	struct sg_table sg_out;
-	struct crypto_blkcipher *tfm = ceph_crypto_alloc_cipher();
-	struct blkcipher_desc desc = { .tfm = tfm, .flags = 0 };
+	struct crypto_skcipher *tfm = ceph_crypto_alloc_cipher();
+	SKCIPHER_REQUEST_ON_STACK(req, tfm);
 	int ret;
-	void *iv;
-	int ivsize;
+	int ivsize = AES_BLOCK_SIZE;
+	char iv[ivsize];
 	size_t zero_padding = (0x10 - (src_len & 0x0f));
 	char pad[16];
 
@@ -184,11 +185,14 @@ static int ceph_aes_encrypt(const void *key, int key_len,
 	if (ret)
 		goto out_tfm;
 
-	crypto_blkcipher_setkey((void *)tfm, key, key_len);
-	iv = crypto_blkcipher_crt(tfm)->iv;
-	ivsize = crypto_blkcipher_ivsize(tfm);
+	crypto_skcipher_setkey((void *)tfm, key, key_len);
 	memcpy(iv, aes_iv, ivsize);
 
+	skcipher_request_set_tfm(req, tfm);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, sg_in, sg_out.sgl,
+				   src_len + zero_padding, iv);
+
 	/*
 	print_hex_dump(KERN_ERR, "enc key: ", DUMP_PREFIX_NONE, 16, 1,
 		       key, key_len, 1);
@@ -197,8 +201,8 @@ static int ceph_aes_encrypt(const void *key, int key_len,
 	print_hex_dump(KERN_ERR, "enc pad: ", DUMP_PREFIX_NONE, 16, 1,
 			pad, zero_padding, 1);
 	*/
-	ret = crypto_blkcipher_encrypt(&desc, sg_out.sgl, sg_in,
-				     src_len + zero_padding);
+	ret = crypto_skcipher_encrypt(req);
+	skcipher_request_zero(req);
 	if (ret < 0) {
 		pr_err("ceph_aes_crypt failed %d\n", ret);
 		goto out_sg;
@@ -211,7 +215,7 @@ static int ceph_aes_encrypt(const void *key, int key_len,
 out_sg:
 	teardown_sgtable(&sg_out);
 out_tfm:
-	crypto_free_blkcipher(tfm);
+	crypto_free_skcipher(tfm);
 	return ret;
 }
 
@@ -222,11 +226,11 @@ static int ceph_aes_encrypt2(const void *key, int key_len, void *dst,
 {
 	struct scatterlist sg_in[3], prealloc_sg;
 	struct sg_table sg_out;
-	struct crypto_blkcipher *tfm = ceph_crypto_alloc_cipher();
-	struct blkcipher_desc desc = { .tfm = tfm, .flags = 0 };
+	struct crypto_skcipher *tfm = ceph_crypto_alloc_cipher();
+	SKCIPHER_REQUEST_ON_STACK(req, tfm);
 	int ret;
-	void *iv;
-	int ivsize;
+	int ivsize = AES_BLOCK_SIZE;
+	char iv[ivsize];
 	size_t zero_padding = (0x10 - ((src1_len + src2_len) & 0x0f));
 	char pad[16];
 
@@ -245,11 +249,14 @@ static int ceph_aes_encrypt2(const void *key, int key_len, void *dst,
 	if (ret)
 		goto out_tfm;
 
-	crypto_blkcipher_setkey((void *)tfm, key, key_len);
-	iv = crypto_blkcipher_crt(tfm)->iv;
-	ivsize = crypto_blkcipher_ivsize(tfm);
+	crypto_skcipher_setkey((void *)tfm, key, key_len);
 	memcpy(iv, aes_iv, ivsize);
 
+	skcipher_request_set_tfm(req, tfm);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, sg_in, sg_out.sgl,
+				   src1_len + src2_len + zero_padding, iv);
+
 	/*
 	print_hex_dump(KERN_ERR, "enc  key: ", DUMP_PREFIX_NONE, 16, 1,
 		       key, key_len, 1);
@@ -260,8 +267,8 @@ static int ceph_aes_encrypt2(const void *key, int key_len, void *dst,
 	print_hex_dump(KERN_ERR, "enc  pad: ", DUMP_PREFIX_NONE, 16, 1,
 			pad, zero_padding, 1);
 	*/
-	ret = crypto_blkcipher_encrypt(&desc, sg_out.sgl, sg_in,
-				     src1_len + src2_len + zero_padding);
+	ret = crypto_skcipher_encrypt(req);
+	skcipher_request_zero(req);
 	if (ret < 0) {
 		pr_err("ceph_aes_crypt2 failed %d\n", ret);
 		goto out_sg;
@@ -274,7 +281,7 @@ static int ceph_aes_encrypt2(const void *key, int key_len, void *dst,
 out_sg:
 	teardown_sgtable(&sg_out);
 out_tfm:
-	crypto_free_blkcipher(tfm);
+	crypto_free_skcipher(tfm);
 	return ret;
 }
 
@@ -284,11 +291,11 @@ static int ceph_aes_decrypt(const void *key, int key_len,
 {
 	struct sg_table sg_in;
 	struct scatterlist sg_out[2], prealloc_sg;
-	struct crypto_blkcipher *tfm = ceph_crypto_alloc_cipher();
-	struct blkcipher_desc desc = { .tfm = tfm };
+	struct crypto_skcipher *tfm = ceph_crypto_alloc_cipher();
+	SKCIPHER_REQUEST_ON_STACK(req, tfm);
 	char pad[16];
-	void *iv;
-	int ivsize;
+	int ivsize = AES_BLOCK_SIZE;
+	char iv[16];
 	int ret;
 	int last_byte;
 
@@ -302,18 +309,22 @@ static int ceph_aes_decrypt(const void *key, int key_len,
 	if (ret)
 		goto out_tfm;
 
-	crypto_blkcipher_setkey((void *)tfm, key, key_len);
-	iv = crypto_blkcipher_crt(tfm)->iv;
-	ivsize = crypto_blkcipher_ivsize(tfm);
+	crypto_skcipher_setkey((void *)tfm, key, key_len);
 	memcpy(iv, aes_iv, ivsize);
 
+	skcipher_request_set_tfm(req, tfm);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, sg_in.sgl, sg_out,
+				   src_len, iv);
+
 	/*
 	print_hex_dump(KERN_ERR, "dec key: ", DUMP_PREFIX_NONE, 16, 1,
 		       key, key_len, 1);
 	print_hex_dump(KERN_ERR, "dec  in: ", DUMP_PREFIX_NONE, 16, 1,
 		       src, src_len, 1);
 	*/
-	ret = crypto_blkcipher_decrypt(&desc, sg_out, sg_in.sgl, src_len);
+	ret = crypto_skcipher_decrypt(req);
+	skcipher_request_zero(req);
 	if (ret < 0) {
 		pr_err("ceph_aes_decrypt failed %d\n", ret);
 		goto out_sg;
@@ -338,7 +349,7 @@ static int ceph_aes_decrypt(const void *key, int key_len,
 out_sg:
 	teardown_sgtable(&sg_in);
 out_tfm:
-	crypto_free_blkcipher(tfm);
+	crypto_free_skcipher(tfm);
 	return ret;
 }
 
@@ -349,11 +360,11 @@ static int ceph_aes_decrypt2(const void *key, int key_len,
 {
 	struct sg_table sg_in;
 	struct scatterlist sg_out[3], prealloc_sg;
-	struct crypto_blkcipher *tfm = ceph_crypto_alloc_cipher();
-	struct blkcipher_desc desc = { .tfm = tfm };
+	struct crypto_skcipher *tfm = ceph_crypto_alloc_cipher();
+	SKCIPHER_REQUEST_ON_STACK(req, tfm);
 	char pad[16];
-	void *iv;
-	int ivsize;
+	int ivsize = AES_BLOCK_SIZE;
+	char iv[ivsize];
 	int ret;
 	int last_byte;
 
@@ -368,18 +379,22 @@ static int ceph_aes_decrypt2(const void *key, int key_len,
 	if (ret)
 		goto out_tfm;
 
-	crypto_blkcipher_setkey((void *)tfm, key, key_len);
-	iv = crypto_blkcipher_crt(tfm)->iv;
-	ivsize = crypto_blkcipher_ivsize(tfm);
+	crypto_skcipher_setkey((void *)tfm, key, key_len);
 	memcpy(iv, aes_iv, ivsize);
 
+	skcipher_request_set_tfm(req, tfm);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, sg_in.sgl, sg_out,
+				   src_len, iv);
+
 	/*
 	print_hex_dump(KERN_ERR, "dec  key: ", DUMP_PREFIX_NONE, 16, 1,
 		       key, key_len, 1);
 	print_hex_dump(KERN_ERR, "dec   in: ", DUMP_PREFIX_NONE, 16, 1,
 		       src, src_len, 1);
 	*/
-	ret = crypto_blkcipher_decrypt(&desc, sg_out, sg_in.sgl, src_len);
+	ret = crypto_skcipher_decrypt(req);
+	skcipher_request_zero(req);
 	if (ret < 0) {
 		pr_err("ceph_aes_decrypt failed %d\n", ret);
 		goto out_sg;
@@ -415,7 +430,7 @@ static int ceph_aes_decrypt2(const void *key, int key_len,
 out_sg:
 	teardown_sgtable(&sg_in);
 out_tfm:
-	crypto_free_blkcipher(tfm);
+	crypto_free_skcipher(tfm);
 	return ret;
 }
 
