From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/9] SUNRPC: RPC metrics and RTT estimator should use same RTT
	value
Date: Wed, 21 Apr 2010 13:44:02 -0400
Message-ID: <20100421174401.2037.67329.stgit@localhost.localdomain>
References: <20100421173628.2037.54635.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f178.google.com ([209.85.222.178]:45285 "EHLO
	mail-pz0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756045Ab0DURux (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 13:50:53 -0400
Received: by pzk8 with SMTP id 8so1018642pzk.16
        for <linux-nfs@vger.kernel.org>; Wed, 21 Apr 2010 10:50:52 -0700 (PDT)
In-Reply-To: <20100421173628.2037.54635.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Compute an RPC request's RTT once, and use that value both for reporting
RPC metrics, and for adjusting the RTT context used by the RPC client's RTT
estimator algorithm.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    1 -
 net/sunrpc/xprt.c           |   13 ++++---------
 net/sunrpc/xprtsock.c       |    1 -
 3 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 6f9457a..94bfee0 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -294,7 +294,6 @@ void			xprt_set_retrans_timeout_rtt(struct rpc_task *task);
 void			xprt_wake_pending_tasks(struct rpc_xprt *xprt, int status);
 void			xprt_wait_for_buffer_space(struct rpc_task *task, rpc_action action);
 void			xprt_write_space(struct rpc_xprt *xprt);
-void			xprt_update_rtt(struct rpc_task *task);
 void			xprt_adjust_cwnd(struct rpc_task *task, int result);
 struct rpc_rqst *	xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid);
 void			xprt_complete_rqst(struct rpc_task *task, int copied);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 42f09ad..5559ec4 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -771,12 +771,7 @@ struct rpc_rqst *xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid)
 }
 EXPORT_SYMBOL_GPL(xprt_lookup_rqst);
 
-/**
- * xprt_update_rtt - update an RPC client's RTT state after receiving a reply
- * @task: RPC request that recently completed
- *
- */
-void xprt_update_rtt(struct rpc_task *task)
+static void xprt_update_rtt(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_rtt *rtt = task->tk_client->cl_rtt;
@@ -784,12 +779,10 @@ void xprt_update_rtt(struct rpc_task *task)
 
 	if (timer) {
 		if (req->rq_ntrans == 1)
-			rpc_update_rtt(rtt, timer,
-					(long)jiffies - req->rq_xtime);
+			rpc_update_rtt(rtt, timer, task->tk_rtt);
 		rpc_set_timeo(rtt, timer, req->rq_ntrans - 1);
 	}
 }
-EXPORT_SYMBOL_GPL(xprt_update_rtt);
 
 /**
  * xprt_complete_rqst - called when reply processing is complete
@@ -808,6 +801,8 @@ void xprt_complete_rqst(struct rpc_task *task, int copied)
 
 	xprt->stat.recvs++;
 	task->tk_rtt = (long)jiffies - req->rq_xtime;
+	if (xprt->ops->timer != NULL)
+		xprt_update_rtt(task);
 
 	list_del_init(&req->rq_list);
 	req->rq_private_buf.len = copied;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 9847c30..38203c8 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -858,7 +858,6 @@ static void xs_udp_data_ready(struct sock *sk, int len)
 	dst_confirm(skb_dst(skb));
 
 	xprt_adjust_cwnd(task, copied);
-	xprt_update_rtt(task);
 	xprt_complete_rqst(task, copied);
 
  out_unlock:

