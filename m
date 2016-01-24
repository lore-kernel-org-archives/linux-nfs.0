Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:43865 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100AbcAXNR4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:17:56 -0500
Subject: [PATCH 8/26] cifs: Use skcipher
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
Message-Id: <E1aNKXd-0008Bs-VK@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:17:17 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of blkcipher with skcipher.
    
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 fs/cifs/cifsencrypt.c |   32 +++++++++++++++++++++-----------
 fs/cifs/smbencrypt.c  |   26 +++++++++++++++++++-------
 2 files changed, 40 insertions(+), 18 deletions(-)

diff --git a/fs/cifs/cifsencrypt.c b/fs/cifs/cifsencrypt.c
index afa09fc..d411654 100644
--- a/fs/cifs/cifsencrypt.c
+++ b/fs/cifs/cifsencrypt.c
@@ -33,6 +33,7 @@
 #include <linux/ctype.h>
 #include <linux/random.h>
 #include <linux/highmem.h>
+#include <crypto/skcipher.h>
 
 static int
 cifs_crypto_shash_md5_allocate(struct TCP_Server_Info *server)
@@ -789,38 +790,46 @@ int
 calc_seckey(struct cifs_ses *ses)
 {
 	int rc;
-	struct crypto_blkcipher *tfm_arc4;
+	struct crypto_skcipher *tfm_arc4;
 	struct scatterlist sgin, sgout;
-	struct blkcipher_desc desc;
+	struct skcipher_request *req;
 	unsigned char sec_key[CIFS_SESS_KEY_SIZE]; /* a nonce */
 
 	get_random_bytes(sec_key, CIFS_SESS_KEY_SIZE);
 
-	tfm_arc4 = crypto_alloc_blkcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
+	tfm_arc4 = crypto_alloc_skcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm_arc4)) {
 		rc = PTR_ERR(tfm_arc4);
 		cifs_dbg(VFS, "could not allocate crypto API arc4\n");
 		return rc;
 	}
 
-	desc.tfm = tfm_arc4;
-
-	rc = crypto_blkcipher_setkey(tfm_arc4, ses->auth_key.response,
+	rc = crypto_skcipher_setkey(tfm_arc4, ses->auth_key.response,
 					CIFS_SESS_KEY_SIZE);
 	if (rc) {
 		cifs_dbg(VFS, "%s: Could not set response as a key\n",
 			 __func__);
-		return rc;
+		goto out_free_cipher;
+	}
+
+	req = skcipher_request_alloc(tfm_arc4, GFP_KERNEL);
+	if (!req) {
+		rc = -ENOMEM;
+		cifs_dbg(VFS, "could not allocate crypto API arc4 request\n");
+		goto out_free_cipher;
 	}
 
 	sg_init_one(&sgin, sec_key, CIFS_SESS_KEY_SIZE);
 	sg_init_one(&sgout, ses->ntlmssp->ciphertext, CIFS_CPHTXT_SIZE);
 
-	rc = crypto_blkcipher_encrypt(&desc, &sgout, &sgin, CIFS_CPHTXT_SIZE);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, &sgin, &sgout, CIFS_CPHTXT_SIZE, NULL);
+
+	rc = crypto_skcipher_encrypt(req);
+	skcipher_request_free(req);
 	if (rc) {
 		cifs_dbg(VFS, "could not encrypt session key rc: %d\n", rc);
-		crypto_free_blkcipher(tfm_arc4);
-		return rc;
+		goto out_free_cipher;
 	}
 
 	/* make secondary_key/nonce as session key */
@@ -828,7 +837,8 @@ calc_seckey(struct cifs_ses *ses)
 	/* and make len as that of session key only */
 	ses->auth_key.len = CIFS_SESS_KEY_SIZE;
 
-	crypto_free_blkcipher(tfm_arc4);
+out_free_cipher:
+	crypto_free_skcipher(tfm_arc4);
 
 	return rc;
 }
diff --git a/fs/cifs/smbencrypt.c b/fs/cifs/smbencrypt.c
index a4232ec..699b786 100644
--- a/fs/cifs/smbencrypt.c
+++ b/fs/cifs/smbencrypt.c
@@ -23,6 +23,7 @@
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
 
+#include <crypto/skcipher.h>
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/fs.h>
@@ -70,31 +71,42 @@ smbhash(unsigned char *out, const unsigned char *in, unsigned char *key)
 {
 	int rc;
 	unsigned char key2[8];
-	struct crypto_blkcipher *tfm_des;
+	struct crypto_skcipher *tfm_des;
 	struct scatterlist sgin, sgout;
-	struct blkcipher_desc desc;
+	struct skcipher_request *req;
 
 	str_to_key(key, key2);
 
-	tfm_des = crypto_alloc_blkcipher("ecb(des)", 0, CRYPTO_ALG_ASYNC);
+	tfm_des = crypto_alloc_skcipher("ecb(des)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm_des)) {
 		rc = PTR_ERR(tfm_des);
 		cifs_dbg(VFS, "could not allocate des crypto API\n");
 		goto smbhash_err;
 	}
 
-	desc.tfm = tfm_des;
+	req = skcipher_request_alloc(tfm_des, GFP_KERNEL);
+	if (!req) {
+		rc = -ENOMEM;
+		cifs_dbg(VFS, "could not allocate des crypto API\n");
+		goto smbhash_free_skcipher;
+	}
 
-	crypto_blkcipher_setkey(tfm_des, key2, 8);
+	crypto_skcipher_setkey(tfm_des, key2, 8);
 
 	sg_init_one(&sgin, in, 8);
 	sg_init_one(&sgout, out, 8);
 
-	rc = crypto_blkcipher_encrypt(&desc, &sgout, &sgin, 8);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, &sgin, &sgout, 8, NULL);
+
+	rc = crypto_skcipher_encrypt(req);
 	if (rc)
 		cifs_dbg(VFS, "could not encrypt crypt key rc: %d\n", rc);
 
-	crypto_free_blkcipher(tfm_des);
+	skcipher_request_free(req);
+
+smbhash_free_skcipher:
+	crypto_free_skcipher(tfm_des);
 smbhash_err:
 	return rc;
 }
