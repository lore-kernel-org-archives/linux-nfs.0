Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:37374 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755056AbbK3WZH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Nov 2015 17:25:07 -0500
Subject: [PATCH v2 5/7] svcrdma: Add infrastructure to receive backwards
 direction RPC/RDMA replies
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 30 Nov 2015 17:25:05 -0500
Message-ID: <20151130222505.13029.578.stgit@klimt.1015granger.net>
In-Reply-To: <20151130222141.13029.98664.stgit@klimt.1015granger.net>
References: <20151130222141.13029.98664.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To support the NFSv4.1 backchannel on RDMA connections, add a
capability for receiving an RPC/RDMA reply on a connection
established by a client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c          |   72 +++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   52 ++++++++++++++++++++++
 net/sunrpc/xprtrdma/xprt_rdma.h         |    4 ++
 3 files changed, 128 insertions(+)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c10d969..e711126 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -946,3 +946,75 @@ repost:
 	if (rpcrdma_ep_post_recv(&r_xprt->rx_ia, &r_xprt->rx_ep, rep))
 		rpcrdma_recv_buffer_put(rep);
 }
+
+int
+rpcrdma_handle_bc_reply(struct rpc_xprt *xprt, struct rpcrdma_msg *rmsgp,
+			struct xdr_buf *rcvbuf)
+{
+	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+	struct kvec *dst, *src = &rcvbuf->head[0];
+	struct rpc_rqst *req;
+	unsigned long cwnd;
+	u32 credits;
+	size_t len;
+	__be32 xid;
+	__be32 *p;
+	int ret;
+
+	p = (__be32 *)src->iov_base;
+	len = src->iov_len;
+	xid = rmsgp->rm_xid;
+
+	dprintk("%s: xid=%08x, length=%zu\n",
+		__func__, be32_to_cpu(xid), len);
+	dprintk("%s: RPC/RDMA: %*ph\n",
+		__func__, (int)RPCRDMA_HDRLEN_MIN, rmsgp);
+	dprintk("%s:      RPC: %*ph\n",
+		__func__, (int)len, p);
+
+	ret = -EAGAIN;
+	if (src->iov_len < 24)
+		goto out_shortreply;
+
+	spin_lock_bh(&xprt->transport_lock);
+	req = xprt_lookup_rqst(xprt, xid);
+	if (!req)
+		goto out_notfound;
+
+	dst = &req->rq_private_buf.head[0];
+	memcpy(&req->rq_private_buf, &req->rq_rcv_buf, sizeof(struct xdr_buf));
+	if (dst->iov_len < len)
+		goto out_unlock;
+	memcpy(dst->iov_base, p, len);
+
+	credits = be32_to_cpu(rmsgp->rm_credit);
+	if (credits == 0)
+		credits = 1;	/* don't deadlock */
+	else if (credits > r_xprt->rx_buf.rb_bc_max_requests)
+		credits = r_xprt->rx_buf.rb_bc_max_requests;
+
+	cwnd = xprt->cwnd;
+	xprt->cwnd = credits << RPC_CWNDSHIFT;
+	if (xprt->cwnd > cwnd)
+		xprt_release_rqst_cong(req->rq_task);
+
+	ret = 0;
+	xprt_complete_rqst(req->rq_task, rcvbuf->len);
+	rcvbuf->len = 0;
+
+out_unlock:
+	spin_unlock_bh(&xprt->transport_lock);
+out:
+	return ret;
+
+out_shortreply:
+	dprintk("svcrdma: short bc reply: xprt=%p, len=%zu\n",
+		xprt, src->iov_len);
+	goto out;
+
+out_notfound:
+	dprintk("svcrdma: unrecognized bc reply: xprt=%p, xid=%08x\n",
+		xprt, be32_to_cpu(xid));
+
+	goto out_unlock;
+}
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index ff4f01e..be89aa0 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -47,6 +47,7 @@
 #include <rdma/ib_verbs.h>
 #include <rdma/rdma_cm.h>
 #include <linux/sunrpc/svc_rdma.h>
+#include "xprt_rdma.h"
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
@@ -567,6 +568,38 @@ static int rdma_read_complete(struct svc_rqst *rqstp,
 	return ret;
 }
 
+/* By convention, backchannel calls arrive via rdma_msg type
+ * messages, and never populate the chunk lists. This makes
+ * the RPC/RDMA header small and fixed in size, so it is
+ * straightforward to check the RPC header's direction field.
+ */
+static bool
+svc_rdma_is_backchannel_reply(struct svc_xprt *xprt, struct rpcrdma_msg *rmsgp)
+{
+	__be32 *p = (__be32 *)rmsgp;
+
+	if (!xprt->xpt_bc_xprt)
+		return false;
+
+	if (rmsgp->rm_type != rdma_msg)
+		return false;
+	if (rmsgp->rm_body.rm_chunks[0] != xdr_zero)
+		return false;
+	if (rmsgp->rm_body.rm_chunks[1] != xdr_zero)
+		return false;
+	if (rmsgp->rm_body.rm_chunks[2] != xdr_zero)
+		return false;
+
+	/* sanity */
+	if (p[7] != rmsgp->rm_xid)
+		return false;
+	/* call direction */
+	if (p[8] == cpu_to_be32(RPC_CALL))
+		return false;
+
+	return true;
+}
+
 /*
  * Set up the rqstp thread context to point to the RQ buffer. If
  * necessary, pull additional data from the client with an RDMA_READ
@@ -632,6 +665,15 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 		goto close_out;
 	}
 
+	if (svc_rdma_is_backchannel_reply(xprt, rmsgp)) {
+		ret = rpcrdma_handle_bc_reply(xprt->xpt_bc_xprt, rmsgp,
+					      &rqstp->rq_arg);
+		svc_rdma_put_context(ctxt, 0);
+		if (ret)
+			goto repost;
+		return ret;
+	}
+
 	/* Read read-list data. */
 	ret = rdma_read_chunks(rdma_xprt, rmsgp, rqstp, ctxt);
 	if (ret > 0) {
@@ -668,4 +710,14 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	set_bit(XPT_CLOSE, &xprt->xpt_flags);
 defer:
 	return 0;
+
+repost:
+	ret = svc_rdma_post_recv(rdma_xprt);
+	if (ret) {
+		pr_err("svcrdma: could not post a receive buffer, err=%d."
+		       "Closing transport %p.\n", ret, rdma_xprt);
+		set_bit(XPT_CLOSE, &rdma_xprt->sc_xprt.xpt_flags);
+		ret = -ENOTCONN;
+	}
+	return ret;
 }
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index ac7f8d4..9aeff2b 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -309,6 +309,8 @@ struct rpcrdma_buffer {
 	u32			rb_bc_srv_max_requests;
 	spinlock_t		rb_reqslock;	/* protect rb_allreqs */
 	struct list_head	rb_allreqs;
+
+	u32			rb_bc_max_requests;
 };
 #define rdmab_to_ia(b) (&container_of((b), struct rpcrdma_xprt, rx_buf)->rx_ia)
 
@@ -511,6 +513,8 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *);
  * RPC/RDMA protocol calls - xprtrdma/rpc_rdma.c
  */
 int rpcrdma_marshal_req(struct rpc_rqst *);
+int rpcrdma_handle_bc_reply(struct rpc_xprt *, struct rpcrdma_msg *,
+			    struct xdr_buf *);
 
 /* RPC/RDMA module init - xprtrdma/transport.c
  */

