Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:18075 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751425AbdBXWUc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 17:20:32 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <schumaker.anna@gmail.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 14/17] SUNRPC SVCAUTH_GSS gss3 reply verifier
Date: Fri, 24 Feb 2017 17:19:50 -0500
Message-ID: <20170224221953.5502-15-andros@netapp.com>
In-Reply-To: <20170224221953.5502-1-andros@netapp.com>
References: <20170224221953.5502-1-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The new GSS Version 3 reply  verifier is taken over the same data as
the call verifier, caveat REPLY direction

verifier data

 rpc_header (6 u32s)
   XID (put32) rqstp->rq_xid
   type REPLY (putnl) always a 1.
   rpcvers u32
   prog (getnl) rqstp->rq_prog
   vers (getnl) rqstp->rq_vers
   proc (getnl) rqstp->rq_proc

 credential (7 u32s plus data)
     flavor (getnl) (new rq_flav)
     length (getnl) (new gc_crlen)
     gss version  gc_v u32 (svcauth_gss_accept)
     gss proceedure u32 gc_proc
     gss seq num    u32 gc_seq
     gss service    u32 gc_svc
     gss context length u32 gc_ctx->len

      gss context gc_ctx->data

size is 13 + gc_ctx->len.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/auth_gss.h   |  1 +
 net/sunrpc/auth_gss/svcauth_gss.c | 77 ++++++++++++++++++++++++++++++++-------
 2 files changed, 65 insertions(+), 13 deletions(-)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index 7f7b378..59469fc 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -41,6 +41,7 @@ enum rpc_gss_svc {
 
 /* on-the-wire gss cred: */
 struct rpc_gss_wire_cred {
+	u32			gc_crlen;
 	u32			gc_v;		/* version */
 	u32			gc_proc;	/* control procedure */
 	u32			gc_seq;		/* sequence number */
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index f7aa8c4..3a42133 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -715,8 +715,50 @@ gss_write_null_verf(struct svc_rqst *rqstp)
 	return 0;
 }
 
+/**
+ * The new GSS Version 3 reply  verifier is taken over the same data as
+ * the call verifier, caveat REPLY direction
+ */
+static void *
+gss3_svc_reply_verifier(struct svc_rqst *rqstp, struct rpc_gss_wire_cred *gc,
+			struct kvec *iov, u32 seq)
+{
+	void	*gss3_buf = NULL;
+	__be32	*ptr = NULL;
+	int	len;
+
+	/* freed in gss_write_verf */
+	len = (13 * 4) + gc->gc_ctx.len;
+	gss3_buf = kmalloc(len, GFP_KERNEL);
+	if (!gss3_buf)
+		return NULL;
+
+	iov->iov_len = 0;
+	iov->iov_base = gss3_buf;
+	/* 12  __be32's plus iov_len = 13 */
+	svc_putnl(iov, rqstp->rq_xid);
+	svc_putnl(iov, RPC_REPLY);
+	svc_putnl(iov, 2);
+	svc_putnl(iov, rqstp->rq_prog);
+	svc_putnl(iov, rqstp->rq_vers);
+	svc_putnl(iov, rqstp->rq_proc);
+	svc_putnl(iov, RPC_AUTH_GSS);
+	svc_putnl(iov, gc->gc_crlen);
+	svc_putnl(iov, gc->gc_v);
+	svc_putnl(iov, gc->gc_proc);
+	svc_putnl(iov, seq);
+	svc_putnl(iov, gc->gc_svc);
+	ptr = iov->iov_base + iov->iov_len;
+
+	ptr = xdr_encode_netobj(ptr, &gc->gc_ctx);
+	iov->iov_len += sizeof(__be32); /* for ctx length */
+	iov->iov_len += gc->gc_ctx.len;
+	return gss3_buf;
+}
+
 static int
-gss_write_verf(struct svc_rqst *rqstp, struct gss_ctx *ctx_id, u32 seq)
+gss_write_verf(struct svc_rqst *rqstp, struct gss_ctx *ctx_id,
+	       struct rpc_gss_wire_cred *gc, u32 seq)
 {
 	__be32			*xdr_seq;
 	u32			maj_stat;
@@ -724,6 +766,7 @@ gss_write_verf(struct svc_rqst *rqstp, struct gss_ctx *ctx_id, u32 seq)
 	struct xdr_netobj	mic;
 	__be32			*p;
 	struct kvec		iov;
+	void			*g3_buf = NULL;
 	int err = -1;
 
 	svc_putnl(rqstp->rq_res.head, RPC_AUTH_GSS);
@@ -732,12 +775,20 @@ gss_write_verf(struct svc_rqst *rqstp, struct gss_ctx *ctx_id, u32 seq)
 		return -1;
 	*xdr_seq = htonl(seq);
 
-	iov.iov_base = xdr_seq;
-	iov.iov_len = 4;
+	if (gc->gc_v == 1) {
+		iov.iov_base = &xdr_seq;
+		iov.iov_len = 4;
+	}
+	if (gc->gc_v == 3) {
+		g3_buf = gss3_svc_reply_verifier(rqstp, gc, &iov, seq);
+		if (!g3_buf)
+			return -1;
+	}
 	xdr_buf_from_iov(&iov, &verf_data);
 	p = rqstp->rq_res.head->iov_base + rqstp->rq_res.head->iov_len;
 	mic.data = (u8 *)(p + 1);
 	maj_stat = gss_get_mic(ctx_id, &verf_data, &mic);
+	kfree(g3_buf);
 	if (maj_stat != GSS_S_COMPLETE)
 		goto out;
 	*p++ = htonl(mic.len);
@@ -976,7 +1027,8 @@ svcauth_gss_set_client(struct svc_rqst *rqstp)
 }
 
 static inline int
-gss_write_init_verf(struct cache_detail *cd, struct svc_rqst *rqstp, u32 gssv,
+gss_write_init_verf(struct cache_detail *cd, struct svc_rqst *rqstp,
+		    struct rpc_gss_wire_cred *gc,
 		    struct xdr_netobj *out_handle, int *major_status)
 {
 	struct rsc *rsci;
@@ -990,8 +1042,8 @@ gss_write_init_verf(struct cache_detail *cd, struct svc_rqst *rqstp, u32 gssv,
 		return gss_write_null_verf(rqstp);
 	}
 	/* set the RPCSEC_GSS version in the context */
-	rsci->mechctx->gss_version = gssv;
-	rc = gss_write_verf(rqstp, rsci->mechctx, GSS_SEQ_WIN);
+	rsci->mechctx->gss_version = gc->gc_v;
+	rc = gss_write_verf(rqstp, rsci->mechctx, gc, GSS_SEQ_WIN);
 	cache_put(&rsci->h, cd);
 	return rc;
 }
@@ -1132,7 +1184,7 @@ static int svcauth_gss_legacy_init(struct svc_rqst *rqstp,
 
 	ret = SVC_CLOSE;
 	/* Got an answer to the upcall; use it: */
-	if (gss_write_init_verf(sn->rsc_cache, rqstp, gc->gc_v,
+	if (gss_write_init_verf(sn->rsc_cache, rqstp, gc,
 				&rsip->out_handle, &rsip->major_status))
 		goto out;
 	if (gss_write_resv(resv, PAGE_SIZE,
@@ -1261,7 +1313,7 @@ static int svcauth_gss_proxy_init(struct svc_rqst *rqstp,
 	}
 
 	/* Got an answer to the upcall; use it: */
-	if (gss_write_init_verf(sn->rsc_cache, rqstp, gc->gc_v,
+	if (gss_write_init_verf(sn->rsc_cache, rqstp, gc,
 				&cli_handle, &ud.major_status))
 		goto out;
 	if (gss_write_resv(resv, PAGE_SIZE,
@@ -1408,7 +1460,6 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 {
 	struct kvec	*argv = &rqstp->rq_arg.head[0];
 	struct kvec	*resv = &rqstp->rq_res.head[0];
-	u32		crlen;
 	struct gss_svc_data *svcdata = rqstp->rq_auth_data;
 	struct rpc_gss_wire_cred *gc;
 	struct rsc	*rsci = NULL;
@@ -1443,7 +1494,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 
 	if (argv->iov_len < 5 * 4)
 		goto auth_err;
-	crlen = svc_getnl(argv);
+	gc->gc_crlen = svc_getnl(argv);
 	gc->gc_v = svc_getnl(argv);
 	if ((gc->gc_v != RPC_GSS_VERSION) && (gc->gc_v != RPC_GSS3_VERSION))
 		goto auth_err;
@@ -1452,7 +1503,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 	gc->gc_svc = svc_getnl(argv);
 	if (svc_safe_getnetobj(argv, &gc->gc_ctx))
 		goto auth_err;
-	if (crlen != round_up_to_quad(gc->gc_ctx.len) + 5 * 4)
+	if (gc->gc_crlen != round_up_to_quad(gc->gc_ctx.len) + 5 * 4)
 		goto auth_err;
 
 	if ((gc->gc_proc != RPC_GSS_PROC_DATA) && (rqstp->rq_proc != 0))
@@ -1495,7 +1546,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 	/* now act upon the command: */
 	switch (gc->gc_proc) {
 	case RPC_GSS_PROC_DESTROY:
-		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
+		if (gss_write_verf(rqstp, rsci->mechctx, gc, gc->gc_seq))
 			goto auth_err;
 		/* Delete the entry from the cache_list and call cache_put */
 		sunrpc_cache_unhash(sn->rsc_cache, &rsci->h);
@@ -1506,7 +1557,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 	case RPC_GSS_PROC_DATA:
 		*authp = rpcsec_gsserr_ctxproblem;
 		svcdata->verf_start = resv->iov_base + resv->iov_len;
-		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
+		if (gss_write_verf(rqstp, rsci->mechctx, gc, gc->gc_seq))
 			goto auth_err;
 		rqstp->rq_cred = rsci->cred;
 		get_group_info(rsci->cred.cr_group_info);
-- 
2.9.3

