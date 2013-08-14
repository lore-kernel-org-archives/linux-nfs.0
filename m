Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:65511 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751019Ab3HNP70 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Aug 2013 11:59:26 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 5/5] SUNRPC refactor rpcauth_checkverf error returns
Date: Wed, 14 Aug 2013 11:59:17 -0400
Message-ID: <1376495957-7482-6-git-send-email-andros@netapp.com>
In-Reply-To: <1376495957-7482-1-git-send-email-andros@netapp.com>
References: <1376495957-7482-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Most of the time an error from the credops crvalidate function means the
server has sent us a garbage verifier. The gss_validate function is the
exception where there is an -EACCES case if the user GSS_context on the client
has expired.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c |  7 +++++--
 net/sunrpc/auth_null.c         |  4 ++--
 net/sunrpc/auth_unix.c         |  4 ++--
 net/sunrpc/clnt.c              | 17 ++++++++++-------
 4 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 8b5526c..f25dfd8 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1335,6 +1335,7 @@ gss_validate(struct rpc_task *task, __be32 *p)
 	struct xdr_netobj mic;
 	u32		flav,len;
 	u32		maj_stat;
+	__be32		*ret = ERR_PTR(-EIO);
 
 	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
 
@@ -1350,6 +1351,7 @@ gss_validate(struct rpc_task *task, __be32 *p)
 	mic.data = (u8 *)p;
 	mic.len = len;
 
+	ret = ERR_PTR(-EACCES);
 	maj_stat = gss_verify_mic(ctx->gc_gss_ctx, &verf_buf, &mic);
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
@@ -1367,8 +1369,9 @@ gss_validate(struct rpc_task *task, __be32 *p)
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
index a5c36c0..1e7d4a1 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -88,13 +88,13 @@ nul_validate(struct rpc_task *task, __be32 *p)
 	flavor = ntohl(*p++);
 	if (flavor != RPC_AUTH_NULL) {
 		printk("RPC: bad verf flavor: %u\n", flavor);
-		return NULL;
+		return ERR_PTR(-EIO);
 	}
 
 	size = ntohl(*p++);
 	if (size != 0) {
 		printk("RPC: bad verf size: %u\n", size);
-		return NULL;
+		return ERR_PTR(-EIO);
 	}
 
 	return p;
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index dc37021..8bfe1b7 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -192,13 +192,13 @@ unx_validate(struct rpc_task *task, __be32 *p)
 	    flavor != RPC_AUTH_UNIX &&
 	    flavor != RPC_AUTH_SHORT) {
 		printk("RPC: bad verf flavor: %u\n", flavor);
-		return NULL;
+		return ERR_PTR(-EIO);
 	}
 
 	size = ntohl(*p++);
 	if (size > RPC_MAX_AUTH_SIZE) {
 		printk("RPC: giant verf size: %u\n", size);
-		return NULL;
+		return ERR_PTR(-EIO);
 	}
 	task->tk_rqstp->rq_cred->cr_auth->au_rslack = (size >> 2) + 2;
 	p += (size >> 2);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b544965..b98b314 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2091,7 +2091,8 @@ rpc_verify_header(struct rpc_task *task)
 		dprintk("RPC: %5u %s: XDR representation not a multiple of"
 		       " 4 bytes: 0x%x\n", task->tk_pid, __func__,
 		       task->tk_rqstp->rq_rcv_buf.len);
-		goto out_eio;
+		error = -EIO;
+		goto out_err;
 	}
 	if ((len -= 3) < 0)
 		goto out_overflow;
@@ -2100,6 +2101,7 @@ rpc_verify_header(struct rpc_task *task)
 	if ((n = ntohl(*p++)) != RPC_REPLY) {
 		dprintk("RPC: %5u %s: not an RPC reply: %x\n",
 			task->tk_pid, __func__, n);
+		error = -EIO;
 		goto out_garbage;
 	}
 
@@ -2118,7 +2120,8 @@ rpc_verify_header(struct rpc_task *task)
 			dprintk("RPC: %5u %s: RPC call rejected, "
 				"unknown error: %x\n",
 				task->tk_pid, __func__, n);
-			goto out_eio;
+			error = -EIO;
+			goto out_err;
 		}
 		if (--len < 0)
 			goto out_overflow;
@@ -2163,9 +2166,11 @@ rpc_verify_header(struct rpc_task *task)
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
@@ -2218,8 +2223,6 @@ out_garbage:
 out_retry:
 		return ERR_PTR(-EAGAIN);
 	}
-out_eio:
-	error = -EIO;
 out_err:
 	rpc_exit(task, error);
 	dprintk("RPC: %5u %s: call failed with error %d\n", task->tk_pid,
-- 
1.8.3.1

