From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] SUNRPC: RPC metrics and RTT estimator should use same RTT
	value
Date: Thu, 27 Mar 2008 16:14:12 -0400
Message-ID: <20080327201411.4587.50445.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: thomas.talpey@netapp.com, linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:46660 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757221AbYC0UO2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Mar 2008 16:14:28 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Compute an RPC request's RTT once, and use that value both for reporting
RPC metrics, and for adjusting the RTT context used by the RPC client's RTT
estimator algorithm.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprt.c     |   10 +++++-----
 net/sunrpc/xprtsock.c |   15 +++++++++++++--
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index fd8cb6d..35fc75e 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -723,6 +723,7 @@ EXPORT_SYMBOL_GPL(xprt_lookup_rqst);
  * xprt_update_rtt - update an RPC client's RTT state after receiving a reply
  * @task: RPC request that recently completed
  *
+ * Caller holds transport lock.
  */
 void xprt_update_rtt(struct rpc_task *task)
 {
@@ -732,8 +733,7 @@ void xprt_update_rtt(struct rpc_task *task)
 
 	if (timer) {
 		if (req->rq_ntrans == 1)
-			rpc_update_rtt(rtt, timer,
-					(long)jiffies - req->rq_xtime);
+			rpc_update_rtt(rtt, timer, task->tk_rtt);
 		rpc_set_timeo(rtt, timer, req->rq_ntrans - 1);
 	}
 }
@@ -750,12 +750,12 @@ void xprt_complete_rqst(struct rpc_task *task, int copied)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 
+	task->tk_rtt = (long)jiffies - req->rq_xtime;
+	task->tk_xprt->stat.recvs++;
+
 	dprintk("RPC: %5u xid %08x complete (%d bytes received)\n",
 			task->tk_pid, ntohl(req->rq_xid), copied);
 
-	task->tk_xprt->stat.recvs++;
-	task->tk_rtt = (long)jiffies - req->rq_xtime;
-
 	list_del_init(&req->rq_list);
 	/* Ensure all writes are done before we update req->rq_received */
 	smp_wmb();
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5c5491e..e4e276b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -705,6 +705,18 @@ static int xs_tcp_send_request(struct rpc_task *task)
 }
 
 /**
+ * xs_udp_release_xprt - clean up after sending an RPC request via UDP
+ * @xprt: transport
+ * @task: rpc task
+ *
+ */
+static void xs_udp_release_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
+{
+	xprt_update_rtt(task);
+	xprt_release_xprt_cong(xprt, task);
+}
+
+/**
  * xs_tcp_release_xprt - clean up after a tcp transmission
  * @xprt: transport
  * @task: rpc task
@@ -856,7 +868,6 @@ static void xs_udp_data_ready(struct sock *sk, int len)
 	dst_confirm(skb->dst);
 
 	xprt_adjust_cwnd(task, copied);
-	xprt_update_rtt(task);
 	xprt_complete_rqst(task, copied);
 
  out_unlock:
@@ -1819,7 +1830,7 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 static struct rpc_xprt_ops xs_udp_ops = {
 	.set_buffer_size	= xs_udp_set_buffer_size,
 	.reserve_xprt		= xprt_reserve_xprt_cong,
-	.release_xprt		= xprt_release_xprt_cong,
+	.release_xprt		= xs_udp_release_xprt,
 	.rpcbind		= rpcb_getport_async,
 	.set_port		= xs_set_port,
 	.connect		= xs_connect,

