Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:27494 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753280Ab2K0Pel (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 10:34:41 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 5/5] SUNRPC refactor rpcauth_checkverf error returns
Date: Tue, 27 Nov 2012 10:34:23 -0500
Message-Id: <1354030463-2372-6-git-send-email-andros@netapp.com>
In-Reply-To: <1354030463-2372-1-git-send-email-andros@netapp.com>
References: <1354030463-2372-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Most of the time an error from the credops crvalidate function means the
server has sent us a garbage verifier. The gss_validate function is the
exception where there is an -EACCES case if the user GSS_context on the client
has expired.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c |    7 +++++--
 net/sunrpc/auth_null.c         |    5 +++--
 net/sunrpc/auth_unix.c         |    5 +++--
 net/sunrpc/clnt.c              |   17 ++++++++++-------
 4 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index e24948f..df92ae3 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1300,6 +1300,7 @@ gss_validate(struct rpc_task *task, __be32 *p)
 	struct xdr_netobj mic;
 	u32		flav,len;
 	u32		maj_stat;
+	__be32		*ret = ERR_PTR(-EIO);
 
 	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
 
@@ -1315,6 +1316,7 @@ gss_validate(struct rpc_task *task, __be32 *p)
 	mic.data = (u8 *)p;
 	mic.len = len;
 
+	ret = ERR_PTR(-EACCES);
 	maj_stat = gss_verify_mic(ctx->gc_gss_ctx, &verf_buf, &mic);
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
@@ -1332,8 +1334,9 @@ gss_validate(struct rpc_task *task, __be32 *p)
 	return p + XDR_QUADLEN(len);
 out_bad:
 	gss_put_ctx(ctx);
-	dprintk("RPC: %5u %s failed.\n", task->tk_pid, __func__);
-	return NULL;
+	dprintk("RPC: %5u %s failed ret %ld.\n", task->tk_pid, __func__,
+		PTR_ERR(ret));
+	return ret;
 }
 
 static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index a5c36c0..d60a673 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -84,17 +84,18 @@ nul_validate(struct rpc_task *task, __be32 *p)
 {
 	rpc_authflavor_t	flavor;
 	u32			size;
+	__be32			*ret = ERR_PTR(-EIO);
 
 	flavor = ntohl(*p++);
 	if (flavor != RPC_AUTH_NULL) {
 		printk("RPC: bad verf flavor: %u\n", flavor);
-		return NULL;
+		return ret;
 	}
 
 	size = ntohl(*p++);
 	if (size != 0) {
 		printk("RPC: bad verf size: %u\n", size);
-		return NULL;
+		return ret;
 	}
 
 	return p;
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 52c5abd..c9dad95 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -192,19 +192,20 @@ unx_validate(struct rpc_task *task, __be32 *p)
 {
 	rpc_authflavor_t	flavor;
 	u32			size;
+	__be32			*ret = ERR_PTR(-EIO);
 
 	flavor = ntohl(*p++);
 	if (flavor != RPC_AUTH_NULL &&
 	    flavor != RPC_AUTH_UNIX &&
 	    flavor != RPC_AUTH_SHORT) {
 		printk("RPC: bad verf flavor: %u\n", flavor);
-		return NULL;
+		return ret;
 	}
 
 	size = ntohl(*p++);
 	if (size > RPC_MAX_AUTH_SIZE) {
 		printk("RPC: giant verf size: %u\n", size);
-		return NULL;
+		return ret;
 	}
 	task->tk_rqstp->rq_cred->cr_auth->au_rslack = (size >> 2) + 2;
 	p += (size >> 2);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 55e174f..c005415 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2041,7 +2041,8 @@ rpc_verify_header(struct rpc_task *task)
 		dprintk("RPC: %5u %s: XDR representation not a multiple of"
 		       " 4 bytes: 0x%x\n", task->tk_pid, __func__,
 		       task->tk_rqstp->rq_rcv_buf.len);
-		goto out_eio;
+		error = -EIO;
+		goto out_err;
 	}
 	if ((len -= 3) < 0)
 		goto out_overflow;
@@ -2050,6 +2051,7 @@ rpc_verify_header(struct rpc_task *task)
 	if ((n = ntohl(*p++)) != RPC_REPLY) {
 		dprintk("RPC: %5u %s: not an RPC reply: %x\n",
 			task->tk_pid, __func__, n);
+		error = -EIO;
 		goto out_garbage;
 	}
 
@@ -2068,7 +2070,8 @@ rpc_verify_header(struct rpc_task *task)
 			dprintk("RPC: %5u %s: RPC call rejected, "
 				"unknown error: %x\n",
 				task->tk_pid, __func__, n);
-			goto out_eio;
+			error = -EIO;
+			goto out_err;
 		}
 		if (--len < 0)
 			goto out_overflow;
@@ -2113,9 +2116,11 @@ rpc_verify_header(struct rpc_task *task)
 				task->tk_pid, __func__, n);
 		goto out_err;
 	}
-	if (!(p = rpcauth_checkverf(task, p))) {
-		dprintk("RPC: %5u %s: auth check failed\n",
-				task->tk_pid, __func__);
+	p = rpcauth_checkverf(task, p);
+	if (IS_ERR(p)) {
+		error = PTR_ERR(p);
+		dprintk("RPC: %5u %s: auth check failed with %d\n",
+				task->tk_pid, __func__, error);
 		goto out_garbage;		/* bad verifier, retry */
 	}
 	len = p - (__be32 *)iov->iov_base - 1;
@@ -2168,8 +2173,6 @@ out_garbage:
 out_retry:
 		return ERR_PTR(-EAGAIN);
 	}
-out_eio:
-	error = -EIO;
 out_err:
 	rpc_exit(task, error);
 	dprintk("RPC: %5u %s: call failed with error %d\n", task->tk_pid,
-- 
1.7.7.6

