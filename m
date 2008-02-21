From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 11/19] gss_krb5: introduce encryption type framework
Date: Thu, 21 Feb 2008 13:44:42 -0500
Message-ID: <20080221184442.19195.30418.stgit@jazz.citi.umich.edu>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:28161 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754513AbYBUSon (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 13:44:43 -0500
Received: from jazz.citi.umich.edu (jazz.citi.umich.edu [141.211.133.62])
	by citi.umich.edu (Postfix) with ESMTP id B66ED4504
	for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 13:44:42 -0500 (EST)
In-Reply-To: <20080221184208.19195.94518.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add enctype framework and change functions to use the generic
values from it rather than the values hard-coded for des.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 include/linux/sunrpc/gss_krb5.h       |   29 +++++++++++
 net/sunrpc/auth_gss/gss_krb5_crypto.c |   16 +++---
 net/sunrpc/auth_gss/gss_krb5_mech.c   |   88 +++++++++++++++++++++++++++------
 net/sunrpc/auth_gss/gss_krb5_seal.c   |   48 +++++++++++-------
 net/sunrpc/auth_gss/gss_krb5_unseal.c |   12 +++--
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |   49 +++++++++++-------
 6 files changed, 175 insertions(+), 67 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index dfe382a..d10d8ce 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -36,13 +36,42 @@
  *
  */
 
+#include <linux/crypto.h>
 #include <linux/sunrpc/auth_gss.h>
 #include <linux/sunrpc/gss_err.h>
 #include <linux/sunrpc/gss_asn1.h>
 
+/* Maximum checksum function output for the supported crypto algorithms */
+#define GSS_KRB5_MAX_CKSUM_LEN  20
+
+/* Maximum blocksize for the supported crypto algorithms */
+#define GSS_KRB5_MAX_BLOCKSIZE  16
+
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
index 1d52308..39643a7 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
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
@@ -95,13 +95,13 @@ krb5_decrypt(
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
@@ -164,7 +164,7 @@ out:
 EXPORT_SYMBOL(make_checksum);
 
 struct encryptor_desc {
-	u8 iv[8]; /* XXX hard-coded blocksize */
+	u8 iv[GSS_KRB5_MAX_BLOCKSIZE];
 	struct blkcipher_desc desc;
 	int pos;
 	struct xdr_buf *outbuf;
@@ -205,7 +205,7 @@ encryptor(struct scatterlist *sg, void *data)
 	desc->fraglen += sg->length;
 	desc->pos += sg->length;
 
-	fraglen = thislen & 7; /* XXX hardcoded blocksize */
+	fraglen = thislen & (crypto_blkcipher_blocksize(desc->desc.tfm) - 1);
 	thislen -= fraglen;
 
 	if (thislen == 0)
@@ -265,7 +265,7 @@ gss_encrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *buf,
 EXPORT_SYMBOL(gss_encrypt_xdr_buf);
 
 struct decryptor_desc {
-	u8 iv[8]; /* XXX hard-coded blocksize */
+	u8 iv[GSS_KRB5_MAX_BLOCKSIZE];
 	struct blkcipher_desc desc;
 	struct scatterlist frags[4];
 	int fragno;
@@ -287,7 +287,7 @@ decryptor(struct scatterlist *sg, void *data)
 	desc->fragno++;
 	desc->fraglen += sg->length;
 
-	fraglen = thislen & 7; /* XXX hardcoded blocksize */
+	fraglen = thislen & (crypto_blkcipher_blocksize(desc->desc.tfm) - 1);
 	thislen -= fraglen;
 
 	if (thislen == 0)
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index f0f0749..fe88266 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -48,6 +48,50 @@
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
+static int num_supported_enctypes =
+	sizeof(supported_gss_krb5_enctypes) / sizeof(struct gss_krb5_enctype);
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
@@ -78,35 +122,45 @@ simple_get_netobj(const void *p, const void *end, struct xdr_netobj *res)
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
 
@@ -134,6 +188,10 @@ gss_import_v1_context(const void *p, const void *end, struct krb5_ctx *ctx)
 	/* Old format supports only DES!  Any other enctype uses new format */
 	ctx->enctype = ENCTYPE_DES_CBC_RAW;
 
+	ctx->gk5e = get_gss_krb5_enctype(ctx->enctype);
+	if (ctx->gk5e == NULL)
+		goto out_err;
+
 	/* The downcall format was designed before we completely understood
 	 * the uses of the context fields; so it includes some stuff we
 	 * just give some minimal sanity-checking, and some we ignore
@@ -164,10 +222,10 @@ gss_import_v1_context(const void *p, const void *end, struct krb5_ctx *ctx)
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
index 3b9cc47..64cabf2 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -71,37 +71,47 @@
 
 DEFINE_SPINLOCK(krb5_seq_lock);
 
+static char *
+setup_token(struct krb5_ctx *ctx, struct xdr_netobj *token)
+{
+	__be16 *ptr, *krb5_hdr;
+	int body_size = 16 + ctx->gk5e->cksumlength;
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
-	unsigned char		*ptr, *krb5_hdr, *msg_start;
+	char			cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
+	struct xdr_netobj	md5cksum = {.len = sizeof(cksumdata),
+					    .data = cksumdata};
+	void			*krb5_hdr;
 	s32			now;
 	u32			seq_send;
 
-	dprintk("RPC:       gss_krb5_seal\n");
+	dprintk("RPC:       %s\n", __func__);
 	BUG_ON(ctx == NULL);
 
 	now = get_seconds();
 
-	token->len = g_token_size(&ctx->mech_used, 24);
-
-	ptr = token->data;
-	g_make_token_header(&ctx->mech_used, 24, &ptr);
-
-	*ptr++ = (unsigned char) ((KG_TOK_MIC_MSG>>8)&0xff);
-	*ptr++ = (unsigned char) (KG_TOK_MIC_MSG&0xff);
-
-	/* ptr now at byte 2 of header described in rfc 1964, section 1.2.1: */
-	krb5_hdr = ptr - 2;
-	msg_start = krb5_hdr + 24;
-
-	*(__be16 *)(krb5_hdr + 2) = htons(SGN_ALG_DES_MAC_MD5);
-	memset(krb5_hdr + 4, 0xff, 4);
+	krb5_hdr = setup_token(ctx, token);
 
-	if (make_checksum("md5", krb5_hdr, 8, text, 0, &md5cksum))
+	if (make_checksum((char *)ctx->gk5e->cksum_name, krb5_hdr, 8,
+						text, 0, &md5cksum))
 		return GSS_S_FAILURE;
 
 	if (krb5_encrypt(ctx->seq, NULL, md5cksum.data,
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index 211eca4..43bd213 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
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
 	s32			seqnum;
@@ -98,7 +99,7 @@ gss_verify_mic_v1(struct krb5_ctx *ctx,
 	/* XXX sanity-check bodysize?? */
 
 	signalg = ptr[0] + (ptr[1] << 8);
-	if (signalg != SGN_ALG_DES_MAC_MD5)
+	if (signalg != ctx->gk5e->signalg)
 		return GSS_S_DEFECTIVE_TOKEN;
 
 	sealalg = ptr[2] + (ptr[3] << 8);
@@ -108,13 +109,14 @@ gss_verify_mic_v1(struct krb5_ctx *ctx,
 	if ((ptr[4] != 0xff) || (ptr[5] != 0xff))
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	if (make_checksum("md5", ptr - 2, 8, message_buffer, 0, &md5cksum))
+	if (make_checksum((char *)ctx->gk5e->cksum_name, ptr - 2, 8,
+					message_buffer, 0, &md5cksum))
 		return GSS_S_FAILURE;
 
 	if (krb5_encrypt(ctx->seq, NULL, md5cksum.data, md5cksum.data, 16))
 		return GSS_S_FAILURE;
 
-	if (memcmp(md5cksum.data + 8, ptr + 14, 8))
+	if (memcmp(md5cksum.data + 8, ptr + 14, ctx->gk5e->cksumlength))
 		return GSS_S_BAD_SIG;
 
 	/* it got through unscathed.  Make sure the context is unexpired */
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 9f13411..e369696 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -102,8 +102,9 @@ static u32
 gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 		struct xdr_buf *buf, struct page **pages)
 {
-	char			cksumdata[16];
-	struct xdr_netobj	md5cksum = {.len = 0, .data = cksumdata};
+	char			cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
+	struct xdr_netobj	md5cksum = {.len = sizeof(cksumdata),
+					    .data = cksumdata};
 	int			blocksize = 0, plainlen;
 	unsigned char		*ptr, *krb5_hdr, *msg_start;
 	s32			now;
@@ -111,7 +112,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	struct page		**tmp_pages;
 	u32			seq_send;
 
-	dprintk("RPC:       gss_wrap_kerberos\n");
+	dprintk("RPC:       %s\n", __func__);
 
 	now = get_seconds();
 
@@ -120,8 +121,8 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	BUG_ON((buf->len - offset) % blocksize);
 	plainlen = blocksize + buf->len - offset;
 
-	headlen = g_token_size(&kctx->mech_used, 24 + plainlen) -
-						(buf->len - offset);
+	headlen = g_token_size(&kctx->mech_used,
+		16 + kctx->gk5e->cksumlength + plainlen) - (buf->len - offset);
 
 	ptr = buf->head[0].iov_base + offset;
 	/* shift data to make room for header. */
@@ -132,7 +133,8 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	buf->len += headlen;
 	BUG_ON((buf->len - offset - headlen) % blocksize);
 
-	g_make_token_header(&kctx->mech_used, 24 + plainlen, &ptr);
+	g_make_token_header(&kctx->mech_used,
+				16 + kctx->gk5e->cksumlength + plainlen, &ptr);
 
 
 	*ptr++ = (unsigned char) ((KG_TOK_WRAP_MSG>>8)&0xff);
@@ -140,18 +142,18 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 
 	/* ptr now at byte 2 of header described in rfc 1964, section 1.2.1: */
 	krb5_hdr = ptr - 2;
-	msg_start = krb5_hdr + 24;
+	msg_start = krb5_hdr + 16 + kctx->gk5e->cksumlength;
 
-	*(__be16 *)(krb5_hdr + 2) = htons(SGN_ALG_DES_MAC_MD5);
+	*(__be16 *)(krb5_hdr + 2) = cpu_to_le16(kctx->gk5e->signalg);
 	memset(krb5_hdr + 4, 0xff, 4);
-	*(__be16 *)(krb5_hdr + 4) = htons(SEAL_ALG_DES);
+	*(__be16 *)(krb5_hdr + 4) = cpu_to_le16(kctx->gk5e->sealalg);
 
 	make_confounder(msg_start, blocksize);
 
 	/* XXXJBF: UGH!: */
 	tmp_pages = buf->pages;
 	buf->pages = pages;
-	if (make_checksum("md5", krb5_hdr, 8, buf,
+	if (make_checksum((char *)kctx->gk5e->cksum_name, krb5_hdr, 8, buf,
 				offset + headlen - blocksize, &md5cksum))
 		return GSS_S_FAILURE;
 	buf->pages = tmp_pages;
@@ -183,8 +185,9 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
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
@@ -193,6 +196,7 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	void			*data_start, *orig_start;
 	int			data_len;
 	int			blocksize;
+	int			crypt_offset;
 
 	dprintk("RPC:       gss_unwrap_kerberos\n");
 
@@ -210,29 +214,34 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	/* get the sign and seal algorithms */
 
 	signalg = ptr[0] + (ptr[1] << 8);
-	if (signalg != SGN_ALG_DES_MAC_MD5)
+	if (signalg != kctx->gk5e->signalg)
 		return GSS_S_DEFECTIVE_TOKEN;
 
 	sealalg = ptr[2] + (ptr[3] << 8);
-	if (sealalg != SEAL_ALG_DES)
+	if (sealalg != kctx->gk5e->sealalg)
 		return GSS_S_DEFECTIVE_TOKEN;
 
 	if ((ptr[4] != 0xff) || (ptr[5] != 0xff))
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	if (gss_decrypt_xdr_buf(kctx->enc, buf,
-			ptr + 22 - (unsigned char *)buf->head[0].iov_base))
+	/*
+	 * Data starts after token header and checksum.  ptr points
+	 * two past the beginning of the token header (which is 16 bytes)
+	 */
+	crypt_offset = ptr + (16 - 2 + kctx->gk5e->cksumlength) -
+					(unsigned char *)buf->head[0].iov_base;
+	if (gss_decrypt_xdr_buf(kctx->enc, buf, crypt_offset))
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	if (make_checksum("md5", ptr - 2, 8, buf,
-		 ptr + 22 - (unsigned char *)buf->head[0].iov_base, &md5cksum))
+	if (make_checksum((char *)kctx->gk5e->cksum_name, ptr - 2, 8, buf,
+						crypt_offset, &md5cksum))
 		return GSS_S_FAILURE;
 
 	if (krb5_encrypt(kctx->seq, NULL, md5cksum.data,
 			   md5cksum.data, md5cksum.len))
 		return GSS_S_FAILURE;
 
-	if (memcmp(md5cksum.data + 8, ptr + 14, 8))
+	if (memcmp(md5cksum.data + 8, ptr + 14, 8))/* this is still DES-aware */
 		return GSS_S_BAD_SIG;
 
 	/* it got through unscathed.  Make sure the context is unexpired */
@@ -256,7 +265,7 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	 * better to copy and encrypt at the same time. */
 
 	blocksize = crypto_blkcipher_blocksize(kctx->enc);
-	data_start = ptr + 22 + blocksize;
+	data_start = ptr + (16 - 2 + kctx->gk5e->cksumlength) + blocksize;
 	orig_start = buf->head[0].iov_base + offset;
 	data_len = (buf->head[0].iov_base + buf->head[0].iov_len) - data_start;
 	memmove(orig_start, data_start, data_len);

