Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35093 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751742AbcIOO5K (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 10:57:10 -0400
Subject: [PATCH v3 16/22] xprtrdma: Client-side support for
 rpcrdma_connect_private
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 15 Sep 2016 10:57:07 -0400
Message-ID: <20160915145707.11080.80346.stgit@manet.1015granger.net>
In-Reply-To: <20160915143440.11080.89241.stgit@manet.1015granger.net>
References: <20160915143440.11080.89241.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Send an RDMA-CM private message on connect, and look for one during
a connection-established event.

Both sides can communicate their various implementation limits.
Implementations that don't support this sideband protocol ignore it.

Once the client knows the server's inline threshold maxima, it can
adjust the use of Reply chunks, and eliminate most use of Position
Zero Read chunks. Moderately-sized I/O can be done using a pure
inline RDMA Send instead of RDMA operations that require memory
registration.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/rpc_rdma.h |    4 ++++
 net/sunrpc/xprtrdma/fmr_ops.c   |    5 ++---
 net/sunrpc/xprtrdma/frwr_ops.c  |    5 ++---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    8 +++++---
 net/sunrpc/xprtrdma/verbs.c     |   40 ++++++++++++++++++++++++++++++++++++---
 net/sunrpc/xprtrdma/xprt_rdma.h |    6 +++---
 6 files changed, 53 insertions(+), 15 deletions(-)

diff --git a/include/linux/sunrpc/rpc_rdma.h b/include/linux/sunrpc/rpc_rdma.h
index a7da6bf..cfda6ad 100644
--- a/include/linux/sunrpc/rpc_rdma.h
+++ b/include/linux/sunrpc/rpc_rdma.h
@@ -46,6 +46,10 @@
 #define RPCRDMA_VERSION		1
 #define rpcrdma_version		cpu_to_be32(RPCRDMA_VERSION)
 
+enum {
+	RPCRDMA_V1_DEF_INLINE_SIZE	= 1024,
+};
+
 struct rpcrdma_segment {
 	__be32 rs_handle;	/* Registered memory handle */
 	__be32 rs_length;	/* Length of the chunk in bytes */
diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 21cb3b1..16690a1 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -160,9 +160,8 @@ static int
 fmr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 	    struct rpcrdma_create_data_internal *cdata)
 {
-	rpcrdma_set_max_header_sizes(ia, cdata, max_t(unsigned int, 1,
-						      RPCRDMA_MAX_DATA_SEGS /
-						      RPCRDMA_MAX_FMR_SGES));
+	ia->ri_max_segs = max_t(unsigned int, 1, RPCRDMA_MAX_DATA_SEGS /
+				RPCRDMA_MAX_FMR_SGES);
 	return 0;
 }
 
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 892b5e1..fcfcf3a 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -242,9 +242,8 @@ frwr_op_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 					       depth;
 	}
 
-	rpcrdma_set_max_header_sizes(ia, cdata, max_t(unsigned int, 1,
-						      RPCRDMA_MAX_DATA_SEGS /
-						      ia->ri_max_frmr_depth));
+	ia->ri_max_segs = max_t(unsigned int, 1, RPCRDMA_MAX_DATA_SEGS /
+				ia->ri_max_frmr_depth);
 	return 0;
 }
 
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c2906e3..ea734c2 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -118,10 +118,12 @@ static unsigned int rpcrdma_max_reply_header_size(unsigned int maxsegs)
 	return size;
 }
 
-void rpcrdma_set_max_header_sizes(struct rpcrdma_ia *ia,
-				  struct rpcrdma_create_data_internal *cdata,
-				  unsigned int maxsegs)
+void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *r_xprt)
 {
+	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	unsigned int maxsegs = ia->ri_max_segs;
+
 	ia->ri_max_inline_write = cdata->inline_wsize -
 				  rpcrdma_max_call_header_size(maxsegs);
 	ia->ri_max_inline_read = cdata->inline_rsize -
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index a49c788..6bab841 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -204,6 +204,33 @@ out_fail:
 	goto out_schedule;
 }
 
+static void
+rpcrdma_update_connect_private(struct rpcrdma_xprt *r_xprt,
+			       struct rdma_conn_param *param)
+{
+	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
+	const struct rpcrdma_connect_private *pmsg = param->private_data;
+	unsigned int rsize, wsize;
+
+	rsize = RPCRDMA_V1_DEF_INLINE_SIZE;
+	wsize = RPCRDMA_V1_DEF_INLINE_SIZE;
+
+	if (pmsg &&
+	    pmsg->cp_magic == rpcrdma_cmp_magic &&
+	    pmsg->cp_version == RPCRDMA_CMP_VERSION) {
+		rsize = rpcrdma_decode_buffer_size(pmsg->cp_send_size);
+		wsize = rpcrdma_decode_buffer_size(pmsg->cp_recv_size);
+	}
+
+	if (rsize < cdata->inline_rsize)
+		cdata->inline_rsize = rsize;
+	if (wsize < cdata->inline_wsize)
+		cdata->inline_wsize = wsize;
+	pr_info("rpcrdma: max send %u, max recv %u\n",
+		cdata->inline_wsize, cdata->inline_rsize);
+	rpcrdma_set_max_header_sizes(r_xprt);
+}
+
 static int
 rpcrdma_conn_upcall(struct rdma_cm_id *id, struct rdma_cm_event *event)
 {
@@ -244,6 +271,7 @@ rpcrdma_conn_upcall(struct rdma_cm_id *id, struct rdma_cm_event *event)
 			" (%d initiator)\n",
 			__func__, attr->max_dest_rd_atomic,
 			attr->max_rd_atomic);
+		rpcrdma_update_connect_private(xprt, &event->param.conn);
 		goto connected;
 	case RDMA_CM_EVENT_CONNECT_ERROR:
 		connstate = -ENOTCONN;
@@ -454,6 +482,7 @@ int
 rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 				struct rpcrdma_create_data_internal *cdata)
 {
+	struct rpcrdma_connect_private *pmsg = &ep->rep_cm_private;
 	struct ib_cq *sendcq, *recvcq;
 	unsigned int max_qp_wr;
 	int rc;
@@ -536,9 +565,14 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	/* Initialize cma parameters */
 	memset(&ep->rep_remote_cma, 0, sizeof(ep->rep_remote_cma));
 
-	/* RPC/RDMA does not use private data */
-	ep->rep_remote_cma.private_data = NULL;
-	ep->rep_remote_cma.private_data_len = 0;
+	/* Prepare RDMA-CM private message */
+	pmsg->cp_magic = rpcrdma_cmp_magic;
+	pmsg->cp_version = RPCRDMA_CMP_VERSION;
+	pmsg->cp_flags = 0;
+	pmsg->cp_send_size = rpcrdma_encode_buffer_size(cdata->inline_wsize);
+	pmsg->cp_recv_size = rpcrdma_encode_buffer_size(cdata->inline_rsize);
+	ep->rep_remote_cma.private_data = pmsg;
+	ep->rep_remote_cma.private_data_len = sizeof(*pmsg);
 
 	/* Client offers RDMA Read but does not initiate */
 	ep->rep_remote_cma.initiator_depth = 0;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 9aabca6..89df168 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -70,6 +70,7 @@ struct rpcrdma_ia {
 	struct ib_pd		*ri_pd;
 	struct completion	ri_done;
 	int			ri_async_rc;
+	unsigned int		ri_max_segs;
 	unsigned int		ri_max_frmr_depth;
 	unsigned int		ri_max_inline_write;
 	unsigned int		ri_max_inline_read;
@@ -87,6 +88,7 @@ struct rpcrdma_ep {
 	int			rep_connected;
 	struct ib_qp_init_attr	rep_attr;
 	wait_queue_head_t 	rep_connect_wait;
+	struct rpcrdma_connect_private	rep_cm_private;
 	struct rdma_conn_param	rep_remote_cma;
 	struct sockaddr_storage	rep_remote_addr;
 	struct delayed_work	rep_connect_worker;
@@ -523,9 +525,7 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *);
  * RPC/RDMA protocol calls - xprtrdma/rpc_rdma.c
  */
 int rpcrdma_marshal_req(struct rpc_rqst *);
-void rpcrdma_set_max_header_sizes(struct rpcrdma_ia *,
-				  struct rpcrdma_create_data_internal *,
-				  unsigned int);
+void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);
 
 /* RPC/RDMA module init - xprtrdma/transport.c
  */

