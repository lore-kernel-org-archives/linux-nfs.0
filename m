Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:33562 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943AbaGNB57 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Jul 2014 21:57:59 -0400
Received: by mail-qg0-f50.google.com with SMTP id j5so2895633qga.9
        for <linux-nfs@vger.kernel.org>; Sun, 13 Jul 2014 18:57:59 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH 5/7] sunrpc: clean up sparse endianness warnings in gss_krb5_seal.c
Date: Sun, 13 Jul 2014 21:57:42 -0400
Message-Id: <1405303064-9102-6-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

KG2_TOK_MIC is a "palindrome" so byte swapping is a no-op here.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 net/sunrpc/auth_gss/gss_krb5_seal.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index 94ad57ff7169..3cf49ea54ca9 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -106,13 +106,13 @@ setup_token_v2(struct krb5_ctx *ctx, struct xdr_netobj *token)
 	 * just start the token */
 	krb5_hdr = ptr = (__be16 *)token->data;
 
-	*ptr++ = KG2_TOK_MIC;
+	*ptr++ = cpu_to_be16(KG2_TOK_MIC);
 	p = (u8 *)ptr;
 	*p++ = flags;
 	*p++ = 0xff;
 	ptr = (__be16 *)p;
-	*ptr++ = 0xffff;
-	*ptr++ = 0xffff;
+	*ptr++ = cpu_to_be16(0xffff);
+	*ptr++ = cpu_to_be16(0xffff);
 
 	token->len = GSS_KRB5_TOK_HDR_LEN + ctx->gk5e->cksumlength;
 	return krb5_hdr;
@@ -181,7 +181,7 @@ gss_get_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *text,
 	spin_lock(&krb5_seq_lock);
 	seq_send = ctx->seq_send64++;
 	spin_unlock(&krb5_seq_lock);
-	*((u64 *)(krb5_hdr + 8)) = cpu_to_be64(seq_send);
+	*((__be64 *)(krb5_hdr + 8)) = cpu_to_be64(seq_send);
 
 	if (ctx->initiate) {
 		cksumkey = ctx->initiator_sign;
-- 
1.9.3

