Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:35494 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774AbcD1PPx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Apr 2016 11:15:53 -0400
Subject: [PATCH 10/10] svcrdma: Switch CQs from IB_POLL_SOFTIRQ to
 IB_POLL_WORKQUEUE
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 28 Apr 2016 11:15:50 -0400
Message-ID: <20160428151550.13068.24199.stgit@klimt.1015granger.net>
In-Reply-To: <20160428150915.13068.94602.stgit@klimt.1015granger.net>
References: <20160428150915.13068.94602.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Spread NFSD completion handling across CPUs, and replace
BH-friendly spin locking with plain spin locks.

iozone -i0 -i1 -s128m -y1k -az -I -N

Microseconds/op Mode. Output is in microseconds per operation.

Before:
              KB  reclen   write rewrite    read    reread
          131072       1      51      51       43       43
          131072       2      53      52       42       43
          131072       4      53      52       43       43
          131072       8      55      54       44       44
          131072      16      62      59       49       47
          131072      32      72      69       53       53
          131072      64      92      87       66       66
          131072     128     144     130       94       93
          131072     256     225     216      146      145
          131072     512     485     474      251      251
          131072    1024     573     540      514      512
          131072    2048    1007     941      624      618
          131072    4096    1672    1699      976      969
          131072    8192    3179    3158     1660     1649
          131072   16384    5836    5659     3062     3041

After:
              KB  reclen   write rewrite    read    reread
          131072       1      54      54       43       43
          131072       2      55      55       43       43
          131072       4      56      57       44       45
          131072       8      59      58       45       45
          131072      16      64      62       47       47
          131072      32      76      74       54       54
          131072      64      96      91       67       66
          131072     128     148     133       97       97
          131072     256     229     227      148      147
          131072     512     488     445      252      255
          131072    1024     582     534      511      540
          131072    2048     998     988      614      620
          131072    4096    1685    1679      946      965
          131072    8192    3113    3048     1650     1644
          131072   16384    6010    5745     3046     3053

NFS READ is roughly the same, NFS WRITE is marginally worse.

Before:
GETATTR:
	242 ops (0%)
	avg bytes sent per op: 127
	avg bytes received per op: 112
	backlog wait: 0.000000
 	RTT: 0.041322
 	total execute time: 0.049587 (milliseconds)

After:
GETATTR:
	242 ops (0%)
	avg bytes sent per op: 127
	avg bytes received per op: 112
	backlog wait: 0.000000
 	RTT: 0.045455
 	total execute time: 0.053719 (milliseconds)

Small op latency increased by 4usec.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    6 +++---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   26 +++++++++++++-------------
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 41adbe7..6159ae6 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -586,13 +586,13 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 
 	dprintk("svcrdma: rqstp=%p\n", rqstp);
 
-	spin_lock_bh(&rdma_xprt->sc_rq_dto_lock);
+	spin_lock(&rdma_xprt->sc_rq_dto_lock);
 	if (!list_empty(&rdma_xprt->sc_read_complete_q)) {
 		ctxt = list_entry(rdma_xprt->sc_read_complete_q.next,
 				  struct svc_rdma_op_ctxt,
 				  dto_q);
 		list_del_init(&ctxt->dto_q);
-		spin_unlock_bh(&rdma_xprt->sc_rq_dto_lock);
+		spin_unlock(&rdma_xprt->sc_rq_dto_lock);
 		rdma_read_complete(rqstp, ctxt);
 		goto complete;
 	} else if (!list_empty(&rdma_xprt->sc_rq_dto_q)) {
@@ -605,7 +605,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 		clear_bit(XPT_DATA, &xprt->xpt_flags);
 		ctxt = NULL;
 	}
-	spin_unlock_bh(&rdma_xprt->sc_rq_dto_lock);
+	spin_unlock(&rdma_xprt->sc_rq_dto_lock);
 	if (!ctxt) {
 		/* This is the EAGAIN path. The svc_recv routine will
 		 * return -EAGAIN, the nfsd thread will go to call into
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index dd94401..8850a5f 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -186,7 +186,7 @@ struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
 {
 	struct svc_rdma_op_ctxt *ctxt = NULL;
 
-	spin_lock_bh(&xprt->sc_ctxt_lock);
+	spin_lock(&xprt->sc_ctxt_lock);
 	xprt->sc_ctxt_used++;
 	if (list_empty(&xprt->sc_ctxts))
 		goto out_empty;
@@ -194,7 +194,7 @@ struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
 	ctxt = list_first_entry(&xprt->sc_ctxts,
 				struct svc_rdma_op_ctxt, free);
 	list_del_init(&ctxt->free);
-	spin_unlock_bh(&xprt->sc_ctxt_lock);
+	spin_unlock(&xprt->sc_ctxt_lock);
 
 out:
 	ctxt->count = 0;
@@ -205,15 +205,15 @@ out_empty:
 	/* Either pre-allocation missed the mark, or send
 	 * queue accounting is broken.
 	 */
-	spin_unlock_bh(&xprt->sc_ctxt_lock);
+	spin_unlock(&xprt->sc_ctxt_lock);
 
 	ctxt = alloc_ctxt(xprt, GFP_NOIO);
 	if (ctxt)
 		goto out;
 
-	spin_lock_bh(&xprt->sc_ctxt_lock);
+	spin_lock(&xprt->sc_ctxt_lock);
 	xprt->sc_ctxt_used--;
-	spin_unlock_bh(&xprt->sc_ctxt_lock);
+	spin_unlock(&xprt->sc_ctxt_lock);
 	WARN_ONCE(1, "svcrdma: empty RDMA ctxt list?\n");
 	return NULL;
 }
@@ -248,10 +248,10 @@ void svc_rdma_put_context(struct svc_rdma_op_ctxt *ctxt, int free_pages)
 		for (i = 0; i < ctxt->count; i++)
 			put_page(ctxt->pages[i]);
 
-	spin_lock_bh(&xprt->sc_ctxt_lock);
+	spin_lock(&xprt->sc_ctxt_lock);
 	xprt->sc_ctxt_used--;
 	list_add(&ctxt->free, &xprt->sc_ctxts);
-	spin_unlock_bh(&xprt->sc_ctxt_lock);
+	spin_unlock(&xprt->sc_ctxt_lock);
 }
 
 static void svc_rdma_destroy_ctxts(struct svcxprt_rdma *xprt)
@@ -897,14 +897,14 @@ struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *rdma)
 {
 	struct svc_rdma_fastreg_mr *frmr = NULL;
 
-	spin_lock_bh(&rdma->sc_frmr_q_lock);
+	spin_lock(&rdma->sc_frmr_q_lock);
 	if (!list_empty(&rdma->sc_frmr_q)) {
 		frmr = list_entry(rdma->sc_frmr_q.next,
 				  struct svc_rdma_fastreg_mr, frmr_list);
 		list_del_init(&frmr->frmr_list);
 		frmr->sg_nents = 0;
 	}
-	spin_unlock_bh(&rdma->sc_frmr_q_lock);
+	spin_unlock(&rdma->sc_frmr_q_lock);
 	if (frmr)
 		return frmr;
 
@@ -918,10 +918,10 @@ void svc_rdma_put_frmr(struct svcxprt_rdma *rdma,
 		ib_dma_unmap_sg(rdma->sc_cm_id->device,
 				frmr->sg, frmr->sg_nents, frmr->direction);
 		atomic_dec(&rdma->sc_dma_used);
-		spin_lock_bh(&rdma->sc_frmr_q_lock);
+		spin_lock(&rdma->sc_frmr_q_lock);
 		WARN_ON_ONCE(!list_empty(&frmr->frmr_list));
 		list_add(&frmr->frmr_list, &rdma->sc_frmr_q);
-		spin_unlock_bh(&rdma->sc_frmr_q_lock);
+		spin_unlock(&rdma->sc_frmr_q_lock);
 	}
 }
 
@@ -999,13 +999,13 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 		goto errout;
 	}
 	newxprt->sc_sq_cq = ib_alloc_cq(dev, newxprt, newxprt->sc_sq_depth,
-					0, IB_POLL_SOFTIRQ);
+					0, IB_POLL_WORKQUEUE);
 	if (IS_ERR(newxprt->sc_sq_cq)) {
 		dprintk("svcrdma: error creating SQ CQ for connect request\n");
 		goto errout;
 	}
 	newxprt->sc_rq_cq = ib_alloc_cq(dev, newxprt, newxprt->sc_rq_depth,
-					0, IB_POLL_SOFTIRQ);
+					0, IB_POLL_WORKQUEUE);
 	if (IS_ERR(newxprt->sc_rq_cq)) {
 		dprintk("svcrdma: error creating RQ CQ for connect request\n");
 		goto errout;

