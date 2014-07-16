Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:62869 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758739AbaGPKwg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 06:52:36 -0400
Received: by mail-qg0-f42.google.com with SMTP id j5so566786qga.15
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jul 2014 03:52:36 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/5] sunrpc: remove "ec" argument from encrypt_v2 operation
Date: Wed, 16 Jul 2014 06:52:22 -0400
Message-Id: <1405507942-12256-6-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405507942-12256-1-git-send-email-jlayton@primarydata.com>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
 <1405507942-12256-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's always 0.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/sunrpc/gss_krb5.h       | 4 ++--
 net/sunrpc/auth_gss/gss_krb5_crypto.c | 9 ++-------
 net/sunrpc/auth_gss/gss_krb5_wrap.c   | 2 +-
 3 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 5af2931cf58d..df02a4188487 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -81,7 +81,7 @@ struct gss_krb5_enctype {
 		       struct xdr_netobj *in,
 		       struct xdr_netobj *out);	/* complete key generation */
 	u32 (*encrypt_v2) (struct krb5_ctx *kctx, u32 offset,
-			   struct xdr_buf *buf, int ec,
+			   struct xdr_buf *buf,
 			   struct page **pages); /* v2 encryption function */
 	u32 (*decrypt_v2) (struct krb5_ctx *kctx, u32 offset,
 			   struct xdr_buf *buf, u32 *headskip,
@@ -310,7 +310,7 @@ gss_krb5_aes_make_key(const struct gss_krb5_enctype *gk5e,
 
 u32
 gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
-		     struct xdr_buf *buf, int ec,
+		     struct xdr_buf *buf,
 		     struct page **pages);
 
 u32
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 0f43e894bc0a..f5ed9f6ece06 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -641,7 +641,7 @@ out:
 
 u32
 gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
-		     struct xdr_buf *buf, int ec, struct page **pages)
+		     struct xdr_buf *buf, struct page **pages)
 {
 	u32 err;
 	struct xdr_netobj hmac;
@@ -684,13 +684,8 @@ gss_krb5_aes_encrypt(struct krb5_ctx *kctx, u32 offset,
 		ecptr = buf->tail[0].iov_base;
 	}
 
-	memset(ecptr, 'X', ec);
-	buf->tail[0].iov_len += ec;
-	buf->len += ec;
-
 	/* copy plaintext gss token header after filler (if any) */
-	memcpy(ecptr + ec, buf->head[0].iov_base + offset,
-						GSS_KRB5_TOK_HDR_LEN);
+	memcpy(ecptr, buf->head[0].iov_base + offset, GSS_KRB5_TOK_HDR_LEN);
 	buf->tail[0].iov_len += GSS_KRB5_TOK_HDR_LEN;
 	buf->len += GSS_KRB5_TOK_HDR_LEN;
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 88cd24aacddc..4b614c604fe0 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -483,7 +483,7 @@ gss_wrap_kerberos_v2(struct krb5_ctx *kctx, u32 offset,
 	*be64ptr = cpu_to_be64(kctx->seq_send64++);
 	spin_unlock(&krb5_seq_lock);
 
-	err = (*kctx->gk5e->encrypt_v2)(kctx, offset, buf, 0, pages);
+	err = (*kctx->gk5e->encrypt_v2)(kctx, offset, buf, pages);
 	if (err)
 		return err;
 
-- 
1.9.3

