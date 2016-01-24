Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:50249 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517AbcAXNSI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:18:08 -0500
Subject: [PATCH 9/26] eCryptfs: Use skcipher and shash
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
Message-Id: <E1aNKXo-0008C9-F9@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:17:28 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of ablkcipher and blkcipher with skcipher,
and the long obsolete hash interface with shash.
   
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 fs/ecryptfs/crypto.c          |  107 +++++++++-----------
 fs/ecryptfs/ecryptfs_kernel.h |   12 +-
 fs/ecryptfs/inode.c           |    1 
 fs/ecryptfs/keystore.c        |  217 ++++++++++++++++++++++++------------------
 fs/ecryptfs/main.c            |    1 
 fs/ecryptfs/mmap.c            |    1 
 fs/ecryptfs/super.c           |    1 
 7 files changed, 179 insertions(+), 161 deletions(-)

diff --git a/fs/ecryptfs/crypto.c b/fs/ecryptfs/crypto.c
index 80d6901..11255cb 100644
--- a/fs/ecryptfs/crypto.c
+++ b/fs/ecryptfs/crypto.c
@@ -23,6 +23,8 @@
  * 02111-1307, USA.
  */
 
+#include <crypto/hash.h>
+#include <crypto/skcipher.h>
 #include <linux/fs.h>
 #include <linux/mount.h>
 #include <linux/pagemap.h>
@@ -30,7 +32,6 @@
 #include <linux/compiler.h>
 #include <linux/key.h>
 #include <linux/namei.h>
-#include <linux/crypto.h>
 #include <linux/file.h>
 #include <linux/scatterlist.h>
 #include <linux/slab.h>
@@ -74,6 +75,19 @@ void ecryptfs_from_hex(char *dst, char *src, int dst_size)
 	}
 }
 
+static int ecryptfs_hash_digest(struct crypto_shash *tfm,
+				char *src, int len, char *dst)
+{
+	SHASH_DESC_ON_STACK(desc, tfm);
+	int err;
+
+	desc->tfm = tfm;
+	desc->flags = CRYPTO_TFM_REQ_MAY_SLEEP;
+	err = crypto_shash_digest(desc, src, len, dst);
+	shash_desc_zero(desc);
+	return err;
+}
+
 /**
  * ecryptfs_calculate_md5 - calculates the md5 of @src
  * @dst: Pointer to 16 bytes of allocated memory
@@ -88,45 +102,26 @@ static int ecryptfs_calculate_md5(char *dst,
 				  struct ecryptfs_crypt_stat *crypt_stat,
 				  char *src, int len)
 {
-	struct scatterlist sg;
-	struct hash_desc desc = {
-		.tfm = crypt_stat->hash_tfm,
-		.flags = CRYPTO_TFM_REQ_MAY_SLEEP
-	};
+	struct crypto_shash *tfm;
 	int rc = 0;
 
 	mutex_lock(&crypt_stat->cs_hash_tfm_mutex);
-	sg_init_one(&sg, (u8 *)src, len);
-	if (!desc.tfm) {
-		desc.tfm = crypto_alloc_hash(ECRYPTFS_DEFAULT_HASH, 0,
-					     CRYPTO_ALG_ASYNC);
-		if (IS_ERR(desc.tfm)) {
-			rc = PTR_ERR(desc.tfm);
+	tfm = crypt_stat->hash_tfm;
+	if (!tfm) {
+		tfm = crypto_alloc_shash(ECRYPTFS_DEFAULT_HASH, 0, 0);
+		if (IS_ERR(tfm)) {
+			rc = PTR_ERR(tfm);
 			ecryptfs_printk(KERN_ERR, "Error attempting to "
 					"allocate crypto context; rc = [%d]\n",
 					rc);
 			goto out;
 		}
-		crypt_stat->hash_tfm = desc.tfm;
-	}
-	rc = crypto_hash_init(&desc);
-	if (rc) {
-		printk(KERN_ERR
-		       "%s: Error initializing crypto hash; rc = [%d]\n",
-		       __func__, rc);
-		goto out;
+		crypt_stat->hash_tfm = tfm;
 	}
-	rc = crypto_hash_update(&desc, &sg, len);
+	rc = ecryptfs_hash_digest(tfm, src, len, dst);
 	if (rc) {
 		printk(KERN_ERR
-		       "%s: Error updating crypto hash; rc = [%d]\n",
-		       __func__, rc);
-		goto out;
-	}
-	rc = crypto_hash_final(&desc, dst);
-	if (rc) {
-		printk(KERN_ERR
-		       "%s: Error finalizing crypto hash; rc = [%d]\n",
+		       "%s: Error computing crypto hash; rc = [%d]\n",
 		       __func__, rc);
 		goto out;
 	}
@@ -234,10 +229,8 @@ void ecryptfs_destroy_crypt_stat(struct ecryptfs_crypt_stat *crypt_stat)
 {
 	struct ecryptfs_key_sig *key_sig, *key_sig_tmp;
 
-	if (crypt_stat->tfm)
-		crypto_free_ablkcipher(crypt_stat->tfm);
-	if (crypt_stat->hash_tfm)
-		crypto_free_hash(crypt_stat->hash_tfm);
+	crypto_free_skcipher(crypt_stat->tfm);
+	crypto_free_shash(crypt_stat->hash_tfm);
 	list_for_each_entry_safe(key_sig, key_sig_tmp,
 				 &crypt_stat->keysig_list, crypt_stat_list) {
 		list_del(&key_sig->crypt_stat_list);
@@ -342,7 +335,7 @@ static int crypt_scatterlist(struct ecryptfs_crypt_stat *crypt_stat,
 			     struct scatterlist *src_sg, int size,
 			     unsigned char *iv, int op)
 {
-	struct ablkcipher_request *req = NULL;
+	struct skcipher_request *req = NULL;
 	struct extent_crypt_result ecr;
 	int rc = 0;
 
@@ -358,20 +351,20 @@ static int crypt_scatterlist(struct ecryptfs_crypt_stat *crypt_stat,
 	init_completion(&ecr.completion);
 
 	mutex_lock(&crypt_stat->cs_tfm_mutex);
-	req = ablkcipher_request_alloc(crypt_stat->tfm, GFP_NOFS);
+	req = skcipher_request_alloc(crypt_stat->tfm, GFP_NOFS);
 	if (!req) {
 		mutex_unlock(&crypt_stat->cs_tfm_mutex);
 		rc = -ENOMEM;
 		goto out;
 	}
 
-	ablkcipher_request_set_callback(req,
+	skcipher_request_set_callback(req,
 			CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
 			extent_crypt_complete, &ecr);
 	/* Consider doing this once, when the file is opened */
 	if (!(crypt_stat->flags & ECRYPTFS_KEY_SET)) {
-		rc = crypto_ablkcipher_setkey(crypt_stat->tfm, crypt_stat->key,
-					      crypt_stat->key_size);
+		rc = crypto_skcipher_setkey(crypt_stat->tfm, crypt_stat->key,
+					    crypt_stat->key_size);
 		if (rc) {
 			ecryptfs_printk(KERN_ERR,
 					"Error setting key; rc = [%d]\n",
@@ -383,9 +376,9 @@ static int crypt_scatterlist(struct ecryptfs_crypt_stat *crypt_stat,
 		crypt_stat->flags |= ECRYPTFS_KEY_SET;
 	}
 	mutex_unlock(&crypt_stat->cs_tfm_mutex);
-	ablkcipher_request_set_crypt(req, src_sg, dst_sg, size, iv);
-	rc = op == ENCRYPT ? crypto_ablkcipher_encrypt(req) :
-			     crypto_ablkcipher_decrypt(req);
+	skcipher_request_set_crypt(req, src_sg, dst_sg, size, iv);
+	rc = op == ENCRYPT ? crypto_skcipher_encrypt(req) :
+			     crypto_skcipher_decrypt(req);
 	if (rc == -EINPROGRESS || rc == -EBUSY) {
 		struct extent_crypt_result *ecr = req->base.data;
 
@@ -394,7 +387,7 @@ static int crypt_scatterlist(struct ecryptfs_crypt_stat *crypt_stat,
 		reinit_completion(&ecr->completion);
 	}
 out:
-	ablkcipher_request_free(req);
+	skcipher_request_free(req);
 	return rc;
 }
 
@@ -622,7 +615,7 @@ int ecryptfs_init_crypt_ctx(struct ecryptfs_crypt_stat *crypt_stat)
 						    crypt_stat->cipher, "cbc");
 	if (rc)
 		goto out_unlock;
-	crypt_stat->tfm = crypto_alloc_ablkcipher(full_alg_name, 0, 0);
+	crypt_stat->tfm = crypto_alloc_skcipher(full_alg_name, 0, 0);
 	if (IS_ERR(crypt_stat->tfm)) {
 		rc = PTR_ERR(crypt_stat->tfm);
 		crypt_stat->tfm = NULL;
@@ -631,7 +624,7 @@ int ecryptfs_init_crypt_ctx(struct ecryptfs_crypt_stat *crypt_stat)
 				full_alg_name);
 		goto out_free;
 	}
-	crypto_ablkcipher_set_flags(crypt_stat->tfm, CRYPTO_TFM_REQ_WEAK_KEY);
+	crypto_skcipher_set_flags(crypt_stat->tfm, CRYPTO_TFM_REQ_WEAK_KEY);
 	rc = 0;
 out_free:
 	kfree(full_alg_name);
@@ -1591,7 +1584,7 @@ out:
  * event, regardless of whether this function succeeds for fails.
  */
 static int
-ecryptfs_process_key_cipher(struct crypto_blkcipher **key_tfm,
+ecryptfs_process_key_cipher(struct crypto_skcipher **key_tfm,
 			    char *cipher_name, size_t *key_size)
 {
 	char dummy_key[ECRYPTFS_MAX_KEY_BYTES];
@@ -1609,21 +1602,18 @@ ecryptfs_process_key_cipher(struct crypto_blkcipher **key_tfm,
 						    "ecb");
 	if (rc)
 		goto out;
-	*key_tfm = crypto_alloc_blkcipher(full_alg_name, 0, CRYPTO_ALG_ASYNC);
+	*key_tfm = crypto_alloc_skcipher(full_alg_name, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(*key_tfm)) {
 		rc = PTR_ERR(*key_tfm);
 		printk(KERN_ERR "Unable to allocate crypto cipher with name "
 		       "[%s]; rc = [%d]\n", full_alg_name, rc);
 		goto out;
 	}
-	crypto_blkcipher_set_flags(*key_tfm, CRYPTO_TFM_REQ_WEAK_KEY);
-	if (*key_size == 0) {
-		struct blkcipher_alg *alg = crypto_blkcipher_alg(*key_tfm);
-
-		*key_size = alg->max_keysize;
-	}
+	crypto_skcipher_set_flags(*key_tfm, CRYPTO_TFM_REQ_WEAK_KEY);
+	if (*key_size == 0)
+		*key_size = crypto_skcipher_default_keysize(*key_tfm);
 	get_random_bytes(dummy_key, *key_size);
-	rc = crypto_blkcipher_setkey(*key_tfm, dummy_key, *key_size);
+	rc = crypto_skcipher_setkey(*key_tfm, dummy_key, *key_size);
 	if (rc) {
 		printk(KERN_ERR "Error attempting to set key of size [%zd] for "
 		       "cipher [%s]; rc = [%d]\n", *key_size, full_alg_name,
@@ -1660,8 +1650,7 @@ int ecryptfs_destroy_crypto(void)
 	list_for_each_entry_safe(key_tfm, key_tfm_tmp, &key_tfm_list,
 				 key_tfm_list) {
 		list_del(&key_tfm->key_tfm_list);
-		if (key_tfm->key_tfm)
-			crypto_free_blkcipher(key_tfm->key_tfm);
+		crypto_free_skcipher(key_tfm->key_tfm);
 		kmem_cache_free(ecryptfs_key_tfm_cache, key_tfm);
 	}
 	mutex_unlock(&key_tfm_list_mutex);
@@ -1747,7 +1736,7 @@ int ecryptfs_tfm_exists(char *cipher_name, struct ecryptfs_key_tfm **key_tfm)
  * Searches for cached item first, and creates new if not found.
  * Returns 0 on success, non-zero if adding new cipher failed
  */
-int ecryptfs_get_tfm_and_mutex_for_cipher_name(struct crypto_blkcipher **tfm,
+int ecryptfs_get_tfm_and_mutex_for_cipher_name(struct crypto_skcipher **tfm,
 					       struct mutex **tfm_mutex,
 					       char *cipher_name)
 {
@@ -2120,7 +2109,7 @@ out:
 int ecryptfs_set_f_namelen(long *namelen, long lower_namelen,
 			   struct ecryptfs_mount_crypt_stat *mount_crypt_stat)
 {
-	struct blkcipher_desc desc;
+	struct crypto_skcipher *tfm;
 	struct mutex *tfm_mutex;
 	size_t cipher_blocksize;
 	int rc;
@@ -2130,7 +2119,7 @@ int ecryptfs_set_f_namelen(long *namelen, long lower_namelen,
 		return 0;
 	}
 
-	rc = ecryptfs_get_tfm_and_mutex_for_cipher_name(&desc.tfm, &tfm_mutex,
+	rc = ecryptfs_get_tfm_and_mutex_for_cipher_name(&tfm, &tfm_mutex,
 			mount_crypt_stat->global_default_fn_cipher_name);
 	if (unlikely(rc)) {
 		(*namelen) = 0;
@@ -2138,7 +2127,7 @@ int ecryptfs_set_f_namelen(long *namelen, long lower_namelen,
 	}
 
 	mutex_lock(tfm_mutex);
-	cipher_blocksize = crypto_blkcipher_blocksize(desc.tfm);
+	cipher_blocksize = crypto_skcipher_blocksize(tfm);
 	mutex_unlock(tfm_mutex);
 
 	/* Return an exact amount for the common cases */
diff --git a/fs/ecryptfs/ecryptfs_kernel.h b/fs/ecryptfs/ecryptfs_kernel.h
index 7b39260..b7f8128 100644
--- a/fs/ecryptfs/ecryptfs_kernel.h
+++ b/fs/ecryptfs/ecryptfs_kernel.h
@@ -28,6 +28,7 @@
 #ifndef ECRYPTFS_KERNEL_H
 #define ECRYPTFS_KERNEL_H
 
+#include <crypto/skcipher.h>
 #include <keys/user-type.h>
 #include <keys/encrypted-type.h>
 #include <linux/fs.h>
@@ -38,7 +39,6 @@
 #include <linux/nsproxy.h>
 #include <linux/backing-dev.h>
 #include <linux/ecryptfs.h>
-#include <linux/crypto.h>
 
 #define ECRYPTFS_DEFAULT_IV_BYTES 16
 #define ECRYPTFS_DEFAULT_EXTENT_SIZE 4096
@@ -233,9 +233,9 @@ struct ecryptfs_crypt_stat {
 	size_t extent_shift;
 	unsigned int extent_mask;
 	struct ecryptfs_mount_crypt_stat *mount_crypt_stat;
-	struct crypto_ablkcipher *tfm;
-	struct crypto_hash *hash_tfm; /* Crypto context for generating
-				       * the initialization vectors */
+	struct crypto_skcipher *tfm;
+	struct crypto_shash *hash_tfm; /* Crypto context for generating
+					* the initialization vectors */
 	unsigned char cipher[ECRYPTFS_MAX_CIPHER_NAME_SIZE + 1];
 	unsigned char key[ECRYPTFS_MAX_KEY_BYTES];
 	unsigned char root_iv[ECRYPTFS_MAX_IV_BYTES];
@@ -309,7 +309,7 @@ struct ecryptfs_global_auth_tok {
  * keeps a list of crypto API contexts around to use when needed.
  */
 struct ecryptfs_key_tfm {
-	struct crypto_blkcipher *key_tfm;
+	struct crypto_skcipher *key_tfm;
 	size_t key_size;
 	struct mutex key_tfm_mutex;
 	struct list_head key_tfm_list;
@@ -659,7 +659,7 @@ ecryptfs_add_new_key_tfm(struct ecryptfs_key_tfm **key_tfm, char *cipher_name,
 int ecryptfs_init_crypto(void);
 int ecryptfs_destroy_crypto(void);
 int ecryptfs_tfm_exists(char *cipher_name, struct ecryptfs_key_tfm **key_tfm);
-int ecryptfs_get_tfm_and_mutex_for_cipher_name(struct crypto_blkcipher **tfm,
+int ecryptfs_get_tfm_and_mutex_for_cipher_name(struct crypto_skcipher **tfm,
 					       struct mutex **tfm_mutex,
 					       char *cipher_name);
 int ecryptfs_keyring_auth_tok_for_sig(struct key **auth_tok_key,
diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index 040aa87..ed74d80 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -29,7 +29,6 @@
 #include <linux/dcache.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
-#include <linux/crypto.h>
 #include <linux/fs_stack.h>
 #include <linux/slab.h>
 #include <linux/xattr.h>
diff --git a/fs/ecryptfs/keystore.c b/fs/ecryptfs/keystore.c
index 6bd67e2..ea08b3c 100644
--- a/fs/ecryptfs/keystore.c
+++ b/fs/ecryptfs/keystore.c
@@ -25,11 +25,12 @@
  * 02111-1307, USA.
  */
 
+#include <crypto/hash.h>
+#include <crypto/skcipher.h>
 #include <linux/string.h>
 #include <linux/pagemap.h>
 #include <linux/key.h>
 #include <linux/random.h>
-#include <linux/crypto.h>
 #include <linux/scatterlist.h>
 #include <linux/slab.h>
 #include "ecryptfs_kernel.h"
@@ -601,12 +602,13 @@ struct ecryptfs_write_tag_70_packet_silly_stack {
 	struct ecryptfs_auth_tok *auth_tok;
 	struct scatterlist src_sg[2];
 	struct scatterlist dst_sg[2];
-	struct blkcipher_desc desc;
+	struct crypto_skcipher *skcipher_tfm;
+	struct skcipher_request *skcipher_req;
 	char iv[ECRYPTFS_MAX_IV_BYTES];
 	char hash[ECRYPTFS_TAG_70_DIGEST_SIZE];
 	char tmp_hash[ECRYPTFS_TAG_70_DIGEST_SIZE];
-	struct hash_desc hash_desc;
-	struct scatterlist hash_sg;
+	struct crypto_shash *hash_tfm;
+	struct shash_desc *hash_desc;
 };
 
 /**
@@ -629,14 +631,13 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *remaining_bytes,
 	struct key *auth_tok_key = NULL;
 	int rc = 0;
 
-	s = kmalloc(sizeof(*s), GFP_KERNEL);
+	s = kzalloc(sizeof(*s), GFP_KERNEL);
 	if (!s) {
 		printk(KERN_ERR "%s: Out of memory whilst trying to kmalloc "
 		       "[%zd] bytes of kernel memory\n", __func__, sizeof(*s));
 		rc = -ENOMEM;
 		goto out;
 	}
-	s->desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
 	(*packet_size) = 0;
 	rc = ecryptfs_find_auth_tok_for_sig(
 		&auth_tok_key,
@@ -649,7 +650,7 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *remaining_bytes,
 		goto out;
 	}
 	rc = ecryptfs_get_tfm_and_mutex_for_cipher_name(
-		&s->desc.tfm,
+		&s->skcipher_tfm,
 		&s->tfm_mutex, mount_crypt_stat->global_default_fn_cipher_name);
 	if (unlikely(rc)) {
 		printk(KERN_ERR "Internal error whilst attempting to get "
@@ -658,7 +659,7 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *remaining_bytes,
 		goto out;
 	}
 	mutex_lock(s->tfm_mutex);
-	s->block_size = crypto_blkcipher_blocksize(s->desc.tfm);
+	s->block_size = crypto_skcipher_blocksize(s->skcipher_tfm);
 	/* Plus one for the \0 separator between the random prefix
 	 * and the plaintext filename */
 	s->num_rand_bytes = (ECRYPTFS_FILENAME_MIN_RANDOM_PREPEND_BYTES + 1);
@@ -691,6 +692,19 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *remaining_bytes,
 		rc = -EINVAL;
 		goto out_unlock;
 	}
+
+	s->skcipher_req = skcipher_request_alloc(s->skcipher_tfm, GFP_KERNEL);
+	if (!s->skcipher_req) {
+		printk(KERN_ERR "%s: Out of kernel memory whilst attempting to "
+		       "skcipher_request_alloc for %s\n", __func__,
+		       crypto_skcipher_driver_name(s->skcipher_tfm));
+		rc = -ENOMEM;
+		goto out_unlock;
+	}
+
+	skcipher_request_set_callback(s->skcipher_req,
+				      CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
+
 	s->block_aligned_filename = kzalloc(s->block_aligned_filename_size,
 					    GFP_KERNEL);
 	if (!s->block_aligned_filename) {
@@ -700,7 +714,6 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *remaining_bytes,
 		rc = -ENOMEM;
 		goto out_unlock;
 	}
-	s->i = 0;
 	dest[s->i++] = ECRYPTFS_TAG_70_PACKET_TYPE;
 	rc = ecryptfs_write_packet_length(&dest[s->i],
 					  (ECRYPTFS_SIG_SIZE
@@ -738,40 +751,36 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *remaining_bytes,
 		       "password tokens\n", __func__);
 		goto out_free_unlock;
 	}
-	sg_init_one(
-		&s->hash_sg,
-		(u8 *)s->auth_tok->token.password.session_key_encryption_key,
-		s->auth_tok->token.password.session_key_encryption_key_bytes);
-	s->hash_desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
-	s->hash_desc.tfm = crypto_alloc_hash(ECRYPTFS_TAG_70_DIGEST, 0,
-					     CRYPTO_ALG_ASYNC);
-	if (IS_ERR(s->hash_desc.tfm)) {
-			rc = PTR_ERR(s->hash_desc.tfm);
+	s->hash_tfm = crypto_alloc_shash(ECRYPTFS_TAG_70_DIGEST, 0, 0);
+	if (IS_ERR(s->hash_tfm)) {
+			rc = PTR_ERR(s->hash_tfm);
 			printk(KERN_ERR "%s: Error attempting to "
 			       "allocate hash crypto context; rc = [%d]\n",
 			       __func__, rc);
 			goto out_free_unlock;
 	}
-	rc = crypto_hash_init(&s->hash_desc);
-	if (rc) {
-		printk(KERN_ERR
-		       "%s: Error initializing crypto hash; rc = [%d]\n",
-		       __func__, rc);
-		goto out_release_free_unlock;
-	}
-	rc = crypto_hash_update(
-		&s->hash_desc, &s->hash_sg,
-		s->auth_tok->token.password.session_key_encryption_key_bytes);
-	if (rc) {
-		printk(KERN_ERR
-		       "%s: Error updating crypto hash; rc = [%d]\n",
-		       __func__, rc);
+
+	s->hash_desc = kmalloc(sizeof(*s->hash_desc) +
+			       crypto_shash_descsize(s->hash_tfm), GFP_KERNEL);
+	if (!s->hash_desc) {
+		printk(KERN_ERR "%s: Out of kernel memory whilst attempting to "
+		       "kmalloc [%zd] bytes\n", __func__,
+		       sizeof(*s->hash_desc) +
+		       crypto_shash_descsize(s->hash_tfm));
+		rc = -ENOMEM;
 		goto out_release_free_unlock;
 	}
-	rc = crypto_hash_final(&s->hash_desc, s->hash);
+
+	s->hash_desc->tfm = s->hash_tfm;
+	s->hash_desc->flags = CRYPTO_TFM_REQ_MAY_SLEEP;
+
+	rc = crypto_shash_digest(s->hash_desc,
+				 (u8 *)s->auth_tok->token.password.session_key_encryption_key,
+				 s->auth_tok->token.password.session_key_encryption_key_bytes,
+				 s->hash);
 	if (rc) {
 		printk(KERN_ERR
-		       "%s: Error finalizing crypto hash; rc = [%d]\n",
+		       "%s: Error computing crypto hash; rc = [%d]\n",
 		       __func__, rc);
 		goto out_release_free_unlock;
 	}
@@ -780,27 +789,12 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *remaining_bytes,
 			s->hash[(s->j % ECRYPTFS_TAG_70_DIGEST_SIZE)];
 		if ((s->j % ECRYPTFS_TAG_70_DIGEST_SIZE)
 		    == (ECRYPTFS_TAG_70_DIGEST_SIZE - 1)) {
-			sg_init_one(&s->hash_sg, (u8 *)s->hash,
-				    ECRYPTFS_TAG_70_DIGEST_SIZE);
-			rc = crypto_hash_init(&s->hash_desc);
-			if (rc) {
-				printk(KERN_ERR
-				       "%s: Error initializing crypto hash; "
-				       "rc = [%d]\n", __func__, rc);
-				goto out_release_free_unlock;
-			}
-			rc = crypto_hash_update(&s->hash_desc, &s->hash_sg,
-						ECRYPTFS_TAG_70_DIGEST_SIZE);
+			rc = crypto_shash_digest(s->hash_desc, (u8 *)s->hash,
+						ECRYPTFS_TAG_70_DIGEST_SIZE,
+						s->tmp_hash);
 			if (rc) {
 				printk(KERN_ERR
-				       "%s: Error updating crypto hash; "
-				       "rc = [%d]\n", __func__, rc);
-				goto out_release_free_unlock;
-			}
-			rc = crypto_hash_final(&s->hash_desc, s->tmp_hash);
-			if (rc) {
-				printk(KERN_ERR
-				       "%s: Error finalizing crypto hash; "
+				       "%s: Error computing crypto hash; "
 				       "rc = [%d]\n", __func__, rc);
 				goto out_release_free_unlock;
 			}
@@ -834,10 +828,8 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *remaining_bytes,
 	 * of the IV here, so we just use 0's for the IV. Note the
 	 * constraint that ECRYPTFS_FILENAME_MIN_RANDOM_PREPEND_BYTES
 	 * >= ECRYPTFS_MAX_IV_BYTES. */
-	memset(s->iv, 0, ECRYPTFS_MAX_IV_BYTES);
-	s->desc.info = s->iv;
-	rc = crypto_blkcipher_setkey(
-		s->desc.tfm,
+	rc = crypto_skcipher_setkey(
+		s->skcipher_tfm,
 		s->auth_tok->token.password.session_key_encryption_key,
 		mount_crypt_stat->global_default_fn_cipher_key_bytes);
 	if (rc < 0) {
@@ -850,8 +842,9 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *remaining_bytes,
 		       mount_crypt_stat->global_default_fn_cipher_key_bytes);
 		goto out_release_free_unlock;
 	}
-	rc = crypto_blkcipher_encrypt_iv(&s->desc, s->dst_sg, s->src_sg,
-					 s->block_aligned_filename_size);
+	skcipher_request_set_crypt(s->skcipher_req, s->src_sg, s->dst_sg,
+				   s->block_aligned_filename_size, s->iv);
+	rc = crypto_skcipher_encrypt(s->skcipher_req);
 	if (rc) {
 		printk(KERN_ERR "%s: Error attempting to encrypt filename; "
 		       "rc = [%d]\n", __func__, rc);
@@ -861,7 +854,7 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *remaining_bytes,
 	(*packet_size) = s->i;
 	(*remaining_bytes) -= (*packet_size);
 out_release_free_unlock:
-	crypto_free_hash(s->hash_desc.tfm);
+	crypto_free_shash(s->hash_tfm);
 out_free_unlock:
 	kzfree(s->block_aligned_filename);
 out_unlock:
@@ -871,6 +864,8 @@ out:
 		up_write(&(auth_tok_key->sem));
 		key_put(auth_tok_key);
 	}
+	skcipher_request_free(s->skcipher_req);
+	kzfree(s->hash_desc);
 	kfree(s);
 	return rc;
 }
@@ -888,7 +883,8 @@ struct ecryptfs_parse_tag_70_packet_silly_stack {
 	struct ecryptfs_auth_tok *auth_tok;
 	struct scatterlist src_sg[2];
 	struct scatterlist dst_sg[2];
-	struct blkcipher_desc desc;
+	struct crypto_skcipher *skcipher_tfm;
+	struct skcipher_request *skcipher_req;
 	char fnek_sig_hex[ECRYPTFS_SIG_SIZE_HEX + 1];
 	char iv[ECRYPTFS_MAX_IV_BYTES];
 	char cipher_string[ECRYPTFS_MAX_CIPHER_NAME_SIZE + 1];
@@ -922,14 +918,13 @@ ecryptfs_parse_tag_70_packet(char **filename, size_t *filename_size,
 	(*packet_size) = 0;
 	(*filename_size) = 0;
 	(*filename) = NULL;
-	s = kmalloc(sizeof(*s), GFP_KERNEL);
+	s = kzalloc(sizeof(*s), GFP_KERNEL);
 	if (!s) {
 		printk(KERN_ERR "%s: Out of memory whilst trying to kmalloc "
 		       "[%zd] bytes of kernel memory\n", __func__, sizeof(*s));
 		rc = -ENOMEM;
 		goto out;
 	}
-	s->desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
 	if (max_packet_size < ECRYPTFS_TAG_70_MIN_METADATA_SIZE) {
 		printk(KERN_WARNING "%s: max_packet_size is [%zd]; it must be "
 		       "at least [%d]\n", __func__, max_packet_size,
@@ -992,7 +987,7 @@ ecryptfs_parse_tag_70_packet(char **filename, size_t *filename_size,
 		       rc);
 		goto out;
 	}
-	rc = ecryptfs_get_tfm_and_mutex_for_cipher_name(&s->desc.tfm,
+	rc = ecryptfs_get_tfm_and_mutex_for_cipher_name(&s->skcipher_tfm,
 							&s->tfm_mutex,
 							s->cipher_string);
 	if (unlikely(rc)) {
@@ -1030,12 +1025,23 @@ ecryptfs_parse_tag_70_packet(char **filename, size_t *filename_size,
 		       __func__, rc, s->block_aligned_filename_size);
 		goto out_free_unlock;
 	}
+
+	s->skcipher_req = skcipher_request_alloc(s->skcipher_tfm, GFP_KERNEL);
+	if (!s->skcipher_req) {
+		printk(KERN_ERR "%s: Out of kernel memory whilst attempting to "
+		       "skcipher_request_alloc for %s\n", __func__,
+		       crypto_skcipher_driver_name(s->skcipher_tfm));
+		rc = -ENOMEM;
+		goto out_free_unlock;
+	}
+
+	skcipher_request_set_callback(s->skcipher_req,
+				      CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
+
 	/* The characters in the first block effectively do the job of
 	 * the IV here, so we just use 0's for the IV. Note the
 	 * constraint that ECRYPTFS_FILENAME_MIN_RANDOM_PREPEND_BYTES
 	 * >= ECRYPTFS_MAX_IV_BYTES. */
-	memset(s->iv, 0, ECRYPTFS_MAX_IV_BYTES);
-	s->desc.info = s->iv;
 	/* TODO: Support other key modules than passphrase for
 	 * filename encryption */
 	if (s->auth_tok->token_type != ECRYPTFS_PASSWORD) {
@@ -1044,8 +1050,8 @@ ecryptfs_parse_tag_70_packet(char **filename, size_t *filename_size,
 		       "password tokens\n", __func__);
 		goto out_free_unlock;
 	}
-	rc = crypto_blkcipher_setkey(
-		s->desc.tfm,
+	rc = crypto_skcipher_setkey(
+		s->skcipher_tfm,
 		s->auth_tok->token.password.session_key_encryption_key,
 		mount_crypt_stat->global_default_fn_cipher_key_bytes);
 	if (rc < 0) {
@@ -1058,14 +1064,14 @@ ecryptfs_parse_tag_70_packet(char **filename, size_t *filename_size,
 		       mount_crypt_stat->global_default_fn_cipher_key_bytes);
 		goto out_free_unlock;
 	}
-	rc = crypto_blkcipher_decrypt_iv(&s->desc, s->dst_sg, s->src_sg,
-					 s->block_aligned_filename_size);
+	skcipher_request_set_crypt(s->skcipher_req, s->src_sg, s->dst_sg,
+				   s->block_aligned_filename_size, s->iv);
+	rc = crypto_skcipher_decrypt(s->skcipher_req);
 	if (rc) {
 		printk(KERN_ERR "%s: Error attempting to decrypt filename; "
 		       "rc = [%d]\n", __func__, rc);
 		goto out_free_unlock;
 	}
-	s->i = 0;
 	while (s->decrypted_filename[s->i] != '\0'
 	       && s->i < s->block_aligned_filename_size)
 		s->i++;
@@ -1108,6 +1114,7 @@ out:
 		up_write(&(auth_tok_key->sem));
 		key_put(auth_tok_key);
 	}
+	skcipher_request_free(s->skcipher_req);
 	kfree(s);
 	return rc;
 }
@@ -1667,9 +1674,8 @@ decrypt_passphrase_encrypted_session_key(struct ecryptfs_auth_tok *auth_tok,
 	struct scatterlist dst_sg[2];
 	struct scatterlist src_sg[2];
 	struct mutex *tfm_mutex;
-	struct blkcipher_desc desc = {
-		.flags = CRYPTO_TFM_REQ_MAY_SLEEP
-	};
+	struct crypto_skcipher *tfm;
+	struct skcipher_request *req = NULL;
 	int rc = 0;
 
 	if (unlikely(ecryptfs_verbosity > 0)) {
@@ -1680,7 +1686,7 @@ decrypt_passphrase_encrypted_session_key(struct ecryptfs_auth_tok *auth_tok,
 			auth_tok->token.password.session_key_encryption_key,
 			auth_tok->token.password.session_key_encryption_key_bytes);
 	}
-	rc = ecryptfs_get_tfm_and_mutex_for_cipher_name(&desc.tfm, &tfm_mutex,
+	rc = ecryptfs_get_tfm_and_mutex_for_cipher_name(&tfm, &tfm_mutex,
 							crypt_stat->cipher);
 	if (unlikely(rc)) {
 		printk(KERN_ERR "Internal error whilst attempting to get "
@@ -1711,8 +1717,19 @@ decrypt_passphrase_encrypted_session_key(struct ecryptfs_auth_tok *auth_tok,
 		goto out;
 	}
 	mutex_lock(tfm_mutex);
-	rc = crypto_blkcipher_setkey(
-		desc.tfm, auth_tok->token.password.session_key_encryption_key,
+	req = skcipher_request_alloc(tfm, GFP_KERNEL);
+	if (!req) {
+		printk(KERN_ERR "%s: Out of kernel memory whilst attempting to "
+		       "skcipher_request_alloc for %s\n", __func__,
+		       crypto_skcipher_driver_name(tfm));
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	skcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP,
+				      NULL, NULL);
+	rc = crypto_skcipher_setkey(
+		tfm, auth_tok->token.password.session_key_encryption_key,
 		crypt_stat->key_size);
 	if (unlikely(rc < 0)) {
 		mutex_unlock(tfm_mutex);
@@ -1720,8 +1737,10 @@ decrypt_passphrase_encrypted_session_key(struct ecryptfs_auth_tok *auth_tok,
 		rc = -EINVAL;
 		goto out;
 	}
-	rc = crypto_blkcipher_decrypt(&desc, dst_sg, src_sg,
-				      auth_tok->session_key.encrypted_key_size);
+	skcipher_request_set_crypt(req, src_sg, dst_sg,
+				   auth_tok->session_key.encrypted_key_size,
+				   NULL);
+	rc = crypto_skcipher_decrypt(req);
 	mutex_unlock(tfm_mutex);
 	if (unlikely(rc)) {
 		printk(KERN_ERR "Error decrypting; rc = [%d]\n", rc);
@@ -1738,6 +1757,7 @@ decrypt_passphrase_encrypted_session_key(struct ecryptfs_auth_tok *auth_tok,
 				  crypt_stat->key_size);
 	}
 out:
+	skcipher_request_free(req);
 	return rc;
 }
 
@@ -2191,16 +2211,14 @@ write_tag_3_packet(char *dest, size_t *remaining_bytes,
 	size_t max_packet_size;
 	struct ecryptfs_mount_crypt_stat *mount_crypt_stat =
 		crypt_stat->mount_crypt_stat;
-	struct blkcipher_desc desc = {
-		.tfm = NULL,
-		.flags = CRYPTO_TFM_REQ_MAY_SLEEP
-	};
+	struct crypto_skcipher *tfm;
+	struct skcipher_request *req;
 	int rc = 0;
 
 	(*packet_size) = 0;
 	ecryptfs_from_hex(key_rec->sig, auth_tok->token.password.signature,
 			  ECRYPTFS_SIG_SIZE);
-	rc = ecryptfs_get_tfm_and_mutex_for_cipher_name(&desc.tfm, &tfm_mutex,
+	rc = ecryptfs_get_tfm_and_mutex_for_cipher_name(&tfm, &tfm_mutex,
 							crypt_stat->cipher);
 	if (unlikely(rc)) {
 		printk(KERN_ERR "Internal error whilst attempting to get "
@@ -2209,12 +2227,11 @@ write_tag_3_packet(char *dest, size_t *remaining_bytes,
 		goto out;
 	}
 	if (mount_crypt_stat->global_default_cipher_key_size == 0) {
-		struct blkcipher_alg *alg = crypto_blkcipher_alg(desc.tfm);
-
 		printk(KERN_WARNING "No key size specified at mount; "
-		       "defaulting to [%d]\n", alg->max_keysize);
+		       "defaulting to [%d]\n",
+		       crypto_skcipher_default_keysize(tfm));
 		mount_crypt_stat->global_default_cipher_key_size =
-			alg->max_keysize;
+			crypto_skcipher_default_keysize(tfm);
 	}
 	if (crypt_stat->key_size == 0)
 		crypt_stat->key_size =
@@ -2284,20 +2301,36 @@ write_tag_3_packet(char *dest, size_t *remaining_bytes,
 		goto out;
 	}
 	mutex_lock(tfm_mutex);
-	rc = crypto_blkcipher_setkey(desc.tfm, session_key_encryption_key,
-				     crypt_stat->key_size);
+	rc = crypto_skcipher_setkey(tfm, session_key_encryption_key,
+				    crypt_stat->key_size);
 	if (rc < 0) {
 		mutex_unlock(tfm_mutex);
 		ecryptfs_printk(KERN_ERR, "Error setting key for crypto "
 				"context; rc = [%d]\n", rc);
 		goto out;
 	}
+
+	req = skcipher_request_alloc(tfm, GFP_KERNEL);
+	if (!req) {
+		mutex_unlock(tfm_mutex);
+		ecryptfs_printk(KERN_ERR, "Out of kernel memory whilst "
+				"attempting to skcipher_request_alloc for "
+				"%s\n", crypto_skcipher_driver_name(tfm));
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	skcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP,
+				      NULL, NULL);
+
 	rc = 0;
 	ecryptfs_printk(KERN_DEBUG, "Encrypting [%zd] bytes of the key\n",
 			crypt_stat->key_size);
-	rc = crypto_blkcipher_encrypt(&desc, dst_sg, src_sg,
-				      (*key_rec).enc_key_size);
+	skcipher_request_set_crypt(req, src_sg, dst_sg,
+				   (*key_rec).enc_key_size, NULL);
+	rc = crypto_skcipher_encrypt(req);
 	mutex_unlock(tfm_mutex);
+	skcipher_request_free(req);
 	if (rc) {
 		printk(KERN_ERR "Error encrypting; rc = [%d]\n", rc);
 		goto out;
diff --git a/fs/ecryptfs/main.c b/fs/ecryptfs/main.c
index e25b6b0..8b0b4a7 100644
--- a/fs/ecryptfs/main.c
+++ b/fs/ecryptfs/main.c
@@ -29,7 +29,6 @@
 #include <linux/module.h>
 #include <linux/namei.h>
 #include <linux/skbuff.h>
-#include <linux/crypto.h>
 #include <linux/mount.h>
 #include <linux/pagemap.h>
 #include <linux/key.h>
diff --git a/fs/ecryptfs/mmap.c b/fs/ecryptfs/mmap.c
index caba848..36c8b08 100644
--- a/fs/ecryptfs/mmap.c
+++ b/fs/ecryptfs/mmap.c
@@ -30,7 +30,6 @@
 #include <linux/page-flags.h>
 #include <linux/mount.h>
 #include <linux/file.h>
-#include <linux/crypto.h>
 #include <linux/scatterlist.h>
 #include <linux/slab.h>
 #include <asm/unaligned.h>
diff --git a/fs/ecryptfs/super.c b/fs/ecryptfs/super.c
index afa1b81..77a486d 100644
--- a/fs/ecryptfs/super.c
+++ b/fs/ecryptfs/super.c
@@ -29,7 +29,6 @@
 #include <linux/slab.h>
 #include <linux/seq_file.h>
 #include <linux/file.h>
-#include <linux/crypto.h>
 #include <linux/statfs.h>
 #include <linux/magic.h>
 #include "ecryptfs_kernel.h"
