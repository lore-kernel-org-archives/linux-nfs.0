From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 2: PATCH 18/26] gss_krb5: add support for new token
	formats in rfc4121
Date: Wed, 30 Apr 2008 12:47:19 -0400
Message-ID: <20080430164719.16010.17675.stgit@jazz.citi.umich.edu>
References: <20080430164306.16010.44650.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:8369 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757789AbYD3QrU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2008 12:47:20 -0400
In-Reply-To: <20080430164306.16010.44650.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a step toward support for AES encryption types which are required
to use the new token formats defined in rfc4121.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 include/linux/sunrpc/gss_krb5.h       |   28 ++++
 net/sunrpc/auth_gss/gss_krb5_crypto.c |   74 ++++++++++
 net/sunrpc/auth_gss/gss_krb5_seal.c   |   70 +++++++++
 net/sunrpc/auth_gss/gss_krb5_unseal.c |   61 ++++++++
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |  247 +++++++++++++++++++++++++++++++++
 5 files changed, 480 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index a76255d..37e6bd9 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -53,6 +53,8 @@
 /* Maximum blocksize for the supported crypto algorithms */
 #define GSS_KRB5_MAX_BLOCKSIZE  (16)
 
+struct krb5_ctx;
+
 struct gss_krb5_enctype {
 	const u32		etype;		/* encryption (key) type */
 	const u32		ctype;		/* checksum type */
@@ -75,6 +77,12 @@ struct gss_krb5_enctype {
 	u32 (*mk_key) (struct gss_krb5_enctype *gk5e,
 		       struct xdr_netobj *in,
 		       struct xdr_netobj *out);	/* complete key generation */
+	u32 (*encrypt_v2) (struct krb5_ctx *kctx, u32 offset,
+			   struct xdr_buf *buf, int ec,
+			   struct page **pages); /* v2 encryption function */
+	u32 (*decrypt_v2) (struct krb5_ctx *kctx, u32 offset,
+			   struct xdr_buf *buf, u32 *headskip,
+			   u32 *tailskip);	/* v2 decryption function */
 };
 
 /* krb5_ctx flags definitions */
@@ -112,6 +120,18 @@ extern spinlock_t krb5_seq_lock;
 #define KG_TOK_MIC_MSG    0x0101
 #define KG_TOK_WRAP_MSG   0x0201
 
+#define KG2_TOK_INITIAL     0x0101
+#define KG2_TOK_RESPONSE    0x0202
+#define KG2_TOK_MIC         0x0404
+#define KG2_TOK_WRAP        0x0504
+
+#define KG2_TOKEN_FLAG_SENTBYACCEPTOR   0x01
+#define KG2_TOKEN_FLAG_SEALED           0x02
+#define KG2_TOKEN_FLAG_ACCEPTORSUBKEY   0x04
+
+#define KG2_RESP_FLAG_ERROR             0x0001
+#define KG2_RESP_FLAG_DELEG_OK          0x0002
+
 enum sgn_alg {
 	SGN_ALG_DES_MAC_MD5 = 0x0000,
 	SGN_ALG_MD2_5 = 0x0001,
@@ -138,6 +158,9 @@ extern struct xdr_netobj krb5_oid;
 #define CKSUMTYPE_RSA_MD5_DES		0x0008
 #define CKSUMTYPE_NIST_SHA		0x0009
 #define CKSUMTYPE_HMAC_SHA1_DES3	0x000c
+#define CKSUMTYPE_HMAC_SHA1_96_AES128   0x000f
+#define CKSUMTYPE_HMAC_SHA1_96_AES256   0x0010
+#define CKSUMTYPE_HMAC_MD5_ARCFOUR      -138 /* Microsoft md5 hmac cksumtype */
 
 /* from gssapi_err_krb5.h */
 #define KG_CCACHE_NOMATCH                        (39756032L)
@@ -214,6 +237,11 @@ make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
 		struct xdr_buf *body, int body_offset, u8 *cksumkey,
 		struct xdr_netobj *cksumout);
 
+u32
+make_checksum_v2(struct krb5_ctx *, char *header, int hdrlen,
+		 struct xdr_buf *body, int body_offset, u8 *key,
+		 struct xdr_netobj *cksum);
+
 u32 gss_get_mic_kerberos(struct gss_ctx *, struct xdr_buf *,
 		struct xdr_netobj *);
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 0c91186..66ba0b3 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -198,6 +198,80 @@ out:
 	return err ? GSS_S_FAILURE : 0;
 }
 
+/*
+ * checksum the plaintext data and hdrlen bytes of the token header
+ * Per rfc4121, sec. 4.2.4, the checksum is performed over the data
+ * body then over the first 16 octets of the MIC token
+ * Inclusion of the header data in the calculation of the
+ * checksum is optional.
+ */
+u32
+make_checksum_v2(struct krb5_ctx *kctx, char *header, int hdrlen,
+		 struct xdr_buf *body, int body_offset, u8 *cksumkey,
+		 struct xdr_netobj *cksumout)
+{
+	struct hash_desc desc;
+	struct scatterlist sg[1];
+	int err;
+	u8 checksumdata[GSS_KRB5_MAX_CKSUM_LEN];
+	unsigned int checksumlen;
+
+	if (kctx->gk5e->keyed_cksum == 0) {
+		dprintk("%s: expected keyed hash for %s\n",
+			__func__, kctx->gk5e->name);
+		return GSS_S_FAILURE;
+	}
+	if (cksumkey == NULL) {
+		dprintk("%s: no key supplied for %s\n",
+			__func__, kctx->gk5e->name);
+		return GSS_S_FAILURE;
+	}
+
+	desc.tfm = crypto_alloc_hash(kctx->gk5e->cksum_name, 0,
+							CRYPTO_ALG_ASYNC);
+	if (IS_ERR(desc.tfm))
+		return GSS_S_FAILURE;
+	checksumlen = crypto_hash_digestsize(desc.tfm);
+	desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
+
+	err = crypto_hash_setkey(desc.tfm, cksumkey, kctx->gk5e->keylength);
+	if (err)
+		goto out;
+
+	err = crypto_hash_init(&desc);
+	if (err)
+		goto out;
+	err = xdr_process_buf(body, body_offset, body->len - body_offset,
+			      checksummer, &desc);
+	if (err)
+		goto out;
+	if (header != NULL) {
+		sg_init_one(sg, header, hdrlen);
+		err = crypto_hash_update(&desc, sg, hdrlen);
+		if (err)
+			goto out;
+	}
+	err = crypto_hash_final(&desc, checksumdata);
+	if (err)
+		goto out;
+
+	cksumout->len = kctx->gk5e->cksumlength;
+
+	switch (kctx->gk5e->ctype) {
+	case CKSUMTYPE_HMAC_SHA1_96_AES128:
+	case CKSUMTYPE_HMAC_SHA1_96_AES256:
+		/* note that this truncates the hash */
+		memcpy(cksumout->data, checksumdata, kctx->gk5e->cksumlength);
+		break;
+	default:
+		BUG();
+		break;
+	}
+out:
+	crypto_free_hash(desc.tfm);
+	return err ? GSS_S_FAILURE : 0;
+}
+
 struct encryptor_desc {
 	u8 iv[GSS_KRB5_MAX_BLOCKSIZE];
 	struct blkcipher_desc desc;
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index 432d6e5..d4706ce 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -92,6 +92,33 @@ setup_token(struct krb5_ctx *ctx, struct xdr_netobj *token)
 	return (char *)krb5_hdr;
 }
 
+static void *
+setup_token_v2(struct krb5_ctx *ctx, struct xdr_netobj *token)
+{
+	__be16 *ptr, *krb5_hdr;
+	u8 *p, flags = 0x00;
+
+	if ((ctx->flags & KRB5_CTX_FLAG_INITIATOR) == 0)
+		flags |= 0x01;
+	if (ctx->flags & KRB5_CTX_FLAG_ACCEPTOR_SUBKEY)
+		flags |= 0x04;
+
+	/* Per rfc 4121, sec 4.2.6.1, there is no header,
+	 * just start the token */
+	krb5_hdr = ptr = (__be16 *)token->data;
+
+	*ptr++ = KG2_TOK_MIC;
+	p = (u8 *)ptr;
+	*p++ = flags;
+	*p++ = 0xff;
+	ptr = (__be16 *)p;
+	*ptr++ = 0xffff;
+	*ptr++ = 0xffff;
+
+	token->len = GSS_KRB5_TOK_HDR_LEN + ctx->gk5e->cksumlength;
+	return krb5_hdr;
+}
+
 static u32
 gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
 		struct xdr_netobj *token)
@@ -134,6 +161,46 @@ gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
 }
 
 u32
+gss_get_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *text,
+		struct xdr_netobj *token)
+{
+	char cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
+	struct xdr_netobj cksumobj = { .len = sizeof(cksumdata),
+				       .data = cksumdata};
+	void *krb5_hdr;
+	s32 now;
+	u64 seq_send;
+	u8 *cksumkey;
+
+	dprintk("RPC:       %s\n", __func__);
+	BUG_ON(ctx == NULL);
+
+	krb5_hdr = setup_token_v2(ctx, token);
+
+	/* Set up the sequence number. Now 64-bits in clear
+	 * text and w/o direction indicator */
+	spin_lock(&krb5_seq_lock);
+	seq_send = ctx->seq_send64++;
+	spin_unlock(&krb5_seq_lock);
+	*((u64 *)(krb5_hdr + 8)) = cpu_to_be64(seq_send);
+
+	if (ctx->initiate)
+		cksumkey = ctx->initiator_sign;
+	else
+		cksumkey = ctx->acceptor_sign;
+
+	if (make_checksum_v2(ctx, krb5_hdr, GSS_KRB5_TOK_HDR_LEN,
+			     text, 0, cksumkey, &cksumobj))
+		return GSS_S_FAILURE;
+
+	memcpy(krb5_hdr + GSS_KRB5_TOK_HDR_LEN, cksumobj.data, cksumobj.len);
+
+	now = get_seconds();
+
+	return (ctx->endtime < now) ? GSS_S_CONTEXT_EXPIRED : GSS_S_COMPLETE;
+}
+
+u32
 gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
 		     struct xdr_netobj *token)
 {
@@ -145,6 +212,9 @@ gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
 	case ENCTYPE_DES_CBC_RAW:
 	case ENCTYPE_DES3_CBC_RAW:
 		return gss_get_mic_v1(ctx, text, token);
+	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
+	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
+		return gss_get_mic_v2(ctx, text, token);
 	}
 }
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index 404edbb..d9ee31d 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -142,6 +142,64 @@ gss_verify_mic_v1(struct krb5_ctx *ctx,
 	return GSS_S_COMPLETE;
 }
 
+static u32
+gss_verify_mic_v2(struct krb5_ctx *ctx,
+		struct xdr_buf *message_buffer, struct xdr_netobj *read_token)
+{
+	char cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
+	struct xdr_netobj cksumobj = {.len = sizeof(cksumdata),
+				      .data = cksumdata};
+	s32 now;
+	u64 seqnum;
+	u8 *ptr = read_token->data;
+	u8 *cksumkey;
+	u8 flags;
+	int i;
+
+	dprintk("RPC:       %s\n", __func__);
+
+	if (be16_to_cpu(*((__be16 *)ptr)) != KG2_TOK_MIC)
+		return GSS_S_DEFECTIVE_TOKEN;
+
+	flags = ptr[2];
+	if ((!ctx->initiate && (flags & KG2_TOKEN_FLAG_SENTBYACCEPTOR)) ||
+	    (ctx->initiate && !(flags & KG2_TOKEN_FLAG_SENTBYACCEPTOR)))
+		return GSS_S_BAD_SIG;
+
+	if (flags & KG2_TOKEN_FLAG_SEALED) {
+		dprintk("%s: token has unexpected sealed flag\n", __func__);
+		return GSS_S_FAILURE;
+	}
+
+	for (i = 3; i < 8; i++)
+		if (ptr[i] != 0xff)
+			return GSS_S_DEFECTIVE_TOKEN;
+
+	if (ctx->initiate)
+		cksumkey = ctx->acceptor_sign;
+	else
+		cksumkey = ctx->initiator_sign;
+
+	if (make_checksum_v2(ctx, ptr, GSS_KRB5_TOK_HDR_LEN, message_buffer, 0,
+			     cksumkey, &cksumobj))
+		return GSS_S_FAILURE;
+
+	if (memcmp(cksumobj.data, ptr + GSS_KRB5_TOK_HDR_LEN,
+				ctx->gk5e->cksumlength))
+		return GSS_S_BAD_SIG;
+
+	/* it got through unscathed.  Make sure the context is unexpired */
+	now = get_seconds();
+	if (now > ctx->endtime)
+		return GSS_S_CONTEXT_EXPIRED;
+
+	/* do sequencing checks */
+
+	seqnum = be64_to_cpu((__be64 *)ptr + 8);
+
+	return GSS_S_COMPLETE;
+}
+
 u32
 gss_verify_mic_kerberos(struct gss_ctx *gss_ctx,
 			struct xdr_buf *message_buffer,
@@ -155,6 +213,9 @@ gss_verify_mic_kerberos(struct gss_ctx *gss_ctx,
 	case ENCTYPE_DES_CBC_RAW:
 	case ENCTYPE_DES3_CBC_RAW:
 		return gss_verify_mic_v1(ctx, message_buffer, read_token);
+	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
+	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
+		return gss_verify_mic_v2(ctx, message_buffer, read_token);
 	}
 }
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index c9c8cfb..c7235ec 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -342,6 +342,247 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	return GSS_S_COMPLETE;
 }
 
+#define TEST_ROTATE 0
+#define TEST_EXTRA_COUNT  0
+
+#if TEST_ROTATE
+static u32
+rotate_right(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf,
+	     struct page **pages, u16 *rrc)
+{
+	u16 rotate_count = 0;
+	u8 *tbuf;
+
+	/*
+	 * As a quick test, if there is tail data that will fit within
+	 * the head, move it there
+	 */
+
+	/* If there is no tail, don't bother */
+	if (buf->tail[0].iov_base == NULL)
+		goto out;
+
+	/* If head and tail share a page, don't bother */
+	if (buf->tail[0].iov_base - buf->head[0].iov_base < PAGE_CACHE_SIZE)
+		goto out;
+
+	tbuf = kmalloc(buf->tail[0].iov_len, GFP_KERNEL);
+	if (tbuf == NULL)
+		goto out;
+
+	memcpy(tbuf, buf->tail[0].iov_base, buf->tail[0].iov_len);
+
+	/* XXX This assumes there is room in the head */
+	rotate_count = buf->tail[0].iov_len;
+
+	if (shift_head_data(buf, offset + GSS_KRB5_TOK_HDR_LEN, rotate_count))
+		goto out;
+	memcpy(buf->head[0].iov_base + offset + GSS_KRB5_TOK_HDR_LEN, tbuf,
+		buf->tail[0].iov_len);
+	/* this is adjusted upwards in shift_head_data(),
+	 * but we aren't adjusting the total length */
+	buf->len -= rotate_count;
+
+	buf->tail[0].iov_len -= rotate_count;
+	buf->tail[0].iov_base = NULL;   /* Needed? Correct? */
+
+	kfree(tbuf);
+out:
+	*rrc = rotate_count;
+	dprintk("%s: returning with rotate_count of %u\n", __func__, *rrc);
+	return 0;
+}
+#endif
+
+/*
+ * We cannot currently handle tokens with rotated data.  We need a
+ * generalized routine to rotate the data in place.  It is anticipated
+ * that we won't encounter rotated data in the general case.
+ */
+static u32
+rotate_left(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf, u16 rrc)
+{
+	unsigned int realrrc = rrc % (buf->len - offset - GSS_KRB5_TOK_HDR_LEN);
+
+	if (realrrc == 0)
+		return 0;
+
+	dprintk("%s: cannot process token with rotated data: "
+		"rrc %u, realrrc %u\n", __func__, rrc, realrrc);
+	return 1;
+}
+
+static u32
+gss_wrap_kerberos_v2(struct krb5_ctx *kctx, u32 offset,
+		     struct xdr_buf *buf, struct page **pages)
+{
+	int		blocksize;
+	u8		*ptr, *plainhdr;
+	s32		now;
+	u8		flags = 0x00;
+	__be16		*be16ptr, ec = 0;
+	__be64		*be64ptr;
+	u32		err;
+#if TEST_ROTATE
+	u16		rrc;
+#endif
+#if TEST_EXTRA_COUNT
+	unsigned int	plainlen;
+#endif
+
+	dprintk("RPC:       %s\n", __func__);
+
+	GSS_KRB5_SLACK_CHECK;
+
+	if (kctx->gk5e->encrypt_v2 == NULL)
+		return GSS_S_FAILURE;
+
+#if TEST_EXTRA_COUNT
+	plainlen = buf->head[0].iov_len - offset
+				+ buf->page_len + buf->tail[0].iov_len;
+#endif
+	/* make room for gss token header */
+	if (shift_head_data(buf, offset, GSS_KRB5_TOK_HDR_LEN))
+		return GSS_S_FAILURE;
+
+	/* construct gss token header */
+	ptr = plainhdr = buf->head[0].iov_base + offset;
+	*ptr++ = (unsigned char) ((KG2_TOK_WRAP>>8) & 0xff);
+	*ptr++ = (unsigned char) (KG2_TOK_WRAP & 0xff);
+
+	if ((kctx->flags & KRB5_CTX_FLAG_INITIATOR) == 0)
+		flags |= KG2_TOKEN_FLAG_SENTBYACCEPTOR;
+	if ((kctx->flags & KRB5_CTX_FLAG_ACCEPTOR_SUBKEY) != 0)
+		flags |= KG2_TOKEN_FLAG_ACCEPTORSUBKEY;
+	/* We always do confidentiality in wrap tokens */
+	flags |= KG2_TOKEN_FLAG_SEALED;
+
+	*ptr++ = flags;
+	*ptr++ = 0xff;
+	be16ptr = (__be16 *)ptr;
+
+	blocksize = crypto_blkcipher_blocksize(kctx->acceptor_enc);
+#if TEST_EXTRA_COUNT
+	ec = plainlen % blocksize ? blocksize - plainlen % blocksize : 0;
+#endif
+	*be16ptr++ = cpu_to_be16(ec);
+	/* "inner" token header always uses 0 for RRC */
+	*be16ptr++ = cpu_to_be16(0);
+
+	be64ptr = (__be64 *)be16ptr;
+	spin_lock(&krb5_seq_lock);
+	*be64ptr = cpu_to_be64(kctx->seq_send64++);
+	spin_unlock(&krb5_seq_lock);
+
+	err = (*kctx->gk5e->encrypt_v2)(kctx, offset, buf, ec, pages);
+	if (err)
+		return err;
+
+#if TEST_ROTATE
+	err = rotate_right(kctx, offset, buf, pages, &rrc);
+	if (err)
+		return err;
+	*((__be16 *)(plainhdr + 6)) = cpu_to_be16(rrc);
+#endif
+	now = get_seconds();
+	return (kctx->endtime < now) ? GSS_S_CONTEXT_EXPIRED : GSS_S_COMPLETE;
+}
+
+static u32
+gss_unwrap_kerberos_v2(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
+{
+	s32		now;
+	u64		seqnum;
+	u8		*ptr;
+	u8		flags = 0x00;
+	u16		ec, rrc;
+	int		err;
+	u32		headskip, tailskip;
+	u8		decrypted_hdr[GSS_KRB5_TOK_HDR_LEN];
+	unsigned int	movelen;
+
+
+	dprintk("RPC:       %s\n", __func__);
+
+	if (kctx->gk5e->decrypt_v2 == NULL)
+		return GSS_S_FAILURE;
+
+	ptr = buf->head[0].iov_base + offset;
+
+	if (be16_to_cpu(*((__be16 *)ptr)) != KG2_TOK_WRAP)
+		return GSS_S_DEFECTIVE_TOKEN;
+
+	flags = ptr[2];
+	if ((!kctx->initiate && (flags & KG2_TOKEN_FLAG_SENTBYACCEPTOR)) ||
+	    (kctx->initiate && !(flags & KG2_TOKEN_FLAG_SENTBYACCEPTOR)))
+		return GSS_S_BAD_SIG;
+
+	if ((flags & KG2_TOKEN_FLAG_SEALED) == 0) {
+		dprintk("%s: token missing expected sealed flag\n", __func__);
+		return GSS_S_DEFECTIVE_TOKEN;
+	}
+
+	if (ptr[3] != 0xff)
+		return GSS_S_DEFECTIVE_TOKEN;
+
+	ec = be16_to_cpup((__be16 *)(ptr + 4));
+	rrc = be16_to_cpup((__be16 *)(ptr + 6));
+
+	seqnum = be64_to_cpup((__be64 *)(ptr + 8));
+
+	if (rrc != 0) {
+		err = rotate_left(kctx, offset, buf, rrc);
+		if (err)
+			return GSS_S_FAILURE;
+	}
+
+	err = (*kctx->gk5e->decrypt_v2)(kctx, offset, buf,
+					&headskip, &tailskip);
+	if (err)
+		return GSS_S_FAILURE;
+
+	/*
+	 * Retrieve the decrypted gss token header and verify
+	 * it against the original
+	 */
+	err = read_bytes_from_xdr_buf(buf,
+				buf->len - GSS_KRB5_TOK_HDR_LEN - tailskip,
+				decrypted_hdr, GSS_KRB5_TOK_HDR_LEN);
+	if (err) {
+		dprintk("%s: error %u getting decrypted_hdr\n", __func__, err);
+		return GSS_S_FAILURE;
+	}
+	if (memcmp(ptr, decrypted_hdr, 6)
+				|| memcmp(ptr + 8, decrypted_hdr + 8, 8)) {
+		dprintk("%s: token hdr, plaintext hdr mismatch!\n", __func__);
+		return GSS_S_FAILURE;
+	}
+
+	/* do sequencing checks */
+
+	/* it got through unscathed.  Make sure the context is unexpired */
+	now = get_seconds();
+	if (now > kctx->endtime)
+		return GSS_S_CONTEXT_EXPIRED;
+
+	/*
+	 * Move the head data back to the right position in xdr_buf.
+	 * We ignore any "ec" data since it might be in the head or
+	 * the tail, and we really don't need to deal with it.
+	 * Note that buf->head[0].iov_len may indicate the available
+	 * head buffer space rather than that actually occupied.
+	 */
+	movelen = min_t(unsigned int, buf->head[0].iov_len, buf->len);
+	movelen -= offset + GSS_KRB5_TOK_HDR_LEN + headskip;
+	BUG_ON(offset + GSS_KRB5_TOK_HDR_LEN + headskip + movelen >
+							buf->head[0].iov_len);
+	memmove(ptr, ptr + GSS_KRB5_TOK_HDR_LEN + headskip, movelen);
+	buf->head[0].iov_len -= GSS_KRB5_TOK_HDR_LEN + headskip;
+	buf->len -= GSS_KRB5_TOK_HDR_LEN + headskip;
+
+	return GSS_S_COMPLETE;
+}
+
 u32
 gss_wrap_kerberos(struct gss_ctx *gctx, int offset,
 		  struct xdr_buf *buf, struct page **pages)
@@ -354,6 +595,9 @@ gss_wrap_kerberos(struct gss_ctx *gctx, int offset,
 	case ENCTYPE_DES_CBC_RAW:
 	case ENCTYPE_DES3_CBC_RAW:
 		return gss_wrap_kerberos_v1(kctx, offset, buf, pages);
+	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
+	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
+		return gss_wrap_kerberos_v2(kctx, offset, buf, pages);
 	}
 }
 
@@ -368,6 +612,9 @@ gss_unwrap_kerberos(struct gss_ctx *gctx, int offset, struct xdr_buf *buf)
 	case ENCTYPE_DES_CBC_RAW:
 	case ENCTYPE_DES3_CBC_RAW:
 		return gss_unwrap_kerberos_v1(kctx, offset, buf);
+	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
+	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
+		return gss_unwrap_kerberos_v2(kctx, offset, buf);
 	}
 }
 

