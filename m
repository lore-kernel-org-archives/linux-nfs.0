From: Tom Talpey <talpey@netapp.com>
Subject: [PATCH 15/15] RPC/RDMA: optionally emit useful transport info upon
	connect/disconnect.
Date: Wed, 08 Oct 2008 11:49:26 -0400
Message-ID: <20081008154926.1336.69706.stgit@tmt3.nane.netapp.com>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:44118 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754461AbYJHQWN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 12:22:13 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m98FnQSp001616
	for <linux-nfs@vger.kernel.org>; Wed, 8 Oct 2008 11:49:26 -0400
In-Reply-To: <20081008154506.1336.59892.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Talpey <talpey@netapp.com>
---

 net/sunrpc/xprtrdma/transport.c |    2 +-
 net/sunrpc/xprtrdma/verbs.c     |   21 +++++++++++++++++++++
 2 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 278a544..b40d0b3 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -785,7 +785,7 @@ static void __exit xprt_rdma_cleanup(void)
 {
 	int rc;
 
-	dprintk("RPCRDMA Module Removed, deregister RPC RDMA transport\n");
+	dprintk(KERN_INFO "RPCRDMA Module Removed, deregister RPC RDMA transport\n");
 #ifdef RPC_DEBUG
 	if (sunrpc_table_header) {
 		unregister_sysctl_table(sunrpc_table_header);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 4076773..f9841b6 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -344,6 +344,27 @@ connected:
 		break;
 	}
 
+#ifdef RPC_DEBUG
+	if (connstate == 1) {
+		int ird = attr.max_dest_rd_atomic;
+		int tird = ep->rep_remote_cma.responder_resources;
+		printk(KERN_INFO "rpcrdma: connection to %u.%u.%u.%u:%u "
+			"on %s, memreg %d slots %d ird %d%s\n",
+			NIPQUAD(addr->sin_addr.s_addr),
+			ntohs(addr->sin_port),
+			ia->ri_id->device->name,
+			ia->ri_memreg_strategy,
+			xprt->rx_buf.rb_max_requests,
+			ird, ird < 4 && ird < tird / 2 ? " (low!)" : "");
+	} else if (connstate < 0) {
+		printk(KERN_INFO "rpcrdma: connection to %u.%u.%u.%u:%u "
+			"closed (%d)\n",
+			NIPQUAD(addr->sin_addr.s_addr),
+			ntohs(addr->sin_port),
+			connstate);
+	}
+#endif
+
 	return 0;
 }
 

