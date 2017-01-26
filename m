Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33421 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754109AbdAZR4g (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2017 12:56:36 -0500
Subject: [PATCH v1 6/7] xprtrdma: Detect unreachable NFS/RDMA servers more
 reliably
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 26 Jan 2017 12:56:20 -0500
Message-ID: <20170126175620.5794.47101.stgit@manet.1015granger.net>
In-Reply-To: <20170126174806.5794.14678.stgit@manet.1015granger.net>
References: <20170126174806.5794.14678.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Current NFS clients rely on connection loss to determine when to
retransmit. In particular, for protocols like NFSv4, clients no
longer rely on RPC timeouts to drive retransmission: NFSv4 servers
are required to terminate a connection when they need a client to
retransmit pending RPCs.

When a server is no longer reachable, either because it has crashed
or because the network path has broken, the server cannot actively
terminate a connection. Thus NFS clients depend on transport-level
keepalive to determine when a connection must be replaced and
pending RPCs retransmitted.

However, RDMA RC connections do not have a native keepalive
mechanism. If an NFS/RDMA server crashes after a client has sent
RPCs successfully (an RC ACK has been received for all OTW RDMA
requests), there is no way for the client to know the connection is
moribund.

In addition, new RDMA requests are subject to the RPC-over-RDMA
credit limit. If the client has consumed all granted credits with
NFS traffic, it is not allowed to send another RDMA request until
the server replies. Thus it has no way to send a true keepalive when
the workload has already consumed all credits with pending RPCs.

To address this, emit an RPC NULL ping when an RPC retransmit
timeout occurs.

The purpose of this ping is to drive traffic on the connection to
force the transport layer to disconnect it if it is no longer
viable. Some RDMA operations are fully offloaded to the HCA, and can
be successful even if the server O/S has crashed. Thus an operation
that requires that the server is responsive is used for the ping.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |   61 +++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/xprt_rdma.h |    5 +++
 2 files changed, 66 insertions(+)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 6990581..f97c851 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -484,6 +484,66 @@
 	dprintk("RPC:       %s: %u\n", __func__, port);
 }
 
+static void rpcrdma_keepalive_done(struct rpc_task *task, void *calldata)
+{
+	struct rpc_xprt *xprt = (struct rpc_xprt *)calldata;
+	struct rpcrdma_xprt *r_xprt =
+		container_of(xprt, struct rpcrdma_xprt, rx_xprt);
+
+	/* Convert to dprintk before merging */
+	pr_info("RPC:       %s: keepalive ping on xprt %p, status %d\n",
+		__func__, xprt, task->tk_status);
+
+	if (task->tk_status)
+		rdma_disconnect(r_xprt->rx_ia.ri_id);
+
+	clear_bit(RPCRDMA_KEEPALIVE, &r_xprt->rx_ia.ri_flags);
+}
+
+static void rpcrdma_keepalive_release(void *calldata)
+{
+	struct rpc_xprt *xprt = (struct rpc_xprt *)calldata;
+
+	xprt_put(xprt);
+}
+
+static const struct rpc_call_ops rpcrdma_keepalive_call_ops = {
+	.rpc_call_done	= rpcrdma_keepalive_done,
+	.rpc_release	= rpcrdma_keepalive_release,
+};
+
+/**
+ * xprt_rdma_timer - invoked when an RPC times out
+ * @xprt: controlling RPC transport
+ * @task: RPC task that timed out
+ *
+ * Send a NULL RPC to see if the server still responds.
+ * If it doesn't, close the connection.
+ */
+static void
+xprt_rdma_timer(struct rpc_xprt *xprt, struct rpc_task *task)
+{
+	struct rpcrdma_xprt *r_xprt =
+		container_of(xprt, struct rpcrdma_xprt, rx_xprt);
+	struct rpc_task *null_task;
+	void *data;
+
+	/* Ensure only one ping is sent at a time */
+	if (!test_and_set_bit(RPCRDMA_KEEPALIVE, &r_xprt->rx_ia.ri_flags))
+		return;
+
+	/* Convert to dprintk before merging */
+	pr_info("RPC:       %s: sending keepalive ping on xprt %p\n",
+		__func__, xprt);
+
+	data = xprt_get(xprt);
+	null_task = rpc_call_null_helper(task->tk_client, xprt, NULL,
+					 RPC_TASK_SOFT | RPC_TASK_ASYNC,
+					 &rpcrdma_keepalive_call_ops, data);
+	if (!IS_ERR(null_task))
+		rpc_put_task(null_task);
+}
+
 static void
 xprt_rdma_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 {
@@ -780,6 +840,7 @@ void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 	.alloc_slot		= xprt_alloc_slot,
 	.release_request	= xprt_release_rqst_cong,       /* ditto */
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def, /* ditto */
+	.timer			= xprt_rdma_timer,
 	.rpcbind		= rpcb_getport_async,	/* sunrpc/rpcb_clnt.c */
 	.set_port		= xprt_rdma_set_port,
 	.connect		= xprt_rdma_connect,
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 171a351..35cd0ac 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -77,11 +77,16 @@ struct rpcrdma_ia {
 	unsigned int		ri_max_send_sges;
 	bool			ri_reminv_expected;
 	bool			ri_implicit_roundup;
+	unsigned long		ri_flags;
 	enum ib_mr_type		ri_mrtype;
 	struct ib_qp_attr	ri_qp_attr;
 	struct ib_qp_init_attr	ri_qp_init_attr;
 };
 
+enum {
+	RPCRDMA_KEEPALIVE	= 0,
+};
+
 /*
  * RDMA Endpoint -- one per transport instance
  */

