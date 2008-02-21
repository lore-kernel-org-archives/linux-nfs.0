From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 01/19] crypto: Add CTS mode required for Kerberos AES support
Date: Thu, 21 Feb 2008 13:43:52 -0500
Message-ID: <20080221184351.19195.15584.stgit@jazz.citi.umich.edu>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:5028 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183AbYBUSnw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 13:43:52 -0500
Received: from jazz.citi.umich.edu (jazz.citi.umich.edu [141.211.133.62])
	by citi.umich.edu (Postfix) with ESMTP id 1739B4609
	for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 13:43:52 -0500 (EST)
In-Reply-To: <20080221184208.19195.94518.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement CTS wrapper for CBC mode required for support of AES
encryption support for Kerberos (rfc3962).

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 crypto/Kconfig  |   11 ++
 crypto/Makefile |    1 
 crypto/cts.c    |  347 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 crypto/tcrypt.c |   16 ++-
 crypto/tcrypt.h |  209 +++++++++++++++++++++++++++++++++
 5 files changed, 582 insertions(+), 2 deletions(-)

diff --git a/crypto/Kconfig b/crypto/Kconfig
index c3166a1..375d269 100644
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -212,6 +212,17 @@ config CRYPTO_CTR
 	  CTR: Counter mode
 	  This block cipher algorithm is required for IPSec.
 
+config CRYPTO_CTS
+	tristate "CTS support"
+	select CRYPTO_BLKCIPHER
+	help
+	  CTS: Cipher Text Stealing
+	  This is the Cipher Text Stealing mode as described by
+	  Section 8 of rfc2040 and referenced by rfc3962.
+	  (rfc3962 includes errata information in its Appendix A)
+	  This mode is required for Kerberos gss mechanism support
+	  for AES encryption.
+
 config CRYPTO_GCM
 	tristate "GCM/GMAC support"
 	select CRYPTO_CTR
diff --git a/crypto/Makefile b/crypto/Makefile
index 48c7583..1b95dec 100644
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -35,6 +35,7 @@ obj-$(CONFIG_CRYPTO_GF128MUL) += gf128mul.o
 obj-$(CONFIG_CRYPTO_ECB) += ecb.o
 obj-$(CONFIG_CRYPTO_CBC) += cbc.o
 obj-$(CONFIG_CRYPTO_PCBC) += pcbc.o
+obj-$(CONFIG_CRYPTO_CTS) += cts.o
 obj-$(CONFIG_CRYPTO_LRW) += lrw.o
 obj-$(CONFIG_CRYPTO_XTS) += xts.o
 obj-$(CONFIG_CRYPTO_CTR) += ctr.o
diff --git a/crypto/cts.c b/crypto/cts.c
new file mode 100644
index 0000000..6fe968a
--- /dev/null
+++ b/crypto/cts.c
@@ -0,0 +1,347 @@
+/*
+ * CTS: Cipher Text Stealing mode
+ *
+ * COPYRIGHT (c) 2008
+ * The Regents of the University of Michigan
+ * ALL RIGHTS RESERVED
+ *
+ * Permission is granted to use, copy, create derivative works
+ * and redistribute this software and such derivative works
+ * for any purpose, so long as the name of The University of
+ * Michigan is not used in any advertising or publicity
+ * pertaining to the use of distribution of this software
+ * without specific, written prior authorization.  If the
+ * above copyright notice or any other identification of the
+ * University of Michigan is included in any copy of any
+ * portion of this software, then the disclaimer below must
+ * also be included.
+ *
+ * THIS SOFTWARE IS PROVIDED AS IS, WITHOUT REPRESENTATION
+ * FROM THE UNIVERSITY OF MICHIGAN AS TO ITS FITNESS FOR ANY
+ * PURPOSE, AND WITHOUT WARRANTY BY THE UNIVERSITY OF
+ * MICHIGAN OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING
+ * WITHOUT LIMITATION THE IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
+ * REGENTS OF THE UNIVERSITY OF MICHIGAN SHALL NOT BE LIABLE
+ * FOR ANY DAMAGES, INCLUDING SPECIAL, INDIRECT, INCIDENTAL, OR
+ * CONSEQUENTIAL DAMAGES, WITH RESPECT TO ANY CLAIM ARISING
+ * OUT OF OR IN CONNECTION WITH THE USE OF THE SOFTWARE, EVEN
+ * IF IT HAS BEEN OR IS HEREAFTER ADVISED OF THE POSSIBILITY OF
+ * SUCH DAMAGES.
+ */
+
+/* Derived from various:
+ *	Copyright (c) 2006 Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
+ */
+
+/*
+ * This is the Cipher Text Stealing mode as described by
+ * Section 8 of rfc2040 and referenced by rfc3962.
+ * rfc3962 includes errata information in its Appendix A.
+ */
+
+#include <crypto/algapi.h>
+#include <linux/err.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/log2.h>
+#include <linux/module.h>
+#include <linux/scatterlist.h>
+#include <crypto/scatterwalk.h>
+#include <linux/slab.h>
+
+struct crypto_cts_ctx {
+	struct crypto_blkcipher *child;
+};
+
+static int crypto_cts_setkey(struct crypto_tfm *parent, const u8 *key,
+			     unsigned int keylen)
+{
+	struct crypto_cts_ctx *ctx = crypto_tfm_ctx(parent);
+	struct crypto_blkcipher *child = ctx->child;
+	int err;
+
+	crypto_blkcipher_clear_flags(child, CRYPTO_TFM_REQ_MASK);
+	crypto_blkcipher_set_flags(child, crypto_tfm_get_flags(parent) &
+				       CRYPTO_TFM_REQ_MASK);
+	err = crypto_blkcipher_setkey(child, key, keylen);
+	crypto_tfm_set_flags(parent, crypto_blkcipher_get_flags(child) &
+				     CRYPTO_TFM_RES_MASK);
+	return err;
+}
+
+static int cts_cbc_encrypt(struct crypto_cts_ctx *ctx,
+			   struct blkcipher_desc *desc,
+			   struct scatterlist *dst,
+			   struct scatterlist *src,
+			   unsigned int offset,
+			   unsigned int nbytes)
+{
+	int bsize = crypto_blkcipher_blocksize(desc->tfm);
+	u8 tmp[bsize], tmp2[bsize];
+	struct blkcipher_desc lcldesc;
+	struct scatterlist sgsrc[1], sgdst[1];
+	int lastn = nbytes - bsize;
+	u8 iv[bsize];
+	u8 s[bsize * 2], d[bsize * 2];
+	int err;
+
+	if (lastn < 0)
+		return -EINVAL;
+
+	memset(s, 0, sizeof(s));
+	scatterwalk_map_and_copy(s, src, offset, nbytes, 0);
+
+	memcpy(iv, desc->info, bsize);
+
+	lcldesc.tfm = ctx->child;
+	lcldesc.info = iv;
+	lcldesc.flags = desc->flags;
+
+	sg_set_buf(&sgsrc[0], s, bsize);
+	sg_set_buf(&sgdst[0], tmp, bsize);
+	err = crypto_blkcipher_encrypt_iv(&lcldesc, sgdst, sgsrc, bsize);
+
+	memcpy(d + bsize, tmp, lastn);
+
+	lcldesc.info = tmp;
+
+	sg_set_buf(&sgsrc[0], s + bsize, bsize);
+	sg_set_buf(&sgdst[0], tmp2, bsize);
+	err = crypto_blkcipher_encrypt_iv(&lcldesc, sgdst, sgsrc, bsize);
+
+	memcpy(d, tmp2, bsize);
+
+	scatterwalk_map_and_copy(d, dst, offset, nbytes, 1);
+
+	memcpy(desc->info, tmp2, bsize);
+
+	return err;
+}
+
+static int crypto_cts_encrypt(struct blkcipher_desc *desc,
+			      struct scatterlist *dst, struct scatterlist *src,
+			      unsigned int nbytes)
+{
+	struct crypto_cts_ctx *ctx = crypto_blkcipher_ctx(desc->tfm);
+	int bsize = crypto_blkcipher_blocksize(desc->tfm);
+	int tot_blocks = (nbytes + bsize - 1) / bsize;
+	int cbc_blocks = tot_blocks > 2 ? tot_blocks - 2 : 0;
+	struct blkcipher_desc lcldesc;
+	int err;
+
+	lcldesc.tfm = ctx->child;
+	lcldesc.info = desc->info;
+	lcldesc.flags = desc->flags;
+
+	if (tot_blocks == 1) {
+		err = crypto_blkcipher_encrypt_iv(&lcldesc, dst, src, bsize);
+	} else if (nbytes <= bsize * 2) {
+		err = cts_cbc_encrypt(ctx, desc, dst, src, 0, nbytes);
+	} else {
+		/* do normal function for tot_blocks - 2 */
+		err = crypto_blkcipher_encrypt_iv(&lcldesc, dst, src,
+							cbc_blocks * bsize);
+		if (err == 0) {
+			/* do cts for final two blocks */
+			err = cts_cbc_encrypt(ctx, desc, dst, src,
+						cbc_blocks * bsize,
+						nbytes - (cbc_blocks * bsize));
+		}
+	}
+
+	return err;
+}
+
+static int cts_cbc_decrypt(struct crypto_cts_ctx *ctx,
+			   struct blkcipher_desc *desc,
+			   struct scatterlist *dst,
+			   struct scatterlist *src,
+			   unsigned int offset,
+			   unsigned int nbytes)
+{
+	int bsize = crypto_blkcipher_blocksize(desc->tfm);
+	u8 tmp[bsize];
+	struct blkcipher_desc lcldesc;
+	struct scatterlist sgsrc[1], sgdst[1];
+	int lastn = nbytes - bsize;
+	u8 iv[bsize];
+	u8 s[bsize * 2], d[bsize * 2];
+	int err;
+
+	if (lastn < 0)
+		return -EINVAL;
+
+	scatterwalk_map_and_copy(s, src, offset, nbytes, 0);
+
+	lcldesc.tfm = ctx->child;
+	lcldesc.info = iv;
+	lcldesc.flags = desc->flags;
+
+	/* 1. Decrypt Cn-1 (s) to create Dn (tmp)*/
+	memset(iv, 0, sizeof(iv));
+	sg_set_buf(&sgsrc[0], s, bsize);
+	sg_set_buf(&sgdst[0], tmp, bsize);
+	err = crypto_blkcipher_decrypt_iv(&lcldesc, sgdst, sgsrc, bsize);
+	if (err)
+		return err;
+	/* 2. Pad Cn with zeros at the end to create C of length BB */
+	memset(iv, 0, sizeof(iv));
+	memcpy(iv, s + bsize, lastn);
+	/* 3. Exclusive-or Dn (tmp) with C (iv) to create Xn (tmp) */
+	crypto_xor(tmp, iv, bsize);
+	/* 4. Select the first Ln bytes of Xn (tmp) to create Pn */
+	memcpy(d + bsize, tmp, lastn);
+
+	/* 5. Append the tail (BB - Ln) bytes of Xn (tmp) to Cn to create En */
+	memcpy(s + bsize + lastn, tmp + lastn, bsize - lastn);
+	/* 6. Decrypt En to create Pn-1 */
+	memset(iv, 0, sizeof(iv));
+	sg_set_buf(&sgsrc[0], s + bsize, bsize);
+	sg_set_buf(&sgdst[0], d, bsize);
+	err = crypto_blkcipher_decrypt_iv(&lcldesc, sgdst, sgsrc, bsize);
+
+	/* XXX xor with previous block ?? */
+	crypto_xor(d, desc->info, bsize);
+
+	scatterwalk_map_and_copy(d, dst, offset, nbytes, 1);
+
+	memcpy(desc->info, s, bsize);
+	return err;
+}
+
+static int crypto_cts_decrypt(struct blkcipher_desc *desc,
+			      struct scatterlist *dst, struct scatterlist *src,
+			      unsigned int nbytes)
+{
+	struct crypto_cts_ctx *ctx = crypto_blkcipher_ctx(desc->tfm);
+	int bsize = crypto_blkcipher_blocksize(desc->tfm);
+	int tot_blocks = (nbytes + bsize - 1) / bsize;
+	int cbc_blocks = tot_blocks > 2 ? tot_blocks - 2 : 0;
+	struct blkcipher_desc lcldesc;
+	int err;
+
+	lcldesc.tfm = ctx->child;
+	lcldesc.info = desc->info;
+	lcldesc.flags = desc->flags;
+
+	if (tot_blocks == 1) {
+		err = crypto_blkcipher_decrypt_iv(&lcldesc, dst, src, bsize);
+	} else if (nbytes <= bsize * 2) {
+		err = cts_cbc_decrypt(ctx, desc, dst, src, 0, nbytes);
+	} else {
+		/* do normal function for tot_blocks - 2 */
+		err = crypto_blkcipher_decrypt_iv(&lcldesc, dst, src,
+							cbc_blocks * bsize);
+		if (err == 0) {
+			/* do cts for final two blocks */
+			err = cts_cbc_decrypt(ctx, desc, dst, src,
+						cbc_blocks * bsize,
+						nbytes - (cbc_blocks * bsize));
+		}
+	}
+	return err;
+}
+
+static int crypto_cts_init_tfm(struct crypto_tfm *tfm)
+{
+	struct crypto_instance *inst = (void *)tfm->__crt_alg;
+	struct crypto_spawn *spawn = crypto_instance_ctx(inst);
+	struct crypto_cts_ctx *ctx = crypto_tfm_ctx(tfm);
+	struct crypto_blkcipher *cipher;
+
+	cipher = crypto_spawn_blkcipher(spawn);
+	if (IS_ERR(cipher))
+		return PTR_ERR(cipher);
+
+	ctx->child = cipher;
+	return 0;
+}
+
+static void crypto_cts_exit_tfm(struct crypto_tfm *tfm)
+{
+	struct crypto_cts_ctx *ctx = crypto_tfm_ctx(tfm);
+	crypto_free_blkcipher(ctx->child);
+}
+
+static struct crypto_instance *crypto_cts_alloc(struct rtattr **tb)
+{
+	struct crypto_instance *inst;
+	struct crypto_alg *alg;
+	int err;
+
+	err = crypto_check_attr_type(tb, CRYPTO_ALG_TYPE_BLKCIPHER);
+	if (err)
+		return ERR_PTR(err);
+
+	alg = crypto_attr_alg(tb[1], CRYPTO_ALG_TYPE_BLKCIPHER,
+				  CRYPTO_ALG_TYPE_MASK);
+	err = PTR_ERR(alg);
+	if (IS_ERR(alg))
+		return ERR_PTR(err);
+
+	inst = ERR_PTR(-EINVAL);
+	if (!is_power_of_2(alg->cra_blocksize))
+		goto out_put_alg;
+
+	inst = crypto_alloc_instance("cts", alg);
+	if (IS_ERR(inst))
+		goto out_put_alg;
+
+	inst->alg.cra_flags = CRYPTO_ALG_TYPE_BLKCIPHER;
+	inst->alg.cra_priority = alg->cra_priority;
+	inst->alg.cra_blocksize = alg->cra_blocksize;
+	inst->alg.cra_alignmask = alg->cra_alignmask;
+	inst->alg.cra_type = &crypto_blkcipher_type;
+
+	/* We access the data as u32s when xoring. */
+	inst->alg.cra_alignmask |= __alignof__(u32) - 1;
+
+	inst->alg.cra_blkcipher.ivsize = alg->cra_blocksize;
+	inst->alg.cra_blkcipher.min_keysize = alg->cra_blkcipher.min_keysize;
+	inst->alg.cra_blkcipher.max_keysize = alg->cra_blkcipher.max_keysize;
+
+	inst->alg.cra_blkcipher.geniv = "seqiv";
+
+	inst->alg.cra_ctxsize = sizeof(struct crypto_cts_ctx);
+
+	inst->alg.cra_init = crypto_cts_init_tfm;
+	inst->alg.cra_exit = crypto_cts_exit_tfm;
+
+	inst->alg.cra_blkcipher.setkey = crypto_cts_setkey;
+	inst->alg.cra_blkcipher.encrypt = crypto_cts_encrypt;
+	inst->alg.cra_blkcipher.decrypt = crypto_cts_decrypt;
+
+out_put_alg:
+	crypto_mod_put(alg);
+	return inst;
+}
+
+static void crypto_cts_free(struct crypto_instance *inst)
+{
+	crypto_drop_spawn(crypto_instance_ctx(inst));
+	kfree(inst);
+}
+
+static struct crypto_template crypto_cts_tmpl = {
+	.name = "cts",
+	.alloc = crypto_cts_alloc,
+	.free = crypto_cts_free,
+	.module = THIS_MODULE,
+};
+
+static int __init crypto_cts_module_init(void)
+{
+	return crypto_register_template(&crypto_cts_tmpl);
+}
+
+static void __exit crypto_cts_module_exit(void)
+{
+	crypto_unregister_template(&crypto_cts_tmpl);
+}
+
+module_init(crypto_cts_module_init);
+module_exit(crypto_cts_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("CTS-CBC) CipherText Stealing for CBC");
diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
index 1ab8c01..103d9e0 100644
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -82,9 +82,8 @@ static char *check[] = {
 	"des", "md5", "des3_ede", "rot13", "sha1", "sha224", "sha256",
 	"blowfish", "twofish", "serpent", "sha384", "sha512", "md4", "aes",
 	"cast6", "arc4", "michael_mic", "deflate", "crc32c", "tea", "xtea",
-	"arc4", "michael_mic", "deflate", "crc32c", "tea", "xtea",
 	"khazad", "wp512", "wp384", "wp256", "tnepres", "xeta",  "fcrypt",
-	"camellia", "seed", "salsa20", "lzo", NULL
+	"camellia", "seed", "salsa20", "lzo", "cts", NULL
 };
 
 static void hexdump(unsigned char *buf, unsigned int len)
@@ -1301,6 +1300,12 @@ static void do_test(void)
 		test_cipher("ecb(seed)", DECRYPT, seed_dec_tv_template,
 			    SEED_DEC_TEST_VECTORS);
 
+		//CTS
+		test_cipher("cts(cbc(aes))", ENCRYPT, cts_mode_enc_tv_template,
+			    CTS_MODE_ENC_TEST_VECTORS);
+		test_cipher("cts(cbc(aes))", DECRYPT, cts_mode_dec_tv_template,
+			    CTS_MODE_DEC_TEST_VECTORS);
+
 		test_hash("sha384", sha384_tv_template, SHA384_TEST_VECTORS);
 		test_hash("sha512", sha512_tv_template, SHA512_TEST_VECTORS);
 		test_hash("wp512", wp512_tv_template, WP512_TEST_VECTORS);
@@ -1584,6 +1589,13 @@ static void do_test(void)
 			  AES_CCM_DEC_TEST_VECTORS);
 		break;
 
+	case 38:
+		test_cipher("cts(cbc(aes))", ENCRYPT, cts_mode_enc_tv_template,
+			    CTS_MODE_ENC_TEST_VECTORS);
+		test_cipher("cts(cbc(aes))", DECRYPT, cts_mode_dec_tv_template,
+			    CTS_MODE_DEC_TEST_VECTORS);
+		break;
+
 	case 100:
 		test_hash("hmac(md5)", hmac_md5_tv_template,
 			  HMAC_MD5_TEST_VECTORS);
diff --git a/crypto/tcrypt.h b/crypto/tcrypt.h
index f785e56..548716b 100644
--- a/crypto/tcrypt.h
+++ b/crypto/tcrypt.h
@@ -7631,6 +7631,215 @@ static struct cipher_testvec salsa20_stream_enc_tv_template[] = {
 };
 
 /*
+ * CTS (Cipher Text Stealing) mode tests
+ */
+#define CTS_MODE_ENC_TEST_VECTORS 6
+#define CTS_MODE_DEC_TEST_VECTORS 6
+static struct cipher_testvec cts_mode_enc_tv_template[] = {
+	{ /* from rfc3962 */
+		.klen	= 16,
+		.key    = { 0x63, 0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x20,
+			    0x74, 0x65, 0x72, 0x69, 0x79, 0x61, 0x6b, 0x69 },
+		.ilen	= 17,
+		.input  = { 0x49, 0x20, 0x77, 0x6f, 0x75, 0x6c, 0x64, 0x20,
+			    0x6c, 0x69, 0x6b, 0x65, 0x20, 0x74, 0x68, 0x65,
+			    0x20 },
+		.rlen	= 17,
+		.result	= { 0xc6, 0x35, 0x35, 0x68, 0xf2, 0xbf, 0x8c, 0xb4,
+			    0xd8, 0xa5, 0x80, 0x36, 0x2d, 0xa7, 0xff, 0x7f,
+			    0x97 },
+	}, {
+		.klen	= 16,
+		.key    = { 0x63, 0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x20,
+			    0x74, 0x65, 0x72, 0x69, 0x79, 0x61, 0x6b, 0x69 },
+		.ilen   = 31,
+		.input  = { 0x49, 0x20, 0x77, 0x6f, 0x75, 0x6c, 0x64, 0x20,
+			    0x6c, 0x69, 0x6b, 0x65, 0x20, 0x74, 0x68, 0x65,
+			    0x20, 0x47, 0x65, 0x6e, 0x65, 0x72, 0x61, 0x6c,
+			    0x20, 0x47, 0x61, 0x75, 0x27, 0x73, 0x20 },
+		.rlen   = 31,
+		.result = { 0xfc, 0x00, 0x78, 0x3e, 0x0e, 0xfd, 0xb2, 0xc1,
+			    0xd4, 0x45, 0xd4, 0xc8, 0xef, 0xf7, 0xed, 0x22,
+			    0x97, 0x68, 0x72, 0x68, 0xd6, 0xec, 0xcc, 0xc0,
+			    0xc0, 0x7b, 0x25, 0xe2, 0x5e, 0xcf, 0xe5 },
+	}, {
+		.klen	= 16,
+		.key    = { 0x63, 0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x20,
+			    0x74, 0x65, 0x72, 0x69, 0x79, 0x61, 0x6b, 0x69 },
+		.ilen   = 32,
+		.input  = { 0x49, 0x20, 0x77, 0x6f, 0x75, 0x6c, 0x64, 0x20,
+			    0x6c, 0x69, 0x6b, 0x65, 0x20, 0x74, 0x68, 0x65,
+			    0x20, 0x47, 0x65, 0x6e, 0x65, 0x72, 0x61, 0x6c,
+			    0x20, 0x47, 0x61, 0x75, 0x27, 0x73, 0x20, 0x43 },
+		.rlen   = 32,
+		.result = { 0x39, 0x31, 0x25, 0x23, 0xa7, 0x86, 0x62, 0xd5,
+			    0xbe, 0x7f, 0xcb, 0xcc, 0x98, 0xeb, 0xf5, 0xa8,
+			    0x97, 0x68, 0x72, 0x68, 0xd6, 0xec, 0xcc, 0xc0,
+			    0xc0, 0x7b, 0x25, 0xe2, 0x5e, 0xcf, 0xe5, 0x84 },
+	}, {
+		.klen	= 16,
+		.key    = { 0x63, 0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x20,
+			    0x74, 0x65, 0x72, 0x69, 0x79, 0x61, 0x6b, 0x69 },
+		.ilen   = 47,
+		.input  = { 0x49, 0x20, 0x77, 0x6f, 0x75, 0x6c, 0x64, 0x20,
+			    0x6c, 0x69, 0x6b, 0x65, 0x20, 0x74, 0x68, 0x65,
+			    0x20, 0x47, 0x65, 0x6e, 0x65, 0x72, 0x61, 0x6c,
+			    0x20, 0x47, 0x61, 0x75, 0x27, 0x73, 0x20, 0x43,
+			    0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x2c, 0x20,
+			    0x70, 0x6c, 0x65, 0x61, 0x73, 0x65, 0x2c },
+		.rlen   = 47,
+		.result = { 0x97, 0x68, 0x72, 0x68, 0xd6, 0xec, 0xcc, 0xc0,
+			    0xc0, 0x7b, 0x25, 0xe2, 0x5e, 0xcf, 0xe5, 0x84,
+			    0xb3, 0xff, 0xfd, 0x94, 0x0c, 0x16, 0xa1, 0x8c,
+			    0x1b, 0x55, 0x49, 0xd2, 0xf8, 0x38, 0x02, 0x9e,
+			    0x39, 0x31, 0x25, 0x23, 0xa7, 0x86, 0x62, 0xd5,
+			    0xbe, 0x7f, 0xcb, 0xcc, 0x98, 0xeb, 0xf5 },
+	}, {
+		.klen	= 16,
+		.key    = { 0x63, 0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x20,
+			    0x74, 0x65, 0x72, 0x69, 0x79, 0x61, 0x6b, 0x69 },
+		.ilen   = 48,
+		.input  = { 0x49, 0x20, 0x77, 0x6f, 0x75, 0x6c, 0x64, 0x20,
+			    0x6c, 0x69, 0x6b, 0x65, 0x20, 0x74, 0x68, 0x65,
+			    0x20, 0x47, 0x65, 0x6e, 0x65, 0x72, 0x61, 0x6c,
+			    0x20, 0x47, 0x61, 0x75, 0x27, 0x73, 0x20, 0x43,
+			    0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x2c, 0x20,
+			    0x70, 0x6c, 0x65, 0x61, 0x73, 0x65, 0x2c, 0x20 },
+		.rlen   = 48,
+		.result = { 0x97, 0x68, 0x72, 0x68, 0xd6, 0xec, 0xcc, 0xc0,
+			    0xc0, 0x7b, 0x25, 0xe2, 0x5e, 0xcf, 0xe5, 0x84,
+			    0x9d, 0xad, 0x8b, 0xbb, 0x96, 0xc4, 0xcd, 0xc0,
+			    0x3b, 0xc1, 0x03, 0xe1, 0xa1, 0x94, 0xbb, 0xd8,
+			    0x39, 0x31, 0x25, 0x23, 0xa7, 0x86, 0x62, 0xd5,
+			    0xbe, 0x7f, 0xcb, 0xcc, 0x98, 0xeb, 0xf5, 0xa8 },
+	}, {
+		.klen	= 16,
+		.key    = { 0x63, 0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x20,
+			    0x74, 0x65, 0x72, 0x69, 0x79, 0x61, 0x6b, 0x69 },
+		.ilen   = 64,
+		.input  = { 0x49, 0x20, 0x77, 0x6f, 0x75, 0x6c, 0x64, 0x20,
+			    0x6c, 0x69, 0x6b, 0x65, 0x20, 0x74, 0x68, 0x65,
+			    0x20, 0x47, 0x65, 0x6e, 0x65, 0x72, 0x61, 0x6c,
+			    0x20, 0x47, 0x61, 0x75, 0x27, 0x73, 0x20, 0x43,
+			    0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x2c, 0x20,
+			    0x70, 0x6c, 0x65, 0x61, 0x73, 0x65, 0x2c, 0x20,
+			    0x61, 0x6e, 0x64, 0x20, 0x77, 0x6f, 0x6e, 0x74,
+			    0x6f, 0x6e, 0x20, 0x73, 0x6f, 0x75, 0x70, 0x2e },
+		.rlen   = 64,
+		.result = { 0x97, 0x68, 0x72, 0x68, 0xd6, 0xec, 0xcc, 0xc0,
+			    0xc0, 0x7b, 0x25, 0xe2, 0x5e, 0xcf, 0xe5, 0x84,
+			    0x39, 0x31, 0x25, 0x23, 0xa7, 0x86, 0x62, 0xd5,
+			    0xbe, 0x7f, 0xcb, 0xcc, 0x98, 0xeb, 0xf5, 0xa8,
+			    0x48, 0x07, 0xef, 0xe8, 0x36, 0xee, 0x89, 0xa5,
+			    0x26, 0x73, 0x0d, 0xbc, 0x2f, 0x7b, 0xc8, 0x40,
+			    0x9d, 0xad, 0x8b, 0xbb, 0x96, 0xc4, 0xcd, 0xc0,
+			    0x3b, 0xc1, 0x03, 0xe1, 0xa1, 0x94, 0xbb, 0xd8 },
+	}
+};
+
+static struct cipher_testvec cts_mode_dec_tv_template[] = {
+	{ /* from rfc3962 */
+		.klen	= 16,
+		.key    = { 0x63, 0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x20,
+			    0x74, 0x65, 0x72, 0x69, 0x79, 0x61, 0x6b, 0x69 },
+		.rlen	= 17,
+		.result = { 0x49, 0x20, 0x77, 0x6f, 0x75, 0x6c, 0x64, 0x20,
+			    0x6c, 0x69, 0x6b, 0x65, 0x20, 0x74, 0x68, 0x65,
+			    0x20 },
+		.ilen	= 17,
+		.input	= { 0xc6, 0x35, 0x35, 0x68, 0xf2, 0xbf, 0x8c, 0xb4,
+			    0xd8, 0xa5, 0x80, 0x36, 0x2d, 0xa7, 0xff, 0x7f,
+			    0x97 },
+	}, {
+		.klen	= 16,
+		.key    = { 0x63, 0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x20,
+			    0x74, 0x65, 0x72, 0x69, 0x79, 0x61, 0x6b, 0x69 },
+		.rlen   = 31,
+		.result = { 0x49, 0x20, 0x77, 0x6f, 0x75, 0x6c, 0x64, 0x20,
+			    0x6c, 0x69, 0x6b, 0x65, 0x20, 0x74, 0x68, 0x65,
+			    0x20, 0x47, 0x65, 0x6e, 0x65, 0x72, 0x61, 0x6c,
+			    0x20, 0x47, 0x61, 0x75, 0x27, 0x73, 0x20 },
+		.ilen   = 31,
+		.input  = { 0xfc, 0x00, 0x78, 0x3e, 0x0e, 0xfd, 0xb2, 0xc1,
+			    0xd4, 0x45, 0xd4, 0xc8, 0xef, 0xf7, 0xed, 0x22,
+			    0x97, 0x68, 0x72, 0x68, 0xd6, 0xec, 0xcc, 0xc0,
+			    0xc0, 0x7b, 0x25, 0xe2, 0x5e, 0xcf, 0xe5 },
+	}, {
+		.klen	= 16,
+		.key    = { 0x63, 0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x20,
+			    0x74, 0x65, 0x72, 0x69, 0x79, 0x61, 0x6b, 0x69 },
+		.rlen   = 32,
+		.result = { 0x49, 0x20, 0x77, 0x6f, 0x75, 0x6c, 0x64, 0x20,
+			    0x6c, 0x69, 0x6b, 0x65, 0x20, 0x74, 0x68, 0x65,
+			    0x20, 0x47, 0x65, 0x6e, 0x65, 0x72, 0x61, 0x6c,
+			    0x20, 0x47, 0x61, 0x75, 0x27, 0x73, 0x20, 0x43 },
+		.ilen   = 32,
+		.input  = { 0x39, 0x31, 0x25, 0x23, 0xa7, 0x86, 0x62, 0xd5,
+			    0xbe, 0x7f, 0xcb, 0xcc, 0x98, 0xeb, 0xf5, 0xa8,
+			    0x97, 0x68, 0x72, 0x68, 0xd6, 0xec, 0xcc, 0xc0,
+			    0xc0, 0x7b, 0x25, 0xe2, 0x5e, 0xcf, 0xe5, 0x84 },
+	}, {
+		.klen	= 16,
+		.key    = { 0x63, 0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x20,
+			    0x74, 0x65, 0x72, 0x69, 0x79, 0x61, 0x6b, 0x69 },
+		.rlen   = 47,
+		.result = { 0x49, 0x20, 0x77, 0x6f, 0x75, 0x6c, 0x64, 0x20,
+			    0x6c, 0x69, 0x6b, 0x65, 0x20, 0x74, 0x68, 0x65,
+			    0x20, 0x47, 0x65, 0x6e, 0x65, 0x72, 0x61, 0x6c,
+			    0x20, 0x47, 0x61, 0x75, 0x27, 0x73, 0x20, 0x43,
+			    0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x2c, 0x20,
+			    0x70, 0x6c, 0x65, 0x61, 0x73, 0x65, 0x2c },
+		.ilen   = 47,
+		.input  = { 0x97, 0x68, 0x72, 0x68, 0xd6, 0xec, 0xcc, 0xc0,
+			    0xc0, 0x7b, 0x25, 0xe2, 0x5e, 0xcf, 0xe5, 0x84,
+			    0xb3, 0xff, 0xfd, 0x94, 0x0c, 0x16, 0xa1, 0x8c,
+			    0x1b, 0x55, 0x49, 0xd2, 0xf8, 0x38, 0x02, 0x9e,
+			    0x39, 0x31, 0x25, 0x23, 0xa7, 0x86, 0x62, 0xd5,
+			    0xbe, 0x7f, 0xcb, 0xcc, 0x98, 0xeb, 0xf5 },
+	}, {
+		.klen	= 16,
+		.key    = { 0x63, 0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x20,
+			    0x74, 0x65, 0x72, 0x69, 0x79, 0x61, 0x6b, 0x69 },
+		.rlen   = 48,
+		.result = { 0x49, 0x20, 0x77, 0x6f, 0x75, 0x6c, 0x64, 0x20,
+			    0x6c, 0x69, 0x6b, 0x65, 0x20, 0x74, 0x68, 0x65,
+			    0x20, 0x47, 0x65, 0x6e, 0x65, 0x72, 0x61, 0x6c,
+			    0x20, 0x47, 0x61, 0x75, 0x27, 0x73, 0x20, 0x43,
+			    0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x2c, 0x20,
+			    0x70, 0x6c, 0x65, 0x61, 0x73, 0x65, 0x2c, 0x20 },
+		.ilen   = 48,
+		.input  = { 0x97, 0x68, 0x72, 0x68, 0xd6, 0xec, 0xcc, 0xc0,
+			    0xc0, 0x7b, 0x25, 0xe2, 0x5e, 0xcf, 0xe5, 0x84,
+			    0x9d, 0xad, 0x8b, 0xbb, 0x96, 0xc4, 0xcd, 0xc0,
+			    0x3b, 0xc1, 0x03, 0xe1, 0xa1, 0x94, 0xbb, 0xd8,
+			    0x39, 0x31, 0x25, 0x23, 0xa7, 0x86, 0x62, 0xd5,
+			    0xbe, 0x7f, 0xcb, 0xcc, 0x98, 0xeb, 0xf5, 0xa8 },
+	}, {
+		.klen	= 16,
+		.key    = { 0x63, 0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x20,
+			    0x74, 0x65, 0x72, 0x69, 0x79, 0x61, 0x6b, 0x69 },
+		.rlen   = 64,
+		.result = { 0x49, 0x20, 0x77, 0x6f, 0x75, 0x6c, 0x64, 0x20,
+			    0x6c, 0x69, 0x6b, 0x65, 0x20, 0x74, 0x68, 0x65,
+			    0x20, 0x47, 0x65, 0x6e, 0x65, 0x72, 0x61, 0x6c,
+			    0x20, 0x47, 0x61, 0x75, 0x27, 0x73, 0x20, 0x43,
+			    0x68, 0x69, 0x63, 0x6b, 0x65, 0x6e, 0x2c, 0x20,
+			    0x70, 0x6c, 0x65, 0x61, 0x73, 0x65, 0x2c, 0x20,
+			    0x61, 0x6e, 0x64, 0x20, 0x77, 0x6f, 0x6e, 0x74,
+			    0x6f, 0x6e, 0x20, 0x73, 0x6f, 0x75, 0x70, 0x2e },
+		.ilen   = 64,
+		.input  = { 0x97, 0x68, 0x72, 0x68, 0xd6, 0xec, 0xcc, 0xc0,
+			    0xc0, 0x7b, 0x25, 0xe2, 0x5e, 0xcf, 0xe5, 0x84,
+			    0x39, 0x31, 0x25, 0x23, 0xa7, 0x86, 0x62, 0xd5,
+			    0xbe, 0x7f, 0xcb, 0xcc, 0x98, 0xeb, 0xf5, 0xa8,
+			    0x48, 0x07, 0xef, 0xe8, 0x36, 0xee, 0x89, 0xa5,
+			    0x26, 0x73, 0x0d, 0xbc, 0x2f, 0x7b, 0xc8, 0x40,
+			    0x9d, 0xad, 0x8b, 0xbb, 0x96, 0xc4, 0xcd, 0xc0,
+			    0x3b, 0xc1, 0x03, 0xe1, 0xa1, 0x94, 0xbb, 0xd8 },
+	}
+};
+
+/*
  * Compression stuff.
  */
 #define COMP_BUF_SIZE           512

