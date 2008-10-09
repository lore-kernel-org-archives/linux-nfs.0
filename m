From: Tom Talpey <talpey@netapp.com>
Subject: [UPDATED PATCH 10/14] RPC/RDMA: return a consistent error,
	when connect fails.
Date: Thu, 09 Oct 2008 15:01:21 -0400
Message-ID: <20081009190121.13947.15892.stgit@tmt3.nane.netapp.com>
References: <20081009185643.13947.64733.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:9809 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758965AbYJITBW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2008 15:01:22 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m99J1L9X014162
	for <linux-nfs@vger.kernel.org>; Thu, 9 Oct 2008 15:01:21 -0400
In-Reply-To: <20081009185643.13947.64733.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The xprt_connect call path does not expect such errors as ECONNREFUSED
to be returned from failed transport connection attempts, otherwise it
translates them to EIO and signals fatal errors. For example, mount.nfs
prints simply "internal error". Translate all such errors to ENOTCONN
from RPC/RDMA to match sockets behavior.

Signed-off-by: Tom Talpey <talpey@netapp.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index d245c0b..94ecf1b 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -699,7 +699,7 @@ rpcrdma_conn_func(struct rpcrdma_ep *ep)
 			xprt_wake_pending_tasks(xprt, 0);
 	} else {
 		if (xprt_test_and_clear_connected(xprt))
-			xprt_wake_pending_tasks(xprt, ep->rep_connected);
+			xprt_wake_pending_tasks(xprt, -ENOTCONN);
 	}
 	spin_unlock_bh(&xprt->transport_lock);
 }

