From: Tom Talpey <talpey@netapp.com>
Subject: [PATCH 1/2] RPC/RDMA: correct the reconnect timer backoff
Date: Fri, 10 Oct 2008 11:32:34 -0400
Message-ID: <20081010153234.3983.29110.stgit@tmt3.nane.netapp.com>
References: <20081010152634.3983.91559.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:10531 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758191AbYJJPcg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Oct 2008 11:32:36 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m9AFWYoe004042
	for <linux-nfs@vger.kernel.org>; Fri, 10 Oct 2008 11:32:35 -0400
In-Reply-To: <20081010152634.3983.91559.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RPC/RDMA code had a constant 5-second reconnect backoff, and
always performed it, even when re-establishing a connection to a
server after the RPC layer closed it due to being idle. Make it
an geometric backoff (up to 30 seconds), and don't delay idle
reconnect.

Signed-off-by: Tom Talpey <talpey@netapp.com>
---

 net/sunrpc/xprtrdma/transport.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index c2da680..9839c3d 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -463,6 +463,8 @@ xprt_rdma_close(struct rpc_xprt *xprt)
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 
 	dprintk("RPC:       %s: closing\n", __func__);
+	if (r_xprt->rx_ep.rep_connected > 0)
+		xprt->reestablish_timeout = 0;
 	xprt_disconnect_done(xprt);
 	(void) rpcrdma_ep_disconnect(&r_xprt->rx_ep, &r_xprt->rx_ia);
 }
@@ -490,6 +492,11 @@ xprt_rdma_connect(struct rpc_task *task)
 			/* Reconnect */
 			schedule_delayed_work(&r_xprt->rdma_connect,
 				xprt->reestablish_timeout);
+			xprt->reestablish_timeout <<= 1;
+			if (xprt->reestablish_timeout > (30 * HZ))
+				xprt->reestablish_timeout = (30 * HZ);
+			else if (xprt->reestablish_timeout < (5 * HZ))
+				xprt->reestablish_timeout = (5 * HZ);
 		} else {
 			schedule_delayed_work(&r_xprt->rdma_connect, 0);
 			if (!RPC_IS_ASYNC(task))

