From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] SUNRPC: Ensure all transports set rq_xtime consistently
Date: Fri, 06 Jun 2008 13:22:25 -0400
Message-ID: <20080606172224.14757.75565.stgit@manray.1015granger.net>
References: <20080606172037.14757.64893.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:63473 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752422AbYFFRW2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jun 2008 13:22:28 -0400
Received: by an-out-0708.google.com with SMTP id d40so291375and.103
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jun 2008 10:22:27 -0700 (PDT)
In-Reply-To: <20080606172037.14757.64893.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
entirely neglected to initialize the rq_xtime field.  RPC performance
metrics for RDMA transports now display correct RPC request round trip
times.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Tom Talpey <thomas.talpey@netapp.com>
---

 net/sunrpc/xprt.c     |    1 +
 net/sunrpc/xprtsock.c |    2 --
 2 files changed, 1 insertions(+), 2 deletions(-)


diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 67996bd..99a52aa 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -872,6 +872,7 @@ void xprt_transmit(struct rpc_task *task)
 		return;
 
 	req->rq_connect_cookie = xprt->connect_cookie;
+	req->rq_xtime = jiffies;
 	status = xprt->ops->send_request(task);
 	if (status == 0) {
 		dprintk("RPC: %5u xmit complete\n", task->tk_pid);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ddbe981..4486c59 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -579,7 +579,6 @@ static int xs_udp_send_request(struct rpc_task *task)
 				req->rq_svec->iov_base,
 				req->rq_svec->iov_len);
 
-	req->rq_xtime = jiffies;
 	status = xs_sendpages(transport->sock,
 			      xs_addr(xprt),
 			      xprt->addrlen, xdr,
@@ -671,7 +670,6 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	 * to cope with writespace callbacks arriving _after_ we have
 	 * called sendmsg(). */
 	while (1) {
-		req->rq_xtime = jiffies;
 		status = xs_sendpages(transport->sock,
 					NULL, 0, xdr, req->rq_bytes_sent);
 

