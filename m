From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 3: PATCH 08/24] gss_krb5: introduce encryption type
	framework
Date: Tue, 06 May 2008 17:04:11 -0400
Message-ID: <20080506210411.3770.81883.stgit@jazz.citi.umich.edu>
References: <20080506210156.3770.95914.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:8636 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765735AbYEFVEM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 17:04:12 -0400
In-Reply-To: <20080506210156.3770.95914.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add enctype framework and change functions to use the generic
values from it rather than the values hard-coded for des.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 include/linux/sunrpc/gss_krb5.h       |   25 +++++++++
 net/sunrpc/auth_gss/gss_krb5_crypto.c |   18 +++----
 net/sunrpc/auth_gss/gss_krb5_mech.c   |   89 +++++++++++++++++++++++++++------
 net/sunrpc/auth_gss/gss_krb5_seal.c   |   49 +++++++++++-------
 net/sunrpc/auth_gss/gss_krb5_unseal.c |   15 +++---
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |   79 ++++++++++++++++++++++-------
 6 files changed, 205 insertions(+), 70 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 12bd0dd..8d79c44 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -4,7 +4,7 @@
  *  Adapted from MIT Kerberos 5-1.2.1 lib/include/krb5.h,
  *  lib/gssapi/krb5/gssapiP_krb5.h, and others
  *
- *  Copyright (c) 2000 The Regents of the University of Michigan.
+ *  Copyright (c) 2000-2008 The Regents of the University of Michigan.
  *  All rights reserved.
  *
  *  Andy Adamson   <andros@umich.edu>
@@ -36,6 +36,7 @@
  *
  */
 
+#include <linux/crypto.h>
 #include <linux/sunrpc/auth_gss.h>
 #include <linux/sunrpc/gss_err.h>
 #include <linux/sunrpc/gss_asn1.h>
@@ -46,9 +47,31 @@
 /* Maximum blocksize for the supported crypto algorithms */
 #define GSS_KRB5_MAX_BLOCKSIZE  (16)
 
+struct gss_krb5_enctype {
+	const u32		etype;		/* encryption (key) type */
+	const u32		ctype;		/* checksum type */
+	const char		*name;		/* "friendly" name */
+	const char		*encrypt_name;	/* crypto encrypt name */
+	const char		*cksum_name;	/* crypto checksum name */
+	const u16		signalg;	/* signing algorithm */
+	const u16		sealalg;	/* sealing algorithm */
+	const u32		blocksize;	/* encryption blocksize */
+	const u32		cksumlength;	/* checksum length */
+	const u32		keyed_cksum;	/* is it a keyed cksum? */
+	const u32		keybytes;	/* raw key len, in bytes */
+	const u32		keylength;	/* final key len, in bytes */
+	u32 (*encrypt) (struct crypto_blkcipher *tfm,
+			void *iv, void *in, void *out,
+			int length);		/* encryption function */
+	u32 (*decrypt) (struct crypto_blkcipher *tfm,
+			void *iv, void *in, void *out,
+			int length);		/* decryption function */
+};
+
 struct krb5_ctx {
 	int			initiate; /* 1 = initiating, 0 = accepting */
 	u32			enctype;
+	struct gss_krb5_enctype *gk5e;		/* enctype-specific info */
 	struct crypto_blkcipher	*enc;
 	struct crypto_blkcipher	*seq;
 	s32			endtime;
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index d0f3371..d3025aa 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -1,7 +1,7 @@
 /*
  *  linux/net/sunrpc/gss_krb5_crypto.c
  *
- *  Copyright (c) 2000 The Regents of the University of Michigan.
+ *  Copyright (c) 2000-2008 The Regents of the University of Michigan.
  *  All rights reserved.
  *
  *  Andy Adamson   <andros@umich.edu>
@@ -59,13 +59,13 @@ krb5_encrypt(
 {
 	u32 ret = -EINVAL;
 	struct scatterlist sg[1];
-	u8 local_iv[16] = {0};
+	u8 local_iv[GSS_KRB5_MAX_BLOCKSIZE] = {0};
 	struct blkcipher_desc desc = { .tfm = tfm, .info = local_iv };
 
 	if (length % crypto_blkcipher_blocksize(tfm) != 0)
 		goto out;
 
-	if (crypto_blkcipher_ivsize(tfm) > 16) {
+	if (crypto_blkcipher_ivsize(tfm) > GSS_KRB5_MAX_BLOCKSIZE) {
 		dprintk("RPC:       gss_k5encrypt: tfm iv size too large %d\n",
 			crypto_blkcipher_ivsize(tfm));
 		goto out;
@@ -93,13 +93,13 @@ krb5_decrypt(
 {
 	u32 ret = -EINVAL;
 	struct scatterlist sg[1];
-	u8 local_iv[16] = {0};
+	u8 local_iv[GSS_KRB5_MAX_BLOCKSIZE] = {0};
 	struct blkcipher_desc desc = { .tfm = tfm, .info = local_iv };
 
 	if (length % crypto_blkcipher_blocksize(tfm) != 0)
 		goto out;
 
-	if (crypto_blkcipher_ivsize(tfm) > 16) {
+	if (crypto_blkcipher_ivsize(tfm) > GSS_KRB5_MAX_BLOCKSIZE) {
 		dprintk("RPC:       gss_k5decrypt: tfm iv size too large %d\n",
 			crypto_blkcipher_ivsize(tfm));
 		goto out;
@@ -158,7 +158,7 @@ out:
 }
 
 struct encryptor_desc {
-	u8 iv[8]; /* XXX hard-coded blocksize */
+	u8 iv[GSS_KRB5_MAX_BLOCKSIZE];
 	struct blkcipher_desc desc;
 	int pos;
 	struct xdr_buf *outbuf;
@@ -199,7 +199,7 @@ encryptor(struct scatterlist *sg, void *data)
 	desc->fraglen += sg->length;
 	desc->pos += sg->length;
 
-	fraglen = thislen & 7; /* XXX hardcoded blocksize */
+	fraglen = thislen & (crypto_blkcipher_blocksize(desc->desc.tfm) - 1);
 	thislen -= fraglen;
 
 	if (thislen == 0)
@@ -257,7 +257,7 @@ gss_encrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *buf,
 }
 
 struct decryptor_desc {
-	u8 iv[8]; /* XXX hard-coded blocksize */
+	u8 iv[GSS_KRB5_MAX_BLOCKSIZE];
 	struct blkcipher_desc desc;
 	struct scatterlist frags[4];
 	int fragno;
@@ -279,7 +279,7 @@ decryptor(struct scatterlist *sg, void *data)
 	desc->fragno++;
 	desc->fraglen += sg->length;
 
-	fraglen = thislen & 7; /* XXX hardcoded blocksize */
+	fraglen = thislen & (crypto_blkcipher_blocksize(desc->desc.tfm) - 1);
 	thislen -= fraglen;
 
 	if (thislen == 0)
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 20e6e8e..aac9168 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -1,7 +1,7 @@
 /*
  *  linux/net/sunrpc/gss_krb5_mech.c
  *
- *  Copyright (c) 2001 The Regents of the University of Michigan.
+ *  Copyright (c) 2001-2008 The Regents of the University of Michigan.
  *  All rights reserved.
  *
  *  Andy Adamson <andros@umich.edu>
@@ -48,6 +48,49 @@
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
 
+static struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
+	/*
+	 * DES (All DES enctypes are mapped to the same gss functionality)
+	 */
+	{
+	  .etype = ENCTYPE_DES_CBC_RAW,
+	  .ctype = CKSUMTYPE_RSA_MD5,
+	  .name = "des-cbc-crc",
+	  .encrypt_name = "cbc(des)",
+	  .cksum_name = "md5",
+	  .encrypt = krb5_encrypt,
+	  .decrypt = krb5_decrypt,
+	  .signalg = SGN_ALG_DES_MAC_MD5,
+	  .sealalg = SEAL_ALG_DES,
+	  .keybytes = 7,
+	  .keylength = 8,
+	  .blocksize = 8,
+	  .cksumlength = 8,
+	},
+};
+
+static int num_supported_enctypes = ARRAY_SIZE(supported_gss_krb5_enctypes);
+
+static int
+supported_gss_krb5_enctype(int etype)
+{
+	int i;
+	for (i = 0; i < num_supported_enctypes; i++)
+		if (supported_gss_krb5_enctypes[i].etype == etype)
+			return 1;
+	return 0;
+}
+
+static struct gss_krb5_enctype *
+get_gss_krb5_enctype(int etype)
+{
+	int i;
+	for (i = 0; i < num_supported_enctypes; i++)
+		if (supported_gss_krb5_enctypes[i].etype == etype)
+			return &supported_gss_krb5_enctypes[i];
+	return NULL;
+}
+
 static const void *
 simple_get_bytes(const void *p, const void *end, void *res, int len)
 {
@@ -78,35 +121,45 @@ simple_get_netobj(const void *p, const void *end, struct xdr_netobj *res)
 }
 
 static inline const void *
-get_key(const void *p, const void *end, struct crypto_blkcipher **res)
+get_key(const void *p, const void *end,
+	struct krb5_ctx *ctx, struct crypto_blkcipher **res)
 {
 	struct xdr_netobj	key;
 	int			alg;
-	char			*alg_name;
 
 	p = simple_get_bytes(p, end, &alg, sizeof(alg));
 	if (IS_ERR(p))
 		goto out_err;
+
+	switch (alg) {
+	case ENCTYPE_DES_CBC_CRC:
+	case ENCTYPE_DES_CBC_MD4:
+	case ENCTYPE_DES_CBC_MD5:
+		/* Map all these key types to ENCTYPE_DES_CBC_RAW */
+		alg = ENCTYPE_DES_CBC_RAW;
+		break;
+	}
+
+	if (!supported_gss_krb5_enctype(alg)) {
+		printk("gss_kerberos_mech: unsupported encryption "
+			"key algorithm %d\n", alg);
+		goto out_err;
+	}
 	p = simple_get_netobj(p, end, &key);
 	if (IS_ERR(p))
 		goto out_err;
 
-	switch (alg) {
-		case ENCTYPE_DES_CBC_RAW:
-			alg_name = "cbc(des)";
-			break;
-		default:
-			printk("gss_kerberos_mech: unsupported algorithm %d\n", alg);
-			goto out_err_free_key;
-	}
-	*res = crypto_alloc_blkcipher(alg_name, 0, CRYPTO_ALG_ASYNC);
+	*res = crypto_alloc_blkcipher(ctx->gk5e->encrypt_name, 0,
+							CRYPTO_ALG_ASYNC);
 	if (IS_ERR(*res)) {
-		printk("gss_kerberos_mech: unable to initialize crypto algorithm %s\n", alg_name);
+		printk("gss_kerberos_mech: unable to initialize crypto "
+			"algorithm %s\n", ctx->gk5e->encrypt_name);
 		*res = NULL;
 		goto out_err_free_key;
 	}
 	if (crypto_blkcipher_setkey(*res, key.data, key.len)) {
-		printk("gss_kerberos_mech: error setting key for crypto algorithm %s\n", alg_name);
+		printk("gss_kerberos_mech: error setting key for crypto "
+			"algorithm %s\n", ctx->gk5e->encrypt_name);
 		goto out_err_free_tfm;
 	}
 
@@ -134,6 +187,10 @@ gss_import_v1_context(const void *p, const void *end, struct krb5_ctx *ctx)
 	/* Old format supports only DES!  Any other enctype uses new format */
 	ctx->enctype = ENCTYPE_DES_CBC_RAW;
 
+	ctx->gk5e = get_gss_krb5_enctype(ctx->enctype);
+	if (ctx->gk5e == NULL)
+		goto out_err;
+
 	/* The downcall format was designed before we completely understood
 	 * the uses of the context fields; so it includes some stuff we
 	 * just give some minimal sanity-checking, and some we ignore
@@ -164,10 +221,10 @@ gss_import_v1_context(const void *p, const void *end, struct krb5_ctx *ctx)
 	p = simple_get_netobj(p, end, &ctx->mech_used);
 	if (IS_ERR(p))
 		goto out_err;
-	p = get_key(p, end, &ctx->enc);
+	p = get_key(p, end, ctx, &ctx->enc);
 	if (IS_ERR(p))
 		goto out_err_free_mech;
-	p = get_key(p, end, &ctx->seq);
+	p = get_key(p, end, ctx, &ctx->seq);
 	if (IS_ERR(p))
 		goto out_err_free_key1;
 	if (p != end) {
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index 6319b33..f0e9a65 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -3,7 +3,7 @@
  *
  *  Adapted from MIT Kerberos 5-1.2.1 lib/gssapi/krb5/k5seal.c
  *
- *  Copyright (c) 2000 The Regents of the University of Michigan.
+ *  Copyright (c) 2000-2008 The Regents of the University of Michigan.
  *  All rights reserved.
  *
  *  Andy Adamson	<andros@umich.edu>
@@ -71,36 +71,47 @@
 
 DEFINE_SPINLOCK(krb5_seq_lock);
 
+static char *
+setup_token(struct krb5_ctx *ctx, struct xdr_netobj *token)
+{
+	__be16 *ptr, *krb5_hdr;
+	int body_size = GSS_KRB5_TOK_HDR_LEN + ctx->gk5e->cksumlength;
+
+	token->len = g_token_size(&ctx->mech_used, body_size);
+
+	ptr = (__be16 *)token->data;
+	g_make_token_header(&ctx->mech_used, body_size, (unsigned char **)&ptr);
+
+	/* ptr now at start of header described in rfc 1964, section 1.2.1: */
+	krb5_hdr = ptr;
+	*ptr++ = KG_TOK_MIC_MSG;
+	*ptr++ = cpu_to_le16(ctx->gk5e->signalg);
+	*ptr++ = SEAL_ALG_NONE;
+	*ptr++ = 0xffff;
+
+	return (char *)krb5_hdr;
+}
+
 static u32
 gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
 		struct xdr_netobj *token)
 {
-	char			cksumdata[16];
-	struct xdr_netobj	md5cksum = {.len = 0, .data = cksumdata};
-	unsigned char		*ptr, *msg_start;
+	char			cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
+	struct xdr_netobj	md5cksum = {.len = sizeof(cksumdata),
+					    .data = cksumdata};
+	void			*ptr;
 	s32			now;
 	u32			seq_send;
 
-	dprintk("RPC:       gss_krb5_seal\n");
+	dprintk("RPC:       %s\n", __func__);
 	BUG_ON(ctx == NULL);
 
 	now = get_seconds();
 
-	token->len = g_token_size(&ctx->mech_used, GSS_KRB5_TOK_HDR_LEN + 8);
-
-	ptr = token->data;
-	g_make_token_header(&ctx->mech_used, GSS_KRB5_TOK_HDR_LEN + 8, &ptr);
-
-	/* ptr now at header described in rfc 1964, section 1.2.1: */
-	ptr[0] = (unsigned char) ((KG_TOK_MIC_MSG >> 8) & 0xff);
-	ptr[1] = (unsigned char) (KG_TOK_MIC_MSG & 0xff);
-
-	msg_start = ptr + GSS_KRB5_TOK_HDR_LEN + 8;
-
-	*(__be16 *)(ptr + 2) = htons(SGN_ALG_DES_MAC_MD5);
-	memset(ptr + 4, 0xff, 4);
+	ptr = setup_token(ctx, token);
 
-	if (make_checksum("md5", ptr, 8, text, 0, &md5cksum))
+	if (make_checksum((char *)ctx->gk5e->cksum_name, ptr, 8,
+						text, 0, &md5cksum))
 		return GSS_S_FAILURE;
 
 	if (krb5_encrypt(ctx->seq, NULL, md5cksum.data,
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index 945609a..ffba3a9 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -3,7 +3,7 @@
  *
  *  Adapted from MIT Kerberos 5-1.2.1 lib/gssapi/krb5/k5unseal.c
  *
- *  Copyright (c) 2000 The Regents of the University of Michigan.
+ *  Copyright (c) 2000-2008 The Regents of the University of Michigan.
  *  All rights reserved.
  *
  *  Andy Adamson   <andros@umich.edu>
@@ -77,8 +77,9 @@ gss_verify_mic_v1(struct krb5_ctx *ctx,
 {
 	int			signalg;
 	int			sealalg;
-	char			cksumdata[16];
-	struct xdr_netobj	md5cksum = {.len = 0, .data = cksumdata};
+	char			cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
+	struct xdr_netobj	md5cksum = {.len = sizeof(cksumdata),
+					    .data = cksumdata};
 	s32			now;
 	int			direction;
 	u32			seqnum;
@@ -98,7 +99,7 @@ gss_verify_mic_v1(struct krb5_ctx *ctx,
 	/* XXX sanity-check bodysize?? */
 
 	signalg = ptr[2] + (ptr[3] << 8);
-	if (signalg != SGN_ALG_DES_MAC_MD5)
+	if (signalg != ctx->gk5e->signalg)
 		return GSS_S_DEFECTIVE_TOKEN;
 
 	sealalg = ptr[4] + (ptr[5] << 8);
@@ -108,13 +109,15 @@ gss_verify_mic_v1(struct krb5_ctx *ctx,
 	if ((ptr[6] != 0xff) || (ptr[7] != 0xff))
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	if (make_checksum("md5", ptr, 8, message_buffer, 0, &md5cksum))
+	if (make_checksum((char *)ctx->gk5e->cksum_name, ptr, 8,
+					message_buffer, 0, &md5cksum))
 		return GSS_S_FAILURE;
 
 	if (krb5_encrypt(ctx->seq, NULL, md5cksum.data, md5cksum.data, 16))
 		return GSS_S_FAILURE;
 
-	if (memcmp(md5cksum.data + 8, ptr + GSS_KRB5_TOK_HDR_LEN, 8))
+	if (memcmp(md5cksum.data + 8, ptr + GSS_KRB5_TOK_HDR_LEN,
+					ctx->gk5e->cksumlength))
 		return GSS_S_BAD_SIG;
 
 	/* it got through unscathed.  Make sure the context is unexpired */
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 743fa92..6de2db3 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -1,3 +1,33 @@
+/*
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
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/jiffies.h>
@@ -129,8 +159,9 @@ static u32
 gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 		struct xdr_buf *buf, struct page **pages)
 {
-	char			cksumdata[16];
-	struct xdr_netobj	md5cksum = {.len = 0, .data = cksumdata};
+	char			cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
+	struct xdr_netobj	md5cksum = {.len = sizeof(cksumdata),
+					    .data = cksumdata};
 	int			blocksize = 0, plainlen;
 	unsigned char		*ptr, *msg_start;
 	s32			now;
@@ -138,7 +169,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	struct page		**tmp_pages;
 	u32			seq_send;
 
-	dprintk("RPC:       gss_wrap_kerberos\n");
+	dprintk("RPC:       %s\n", __func__);
 
 	GSS_KRB5_SLACK_CHECK;
 	now = get_seconds();
@@ -148,8 +179,9 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	BUG_ON((buf->len - offset) % blocksize);
 	plainlen = blocksize + buf->len - offset;
 
-	headlen = g_token_size(&kctx->mech_used, 24 + plainlen) -
-						(buf->len - offset);
+	headlen = g_token_size(&kctx->mech_used,
+		GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength + plainlen) -
+		(buf->len - offset);
 
 	ptr = buf->head[0].iov_base + offset;
 	/* shift data to make room for header. */
@@ -159,25 +191,26 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	BUG_ON((buf->len - offset - headlen) % blocksize);
 
 	g_make_token_header(&kctx->mech_used,
-				GSS_KRB5_TOK_HDR_LEN + 8 + plainlen, &ptr);
+				GSS_KRB5_TOK_HDR_LEN +
+				kctx->gk5e->cksumlength + plainlen, &ptr);
 
 
 	/* ptr now at header described in rfc 1964, section 1.2.1: */
 	ptr[0] = (unsigned char) ((KG_TOK_WRAP_MSG >> 8) & 0xff);
 	ptr[1] = (unsigned char) (KG_TOK_WRAP_MSG & 0xff);
 
-	msg_start = ptr + 24;
+	msg_start = ptr + GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength;
 
-	*(__be16 *)(ptr + 2) = htons(SGN_ALG_DES_MAC_MD5);
+	*(__be16 *)(ptr + 2) = cpu_to_le16(kctx->gk5e->signalg);
 	memset(ptr + 4, 0xff, 4);
-	*(__be16 *)(ptr + 4) = htons(SEAL_ALG_DES);
+	*(__be16 *)(ptr + 4) = cpu_to_le16(kctx->gk5e->sealalg);
 
 	make_confounder(msg_start, blocksize);
 
 	/* XXXJBF: UGH!: */
 	tmp_pages = buf->pages;
 	buf->pages = pages;
-	if (make_checksum("md5", ptr, 8, buf,
+	if (make_checksum((char *)kctx->gk5e->cksum_name, ptr, 8, buf,
 				offset + headlen - blocksize, &md5cksum))
 		return GSS_S_FAILURE;
 	buf->pages = tmp_pages;
@@ -209,8 +242,9 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 {
 	int			signalg;
 	int			sealalg;
-	char			cksumdata[16];
-	struct xdr_netobj	md5cksum = {.len = 0, .data = cksumdata};
+	char			cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
+	struct xdr_netobj	md5cksum = {.len = sizeof(cksumdata),
+					    .data = cksumdata};
 	s32			now;
 	int			direction;
 	s32			seqnum;
@@ -219,6 +253,7 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	void			*data_start, *orig_start;
 	int			data_len;
 	int			blocksize;
+	int			crypt_offset;
 
 	dprintk("RPC:       gss_unwrap_kerberos\n");
 
@@ -236,22 +271,27 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	/* get the sign and seal algorithms */
 
 	signalg = ptr[2] + (ptr[3] << 8);
-	if (signalg != SGN_ALG_DES_MAC_MD5)
+	if (signalg != kctx->gk5e->signalg)
 		return GSS_S_DEFECTIVE_TOKEN;
 
 	sealalg = ptr[4] + (ptr[5] << 8);
-	if (sealalg != SEAL_ALG_DES)
+	if (sealalg != kctx->gk5e->sealalg)
 		return GSS_S_DEFECTIVE_TOKEN;
 
 	if ((ptr[6] != 0xff) || (ptr[7] != 0xff))
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	if (gss_decrypt_xdr_buf(kctx->enc, buf,
-			ptr + GSS_KRB5_TOK_HDR_LEN + 8 - (unsigned char *)buf->head[0].iov_base))
+	/*
+	 * Data starts after token header and checksum.  ptr points
+	 * to the beginning of the token header
+	 */
+	crypt_offset = ptr + (GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength) -
+					(unsigned char *)buf->head[0].iov_base;
+	if (gss_decrypt_xdr_buf(kctx->enc, buf, crypt_offset))
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	if (make_checksum("md5", ptr, 8, buf,
-		 ptr + GSS_KRB5_TOK_HDR_LEN + 8 - (unsigned char *)buf->head[0].iov_base, &md5cksum))
+	if (make_checksum((char *)kctx->gk5e->cksum_name, ptr, 8, buf,
+						crypt_offset, &md5cksum))
 		return GSS_S_FAILURE;
 
 	if (krb5_encrypt(kctx->seq, NULL, md5cksum.data,
@@ -282,7 +322,8 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	 * better to copy and encrypt at the same time. */
 
 	blocksize = crypto_blkcipher_blocksize(kctx->enc);
-	data_start = ptr + GSS_KRB5_TOK_HDR_LEN + 8 + blocksize;
+	data_start = ptr + (GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength) +
+					blocksize;
 	orig_start = buf->head[0].iov_base + offset;
 	data_len = (buf->head[0].iov_base + buf->head[0].iov_len) - data_start;
 	memmove(orig_start, data_start, data_len);

