Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60861 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755200Ab0IFDge (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Sep 2010 23:36:34 -0400
Message-ID: <4C8461BA.5050208@cn.fujitsu.com>
Date: Mon, 06 Sep 2010 11:36:26 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2]gss:krb5 miss returning error to caller when import security
 context
References: <4C846162.40305@cn.fujitsu.com>
In-Reply-To: <4C846162.40305@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

krb5 miss returning error to up layer when import security context, 
it may be return ok though it has failed to import security context.

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>

----

diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 0326446..778e5df 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -237,6 +237,7 @@ get_key(const void *p, const void *end,
 	if (!supported_gss_krb5_enctype(alg)) {
 		printk(KERN_WARNING "gss_kerberos_mech: unsupported "
 			"encryption key algorithm %d\n", alg);
+		p = ERR_PTR(-EINVAL);
 		goto out_err;
 	}
 	p = simple_get_netobj(p, end, &key);
@@ -282,15 +283,19 @@ gss_import_v1_context(const void *p, const void *end, struct krb5_ctx *ctx)
 	ctx->enctype = ENCTYPE_DES_CBC_RAW;
 
 	ctx->gk5e = get_gss_krb5_enctype(ctx->enctype);
-	if (ctx->gk5e == NULL)
+	if (ctx->gk5e == NULL) {
+		p = ERR_PTR(-EINVAL);
 		goto out_err;
+	}
 
 	/* The downcall format was designed before we completely understood
 	 * the uses of the context fields; so it includes some stuff we
 	 * just give some minimal sanity-checking, and some we ignore
 	 * completely (like the next twenty bytes): */
-	if (unlikely(p + 20 > end || p + 20 < p))
+	if (unlikely(p + 20 > end || p + 20 < p)) {
+		p = ERR_PTR(-EFAULT);
 		goto out_err;
+	}
 	p += 20;
 	p = simple_get_bytes(p, end, &tmp, sizeof(tmp));
 	if (IS_ERR(p))
@@ -619,6 +624,7 @@ gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx,
 	if (ctx->seq_send64 != ctx->seq_send) {
 		dprintk("%s: seq_send64 %lx, seq_send %x overflow?\n", __func__,
 			(long unsigned)ctx->seq_send64, ctx->seq_send);
+		p = ERR_PTR(-EINVAL);
 		goto out_err;
 	}
 	p = simple_get_bytes(p, end, &ctx->enctype, sizeof(ctx->enctype));

-- 
Regards
Bian Naimeng

