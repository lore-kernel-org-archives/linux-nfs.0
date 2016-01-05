Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37210 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572AbcAEJuh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jan 2016 04:50:37 -0500
Date: Tue, 5 Jan 2016 12:50:19 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: [patch] svcrdma: signedness bug in xprt_rdma_bc_send_request()
Message-ID: <20160105095019.GA23619@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The "len" variable was unsigned so the error handling didn't work.  Also
"len" was a misleading name because it's either a negative error code or
it's zero.  It's never actually a length.  I've renamed it to "ret".

Fixes: eb57be60eca9 ('svcrdma: Add class for RDMA backwards direction transport')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 417cec1..deff06a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -240,7 +240,7 @@ xprt_rdma_bc_send_request(struct rpc_task *task)
 	struct rpc_rqst *rqst = task->tk_rqstp;
 	struct svc_xprt *sxprt = rqst->rq_xprt->bc_xprt;
 	struct svcxprt_rdma *rdma;
-	u32 len;
+	int ret;
 
 	dprintk("svcrdma: sending bc call with xid: %08x\n",
 		be32_to_cpu(rqst->rq_xid));
@@ -252,15 +252,15 @@ xprt_rdma_bc_send_request(struct rpc_task *task)
 		rpc_wake_up_queued_task(&sxprt->xpt_bc_pending, task);
 	}
 
-	len = -ENOTCONN;
+	ret = -ENOTCONN;
 	rdma = container_of(sxprt, struct svcxprt_rdma, sc_xprt);
 	if (!test_bit(XPT_DEAD, &sxprt->xpt_flags))
-		len = rpcrdma_bc_send_request(rdma, rqst);
+		ret = rpcrdma_bc_send_request(rdma, rqst);
 
 	mutex_unlock(&sxprt->xpt_mutex);
 
-	if (len < 0)
-		return len;
+	if (ret < 0)
+		return ret;
 	return 0;
 }
 
