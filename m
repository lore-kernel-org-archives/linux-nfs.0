From: Tom Talpey <talpey@netapp.com>
Subject: [PATCH 12/15] RPC/RDMA: correct a 5 second pause on reconnecting to
	an idle server.
Date: Wed, 08 Oct 2008 11:48:56 -0400
Message-ID: <20081008154856.1336.18339.stgit@tmt3.nane.netapp.com>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:44118 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754418AbYJHQWL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 12:22:11 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m98FmuHB001574
	for <linux-nfs@vger.kernel.org>; Wed, 8 Oct 2008 11:48:56 -0400
In-Reply-To: <20081008154506.1336.59892.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RPC/RDMA code always performed a reconnect-with-backoff, even
when re-establishing a connection to a server after the RPC layer
closed it due to being idle.
---

 net/sunrpc/xprtrdma/transport.c |    5 +++--
 net/sunrpc/xprtrdma/verbs.c     |    2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index c7d2380..278a544 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -486,8 +486,9 @@ xprt_rdma_connect(struct rpc_task *task)
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 
 	if (!xprt_test_and_set_connecting(xprt)) {
-		if (r_xprt->rx_ep.rep_connected != 0) {
-			/* Reconnect */
+		if (r_xprt->rx_ep.rep_connected &&
+		    r_xprt->rx_ep.rep_connected != -EPIPE) {
+			/* Reconnect with backoff */
 			schedule_delayed_work(&r_xprt->rdma_connect,
 				xprt->reestablish_timeout);
 		} else {
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index a63d0c0..9ef7e0d 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -317,7 +317,7 @@ rpcrdma_conn_upcall(struct rdma_cm_id *id, struct rdma_cm_event *event)
 		connstate = -ECONNREFUSED;
 		goto connected;
 	case RDMA_CM_EVENT_DISCONNECTED:
-		connstate = -ECONNABORTED;
+		connstate = -EPIPE;
 		goto connected;
 	case RDMA_CM_EVENT_DEVICE_REMOVAL:
 		connstate = -ENODEV;

