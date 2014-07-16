Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:57735 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758739AbaGPKwf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 06:52:35 -0400
Received: by mail-qg0-f42.google.com with SMTP id j5so586035qga.1
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jul 2014 03:52:35 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/5] sunrpc: clean up sparse endianness warnings in gss_krb5_wrap.c
Date: Wed, 16 Jul 2014 06:52:21 -0400
Message-Id: <1405507942-12256-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405507942-12256-1-git-send-email-jlayton@primarydata.com>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
 <1405507942-12256-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix the endianness handling in gss_wrap_kerberos_v1 and drop the memset
call there in favor of setting the filler bytes directly.

In gss_wrap_kerberos_v2, get rid of the "ec" variable which is always
zero, and drop the endianness conversion of 0. Sparse handles 0 as a
special case, so it's not necessary.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 net/sunrpc/auth_gss/gss_krb5_wrap.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 42560e55d978..88cd24aacddc 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -201,9 +201,15 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
 
 	msg_start = ptr + GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength;
 
-	*(__be16 *)(ptr + 2) = cpu_to_le16(kctx->gk5e->signalg);
-	memset(ptr + 4, 0xff, 4);
-	*(__be16 *)(ptr + 4) = cpu_to_le16(kctx->gk5e->sealalg);
+	/*
+	 * signalg and sealalg are stored as if they were converted from LE
+	 * to host endian, even though they're opaque pairs of bytes according
+	 * to the RFC.
+	 */
+	*(__le16 *)(ptr + 2) = cpu_to_le16(kctx->gk5e->signalg);
+	*(__le16 *)(ptr + 4) = cpu_to_le16(kctx->gk5e->sealalg);
+	ptr[6] = 0xff;
+	ptr[7] = 0xff;
 
 	gss_krb5_make_confounder(msg_start, conflen);
 
@@ -438,7 +444,7 @@ gss_wrap_kerberos_v2(struct krb5_ctx *kctx, u32 offset,
 	u8		*ptr, *plainhdr;
 	s32		now;
 	u8		flags = 0x00;
-	__be16		*be16ptr, ec = 0;
+	__be16		*be16ptr;
 	__be64		*be64ptr;
 	u32		err;
 
@@ -468,16 +474,16 @@ gss_wrap_kerberos_v2(struct krb5_ctx *kctx, u32 offset,
 	be16ptr = (__be16 *)ptr;
 
 	blocksize = crypto_blkcipher_blocksize(kctx->acceptor_enc);
-	*be16ptr++ = cpu_to_be16(ec);
+	*be16ptr++ = 0;
 	/* "inner" token header always uses 0 for RRC */
-	*be16ptr++ = cpu_to_be16(0);
+	*be16ptr++ = 0;
 
 	be64ptr = (__be64 *)be16ptr;
 	spin_lock(&krb5_seq_lock);
 	*be64ptr = cpu_to_be64(kctx->seq_send64++);
 	spin_unlock(&krb5_seq_lock);
 
-	err = (*kctx->gk5e->encrypt_v2)(kctx, offset, buf, ec, pages);
+	err = (*kctx->gk5e->encrypt_v2)(kctx, offset, buf, 0, pages);
 	if (err)
 		return err;
 
-- 
1.9.3

