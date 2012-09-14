Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60918 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755379Ab2INVLg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Sep 2012 17:11:36 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 5/5] SUNRPC Fix rpc_verify_header error returns
Date: Fri, 14 Sep 2012 17:11:49 -0400
Message-Id: <1347657109-2180-6-git-send-email-andros@netapp.com>
In-Reply-To: <1347657109-2180-1-git-send-email-andros@netapp.com>
References: <1347657109-2180-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/clnt.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index a15b96c..f3136cc 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2005,7 +2005,8 @@ rpc_verify_header(struct rpc_task *task)
 		dprintk("RPC: %5u %s: XDR representation not a multiple of"
 		       " 4 bytes: 0x%x\n", task->tk_pid, __func__,
 		       task->tk_rqstp->rq_rcv_buf.len);
-		goto out_eio;
+		error = -EIO;
+		goto out_err;
 	}
 	if ((len -= 3) < 0)
 		goto out_overflow;
@@ -2014,6 +2015,7 @@ rpc_verify_header(struct rpc_task *task)
 	if ((n = ntohl(*p++)) != RPC_REPLY) {
 		dprintk("RPC: %5u %s: not an RPC reply: %x\n",
 			task->tk_pid, __func__, n);
+		error = -EIO;
 		goto out_garbage;
 	}
 
@@ -2032,7 +2034,8 @@ rpc_verify_header(struct rpc_task *task)
 			dprintk("RPC: %5u %s: RPC call rejected, "
 				"unknown error: %x\n",
 				task->tk_pid, __func__, n);
-			goto out_eio;
+			error = -EIO;
+			goto out_err;
 		}
 		if (--len < 0)
 			goto out_overflow;
@@ -2080,6 +2083,7 @@ rpc_verify_header(struct rpc_task *task)
 	if (!(p = rpcauth_checkverf(task, p))) {
 		dprintk("RPC: %5u %s: auth check failed\n",
 				task->tk_pid, __func__);
+		error = -EACCES;
 		goto out_garbage;		/* bad verifier, retry */
 	}
 	len = p - (__be32 *)iov->iov_base - 1;
@@ -2132,8 +2136,6 @@ out_garbage:
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

