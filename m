From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 3: PATCH 21/24] gss_krb5: pass struct krb5_ctx
	pointer to sequence number functions
Date: Tue, 06 May 2008 17:05:19 -0400
Message-ID: <20080506210519.3770.22673.stgit@jazz.citi.umich.edu>
References: <20080506210156.3770.95914.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:24004 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764787AbYEFVFU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 17:05:20 -0400
In-Reply-To: <20080506210156.3770.95914.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For the arcfour-hmac support, the make_seq_num and get_seq_num functions
need access to the kerberos context structure.  This will be used in a
later patch.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 include/linux/sunrpc/gss_krb5.h       |    6 ++++--
 net/sunrpc/auth_gss/gss_krb5_seal.c   |    5 ++---
 net/sunrpc/auth_gss/gss_krb5_seqnum.c |    6 ++++--
 net/sunrpc/auth_gss/gss_krb5_unseal.c |    3 ++-
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |    6 +++---
 5 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 9753485..de87e20 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -275,12 +275,14 @@ gss_decrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *inbuf,
 		    int offset);
 
 s32
-krb5_make_seq_num(struct crypto_blkcipher *key,
+krb5_make_seq_num(struct krb5_ctx *kctx,
+		struct crypto_blkcipher *key,
 		int direction,
 		u32 seqnum, unsigned char *cksum, unsigned char *buf);
 
 s32
-krb5_get_seq_num(struct crypto_blkcipher *key,
+krb5_get_seq_num(struct krb5_ctx *kctx,
+	       struct crypto_blkcipher *key,
 	       unsigned char *cksum,
 	       unsigned char *buf, int *direction, u32 *seqnum);
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index ee46080..0048ed7 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -153,9 +153,8 @@ gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
 	seq_send = ctx->seq_send++;
 	spin_unlock(&krb5_seq_lock);
 
-	if (krb5_make_seq_num(ctx->seq, ctx->initiate ? 0 : 0xff,
-			      seq_send, ptr + GSS_KRB5_TOK_HDR_LEN,
-			      ptr + 8))
+	if (krb5_make_seq_num(ctx, ctx->seq, ctx->initiate ? 0 : 0xff,
+			      seq_send, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8))
 		return GSS_S_FAILURE;
 
 	return (ctx->endtime < now) ? GSS_S_CONTEXT_EXPIRED : GSS_S_COMPLETE;
diff --git a/net/sunrpc/auth_gss/gss_krb5_seqnum.c b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
index f160be6..c7b196d 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seqnum.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
@@ -41,7 +41,8 @@
 #endif
 
 s32
-krb5_make_seq_num(struct crypto_blkcipher *key,
+krb5_make_seq_num(struct krb5_ctx *kctx,
+		struct crypto_blkcipher *key,
 		int direction,
 		u32 seqnum,
 		unsigned char *cksum, unsigned char *buf)
@@ -62,7 +63,8 @@ krb5_make_seq_num(struct crypto_blkcipher *key,
 }
 
 s32
-krb5_get_seq_num(struct crypto_blkcipher *key,
+krb5_get_seq_num(struct krb5_ctx *kctx,
+	       struct crypto_blkcipher *key,
 	       unsigned char *cksum,
 	       unsigned char *buf,
 	       int *direction, u32 *seqnum)
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index 5491886..760d628 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -132,7 +132,8 @@ gss_verify_mic_v1(struct krb5_ctx *ctx,
 
 	/* do sequencing checks */
 
-	if (krb5_get_seq_num(ctx->seq, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8, &direction, &seqnum))
+	if (krb5_get_seq_num(ctx, ctx->seq, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8,
+			     &direction, &seqnum))
 		return GSS_S_FAILURE;
 
 	if ((ctx->initiate && direction != 0xff) ||
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 6453dd3..2a0d72f 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -229,7 +229,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 
 	/* XXX would probably be more efficient to compute checksum
 	 * and encrypt at the same time: */
-	if ((krb5_make_seq_num(kctx->seq, kctx->initiate ? 0 : 0xff,
+	if ((krb5_make_seq_num(kctx, kctx->seq, kctx->initiate ? 0 : 0xff,
 			       seq_send, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8)))
 		return GSS_S_FAILURE;
 
@@ -316,8 +316,8 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 
 	/* do sequencing checks */
 
-	if (krb5_get_seq_num(kctx->seq, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8,
-				    &direction, &seqnum))
+	if (krb5_get_seq_num(kctx, kctx->seq, ptr + GSS_KRB5_TOK_HDR_LEN,
+				    ptr + 8, &direction, &seqnum))
 		return GSS_S_BAD_SIG;
 
 	if ((kctx->initiate && direction != 0xff) ||

