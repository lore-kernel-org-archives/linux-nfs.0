Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34324 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755015Ab3BUQi2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2013 11:38:28 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, chuck.lever@oracle.com, simo@redhat.com,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/6] SUNRPC: conditionally return endtime from import_sec_context
Date: Thu, 21 Feb 2013 11:38:23 -0500
Message-Id: <1361464705-12340-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1361464705-12340-1-git-send-email-bfields@redhat.com>
References: <1361464705-12340-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Simo Sorce <simo@redhat.com>

We expose this parameter for a future caller.
It will be used to extract the endtime from the gss-proxy upcall mechanism,
in order to set the rsc cache expiration time.

Signed-off-by: Simo Sorce <simo@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/gss_api.h        |    2 ++
 net/sunrpc/auth_gss/auth_gss.c        |    2 +-
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    7 +++++--
 net/sunrpc/auth_gss/gss_mech_switch.c |    5 +++--
 net/sunrpc/auth_gss/svcauth_gss.c     |    3 ++-
 5 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index a19e254..04d03bb 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -37,6 +37,7 @@ int gss_import_sec_context(
 		size_t			bufsize,
 		struct gss_api_mech	*mech,
 		struct gss_ctx		**ctx_id,
+		time_t			*endtime,
 		gfp_t			gfp_mask);
 u32 gss_get_mic(
 		struct gss_ctx		*ctx_id,
@@ -92,6 +93,7 @@ struct gss_api_ops {
 			const void		*input_token,
 			size_t			bufsize,
 			struct gss_ctx		*ctx_id,
+			time_t			*endtime,
 			gfp_t			gfp_mask);
 	u32 (*gss_get_mic)(
 			struct gss_ctx		*ctx_id,
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 6e5c824..7edfda5 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -238,7 +238,7 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
 		p = ERR_PTR(-EFAULT);
 		goto err;
 	}
-	ret = gss_import_sec_context(p, seclen, gm, &ctx->gc_gss_ctx, GFP_NOFS);
+	ret = gss_import_sec_context(p, seclen, gm, &ctx->gc_gss_ctx, NULL, GFP_NOFS);
 	if (ret < 0) {
 		p = ERR_PTR(ret);
 		goto err;
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index d3611f1..3bc4a23 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -679,6 +679,7 @@ out_err:
 static int
 gss_import_sec_context_kerberos(const void *p, size_t len,
 				struct gss_ctx *ctx_id,
+				time_t *endtime,
 				gfp_t gfp_mask)
 {
 	const void *end = (const void *)((const char *)p + len);
@@ -694,9 +695,11 @@ gss_import_sec_context_kerberos(const void *p, size_t len,
 	else
 		ret = gss_import_v2_context(p, end, ctx, gfp_mask);
 
-	if (ret == 0)
+	if (ret == 0) {
 		ctx_id->internal_ctx_id = ctx;
-	else
+		if (endtime)
+			*endtime = ctx->endtime;
+	} else
 		kfree(ctx);
 
 	dprintk("RPC:       %s: returning %d\n", __func__, ret);
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index b174fcd..cfed709 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -325,14 +325,15 @@ int
 gss_import_sec_context(const void *input_token, size_t bufsize,
 		       struct gss_api_mech	*mech,
 		       struct gss_ctx		**ctx_id,
+		       time_t			*endtime,
 		       gfp_t gfp_mask)
 {
 	if (!(*ctx_id = kzalloc(sizeof(**ctx_id), gfp_mask)))
 		return -ENOMEM;
 	(*ctx_id)->mech_type = gss_mech_get(mech);
 
-	return mech->gm_ops
-		->gss_import_sec_context(input_token, bufsize, *ctx_id, gfp_mask);
+	return mech->gm_ops->gss_import_sec_context(input_token, bufsize,
+						*ctx_id, endtime, gfp_mask);
 }
 
 /* gss_get_mic: compute a mic over message and return mic_token. */
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index eb2b1f7..8fff637 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -485,7 +485,8 @@ static int rsc_parse(struct cache_detail *cd,
 		len = qword_get(&mesg, buf, mlen);
 		if (len < 0)
 			goto out;
-		status = gss_import_sec_context(buf, len, gm, &rsci.mechctx, GFP_KERNEL);
+		status = gss_import_sec_context(buf, len, gm, &rsci.mechctx,
+						NULL, GFP_KERNEL);
 		if (status)
 			goto out;
 
-- 
1.7.9.5

