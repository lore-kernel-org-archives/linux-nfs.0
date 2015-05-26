Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:34802 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753625AbbEZPxg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 May 2015 11:53:36 -0400
Subject: [PATCH v3 15/17] xprtrdma: Reduce per-transport MR allocation
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 26 May 2015 11:53:33 -0400
Message-ID: <20150526155333.4542.16872.stgit@manet.1015granger.net>
In-Reply-To: <20150526153926.4542.96409.stgit@manet.1015granger.net>
References: <20150526153926.4542.96409.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reduce resource consumption per-transport to make way for increasing
the credit limit and maximum r/wsize. Pre-allocate fewer MRs.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Reviewed-by: Devesh Sharma <devesh.sharma@avagotech.com>
Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>
Reviewed-by: Doug Ledford <dledford@redhat.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c  |    6 ++++--
 net/sunrpc/xprtrdma/frwr_ops.c |    6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 4a53ad5..f1e8daf 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -69,8 +69,10 @@ fmr_op_init(struct rpcrdma_xprt *r_xprt)
 	INIT_LIST_HEAD(&buf->rb_mws);
 	INIT_LIST_HEAD(&buf->rb_all);
 
-	i = (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS;
-	dprintk("RPC:       %s: initializing %d FMRs\n", __func__, i);
+	i = max_t(int, RPCRDMA_MAX_DATA_SEGS / RPCRDMA_MAX_FMR_SGES, 1);
+	i += 2;				/* head + tail */
+	i *= buf->rb_max_requests;	/* one set for each RPC slot */
+	dprintk("RPC:       %s: initalizing %d FMRs\n", __func__, i);
 
 	rc = -ENOMEM;
 	while (i--) {
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 18b7305..661fbc1 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -270,8 +270,10 @@ frwr_op_init(struct rpcrdma_xprt *r_xprt)
 	INIT_LIST_HEAD(&buf->rb_mws);
 	INIT_LIST_HEAD(&buf->rb_all);
 
-	i = (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS;
-	dprintk("RPC:       %s: initializing %d FRMRs\n", __func__, i);
+	i = max_t(int, RPCRDMA_MAX_DATA_SEGS / depth, 1);
+	i += 2;				/* head + tail */
+	i *= buf->rb_max_requests;	/* one set for each RPC slot */
+	dprintk("RPC:       %s: initalizing %d FRMRs\n", __func__, i);
 
 	while (i--) {
 		struct rpcrdma_mw *r;

