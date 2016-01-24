Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:37240 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753418AbcAXNTH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:19:07 -0500
Subject: [PATCH 15/26] Bluetooth: Use skcipher and hash
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
Message-Id: <E1aNKYo-0008Dp-5h@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:18:30 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of blkcipher with skcipher and the long
obsolete hash interface with shash.
   
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bluetooth/smp.c |  135 ++++++++++++++++++++++++----------------------------
 1 file changed, 63 insertions(+), 72 deletions(-)

diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index ffed8a1..78ad7d6 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -21,9 +21,10 @@
 */
 
 #include <linux/debugfs.h>
-#include <linux/crypto.h>
 #include <linux/scatterlist.h>
 #include <crypto/b128ops.h>
+#include <crypto/hash.h>
+#include <crypto/skcipher.h>
 
 #include <net/bluetooth/bluetooth.h>
 #include <net/bluetooth/hci_core.h>
@@ -87,8 +88,8 @@ struct smp_dev {
 	u8			min_key_size;
 	u8			max_key_size;
 
-	struct crypto_blkcipher	*tfm_aes;
-	struct crypto_hash	*tfm_cmac;
+	struct crypto_skcipher	*tfm_aes;
+	struct crypto_shash	*tfm_cmac;
 };
 
 struct smp_chan {
@@ -126,8 +127,8 @@ struct smp_chan {
 	u8			dhkey[32];
 	u8			mackey[16];
 
-	struct crypto_blkcipher	*tfm_aes;
-	struct crypto_hash	*tfm_cmac;
+	struct crypto_skcipher	*tfm_aes;
+	struct crypto_shash	*tfm_cmac;
 };
 
 /* These debug key values are defined in the SMP section of the core
@@ -165,12 +166,11 @@ static inline void swap_buf(const u8 *src, u8 *dst, size_t len)
  * AES-CMAC, f4, f5, f6, g2 and h6.
  */
 
-static int aes_cmac(struct crypto_hash *tfm, const u8 k[16], const u8 *m,
+static int aes_cmac(struct crypto_shash *tfm, const u8 k[16], const u8 *m,
 		    size_t len, u8 mac[16])
 {
 	uint8_t tmp[16], mac_msb[16], msg_msb[CMAC_MSG_MAX];
-	struct hash_desc desc;
-	struct scatterlist sg;
+	SHASH_DESC_ON_STACK(desc, tfm);
 	int err;
 
 	if (len > CMAC_MSG_MAX)
@@ -181,10 +181,8 @@ static int aes_cmac(struct crypto_hash *tfm, const u8 k[16], const u8 *m,
 		return -EINVAL;
 	}
 
-	desc.tfm = tfm;
-	desc.flags = 0;
-
-	crypto_hash_init(&desc);
+	desc->tfm = tfm;
+	desc->flags = 0;
 
 	/* Swap key and message from LSB to MSB */
 	swap_buf(k, tmp, 16);
@@ -193,23 +191,16 @@ static int aes_cmac(struct crypto_hash *tfm, const u8 k[16], const u8 *m,
 	SMP_DBG("msg (len %zu) %*phN", len, (int) len, m);
 	SMP_DBG("key %16phN", k);
 
-	err = crypto_hash_setkey(tfm, tmp, 16);
+	err = crypto_shash_setkey(tfm, tmp, 16);
 	if (err) {
 		BT_ERR("cipher setkey failed: %d", err);
 		return err;
 	}
 
-	sg_init_one(&sg, msg_msb, len);
-
-	err = crypto_hash_update(&desc, &sg, len);
+	err = crypto_shash_digest(desc, msg_msb, len, mac_msb);
+	shash_desc_zero(desc);
 	if (err) {
-		BT_ERR("Hash update error %d", err);
-		return err;
-	}
-
-	err = crypto_hash_final(&desc, mac_msb);
-	if (err) {
-		BT_ERR("Hash final error %d", err);
+		BT_ERR("Hash computation error %d", err);
 		return err;
 	}
 
@@ -220,8 +211,8 @@ static int aes_cmac(struct crypto_hash *tfm, const u8 k[16], const u8 *m,
 	return 0;
 }
 
-static int smp_f4(struct crypto_hash *tfm_cmac, const u8 u[32], const u8 v[32],
-		  const u8 x[16], u8 z, u8 res[16])
+static int smp_f4(struct crypto_shash *tfm_cmac, const u8 u[32],
+		  const u8 v[32], const u8 x[16], u8 z, u8 res[16])
 {
 	u8 m[65];
 	int err;
@@ -243,7 +234,7 @@ static int smp_f4(struct crypto_hash *tfm_cmac, const u8 u[32], const u8 v[32],
 	return err;
 }
 
-static int smp_f5(struct crypto_hash *tfm_cmac, const u8 w[32],
+static int smp_f5(struct crypto_shash *tfm_cmac, const u8 w[32],
 		  const u8 n1[16], const u8 n2[16], const u8 a1[7],
 		  const u8 a2[7], u8 mackey[16], u8 ltk[16])
 {
@@ -296,7 +287,7 @@ static int smp_f5(struct crypto_hash *tfm_cmac, const u8 w[32],
 	return 0;
 }
 
-static int smp_f6(struct crypto_hash *tfm_cmac, const u8 w[16],
+static int smp_f6(struct crypto_shash *tfm_cmac, const u8 w[16],
 		  const u8 n1[16], const u8 n2[16], const u8 r[16],
 		  const u8 io_cap[3], const u8 a1[7], const u8 a2[7],
 		  u8 res[16])
@@ -324,7 +315,7 @@ static int smp_f6(struct crypto_hash *tfm_cmac, const u8 w[16],
 	return err;
 }
 
-static int smp_g2(struct crypto_hash *tfm_cmac, const u8 u[32], const u8 v[32],
+static int smp_g2(struct crypto_shash *tfm_cmac, const u8 u[32], const u8 v[32],
 		  const u8 x[16], const u8 y[16], u32 *val)
 {
 	u8 m[80], tmp[16];
@@ -350,7 +341,7 @@ static int smp_g2(struct crypto_hash *tfm_cmac, const u8 u[32], const u8 v[32],
 	return 0;
 }
 
-static int smp_h6(struct crypto_hash *tfm_cmac, const u8 w[16],
+static int smp_h6(struct crypto_shash *tfm_cmac, const u8 w[16],
 		  const u8 key_id[4], u8 res[16])
 {
 	int err;
@@ -370,9 +361,9 @@ static int smp_h6(struct crypto_hash *tfm_cmac, const u8 w[16],
  * s1 and ah.
  */
 
-static int smp_e(struct crypto_blkcipher *tfm, const u8 *k, u8 *r)
+static int smp_e(struct crypto_skcipher *tfm, const u8 *k, u8 *r)
 {
-	struct blkcipher_desc desc;
+	SKCIPHER_REQUEST_ON_STACK(req, tfm);
 	struct scatterlist sg;
 	uint8_t tmp[16], data[16];
 	int err;
@@ -384,13 +375,10 @@ static int smp_e(struct crypto_blkcipher *tfm, const u8 *k, u8 *r)
 		return -EINVAL;
 	}
 
-	desc.tfm = tfm;
-	desc.flags = 0;
-
 	/* The most significant octet of key corresponds to k[0] */
 	swap_buf(k, tmp, 16);
 
-	err = crypto_blkcipher_setkey(tfm, tmp, 16);
+	err = crypto_skcipher_setkey(tfm, tmp, 16);
 	if (err) {
 		BT_ERR("cipher setkey failed: %d", err);
 		return err;
@@ -401,7 +389,12 @@ static int smp_e(struct crypto_blkcipher *tfm, const u8 *k, u8 *r)
 
 	sg_init_one(&sg, data, 16);
 
-	err = crypto_blkcipher_encrypt(&desc, &sg, &sg, 16);
+	skcipher_request_set_tfm(req, tfm);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, &sg, &sg, 16, NULL);
+
+	err = crypto_skcipher_encrypt(req);
+	skcipher_request_zero(req);
 	if (err)
 		BT_ERR("Encrypt data error %d", err);
 
@@ -413,7 +406,7 @@ static int smp_e(struct crypto_blkcipher *tfm, const u8 *k, u8 *r)
 	return err;
 }
 
-static int smp_c1(struct crypto_blkcipher *tfm_aes, const u8 k[16],
+static int smp_c1(struct crypto_skcipher *tfm_aes, const u8 k[16],
 		  const u8 r[16], const u8 preq[7], const u8 pres[7], u8 _iat,
 		  const bdaddr_t *ia, u8 _rat, const bdaddr_t *ra, u8 res[16])
 {
@@ -462,7 +455,7 @@ static int smp_c1(struct crypto_blkcipher *tfm_aes, const u8 k[16],
 	return err;
 }
 
-static int smp_s1(struct crypto_blkcipher *tfm_aes, const u8 k[16],
+static int smp_s1(struct crypto_skcipher *tfm_aes, const u8 k[16],
 		  const u8 r1[16], const u8 r2[16], u8 _r[16])
 {
 	int err;
@@ -478,7 +471,7 @@ static int smp_s1(struct crypto_blkcipher *tfm_aes, const u8 k[16],
 	return err;
 }
 
-static int smp_ah(struct crypto_blkcipher *tfm, const u8 irk[16],
+static int smp_ah(struct crypto_skcipher *tfm, const u8 irk[16],
 		  const u8 r[3], u8 res[3])
 {
 	u8 _res[16];
@@ -766,8 +759,8 @@ static void smp_chan_destroy(struct l2cap_conn *conn)
 	kzfree(smp->slave_csrk);
 	kzfree(smp->link_key);
 
-	crypto_free_blkcipher(smp->tfm_aes);
-	crypto_free_hash(smp->tfm_cmac);
+	crypto_free_skcipher(smp->tfm_aes);
+	crypto_free_shash(smp->tfm_cmac);
 
 	/* Ensure that we don't leave any debug key around if debug key
 	 * support hasn't been explicitly enabled.
@@ -1382,17 +1375,17 @@ static struct smp_chan *smp_chan_create(struct l2cap_conn *conn)
 	if (!smp)
 		return NULL;
 
-	smp->tfm_aes = crypto_alloc_blkcipher("ecb(aes)", 0, CRYPTO_ALG_ASYNC);
+	smp->tfm_aes = crypto_alloc_skcipher("ecb(aes)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(smp->tfm_aes)) {
 		BT_ERR("Unable to create ECB crypto context");
 		kzfree(smp);
 		return NULL;
 	}
 
-	smp->tfm_cmac = crypto_alloc_hash("cmac(aes)", 0, CRYPTO_ALG_ASYNC);
+	smp->tfm_cmac = crypto_alloc_shash("cmac(aes)", 0, 0);
 	if (IS_ERR(smp->tfm_cmac)) {
 		BT_ERR("Unable to create CMAC crypto context");
-		crypto_free_blkcipher(smp->tfm_aes);
+		crypto_free_skcipher(smp->tfm_aes);
 		kzfree(smp);
 		return NULL;
 	}
@@ -3143,8 +3136,8 @@ static struct l2cap_chan *smp_add_cid(struct hci_dev *hdev, u16 cid)
 {
 	struct l2cap_chan *chan;
 	struct smp_dev *smp;
-	struct crypto_blkcipher *tfm_aes;
-	struct crypto_hash *tfm_cmac;
+	struct crypto_skcipher *tfm_aes;
+	struct crypto_shash *tfm_cmac;
 
 	if (cid == L2CAP_CID_SMP_BREDR) {
 		smp = NULL;
@@ -3155,17 +3148,17 @@ static struct l2cap_chan *smp_add_cid(struct hci_dev *hdev, u16 cid)
 	if (!smp)
 		return ERR_PTR(-ENOMEM);
 
-	tfm_aes = crypto_alloc_blkcipher("ecb(aes)", 0, CRYPTO_ALG_ASYNC);
+	tfm_aes = crypto_alloc_skcipher("ecb(aes)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm_aes)) {
 		BT_ERR("Unable to create ECB crypto context");
 		kzfree(smp);
 		return ERR_CAST(tfm_aes);
 	}
 
-	tfm_cmac = crypto_alloc_hash("cmac(aes)", 0, CRYPTO_ALG_ASYNC);
+	tfm_cmac = crypto_alloc_shash("cmac(aes)", 0, 0);
 	if (IS_ERR(tfm_cmac)) {
 		BT_ERR("Unable to create CMAC crypto context");
-		crypto_free_blkcipher(tfm_aes);
+		crypto_free_skcipher(tfm_aes);
 		kzfree(smp);
 		return ERR_CAST(tfm_cmac);
 	}
@@ -3179,8 +3172,8 @@ create_chan:
 	chan = l2cap_chan_create();
 	if (!chan) {
 		if (smp) {
-			crypto_free_blkcipher(smp->tfm_aes);
-			crypto_free_hash(smp->tfm_cmac);
+			crypto_free_skcipher(smp->tfm_aes);
+			crypto_free_shash(smp->tfm_cmac);
 			kzfree(smp);
 		}
 		return ERR_PTR(-ENOMEM);
@@ -3226,10 +3219,8 @@ static void smp_del_chan(struct l2cap_chan *chan)
 	smp = chan->data;
 	if (smp) {
 		chan->data = NULL;
-		if (smp->tfm_aes)
-			crypto_free_blkcipher(smp->tfm_aes);
-		if (smp->tfm_cmac)
-			crypto_free_hash(smp->tfm_cmac);
+		crypto_free_skcipher(smp->tfm_aes);
+		crypto_free_shash(smp->tfm_cmac);
 		kzfree(smp);
 	}
 
@@ -3465,7 +3456,7 @@ void smp_unregister(struct hci_dev *hdev)
 
 #if IS_ENABLED(CONFIG_BT_SELFTEST_SMP)
 
-static int __init test_ah(struct crypto_blkcipher *tfm_aes)
+static int __init test_ah(struct crypto_skcipher *tfm_aes)
 {
 	const u8 irk[16] = {
 			0x9b, 0x7d, 0x39, 0x0a, 0xa6, 0x10, 0x10, 0x34,
@@ -3485,7 +3476,7 @@ static int __init test_ah(struct crypto_blkcipher *tfm_aes)
 	return 0;
 }
 
-static int __init test_c1(struct crypto_blkcipher *tfm_aes)
+static int __init test_c1(struct crypto_skcipher *tfm_aes)
 {
 	const u8 k[16] = {
 			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
@@ -3515,7 +3506,7 @@ static int __init test_c1(struct crypto_blkcipher *tfm_aes)
 	return 0;
 }
 
-static int __init test_s1(struct crypto_blkcipher *tfm_aes)
+static int __init test_s1(struct crypto_skcipher *tfm_aes)
 {
 	const u8 k[16] = {
 			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
@@ -3540,7 +3531,7 @@ static int __init test_s1(struct crypto_blkcipher *tfm_aes)
 	return 0;
 }
 
-static int __init test_f4(struct crypto_hash *tfm_cmac)
+static int __init test_f4(struct crypto_shash *tfm_cmac)
 {
 	const u8 u[32] = {
 			0xe6, 0x9d, 0x35, 0x0e, 0x48, 0x01, 0x03, 0xcc,
@@ -3572,7 +3563,7 @@ static int __init test_f4(struct crypto_hash *tfm_cmac)
 	return 0;
 }
 
-static int __init test_f5(struct crypto_hash *tfm_cmac)
+static int __init test_f5(struct crypto_shash *tfm_cmac)
 {
 	const u8 w[32] = {
 			0x98, 0xa6, 0xbf, 0x73, 0xf3, 0x34, 0x8d, 0x86,
@@ -3609,7 +3600,7 @@ static int __init test_f5(struct crypto_hash *tfm_cmac)
 	return 0;
 }
 
-static int __init test_f6(struct crypto_hash *tfm_cmac)
+static int __init test_f6(struct crypto_shash *tfm_cmac)
 {
 	const u8 w[16] = {
 			0x20, 0x6e, 0x63, 0xce, 0x20, 0x6a, 0x3f, 0xfd,
@@ -3642,7 +3633,7 @@ static int __init test_f6(struct crypto_hash *tfm_cmac)
 	return 0;
 }
 
-static int __init test_g2(struct crypto_hash *tfm_cmac)
+static int __init test_g2(struct crypto_shash *tfm_cmac)
 {
 	const u8 u[32] = {
 			0xe6, 0x9d, 0x35, 0x0e, 0x48, 0x01, 0x03, 0xcc,
@@ -3674,7 +3665,7 @@ static int __init test_g2(struct crypto_hash *tfm_cmac)
 	return 0;
 }
 
-static int __init test_h6(struct crypto_hash *tfm_cmac)
+static int __init test_h6(struct crypto_shash *tfm_cmac)
 {
 	const u8 w[16] = {
 			0x9b, 0x7d, 0x39, 0x0a, 0xa6, 0x10, 0x10, 0x34,
@@ -3711,8 +3702,8 @@ static const struct file_operations test_smp_fops = {
 	.llseek		= default_llseek,
 };
 
-static int __init run_selftests(struct crypto_blkcipher *tfm_aes,
-				struct crypto_hash *tfm_cmac)
+static int __init run_selftests(struct crypto_skcipher *tfm_aes,
+				struct crypto_shash *tfm_cmac)
 {
 	ktime_t calltime, delta, rettime;
 	unsigned long long duration;
@@ -3789,27 +3780,27 @@ done:
 
 int __init bt_selftest_smp(void)
 {
-	struct crypto_blkcipher *tfm_aes;
-	struct crypto_hash *tfm_cmac;
+	struct crypto_skcipher *tfm_aes;
+	struct crypto_shash *tfm_cmac;
 	int err;
 
-	tfm_aes = crypto_alloc_blkcipher("ecb(aes)", 0, CRYPTO_ALG_ASYNC);
+	tfm_aes = crypto_alloc_skcipher("ecb(aes)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm_aes)) {
 		BT_ERR("Unable to create ECB crypto context");
 		return PTR_ERR(tfm_aes);
 	}
 
-	tfm_cmac = crypto_alloc_hash("cmac(aes)", 0, CRYPTO_ALG_ASYNC);
+	tfm_cmac = crypto_alloc_shash("cmac(aes)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm_cmac)) {
 		BT_ERR("Unable to create CMAC crypto context");
-		crypto_free_blkcipher(tfm_aes);
+		crypto_free_skcipher(tfm_aes);
 		return PTR_ERR(tfm_cmac);
 	}
 
 	err = run_selftests(tfm_aes, tfm_cmac);
 
-	crypto_free_hash(tfm_cmac);
-	crypto_free_blkcipher(tfm_aes);
+	crypto_free_shash(tfm_cmac);
+	crypto_free_skcipher(tfm_aes);
 
 	return err;
 }
