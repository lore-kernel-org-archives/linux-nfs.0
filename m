From: steved@redhat.com
Subject: [PATCH 19/23] gssd_krb5: More arcfour-hmac support
Date: Wed, 17 Mar 2010 13:03:04 -0400
Message-ID: <1268845388-9516-20-git-send-email-steved@redhat.com>
References: <1268845388-9516-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:43414 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753688Ab0CQR0A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 13:26:00 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1NrweJ-0003fC-AT
	for linux-nfs@vger.kernel.org; Wed, 17 Mar 2010 13:03:15 -0400
In-Reply-To: <1268845388-9516-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

For the arcfour-hmac support, the make_seq_num and get_seq_num
functions need access to the kerberos context structure.
This will be used in a later patch.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 include/linux/sunrpc/gss_krb5.h       |    5 +++--
 net/sunrpc/auth_gss/gss_krb5_seal.c   |    5 ++---
 net/sunrpc/auth_gss/gss_krb5_seqnum.c |    6 ++++--
 net/sunrpc/auth_gss/gss_krb5_unseal.c |    3 ++-
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |    6 +++---
 5 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 14c9b0c..9cc39fe 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -275,12 +275,13 @@ gss_decrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *inbuf,
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
 	       unsigned char *cksum,
 	       unsigned char *buf, int *direction, u32 *seqnum);
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index eb18930..b6bc20f 100644
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
index 17562b4..46d900e 100644
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
@@ -62,13 +63,14 @@ krb5_make_seq_num(struct crypto_blkcipher *key,
 }
 
 s32
-krb5_get_seq_num(struct crypto_blkcipher *key,
+krb5_get_seq_num(struct krb5_ctx *kctx,
 	       unsigned char *cksum,
 	       unsigned char *buf,
 	       int *direction, u32 *seqnum)
 {
 	s32 code;
 	unsigned char plain[8];
+	struct crypto_blkcipher *key = kctx->seq;
 
 	dprintk("RPC:       krb5_get_seq_num:\n");
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index 5491886..b4416e6 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -132,7 +132,8 @@ gss_verify_mic_v1(struct krb5_ctx *ctx,
 
 	/* do sequencing checks */
 
-	if (krb5_get_seq_num(ctx->seq, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8, &direction, &seqnum))
+	if (krb5_get_seq_num(ctx, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8,
+			     &direction, &seqnum))
 		return GSS_S_FAILURE;
 
 	if ((ctx->initiate && direction != 0xff) ||
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index c8c402b..82014cc 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -228,7 +228,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 
 	/* XXX would probably be more efficient to compute checksum
 	 * and encrypt at the same time: */
-	if ((krb5_make_seq_num(kctx->seq, kctx->initiate ? 0 : 0xff,
+	if ((krb5_make_seq_num(kctx, kctx->seq, kctx->initiate ? 0 : 0xff,
 			       seq_send, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8)))
 		return GSS_S_FAILURE;
 
@@ -315,8 +315,8 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 
 	/* do sequencing checks */
 
-	if (krb5_get_seq_num(kctx->seq, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8,
-				    &direction, &seqnum))
+	if (krb5_get_seq_num(kctx, ptr + GSS_KRB5_TOK_HDR_LEN,
+				    ptr + 8, &direction, &seqnum))
 		return GSS_S_BAD_SIG;
 
 	if ((kctx->initiate && direction != 0xff) ||
-- 
1.6.6.1

