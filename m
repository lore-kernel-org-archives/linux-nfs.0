Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:39969 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751462AbeCEUNJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2018 15:13:09 -0500
Subject: [PATCH 3/9] SUNRPC: Make RTT measurement more precise (Send)
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 05 Mar 2018 15:13:07 -0500
Message-ID: <20180305201307.10904.62368.stgit@manet.1015granger.net>
In-Reply-To: <20180305200825.10904.40829.stgit@manet.1015granger.net>
References: <20180305200825.10904.40829.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some RPC transports have more overhead in their send_request
callouts than others. For example, for RPC-over-RDMA:

- Marshaling an RPC often has to DMA map the RPC arguments

- Registration methods perform memory registration as part of
  marshaling

To capture just server and network latencies more precisely: when
sending a Call, capture the rq_xtime timestamp _after_ the transport
header has been marshaled.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprt.c               |    1 -
 net/sunrpc/xprtrdma/transport.c |    1 +
 net/sunrpc/xprtsock.c           |    3 +++
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index cb7784c..73f05a1 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1033,7 +1033,6 @@ void xprt_transmit(struct rpc_task *task)
 		return;
 
 	connect_cookie = xprt->connect_cookie;
-	req->rq_xtime = ktime_get();
 	status = xprt->ops->send_request(task);
 	trace_xprt_transmit(xprt, req->rq_xid, status);
 	if (status != 0) {
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 67e4386..cc1aad3 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -696,6 +696,7 @@
 	/* Must suppress retransmit to maintain credits */
 	if (rqst->rq_connect_cookie == xprt->connect_cookie)
 		goto drop_connection;
+	rqst->rq_xtime = ktime_get();
 
 	__set_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags);
 	if (rpcrdma_ep_post(&r_xprt->rx_ia, &r_xprt->rx_ep, req))
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 61df77f..e3c6a3d 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -527,6 +527,7 @@ static int xs_local_send_request(struct rpc_task *task)
 	xs_pktdump("packet data:",
 			req->rq_svec->iov_base, req->rq_svec->iov_len);
 
+	req->rq_xtime = ktime_get();
 	status = xs_sendpages(transport->sock, NULL, 0, xdr, req->rq_bytes_sent,
 			      true, &sent);
 	dprintk("RPC:       %s(%u) = %d\n",
@@ -589,6 +590,7 @@ static int xs_udp_send_request(struct rpc_task *task)
 
 	if (!xprt_bound(xprt))
 		return -ENOTCONN;
+	req->rq_xtime = ktime_get();
 	status = xs_sendpages(transport->sock, xs_addr(xprt), xprt->addrlen,
 			      xdr, req->rq_bytes_sent, true, &sent);
 
@@ -678,6 +680,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	/* Continue transmitting the packet/record. We must be careful
 	 * to cope with writespace callbacks arriving _after_ we have
 	 * called sendmsg(). */
+	req->rq_xtime = ktime_get();
 	while (1) {
 		sent = 0;
 		status = xs_sendpages(transport->sock, NULL, 0, xdr,

