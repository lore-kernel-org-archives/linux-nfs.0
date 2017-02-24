Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:52563 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751442AbdBXWUH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 17:20:07 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <schumaker.anna@gmail.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 06/17] SUNRPC AUTH_GSS gss3 reply verifier
Date: Fri, 24 Feb 2017 17:19:42 -0500
Message-ID: <20170224221953.5502-7-andros@netapp.com>
In-Reply-To: <20170224221953.5502-1-andros@netapp.com>
References: <20170224221953.5502-1-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The new GSS Version 3 reply  verifier is taken over the same data as
the call verifier, caveat REPLY direction

Verifier Data

   xid          tk_rqstp->rq_xid
   direction    REPLY (always a 1) RPC_REPLY
   rpcvers      RPC_VERSION
   prog         clnt->cl_prog
   vers         clnt->cl_vers
   proc         tk_msg.rpc_proc->p_proc
   credential
         flavor       RPC_AUTH_GSS
         length       cred_len is in gss_marshal (new gv_crlen)
         gss version  ctx->gc_v
         gss proc     ctx->gv_proc
         gss seq      tk_rqstp->rq_seqno
         gss svc      gss_cred->gc_service
         gss ctx len  ctx->gc_wire_ctx
         gss ctx data ctx->gc_wire_ctx

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 59 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 57 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 216a78e..499cf99 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1624,6 +1624,53 @@ gss_refresh_null(struct rpc_task *task)
 	return 0;
 }
 
+/**
+ * gss3_reply_verifier: The new gssv3 verifier uses same data as call
+ * caveat REPLY direction - see rpc_encode_header
+ */
+static  void *
+gss3_reply_verifier(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
+		    struct rpc_task *task, __be32 *seq, struct kvec *iov)
+{
+	struct gss_cred *g_cred = container_of(cred, struct gss_cred, gc_base);
+	void	*gss3_buf = NULL;
+	__be32 *crlen, *ptr = NULL;
+	int len;
+
+	/* freed in gss_validate */
+	len = (13 * 4) + ctx->gc_wire_ctx.len;
+	gss3_buf = kmalloc(len, GFP_NOFS);
+	if (!gss3_buf) {
+		gss3_buf = ERR_PTR(-EIO);
+		goto out;
+	}
+	ptr = (__be32 *)gss3_buf;
+
+	*ptr++ = htonl(task->tk_rqstp->rq_xid);
+	*ptr++ = htonl(RPC_REPLY);
+	*ptr++ = htonl(RPC_VERSION);
+	*ptr++ = htonl(task->tk_client->cl_prog);
+	*ptr++ = htonl(task->tk_client->cl_vers);
+	*ptr++ = htonl(task->tk_msg.rpc_proc->p_proc);
+	*ptr++ = htonl(RPC_AUTH_GSS);
+
+	/* credential */
+	crlen = ptr++;
+	*ptr++ = htonl(ctx->gc_v);
+	*ptr++ = htonl(ctx->gc_proc);
+	*ptr++ = *seq;
+	*ptr++ = htonl(g_cred->gc_service);
+	ptr = xdr_encode_netobj(ptr, &ctx->gc_wire_ctx);
+
+	/* backfill cred length */
+	*crlen = htonl((ptr - (crlen + 1)) << 2);
+
+	iov->iov_base = gss3_buf;
+	iov->iov_len = (ptr - (__be32 *)gss3_buf) << 2;
+out:
+	return gss3_buf;
+}
+
 static __be32 *
 gss_validate(struct rpc_task *task, __be32 *p)
 {
@@ -1633,6 +1680,7 @@ gss_validate(struct rpc_task *task, __be32 *p)
 	struct kvec	iov;
 	struct xdr_buf	verf_buf;
 	struct xdr_netobj mic;
+	void	*g3_buf = NULL;
 	u32		flav,len;
 	u32		maj_stat;
 	__be32		*ret = ERR_PTR(-EIO);
@@ -1648,14 +1696,21 @@ gss_validate(struct rpc_task *task, __be32 *p)
 	if (!seq)
 		goto out_bad;
 	*seq = htonl(task->tk_rqstp->rq_seqno);
-	iov.iov_base = seq;
-	iov.iov_len = 4;
+	if (ctx->gc_v == RPC_GSS_VERSION) {
+		iov.iov_base = seq;
+		iov.iov_len = 4;
+	} else if (ctx->gc_v == RPC_GSS3_VERSION) {
+		g3_buf = gss3_reply_verifier(cred, ctx, task, seq, &iov);
+		if (IS_ERR(g3_buf))
+			goto out_bad;
+	}
 	xdr_buf_from_iov(&iov, &verf_buf);
 	mic.data = (u8 *)p;
 	mic.len = len;
 
 	ret = ERR_PTR(-EACCES);
 	maj_stat = gss_verify_mic(ctx->gc_gss_ctx, &verf_buf, &mic);
+	kfree(g3_buf);
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	if (maj_stat) {
-- 
2.9.3

