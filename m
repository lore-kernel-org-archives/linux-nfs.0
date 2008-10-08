From: Tom Talpey <talpey@netapp.com>
Subject: [PATCH 10/15] RPC/RDMA: return a consistent error to mount,
	when connect fails.
Date: Wed, 08 Oct 2008 11:48:35 -0400
Message-ID: <20081008154835.1336.85484.stgit@tmt3.nane.netapp.com>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:44118 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754406AbYJHQWK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 12:22:10 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m98FmZ5n001545
	for <linux-nfs@vger.kernel.org>; Wed, 8 Oct 2008 11:48:35 -0400
In-Reply-To: <20081008154506.1336.59892.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The mount system call path does not expect such errors as ECONNREFUSED
to be returned from failed transport connection attempts, otherwise it
prints simply "internal error". Translate all such errors to ENOTCONN
from RPC/RDMA to match sockets behavior.

Signed-off-by: Tom Talpey <talpey@netapp.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c4b8011..11ea8da 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -700,7 +700,7 @@ rpcrdma_conn_func(struct rpcrdma_ep *ep)
 			xprt_wake_pending_tasks(xprt, 0);
 	} else {
 		if (xprt_test_and_clear_connected(xprt))
-			xprt_wake_pending_tasks(xprt, ep->rep_connected);
+			xprt_wake_pending_tasks(xprt, -ENOTCONN);
 	}
 	spin_unlock_bh(&xprt->transport_lock);
 }

