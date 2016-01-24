Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:57424 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243AbcAXNSr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:18:47 -0500
Subject: [PATCH 13/26] lib80211: Use skcipher and ahash
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
Message-Id: <E1aNKYT-0008DG-My@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:18:09 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of blkcipher with skcipher and the long
obsolete hash interface with ahash.
   
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/wireless/lib80211_crypt_tkip.c |   99 ++++++++++++++++++++-----------------
 net/wireless/lib80211_crypt_wep.c  |   46 ++++++++++-------
 2 files changed, 81 insertions(+), 64 deletions(-)

diff --git a/net/wireless/lib80211_crypt_tkip.c b/net/wireless/lib80211_crypt_tkip.c
index 3cd8195..71447cf 100644
--- a/net/wireless/lib80211_crypt_tkip.c
+++ b/net/wireless/lib80211_crypt_tkip.c
@@ -29,7 +29,8 @@
 #include <linux/ieee80211.h>
 #include <net/iw_handler.h>
 
-#include <linux/crypto.h>
+#include <crypto/hash.h>
+#include <crypto/skcipher.h>
 #include <linux/crc32.h>
 
 #include <net/lib80211.h>
@@ -63,10 +64,10 @@ struct lib80211_tkip_data {
 
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
 	u8 rx_hdr[16], tx_hdr[16];
@@ -98,29 +99,29 @@ static void *lib80211_tkip_init(int key_idx)
 
 	priv->key_idx = key_idx;
 
-	priv->tx_tfm_arc4 = crypto_alloc_blkcipher("ecb(arc4)", 0,
-						CRYPTO_ALG_ASYNC);
+	priv->tx_tfm_arc4 = crypto_alloc_skcipher("ecb(arc4)", 0,
+						  CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->tx_tfm_arc4)) {
 		priv->tx_tfm_arc4 = NULL;
 		goto fail;
 	}
 
-	priv->tx_tfm_michael = crypto_alloc_hash("michael_mic", 0,
-						 CRYPTO_ALG_ASYNC);
+	priv->tx_tfm_michael = crypto_alloc_ahash("michael_mic", 0,
+						  CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->tx_tfm_michael)) {
 		priv->tx_tfm_michael = NULL;
 		goto fail;
 	}
 
-	priv->rx_tfm_arc4 = crypto_alloc_blkcipher("ecb(arc4)", 0,
-						CRYPTO_ALG_ASYNC);
+	priv->rx_tfm_arc4 = crypto_alloc_skcipher("ecb(arc4)", 0,
+						  CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->rx_tfm_arc4)) {
 		priv->rx_tfm_arc4 = NULL;
 		goto fail;
 	}
 
-	priv->rx_tfm_michael = crypto_alloc_hash("michael_mic", 0,
-						 CRYPTO_ALG_ASYNC);
+	priv->rx_tfm_michael = crypto_alloc_ahash("michael_mic", 0,
+						  CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->rx_tfm_michael)) {
 		priv->rx_tfm_michael = NULL;
 		goto fail;
@@ -130,14 +131,10 @@ static void *lib80211_tkip_init(int key_idx)
 
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
 
@@ -148,14 +145,10 @@ static void lib80211_tkip_deinit(void *priv)
 {
 	struct lib80211_tkip_data *_priv = priv;
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
@@ -353,11 +346,12 @@ static int lib80211_tkip_hdr(struct sk_buff *skb, int hdr_len,
 static int lib80211_tkip_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
 {
 	struct lib80211_tkip_data *tkey = priv;
-	struct blkcipher_desc desc = { .tfm = tkey->tx_tfm_arc4 };
+	SKCIPHER_REQUEST_ON_STACK(req, tkey->tx_tfm_arc4);
 	int len;
 	u8 rc4key[16], *pos, *icv;
 	u32 crc;
 	struct scatterlist sg;
+	int err;
 
 	if (tkey->flags & IEEE80211_CRYPTO_TKIP_COUNTERMEASURES) {
 		struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
@@ -382,9 +376,14 @@ static int lib80211_tkip_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	icv[2] = crc >> 16;
 	icv[3] = crc >> 24;
 
-	crypto_blkcipher_setkey(tkey->tx_tfm_arc4, rc4key, 16);
+	crypto_skcipher_setkey(tkey->tx_tfm_arc4, rc4key, 16);
 	sg_init_one(&sg, pos, len + 4);
-	return crypto_blkcipher_encrypt(&desc, &sg, &sg, len + 4);
+	skcipher_request_set_tfm(req, tkey->tx_tfm_arc4);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, &sg, &sg, len + 4, NULL);
+	err = crypto_skcipher_encrypt(req);
+	skcipher_request_zero(req);
+	return err;
 }
 
 /*
@@ -403,7 +402,7 @@ static inline int tkip_replay_check(u32 iv32_n, u16 iv16_n,
 static int lib80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 {
 	struct lib80211_tkip_data *tkey = priv;
-	struct blkcipher_desc desc = { .tfm = tkey->rx_tfm_arc4 };
+	SKCIPHER_REQUEST_ON_STACK(req, tkey->rx_tfm_arc4);
 	u8 rc4key[16];
 	u8 keyidx, *pos;
 	u32 iv32;
@@ -413,6 +412,7 @@ static int lib80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	u32 crc;
 	struct scatterlist sg;
 	int plen;
+	int err;
 
 	hdr = (struct ieee80211_hdr *)skb->data;
 
@@ -465,9 +465,14 @@ static int lib80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 
 	plen = skb->len - hdr_len - 12;
 
-	crypto_blkcipher_setkey(tkey->rx_tfm_arc4, rc4key, 16);
+	crypto_skcipher_setkey(tkey->rx_tfm_arc4, rc4key, 16);
 	sg_init_one(&sg, pos, plen + 4);
-	if (crypto_blkcipher_decrypt(&desc, &sg, &sg, plen + 4)) {
+	skcipher_request_set_tfm(req, tkey->rx_tfm_arc4);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, &sg, &sg, plen + 4, NULL);
+	err = crypto_skcipher_decrypt(req);
+	skcipher_request_zero(req);
+	if (err) {
 		net_dbg_ratelimited("TKIP: failed to decrypt received packet from %pM\n",
 				    hdr->addr2);
 		return -7;
@@ -505,11 +510,12 @@ static int lib80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	return keyidx;
 }
 
-static int michael_mic(struct crypto_hash *tfm_michael, u8 * key, u8 * hdr,
+static int michael_mic(struct crypto_ahash *tfm_michael, u8 * key, u8 * hdr,
 		       u8 * data, size_t data_len, u8 * mic)
 {
-	struct hash_desc desc;
+	AHASH_REQUEST_ON_STACK(req, tfm_michael);
 	struct scatterlist sg[2];
+	int err;
 
 	if (tfm_michael == NULL) {
 		pr_warn("%s(): tfm_michael == NULL\n", __func__);
@@ -519,12 +525,15 @@ static int michael_mic(struct crypto_hash *tfm_michael, u8 * key, u8 * hdr,
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
 
 static void michael_mic_hdr(struct sk_buff *skb, u8 * hdr)
@@ -645,10 +654,10 @@ static int lib80211_tkip_set_key(void *key, int len, u8 * seq, void *priv)
 {
 	struct lib80211_tkip_data *tkey = priv;
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
diff --git a/net/wireless/lib80211_crypt_wep.c b/net/wireless/lib80211_crypt_wep.c
index 1c292e4..d05f58b 100644
--- a/net/wireless/lib80211_crypt_wep.c
+++ b/net/wireless/lib80211_crypt_wep.c
@@ -22,7 +22,7 @@
 
 #include <net/lib80211.h>
 
-#include <linux/crypto.h>
+#include <crypto/skcipher.h>
 #include <linux/crc32.h>
 
 MODULE_AUTHOR("Jouni Malinen");
@@ -35,8 +35,8 @@ struct lib80211_wep_data {
 	u8 key[WEP_KEY_LEN + 1];
 	u8 key_len;
 	u8 key_idx;
-	struct crypto_blkcipher *tx_tfm;
-	struct crypto_blkcipher *rx_tfm;
+	struct crypto_skcipher *tx_tfm;
+	struct crypto_skcipher *rx_tfm;
 };
 
 static void *lib80211_wep_init(int keyidx)
@@ -48,13 +48,13 @@ static void *lib80211_wep_init(int keyidx)
 		goto fail;
 	priv->key_idx = keyidx;
 
-	priv->tx_tfm = crypto_alloc_blkcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
+	priv->tx_tfm = crypto_alloc_skcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->tx_tfm)) {
 		priv->tx_tfm = NULL;
 		goto fail;
 	}
 
-	priv->rx_tfm = crypto_alloc_blkcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
+	priv->rx_tfm = crypto_alloc_skcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->rx_tfm)) {
 		priv->rx_tfm = NULL;
 		goto fail;
@@ -66,10 +66,8 @@ static void *lib80211_wep_init(int keyidx)
 
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
@@ -79,10 +77,8 @@ static void lib80211_wep_deinit(void *priv)
 {
 	struct lib80211_wep_data *_priv = priv;
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
@@ -133,11 +129,12 @@ static int lib80211_wep_build_iv(struct sk_buff *skb, int hdr_len,
 static int lib80211_wep_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
 {
 	struct lib80211_wep_data *wep = priv;
-	struct blkcipher_desc desc = { .tfm = wep->tx_tfm };
+	SKCIPHER_REQUEST_ON_STACK(req, wep->tx_tfm);
 	u32 crc, klen, len;
 	u8 *pos, *icv;
 	struct scatterlist sg;
 	u8 key[WEP_KEY_LEN + 3];
+	int err;
 
 	/* other checks are in lib80211_wep_build_iv */
 	if (skb_tailroom(skb) < 4)
@@ -165,9 +162,14 @@ static int lib80211_wep_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	icv[2] = crc >> 16;
 	icv[3] = crc >> 24;
 
-	crypto_blkcipher_setkey(wep->tx_tfm, key, klen);
+	crypto_skcipher_setkey(wep->tx_tfm, key, klen);
 	sg_init_one(&sg, pos, len + 4);
-	return crypto_blkcipher_encrypt(&desc, &sg, &sg, len + 4);
+	skcipher_request_set_tfm(req, wep->tx_tfm);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, &sg, &sg, len + 4, NULL);
+	err = crypto_skcipher_encrypt(req);
+	skcipher_request_zero(req);
+	return err;
 }
 
 /* Perform WEP decryption on given buffer. Buffer includes whole WEP part of
@@ -180,11 +182,12 @@ static int lib80211_wep_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
 static int lib80211_wep_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 {
 	struct lib80211_wep_data *wep = priv;
-	struct blkcipher_desc desc = { .tfm = wep->rx_tfm };
+	SKCIPHER_REQUEST_ON_STACK(req, wep->rx_tfm);
 	u32 crc, klen, plen;
 	u8 key[WEP_KEY_LEN + 3];
 	u8 keyidx, *pos, icv[4];
 	struct scatterlist sg;
+	int err;
 
 	if (skb->len < hdr_len + 8)
 		return -1;
@@ -205,9 +208,14 @@ static int lib80211_wep_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	/* Apply RC4 to data and compute CRC32 over decrypted data */
 	plen = skb->len - hdr_len - 8;
 
-	crypto_blkcipher_setkey(wep->rx_tfm, key, klen);
+	crypto_skcipher_setkey(wep->rx_tfm, key, klen);
 	sg_init_one(&sg, pos, plen + 4);
-	if (crypto_blkcipher_decrypt(&desc, &sg, &sg, plen + 4))
+	skcipher_request_set_tfm(req, wep->rx_tfm);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, &sg, &sg, plen + 4, NULL);
+	err = crypto_skcipher_decrypt(req);
+	skcipher_request_zero(req);
+	if (err)
 		return -7;
 
 	crc = ~crc32_le(~0, pos, plen);
