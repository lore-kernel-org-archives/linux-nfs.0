Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33240 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936679AbdAGRPf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2017 12:15:35 -0500
Subject: [PATCH v1 02/22] svcrdma: Replace RPCRDMA_SQ_DEPTH_MULT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 07 Jan 2017 12:15:33 -0500
Message-ID: <20170107171533.14126.86910.stgit@klimt.1015granger.net>
In-Reply-To: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The SQ depth is currently computed using a fixed multipler. For
some configurations this underestimates the needed number of SQEs
and CQEs. Usually that means the server has to pause on occasion
for SQEs to become available before it can send RDMA Reads or RPC
Replies.

There might be some cases where the new estimator generates a SQ
depth that is larger than the local HCA can support. If that is a
frequent problem, then a mechanism can be introduced that
automatically reduces the number of RPC-over-RDMA credits per
connection.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |    1 -
 net/sunrpc/xprtrdma/svc_rdma.c           |    2 -
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   44 +++++++++++++++++++++++++++++-
 3 files changed, 43 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 551c518..cb3d87a 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -182,7 +182,6 @@ struct svcxprt_rdma {
 /* The default ORD value is based on two outstanding full-size writes with a
  * page size of 4k, or 32k * 2 ops / 4k = 16 outstanding RDMA_READ.  */
 #define RPCRDMA_ORD             (64/4)
-#define RPCRDMA_SQ_DEPTH_MULT   8
 #define RPCRDMA_MAX_REQUESTS    32
 #define RPCRDMA_MAX_REQ_SIZE    4096
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index c846ca9..9124441 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -247,8 +247,6 @@ int svc_rdma_init(void)
 	dprintk("SVCRDMA Module Init, register RPC RDMA transport\n");
 	dprintk("\tsvcrdma_ord      : %d\n", svcrdma_ord);
 	dprintk("\tmax_requests     : %u\n", svcrdma_max_requests);
-	dprintk("\tsq_depth         : %u\n",
-		svcrdma_max_requests * RPCRDMA_SQ_DEPTH_MULT);
 	dprintk("\tmax_bc_requests  : %u\n", svcrdma_max_bc_requests);
 	dprintk("\tmax_inline       : %d\n", svcrdma_max_req_size);
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index ca2799a..f246197 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -950,6 +950,48 @@ void svc_rdma_put_frmr(struct svcxprt_rdma *rdma,
 	}
 }
 
+static unsigned int svc_rdma_read_sqes_per_credit(struct svcxprt_rdma *newxprt)
+{
+	struct ib_device_attr *attrs = &newxprt->sc_cm_id->device->attrs;
+
+	if (!(attrs->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS))
+		return DIV_ROUND_UP(RPCSVC_MAXPAGES, newxprt->sc_max_sge_rd);
+
+	/* FRWR: reg, read, inv */
+	return DIV_ROUND_UP(RPCSVC_MAXPAGES,
+			    attrs->max_fast_reg_page_list_len) * 3;
+}
+
+static unsigned int svc_rdma_write_sqes_per_credit(struct svcxprt_rdma *newxprt)
+{
+	return DIV_ROUND_UP(RPCSVC_MAXPAGES, newxprt->sc_max_sge);
+}
+
+static unsigned int svc_rdma_sq_depth(struct svcxprt_rdma *newxprt)
+{
+	unsigned int sqes_per_credit;
+
+	/* Estimate SQEs per credit assuming a full Read chunk payload
+	 * and a full Write chunk payload (possible with krb5i/p). Each
+	 * credit will consume Read WRs then Write WRs, serially, so
+	 * we need just the larger of the two, not the sum.
+	 *
+	 * This is not an upper bound. Clients can break chunks into
+	 * arbitrarily many segments. However, if more SQEs are needed
+	 * then are available, the server has Send Queue accounting to
+	 * wait until enough SQEs are ready. But we want that waiting
+	 * to be very rare.
+	 */
+	sqes_per_credit = max_t(unsigned int,
+				svc_rdma_read_sqes_per_credit(newxprt),
+				svc_rdma_write_sqes_per_credit(newxprt));
+
+	/* RDMA Sends per credit */
+	sqes_per_credit += 1;
+
+	return sqes_per_credit * newxprt->sc_rq_depth;
+}
+
 /*
  * This is the xpo_recvfrom function for listening endpoints. Its
  * purpose is to accept incoming connections. The CMA callback handler
@@ -1006,7 +1048,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 					    svcrdma_max_bc_requests);
 	newxprt->sc_rq_depth = newxprt->sc_max_requests +
 			       newxprt->sc_max_bc_requests;
-	newxprt->sc_sq_depth = RPCRDMA_SQ_DEPTH_MULT * newxprt->sc_rq_depth;
+	newxprt->sc_sq_depth = svc_rdma_sq_depth(newxprt);
 	atomic_set(&newxprt->sc_sq_avail, newxprt->sc_sq_depth);
 
 	if (!svc_rdma_prealloc_ctxts(newxprt))

