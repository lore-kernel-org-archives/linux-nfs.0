Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:18075 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751386AbdBXWUN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 17:20:13 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <schumaker.anna@gmail.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 13/17] SUNRPC SVCAUTH_GSS allow RPCSEC_GSS version 1 or 3
Date: Fri, 24 Feb 2017 17:19:49 -0500
Message-ID: <20170224221953.5502-14-andros@netapp.com>
In-Reply-To: <20170224221953.5502-1-andros@netapp.com>
References: <20170224221953.5502-1-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Store the version used in the context INIT phase with the context.
Check the incoming rpcsec gss version against the stored context version.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/gss_api.h    |  1 +
 net/sunrpc/auth_gss/svcauth_gss.c | 20 ++++++++++++++------
 2 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index c2c6354..c0e5058 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -30,6 +30,7 @@ struct gss3_assert {
 /* The mechanism-independent gss-api context: */
 struct gss_ctx {
 	struct gss_api_mech	*mech_type;
+	u32			 gss_version;
 	void			*internal_ctx_id;
 };
 
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index aa7cb3b..f7aa8c4 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -976,8 +976,8 @@ svcauth_gss_set_client(struct svc_rqst *rqstp)
 }
 
 static inline int
-gss_write_init_verf(struct cache_detail *cd, struct svc_rqst *rqstp,
-		struct xdr_netobj *out_handle, int *major_status)
+gss_write_init_verf(struct cache_detail *cd, struct svc_rqst *rqstp, u32 gssv,
+		    struct xdr_netobj *out_handle, int *major_status)
 {
 	struct rsc *rsci;
 	int        rc;
@@ -989,6 +989,8 @@ gss_write_init_verf(struct cache_detail *cd, struct svc_rqst *rqstp,
 		*major_status = GSS_S_NO_CONTEXT;
 		return gss_write_null_verf(rqstp);
 	}
+	/* set the RPCSEC_GSS version in the context */
+	rsci->mechctx->gss_version = gssv;
 	rc = gss_write_verf(rqstp, rsci->mechctx, GSS_SEQ_WIN);
 	cache_put(&rsci->h, cd);
 	return rc;
@@ -1130,7 +1132,7 @@ static int svcauth_gss_legacy_init(struct svc_rqst *rqstp,
 
 	ret = SVC_CLOSE;
 	/* Got an answer to the upcall; use it: */
-	if (gss_write_init_verf(sn->rsc_cache, rqstp,
+	if (gss_write_init_verf(sn->rsc_cache, rqstp, gc->gc_v,
 				&rsip->out_handle, &rsip->major_status))
 		goto out;
 	if (gss_write_resv(resv, PAGE_SIZE,
@@ -1259,7 +1261,7 @@ static int svcauth_gss_proxy_init(struct svc_rqst *rqstp,
 	}
 
 	/* Got an answer to the upcall; use it: */
-	if (gss_write_init_verf(sn->rsc_cache, rqstp,
+	if (gss_write_init_verf(sn->rsc_cache, rqstp, gc->gc_v,
 				&cli_handle, &ud.major_status))
 		goto out;
 	if (gss_write_resv(resv, PAGE_SIZE,
@@ -1435,14 +1437,15 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 	rpcstart -= 7;
 
 	/* credential is:
-	 *   version(==1), proc(0,1,2,3), seq, service (1,2,3), handle
+	 *   version(==1 or 3), proc(0,1,2,3), seq, service (1,2,3), handle
 	 * at least 5 u32s, and is preceded by length, so that makes 6.
 	 */
 
 	if (argv->iov_len < 5 * 4)
 		goto auth_err;
 	crlen = svc_getnl(argv);
-	if (svc_getnl(argv) != RPC_GSS_VERSION)
+	gc->gc_v = svc_getnl(argv);
+	if ((gc->gc_v != RPC_GSS_VERSION) && (gc->gc_v != RPC_GSS3_VERSION))
 		goto auth_err;
 	gc->gc_proc = svc_getnl(argv);
 	gc->gc_seq = svc_getnl(argv);
@@ -1470,6 +1473,11 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 		rsci = gss_svc_searchbyctx(sn->rsc_cache, &gc->gc_ctx);
 		if (!rsci)
 			goto auth_err;
+		if (rsci->mechctx->gss_version != gc->gc_v) {
+			pr_warn("NFSD:  RPCSEC_GSS version mismatch (%u:%u)\n",
+				rsci->mechctx->gss_version, gc->gc_v);
+			goto auth_err;
+		}
 		switch (gss_verify_header(rqstp, rsci, rpcstart, gc, authp)) {
 		case SVC_OK:
 			break;
-- 
2.9.3

