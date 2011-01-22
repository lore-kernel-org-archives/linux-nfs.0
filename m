Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:25788 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab1AVVju (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Jan 2011 16:39:50 -0500
Date: Sat, 22 Jan 2011 22:40:20 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
To: linux-nfs@vger.kernel.org
cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Pavel Emelyanov <xemul@openvz.org>,
        Chuck Lever <chuck.lever@oracle.com>, Tejun Heo <tj@kernel.org>,
        Tom Tucker <tom@opengridcomputing.com>,
        "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] SUNRPC: Remove resource leak in svc_rdma_send_error()
Message-ID: <alpine.LNX.2.00.1101222233260.7746@swampdragon.chaosbits.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We leak the memory allocated to 'ctxt' when we return after 
'ib_dma_mapping_error()' returns !=0.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 svc_rdma_transport.c |    1 +
 1 file changed, 1 insertion(+)

  compile tested only

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 9df1ead..1a10dcd 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1335,6 +1335,7 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 					    p, 0, length, DMA_FROM_DEVICE);
 	if (ib_dma_mapping_error(xprt->sc_cm_id->device, ctxt->sge[0].addr)) {
 		put_page(p);
+		svc_rdma_put_context(ctxt, 1);
 		return;
 	}
 	atomic_inc(&xprt->sc_dma_used);


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

