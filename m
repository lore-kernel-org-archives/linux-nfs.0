Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:39591 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755235AbbBLPOz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Feb 2015 10:14:55 -0500
Received: by mail-ig0-f172.google.com with SMTP id l13so4240885iga.5
        for <linux-nfs@vger.kernel.org>; Thu, 12 Feb 2015 07:14:54 -0800 (PST)
Subject: [PATCH] xprtrdma: Store RDMA credits in unsigned variables
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com
Date: Thu, 12 Feb 2015 10:14:51 -0500
Message-ID: <20150212151451.18290.89745.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dan Carpenter's static checker pointed out:

   net/sunrpc/xprtrdma/rpc_rdma.c:879 rpcrdma_reply_handler()
   warn: can 'credits' be negative?

"credits" is defined as an int. The credits value comes from the
server as a 32-bit unsigned integer.

A malicious or broken server can plant a large unsigned integer in
that field which would result in an underflow in the following
logic, potentially triggering a deadlock of the mount point by
blocking the client from issuing more RPC requests.

net/sunrpc/xprtrdma/rpc_rdma.c:

  876          credits = be32_to_cpu(headerp->rm_credit);
  877          if (credits == 0)
  878                  credits = 1;    /* don't deadlock */
  879          else if (credits > r_xprt->rx_buf.rb_max_requests)
  880                  credits = r_xprt->rx_buf.rb_max_requests;
  881
  882          cwnd = xprt->cwnd;
  883          xprt->cwnd = credits << RPC_CWNDSHIFT;
  884          if (xprt->cwnd > cwnd)
  885                  xprt_release_rqst_cong(rqst->rq_task);

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Fixes: eba8ff660b2d ("xprtrdma: Move credit update to RPC . . .")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    3 ++-
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 7e9acd9..91ffde8 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -738,8 +738,9 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	struct rpc_xprt *xprt = rep->rr_xprt;
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	__be32 *iptr;
-	int credits, rdmalen, status;
+	int rdmalen, status;
 	unsigned long cwnd;
+	u32 credits;
 
 	/* Check status. If bad, signal disconnect and return rep to pool */
 	if (rep->rr_len == ~0U) {
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index d1b7039..0a16fb6 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -285,7 +285,7 @@ rpcr_to_rdmar(struct rpc_rqst *rqst)
  */
 struct rpcrdma_buffer {
 	spinlock_t	rb_lock;	/* protects indexes */
-	int		rb_max_requests;/* client max requests */
+	u32		rb_max_requests;/* client max requests */
 	struct list_head rb_mws;	/* optional memory windows/fmrs/frmrs */
 	struct list_head rb_all;
 	int		rb_send_index;

