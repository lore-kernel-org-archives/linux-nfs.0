Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:33465 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbbJXV2B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 17:28:01 -0400
Subject: [PATCH v4 12/16] xprtrdma: Add support for sending backward
 direction RPC replies
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 24 Oct 2015 17:27:59 -0400
Message-ID: <20151024212759.4715.354.stgit@manet.1015granger.net>
In-Reply-To: <20151024211707.4715.61650.stgit@manet.1015granger.net>
References: <20151024211707.4715.61650.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Backward direction RPC replies are sent via the client transport's
send_request method, the same way forward direction RPC calls are
sent.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>
---
 net/sunrpc/xprtrdma/backchannel.c |   45 +++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/rpc_rdma.c    |    5 ++++
 net/sunrpc/xprtrdma/xprt_rdma.h   |    1 +
 3 files changed, 51 insertions(+)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 3165ed6..ffc4853 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -170,6 +170,51 @@ out_err:
 }
 
 /**
+ * rpcrdma_bc_marshal_reply - Send backwards direction reply
+ * @rqst: buffer containing RPC reply data
+ *
+ * Returns zero on success.
+ */
+int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
+{
+	struct rpc_xprt *xprt = rqst->rq_xprt;
+	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
+	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
+	struct rpcrdma_msg *headerp;
+	size_t rpclen;
+
+	headerp = rdmab_to_msg(req->rl_rdmabuf);
+	headerp->rm_xid = rqst->rq_xid;
+	headerp->rm_vers = rpcrdma_version;
+	headerp->rm_credit =
+			cpu_to_be32(r_xprt->rx_buf.rb_bc_srv_max_requests);
+	headerp->rm_type = rdma_msg;
+	headerp->rm_body.rm_chunks[0] = xdr_zero;
+	headerp->rm_body.rm_chunks[1] = xdr_zero;
+	headerp->rm_body.rm_chunks[2] = xdr_zero;
+
+	rpclen = rqst->rq_svec[0].iov_len;
+
+	pr_info("RPC:       %s: rpclen %zd headerp 0x%p lkey 0x%x\n",
+		__func__, rpclen, headerp, rdmab_lkey(req->rl_rdmabuf));
+	pr_info("RPC:       %s: RPC/RDMA: %*ph\n",
+		__func__, (int)RPCRDMA_HDRLEN_MIN, headerp);
+	pr_info("RPC:       %s:      RPC: %*ph\n",
+		__func__, (int)rpclen, rqst->rq_svec[0].iov_base);
+
+	req->rl_send_iov[0].addr = rdmab_addr(req->rl_rdmabuf);
+	req->rl_send_iov[0].length = RPCRDMA_HDRLEN_MIN;
+	req->rl_send_iov[0].lkey = rdmab_lkey(req->rl_rdmabuf);
+
+	req->rl_send_iov[1].addr = rdmab_addr(req->rl_sendbuf);
+	req->rl_send_iov[1].length = rpclen;
+	req->rl_send_iov[1].lkey = rdmab_lkey(req->rl_sendbuf);
+
+	req->rl_niovs = 2;
+	return 0;
+}
+
+/**
  * xprt_rdma_bc_destroy - Release resources for handling backchannel requests
  * @xprt: transport associated with these backchannel resources
  * @reqs: number of incoming requests to destroy; ignored
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 95774fc..b7a21e5 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -441,6 +441,11 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	enum rpcrdma_chunktype rtype, wtype;
 	struct rpcrdma_msg *headerp;
 
+#if defined(CONFIG_SUNRPC_BACKCHANNEL)
+	if (test_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state))
+		return rpcrdma_bc_marshal_reply(rqst);
+#endif
+
 	/*
 	 * rpclen gets amount of data in first buffer, which is the
 	 * pre-registered buffer.
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 55d2660..e2d23ea 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -520,6 +520,7 @@ void xprt_rdma_cleanup(void);
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 int xprt_rdma_bc_setup(struct rpc_xprt *, unsigned int);
 int rpcrdma_bc_post_recv(struct rpcrdma_xprt *, unsigned int);
+int rpcrdma_bc_marshal_reply(struct rpc_rqst *);
 void xprt_rdma_bc_free_rqst(struct rpc_rqst *);
 void xprt_rdma_bc_destroy(struct rpc_xprt *, unsigned int);
 #endif	/* CONFIG_SUNRPC_BACKCHANNEL */

