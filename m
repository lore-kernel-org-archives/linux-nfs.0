From: Tom Talpey <talpey@netapp.com>
Subject: [PATCH 14/15] RPC/RDMA: reformat a debug printk to keep lines
	together.
Date: Wed, 08 Oct 2008 11:49:16 -0400
Message-ID: <20081008154916.1336.12475.stgit@tmt3.nane.netapp.com>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:44118 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754397AbYJHQWJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 12:22:09 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m98FnGCK001602
	for <linux-nfs@vger.kernel.org>; Wed, 8 Oct 2008 11:49:16 -0400
In-Reply-To: <20081008154506.1336.59892.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The send marshaling code split a particular dprintk across two
lines, which makes it hard to extract from logfiles.

Signed-off-by: Tom Talpey <talpey@netapp.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 11ea8da..0dda063 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -513,8 +513,8 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	if (hdrlen == 0)
 		return -1;
 
-	dprintk("RPC:       %s: %s: hdrlen %zd rpclen %zd padlen %zd\n"
-		"                   headerp 0x%p base 0x%p lkey 0x%x\n",
+	dprintk("RPC:       %s: %s: hdrlen %zd rpclen %zd padlen %zd"
+		" headerp 0x%p base 0x%p lkey 0x%x\n",
 		__func__, transfertypes[wtype], hdrlen, rpclen, padlen,
 		headerp, base, req->rl_iov.lkey);
 

