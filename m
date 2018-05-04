Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35749 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbeEDTf1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 15:35:27 -0400
Subject: [PATCH v1 11/19] xprtrdma: Remove rpcrdma_ep_{post_recv,
 post_extra_recv}
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 04 May 2018 15:35:25 -0400
Message-ID: <20180504193525.31688.6670.stgit@manet.1015granger.net>
In-Reply-To: <20180504192748.31688.3678.stgit@manet.1015granger.net>
References: <20180504192748.31688.3678.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: These functions are no longer used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h  |    2 -
 net/sunrpc/xprtrdma/verbs.c     |   59 ---------------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    3 --
 3 files changed, 64 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index ad27e19..ac82849 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -879,8 +879,6 @@
 	)
 );
 
-DEFINE_RXPRT_EVENT(xprtrdma_noreps);
-
 /**
  ** Callback events
  **/
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 2a38301..9c35540 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1520,65 +1520,6 @@ struct rpcrdma_regbuf *
 	return 0;
 }
 
-int
-rpcrdma_ep_post_recv(struct rpcrdma_ia *ia,
-		     struct rpcrdma_rep *rep)
-{
-	struct ib_recv_wr *recv_wr_fail;
-	int rc;
-
-	if (!rpcrdma_dma_map_regbuf(ia, rep->rr_rdmabuf))
-		goto out_map;
-	rc = ib_post_recv(ia->ri_id->qp, &rep->rr_recv_wr, &recv_wr_fail);
-	trace_xprtrdma_post_recv(rep->rr_recv_wr.wr_cqe);
-	if (rc)
-		return -ENOTCONN;
-	return 0;
-
-out_map:
-	pr_err("rpcrdma: failed to DMA map the Receive buffer\n");
-	return -EIO;
-}
-
-/**
- * rpcrdma_ep_post_extra_recv - Post buffers for incoming backchannel requests
- * @r_xprt: transport associated with these backchannel resources
- * @count: minimum number of incoming requests expected
- *
- * Returns zero if all requested buffers were posted, or a negative errno.
- */
-int
-rpcrdma_ep_post_extra_recv(struct rpcrdma_xprt *r_xprt, unsigned int count)
-{
-	struct rpcrdma_buffer *buffers = &r_xprt->rx_buf;
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-	struct rpcrdma_rep *rep;
-	int rc;
-
-	while (count--) {
-		spin_lock(&buffers->rb_lock);
-		if (list_empty(&buffers->rb_recv_bufs))
-			goto out_reqbuf;
-		rep = rpcrdma_buffer_get_rep_locked(buffers);
-		spin_unlock(&buffers->rb_lock);
-
-		rc = rpcrdma_ep_post_recv(ia, rep);
-		if (rc)
-			goto out_rc;
-	}
-
-	return 0;
-
-out_reqbuf:
-	spin_unlock(&buffers->rb_lock);
-	trace_xprtrdma_noreps(r_xprt);
-	return -ENOMEM;
-
-out_rc:
-	rpcrdma_recv_buffer_put(rep);
-	return rc;
-}
-
 /**
  * rpcrdma_post_recvs - Maybe post some Receive buffers
  * @r_xprt: controlling transport
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index a6d0d6e..507b515 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -558,7 +558,6 @@ int rpcrdma_ep_create(struct rpcrdma_ep *, struct rpcrdma_ia *,
 
 int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
 				struct rpcrdma_req *);
-int rpcrdma_ep_post_recv(struct rpcrdma_ia *, struct rpcrdma_rep *);
 void rpcrdma_post_recvs(struct rpcrdma_xprt *r_xprt, bool temp);
 
 /*
@@ -599,8 +598,6 @@ struct rpcrdma_regbuf *rpcrdma_alloc_regbuf(size_t, enum dma_data_direction,
 	return __rpcrdma_dma_map_regbuf(ia, rb);
 }
 
-int rpcrdma_ep_post_extra_recv(struct rpcrdma_xprt *, unsigned int);
-
 int rpcrdma_alloc_wq(void);
 void rpcrdma_destroy_wq(void);
 

