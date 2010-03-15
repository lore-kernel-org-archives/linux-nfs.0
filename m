From: steved@redhat.com
Subject: [PATCH 22/22] Fixed memory leak in gss_import_v1_context()
Date: Mon, 15 Mar 2010 08:20:27 -0400
Message-ID: <1268655627-18712-23-git-send-email-steved@redhat.com>
References: <1268655627-18712-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:41152 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964916Ab0CON00 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Mar 2010 09:26:26 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Nr9Hf-00009j-6a
	for linux-nfs@vger.kernel.org; Mon, 15 Mar 2010 08:20:35 -0400
In-Reply-To: <1268655627-18712-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peter Staubach <staubach@redhat.com>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 net/sunrpc/auth_gss/gss_krb5_mech.c   |   29 +++++++++++------------------
 net/sunrpc/auth_gss/gss_krb5_unseal.c |    2 +-
 2 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 35e3a01..5cc084b 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -271,18 +271,11 @@ out_err:
 static int
 gss_import_v1_context(const void *p, const void *end, struct krb5_ctx *ctx)
 {
-	const void *end = (const void *)((const char *)p + len);
-	struct	krb5_ctx *ctx;
 	int tmp;
 
-	if (!(ctx = kzalloc(sizeof(*ctx), GFP_NOFS))) {
-		p = ERR_PTR(-ENOMEM);
-		goto out_err;
-	}
-
 	p = simple_get_bytes(p, end, &ctx->initiate, sizeof(ctx->initiate));
 	if (IS_ERR(p))
-		goto out_err_free_ctx;
+		goto out_err;
 
 	/* Old format supports only DES!  Any other enctype uses new format */
 	ctx->enctype = ENCTYPE_DES_CBC_RAW;
@@ -296,35 +289,35 @@ gss_import_v1_context(const void *p, const void *end, struct krb5_ctx *ctx)
 	 * just give some minimal sanity-checking, and some we ignore
 	 * completely (like the next twenty bytes): */
 	if (unlikely(p + 20 > end || p + 20 < p))
-		goto out_err_free_ctx;
+		goto out_err;
 	p += 20;
 	p = simple_get_bytes(p, end, &tmp, sizeof(tmp));
 	if (IS_ERR(p))
-		goto out_err_free_ctx;
+		goto out_err;
 	if (tmp != SGN_ALG_DES_MAC_MD5) {
 		p = ERR_PTR(-ENOSYS);
-		goto out_err_free_ctx;
+		goto out_err;
 	}
 	p = simple_get_bytes(p, end, &tmp, sizeof(tmp));
 	if (IS_ERR(p))
-		goto out_err_free_ctx;
+		goto out_err;
 	if (tmp != SEAL_ALG_DES) {
 		p = ERR_PTR(-ENOSYS);
-		goto out_err_free_ctx;
+		goto out_err;
 	}
 	p = simple_get_bytes(p, end, &ctx->endtime, sizeof(ctx->endtime));
 	if (IS_ERR(p))
-		goto out_err_free_ctx;
+		goto out_err;
 	p = simple_get_bytes(p, end, &ctx->seq_send, sizeof(ctx->seq_send));
 	if (IS_ERR(p))
-		goto out_err_free_ctx;
+		goto out_err;
 	p = simple_get_netobj(p, end, &ctx->mech_used);
 	if (IS_ERR(p))
-		goto out_err_free_ctx;
-	p = get_key(p, end, &ctx->enc);
+		goto out_err;
+	p = get_key(p, end, ctx, &ctx->enc);
 	if (IS_ERR(p))
 		goto out_err_free_mech;
-	p = get_key(p, end, &ctx->seq);
+	p = get_key(p, end, ctx, &ctx->seq);
 	if (IS_ERR(p))
 		goto out_err_free_key1;
 	if (p != end) {
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index 0307911..eaa796e 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -200,7 +200,7 @@ gss_verify_mic_v2(struct krb5_ctx *ctx,
 
 	/* do sequencing checks */
 
-	seqnum = be64_to_cpu((__be64 *)ptr + 8);
+	seqnum = be64_to_cpup((__be64 *)(ptr + 8));
 
 	return GSS_S_COMPLETE;
 }
-- 
1.6.6.1

