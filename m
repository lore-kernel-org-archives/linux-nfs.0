Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:56901 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943AbaGNB6B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Jul 2014 21:58:01 -0400
Received: by mail-qa0-f52.google.com with SMTP id j15so2751333qaq.11
        for <linux-nfs@vger.kernel.org>; Sun, 13 Jul 2014 18:58:00 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH 6/7] sunrpc: clean up sparse endianness warnings in gss_krb5_wrap.c
Date: Sun, 13 Jul 2014 21:57:43 -0400
Message-Id: <1405303064-9102-7-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 net/sunrpc/auth_gss/gss_krb5_wrap.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 42560e55d978..c5cc0270a334 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -201,9 +201,9 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 
 	msg_start = ptr + GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength;
 
-	*(__be16 *)(ptr + 2) = cpu_to_le16(kctx->gk5e->signalg);
+	*(__be16 *)(ptr + 2) = (__force __be16)cpu_to_le16(kctx->gk5e->signalg);
 	memset(ptr + 4, 0xff, 4);
-	*(__be16 *)(ptr + 4) = cpu_to_le16(kctx->gk5e->sealalg);
+	*(__be16 *)(ptr + 4) = (__force __be16)cpu_to_le16(kctx->gk5e->sealalg);
 
 	gss_krb5_make_confounder(msg_start, conflen);
 
@@ -438,7 +438,7 @@ gss_wrap_kerberos_v2(struct krb5_ctx *kctx, u32 offset,
 	u8		*ptr, *plainhdr;
 	s32		now;
 	u8		flags = 0x00;
-	__be16		*be16ptr, ec = 0;
+	__be16		*be16ptr;
 	__be64		*be64ptr;
 	u32		err;
 
@@ -468,7 +468,7 @@ gss_wrap_kerberos_v2(struct krb5_ctx *kctx, u32 offset,
 	be16ptr = (__be16 *)ptr;
 
 	blocksize = crypto_blkcipher_blocksize(kctx->acceptor_enc);
-	*be16ptr++ = cpu_to_be16(ec);
+	*be16ptr++ = cpu_to_be16(0);
 	/* "inner" token header always uses 0 for RRC */
 	*be16ptr++ = cpu_to_be16(0);
 
@@ -477,7 +477,7 @@ gss_wrap_kerberos_v2(struct krb5_ctx *kctx, u32 offset,
 	*be64ptr = cpu_to_be64(kctx->seq_send64++);
 	spin_unlock(&krb5_seq_lock);
 
-	err = (*kctx->gk5e->encrypt_v2)(kctx, offset, buf, ec, pages);
+	err = (*kctx->gk5e->encrypt_v2)(kctx, offset, buf, 0, pages);
 	if (err)
 		return err;
 
-- 
1.9.3

