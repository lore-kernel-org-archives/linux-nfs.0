From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/69] SUNRPC: Remove the last remnant of the BKL...
Date: Tue, 23 Dec 2008 18:02:05 -0500
Message-ID: <20081223230204.13743.98612.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752230AbYLWXXk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:40 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNaFV006177
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:38 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Somehow, this escaped the previous purge. There should be no need to keep
any extra locks in the XDR callbacks.

The NFS client XDR code only writes into private objects, whereas all reads
of shared objects are confined to fields that do not change, such as
filehandles...

Ditto for lockd, the NFSv2/v3 client mount code, and rpcbind.

The nfsd XDR code may require the BKL, but since it does a synchronous RPC
call from a thread that already holds the lock, that issue is moot.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/xdr.h     |   15 ---------------
 net/sunrpc/auth.c              |    4 ++--
 net/sunrpc/auth_gss/auth_gss.c |   10 +++++-----
 3 files changed, 7 insertions(+), 22 deletions(-)


diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index e4057d7..49e1eb4 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -37,21 +37,6 @@ struct xdr_netobj {
 typedef int	(*kxdrproc_t)(void *rqstp, __be32 *data, void *obj);
 
 /*
- * We're still requiring the BKL in the xdr code until it's been
- * more carefully audited, at which point this wrapper will become
- * unnecessary.
- */
-static inline int rpc_call_xdrproc(kxdrproc_t xdrproc, void *rqstp, __be32 *data, void *obj)
-{
-	int ret;
-
-	lock_kernel();
-	ret = xdrproc(rqstp, data, obj);
-	unlock_kernel();
-	return ret;
-}
-
-/*
  * Basic structure for transmission/reception of a client XDR message.
  * Features a header (for a linear buffer containing RPC headers
  * and the data payload for short messages), and then an array of
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index cb216b2..6e28744 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -513,7 +513,7 @@ rpcauth_wrap_req(struct rpc_task *task, kxdrproc_t encode, void *rqstp,
 	if (cred->cr_ops->crwrap_req)
 		return cred->cr_ops->crwrap_req(task, encode, rqstp, data, obj);
 	/* By default, we encode the arguments normally. */
-	return rpc_call_xdrproc(encode, rqstp, data, obj);
+	return encode(rqstp, data, obj);
 }
 
 int
@@ -528,7 +528,7 @@ rpcauth_unwrap_resp(struct rpc_task *task, kxdrproc_t decode, void *rqstp,
 		return cred->cr_ops->crunwrap_resp(task, decode, rqstp,
 						   data, obj);
 	/* By default, we decode the arguments normally. */
-	return rpc_call_xdrproc(decode, rqstp, data, obj);
+	return decode(rqstp, data, obj);
 }
 
 int
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 853a414..b856159 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1017,7 +1017,7 @@ gss_wrap_req_integ(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 	offset = (u8 *)p - (u8 *)snd_buf->head[0].iov_base;
 	*p++ = htonl(rqstp->rq_seqno);
 
-	status = rpc_call_xdrproc(encode, rqstp, p, obj);
+	status = encode(rqstp, p, obj);
 	if (status)
 		return status;
 
@@ -1111,7 +1111,7 @@ gss_wrap_req_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 	offset = (u8 *)p - (u8 *)snd_buf->head[0].iov_base;
 	*p++ = htonl(rqstp->rq_seqno);
 
-	status = rpc_call_xdrproc(encode, rqstp, p, obj);
+	status = encode(rqstp, p, obj);
 	if (status)
 		return status;
 
@@ -1170,12 +1170,12 @@ gss_wrap_req(struct rpc_task *task,
 		/* The spec seems a little ambiguous here, but I think that not
 		 * wrapping context destruction requests makes the most sense.
 		 */
-		status = rpc_call_xdrproc(encode, rqstp, p, obj);
+		status = encode(rqstp, p, obj);
 		goto out;
 	}
 	switch (gss_cred->gc_service) {
 		case RPC_GSS_SVC_NONE:
-			status = rpc_call_xdrproc(encode, rqstp, p, obj);
+			status = encode(rqstp, p, obj);
 			break;
 		case RPC_GSS_SVC_INTEGRITY:
 			status = gss_wrap_req_integ(cred, ctx, encode,
@@ -1291,7 +1291,7 @@ gss_unwrap_resp(struct rpc_task *task,
 	cred->cr_auth->au_rslack = cred->cr_auth->au_verfsize + (p - savedp)
 						+ (savedlen - head->iov_len);
 out_decode:
-	status = rpc_call_xdrproc(decode, rqstp, p, obj);
+	status = decode(rqstp, p, obj);
 out:
 	gss_put_ctx(ctx);
 	dprintk("RPC: %5u gss_unwrap_resp returning %d\n", task->tk_pid,

