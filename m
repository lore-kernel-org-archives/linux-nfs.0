From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 19/22] gssd_krb5: More arcfour-hmac support
Date: Wed, 14 Apr 2010 13:36:55 -0400
Message-ID: <1271266618-26016-20-git-send-email-Trond.Myklebust@netapp.com>
References: <1271266618-26016-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-6-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-7-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-8-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-9-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-10-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-11-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-12-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-13-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-14-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-15-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-16-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-17-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-18-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-19-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28110 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756571Ab0DNRhV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Apr 2010 13:37:21 -0400
Received: from localhost.localdomain (pd07336a.hq.netapp.com [10.58.61.110] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3EHawKF021574
	for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2010 10:37:10 -0700 (PDT)
In-Reply-To: <1271266618-26016-19-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

For the arcfour-hmac support, the make_seq_num and get_seq_num
functions need access to the kerberos context structure.
This will be used in a later patch.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/gss_krb5.h       |    5 +++--
 net/sunrpc/auth_gss/gss_krb5_seal.c   |    5 ++---
 net/sunrpc/auth_gss/gss_krb5_seqnum.c |    6 ++++--
 net/sunrpc/auth_gss/gss_krb5_unseal.c |    3 ++-
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |    6 +++---
 5 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index b0ab827..d840856 100644
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
index e22fed3..36fe487 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -152,9 +152,8 @@ gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
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
index 6331cd6..83b5930 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seqnum.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
@@ -40,7 +40,8 @@
 #endif
 
 s32
-krb5_make_seq_num(struct crypto_blkcipher *key,
+krb5_make_seq_num(struct krb5_ctx *kctx,
+		struct crypto_blkcipher *key,
 		int direction,
 		u32 seqnum,
 		unsigned char *cksum, unsigned char *buf)
@@ -61,13 +62,14 @@ krb5_make_seq_num(struct crypto_blkcipher *key,
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
index ef91366..97eb91b 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -131,7 +131,8 @@ gss_verify_mic_v1(struct krb5_ctx *ctx,
 
 	/* do sequencing checks */
 
-	if (krb5_get_seq_num(ctx->seq, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8, &direction, &seqnum))
+	if (krb5_get_seq_num(ctx, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8,
+			     &direction, &seqnum))
 		return GSS_S_FAILURE;
 
 	if ((ctx->initiate && direction != 0xff) ||
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 097cc27..a95e7e0 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -227,7 +227,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 
 	/* XXX would probably be more efficient to compute checksum
 	 * and encrypt at the same time: */
-	if ((krb5_make_seq_num(kctx->seq, kctx->initiate ? 0 : 0xff,
+	if ((krb5_make_seq_num(kctx, kctx->seq, kctx->initiate ? 0 : 0xff,
 			       seq_send, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8)))
 		return GSS_S_FAILURE;
 
@@ -314,8 +314,8 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 
 	/* do sequencing checks */
 
-	if (krb5_get_seq_num(kctx->seq, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8,
-				    &direction, &seqnum))
+	if (krb5_get_seq_num(kctx, ptr + GSS_KRB5_TOK_HDR_LEN,
+				    ptr + 8, &direction, &seqnum))
 		return GSS_S_BAD_SIG;
 
 	if ((kctx->initiate && direction != 0xff) ||
-- 
1.6.6.1

