From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] SUNRPC: Ensure all transports set rq_xtime consistently
Date: Thu, 27 Mar 2008 16:14:04 -0400
Message-ID: <20080327201404.4587.40085.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: thomas.talpey@netapp.com, linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:46490 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757236AbYC0UOW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Mar 2008 16:14:22 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RPC client uses the rq_xtime field in each RPC request to determine the
round-trip time of the request.  Currently, the rq_xtime field is
initialized by each transport just before it starts enqueing a request to
be sent.  However, transports do not handle initializing this value
consistently; sometimes they don't initialize it at all.

To make the measurement of request round-trip time consistent for all
RPC client transport capabilities, pull rq_xtime initialization into the
RPC client's generic transport logic.  Now all transports will get a
standardized RTT measure automatically, from:

  xprt_transmit()

to

  xprt_complete_rqst()

This makes round-trip time calculation more accurate for the TCP transport.
The socket ->sendmsg() method can return "-EAGAIN" if the socket's output
buffer is full, so the TCP transport's ->send_request() method may call
the ->sendmsg() method repeatedly until it gets all of the request's bytes
queued in the socket's buffer.

Currently, the TCP transport sets the rq_xtime field every time through
that loop so the final value is the timestamp just before the *last* call
to the underlying socket's ->sendmsg() method.  After this patch, the
rq_xtime field contains a timestamp that reflects the time just before the
*first* call to ->sendmsg().

This is consequential under heavy workloads because large requests often
take multiple ->sendmsg() calls to get all the bytes of a request queued.
The TCP transport causes the request to sleep until the remote end of the
socket has received enough bytes to clear space in the socket's local
output buffer.  This delay can be quite significant.

The method introduced by this patch is a more accurate measure of RTT
for stream transports, since the server can cause enough back pressure
to delay (ie increase the latency of) requests from the client.

Additionally, this patch corrects the behavior of the RDMA transport, which
neglected to initialize the rq_xtime field.  RPC performance metrics for
RDMA transports now display correct RPC request round trip times.

Acked-by: Tom Talpey <thomas.talpey@netapp.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprt.c     |    1 +
 net/sunrpc/xprtsock.c |    2 --
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index d5553b8..fd8cb6d 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -849,6 +849,7 @@ void xprt_transmit(struct rpc_task *task)
 	} else if (!req->rq_bytes_sent)
 		return;
 
+	req->rq_xtime = jiffies;
 	status = xprt->ops->send_request(task);
 	if (status == 0) {
 		dprintk("RPC: %5u xmit complete\n", task->tk_pid);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 565bcb8..5c5491e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -570,7 +570,6 @@ static int xs_udp_send_request(struct rpc_task *task)
 				req->rq_svec->iov_base,
 				req->rq_svec->iov_len);
 
-	req->rq_xtime = jiffies;
 	status = xs_sendpages(transport->sock,
 			      xs_addr(xprt),
 			      xprt->addrlen, xdr,
@@ -662,7 +661,6 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	 * to cope with writespace callbacks arriving _after_ we have
 	 * called sendmsg(). */
 	while (1) {
-		req->rq_xtime = jiffies;
 		status = xs_sendpages(transport->sock,
 					NULL, 0, xdr, req->rq_bytes_sent);
 

