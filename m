Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:52420 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758739AbaGPKwe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 06:52:34 -0400
Received: by mail-qa0-f53.google.com with SMTP id v10so530402qac.26
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jul 2014 03:52:33 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/5] sunrpc: clean up sparse endianness warnings in gss_krb5_seal.c
Date: Wed, 16 Jul 2014 06:52:20 -0400
Message-Id: <1405507942-12256-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405507942-12256-1-git-send-email-jlayton@primarydata.com>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
 <1405507942-12256-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use u16 pointer in setup_token and setup_token_v2. None of the fields
are actually handled as __be16, so this simplifies the code a bit. Also
get rid of some unneeded pointer increments.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 net/sunrpc/auth_gss/gss_krb5_seal.c | 28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index 62ae3273186c..42768e5c3994 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -70,31 +70,37 @@
 
 DEFINE_SPINLOCK(krb5_seq_lock);
 
-static char *
+static void *
 setup_token(struct krb5_ctx *ctx, struct xdr_netobj *token)
 {
-	__be16 *ptr, *krb5_hdr;
+	u16 *ptr;
+	void *krb5_hdr;
 	int body_size = GSS_KRB5_TOK_HDR_LEN + ctx->gk5e->cksumlength;
 
 	token->len = g_token_size(&ctx->mech_used, body_size);
 
-	ptr = (__be16 *)token->data;
+	ptr = (u16 *)token->data;
 	g_make_token_header(&ctx->mech_used, body_size, (unsigned char **)&ptr);
 
 	/* ptr now at start of header described in rfc 1964, section 1.2.1: */
 	krb5_hdr = ptr;
 	*ptr++ = KG_TOK_MIC_MSG;
-	*ptr++ = cpu_to_le16(ctx->gk5e->signalg);
+	/*
+	 * signalg is stored as if it were converted from LE to host endian, even
+	 * though it's an opaque pair of bytes according to the RFC.
+	 */
+	*ptr++ = (__force u16)cpu_to_le16(ctx->gk5e->signalg);
 	*ptr++ = SEAL_ALG_NONE;
-	*ptr++ = 0xffff;
+	*ptr = 0xffff;
 
-	return (char *)krb5_hdr;
+	return krb5_hdr;
 }
 
 static void *
 setup_token_v2(struct krb5_ctx *ctx, struct xdr_netobj *token)
 {
-	__be16 *ptr, *krb5_hdr;
+	u16 *ptr;
+	void *krb5_hdr;
 	u8 *p, flags = 0x00;
 
 	if ((ctx->flags & KRB5_CTX_FLAG_INITIATOR) == 0)
@@ -104,15 +110,15 @@ setup_token_v2(struct krb5_ctx *ctx, struct xdr_netobj *token)
 
 	/* Per rfc 4121, sec 4.2.6.1, there is no header,
 	 * just start the token */
-	krb5_hdr = ptr = (__be16 *)token->data;
+	krb5_hdr = ptr = (u16 *)token->data;
 
 	*ptr++ = KG2_TOK_MIC;
 	p = (u8 *)ptr;
 	*p++ = flags;
 	*p++ = 0xff;
-	ptr = (__be16 *)p;
-	*ptr++ = 0xffff;
+	ptr = (u16 *)p;
 	*ptr++ = 0xffff;
+	*ptr = 0xffff;
 
 	token->len = GSS_KRB5_TOK_HDR_LEN + ctx->gk5e->cksumlength;
 	return krb5_hdr;
@@ -181,7 +187,7 @@ gss_get_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *text,
 	spin_lock(&krb5_seq_lock);
 	seq_send = ctx->seq_send64++;
 	spin_unlock(&krb5_seq_lock);
-	*((u64 *)(krb5_hdr + 8)) = cpu_to_be64(seq_send);
+	*((__be64 *)(krb5_hdr + 8)) = cpu_to_be64(seq_send);
 
 	if (ctx->initiate) {
 		cksumkey = ctx->initiator_sign;
-- 
1.9.3

