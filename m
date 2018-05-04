Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:43264 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751573AbeEDTeo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 15:34:44 -0400
Subject: [PATCH v1 03/19] xprtrdma: Create transport's CM ID in the correct
 network namespace
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 04 May 2018 15:34:42 -0400
Message-ID: <20180504193442.31688.58984.stgit@manet.1015granger.net>
In-Reply-To: <20180504192748.31688.3678.stgit@manet.1015granger.net>
References: <20180504192748.31688.3678.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set up RPC/RDMA transport in mount.nfs's network namespace. This
passes the correct namespace information to the RDMA core, similar
to how RPC sockets are created (see xs_create_sock).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 331d372..817a692 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -306,8 +306,8 @@
 	init_completion(&ia->ri_done);
 	init_completion(&ia->ri_remove_done);
 
-	id = rdma_create_id(&init_net, rpcrdma_conn_upcall, xprt, RDMA_PS_TCP,
-			    IB_QPT_RC);
+	id = rdma_create_id(xprt->rx_xprt.xprt_net, rpcrdma_conn_upcall,
+			    xprt, RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(id)) {
 		rc = PTR_ERR(id);
 		dprintk("RPC:       %s: rdma_create_id() failed %i\n",

