Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:43366 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753571AbcAXNR1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:17:27 -0500
Subject: [PATCH 5/26] orinoco: Use ahash
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
Message-Id: <E1aNKX9-0008Az-6R@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:16:47 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses the long obsolete hash interface with ahash.
    
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/wireless/intersil/orinoco/mic.c     |   29 ++++++++++++++----------
 drivers/net/wireless/intersil/orinoco/mic.h     |    4 +--
 drivers/net/wireless/intersil/orinoco/orinoco.h |    4 +--
 3 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wireless/intersil/orinoco/mic.c b/drivers/net/wireless/intersil/orinoco/mic.c
index fce4a84..bc7397d 100644
--- a/drivers/net/wireless/intersil/orinoco/mic.c
+++ b/drivers/net/wireless/intersil/orinoco/mic.c
@@ -6,7 +6,7 @@
 #include <linux/string.h>
 #include <linux/if_ether.h>
 #include <linux/scatterlist.h>
-#include <linux/crypto.h>
+#include <crypto/hash.h>
 
 #include "orinoco.h"
 #include "mic.h"
@@ -16,7 +16,8 @@
 /********************************************************************/
 int orinoco_mic_init(struct orinoco_private *priv)
 {
-	priv->tx_tfm_mic = crypto_alloc_hash("michael_mic", 0, 0);
+	priv->tx_tfm_mic = crypto_alloc_ahash("michael_mic", 0,
+					      CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->tx_tfm_mic)) {
 		printk(KERN_DEBUG "orinoco_mic_init: could not allocate "
 		       "crypto API michael_mic\n");
@@ -24,7 +25,8 @@ int orinoco_mic_init(struct orinoco_private *priv)
 		return -ENOMEM;
 	}
 
-	priv->rx_tfm_mic = crypto_alloc_hash("michael_mic", 0, 0);
+	priv->rx_tfm_mic = crypto_alloc_ahash("michael_mic", 0,
+					      CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->rx_tfm_mic)) {
 		printk(KERN_DEBUG "orinoco_mic_init: could not allocate "
 		       "crypto API michael_mic\n");
@@ -38,18 +40,19 @@ int orinoco_mic_init(struct orinoco_private *priv)
 void orinoco_mic_free(struct orinoco_private *priv)
 {
 	if (priv->tx_tfm_mic)
-		crypto_free_hash(priv->tx_tfm_mic);
+		crypto_free_ahash(priv->tx_tfm_mic);
 	if (priv->rx_tfm_mic)
-		crypto_free_hash(priv->rx_tfm_mic);
+		crypto_free_ahash(priv->rx_tfm_mic);
 }
 
-int orinoco_mic(struct crypto_hash *tfm_michael, u8 *key,
+int orinoco_mic(struct crypto_ahash *tfm_michael, u8 *key,
 		u8 *da, u8 *sa, u8 priority,
 		u8 *data, size_t data_len, u8 *mic)
 {
-	struct hash_desc desc;
+	AHASH_REQUEST_ON_STACK(req, tfm_michael);
 	struct scatterlist sg[2];
 	u8 hdr[ETH_HLEN + 2]; /* size of header + padding */
+	int err;
 
 	if (tfm_michael == NULL) {
 		printk(KERN_WARNING "orinoco_mic: tfm_michael == NULL\n");
@@ -69,11 +72,13 @@ int orinoco_mic(struct crypto_hash *tfm_michael, u8 *key,
 	sg_set_buf(&sg[0], hdr, sizeof(hdr));
 	sg_set_buf(&sg[1], data, data_len);
 
-	if (crypto_hash_setkey(tfm_michael, key, MIC_KEYLEN))
+	if (crypto_ahash_setkey(tfm_michael, key, MIC_KEYLEN))
 		return -1;
 
-	desc.tfm = tfm_michael;
-	desc.flags = 0;
-	return crypto_hash_digest(&desc, sg, data_len + sizeof(hdr),
-				  mic);
+	ahash_request_set_tfm(req, tfm_michael);
+	ahash_request_set_callback(req, 0, NULL, NULL);
+	ahash_request_set_crypt(req, sg, mic, data_len + sizeof(hdr));
+	err = crypto_ahash_digest(req);
+	ahash_request_zero(req);
+	return err;
 }
diff --git a/drivers/net/wireless/intersil/orinoco/mic.h b/drivers/net/wireless/intersil/orinoco/mic.h
index 04d05bc..ce731d0 100644
--- a/drivers/net/wireless/intersil/orinoco/mic.h
+++ b/drivers/net/wireless/intersil/orinoco/mic.h
@@ -11,11 +11,11 @@
 
 /* Forward declarations */
 struct orinoco_private;
-struct crypto_hash;
+struct crypto_ahash;
 
 int orinoco_mic_init(struct orinoco_private *priv);
 void orinoco_mic_free(struct orinoco_private *priv);
-int orinoco_mic(struct crypto_hash *tfm_michael, u8 *key,
+int orinoco_mic(struct crypto_ahash *tfm_michael, u8 *key,
 		u8 *da, u8 *sa, u8 priority,
 		u8 *data, size_t data_len, u8 *mic);
 
diff --git a/drivers/net/wireless/intersil/orinoco/orinoco.h b/drivers/net/wireless/intersil/orinoco/orinoco.h
index eebd2be..2f0c84b 100644
--- a/drivers/net/wireless/intersil/orinoco/orinoco.h
+++ b/drivers/net/wireless/intersil/orinoco/orinoco.h
@@ -152,8 +152,8 @@ struct orinoco_private {
 	u8 *wpa_ie;
 	int wpa_ie_len;
 
-	struct crypto_hash *rx_tfm_mic;
-	struct crypto_hash *tx_tfm_mic;
+	struct crypto_ahash *rx_tfm_mic;
+	struct crypto_ahash *tx_tfm_mic;
 
 	unsigned int wpa_enabled:1;
 	unsigned int tkip_cm_active:1;
