Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33987 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755095AbbK3WPM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Nov 2015 17:15:12 -0500
Subject: [PATCH v2 09/11] SUNRPC: Introduce xprt_commit_rqst()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 30 Nov 2015 17:15:10 -0500
Message-ID: <20151130221510.12235.65241.stgit@manet.1015granger.net>
In-Reply-To: <20151130221349.12235.29565.stgit@manet.1015granger.net>
References: <20151130221349.12235.29565.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm about to add code in the RPC/RDMA reply handler between the
xprt_lookup_rqst() and xprt_complete_rqst() call site that needs
to execute outside of spinlock critical sections.

Add a hook to remove an rpc_rqst from the pending list once
the transport knows its going to invoke xprt_complete_rqst().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xprt.h    |    1 +
 net/sunrpc/xprt.c              |   14 ++++++++++++++
 net/sunrpc/xprtrdma/rpc_rdma.c |    4 ++++
 3 files changed, 19 insertions(+)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 69ef5b3..ab6c3a5 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -366,6 +366,7 @@ void			xprt_wait_for_buffer_space(struct rpc_task *task, rpc_action action);
 void			xprt_write_space(struct rpc_xprt *xprt);
 void			xprt_adjust_cwnd(struct rpc_xprt *xprt, struct rpc_task *task, int result);
 struct rpc_rqst *	xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid);
+void			xprt_commit_rqst(struct rpc_task *task);
 void			xprt_complete_rqst(struct rpc_task *task, int copied);
 void			xprt_release_rqst_cong(struct rpc_task *task);
 void			xprt_disconnect_done(struct rpc_xprt *xprt);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 2e98f4a..a5be4ab 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -837,6 +837,20 @@ static void xprt_update_rtt(struct rpc_task *task)
 }
 
 /**
+ * xprt_commit_rqst - remove rqst from pending list early
+ * @task: RPC request to remove
+ *
+ * Caller holds transport lock.
+ */
+void xprt_commit_rqst(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+
+	list_del_init(&req->rq_list);
+}
+EXPORT_SYMBOL_GPL(xprt_commit_rqst);
+
+/**
  * xprt_complete_rqst - called when reply processing is complete
  * @task: RPC request that recently completed
  * @copied: actual number of bytes received from the transport
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c10d969..0bc8c39 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -804,6 +804,9 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	if (req->rl_reply)
 		goto out_duplicate;
 
+	xprt_commit_rqst(rqst->rq_task);
+	spin_unlock_bh(&xprt->transport_lock);
+
 	dprintk("RPC:       %s: reply 0x%p completes request 0x%p\n"
 		"                   RPC request 0x%p xid 0x%08x\n",
 			__func__, rep, req, rqst,
@@ -894,6 +897,7 @@ badheader:
 	else if (credits > r_xprt->rx_buf.rb_max_requests)
 		credits = r_xprt->rx_buf.rb_max_requests;
 
+	spin_lock_bh(&xprt->transport_lock);
 	cwnd = xprt->cwnd;
 	xprt->cwnd = credits << RPC_CWNDSHIFT;
 	if (xprt->cwnd > cwnd)

