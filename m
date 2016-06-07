Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33919 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755967AbcFGTre (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 15:47:34 -0400
Subject: [PATCH v1 09/20] xprtrdma: Limit the number of rpcrdma_mws
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 07 Jun 2016 15:47:32 -0400
Message-ID: <20160607194732.18401.71941.stgit@manet.1015granger.net>
In-Reply-To: <20160607194001.18401.88592.stgit@manet.1015granger.net>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The fixed part of an R_key is 24 bits, but the variant part is only
8 bits, allowing 256 unique R_keys concurrenly in flight on one QP.

Thus an rpcrdma_xprt cannot use more than 256 rpcrdma_mws at a time.

Capping the number of rpcrdma_mws should prevent ro_map from
re-using an R_key, which could change the MR co-ordinates or access
settings while an RPC is still in progress. It also reduces the
number of pre-allocated FRMRs per transport, allowing more
transports per device.

To get more R_keys in flight at once, additional QPs will be
necessary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |    6 +-----
 net/sunrpc/xprtrdma/frwr_ops.c  |    6 +-----
 net/sunrpc/xprtrdma/xprt_rdma.h |    8 ++++++++
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 4632d25..33c4661 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -127,12 +127,8 @@ fmr_op_init(struct rpcrdma_xprt *r_xprt)
 	struct rpcrdma_mw *r;
 	int i, rc;
 
-	i = max_t(int, RPCRDMA_MAX_DATA_SEGS / RPCRDMA_MAX_FMR_SGES, 1);
-	i += 2;				/* head + tail */
-	i *= buf->rb_max_requests;	/* one set for each RPC slot */
-	dprintk("RPC:       %s: initalizing %d FMRs\n", __func__, i);
-
 	rc = -ENOMEM;
+	i = RPCRDMA_RKEYS_PER_QP;
 	while (i--) {
 		r = kzalloc(sizeof(*r), GFP_KERNEL);
 		if (!r)
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index e0f610c..04b8ab2e 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -317,11 +317,7 @@ frwr_op_init(struct rpcrdma_xprt *r_xprt)
 	struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
 	int i;
 
-	i = max_t(int, RPCRDMA_MAX_DATA_SEGS / depth, 1);
-	i += 2;				/* head + tail */
-	i *= buf->rb_max_requests;	/* one set for each RPC slot */
-	dprintk("RPC:       %s: initalizing %d FRMRs\n", __func__, i);
-
+	i = RPCRDMA_RKEYS_PER_QP;
 	while (i--) {
 		struct rpcrdma_mw *r;
 		int rc;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index ea8d4f8..8e53057 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -164,6 +164,14 @@ rdmab_to_msg(struct rpcrdma_regbuf *rb)
  */
 #define RPCRDMA_MAX_HDR_SEGS	(8)
 
+/* An R_key is 32 bits wide. 24 bits are fixed per QP, and
+ * 8 bits vary for each registered MR. Thus only 256 R_keys
+ * can be registered at one time per QP.
+ */
+enum {
+	RPCRDMA_RKEYS_PER_QP	= 256
+};
+
 /*
  * struct rpcrdma_rep -- this structure encapsulates state required to recv
  * and complete a reply, asychronously. It needs several pieces of

