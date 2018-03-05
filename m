Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:43046 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751462AbeCEUM6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2018 15:12:58 -0500
Subject: [PATCH 1/9] SUNRPC: Move xprt_update_rtt callsite
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 05 Mar 2018 15:12:57 -0500
Message-ID: <20180305201256.10904.41488.stgit@manet.1015granger.net>
In-Reply-To: <20180305200825.10904.40829.stgit@manet.1015granger.net>
References: <20180305200825.10904.40829.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit 33849792cbcd ("xprtrdma: Detect unreachable NFS/RDMA
servers more reliably"), the xprtrdma transport now has a ->timer
callout. But xprtrdma does not need to compute RTT data, only UDP
needs that. Move the xprt_update_rtt call into the UDP transport
implementation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/xprt.c           |   11 ++++++++---
 net/sunrpc/xprtsock.c       |    1 +
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 7fad838..ad322ce 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -373,6 +373,7 @@ static inline __be32 *xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *
 void			xprt_write_space(struct rpc_xprt *xprt);
 void			xprt_adjust_cwnd(struct rpc_xprt *xprt, struct rpc_task *task, int result);
 struct rpc_rqst *	xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid);
+void			xprt_update_rtt(struct rpc_task *task);
 void			xprt_complete_rqst(struct rpc_task *task, int copied);
 void			xprt_pin_rqst(struct rpc_rqst *req);
 void			xprt_unpin_rqst(struct rpc_rqst *req);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 8f0ad4f..13fbb48 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -889,7 +889,13 @@ static void xprt_wait_on_pinned_rqst(struct rpc_rqst *req)
 	}
 }
 
-static void xprt_update_rtt(struct rpc_task *task)
+/**
+ * xprt_update_rtt - Update RPC RTT statistics
+ * @task: RPC request that recently completed
+ *
+ * Caller holds xprt->recv_lock.
+ */
+void xprt_update_rtt(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_rtt *rtt = task->tk_client->cl_rtt;
@@ -902,6 +908,7 @@ static void xprt_update_rtt(struct rpc_task *task)
 		rpc_set_timeo(rtt, timer, req->rq_ntrans - 1);
 	}
 }
+EXPORT_SYMBOL_GPL(xprt_update_rtt);
 
 /**
  * xprt_complete_rqst - called when reply processing is complete
@@ -921,8 +928,6 @@ void xprt_complete_rqst(struct rpc_task *task, int copied)
 
 	xprt->stat.recvs++;
 	req->rq_rtt = ktime_sub(ktime_get(), req->rq_xtime);
-	if (xprt->ops->timer != NULL)
-		xprt_update_rtt(task);
 
 	list_del_init(&req->rq_list);
 	req->rq_private_buf.len = copied;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index a6b8c1f..61df77f 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1060,6 +1060,7 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
 	if (!rovr)
 		goto out_unlock;
 	xprt_pin_rqst(rovr);
+	xprt_update_rtt(rovr->rq_task);
 	spin_unlock(&xprt->recv_lock);
 	task = rovr->rq_task;
 

