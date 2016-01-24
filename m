Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:40861 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754266AbcAXNUL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:20:11 -0500
Subject: [PATCH 21/26] nfc: s3fwrn5: Use shash
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
Message-Id: <E1aNKZn-0008FU-OU@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:19:31 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of the long obsolete hash interface with
shash.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/nfc/s3fwrn5/firmware.c |   36 +++++++++++++++++++++++++++---------
 1 file changed, 27 insertions(+), 9 deletions(-)

diff --git a/drivers/nfc/s3fwrn5/firmware.c b/drivers/nfc/s3fwrn5/firmware.c
index 64a9025..5f97da1 100644
--- a/drivers/nfc/s3fwrn5/firmware.c
+++ b/drivers/nfc/s3fwrn5/firmware.c
@@ -19,7 +19,7 @@
 
 #include <linux/completion.h>
 #include <linux/firmware.h>
-#include <linux/crypto.h>
+#include <crypto/hash.h>
 #include <crypto/sha.h>
 
 #include "s3fwrn5.h"
@@ -429,8 +429,7 @@ int s3fwrn5_fw_download(struct s3fwrn5_fw_info *fw_info)
 {
 	struct s3fwrn5_fw_image *fw = &fw_info->fw;
 	u8 hash_data[SHA1_DIGEST_SIZE];
-	struct scatterlist sg;
-	struct hash_desc desc;
+	struct crypto_shash *tfm;
 	u32 image_size, off;
 	int ret;
 
@@ -438,12 +437,31 @@ int s3fwrn5_fw_download(struct s3fwrn5_fw_info *fw_info)
 
 	/* Compute SHA of firmware data */
 
-	sg_init_one(&sg, fw->image, image_size);
-	desc.tfm = crypto_alloc_hash("sha1", 0, CRYPTO_ALG_ASYNC);
-	crypto_hash_init(&desc);
-	crypto_hash_update(&desc, &sg, image_size);
-	crypto_hash_final(&desc, hash_data);
-	crypto_free_hash(desc.tfm);
+	tfm = crypto_alloc_shash("sha1", 0, 0);
+	if (IS_ERR(tfm)) {
+		ret = PTR_ERR(tfm);
+		dev_err(&fw_info->ndev->nfc_dev->dev,
+			"Cannot allocate shash (code=%d)\n", ret);
+		goto out;
+	}
+
+	{
+		SHASH_DESC_ON_STACK(desc, tfm);
+
+		desc->tfm = tfm;
+		desc->flags = CRYPTO_TFM_REQ_MAY_SLEEP;
+
+		ret = crypto_shash_digest(desc, fw->image, image_size,
+					  hash_data);
+		shash_desc_zero(desc);
+	}
+
+	crypto_free_shash(tfm);
+	if (ret) {
+		dev_err(&fw_info->ndev->nfc_dev->dev,
+			"Cannot compute hash (code=%d)\n", ret);
+		goto out;
+	}
 
 	/* Firmware update process */
 
