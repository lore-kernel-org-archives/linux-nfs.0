From: steved@redhat.com
Subject: [PATCH 04/22] gss_krb5: prepare for new context format
Date: Mon, 15 Mar 2010 08:20:09 -0400
Message-ID: <1268655627-18712-5-git-send-email-steved@redhat.com>
References: <1268655627-18712-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:41151 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964916Ab0CON0Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Mar 2010 09:26:24 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Nr9HZ-00009j-1V
	for linux-nfs@vger.kernel.org; Mon, 15 Mar 2010 08:20:29 -0400
In-Reply-To: <1268655627-18712-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

Prepare for new context format by splitting out the old "v1"
context processing function

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 net/sunrpc/auth_gss/gss_krb5_mech.c |   39 +++++++++++++++++++++++++++-------
 1 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 0cd940e..cb01795 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -123,9 +123,7 @@ out_err:
 }
 
 static int
-gss_import_sec_context_kerberos(const void *p,
-				size_t len,
-				struct gss_ctx *ctx_id)
+gss_import_v1_context(const void *p, const void *end, struct krb5_ctx *ctx)
 {
 	const void *end = (const void *)((const char *)p + len);
 	struct	krb5_ctx *ctx;
@@ -139,7 +137,10 @@ gss_import_sec_context_kerberos(const void *p,
 	p = simple_get_bytes(p, end, &ctx->initiate, sizeof(ctx->initiate));
 	if (IS_ERR(p))
 		goto out_err_free_ctx;
+
+	/* Old format supports only DES!  Any other enctype uses new format */
 	ctx->enctype = ENCTYPE_DES_CBC_RAW;
+
 	/* The downcall format was designed before we completely understood
 	 * the uses of the context fields; so it includes some stuff we
 	 * just give some minimal sanity-checking, and some we ignore
@@ -181,9 +182,6 @@ gss_import_sec_context_kerberos(const void *p,
 		goto out_err_free_key2;
 	}
 
-	ctx_id->internal_ctx_id = ctx;
-
-	dprintk("RPC:       Successfully imported new context.\n");
 	return 0;
 
 out_err_free_key2:
@@ -192,12 +190,37 @@ out_err_free_key1:
 	crypto_free_blkcipher(ctx->enc);
 out_err_free_mech:
 	kfree(ctx->mech_used.data);
-out_err_free_ctx:
-	kfree(ctx);
 out_err:
 	return PTR_ERR(p);
 }
 
+static int
+gss_import_sec_context_kerberos(const void *p, size_t len,
+				struct gss_ctx *ctx_id)
+{
+	const void *end = (const void *)((const char *)p + len);
+	struct  krb5_ctx *ctx;
+	int ret;
+
+	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
+	if (ctx == NULL)
+		return -ENOMEM;
+	memset(ctx, 0, sizeof(*ctx));
+
+	if (len == 85)
+		ret = gss_import_v1_context(p, end, ctx);
+	else
+		ret = -EINVAL;
+
+	if (ret == 0)
+		ctx_id->internal_ctx_id = ctx;
+	else
+		kfree(ctx);
+
+	dprintk("RPC:       %s: returning %d\n", __func__, ret);
+	return ret;
+}
+
 static void
 gss_delete_sec_context_kerberos(void *internal_ctx) {
 	struct krb5_ctx *kctx = internal_ctx;
-- 
1.6.6.1

