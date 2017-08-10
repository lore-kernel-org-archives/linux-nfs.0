Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:38450 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752283AbdHJQra (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Aug 2017 12:47:30 -0400
Received: by mail-io0-f194.google.com with SMTP id o9so1925349iod.5
        for <linux-nfs@vger.kernel.org>; Thu, 10 Aug 2017 09:47:30 -0700 (PDT)
Subject: [PATCH v1 3/5] xprtrdma: Set up an xdr_stream in
 rpcrdma_marshal_req()
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 10 Aug 2017 12:47:28 -0400
Message-ID: <20170810164728.23774.43114.stgit@manet.1015granger.net>
In-Reply-To: <20170810164425.23774.91430.stgit@manet.1015granger.net>
References: <20170810164425.23774.91430.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Initialize an xdr_stream at the top of rpcrdma_marshal_req(), and
use it to encode the fixed transport header fields. This xdr_stream
will be used to encode the chunk lists in a subsequent patch.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   24 ++++++++++++++++++------
 net/sunrpc/xprtrdma/transport.c |    1 +
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 ++
 3 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index f1d63ac9..ffa99f0 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -667,17 +667,20 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
  *	%-ENOTCONN if the connection was lost,
  *	%-EAGAIN if not enough pages are available for on-demand reply buffer,
  *	%-ENOBUFS if no MRs are available to register chunks,
+ *	%-EMSGSIZE if the transport header is too small,
  *	%-EIO if a permanent problem occurred while marshaling.
  */
 int
 rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst)
 {
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
+	struct xdr_stream *xdr = &req->rl_stream;
 	enum rpcrdma_chunktype rtype, wtype;
 	struct rpcrdma_msg *headerp;
 	bool ddp_allowed;
 	ssize_t hdrlen;
 	__be32 *iptr;
+	__be32 *p;
 
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	if (test_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state))
@@ -685,11 +688,18 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 #endif
 
 	headerp = rdmab_to_msg(req->rl_rdmabuf);
-	/* don't byte-swap XID, it's already done in request */
-	headerp->rm_xid = rqst->rq_xid;
-	headerp->rm_vers = rpcrdma_version;
-	headerp->rm_credit = cpu_to_be32(r_xprt->rx_buf.rb_max_requests);
-	headerp->rm_type = rdma_msg;
+	rpcrdma_set_xdrlen(&req->rl_hdrbuf, 0);
+	xdr_init_encode(xdr, &req->rl_hdrbuf,
+			req->rl_rdmabuf->rg_base);
+
+	/* Fixed header fields */
+	iptr = ERR_PTR(-EMSGSIZE);
+	p = xdr_reserve_space(xdr, 4 * sizeof(*p));
+	if (!p)
+		goto out_err;
+	*p++ = rqst->rq_xid;
+	*p++ = rpcrdma_version;
+	*p++ = cpu_to_be32(r_xprt->rx_buf.rb_max_requests);
 
 	/* When the ULP employs a GSS flavor that guarantees integrity
 	 * or privacy, direct data placement of individual data items
@@ -729,12 +739,14 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 * by themselves are larger than the inline threshold.
 	 */
 	if (rpcrdma_args_inline(r_xprt, rqst)) {
+		*p++ = rdma_msg;
 		rtype = rpcrdma_noch;
 	} else if (ddp_allowed && rqst->rq_snd_buf.flags & XDRBUF_WRITE) {
+		*p++ = rdma_msg;
 		rtype = rpcrdma_readch;
 	} else {
 		r_xprt->rx_stats.nomsg_call_count++;
-		headerp->rm_type = htonl(RDMA_NOMSG);
+		*p++ = rdma_nomsg;
 		rtype = rpcrdma_areadch;
 	}
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index a43b8280..b680591 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -559,6 +559,7 @@
 
 	r_xprt->rx_stats.hardway_register_count += size;
 	req->rl_rdmabuf = rb;
+	xdr_buf_init(&req->rl_hdrbuf, rb->rg_base, rdmab_length(rb));
 	return true;
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 78958e9..2af9106 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -345,6 +345,8 @@ struct rpcrdma_req {
 	unsigned int		rl_connect_cookie;
 	struct rpcrdma_buffer	*rl_buffer;
 	struct rpcrdma_rep	*rl_reply;
+	struct xdr_stream	rl_stream;
+	struct xdr_buf		rl_hdrbuf;
 	struct ib_send_wr	rl_send_wr;
 	struct ib_sge		rl_send_sge[RPCRDMA_MAX_SEND_SGES];
 	struct rpcrdma_regbuf	*rl_rdmabuf;	/* xprt header */

