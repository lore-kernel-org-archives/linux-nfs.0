From: Tom Talpey <talpey@netapp.com>
Subject: [UPDATED PATCH 13/14] RPC/RDMA: reformat a debug printk to keep lines
	together.
Date: Thu, 09 Oct 2008 15:01:52 -0400
Message-ID: <20081009190152.13947.80004.stgit@tmt3.nane.netapp.com>
References: <20081009185643.13947.64733.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:15673 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757574AbYJITBx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2008 15:01:53 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m99J1qBp014204
	for <linux-nfs@vger.kernel.org>; Thu, 9 Oct 2008 15:01:52 -0400
In-Reply-To: <20081009185643.13947.64733.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The send marshaling code split a particular dprintk across two
lines, which makes it hard to extract from logfiles.

Signed-off-by: Tom Talpey <talpey@netapp.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 94ecf1b..15101f2 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -512,8 +512,8 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	if (hdrlen == 0)
 		return -1;
 
-	dprintk("RPC:       %s: %s: hdrlen %zd rpclen %zd padlen %zd\n"
-		"                   headerp 0x%p base 0x%p lkey 0x%x\n",
+	dprintk("RPC:       %s: %s: hdrlen %zd rpclen %zd padlen %zd"
+		" headerp 0x%p base 0x%p lkey 0x%x\n",
 		__func__, transfertypes[wtype], hdrlen, rpclen, padlen,
 		headerp, base, req->rl_iov.lkey);
 

