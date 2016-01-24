Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:53366 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754432AbcAXNSR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:18:17 -0500
Subject: [PATCH 10/26] ext4: Use skcipher
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
Message-Id: <E1aNKXy-0008CQ-Ne@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:17:38 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of ablkcipher with skcipher.
   
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 fs/ext4/crypto.c       |   24 +++++++++++-------------
 fs/ext4/crypto_fname.c |   32 +++++++++++++++-----------------
 fs/ext4/crypto_key.c   |   42 ++++++++++++++++++++----------------------
 fs/ext4/ext4_crypto.h  |    2 +-
 4 files changed, 47 insertions(+), 53 deletions(-)

diff --git a/fs/ext4/crypto.c b/fs/ext4/crypto.c
index 1a08350..a052c2a 100644
--- a/fs/ext4/crypto.c
+++ b/fs/ext4/crypto.c
@@ -18,11 +18,9 @@
  * Special Publication 800-38E and IEEE P1619/D16.
  */
 
-#include <crypto/hash.h>
-#include <crypto/sha.h>
+#include <crypto/skcipher.h>
 #include <keys/user-type.h>
 #include <keys/encrypted-type.h>
-#include <linux/crypto.h>
 #include <linux/ecryptfs.h>
 #include <linux/gfp.h>
 #include <linux/kernel.h>
@@ -261,21 +259,21 @@ static int ext4_page_crypto(struct inode *inode,
 
 {
 	u8 xts_tweak[EXT4_XTS_TWEAK_SIZE];
-	struct ablkcipher_request *req = NULL;
+	struct skcipher_request *req = NULL;
 	DECLARE_EXT4_COMPLETION_RESULT(ecr);
 	struct scatterlist dst, src;
 	struct ext4_crypt_info *ci = EXT4_I(inode)->i_crypt_info;
-	struct crypto_ablkcipher *tfm = ci->ci_ctfm;
+	struct crypto_skcipher *tfm = ci->ci_ctfm;
 	int res = 0;
 
-	req = ablkcipher_request_alloc(tfm, GFP_NOFS);
+	req = skcipher_request_alloc(tfm, GFP_NOFS);
 	if (!req) {
 		printk_ratelimited(KERN_ERR
 				   "%s: crypto_request_alloc() failed\n",
 				   __func__);
 		return -ENOMEM;
 	}
-	ablkcipher_request_set_callback(
+	skcipher_request_set_callback(
 		req, CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
 		ext4_crypt_complete, &ecr);
 
@@ -288,21 +286,21 @@ static int ext4_page_crypto(struct inode *inode,
 	sg_set_page(&dst, dest_page, PAGE_CACHE_SIZE, 0);
 	sg_init_table(&src, 1);
 	sg_set_page(&src, src_page, PAGE_CACHE_SIZE, 0);
-	ablkcipher_request_set_crypt(req, &src, &dst, PAGE_CACHE_SIZE,
-				     xts_tweak);
+	skcipher_request_set_crypt(req, &src, &dst, PAGE_CACHE_SIZE,
+				   xts_tweak);
 	if (rw == EXT4_DECRYPT)
-		res = crypto_ablkcipher_decrypt(req);
+		res = crypto_skcipher_decrypt(req);
 	else
-		res = crypto_ablkcipher_encrypt(req);
+		res = crypto_skcipher_encrypt(req);
 	if (res == -EINPROGRESS || res == -EBUSY) {
 		wait_for_completion(&ecr.completion);
 		res = ecr.res;
 	}
-	ablkcipher_request_free(req);
+	skcipher_request_free(req);
 	if (res) {
 		printk_ratelimited(
 			KERN_ERR
-			"%s: crypto_ablkcipher_encrypt() returned %d\n",
+			"%s: crypto_skcipher_encrypt() returned %d\n",
 			__func__, res);
 		return res;
 	}
diff --git a/fs/ext4/crypto_fname.c b/fs/ext4/crypto_fname.c
index 2fbef8a..1a2f360 100644
--- a/fs/ext4/crypto_fname.c
+++ b/fs/ext4/crypto_fname.c
@@ -11,11 +11,9 @@
  *
  */
 
-#include <crypto/hash.h>
-#include <crypto/sha.h>
+#include <crypto/skcipher.h>
 #include <keys/encrypted-type.h>
 #include <keys/user-type.h>
-#include <linux/crypto.h>
 #include <linux/gfp.h>
 #include <linux/kernel.h>
 #include <linux/key.h>
@@ -65,10 +63,10 @@ static int ext4_fname_encrypt(struct inode *inode,
 			      struct ext4_str *oname)
 {
 	u32 ciphertext_len;
-	struct ablkcipher_request *req = NULL;
+	struct skcipher_request *req = NULL;
 	DECLARE_EXT4_COMPLETION_RESULT(ecr);
 	struct ext4_crypt_info *ci = EXT4_I(inode)->i_crypt_info;
-	struct crypto_ablkcipher *tfm = ci->ci_ctfm;
+	struct crypto_skcipher *tfm = ci->ci_ctfm;
 	int res = 0;
 	char iv[EXT4_CRYPTO_BLOCK_SIZE];
 	struct scatterlist src_sg, dst_sg;
@@ -95,14 +93,14 @@ static int ext4_fname_encrypt(struct inode *inode,
 	}
 
 	/* Allocate request */
-	req = ablkcipher_request_alloc(tfm, GFP_NOFS);
+	req = skcipher_request_alloc(tfm, GFP_NOFS);
 	if (!req) {
 		printk_ratelimited(
 		    KERN_ERR "%s: crypto_request_alloc() failed\n", __func__);
 		kfree(alloc_buf);
 		return -ENOMEM;
 	}
-	ablkcipher_request_set_callback(req,
+	skcipher_request_set_callback(req,
 		CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
 		ext4_dir_crypt_complete, &ecr);
 
@@ -117,14 +115,14 @@ static int ext4_fname_encrypt(struct inode *inode,
 	/* Create encryption request */
 	sg_init_one(&src_sg, workbuf, ciphertext_len);
 	sg_init_one(&dst_sg, oname->name, ciphertext_len);
-	ablkcipher_request_set_crypt(req, &src_sg, &dst_sg, ciphertext_len, iv);
-	res = crypto_ablkcipher_encrypt(req);
+	skcipher_request_set_crypt(req, &src_sg, &dst_sg, ciphertext_len, iv);
+	res = crypto_skcipher_encrypt(req);
 	if (res == -EINPROGRESS || res == -EBUSY) {
 		wait_for_completion(&ecr.completion);
 		res = ecr.res;
 	}
 	kfree(alloc_buf);
-	ablkcipher_request_free(req);
+	skcipher_request_free(req);
 	if (res < 0) {
 		printk_ratelimited(
 		    KERN_ERR "%s: Error (error code %d)\n", __func__, res);
@@ -145,11 +143,11 @@ static int ext4_fname_decrypt(struct inode *inode,
 			      struct ext4_str *oname)
 {
 	struct ext4_str tmp_in[2], tmp_out[1];
-	struct ablkcipher_request *req = NULL;
+	struct skcipher_request *req = NULL;
 	DECLARE_EXT4_COMPLETION_RESULT(ecr);
 	struct scatterlist src_sg, dst_sg;
 	struct ext4_crypt_info *ci = EXT4_I(inode)->i_crypt_info;
-	struct crypto_ablkcipher *tfm = ci->ci_ctfm;
+	struct crypto_skcipher *tfm = ci->ci_ctfm;
 	int res = 0;
 	char iv[EXT4_CRYPTO_BLOCK_SIZE];
 	unsigned lim = max_name_len(inode);
@@ -162,13 +160,13 @@ static int ext4_fname_decrypt(struct inode *inode,
 	tmp_out[0].name = oname->name;
 
 	/* Allocate request */
-	req = ablkcipher_request_alloc(tfm, GFP_NOFS);
+	req = skcipher_request_alloc(tfm, GFP_NOFS);
 	if (!req) {
 		printk_ratelimited(
 		    KERN_ERR "%s: crypto_request_alloc() failed\n",  __func__);
 		return -ENOMEM;
 	}
-	ablkcipher_request_set_callback(req,
+	skcipher_request_set_callback(req,
 		CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
 		ext4_dir_crypt_complete, &ecr);
 
@@ -178,13 +176,13 @@ static int ext4_fname_decrypt(struct inode *inode,
 	/* Create encryption request */
 	sg_init_one(&src_sg, iname->name, iname->len);
 	sg_init_one(&dst_sg, oname->name, oname->len);
-	ablkcipher_request_set_crypt(req, &src_sg, &dst_sg, iname->len, iv);
-	res = crypto_ablkcipher_decrypt(req);
+	skcipher_request_set_crypt(req, &src_sg, &dst_sg, iname->len, iv);
+	res = crypto_skcipher_decrypt(req);
 	if (res == -EINPROGRESS || res == -EBUSY) {
 		wait_for_completion(&ecr.completion);
 		res = ecr.res;
 	}
-	ablkcipher_request_free(req);
+	skcipher_request_free(req);
 	if (res < 0) {
 		printk_ratelimited(
 		    KERN_ERR "%s: Error in ext4_fname_encrypt (error code %d)\n",
diff --git a/fs/ext4/crypto_key.c b/fs/ext4/crypto_key.c
index c5882b3..1b8bdbb 100644
--- a/fs/ext4/crypto_key.c
+++ b/fs/ext4/crypto_key.c
@@ -8,6 +8,7 @@
  * Written by Michael Halcrow, Ildar Muslukhov, and Uday Savagaonkar, 2015.
  */
 
+#include <crypto/skcipher.h>
 #include <keys/encrypted-type.h>
 #include <keys/user-type.h>
 #include <linux/random.h>
@@ -41,45 +42,42 @@ static int ext4_derive_key_aes(char deriving_key[EXT4_AES_128_ECB_KEY_SIZE],
 			       char derived_key[EXT4_AES_256_XTS_KEY_SIZE])
 {
 	int res = 0;
-	struct ablkcipher_request *req = NULL;
+	struct skcipher_request *req = NULL;
 	DECLARE_EXT4_COMPLETION_RESULT(ecr);
 	struct scatterlist src_sg, dst_sg;
-	struct crypto_ablkcipher *tfm = crypto_alloc_ablkcipher("ecb(aes)", 0,
-								0);
+	struct crypto_skcipher *tfm = crypto_alloc_skcipher("ecb(aes)", 0, 0);
 
 	if (IS_ERR(tfm)) {
 		res = PTR_ERR(tfm);
 		tfm = NULL;
 		goto out;
 	}
-	crypto_ablkcipher_set_flags(tfm, CRYPTO_TFM_REQ_WEAK_KEY);
-	req = ablkcipher_request_alloc(tfm, GFP_NOFS);
+	crypto_skcipher_set_flags(tfm, CRYPTO_TFM_REQ_WEAK_KEY);
+	req = skcipher_request_alloc(tfm, GFP_NOFS);
 	if (!req) {
 		res = -ENOMEM;
 		goto out;
 	}
-	ablkcipher_request_set_callback(req,
+	skcipher_request_set_callback(req,
 			CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
 			derive_crypt_complete, &ecr);
-	res = crypto_ablkcipher_setkey(tfm, deriving_key,
-				       EXT4_AES_128_ECB_KEY_SIZE);
+	res = crypto_skcipher_setkey(tfm, deriving_key,
+				     EXT4_AES_128_ECB_KEY_SIZE);
 	if (res < 0)
 		goto out;
 	sg_init_one(&src_sg, source_key, EXT4_AES_256_XTS_KEY_SIZE);
 	sg_init_one(&dst_sg, derived_key, EXT4_AES_256_XTS_KEY_SIZE);
-	ablkcipher_request_set_crypt(req, &src_sg, &dst_sg,
-				     EXT4_AES_256_XTS_KEY_SIZE, NULL);
-	res = crypto_ablkcipher_encrypt(req);
+	skcipher_request_set_crypt(req, &src_sg, &dst_sg,
+				   EXT4_AES_256_XTS_KEY_SIZE, NULL);
+	res = crypto_skcipher_encrypt(req);
 	if (res == -EINPROGRESS || res == -EBUSY) {
 		wait_for_completion(&ecr.completion);
 		res = ecr.res;
 	}
 
 out:
-	if (req)
-		ablkcipher_request_free(req);
-	if (tfm)
-		crypto_free_ablkcipher(tfm);
+	skcipher_request_free(req);
+	crypto_free_skcipher(tfm);
 	return res;
 }
 
@@ -90,7 +88,7 @@ void ext4_free_crypt_info(struct ext4_crypt_info *ci)
 
 	if (ci->ci_keyring_key)
 		key_put(ci->ci_keyring_key);
-	crypto_free_ablkcipher(ci->ci_ctfm);
+	crypto_free_skcipher(ci->ci_ctfm);
 	kmem_cache_free(ext4_crypt_info_cachep, ci);
 }
 
@@ -122,7 +120,7 @@ int _ext4_get_encryption_info(struct inode *inode)
 	struct ext4_encryption_context ctx;
 	const struct user_key_payload *ukp;
 	struct ext4_sb_info *sbi = EXT4_SB(inode->i_sb);
-	struct crypto_ablkcipher *ctfm;
+	struct crypto_skcipher *ctfm;
 	const char *cipher_str;
 	char raw_key[EXT4_MAX_KEY_SIZE];
 	char mode;
@@ -233,7 +231,7 @@ retry:
 	if (res)
 		goto out;
 got_key:
-	ctfm = crypto_alloc_ablkcipher(cipher_str, 0, 0);
+	ctfm = crypto_alloc_skcipher(cipher_str, 0, 0);
 	if (!ctfm || IS_ERR(ctfm)) {
 		res = ctfm ? PTR_ERR(ctfm) : -ENOMEM;
 		printk(KERN_DEBUG
@@ -242,11 +240,11 @@ got_key:
 		goto out;
 	}
 	crypt_info->ci_ctfm = ctfm;
-	crypto_ablkcipher_clear_flags(ctfm, ~0);
-	crypto_tfm_set_flags(crypto_ablkcipher_tfm(ctfm),
+	crypto_skcipher_clear_flags(ctfm, ~0);
+	crypto_tfm_set_flags(crypto_skcipher_tfm(ctfm),
 			     CRYPTO_TFM_REQ_WEAK_KEY);
-	res = crypto_ablkcipher_setkey(ctfm, raw_key,
-				       ext4_encryption_key_size(mode));
+	res = crypto_skcipher_setkey(ctfm, raw_key,
+				     ext4_encryption_key_size(mode));
 	if (res)
 		goto out;
 	memzero_explicit(raw_key, sizeof(raw_key));
diff --git a/fs/ext4/ext4_crypto.h b/fs/ext4/ext4_crypto.h
index ac7d4e8..1f73c29 100644
--- a/fs/ext4/ext4_crypto.h
+++ b/fs/ext4/ext4_crypto.h
@@ -77,7 +77,7 @@ struct ext4_crypt_info {
 	char		ci_data_mode;
 	char		ci_filename_mode;
 	char		ci_flags;
-	struct crypto_ablkcipher *ci_ctfm;
+	struct crypto_skcipher *ci_ctfm;
 	struct key	*ci_keyring_key;
 	char		ci_master_key[EXT4_KEY_DESCRIPTOR_SIZE];
 };
