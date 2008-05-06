From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 3: PATCH 01/24] gss_krb5: create a define for token
	header size and clean up ptr location
Date: Tue, 06 May 2008 17:03:35 -0400
Message-ID: <20080506210333.3770.11447.stgit@jazz.citi.umich.edu>
References: <20080506210156.3770.95914.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:23021 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757421AbYEFVDf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 17:03:35 -0400
In-Reply-To: <20080506210156.3770.95914.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

cleanup:
Document token header size with a #define instead of open-coding it.

Don't needlessly increment "ptr" past the beginning of the header
which makes the values passed to functions more understandable and
eliminates the need for extra "krb5_hdr" pointer.

Clean up some intersecting  white-space issues flagged by checkpatch.pl.

This leaves the checksum length hard-coded at 8 for DES.  A later patch
cleans that up.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 include/linux/sunrpc/gss_krb5.h       |    3 ++
 net/sunrpc/auth_gss/gss_krb5_seal.c   |   26 +++++++++--------
 net/sunrpc/auth_gss/gss_krb5_unseal.c |   16 +++++------
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |   50 +++++++++++++++++----------------
 4 files changed, 49 insertions(+), 46 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index a10f1fb..e7bbdba 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -51,6 +51,9 @@ struct krb5_ctx {
 
 extern spinlock_t krb5_seq_lock;
 
+/* The length of the Kerberos GSS token header */
+#define GSS_KRB5_TOK_HDR_LEN	(16)
+
 #define KG_TOK_MIC_MSG    0x0101
 #define KG_TOK_WRAP_MSG   0x0201
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index 5f1d36d..b8f42ef 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -78,7 +78,7 @@ gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
 	struct krb5_ctx		*ctx = gss_ctx->internal_ctx_id;
 	char			cksumdata[16];
 	struct xdr_netobj	md5cksum = {.len = 0, .data = cksumdata};
-	unsigned char		*ptr, *krb5_hdr, *msg_start;
+	unsigned char		*ptr, *msg_start;
 	s32			now;
 	u32			seq_send;
 
@@ -87,36 +87,36 @@ gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
 
 	now = get_seconds();
 
-	token->len = g_token_size(&ctx->mech_used, 24);
+	token->len = g_token_size(&ctx->mech_used, GSS_KRB5_TOK_HDR_LEN + 8);
 
 	ptr = token->data;
-	g_make_token_header(&ctx->mech_used, 24, &ptr);
+	g_make_token_header(&ctx->mech_used, GSS_KRB5_TOK_HDR_LEN + 8, &ptr);
 
-	*ptr++ = (unsigned char) ((KG_TOK_MIC_MSG>>8)&0xff);
-	*ptr++ = (unsigned char) (KG_TOK_MIC_MSG&0xff);
+	/* ptr now at header described in rfc 1964, section 1.2.1: */
+	ptr[0] = (unsigned char) ((KG_TOK_MIC_MSG >> 8) & 0xff);
+	ptr[1] = (unsigned char) (KG_TOK_MIC_MSG & 0xff);
 
-	/* ptr now at byte 2 of header described in rfc 1964, section 1.2.1: */
-	krb5_hdr = ptr - 2;
-	msg_start = krb5_hdr + 24;
+	msg_start = ptr + GSS_KRB5_TOK_HDR_LEN + 8;
 
-	*(__be16 *)(krb5_hdr + 2) = htons(SGN_ALG_DES_MAC_MD5);
-	memset(krb5_hdr + 4, 0xff, 4);
+	*(__be16 *)(ptr + 2) = htons(SGN_ALG_DES_MAC_MD5);
+	memset(ptr + 4, 0xff, 4);
 
-	if (make_checksum("md5", krb5_hdr, 8, text, 0, &md5cksum))
+	if (make_checksum("md5", ptr, 8, text, 0, &md5cksum))
 		return GSS_S_FAILURE;
 
 	if (krb5_encrypt(ctx->seq, NULL, md5cksum.data,
 			  md5cksum.data, md5cksum.len))
 		return GSS_S_FAILURE;
 
-	memcpy(krb5_hdr + 16, md5cksum.data + md5cksum.len - 8, 8);
+	memcpy(ptr + GSS_KRB5_TOK_HDR_LEN, md5cksum.data + md5cksum.len - 8, 8);
 
 	spin_lock(&krb5_seq_lock);
 	seq_send = ctx->seq_send++;
 	spin_unlock(&krb5_seq_lock);
 
 	if (krb5_make_seq_num(ctx->seq, ctx->initiate ? 0 : 0xff,
-			      seq_send, krb5_hdr + 16, krb5_hdr + 8))
+			      seq_send, ptr + GSS_KRB5_TOK_HDR_LEN,
+			      ptr + 8))
 		return GSS_S_FAILURE;
 
 	return (ctx->endtime < now) ? GSS_S_CONTEXT_EXPIRED : GSS_S_COMPLETE;
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index d91a5d0..066ec73 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -92,30 +92,30 @@ gss_verify_mic_kerberos(struct gss_ctx *gss_ctx,
 					read_token->len))
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	if ((*ptr++ != ((KG_TOK_MIC_MSG>>8)&0xff)) ||
-	    (*ptr++ != ( KG_TOK_MIC_MSG    &0xff))   )
+	if ((ptr[0] != ((KG_TOK_MIC_MSG >> 8) & 0xff)) ||
+	    (ptr[1] !=  (KG_TOK_MIC_MSG & 0xff)))
 		return GSS_S_DEFECTIVE_TOKEN;
 
 	/* XXX sanity-check bodysize?? */
 
-	signalg = ptr[0] + (ptr[1] << 8);
+	signalg = ptr[2] + (ptr[3] << 8);
 	if (signalg != SGN_ALG_DES_MAC_MD5)
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	sealalg = ptr[2] + (ptr[3] << 8);
+	sealalg = ptr[4] + (ptr[5] << 8);
 	if (sealalg != SEAL_ALG_NONE)
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	if ((ptr[4] != 0xff) || (ptr[5] != 0xff))
+	if ((ptr[6] != 0xff) || (ptr[7] != 0xff))
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	if (make_checksum("md5", ptr - 2, 8, message_buffer, 0, &md5cksum))
+	if (make_checksum("md5", ptr, 8, message_buffer, 0, &md5cksum))
 		return GSS_S_FAILURE;
 
 	if (krb5_encrypt(ctx->seq, NULL, md5cksum.data, md5cksum.data, 16))
 		return GSS_S_FAILURE;
 
-	if (memcmp(md5cksum.data + 8, ptr + 14, 8))
+	if (memcmp(md5cksum.data + 8, ptr + GSS_KRB5_TOK_HDR_LEN, 8))
 		return GSS_S_BAD_SIG;
 
 	/* it got through unscathed.  Make sure the context is unexpired */
@@ -127,7 +127,7 @@ gss_verify_mic_kerberos(struct gss_ctx *gss_ctx,
 
 	/* do sequencing checks */
 
-	if (krb5_get_seq_num(ctx->seq, ptr + 14, ptr + 6, &direction, &seqnum))
+	if (krb5_get_seq_num(ctx->seq, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8, &direction, &seqnum))
 		return GSS_S_FAILURE;
 
 	if ((ctx->initiate && direction != 0xff) ||
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index b00b1b4..283cb25 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -122,7 +122,7 @@ gss_wrap_kerberos(struct gss_ctx *ctx, int offset,
 	char			cksumdata[16];
 	struct xdr_netobj	md5cksum = {.len = 0, .data = cksumdata};
 	int			blocksize = 0, plainlen;
-	unsigned char		*ptr, *krb5_hdr, *msg_start;
+	unsigned char		*ptr, *msg_start;
 	s32			now;
 	int			headlen;
 	struct page		**tmp_pages;
@@ -149,26 +149,26 @@ gss_wrap_kerberos(struct gss_ctx *ctx, int offset,
 	buf->len += headlen;
 	BUG_ON((buf->len - offset - headlen) % blocksize);
 
-	g_make_token_header(&kctx->mech_used, 24 + plainlen, &ptr);
+	g_make_token_header(&kctx->mech_used,
+				GSS_KRB5_TOK_HDR_LEN + 8 + plainlen, &ptr);
 
 
-	*ptr++ = (unsigned char) ((KG_TOK_WRAP_MSG>>8)&0xff);
-	*ptr++ = (unsigned char) (KG_TOK_WRAP_MSG&0xff);
+	/* ptr now at header described in rfc 1964, section 1.2.1: */
+	ptr[0] = (unsigned char) ((KG_TOK_WRAP_MSG >> 8) & 0xff);
+	ptr[1] = (unsigned char) (KG_TOK_WRAP_MSG & 0xff);
 
-	/* ptr now at byte 2 of header described in rfc 1964, section 1.2.1: */
-	krb5_hdr = ptr - 2;
-	msg_start = krb5_hdr + 24;
+	msg_start = ptr + 24;
 
-	*(__be16 *)(krb5_hdr + 2) = htons(SGN_ALG_DES_MAC_MD5);
-	memset(krb5_hdr + 4, 0xff, 4);
-	*(__be16 *)(krb5_hdr + 4) = htons(SEAL_ALG_DES);
+	*(__be16 *)(ptr + 2) = htons(SGN_ALG_DES_MAC_MD5);
+	memset(ptr + 4, 0xff, 4);
+	*(__be16 *)(ptr + 4) = htons(SEAL_ALG_DES);
 
 	make_confounder(msg_start, blocksize);
 
 	/* XXXJBF: UGH!: */
 	tmp_pages = buf->pages;
 	buf->pages = pages;
-	if (make_checksum("md5", krb5_hdr, 8, buf,
+	if (make_checksum("md5", ptr, 8, buf,
 				offset + headlen - blocksize, &md5cksum))
 		return GSS_S_FAILURE;
 	buf->pages = tmp_pages;
@@ -176,7 +176,7 @@ gss_wrap_kerberos(struct gss_ctx *ctx, int offset,
 	if (krb5_encrypt(kctx->seq, NULL, md5cksum.data,
 			  md5cksum.data, md5cksum.len))
 		return GSS_S_FAILURE;
-	memcpy(krb5_hdr + 16, md5cksum.data + md5cksum.len - 8, 8);
+	memcpy(ptr + GSS_KRB5_TOK_HDR_LEN, md5cksum.data + md5cksum.len - 8, 8);
 
 	spin_lock(&krb5_seq_lock);
 	seq_send = kctx->seq_send++;
@@ -185,7 +185,7 @@ gss_wrap_kerberos(struct gss_ctx *ctx, int offset,
 	/* XXX would probably be more efficient to compute checksum
 	 * and encrypt at the same time: */
 	if ((krb5_make_seq_num(kctx->seq, kctx->initiate ? 0 : 0xff,
-			       seq_send, krb5_hdr + 16, krb5_hdr + 8)))
+			       seq_send, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8)))
 		return GSS_S_FAILURE;
 
 	if (gss_encrypt_xdr_buf(kctx->enc, buf, offset + headlen - blocksize,
@@ -219,38 +219,38 @@ gss_unwrap_kerberos(struct gss_ctx *ctx, int offset, struct xdr_buf *buf)
 					buf->len - offset))
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	if ((*ptr++ != ((KG_TOK_WRAP_MSG>>8)&0xff)) ||
-	    (*ptr++ !=  (KG_TOK_WRAP_MSG    &0xff))   )
+	if ((ptr[0] != ((KG_TOK_WRAP_MSG >> 8) & 0xff)) ||
+	    (ptr[1] !=  (KG_TOK_WRAP_MSG & 0xff)))
 		return GSS_S_DEFECTIVE_TOKEN;
 
 	/* XXX sanity-check bodysize?? */
 
 	/* get the sign and seal algorithms */
 
-	signalg = ptr[0] + (ptr[1] << 8);
+	signalg = ptr[2] + (ptr[3] << 8);
 	if (signalg != SGN_ALG_DES_MAC_MD5)
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	sealalg = ptr[2] + (ptr[3] << 8);
+	sealalg = ptr[4] + (ptr[5] << 8);
 	if (sealalg != SEAL_ALG_DES)
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	if ((ptr[4] != 0xff) || (ptr[5] != 0xff))
+	if ((ptr[6] != 0xff) || (ptr[7] != 0xff))
 		return GSS_S_DEFECTIVE_TOKEN;
 
 	if (gss_decrypt_xdr_buf(kctx->enc, buf,
-			ptr + 22 - (unsigned char *)buf->head[0].iov_base))
+			ptr + GSS_KRB5_TOK_HDR_LEN + 8 - (unsigned char *)buf->head[0].iov_base))
 		return GSS_S_DEFECTIVE_TOKEN;
 
-	if (make_checksum("md5", ptr - 2, 8, buf,
-		 ptr + 22 - (unsigned char *)buf->head[0].iov_base, &md5cksum))
+	if (make_checksum("md5", ptr, 8, buf,
+		 ptr + GSS_KRB5_TOK_HDR_LEN + 8 - (unsigned char *)buf->head[0].iov_base, &md5cksum))
 		return GSS_S_FAILURE;
 
 	if (krb5_encrypt(kctx->seq, NULL, md5cksum.data,
 			   md5cksum.data, md5cksum.len))
 		return GSS_S_FAILURE;
 
-	if (memcmp(md5cksum.data + 8, ptr + 14, 8))
+	if (memcmp(md5cksum.data + 8, ptr + GSS_KRB5_TOK_HDR_LEN, 8))
 		return GSS_S_BAD_SIG;
 
 	/* it got through unscathed.  Make sure the context is unexpired */
@@ -262,8 +262,8 @@ gss_unwrap_kerberos(struct gss_ctx *ctx, int offset, struct xdr_buf *buf)
 
 	/* do sequencing checks */
 
-	if (krb5_get_seq_num(kctx->seq, ptr + 14, ptr + 6, &direction,
-				    &seqnum))
+	if (krb5_get_seq_num(kctx->seq, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8,
+				    &direction, &seqnum))
 		return GSS_S_BAD_SIG;
 
 	if ((kctx->initiate && direction != 0xff) ||
@@ -274,7 +274,7 @@ gss_unwrap_kerberos(struct gss_ctx *ctx, int offset, struct xdr_buf *buf)
 	 * better to copy and encrypt at the same time. */
 
 	blocksize = crypto_blkcipher_blocksize(kctx->enc);
-	data_start = ptr + 22 + blocksize;
+	data_start = ptr + GSS_KRB5_TOK_HDR_LEN + 8 + blocksize;
 	orig_start = buf->head[0].iov_base + offset;
 	data_len = (buf->head[0].iov_base + buf->head[0].iov_len) - data_start;
 	memmove(orig_start, data_start, data_len);

