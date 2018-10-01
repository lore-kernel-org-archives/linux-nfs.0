Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f171.google.com ([209.85.166.171]:53260 "EHLO
        mail-it1-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726418AbeJBBEg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 21:04:36 -0400
Subject: [PATCH v2 05/20] xprtrdma: Name MR trace events consistently
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:25:30 -0400
Message-ID: <20181001182530.18578.7209.stgit@manet.1015granger.net>
In-Reply-To: <20181001182005.18578.57544.stgit@manet.1015granger.net>
References: <20181001182005.18578.57544.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up the names of trace events related to MRs so that it's
easy to enable these with a glob.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h |   12 ++++++------
 net/sunrpc/xprtrdma/fmr_ops.c  |    6 +++---
 net/sunrpc/xprtrdma/frwr_ops.c |    8 ++++----
 net/sunrpc/xprtrdma/verbs.c    |    2 +-
 4 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 9906f4d..89e017b 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -263,7 +263,7 @@
 );
 
 #define DEFINE_MR_EVENT(name) \
-		DEFINE_EVENT(xprtrdma_mr, name, \
+		DEFINE_EVENT(xprtrdma_mr, xprtrdma_mr_##name, \
 				TP_PROTO( \
 					const struct rpcrdma_mr *mr \
 				), \
@@ -651,11 +651,11 @@
 DEFINE_FRWR_DONE_EVENT(xprtrdma_wc_li);
 DEFINE_FRWR_DONE_EVENT(xprtrdma_wc_li_wake);
 
-DEFINE_MR_EVENT(xprtrdma_localinv);
-DEFINE_MR_EVENT(xprtrdma_dma_map);
-DEFINE_MR_EVENT(xprtrdma_dma_unmap);
-DEFINE_MR_EVENT(xprtrdma_remoteinv);
-DEFINE_MR_EVENT(xprtrdma_mr_recycle);
+DEFINE_MR_EVENT(localinv);
+DEFINE_MR_EVENT(map);
+DEFINE_MR_EVENT(unmap);
+DEFINE_MR_EVENT(remoteinv);
+DEFINE_MR_EVENT(recycle);
 
 /**
  ** Reply events
diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index f1cf3a3..7f5632c 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -97,7 +97,7 @@ enum {
 
 	trace_xprtrdma_mr_recycle(mr);
 
-	trace_xprtrdma_dma_unmap(mr);
+	trace_xprtrdma_mr_unmap(mr);
 	ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
 			mr->mr_sg, mr->mr_nents, mr->mr_dir);
 
@@ -234,7 +234,7 @@ enum {
 				     mr->mr_sg, i, mr->mr_dir);
 	if (!mr->mr_nents)
 		goto out_dmamap_err;
-	trace_xprtrdma_dma_map(mr);
+	trace_xprtrdma_mr_map(mr);
 
 	for (i = 0, dma_pages = mr->fmr.fm_physaddrs; i < mr->mr_nents; i++)
 		dma_pages[i] = sg_dma_address(&mr->mr_sg[i]);
@@ -295,7 +295,7 @@ enum {
 	list_for_each_entry(mr, mrs, mr_list) {
 		dprintk("RPC:       %s: unmapping fmr %p\n",
 			__func__, &mr->fmr);
-		trace_xprtrdma_localinv(mr);
+		trace_xprtrdma_mr_localinv(mr);
 		list_add_tail(&mr->fmr.fm_mr->list, &unmap_list);
 	}
 	r_xprt->rx_stats.local_inv_needed++;
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 6594627..fc6378cc 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -123,7 +123,7 @@
 	trace_xprtrdma_mr_recycle(mr);
 
 	if (state != FRWR_FLUSHED_LI) {
-		trace_xprtrdma_dma_unmap(mr);
+		trace_xprtrdma_mr_unmap(mr);
 		ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
 				mr->mr_sg, mr->mr_nents, mr->mr_dir);
 	}
@@ -384,7 +384,7 @@
 	mr->mr_nents = ib_dma_map_sg(ia->ri_device, mr->mr_sg, i, mr->mr_dir);
 	if (!mr->mr_nents)
 		goto out_dmamap_err;
-	trace_xprtrdma_dma_map(mr);
+	trace_xprtrdma_mr_map(mr);
 
 	ibmr = frwr->fr_mr;
 	n = ib_map_mr_sg(ibmr, mr->mr_sg, mr->mr_nents, NULL, PAGE_SIZE);
@@ -466,7 +466,7 @@
 	list_for_each_entry(mr, mrs, mr_list)
 		if (mr->mr_handle == rep->rr_inv_rkey) {
 			list_del_init(&mr->mr_list);
-			trace_xprtrdma_remoteinv(mr);
+			trace_xprtrdma_mr_remoteinv(mr);
 			mr->frwr.fr_state = FRWR_IS_INVALID;
 			rpcrdma_mr_unmap_and_put(mr);
 			break;	/* only one invalidated MR per RPC */
@@ -503,7 +503,7 @@
 		mr->frwr.fr_state = FRWR_IS_INVALID;
 
 		frwr = &mr->frwr;
-		trace_xprtrdma_localinv(mr);
+		trace_xprtrdma_mr_localinv(mr);
 
 		frwr->fr_cqe.done = frwr_wc_localinv;
 		last = &frwr->fr_invwr;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 88fe75e..3a9a62d 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1288,7 +1288,7 @@ struct rpcrdma_mr *
 {
 	struct rpcrdma_xprt *r_xprt = mr->mr_xprt;
 
-	trace_xprtrdma_dma_unmap(mr);
+	trace_xprtrdma_mr_unmap(mr);
 	ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
 			mr->mr_sg, mr->mr_nents, mr->mr_dir);
 	__rpcrdma_mr_put(&r_xprt->rx_buf, mr);
