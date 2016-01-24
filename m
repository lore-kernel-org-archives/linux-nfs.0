Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:44010 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbcAXNQq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:16:46 -0500
Subject: [PATCH 1/26] block: cryptoloop - Use new skcipher interface
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
Message-Id: <E1aNKWU-0008A9-Dx@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:16:06 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of blkcipher with the new skcipher
interface.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/block/cryptoloop.c |   48 +++++++++++++++++++++++----------------------
 1 file changed, 25 insertions(+), 23 deletions(-)

diff --git a/drivers/block/cryptoloop.c b/drivers/block/cryptoloop.c
index 99e773c..3d31761 100644
--- a/drivers/block/cryptoloop.c
+++ b/drivers/block/cryptoloop.c
@@ -21,9 +21,9 @@
 
 #include <linux/module.h>
 
+#include <crypto/skcipher.h>
 #include <linux/init.h>
 #include <linux/string.h>
-#include <linux/crypto.h>
 #include <linux/blkdev.h>
 #include <linux/scatterlist.h>
 #include <asm/uaccess.h>
@@ -46,7 +46,7 @@ cryptoloop_init(struct loop_device *lo, const struct loop_info64 *info)
 	char *cipher;
 	char *mode;
 	char *cmsp = cms;			/* c-m string pointer */
-	struct crypto_blkcipher *tfm;
+	struct crypto_skcipher *tfm;
 
 	/* encryption breaks for non sector aligned offsets */
 
@@ -82,12 +82,12 @@ cryptoloop_init(struct loop_device *lo, const struct loop_info64 *info)
 	*cmsp++ = ')';
 	*cmsp = 0;
 
-	tfm = crypto_alloc_blkcipher(cms, 0, CRYPTO_ALG_ASYNC);
+	tfm = crypto_alloc_skcipher(cms, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm))
 		return PTR_ERR(tfm);
 
-	err = crypto_blkcipher_setkey(tfm, info->lo_encrypt_key,
-				      info->lo_encrypt_key_size);
+	err = crypto_skcipher_setkey(tfm, info->lo_encrypt_key,
+				     info->lo_encrypt_key_size);
 	
 	if (err != 0)
 		goto out_free_tfm;
@@ -96,17 +96,14 @@ cryptoloop_init(struct loop_device *lo, const struct loop_info64 *info)
 	return 0;
 
  out_free_tfm:
-	crypto_free_blkcipher(tfm);
+	crypto_free_skcipher(tfm);
 
  out:
 	return err;
 }
 
 
-typedef int (*encdec_cbc_t)(struct blkcipher_desc *desc,
-			struct scatterlist *sg_out,
-			struct scatterlist *sg_in,
-			unsigned int nsg);
+typedef int (*encdec_cbc_t)(struct skcipher_request *req);
 
 static int
 cryptoloop_transfer(struct loop_device *lo, int cmd,
@@ -114,11 +111,8 @@ cryptoloop_transfer(struct loop_device *lo, int cmd,
 		    struct page *loop_page, unsigned loop_off,
 		    int size, sector_t IV)
 {
-	struct crypto_blkcipher *tfm = lo->key_data;
-	struct blkcipher_desc desc = {
-		.tfm = tfm,
-		.flags = CRYPTO_TFM_REQ_MAY_SLEEP,
-	};
+	struct crypto_skcipher *tfm = lo->key_data;
+	SKCIPHER_REQUEST_ON_STACK(req, tfm);
 	struct scatterlist sg_out;
 	struct scatterlist sg_in;
 
@@ -127,6 +121,10 @@ cryptoloop_transfer(struct loop_device *lo, int cmd,
 	unsigned in_offs, out_offs;
 	int err;
 
+	skcipher_request_set_tfm(req, tfm);
+	skcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP,
+				      NULL, NULL);
+
 	sg_init_table(&sg_out, 1);
 	sg_init_table(&sg_in, 1);
 
@@ -135,13 +133,13 @@ cryptoloop_transfer(struct loop_device *lo, int cmd,
 		in_offs = raw_off;
 		out_page = loop_page;
 		out_offs = loop_off;
-		encdecfunc = crypto_blkcipher_crt(tfm)->decrypt;
+		encdecfunc = crypto_skcipher_decrypt;
 	} else {
 		in_page = loop_page;
 		in_offs = loop_off;
 		out_page = raw_page;
 		out_offs = raw_off;
-		encdecfunc = crypto_blkcipher_crt(tfm)->encrypt;
+		encdecfunc = crypto_skcipher_encrypt;
 	}
 
 	while (size > 0) {
@@ -152,10 +150,10 @@ cryptoloop_transfer(struct loop_device *lo, int cmd,
 		sg_set_page(&sg_in, in_page, sz, in_offs);
 		sg_set_page(&sg_out, out_page, sz, out_offs);
 
-		desc.info = iv;
-		err = encdecfunc(&desc, &sg_out, &sg_in, sz);
+		skcipher_request_set_crypt(req, &sg_in, &sg_out, sz, iv);
+		err = encdecfunc(req);
 		if (err)
-			return err;
+			goto out;
 
 		IV++;
 		size -= sz;
@@ -163,7 +161,11 @@ cryptoloop_transfer(struct loop_device *lo, int cmd,
 		out_offs += sz;
 	}
 
-	return 0;
+	err = 0;
+
+out:
+	skcipher_request_zero(req);
+	return err;
 }
 
 static int
@@ -175,9 +177,9 @@ cryptoloop_ioctl(struct loop_device *lo, int cmd, unsigned long arg)
 static int
 cryptoloop_release(struct loop_device *lo)
 {
-	struct crypto_blkcipher *tfm = lo->key_data;
+	struct crypto_skcipher *tfm = lo->key_data;
 	if (tfm != NULL) {
-		crypto_free_blkcipher(tfm);
+		crypto_free_skcipher(tfm);
 		lo->key_data = NULL;
 		return 0;
 	}
