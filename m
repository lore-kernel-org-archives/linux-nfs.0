Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f45.google.com ([209.85.220.45]:39872 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbaG1P3q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jul 2014 11:29:46 -0400
Date: Mon, 28 Jul 2014 20:59:38 +0530
From: Himangi Saraogi <himangi774@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: julia.lawall@lip6.fr
Subject: [PATCH] svcrdma: delete double assignment
Message-ID: <20140728152938.GA3040@himangi-Dell>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Delete successive assignments to the same location.

A simplified version of Coccinelle semantic match that finds this problem is as
follows:

// <smpl>
@@
expression i;
@@

*i = ...;
 i = ...;
// </smpl>

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
---
Should the assignment be the maximum of the 2 values?
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 06a5d92..8976529 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -956,7 +956,6 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 			dprintk("svcrdma: failed to create QP, ret=%d\n", ret);
 			goto errout;
 		}
-		newxprt->sc_max_sge = qp_attr.cap.max_send_sge;
 		newxprt->sc_max_sge = qp_attr.cap.max_recv_sge;
 		newxprt->sc_sq_depth = qp_attr.cap.max_send_wr;
 		newxprt->sc_max_requests = qp_attr.cap.max_recv_wr;
-- 
1.9.1

