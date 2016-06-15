Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34205 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018AbcFODQ4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 23:16:56 -0400
Subject: [PATCH v2 12/24] xprtrdma: Honor ->send_request API contract
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 14 Jun 2016 23:16:54 -0400
Message-ID: <20160615031654.14794.1227.stgit@manet.1015granger.net>
In-Reply-To: <20160615030626.14794.43805.stgit@manet.1015granger.net>
References: <20160615030626.14794.43805.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit c93c62231cf5 ("xprtrdma: Disconnect on registration failure")
added a disconnect for some RPC marshaling failures. This is needed
only in a handful of cases, but it was triggering for simple stuff
like temporary resource shortages. Try to straighten this out.

Fix up the lower layers so they don't return -ENOMEM or other error
codes that the RPC client's FSM doesn't explicitly recognize.

Also fix up the places in the send_request path that do want a
disconnect. For example, when ib_post_send or ib_post_recv fail,
this is a sign that there is a send or receive queue resource
miscalculation. That should be rare, and is a sign of a software
bug. But xprtrdma can recover: disconnect to reset the transport and
start over.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |    6 +++---
 net/sunrpc/xprtrdma/frwr_ops.c  |   13 +++++++------
 net/sunrpc/xprtrdma/rpc_rdma.c  |    2 +-
 net/sunrpc/xprtrdma/transport.c |   20 +++++++++++++++-----
 net/sunrpc/xprtrdma/verbs.c     |   22 +++++++++++++---------
 5 files changed, 39 insertions(+), 24 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index eb42d7f..1ee2b10 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -209,7 +209,7 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 		rpcrdma_defer_mr_recovery(mw);
 	mw = rpcrdma_get_mw(r_xprt);
 	if (!mw)
-		return -ENOMEM;
+		return -ENOBUFS;
 
 	pageoff = offset_in_page(seg1->mr_offset);
 	seg1->mr_offset -= pageoff;	/* start of page */
@@ -259,14 +259,14 @@ out_dmamap_err:
 	pr_err("rpcrdma: failed to dma map sg %p sg_nents %u\n",
 	       mw->mw_sg, mw->mw_nents);
 	rpcrdma_defer_mr_recovery(mw);
-	return -ENOMEM;
+	return -EIO;
 
 out_maperr:
 	pr_err("rpcrdma: ib_map_phys_fmr %u@0x%llx+%i (%d) status %i\n",
 	       len, (unsigned long long)dma_pages[0],
 	       pageoff, mw->mw_nents, rc);
 	rpcrdma_defer_mr_recovery(mw);
-	return rc;
+	return -EIO;
 }
 
 /* Invalidate all memory regions that were registered for "req".
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index c9ead2b..e77e40a 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -365,7 +365,7 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 			rpcrdma_defer_mr_recovery(mw);
 		mw = rpcrdma_get_mw(r_xprt);
 		if (!mw)
-			return -ENOMEM;
+			return -ENOBUFS;
 	} while (mw->frmr.fr_state != FRMR_IS_INVALID);
 	frmr = &mw->frmr;
 	frmr->fr_state = FRMR_IS_VALID;
@@ -439,18 +439,18 @@ out_dmamap_err:
 	pr_err("rpcrdma: failed to dma map sg %p sg_nents %u\n",
 	       mw->mw_sg, mw->mw_nents);
 	rpcrdma_defer_mr_recovery(mw);
-	return -ENOMEM;
+	return -EIO;
 
 out_mapmr_err:
 	pr_err("rpcrdma: failed to map mr %p (%u/%u)\n",
 	       frmr->fr_mr, n, mw->mw_nents);
-	rc = n < 0 ? n : -EIO;
 	rpcrdma_defer_mr_recovery(mw);
-	return rc;
+	return -EIO;
 
 out_senderr:
+	pr_err("rpcrdma: FRMR registration ib_post_send returned %i\n", rc);
 	rpcrdma_defer_mr_recovery(mw);
-	return rc;
+	return -ENOTCONN;
 }
 
 static struct ib_send_wr *
@@ -552,7 +552,8 @@ unmap:
 	return;
 
 reset_mrs:
-	pr_warn("%s: ib_post_send failed %i\n", __func__, rc);
+	pr_err("rpcrdma: FRMR invalidate ib_post_send returned %i\n", rc);
+	rdma_disconnect(ia->ri_id);
 
 	/* Find and reset the MRs in the LOCAL_INV WRs that did not
 	 * get posted. This is synchronous, and slow.
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 35a8109..77e002f 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -251,7 +251,7 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
 			/* alloc the pagelist for receiving buffer */
 			ppages[p] = alloc_page(GFP_ATOMIC);
 			if (!ppages[p])
-				return -ENOMEM;
+				return -EAGAIN;
 		}
 		seg[n].mr_page = ppages[p];
 		seg[n].mr_offset = (void *)(unsigned long) page_base;
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 4c8e7f1..be4dd2c 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -558,7 +558,6 @@ out_sendbuf:
 
 out_fail:
 	rpcrdma_buffer_put(req);
-	r_xprt->rx_stats.failed_marshal_count++;
 	return NULL;
 }
 
@@ -590,8 +589,19 @@ xprt_rdma_free(void *buffer)
 	rpcrdma_buffer_put(req);
 }
 
-/*
+/**
+ * xprt_rdma_send_request - marshal and send an RPC request
+ * @task: RPC task with an RPC message in rq_snd_buf
+ *
+ * Return values:
+ *        0:	The request has been sent
+ * ENOTCONN:	Caller needs to invoke connect logic then call again
+ *  ENOBUFS:	Call again later to send the request
+ *      EIO:	A permanent error occurred. The request was not sent,
+ *		and don't try it again
+ *
  * send_request invokes the meat of RPC RDMA. It must do the following:
+ *
  *  1.  Marshal the RPC request into an RPC RDMA request, which means
  *	putting a header in front of data, and creating IOVs for RDMA
  *	from those in the request.
@@ -600,7 +610,6 @@ xprt_rdma_free(void *buffer)
  *	the request (rpcrdma_ep_post).
  *  4.  No partial sends are possible in the RPC-RDMA protocol (as in UDP).
  */
-
 static int
 xprt_rdma_send_request(struct rpc_task *task)
 {
@@ -630,11 +639,12 @@ xprt_rdma_send_request(struct rpc_task *task)
 	return 0;
 
 failed_marshal:
-	r_xprt->rx_stats.failed_marshal_count++;
 	dprintk("RPC:       %s: rpcrdma_marshal_req failed, status %i\n",
 		__func__, rc);
 	if (rc == -EIO)
-		return -EIO;
+		r_xprt->rx_stats.failed_marshal_count++;
+	if (rc != -ENOTCONN)
+		return rc;
 drop_connection:
 	xprt_disconnect_done(xprt);
 	return -ENOTCONN;	/* implies disconnect */
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 8b8abd6..35f2176 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1166,7 +1166,7 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
 	if (rep) {
 		rc = rpcrdma_ep_post_recv(ia, ep, rep);
 		if (rc)
-			goto out;
+			return rc;
 		req->rl_reply = NULL;
 	}
 
@@ -1191,10 +1191,12 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
 
 	rc = ib_post_send(ia->ri_id->qp, &send_wr, &send_wr_fail);
 	if (rc)
-		dprintk("RPC:       %s: ib_post_send returned %i\n", __func__,
-			rc);
-out:
-	return rc;
+		goto out_postsend_err;
+	return 0;
+
+out_postsend_err:
+	pr_err("rpcrdma: RDMA Send ib_post_send returned %i\n", rc);
+	return -ENOTCONN;
 }
 
 /*
@@ -1219,11 +1221,13 @@ rpcrdma_ep_post_recv(struct rpcrdma_ia *ia,
 				   DMA_BIDIRECTIONAL);
 
 	rc = ib_post_recv(ia->ri_id->qp, &recv_wr, &recv_wr_fail);
-
 	if (rc)
-		dprintk("RPC:       %s: ib_post_recv returned %i\n", __func__,
-			rc);
-	return rc;
+		goto out_postrecv;
+	return 0;
+
+out_postrecv:
+	pr_err("rpcrdma: ib_post_recv returned %i\n", rc);
+	return -ENOTCONN;
 }
 
 /**

