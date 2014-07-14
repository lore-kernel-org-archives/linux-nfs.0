Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:42901 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943AbaGNB55 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Jul 2014 21:57:57 -0400
Received: by mail-qa0-f42.google.com with SMTP id j15so2784427qaq.29
        for <linux-nfs@vger.kernel.org>; Sun, 13 Jul 2014 18:57:56 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH 3/7] sunrpc: clean up endianness warnings in setup_token
Date: Sun, 13 Jul 2014 21:57:40 -0400
Message-Id: <1405303064-9102-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is safe since KG_TOK_MIC_MSG and SEAL_ALG_NONE are both endian
palindromes. I'm also making the assumption that the signalg field
really should be in little-endian. That looks odd, but looking at the
spec I guess it's correct.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 net/sunrpc/auth_gss/gss_krb5_seal.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index 62ae3273186c..94ad57ff7169 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -83,10 +83,10 @@ setup_token(struct krb5_ctx *ctx, struct xdr_netobj *token)
 
 	/* ptr now at start of header described in rfc 1964, section 1.2.1: */
 	krb5_hdr = ptr;
-	*ptr++ = KG_TOK_MIC_MSG;
-	*ptr++ = cpu_to_le16(ctx->gk5e->signalg);
-	*ptr++ = SEAL_ALG_NONE;
-	*ptr++ = 0xffff;
+	*ptr++ = cpu_to_be16(KG_TOK_MIC_MSG);
+	*ptr++ = (__force __be16)cpu_to_le16(ctx->gk5e->signalg);
+	*ptr++ = cpu_to_be16(SEAL_ALG_NONE);
+	*ptr++ = cpu_to_be16(0xffff);
 
 	return (char *)krb5_hdr;
 }
-- 
1.9.3

