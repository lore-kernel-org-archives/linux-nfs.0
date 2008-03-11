From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH] SVCRDMA: Fix erroneous BUG_ON in send_write
Date: Tue, 11 Mar 2008 13:05:33 -0500
Message-ID: <1205258733.4795.8.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:59207 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753865AbYCKRzK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Mar 2008 13:55:10 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The assertion that checks for sge context overflow is
incorrectly hard-coded to 32. This causes a kernel bug
check when using big-data mounts. Changed the BUG_ON to
use the computed value RPCSVC_MAXPAGES.
    
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---
Please queue this for 2.6.25. This problem was found by a 2.6.25 user who sent me
the oops.

 net/sunrpc/xprtrdma/svc_rdma_sendto.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 0598b22..981f190 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -156,7 +156,7 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
 	struct svc_rdma_op_ctxt *ctxt;
 	int ret = 0;
 
-	BUG_ON(sge_count >= 32);
+	BUG_ON(sge_count > RPCSVC_MAXPAGES);
 	dprintk("svcrdma: RDMA_WRITE rmr=%x, to=%llx, xdr_off=%d, "
 		"write_len=%d, xdr_sge=%p, sge_count=%d\n",
 		rmr, (unsigned long long)to, xdr_off,

