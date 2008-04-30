From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 2: PATCH 21/26] gss_krb5: add a usage parameter to
	the make_checksum function
Date: Wed, 30 Apr 2008 12:47:34 -0400
Message-ID: <20080430164734.16010.89288.stgit@jazz.citi.umich.edu>
References: <20080430164306.16010.44650.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:28305 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757848AbYD3Qrf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2008 12:47:35 -0400
In-Reply-To: <20080430164306.16010.44650.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For arcfour-hmac support, the make_checksum function needs a usage
field to correctly calculate the checksum differently for MIC and
WRAP tokens.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 include/linux/sunrpc/gss_krb5.h       |    4 ++--
 net/sunrpc/auth_gss/gss_krb5_crypto.c |   15 +++++++++++----
 net/sunrpc/auth_gss/gss_krb5_seal.c   |   13 +++++++++----
 net/sunrpc/auth_gss/gss_krb5_unseal.c |   12 ++++++++----
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |    4 ++--
 5 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index eb97980..9fa6fec 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -237,12 +237,12 @@ extern struct xdr_netobj krb5_oid;
 u32
 make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
 		struct xdr_buf *body, int body_offset, u8 *cksumkey,
-		struct xdr_netobj *cksumout);
+		unsigned int usage, struct xdr_netobj *cksumout);
 
 u32
 make_checksum_v2(struct krb5_ctx *, char *header, int hdrlen,
 		 struct xdr_buf *body, int body_offset, u8 *key,
-		 struct xdr_netobj *cksum);
+		 unsigned int usage, struct xdr_netobj *cksum);
 
 u32 gss_get_mic_kerberos(struct gss_ctx *, struct xdr_buf *,
 		struct xdr_netobj *);
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index c50ec81..deb3530 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -133,7 +133,7 @@ checksummer(struct scatterlist *sg, void *data)
 u32
 make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
 	      struct xdr_buf *body, int body_offset, u8 *cksumkey,
-	      struct xdr_netobj *cksumout)
+	      unsigned int usage, struct xdr_netobj *cksumout)
 {
 	struct hash_desc                desc;
 	struct scatterlist              sg[1];
@@ -209,7 +209,7 @@ out:
 u32
 make_checksum_v2(struct krb5_ctx *kctx, char *header, int hdrlen,
 		 struct xdr_buf *body, int body_offset, u8 *cksumkey,
-		 struct xdr_netobj *cksumout)
+		 unsigned int usage, struct xdr_netobj *cksumout)
 {
 	struct hash_desc desc;
 	struct scatterlist sg[1];
@@ -556,15 +556,18 @@ gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
 	int nblocks, nbytes;
 	struct encryptor_desc desc;
 	u32 cbcbytes;
+	unsigned int usage;
 
 	if (kctx->initiate) {
 		cipher = kctx->initiator_enc;
 		aux_cipher = kctx->initiator_enc_aux;
 		cksumkey = kctx->initiator_integ;
+		usage = KG_USAGE_INITIATOR_SEAL;
 	} else {
 		cipher = kctx->acceptor_enc;
 		aux_cipher = kctx->acceptor_enc_aux;
 		cksumkey = kctx->acceptor_integ;
+		usage = KG_USAGE_ACCEPTOR_SEAL;
 	}
 	blocksize = crypto_blkcipher_blocksize(cipher);
 
@@ -609,7 +612,8 @@ gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
 	buf->pages = pages;
 
 	err = make_checksum_v2(kctx, NULL, 0, buf,
-			       offset + GSS_KRB5_TOK_HDR_LEN, cksumkey, &hmac);
+			       offset + GSS_KRB5_TOK_HDR_LEN,
+			       cksumkey, usage, &hmac);
 	buf->pages = save_pages;
 	if (err)
 		return GSS_S_FAILURE;
@@ -673,15 +677,18 @@ gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf,
 	u8 pkt_hmac[GSS_KRB5_MAX_CKSUM_LEN];
 	int nblocks, blocksize, cbcbytes;
 	struct decryptor_desc desc;
+	unsigned int usage;
 
 	if (kctx->initiate) {
 		cipher = kctx->acceptor_enc;
 		aux_cipher = kctx->acceptor_enc_aux;
 		cksum_key = kctx->acceptor_integ;
+		usage = KG_USAGE_ACCEPTOR_SEAL;
 	} else {
 		cipher = kctx->initiator_enc;
 		aux_cipher = kctx->initiator_enc_aux;
 		cksum_key = kctx->initiator_integ;
+		usage = KG_USAGE_INITIATOR_SEAL;
 	}
 	blocksize = crypto_blkcipher_blocksize(cipher);
 
@@ -724,7 +731,7 @@ gss_krb5_aes_decrypt(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf,
 	our_hmac_obj.data = our_hmac;
 
 	ret = make_checksum_v2(kctx, NULL, 0, &subbuf, 0,
-			       cksum_key, &our_hmac_obj);
+			       cksum_key, usage, &our_hmac_obj);
 	if (ret)
 		goto out_err;
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index d4706ce..a98fbb5 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -143,7 +143,8 @@ gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
 	else
 		cksumkey = NULL;
 
-	if (make_checksum(ctx, ptr, 8, text, 0, cksumkey, &md5cksum))
+	if (make_checksum(ctx, ptr, 8, text, 0, cksumkey,
+			  KG_USAGE_SIGN, &md5cksum))
 		return GSS_S_FAILURE;
 
 	memcpy(ptr + GSS_KRB5_TOK_HDR_LEN, md5cksum.data, md5cksum.len);
@@ -171,6 +172,7 @@ gss_get_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *text,
 	s32 now;
 	u64 seq_send;
 	u8 *cksumkey;
+	unsigned int cksum_usage;
 
 	dprintk("RPC:       %s\n", __func__);
 	BUG_ON(ctx == NULL);
@@ -184,13 +186,16 @@ gss_get_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *text,
 	spin_unlock(&krb5_seq_lock);
 	*((u64 *)(krb5_hdr + 8)) = cpu_to_be64(seq_send);
 
-	if (ctx->initiate)
+	if (ctx->initiate) {
 		cksumkey = ctx->initiator_sign;
-	else
+		cksum_usage = KG_USAGE_INITIATOR_SIGN;
+	} else {
 		cksumkey = ctx->acceptor_sign;
+		cksum_usage = KG_USAGE_ACCEPTOR_SIGN;
+	}
 
 	if (make_checksum_v2(ctx, krb5_hdr, GSS_KRB5_TOK_HDR_LEN,
-			     text, 0, cksumkey, &cksumobj))
+			     text, 0, cksumkey, cksum_usage, &cksumobj))
 		return GSS_S_FAILURE;
 
 	memcpy(krb5_hdr + GSS_KRB5_TOK_HDR_LEN, cksumobj.data, cksumobj.len);
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index d9ee31d..ecd424a 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -116,7 +116,7 @@ gss_verify_mic_v1(struct krb5_ctx *ctx,
 		cksumkey = NULL;
 
 	if (make_checksum(ctx, ptr, 8, message_buffer, 0,
-			  cksumkey, &md5cksum))
+			  cksumkey, KG_USAGE_SIGN, &md5cksum))
 		return GSS_S_FAILURE;
 
 	if (memcmp(md5cksum.data, ptr + GSS_KRB5_TOK_HDR_LEN,
@@ -155,6 +155,7 @@ gss_verify_mic_v2(struct krb5_ctx *ctx,
 	u8 *cksumkey;
 	u8 flags;
 	int i;
+	unsigned int cksum_usage;
 
 	dprintk("RPC:       %s\n", __func__);
 
@@ -175,13 +176,16 @@ gss_verify_mic_v2(struct krb5_ctx *ctx,
 		if (ptr[i] != 0xff)
 			return GSS_S_DEFECTIVE_TOKEN;
 
-	if (ctx->initiate)
+	if (ctx->initiate) {
 		cksumkey = ctx->acceptor_sign;
-	else
+		cksum_usage = KG_USAGE_ACCEPTOR_SIGN;
+	} else {
 		cksumkey = ctx->initiator_sign;
+		cksum_usage = KG_USAGE_INITIATOR_SIGN;
+	}
 
 	if (make_checksum_v2(ctx, ptr, GSS_KRB5_TOK_HDR_LEN, message_buffer, 0,
-			     cksumkey, &cksumobj))
+			     cksumkey, cksum_usage, &cksumobj))
 		return GSS_S_FAILURE;
 
 	if (memcmp(cksumobj.data, ptr + GSS_KRB5_TOK_HDR_LEN,
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index b249f27..5e8572f 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -217,7 +217,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 	tmp_pages = buf->pages;
 	buf->pages = pages;
 	if (make_checksum(kctx, ptr, 8, buf, offset + headlen - blocksize,
-					cksumkey, &md5cksum))
+					cksumkey, KG_USAGE_SEAL, &md5cksum))
 		return GSS_S_FAILURE;
 	buf->pages = tmp_pages;
 
@@ -300,7 +300,7 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 		cksumkey = NULL;
 
 	if (make_checksum(kctx, ptr, 8, buf, crypt_offset,
-						cksumkey, &md5cksum))
+					cksumkey, KG_USAGE_SEAL, &md5cksum))
 		return GSS_S_FAILURE;
 
 	if (memcmp(md5cksum.data, ptr + GSS_KRB5_TOK_HDR_LEN,

