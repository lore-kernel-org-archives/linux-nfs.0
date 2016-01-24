Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:54873 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889AbcAXNRq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:17:46 -0500
Subject: [PATCH 7/26] wusb: Use skcipher
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
Message-Id: <E1aNKXT-0008BX-N7@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:17:07 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of blkcipher with skcipher.
    
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/usb/wusbcore/crypto.c |   30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/usb/wusbcore/crypto.c b/drivers/usb/wusbcore/crypto.c
index 50ce80d..8ed8e34 100644
--- a/drivers/usb/wusbcore/crypto.c
+++ b/drivers/usb/wusbcore/crypto.c
@@ -45,6 +45,7 @@
  *             funneled through AES are...16 bytes in size!
  */
 
+#include <crypto/skcipher.h>
 #include <linux/crypto.h>
 #include <linux/module.h>
 #include <linux/err.h>
@@ -195,21 +196,22 @@ static void bytewise_xor(void *_bo, const void *_bi1, const void *_bi2,
  * NOTE: blen is not aligned to a block size, we'll pad zeros, that's
  *       what sg[4] is for. Maybe there is a smarter way to do this.
  */
-static int wusb_ccm_mac(struct crypto_blkcipher *tfm_cbc,
+static int wusb_ccm_mac(struct crypto_skcipher *tfm_cbc,
 			struct crypto_cipher *tfm_aes, void *mic,
 			const struct aes_ccm_nonce *n,
 			const struct aes_ccm_label *a, const void *b,
 			size_t blen)
 {
 	int result = 0;
-	struct blkcipher_desc desc;
+	SKCIPHER_REQUEST_ON_STACK(req, tfm_cbc);
 	struct aes_ccm_b0 b0;
 	struct aes_ccm_b1 b1;
 	struct aes_ccm_a ax;
 	struct scatterlist sg[4], sg_dst;
-	void *iv, *dst_buf;
-	size_t ivsize, dst_size;
+	void *dst_buf;
+	size_t dst_size;
 	const u8 bzero[16] = { 0 };
+	u8 iv[crypto_skcipher_ivsize(tfm_cbc)];
 	size_t zero_padding;
 
 	/*
@@ -232,9 +234,7 @@ static int wusb_ccm_mac(struct crypto_blkcipher *tfm_cbc,
 		goto error_dst_buf;
 	}
 
-	iv = crypto_blkcipher_crt(tfm_cbc)->iv;
-	ivsize = crypto_blkcipher_ivsize(tfm_cbc);
-	memset(iv, 0, ivsize);
+	memset(iv, 0, sizeof(iv));
 
 	/* Setup B0 */
 	b0.flags = 0x59;	/* Format B0 */
@@ -259,9 +259,11 @@ static int wusb_ccm_mac(struct crypto_blkcipher *tfm_cbc,
 	sg_set_buf(&sg[3], bzero, zero_padding);
 	sg_init_one(&sg_dst, dst_buf, dst_size);
 
-	desc.tfm = tfm_cbc;
-	desc.flags = 0;
-	result = crypto_blkcipher_encrypt(&desc, &sg_dst, sg, dst_size);
+	skcipher_request_set_tfm(req, tfm_cbc);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, sg, &sg_dst, dst_size, iv);
+	result = crypto_skcipher_encrypt(req);
+	skcipher_request_zero(req);
 	if (result < 0) {
 		printk(KERN_ERR "E: can't compute CBC-MAC tag (MIC): %d\n",
 		       result);
@@ -301,18 +303,18 @@ ssize_t wusb_prf(void *out, size_t out_size,
 {
 	ssize_t result, bytes = 0, bitr;
 	struct aes_ccm_nonce n = *_n;
-	struct crypto_blkcipher *tfm_cbc;
+	struct crypto_skcipher *tfm_cbc;
 	struct crypto_cipher *tfm_aes;
 	u64 sfn = 0;
 	__le64 sfn_le;
 
-	tfm_cbc = crypto_alloc_blkcipher("cbc(aes)", 0, CRYPTO_ALG_ASYNC);
+	tfm_cbc = crypto_alloc_skcipher("cbc(aes)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm_cbc)) {
 		result = PTR_ERR(tfm_cbc);
 		printk(KERN_ERR "E: can't load CBC(AES): %d\n", (int)result);
 		goto error_alloc_cbc;
 	}
-	result = crypto_blkcipher_setkey(tfm_cbc, key, 16);
+	result = crypto_skcipher_setkey(tfm_cbc, key, 16);
 	if (result < 0) {
 		printk(KERN_ERR "E: can't set CBC key: %d\n", (int)result);
 		goto error_setkey_cbc;
@@ -345,7 +347,7 @@ error_setkey_aes:
 	crypto_free_cipher(tfm_aes);
 error_alloc_aes:
 error_setkey_cbc:
-	crypto_free_blkcipher(tfm_cbc);
+	crypto_free_skcipher(tfm_cbc);
 error_alloc_cbc:
 	return result;
 }
