Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:33814 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432AbbJXV2K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 17:28:10 -0400
Subject: [PATCH v4 13/16] xprtrdma: Handle incoming backward direction RPC
 calls
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 24 Oct 2015 17:28:08 -0400
Message-ID: <20151024212808.4715.98766.stgit@manet.1015granger.net>
In-Reply-To: <20151024211707.4715.61650.stgit@manet.1015granger.net>
References: <20151024211707.4715.61650.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a code path in the rpcrdma_reply_handler() to catch
incoming backward direction RPC calls and route them to the ULP's
backchannel server.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>
---
 net/sunrpc/xprtrdma/backchannel.c |  118 +++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/rpc_rdma.c    |   41 +++++++++++++
 net/sunrpc/xprtrdma/xprt_rdma.h   |    2 +
 3 files changed, 161 insertions(+)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index ffc4853..0b3387f 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -5,6 +5,8 @@
  */
 
 #include <linux/module.h>
+#include <linux/sunrpc/xprt.h>
+#include <linux/sunrpc/svc.h>
 
 #include "xprt_rdma.h"
 
@@ -12,6 +14,8 @@
 # define RPCDBG_FACILITY	RPCDBG_TRANS
 #endif
 
+#define RPCRDMA_BACKCHANNEL_DEBUG
+
 static void rpcrdma_bc_free_rqst(struct rpcrdma_xprt *r_xprt,
 				 struct rpc_rqst *rqst)
 {
@@ -253,3 +257,117 @@ void xprt_rdma_bc_free_rqst(struct rpc_rqst *rqst)
 	list_add_tail(&rqst->rq_bc_pa_list, &xprt->bc_pa_list);
 	spin_unlock_bh(&xprt->bc_pa_lock);
 }
+
+/**
+ * rpcrdma_bc_receive_call - Handle a backward direction call
+ * @xprt: transport receiving the call
+ * @rep: receive buffer containing the call
+ *
+ * Called in the RPC reply handler, which runs in a tasklet.
+ * Be quick about it.
+ *
+ * Operational assumptions:
+ *    o Backchannel credits are ignored, just as the NFS server
+ *      forechannel currently does
+ *    o The ULP manages a replay cache (eg, NFSv4.1 sessions).
+ *      No replay detection is done at the transport level
+ */
+void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
+			     struct rpcrdma_rep *rep)
+{
+	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
+	struct rpcrdma_msg *headerp;
+	struct svc_serv *bc_serv;
+	struct rpcrdma_req *req;
+	struct rpc_rqst *rqst;
+	struct xdr_buf *buf;
+	size_t size;
+	__be32 *p;
+
+	headerp = rdmab_to_msg(rep->rr_rdmabuf);
+#ifdef RPCRDMA_BACKCHANNEL_DEBUG
+	pr_info("RPC:       %s: callback XID %08x, length=%u\n",
+		__func__, be32_to_cpu(headerp->rm_xid), rep->rr_len);
+	pr_info("RPC:       %s: %*ph\n", __func__, rep->rr_len, headerp);
+#endif
+
+	/* Sanity check:
+	 * Need at least enough bytes for RPC/RDMA header, as code
+	 * here references the header fields by array offset. Also,
+	 * backward calls are always inline, so ensure there
+	 * are some bytes beyond the RPC/RDMA header.
+	 */
+	if (rep->rr_len < RPCRDMA_HDRLEN_MIN + 24)
+		goto out_short;
+	p = (__be32 *)((unsigned char *)headerp + RPCRDMA_HDRLEN_MIN);
+	size = rep->rr_len - RPCRDMA_HDRLEN_MIN;
+
+	/* Grab a free bc rqst */
+	spin_lock(&xprt->bc_pa_lock);
+	if (list_empty(&xprt->bc_pa_list)) {
+		spin_unlock(&xprt->bc_pa_lock);
+		goto out_overflow;
+	}
+	rqst = list_first_entry(&xprt->bc_pa_list,
+				struct rpc_rqst, rq_bc_pa_list);
+	list_del(&rqst->rq_bc_pa_list);
+	spin_unlock(&xprt->bc_pa_lock);
+#ifdef RPCRDMA_BACKCHANNEL_DEBUG
+	pr_info("RPC:       %s: using rqst %p\n", __func__, rqst);
+#endif
+
+	/* Prepare rqst */
+	rqst->rq_reply_bytes_recvd = 0;
+	rqst->rq_bytes_sent = 0;
+	rqst->rq_xid = headerp->rm_xid;
+	set_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
+
+	buf = &rqst->rq_rcv_buf;
+	memset(buf, 0, sizeof(*buf));
+	buf->head[0].iov_base = p;
+	buf->head[0].iov_len = size;
+	buf->len = size;
+
+	/* The receive buffer has to be hooked to the rpcrdma_req
+	 * so that it can be reposted after the server is done
+	 * parsing it but just before sending the backward
+	 * direction reply.
+	 */
+	req = rpcr_to_rdmar(rqst);
+#ifdef RPCRDMA_BACKCHANNEL_DEBUG
+	pr_info("RPC:       %s: attaching rep %p to req %p\n",
+		__func__, rep, req);
+#endif
+	req->rl_reply = rep;
+
+	/* Defeat the retransmit detection logic in send_request */
+	req->rl_connect_cookie = 0;
+
+	/* Queue rqst for ULP's callback service */
+	bc_serv = xprt->bc_serv;
+	spin_lock(&bc_serv->sv_cb_lock);
+	list_add(&rqst->rq_bc_list, &bc_serv->sv_cb_list);
+	spin_unlock(&bc_serv->sv_cb_lock);
+
+	wake_up(&bc_serv->sv_cb_waitq);
+
+	r_xprt->rx_stats.bcall_count++;
+	return;
+
+out_overflow:
+	pr_warn("RPC/RDMA backchannel overflow\n");
+	xprt_disconnect_done(xprt);
+	/* This receive buffer gets reposted automatically
+	 * when the connection is re-established.
+	 */
+	return;
+
+out_short:
+	pr_warn("RPC/RDMA short backward direction call\n");
+
+	if (rpcrdma_ep_post_recv(&r_xprt->rx_ia, &r_xprt->rx_ep, rep))
+		xprt_disconnect_done(xprt);
+	else
+		pr_warn("RPC:       %s: reposting rep %p\n",
+			__func__, rep);
+}
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index b7a21e5..c10d969 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -716,6 +716,37 @@ rpcrdma_connect_worker(struct work_struct *work)
 	spin_unlock_bh(&xprt->transport_lock);
 }
 
+#if defined(CONFIG_SUNRPC_BACKCHANNEL)
+/* By convention, backchannel calls arrive via rdma_msg type
+ * messages, and never populate the chunk lists. This makes
+ * the RPC/RDMA header small and fixed in size, so it is
+ * straightforward to check the RPC header's direction field.
+ */
+static bool
+rpcrdma_is_bcall(struct rpcrdma_msg *headerp)
+{
+	__be32 *p = (__be32 *)headerp;
+
+	if (headerp->rm_type != rdma_msg)
+		return false;
+	if (headerp->rm_body.rm_chunks[0] != xdr_zero)
+		return false;
+	if (headerp->rm_body.rm_chunks[1] != xdr_zero)
+		return false;
+	if (headerp->rm_body.rm_chunks[2] != xdr_zero)
+		return false;
+
+	/* sanity */
+	if (p[7] != headerp->rm_xid)
+		return false;
+	/* call direction */
+	if (p[8] != cpu_to_be32(RPC_CALL))
+		return false;
+
+	return true;
+}
+#endif	/* CONFIG_SUNRPC_BACKCHANNEL */
+
 /*
  * This function is called when an async event is posted to
  * the connection which changes the connection state. All it
@@ -756,6 +787,10 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	headerp = rdmab_to_msg(rep->rr_rdmabuf);
 	if (headerp->rm_vers != rpcrdma_version)
 		goto out_badversion;
+#if defined(CONFIG_SUNRPC_BACKCHANNEL)
+	if (rpcrdma_is_bcall(headerp))
+		goto out_bcall;
+#endif
 
 	/* Match incoming rpcrdma_rep to an rpcrdma_req to
 	 * get context for handling any incoming chunks.
@@ -878,6 +913,12 @@ out_badstatus:
 	}
 	return;
 
+#if defined(CONFIG_SUNRPC_BACKCHANNEL)
+out_bcall:
+	rpcrdma_bc_receive_call(r_xprt, rep);
+	return;
+#endif
+
 out_shortreply:
 	dprintk("RPC:       %s: short/invalid reply\n", __func__);
 	goto repost;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index e2d23ea..eb87d96e8 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -353,6 +353,7 @@ struct rpcrdma_stats {
 	unsigned long		failed_marshal_count;
 	unsigned long		bad_reply_count;
 	unsigned long		nomsg_call_count;
+	unsigned long		bcall_count;
 };
 
 /*
@@ -520,6 +521,7 @@ void xprt_rdma_cleanup(void);
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 int xprt_rdma_bc_setup(struct rpc_xprt *, unsigned int);
 int rpcrdma_bc_post_recv(struct rpcrdma_xprt *, unsigned int);
+void rpcrdma_bc_receive_call(struct rpcrdma_xprt *, struct rpcrdma_rep *);
 int rpcrdma_bc_marshal_reply(struct rpc_rqst *);
 void xprt_rdma_bc_free_rqst(struct rpc_rqst *);
 void xprt_rdma_bc_destroy(struct rpc_xprt *, unsigned int);

