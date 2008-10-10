From: Tom Talpey <talpey@netapp.com>
Subject: [PATCH 2/2] RPC/RDMA: ensure connection attempt is complete before
	signalling.
Date: Fri, 10 Oct 2008 11:32:45 -0400
Message-ID: <20081010153245.3983.56961.stgit@tmt3.nane.netapp.com>
References: <20081010152634.3983.91559.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:8706 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758413AbYJJPcq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Oct 2008 11:32:46 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m9AFWjJT004056
	for <linux-nfs@vger.kernel.org>; Fri, 10 Oct 2008 11:32:45 -0400
In-Reply-To: <20081010152634.3983.91559.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RPC/RDMA connection logic could return early from reconnection
attempts, leading to additional spurious retries.

Signed-off-by: Tom Talpey <talpey@netapp.com>
---

 net/sunrpc/xprtrdma/verbs.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 170e69c..a5fef5e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -804,9 +804,8 @@ rpcrdma_ep_connect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 	struct rdma_cm_id *id;
 	int rc = 0;
 	int retry_count = 0;
-	int reconnect = (ep->rep_connected != 0);
 
-	if (reconnect) {
+	if (ep->rep_connected != 0) {
 		struct rpcrdma_xprt *xprt;
 retry:
 		rc = rpcrdma_ep_disconnect(ep, ia);
@@ -871,9 +870,6 @@ if (strnicmp(ia->ri_id->device->dma_device->bus->name, "pci", 3) == 0) {
 		goto out;
 	}
 
-	if (reconnect)
-		return 0;
-
 	wait_event_interruptible(ep->rep_connect_wait, ep->rep_connected != 0);
 
 	/*

