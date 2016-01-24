Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:44310 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbcAXNRI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:17:08 -0500
Subject: [PATCH 3/26] staging: rtl8192e: Replace uses of obsolete blkcipher and hash
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
Message-Id: <E1aNKWo-0008AS-PG@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:16:26 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The interfaces blkcipher and hash are obsolete.  This patch replaces
them with skcipher and ahash respectively.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/staging/rtl8192e/rtllib_crypt_tkip.c |   99 ++++++++++++++-------------
 drivers/staging/rtl8192e/rtllib_crypt_wep.c  |   48 +++++++------
 2 files changed, 82 insertions(+), 65 deletions(-)

diff --git a/drivers/staging/rtl8192e/rtllib_crypt_tkip.c b/drivers/staging/rtl8192e/rtllib_crypt_tkip.c
index 2096d78..8eac7cd 100644
--- a/drivers/staging/rtl8192e/rtllib_crypt_tkip.c
+++ b/drivers/staging/rtl8192e/rtllib_crypt_tkip.c
@@ -9,6 +9,8 @@
  * more details.
  */
 
+#include <crypto/hash.h>
+#include <crypto/skcipher.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/slab.h>
@@ -18,7 +20,6 @@
 #include <linux/if_ether.h>
 #include <linux/if_arp.h>
 #include <linux/string.h>
-#include <linux/crypto.h>
 #include <linux/scatterlist.h>
 #include <linux/crc32.h>
 #include <linux/etherdevice.h>
@@ -48,10 +49,10 @@ struct rtllib_tkip_data {
 	u32 dot11RSNAStatsTKIPLocalMICFailures;
 
 	int key_idx;
-	struct crypto_blkcipher *rx_tfm_arc4;
-	struct crypto_hash *rx_tfm_michael;
-	struct crypto_blkcipher *tx_tfm_arc4;
-	struct crypto_hash *tx_tfm_michael;
+	struct crypto_skcipher *rx_tfm_arc4;
+	struct crypto_ahash *rx_tfm_michael;
+	struct crypto_skcipher *tx_tfm_arc4;
+	struct crypto_ahash *tx_tfm_michael;
 	/* scratch buffers for virt_to_page() (crypto API) */
 	u8 rx_hdr[16];
 	u8 tx_hdr[16];
@@ -65,32 +66,32 @@ static void *rtllib_tkip_init(int key_idx)
 	if (priv == NULL)
 		goto fail;
 	priv->key_idx = key_idx;
-	priv->tx_tfm_arc4 = crypto_alloc_blkcipher("ecb(arc4)", 0,
-			CRYPTO_ALG_ASYNC);
+	priv->tx_tfm_arc4 = crypto_alloc_skcipher("ecb(arc4)", 0,
+						  CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->tx_tfm_arc4)) {
 		pr_debug("Could not allocate crypto API arc4\n");
 		priv->tx_tfm_arc4 = NULL;
 		goto fail;
 	}
 
-	priv->tx_tfm_michael = crypto_alloc_hash("michael_mic", 0,
-			CRYPTO_ALG_ASYNC);
+	priv->tx_tfm_michael = crypto_alloc_ahash("michael_mic", 0,
+						  CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->tx_tfm_michael)) {
 		pr_debug("Could not allocate crypto API michael_mic\n");
 		priv->tx_tfm_michael = NULL;
 		goto fail;
 	}
 
-	priv->rx_tfm_arc4 = crypto_alloc_blkcipher("ecb(arc4)", 0,
-			CRYPTO_ALG_ASYNC);
+	priv->rx_tfm_arc4 = crypto_alloc_skcipher("ecb(arc4)", 0,
+						  CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->rx_tfm_arc4)) {
 		pr_debug("Could not allocate crypto API arc4\n");
 		priv->rx_tfm_arc4 = NULL;
 		goto fail;
 	}
 
-	priv->rx_tfm_michael = crypto_alloc_hash("michael_mic", 0,
-			CRYPTO_ALG_ASYNC);
+	priv->rx_tfm_michael = crypto_alloc_ahash("michael_mic", 0,
+						  CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->rx_tfm_michael)) {
 		pr_debug("Could not allocate crypto API michael_mic\n");
 		priv->rx_tfm_michael = NULL;
@@ -100,14 +101,10 @@ static void *rtllib_tkip_init(int key_idx)
 
 fail:
 	if (priv) {
-		if (priv->tx_tfm_michael)
-			crypto_free_hash(priv->tx_tfm_michael);
-		if (priv->tx_tfm_arc4)
-			crypto_free_blkcipher(priv->tx_tfm_arc4);
-		if (priv->rx_tfm_michael)
-			crypto_free_hash(priv->rx_tfm_michael);
-		if (priv->rx_tfm_arc4)
-			crypto_free_blkcipher(priv->rx_tfm_arc4);
+		crypto_free_ahash(priv->tx_tfm_michael);
+		crypto_free_skcipher(priv->tx_tfm_arc4);
+		crypto_free_ahash(priv->rx_tfm_michael);
+		crypto_free_skcipher(priv->rx_tfm_arc4);
 		kfree(priv);
 	}
 
@@ -120,14 +117,10 @@ static void rtllib_tkip_deinit(void *priv)
 	struct rtllib_tkip_data *_priv = priv;
 
 	if (_priv) {
-		if (_priv->tx_tfm_michael)
-			crypto_free_hash(_priv->tx_tfm_michael);
-		if (_priv->tx_tfm_arc4)
-			crypto_free_blkcipher(_priv->tx_tfm_arc4);
-		if (_priv->rx_tfm_michael)
-			crypto_free_hash(_priv->rx_tfm_michael);
-		if (_priv->rx_tfm_arc4)
-			crypto_free_blkcipher(_priv->rx_tfm_arc4);
+		crypto_free_ahash(_priv->tx_tfm_michael);
+		crypto_free_skcipher(_priv->tx_tfm_arc4);
+		crypto_free_ahash(_priv->rx_tfm_michael);
+		crypto_free_skcipher(_priv->rx_tfm_arc4);
 	}
 	kfree(priv);
 }
@@ -301,7 +294,6 @@ static int rtllib_tkip_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	struct rtllib_hdr_4addr *hdr;
 	struct cb_desc *tcb_desc = (struct cb_desc *)(skb->cb +
 				    MAX_DEV_ADDR_SIZE);
-	struct blkcipher_desc desc = {.tfm = tkey->tx_tfm_arc4};
 	int ret = 0;
 	u8 rc4key[16],  *icv;
 	u32 crc;
@@ -347,6 +339,8 @@ static int rtllib_tkip_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	*pos++ = (tkey->tx_iv32 >> 24) & 0xff;
 
 	if (!tcb_desc->bHwSec) {
+		SKCIPHER_REQUEST_ON_STACK(req, tkey->tx_tfm_arc4);
+
 		icv = skb_put(skb, 4);
 		crc = ~crc32_le(~0, pos, len);
 		icv[0] = crc;
@@ -357,8 +351,12 @@ static int rtllib_tkip_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
 		sg_init_one(&sg, pos, len+4);
 
 
-		crypto_blkcipher_setkey(tkey->tx_tfm_arc4, rc4key, 16);
-		ret = crypto_blkcipher_encrypt(&desc, &sg, &sg, len + 4);
+		crypto_skcipher_setkey(tkey->tx_tfm_arc4, rc4key, 16);
+		skcipher_request_set_tfm(req, tkey->tx_tfm_arc4);
+		skcipher_request_set_callback(req, 0, NULL, NULL);
+		skcipher_request_set_crypt(req, &sg, &sg, len + 4, NULL);
+		ret = crypto_skcipher_encrypt(req);
+		skcipher_request_zero(req);
 	}
 
 	tkey->tx_iv16++;
@@ -384,12 +382,12 @@ static int rtllib_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	struct rtllib_hdr_4addr *hdr;
 	struct cb_desc *tcb_desc = (struct cb_desc *)(skb->cb +
 				    MAX_DEV_ADDR_SIZE);
-	struct blkcipher_desc desc = {.tfm = tkey->rx_tfm_arc4};
 	u8 rc4key[16];
 	u8 icv[4];
 	u32 crc;
 	struct scatterlist sg;
 	int plen;
+	int err;
 
 	if (skb->len < hdr_len + 8 + 4)
 		return -1;
@@ -425,6 +423,8 @@ static int rtllib_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	pos += 8;
 
 	if (!tcb_desc->bHwSec || (skb->cb[0] == 1)) {
+		SKCIPHER_REQUEST_ON_STACK(req, tkey->rx_tfm_arc4);
+
 		if ((iv32 < tkey->rx_iv32 ||
 		    (iv32 == tkey->rx_iv32 && iv16 <= tkey->rx_iv16)) &&
 		    tkey->initialized) {
@@ -450,8 +450,13 @@ static int rtllib_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 
 		sg_init_one(&sg, pos, plen+4);
 
-		crypto_blkcipher_setkey(tkey->rx_tfm_arc4, rc4key, 16);
-		if (crypto_blkcipher_decrypt(&desc, &sg, &sg, plen + 4)) {
+		crypto_skcipher_setkey(tkey->rx_tfm_arc4, rc4key, 16);
+		skcipher_request_set_tfm(req, tkey->rx_tfm_arc4);
+		skcipher_request_set_callback(req, 0, NULL, NULL);
+		skcipher_request_set_crypt(req, &sg, &sg, plen + 4, NULL);
+		err = crypto_skcipher_decrypt(req);
+		skcipher_request_zero(req);
+		if (err) {
 			if (net_ratelimit()) {
 				netdev_dbg(skb->dev,
 					   "Failed to decrypt received packet from %pM\n",
@@ -500,11 +505,12 @@ static int rtllib_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 }
 
 
-static int michael_mic(struct crypto_hash *tfm_michael, u8 *key, u8 *hdr,
+static int michael_mic(struct crypto_ahash *tfm_michael, u8 *key, u8 *hdr,
 		       u8 *data, size_t data_len, u8 *mic)
 {
-	struct hash_desc desc;
+	AHASH_REQUEST_ON_STACK(req, tfm_michael);
 	struct scatterlist sg[2];
+	int err;
 
 	if (tfm_michael == NULL) {
 		pr_warn("michael_mic: tfm_michael == NULL\n");
@@ -514,12 +520,15 @@ static int michael_mic(struct crypto_hash *tfm_michael, u8 *key, u8 *hdr,
 	sg_set_buf(&sg[0], hdr, 16);
 	sg_set_buf(&sg[1], data, data_len);
 
-	if (crypto_hash_setkey(tfm_michael, key, 8))
+	if (crypto_ahash_setkey(tfm_michael, key, 8))
 		return -1;
 
-	desc.tfm = tfm_michael;
-	desc.flags = 0;
-	return crypto_hash_digest(&desc, sg, data_len + 16, mic);
+	ahash_request_set_tfm(req, tfm_michael);
+	ahash_request_set_callback(req, 0, NULL, NULL);
+	ahash_request_set_crypt(req, sg, mic, data_len + 16);
+	err = crypto_ahash_digest(req);
+	ahash_request_zero(req);
+	return err;
 }
 
 static void michael_mic_hdr(struct sk_buff *skb, u8 *hdr)
@@ -655,10 +664,10 @@ static int rtllib_tkip_set_key(void *key, int len, u8 *seq, void *priv)
 {
 	struct rtllib_tkip_data *tkey = priv;
 	int keyidx;
-	struct crypto_hash *tfm = tkey->tx_tfm_michael;
-	struct crypto_blkcipher *tfm2 = tkey->tx_tfm_arc4;
-	struct crypto_hash *tfm3 = tkey->rx_tfm_michael;
-	struct crypto_blkcipher *tfm4 = tkey->rx_tfm_arc4;
+	struct crypto_ahash *tfm = tkey->tx_tfm_michael;
+	struct crypto_skcipher *tfm2 = tkey->tx_tfm_arc4;
+	struct crypto_ahash *tfm3 = tkey->rx_tfm_michael;
+	struct crypto_skcipher *tfm4 = tkey->rx_tfm_arc4;
 
 	keyidx = tkey->key_idx;
 	memset(tkey, 0, sizeof(*tkey));
diff --git a/drivers/staging/rtl8192e/rtllib_crypt_wep.c b/drivers/staging/rtl8192e/rtllib_crypt_wep.c
index 21d7eee..b3343a5 100644
--- a/drivers/staging/rtl8192e/rtllib_crypt_wep.c
+++ b/drivers/staging/rtl8192e/rtllib_crypt_wep.c
@@ -9,6 +9,7 @@
  * more details.
  */
 
+#include <crypto/skcipher.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/slab.h>
@@ -17,8 +18,6 @@
 #include <linux/string.h>
 #include "rtllib.h"
 
-#include <linux/crypto.h>
-
 #include <linux/scatterlist.h>
 #include <linux/crc32.h>
 
@@ -28,8 +27,8 @@ struct prism2_wep_data {
 	u8 key[WEP_KEY_LEN + 1];
 	u8 key_len;
 	u8 key_idx;
-	struct crypto_blkcipher *tx_tfm;
-	struct crypto_blkcipher *rx_tfm;
+	struct crypto_skcipher *tx_tfm;
+	struct crypto_skcipher *rx_tfm;
 };
 
 
@@ -42,13 +41,13 @@ static void *prism2_wep_init(int keyidx)
 		goto fail;
 	priv->key_idx = keyidx;
 
-	priv->tx_tfm = crypto_alloc_blkcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
+	priv->tx_tfm = crypto_alloc_skcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->tx_tfm)) {
 		pr_debug("rtllib_crypt_wep: could not allocate crypto API arc4\n");
 		priv->tx_tfm = NULL;
 		goto fail;
 	}
-	priv->rx_tfm = crypto_alloc_blkcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
+	priv->rx_tfm = crypto_alloc_skcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->rx_tfm)) {
 		pr_debug("rtllib_crypt_wep: could not allocate crypto API arc4\n");
 		priv->rx_tfm = NULL;
@@ -62,10 +61,8 @@ static void *prism2_wep_init(int keyidx)
 
 fail:
 	if (priv) {
-		if (priv->tx_tfm)
-			crypto_free_blkcipher(priv->tx_tfm);
-		if (priv->rx_tfm)
-			crypto_free_blkcipher(priv->rx_tfm);
+		crypto_free_skcipher(priv->tx_tfm);
+		crypto_free_skcipher(priv->rx_tfm);
 		kfree(priv);
 	}
 	return NULL;
@@ -77,10 +74,8 @@ static void prism2_wep_deinit(void *priv)
 	struct prism2_wep_data *_priv = priv;
 
 	if (_priv) {
-		if (_priv->tx_tfm)
-			crypto_free_blkcipher(_priv->tx_tfm);
-		if (_priv->rx_tfm)
-			crypto_free_blkcipher(_priv->rx_tfm);
+		crypto_free_skcipher(_priv->tx_tfm);
+		crypto_free_skcipher(_priv->rx_tfm);
 	}
 	kfree(priv);
 }
@@ -99,10 +94,10 @@ static int prism2_wep_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	u8 *pos;
 	struct cb_desc *tcb_desc = (struct cb_desc *)(skb->cb +
 				    MAX_DEV_ADDR_SIZE);
-	struct blkcipher_desc desc = {.tfm = wep->tx_tfm};
 	u32 crc;
 	u8 *icv;
 	struct scatterlist sg;
+	int err;
 
 	if (skb_headroom(skb) < 4 || skb_tailroom(skb) < 4 ||
 	    skb->len < hdr_len){
@@ -140,6 +135,7 @@ static int prism2_wep_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	memcpy(key + 3, wep->key, wep->key_len);
 
 	if (!tcb_desc->bHwSec) {
+		SKCIPHER_REQUEST_ON_STACK(req, wep->tx_tfm);
 
 		/* Append little-endian CRC32 and encrypt it to produce ICV */
 		crc = ~crc32_le(~0, pos, len);
@@ -150,8 +146,13 @@ static int prism2_wep_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
 		icv[3] = crc >> 24;
 
 		sg_init_one(&sg, pos, len+4);
-		crypto_blkcipher_setkey(wep->tx_tfm, key, klen);
-		return crypto_blkcipher_encrypt(&desc, &sg, &sg, len + 4);
+		crypto_skcipher_setkey(wep->tx_tfm, key, klen);
+		skcipher_request_set_tfm(req, wep->tx_tfm);
+		skcipher_request_set_callback(req, 0, NULL, NULL);
+		skcipher_request_set_crypt(req, &sg, &sg, len + 4, NULL);
+		err = crypto_skcipher_encrypt(req);
+		skcipher_request_zero(req);
+		return err;
 	}
 
 	return 0;
@@ -173,10 +174,10 @@ static int prism2_wep_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	u8 keyidx, *pos;
 	struct cb_desc *tcb_desc = (struct cb_desc *)(skb->cb +
 				    MAX_DEV_ADDR_SIZE);
-	struct blkcipher_desc desc = {.tfm = wep->rx_tfm};
 	u32 crc;
 	u8 icv[4];
 	struct scatterlist sg;
+	int err;
 
 	if (skb->len < hdr_len + 8)
 		return -1;
@@ -198,9 +199,16 @@ static int prism2_wep_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	plen = skb->len - hdr_len - 8;
 
 	if (!tcb_desc->bHwSec) {
+		SKCIPHER_REQUEST_ON_STACK(req, wep->rx_tfm);
+
 		sg_init_one(&sg, pos, plen+4);
-		crypto_blkcipher_setkey(wep->rx_tfm, key, klen);
-		if (crypto_blkcipher_decrypt(&desc, &sg, &sg, plen + 4))
+		crypto_skcipher_setkey(wep->rx_tfm, key, klen);
+		skcipher_request_set_tfm(req, wep->rx_tfm);
+		skcipher_request_set_callback(req, 0, NULL, NULL);
+		skcipher_request_set_crypt(req, &sg, &sg, plen + 4, NULL);
+		err = crypto_skcipher_decrypt(req);
+		skcipher_request_zero(req);
+		if (err)
 			return -7;
 		crc = ~crc32_le(~0, pos, plen);
 		icv[0] = crc;
