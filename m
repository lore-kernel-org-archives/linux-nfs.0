Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:36253 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728317AbeIQSbv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:51 -0400
Received: by mail-qt0-f176.google.com with SMTP id t5-v6so15140949qtn.3
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:35 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.34
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:34 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 33/44] SUNRPC: Cleanup: remove the unused 'task' argument from the request_send()
Date: Mon, 17 Sep 2018 09:03:24 -0400
Message-Id: <20180917130335.112832-34-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-33-trond.myklebust@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
 <20180917130335.112832-5-trond.myklebust@hammerspace.com>
 <20180917130335.112832-6-trond.myklebust@hammerspace.com>
 <20180917130335.112832-7-trond.myklebust@hammerspace.com>
 <20180917130335.112832-8-trond.myklebust@hammerspace.com>
 <20180917130335.112832-9-trond.myklebust@hammerspace.com>
 <20180917130335.112832-10-trond.myklebust@hammerspace.com>
 <20180917130335.112832-11-trond.myklebust@hammerspace.com>
 <20180917130335.112832-12-trond.myklebust@hammerspace.com>
 <20180917130335.112832-13-trond.myklebust@hammerspace.com>
 <20180917130335.112832-14-trond.myklebust@hammerspace.com>
 <20180917130335.112832-15-trond.myklebust@hammerspace.com>
 <20180917130335.112832-16-trond.myklebust@hammerspace.com>
 <20180917130335.112832-17-trond.myklebust@hammerspace.com>
 <20180917130335.112832-18-trond.myklebust@hammerspace.com>
 <20180917130335.112832-19-trond.myklebust@hammerspace.com>
 <20180917130335.112832-20-trond.myklebust@hammerspace.com>
 <20180917130335.112832-21-trond.myklebust@hammerspace.com>
 <20180917130335.112832-22-trond.myklebust@hammerspace.com>
 <20180917130335.112832-23-trond.myklebust@hammerspace.com>
 <20180917130335.112832-24-trond.myklebust@hammerspace.com>
 <20180917130335.112832-25-trond.myklebust@hammerspace.com>
 <20180917130335.112832-26-trond.myklebust@hammerspace.com>
 <20180917130335.112832-27-trond.myklebust@hammerspace.com>
 <20180917130335.112832-28-trond.myklebust@hammerspace.com>
 <20180917130335.112832-29-trond.myklebust@hammerspace.com>
 <20180917130335.112832-30-trond.myklebust@hammerspace.com>
 <20180917130335.112832-31-trond.myklebust@hammerspace.com>
 <20180917130335.112832-32-trond.myklebust@hammerspace.com>
 <20180917130335.112832-33-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h                |  2 +-
 net/sunrpc/xprt.c                          |  2 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  2 +-
 net/sunrpc/xprtrdma/transport.c            |  4 ++--
 net/sunrpc/xprtsock.c                      | 11 ++++-------
 5 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 5600242ccbf9..823860cce0bc 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -141,7 +141,7 @@ struct rpc_xprt_ops {
 	void		(*connect)(struct rpc_xprt *xprt, struct rpc_task *task);
 	int		(*buf_alloc)(struct rpc_task *task);
 	void		(*buf_free)(struct rpc_task *task);
-	int		(*send_request)(struct rpc_rqst *req, struct rpc_task *task);
+	int		(*send_request)(struct rpc_rqst *req);
 	void		(*set_retrans_timeout)(struct rpc_task *task);
 	void		(*timer)(struct rpc_xprt *xprt, struct rpc_task *task);
 	void		(*release_request)(struct rpc_task *task);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index e4d57f5be5e2..d1ea88b3f9d4 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1282,7 +1282,7 @@ xprt_request_transmit(struct rpc_rqst *req, struct rpc_task *snd_task)
 	req->rq_ntrans++;
 
 	connect_cookie = xprt->connect_cookie;
-	status = xprt->ops->send_request(req, snd_task);
+	status = xprt->ops->send_request(req);
 	trace_xprt_transmit(xprt, req->rq_xid, status);
 	if (status != 0) {
 		req->rq_ntrans--;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 35a8c3aab302..992312504cfd 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -215,7 +215,7 @@ rpcrdma_bc_send_request(struct svcxprt_rdma *rdma, struct rpc_rqst *rqst)
  * connection.
  */
 static int
-xprt_rdma_bc_send_request(struct rpc_rqst *rqst, struct rpc_task *task)
+xprt_rdma_bc_send_request(struct rpc_rqst *rqst)
 {
 	struct svc_xprt *sxprt = rqst->rq_xprt->bc_xprt;
 	struct svcxprt_rdma *rdma;
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 9ff322e53f37..a5a6a4a353f2 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -693,7 +693,7 @@ xprt_rdma_free(struct rpc_task *task)
 
 /**
  * xprt_rdma_send_request - marshal and send an RPC request
- * @task: RPC task with an RPC message in rq_snd_buf
+ * @rqst: RPC message in rq_snd_buf
  *
  * Caller holds the transport's write lock.
  *
@@ -706,7 +706,7 @@ xprt_rdma_free(struct rpc_task *task)
  *		sent. Do not try to send this message again.
  */
 static int
-xprt_rdma_send_request(struct rpc_rqst *rqst, struct rpc_task *task)
+xprt_rdma_send_request(struct rpc_rqst *rqst)
 {
 	struct rpc_xprt *xprt = rqst->rq_xprt;
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ef8d0e81cbda..f16406228ead 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -507,7 +507,6 @@ static inline void xs_encode_stream_record_marker(struct xdr_buf *buf)
 /**
  * xs_local_send_request - write an RPC request to an AF_LOCAL socket
  * @req: pointer to RPC request
- * @task: RPC task that manages the state of an RPC request
  *
  * Return values:
  *        0:	The request has been sent
@@ -516,7 +515,7 @@ static inline void xs_encode_stream_record_marker(struct xdr_buf *buf)
  * ENOTCONN:	Caller needs to invoke connect logic then call again
  *    other:	Some other error occured, the request was not sent
  */
-static int xs_local_send_request(struct rpc_rqst *req, struct rpc_task *task)
+static int xs_local_send_request(struct rpc_rqst *req)
 {
 	struct rpc_xprt *xprt = req->rq_xprt;
 	struct sock_xprt *transport =
@@ -579,7 +578,6 @@ static int xs_local_send_request(struct rpc_rqst *req, struct rpc_task *task)
 /**
  * xs_udp_send_request - write an RPC request to a UDP socket
  * @req: pointer to RPC request
- * @task: address of RPC task that manages the state of an RPC request
  *
  * Return values:
  *        0:	The request has been sent
@@ -588,7 +586,7 @@ static int xs_local_send_request(struct rpc_rqst *req, struct rpc_task *task)
  * ENOTCONN:	Caller needs to invoke connect logic then call again
  *    other:	Some other error occurred, the request was not sent
  */
-static int xs_udp_send_request(struct rpc_rqst *req, struct rpc_task *task)
+static int xs_udp_send_request(struct rpc_rqst *req)
 {
 	struct rpc_xprt *xprt = req->rq_xprt;
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
@@ -656,7 +654,6 @@ static int xs_udp_send_request(struct rpc_rqst *req, struct rpc_task *task)
 /**
  * xs_tcp_send_request - write an RPC request to a TCP socket
  * @req: pointer to RPC request
- * @task: address of RPC task that manages the state of an RPC request
  *
  * Return values:
  *        0:	The request has been sent
@@ -668,7 +665,7 @@ static int xs_udp_send_request(struct rpc_rqst *req, struct rpc_task *task)
  * XXX: In the case of soft timeouts, should we eventually give up
  *	if sendmsg is not able to make progress?
  */
-static int xs_tcp_send_request(struct rpc_rqst *req, struct rpc_task *task)
+static int xs_tcp_send_request(struct rpc_rqst *req)
 {
 	struct rpc_xprt *xprt = req->rq_xprt;
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
@@ -2704,7 +2701,7 @@ static int bc_sendto(struct rpc_rqst *req)
 /*
  * The send routine. Borrows from svc_send
  */
-static int bc_send_request(struct rpc_rqst *req, struct rpc_task *task)
+static int bc_send_request(struct rpc_rqst *req)
 {
 	struct svc_xprt	*xprt;
 	int len;
-- 
2.17.1
