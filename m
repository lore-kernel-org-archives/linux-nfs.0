Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33128 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752384AbdHPXAO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Aug 2017 19:00:14 -0400
Received: by mail-io0-f193.google.com with SMTP id q64so3128254ioi.0
        for <linux-nfs@vger.kernel.org>; Wed, 16 Aug 2017 16:00:14 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/5] SUNRPC: Don't hold the transport lock across socket copy operations
Date: Wed, 16 Aug 2017 19:00:04 -0400
Message-Id: <20170816230008.20006-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170816230008.20006-1-trond.myklebust@primarydata.com>
References: <20170816230008.20006-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead add a mechanism to ensure that the request doesn't disappear
from underneath us while copying from the socket. We do this by
preventing xprt_release() from freeing the XDR buffers until the
flag RPC_TASK_MSG_RECV has been cleared from the request.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/sched.h |  2 ++
 include/linux/sunrpc/xprt.h  |  2 ++
 net/sunrpc/xprt.c            | 43 +++++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtsock.c        | 23 ++++++++++++++++++-----
 4 files changed, 65 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 50a99a117da7..c1768f9d993b 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -139,6 +139,8 @@ struct rpc_task_setup {
 #define RPC_TASK_RUNNING	0
 #define RPC_TASK_QUEUED		1
 #define RPC_TASK_ACTIVE		2
+#define RPC_TASK_MSG_RECV	3
+#define RPC_TASK_MSG_RECV_WAIT	4
 
 #define RPC_IS_RUNNING(t)	test_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
 #define rpc_set_running(t)	set_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index eab1c749e192..65b9e0224753 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -372,6 +372,8 @@ void			xprt_write_space(struct rpc_xprt *xprt);
 void			xprt_adjust_cwnd(struct rpc_xprt *xprt, struct rpc_task *task, int result);
 struct rpc_rqst *	xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid);
 void			xprt_complete_rqst(struct rpc_task *task, int copied);
+void			xprt_pin_rqst(struct rpc_rqst *req);
+void			xprt_unpin_rqst(struct rpc_rqst *req);
 void			xprt_release_rqst_cong(struct rpc_task *task);
 void			xprt_disconnect_done(struct rpc_xprt *xprt);
 void			xprt_force_disconnect(struct rpc_xprt *xprt);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 4654a9934269..3eb9ec16eec4 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -844,6 +844,48 @@ struct rpc_rqst *xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid)
 }
 EXPORT_SYMBOL_GPL(xprt_lookup_rqst);
 
+/**
+ * xprt_pin_rqst - Pin a request on the transport receive list
+ * @req: Request to pin
+ *
+ * Caller must ensure this is atomic with the call to xprt_lookup_rqst()
+ * so should be holding the xprt transport lock.
+ */
+void xprt_pin_rqst(struct rpc_rqst *req)
+{
+	set_bit(RPC_TASK_MSG_RECV, &req->rq_task->tk_runstate);
+}
+
+/**
+ * xprt_unpin_rqst - Unpin a request on the transport receive list
+ * @req: Request to pin
+ *
+ * Caller should be holding the xprt transport lock.
+ */
+void xprt_unpin_rqst(struct rpc_rqst *req)
+{
+	struct rpc_task *task = req->rq_task;
+
+	clear_bit(RPC_TASK_MSG_RECV, &task->tk_runstate);
+	if (test_bit(RPC_TASK_MSG_RECV_WAIT, &task->tk_runstate))
+		wake_up_bit(&task->tk_runstate, RPC_TASK_MSG_RECV);
+}
+
+static void xprt_wait_on_pinned_rqst(struct rpc_rqst *req)
+__must_hold(&req->rq_xprt->transport_lock)
+{
+	struct rpc_task *task = req->rq_task;
+	
+	if (task && test_bit(RPC_TASK_MSG_RECV, &task->tk_runstate)) {
+		spin_unlock_bh(&req->rq_xprt->transport_lock);
+		set_bit(RPC_TASK_MSG_RECV_WAIT, &task->tk_runstate);
+		wait_on_bit(&task->tk_runstate, RPC_TASK_MSG_RECV,
+				TASK_UNINTERRUPTIBLE);
+		clear_bit(RPC_TASK_MSG_RECV_WAIT, &task->tk_runstate);
+		spin_lock_bh(&req->rq_xprt->transport_lock);
+	}
+}
+
 static void xprt_update_rtt(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
@@ -1295,6 +1337,7 @@ void xprt_release(struct rpc_task *task)
 		list_del(&req->rq_list);
 	xprt->last_used = jiffies;
 	xprt_schedule_autodisconnect(xprt);
+	xprt_wait_on_pinned_rqst(req);
 	spin_unlock_bh(&xprt->transport_lock);
 	if (req->rq_buffer)
 		xprt->ops->buf_free(task);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4f154d388748..04dbc7027712 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -973,6 +973,8 @@ static void xs_local_data_read_skb(struct rpc_xprt *xprt,
 	rovr = xprt_lookup_rqst(xprt, *xp);
 	if (!rovr)
 		goto out_unlock;
+	xprt_pin_rqst(rovr);
+	spin_unlock_bh(&xprt->transport_lock);
 	task = rovr->rq_task;
 
 	copied = rovr->rq_private_buf.buflen;
@@ -981,11 +983,14 @@ static void xs_local_data_read_skb(struct rpc_xprt *xprt,
 
 	if (xs_local_copy_to_xdr(&rovr->rq_private_buf, skb)) {
 		dprintk("RPC:       sk_buff copy failed\n");
-		goto out_unlock;
+		spin_lock_bh(&xprt->transport_lock);
+		goto out_unpin;
 	}
 
+	spin_lock_bh(&xprt->transport_lock);
 	xprt_complete_rqst(task, copied);
-
+out_unpin:
+	xprt_unpin_rqst(rovr);
  out_unlock:
 	spin_unlock_bh(&xprt->transport_lock);
 }
@@ -1054,6 +1059,8 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
 	rovr = xprt_lookup_rqst(xprt, *xp);
 	if (!rovr)
 		goto out_unlock;
+	xprt_pin_rqst(rovr);
+	spin_unlock_bh(&xprt->transport_lock);
 	task = rovr->rq_task;
 
 	if ((copied = rovr->rq_private_buf.buflen) > repsize)
@@ -1062,14 +1069,17 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
 	/* Suck it into the iovec, verify checksum if not done by hw. */
 	if (csum_partial_copy_to_xdr(&rovr->rq_private_buf, skb)) {
 		__UDPX_INC_STATS(sk, UDP_MIB_INERRORS);
-		goto out_unlock;
+		spin_lock_bh(&xprt->transport_lock);
+		goto out_unpin;
 	}
 
 	__UDPX_INC_STATS(sk, UDP_MIB_INDATAGRAMS);
 
+	spin_lock_bh(&xprt->transport_lock);
 	xprt_adjust_cwnd(xprt, task, copied);
 	xprt_complete_rqst(task, copied);
-
+out_unpin:
+	xprt_unpin_rqst(rovr);
  out_unlock:
 	spin_unlock_bh(&xprt->transport_lock);
 }
@@ -1351,12 +1361,15 @@ static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
 		spin_unlock_bh(&xprt->transport_lock);
 		return -1;
 	}
+	xprt_pin_rqst(req);
+	spin_unlock_bh(&xprt->transport_lock);
 
 	xs_tcp_read_common(xprt, desc, req);
 
+	spin_lock_bh(&xprt->transport_lock);
 	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
 		xprt_complete_rqst(req->rq_task, transport->tcp_copied);
-
+	xprt_unpin_rqst(req);
 	spin_unlock_bh(&xprt->transport_lock);
 	return 0;
 }
-- 
2.13.5

