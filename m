Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35928 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934322AbeB1Uap (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Feb 2018 15:30:45 -0500
Subject: [PATCH 4/8] xprtrdma: ->send_request returns -EAGAIN when there are
 no free MRs
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 28 Feb 2018 15:30:44 -0500
Message-ID: <20180228203043.25968.71704.stgit@manet.1015granger.net>
In-Reply-To: <20180228202916.25968.21750.stgit@manet.1015granger.net>
References: <20180228202916.25968.21750.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, when the MR free list is exhausted during marshaling, the
RPC/RDMA transport places the RPC task on the delayq, which forces a
wait for HZ >> 2 before the marshal and send is retried.

With this change, the transport now places such an RPC task on the
pending queue, and wakes it just as soon as more MRs have been
created. Creating more MRs typically takes less than a millisecond,
and this waking mechanism is less deadlock-prone.

Moreover, the waiting RPC task is holding the transport's write
lock, which blocks the transport from sending RPCs. Therefore faster
recovery from MR exhaustion is desirable.

This is the same mechanism that the TCP transport utilizes when
handling write buffer space exhaustion.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |    2 +-
 net/sunrpc/xprtrdma/frwr_ops.c  |    2 +-
 net/sunrpc/xprtrdma/rpc_rdma.c  |   30 +++++++++++++++++++++---------
 net/sunrpc/xprtrdma/transport.c |    3 ++-
 net/sunrpc/xprtrdma/verbs.c     |    3 ++-
 5 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index d5f95bb..629e539 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -191,7 +191,7 @@ enum {
 
 	mr = rpcrdma_mr_get(r_xprt);
 	if (!mr)
-		return ERR_PTR(-ENOBUFS);
+		return ERR_PTR(-EAGAIN);
 
 	pageoff = offset_in_page(seg1->mr_offset);
 	seg1->mr_offset -= pageoff;	/* start of page */
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 90f688f..e21781c 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -367,7 +367,7 @@
 			rpcrdma_mr_defer_recovery(mr);
 		mr = rpcrdma_mr_get(r_xprt);
 		if (!mr)
-			return ERR_PTR(-ENOBUFS);
+			return ERR_PTR(-EAGAIN);
 	} while (mr->frwr.fr_state != FRWR_IS_INVALID);
 	frwr = &mr->frwr;
 	frwr->fr_state = FRWR_IS_VALID;
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 4bc0f4d..e8adad3 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -365,7 +365,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
 						   false, &mr);
 		if (IS_ERR(seg))
-			return PTR_ERR(seg);
+			goto out_maperr;
 		rpcrdma_mr_push(mr, &req->rl_registered);
 
 		if (encode_read_segment(xdr, mr, pos) < 0)
@@ -377,6 +377,11 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	} while (nsegs);
 
 	return 0;
+
+out_maperr:
+	if (PTR_ERR(seg) == -EAGAIN)
+		xprt_wait_for_buffer_space(rqst->rq_task, NULL);
+	return PTR_ERR(seg);
 }
 
 /* Register and XDR encode the Write list. Supports encoding a list
@@ -423,7 +428,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
 						   true, &mr);
 		if (IS_ERR(seg))
-			return PTR_ERR(seg);
+			goto out_maperr;
 		rpcrdma_mr_push(mr, &req->rl_registered);
 
 		if (encode_rdma_segment(xdr, mr) < 0)
@@ -440,6 +445,11 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	*segcount = cpu_to_be32(nchunks);
 
 	return 0;
+
+out_maperr:
+	if (PTR_ERR(seg) == -EAGAIN)
+		xprt_wait_for_buffer_space(rqst->rq_task, NULL);
+	return PTR_ERR(seg);
 }
 
 /* Register and XDR encode the Reply chunk. Supports encoding an array
@@ -481,7 +491,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
 						   true, &mr);
 		if (IS_ERR(seg))
-			return PTR_ERR(seg);
+			goto out_maperr;
 		rpcrdma_mr_push(mr, &req->rl_registered);
 
 		if (encode_rdma_segment(xdr, mr) < 0)
@@ -498,6 +508,11 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	*segcount = cpu_to_be32(nchunks);
 
 	return 0;
+
+out_maperr:
+	if (PTR_ERR(seg) == -EAGAIN)
+		xprt_wait_for_buffer_space(rqst->rq_task, NULL);
+	return PTR_ERR(seg);
 }
 
 /**
@@ -724,8 +739,8 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
  * Returns:
  *	%0 if the RPC was sent successfully,
  *	%-ENOTCONN if the connection was lost,
- *	%-EAGAIN if not enough pages are available for on-demand reply buffer,
- *	%-ENOBUFS if no MRs are available to register chunks,
+ *	%-EAGAIN if the caller should call again with the same arguments,
+ *	%-ENOBUFS if the caller should call again after a delay,
  *	%-EMSGSIZE if the transport header is too small,
  *	%-EIO if a permanent problem occurred while marshaling.
  */
@@ -868,10 +883,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	return 0;
 
 out_err:
-	if (ret != -ENOBUFS) {
-		pr_err("rpcrdma: header marshaling failed (%d)\n", ret);
-		r_xprt->rx_stats.failed_marshal_count++;
-	}
+	r_xprt->rx_stats.failed_marshal_count++;
 	return ret;
 }
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 47b4604..0819689 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -689,7 +689,8 @@
  * Returns:
  *	%0 if the RPC message has been sent
  *	%-ENOTCONN if the caller should reconnect and call again
- *	%-ENOBUFS if the caller should call again later
+ *	%-EAGAIN if the caller should call again
+ *	%-ENOBUFS if the caller should call again after a delay
  *	%-EIO if a permanent error occurred and the request was not
  *		sent. Do not try to send this message again.
  */
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 520e7e4..d36c18f 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1048,8 +1048,9 @@ void rpcrdma_sendctx_put_locked(struct rpcrdma_sendctx *sc)
 	list_splice(&all, &buf->rb_all);
 	r_xprt->rx_stats.mrs_allocated += count;
 	spin_unlock(&buf->rb_mrlock);
-
 	trace_xprtrdma_createmrs(r_xprt, count);
+
+	xprt_write_space(&r_xprt->rx_xprt);
 }
 
 static void

