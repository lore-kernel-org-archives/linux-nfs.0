Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:60865 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754630AbcAXNS0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:18:26 -0500
Subject: [PATCH 11/26] f2fs: Use skcipher
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
Message-Id: <E1aNKY9-0008Ch-75@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:17:49 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of ablkcipher with skcipher.
   
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 fs/f2fs/crypto.c       |   24 +++++++++++-------------
 fs/f2fs/crypto_fname.c |   32 +++++++++++++++-----------------
 fs/f2fs/crypto_key.c   |   40 ++++++++++++++++++----------------------
 fs/f2fs/f2fs_crypto.h  |    2 +-
 4 files changed, 45 insertions(+), 53 deletions(-)

diff --git a/fs/f2fs/crypto.c b/fs/f2fs/crypto.c
index 4a62ef1..95c5cf0 100644
--- a/fs/f2fs/crypto.c
+++ b/fs/f2fs/crypto.c
@@ -23,11 +23,9 @@
  * The usage of AES-XTS should conform to recommendations in NIST
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
@@ -328,21 +326,21 @@ static int f2fs_page_crypto(struct f2fs_crypto_ctx *ctx,
 				struct page *dest_page)
 {
 	u8 xts_tweak[F2FS_XTS_TWEAK_SIZE];
-	struct ablkcipher_request *req = NULL;
+	struct skcipher_request *req = NULL;
 	DECLARE_F2FS_COMPLETION_RESULT(ecr);
 	struct scatterlist dst, src;
 	struct f2fs_crypt_info *ci = F2FS_I(inode)->i_crypt_info;
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
 		f2fs_crypt_complete, &ecr);
 
@@ -355,21 +353,21 @@ static int f2fs_page_crypto(struct f2fs_crypto_ctx *ctx,
 	sg_set_page(&dst, dest_page, PAGE_CACHE_SIZE, 0);
 	sg_init_table(&src, 1);
 	sg_set_page(&src, src_page, PAGE_CACHE_SIZE, 0);
-	ablkcipher_request_set_crypt(req, &src, &dst, PAGE_CACHE_SIZE,
-					xts_tweak);
+	skcipher_request_set_crypt(req, &src, &dst, PAGE_CACHE_SIZE,
+				   xts_tweak);
 	if (rw == F2FS_DECRYPT)
-		res = crypto_ablkcipher_decrypt(req);
+		res = crypto_skcipher_decrypt(req);
 	else
-		res = crypto_ablkcipher_encrypt(req);
+		res = crypto_skcipher_encrypt(req);
 	if (res == -EINPROGRESS || res == -EBUSY) {
 		BUG_ON(req->base.data != &ecr);
 		wait_for_completion(&ecr.completion);
 		res = ecr.res;
 	}
-	ablkcipher_request_free(req);
+	skcipher_request_free(req);
 	if (res) {
 		printk_ratelimited(KERN_ERR
-			"%s: crypto_ablkcipher_encrypt() returned %d\n",
+			"%s: crypto_skcipher_encrypt() returned %d\n",
 			__func__, res);
 		return res;
 	}
diff --git a/fs/f2fs/crypto_fname.c b/fs/f2fs/crypto_fname.c
index ab377d4..16aec66 100644
--- a/fs/f2fs/crypto_fname.c
+++ b/fs/f2fs/crypto_fname.c
@@ -15,11 +15,9 @@
  *
  * This has not yet undergone a rigorous security audit.
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
@@ -70,10 +68,10 @@ static int f2fs_fname_encrypt(struct inode *inode,
 			const struct qstr *iname, struct f2fs_str *oname)
 {
 	u32 ciphertext_len;
-	struct ablkcipher_request *req = NULL;
+	struct skcipher_request *req = NULL;
 	DECLARE_F2FS_COMPLETION_RESULT(ecr);
 	struct f2fs_crypt_info *ci = F2FS_I(inode)->i_crypt_info;
-	struct crypto_ablkcipher *tfm = ci->ci_ctfm;
+	struct crypto_skcipher *tfm = ci->ci_ctfm;
 	int res = 0;
 	char iv[F2FS_CRYPTO_BLOCK_SIZE];
 	struct scatterlist src_sg, dst_sg;
@@ -99,14 +97,14 @@ static int f2fs_fname_encrypt(struct inode *inode,
 	}
 
 	/* Allocate request */
-	req = ablkcipher_request_alloc(tfm, GFP_NOFS);
+	req = skcipher_request_alloc(tfm, GFP_NOFS);
 	if (!req) {
 		printk_ratelimited(KERN_ERR
 			"%s: crypto_request_alloc() failed\n", __func__);
 		kfree(alloc_buf);
 		return -ENOMEM;
 	}
-	ablkcipher_request_set_callback(req,
+	skcipher_request_set_callback(req,
 			CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
 			f2fs_dir_crypt_complete, &ecr);
 
@@ -121,15 +119,15 @@ static int f2fs_fname_encrypt(struct inode *inode,
 	/* Create encryption request */
 	sg_init_one(&src_sg, workbuf, ciphertext_len);
 	sg_init_one(&dst_sg, oname->name, ciphertext_len);
-	ablkcipher_request_set_crypt(req, &src_sg, &dst_sg, ciphertext_len, iv);
-	res = crypto_ablkcipher_encrypt(req);
+	skcipher_request_set_crypt(req, &src_sg, &dst_sg, ciphertext_len, iv);
+	res = crypto_skcipher_encrypt(req);
 	if (res == -EINPROGRESS || res == -EBUSY) {
 		BUG_ON(req->base.data != &ecr);
 		wait_for_completion(&ecr.completion);
 		res = ecr.res;
 	}
 	kfree(alloc_buf);
-	ablkcipher_request_free(req);
+	skcipher_request_free(req);
 	if (res < 0) {
 		printk_ratelimited(KERN_ERR
 				"%s: Error (error code %d)\n", __func__, res);
@@ -148,11 +146,11 @@ static int f2fs_fname_encrypt(struct inode *inode,
 static int f2fs_fname_decrypt(struct inode *inode,
 			const struct f2fs_str *iname, struct f2fs_str *oname)
 {
-	struct ablkcipher_request *req = NULL;
+	struct skcipher_request *req = NULL;
 	DECLARE_F2FS_COMPLETION_RESULT(ecr);
 	struct scatterlist src_sg, dst_sg;
 	struct f2fs_crypt_info *ci = F2FS_I(inode)->i_crypt_info;
-	struct crypto_ablkcipher *tfm = ci->ci_ctfm;
+	struct crypto_skcipher *tfm = ci->ci_ctfm;
 	int res = 0;
 	char iv[F2FS_CRYPTO_BLOCK_SIZE];
 	unsigned lim = max_name_len(inode);
@@ -161,13 +159,13 @@ static int f2fs_fname_decrypt(struct inode *inode,
 		return -EIO;
 
 	/* Allocate request */
-	req = ablkcipher_request_alloc(tfm, GFP_NOFS);
+	req = skcipher_request_alloc(tfm, GFP_NOFS);
 	if (!req) {
 		printk_ratelimited(KERN_ERR
 			"%s: crypto_request_alloc() failed\n",  __func__);
 		return -ENOMEM;
 	}
-	ablkcipher_request_set_callback(req,
+	skcipher_request_set_callback(req,
 		CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
 		f2fs_dir_crypt_complete, &ecr);
 
@@ -177,14 +175,14 @@ static int f2fs_fname_decrypt(struct inode *inode,
 	/* Create decryption request */
 	sg_init_one(&src_sg, iname->name, iname->len);
 	sg_init_one(&dst_sg, oname->name, oname->len);
-	ablkcipher_request_set_crypt(req, &src_sg, &dst_sg, iname->len, iv);
-	res = crypto_ablkcipher_decrypt(req);
+	skcipher_request_set_crypt(req, &src_sg, &dst_sg, iname->len, iv);
+	res = crypto_skcipher_decrypt(req);
 	if (res == -EINPROGRESS || res == -EBUSY) {
 		BUG_ON(req->base.data != &ecr);
 		wait_for_completion(&ecr.completion);
 		res = ecr.res;
 	}
-	ablkcipher_request_free(req);
+	skcipher_request_free(req);
 	if (res < 0) {
 		printk_ratelimited(KERN_ERR
 			"%s: Error in f2fs_fname_decrypt (error code %d)\n",
diff --git a/fs/f2fs/crypto_key.c b/fs/f2fs/crypto_key.c
index 5de2d86..2aeb627 100644
--- a/fs/f2fs/crypto_key.c
+++ b/fs/f2fs/crypto_key.c
@@ -14,7 +14,7 @@
 #include <linux/random.h>
 #include <linux/scatterlist.h>
 #include <uapi/linux/keyctl.h>
-#include <crypto/hash.h>
+#include <crypto/skcipher.h>
 #include <linux/f2fs_fs.h>
 
 #include "f2fs.h"
@@ -44,46 +44,43 @@ static int f2fs_derive_key_aes(char deriving_key[F2FS_AES_128_ECB_KEY_SIZE],
 				char derived_key[F2FS_AES_256_XTS_KEY_SIZE])
 {
 	int res = 0;
-	struct ablkcipher_request *req = NULL;
+	struct skcipher_request *req = NULL;
 	DECLARE_F2FS_COMPLETION_RESULT(ecr);
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
+	res = crypto_skcipher_setkey(tfm, deriving_key,
 				F2FS_AES_128_ECB_KEY_SIZE);
 	if (res < 0)
 		goto out;
 
 	sg_init_one(&src_sg, source_key, F2FS_AES_256_XTS_KEY_SIZE);
 	sg_init_one(&dst_sg, derived_key, F2FS_AES_256_XTS_KEY_SIZE);
-	ablkcipher_request_set_crypt(req, &src_sg, &dst_sg,
+	skcipher_request_set_crypt(req, &src_sg, &dst_sg,
 					F2FS_AES_256_XTS_KEY_SIZE, NULL);
-	res = crypto_ablkcipher_encrypt(req);
+	res = crypto_skcipher_encrypt(req);
 	if (res == -EINPROGRESS || res == -EBUSY) {
 		BUG_ON(req->base.data != &ecr);
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
 
@@ -93,7 +90,7 @@ static void f2fs_free_crypt_info(struct f2fs_crypt_info *ci)
 		return;
 
 	key_put(ci->ci_keyring_key);
-	crypto_free_ablkcipher(ci->ci_ctfm);
+	crypto_free_skcipher(ci->ci_ctfm);
 	kmem_cache_free(f2fs_crypt_info_cachep, ci);
 }
 
@@ -123,7 +120,7 @@ int _f2fs_get_encryption_info(struct inode *inode)
 	struct f2fs_encryption_key *master_key;
 	struct f2fs_encryption_context ctx;
 	const struct user_key_payload *ukp;
-	struct crypto_ablkcipher *ctfm;
+	struct crypto_skcipher *ctfm;
 	const char *cipher_str;
 	char raw_key[F2FS_MAX_KEY_SIZE];
 	char mode;
@@ -213,7 +210,7 @@ retry:
 	if (res)
 		goto out;
 
-	ctfm = crypto_alloc_ablkcipher(cipher_str, 0, 0);
+	ctfm = crypto_alloc_skcipher(cipher_str, 0, 0);
 	if (!ctfm || IS_ERR(ctfm)) {
 		res = ctfm ? PTR_ERR(ctfm) : -ENOMEM;
 		printk(KERN_DEBUG
@@ -222,11 +219,10 @@ retry:
 		goto out;
 	}
 	crypt_info->ci_ctfm = ctfm;
-	crypto_ablkcipher_clear_flags(ctfm, ~0);
-	crypto_tfm_set_flags(crypto_ablkcipher_tfm(ctfm),
-			     CRYPTO_TFM_REQ_WEAK_KEY);
-	res = crypto_ablkcipher_setkey(ctfm, raw_key,
-					f2fs_encryption_key_size(mode));
+	crypto_skcipher_clear_flags(ctfm, ~0);
+	crypto_skcipher_set_flags(ctfm, CRYPTO_TFM_REQ_WEAK_KEY);
+	res = crypto_skcipher_setkey(ctfm, raw_key,
+				     f2fs_encryption_key_size(mode));
 	if (res)
 		goto out;
 
diff --git a/fs/f2fs/f2fs_crypto.h b/fs/f2fs/f2fs_crypto.h
index c2c1c2b..ea3d1d7 100644
--- a/fs/f2fs/f2fs_crypto.h
+++ b/fs/f2fs/f2fs_crypto.h
@@ -78,7 +78,7 @@ struct f2fs_crypt_info {
 	char		ci_data_mode;
 	char		ci_filename_mode;
 	char		ci_flags;
-	struct crypto_ablkcipher *ci_ctfm;
+	struct crypto_skcipher *ci_ctfm;
 	struct key	*ci_keyring_key;
 	char		ci_master_key[F2FS_KEY_DESCRIPTOR_SIZE];
 };
