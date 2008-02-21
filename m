From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 10/19] gss_krb5: prepare for new context format
Date: Thu, 21 Feb 2008 13:44:37 -0500
Message-ID: <20080221184437.19195.77971.stgit@jazz.citi.umich.edu>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:27362 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754232AbYBUSoi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 13:44:38 -0500
Received: from jazz.citi.umich.edu (jazz.citi.umich.edu [141.211.133.62])
	by citi.umich.edu (Postfix) with ESMTP id A7B4B460B
	for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 13:44:37 -0500 (EST)
In-Reply-To: <20080221184208.19195.94518.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prepare for new context format by splitting out the old "v1"
context processing function.

From: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 net/sunrpc/auth_gss/gss_krb5_mech.c |   62 +++++++++++++++++++++++------------
 1 files changed, 40 insertions(+), 22 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 477cf07..f0f0749 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -123,51 +123,47 @@ out_err:
 }
 
 static int
-gss_import_sec_context_kerberos(const void *p,
-				size_t len,
-				struct gss_ctx *ctx_id)
+gss_import_v1_context(const void *p, const void *end, struct krb5_ctx *ctx)
 {
-	const void *end = (const void *)((const char *)p + len);
-	struct	krb5_ctx *ctx;
 	int tmp;
 
-	if (!(ctx = kzalloc(sizeof(*ctx), GFP_KERNEL)))
-		goto out_err;
-
 	p = simple_get_bytes(p, end, &ctx->initiate, sizeof(ctx->initiate));
 	if (IS_ERR(p))
-		goto out_err_free_ctx;
+		goto out_err;
+
+	/* Old format supports only DES!  Any other enctype uses new format */
 	ctx->enctype = ENCTYPE_DES_CBC_RAW;
+
 	/* The downcall format was designed before we completely understood
 	 * the uses of the context fields; so it includes some stuff we
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
+		goto out_err;
 	p = get_key(p, end, &ctx->enc);
 	if (IS_ERR(p))
 		goto out_err_free_mech;
@@ -179,9 +175,6 @@ gss_import_sec_context_kerberos(const void *p,
 		goto out_err_free_key2;
 	}
 
-	ctx_id->internal_ctx_id = ctx;
-
-	dprintk("RPC:       Successfully imported new context.\n");
 	return 0;
 
 out_err_free_key2:
@@ -190,12 +183,37 @@ out_err_free_key1:
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

