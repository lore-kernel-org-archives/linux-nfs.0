Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36547 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753008AbdC0OGM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Mar 2017 10:06:12 -0400
Subject: [PATCH v2 03/13] xprtrdma: Detect unreachable NFS/RDMA servers more
 reliably
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 27 Mar 2017 10:05:59 -0400
Message-ID: <20170327140559.20813.21930.stgit@manet.1015granger.net>
In-Reply-To: <20170327134847.20813.52412.stgit@manet.1015granger.net>
References: <20170327134847.20813.52412.stgit@manet.1015granger.net>
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

To address this, forcibly disconnect a transport when an RPC times
out. This prevents moribund connections from stopping the
detection of failover or other configuration changes on the server.

Note that even if the connection is still good, retransmitting
any RPC will trigger a disconnect thanks to this logic in
xprt_rdma_send_request:

	/* Must suppress retransmit to maintain credits */
	if (req->rl_connect_cookie == xprt->connect_cookie)
		goto drop_connection;
	req->rl_connect_cookie = xprt->connect_cookie;

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |   22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index c717f54..acf5d81 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -484,6 +484,27 @@
 	dprintk("RPC:       %s: %u\n", __func__, port);
 }
 
+/**
+ * xprt_rdma_timer - invoked when an RPC times out
+ * @xprt: controlling RPC transport
+ * @task: RPC task that timed out
+ *
+ * Invoked when the transport is still connected, but an RPC
+ * retransmit timeout occurs.
+ *
+ * Since RDMA connections don't have a keep-alive, forcibly
+ * disconnect and retry to connect. This drives full
+ * detection of the network path, and retransmissions of
+ * all pending RPCs.
+ */
+static void
+xprt_rdma_timer(struct rpc_xprt *xprt, struct rpc_task *task)
+{
+	dprintk("RPC: %5u %s: xprt = %p\n", task->tk_pid, __func__, xprt);
+
+	xprt_force_disconnect(xprt);
+}
+
 static void
 xprt_rdma_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 {
@@ -776,6 +797,7 @@ void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 	.alloc_slot		= xprt_alloc_slot,
 	.release_request	= xprt_release_rqst_cong,       /* ditto */
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def, /* ditto */
+	.timer			= xprt_rdma_timer,
 	.rpcbind		= rpcb_getport_async,	/* sunrpc/rpcb_clnt.c */
 	.set_port		= xprt_rdma_set_port,
 	.connect		= xprt_rdma_connect,

