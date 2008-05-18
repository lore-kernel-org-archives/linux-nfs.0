From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/8] SUNRPC: Rename "call_" functions that are no longer FSM
	states
Date: Sat, 17 May 2008 22:16:58 -0400
Message-ID: <20080518021658.8366.95808.stgit@ellison.1015granger.net>
References: <20080518021241.8366.12464.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:47902 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbYERCak (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 May 2008 22:30:40 -0400
In-Reply-To: <20080518021241.8366.12464.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RPC client uses a finite state machine to move RPC tasks through each
step of an RPC request.  Each state is contained in a function in
net/sunrpc/clnt.c, and named call_foo.

Some of the functions named call_foo have changed over the past few years and
are no longer states in the FSM.  These include: call_encode, call_header,
and call_verify.  As a clean up, rename the functions that have changed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |   35 ++++++++++++++---------------------
 1 files changed, 14 insertions(+), 21 deletions(-)


diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 1b2c766..ba87a0f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -58,7 +58,6 @@ static void	call_start(struct rpc_task *task);
 static void	call_reserve(struct rpc_task *task);
 static void	call_reserveresult(struct rpc_task *task);
 static void	call_allocate(struct rpc_task *task);
-static void	call_encode(struct rpc_task *task);
 static void	call_decode(struct rpc_task *task);
 static void	call_bind(struct rpc_task *task);
 static void	call_bind_status(struct rpc_task *task);
@@ -70,9 +69,9 @@ static void	call_refreshresult(struct rpc_task *task);
 static void	call_timeout(struct rpc_task *task);
 static void	call_connect(struct rpc_task *task);
 static void	call_connect_status(struct rpc_task *task);
-static __be32 *	call_header(struct rpc_task *task);
-static __be32 *	call_verify(struct rpc_task *task);
 
+static __be32	*rpc_encode_header(struct rpc_task *task);
+static __be32	*rpc_verify_header(struct rpc_task *task);
 static int	rpc_ping(struct rpc_clnt *clnt, int flags);
 
 static void rpc_register_client(struct rpc_clnt *clnt)
@@ -861,7 +860,7 @@ rpc_xdr_buf_init(struct xdr_buf *buf, void *start, size_t len)
  * 3.	Encode arguments of an RPC call
  */
 static void
-call_encode(struct rpc_task *task)
+rpc_xdr_encode(struct rpc_task *task)
 {
 	struct rpc_rqst	*req = task->tk_rqstp;
 	kxdrproc_t	encode;
@@ -876,13 +875,14 @@ call_encode(struct rpc_task *task)
 			 (char *)req->rq_buffer + req->rq_callsize,
 			 req->rq_rcvsize);
 
-	/* Encode header and provided arguments */
-	encode = task->tk_msg.rpc_proc->p_encode;
-	if (!(p = call_header(task))) {
-		printk(KERN_INFO "RPC: call_header failed, exit EIO\n");
+	p = rpc_encode_header(task);
+	if (p == NULL) {
+		printk(KERN_INFO "RPC: couldn't encode RPC header, exit EIO\n");
 		rpc_exit(task, -EIO);
 		return;
 	}
+
+	encode = task->tk_msg.rpc_proc->p_encode;
 	if (encode == NULL)
 		return;
 
@@ -1046,7 +1046,7 @@ call_transmit(struct rpc_task *task)
 	/* Encode here so that rpcsec_gss can use correct sequence number. */
 	if (rpc_task_need_encode(task)) {
 		BUG_ON(task->tk_rqstp->rq_bytes_sent != 0);
-		call_encode(task);
+		rpc_xdr_encode(task);
 		/* Did the encode result in an error condition? */
 		if (task->tk_status != 0)
 			return;
@@ -1224,8 +1224,7 @@ call_decode(struct rpc_task *task)
 		goto out_retry;
 	}
 
-	/* Verify the RPC header */
-	p = call_verify(task);
+	p = rpc_verify_header(task);
 	if (IS_ERR(p)) {
 		if (p == ERR_PTR(-EAGAIN))
 			goto out_retry;
@@ -1243,7 +1242,7 @@ call_decode(struct rpc_task *task)
 	return;
 out_retry:
 	task->tk_status = 0;
-	/* Note: call_verify() may have freed the RPC slot */
+	/* Note: rpc_verify_header() may have freed the RPC slot */
 	if (task->tk_rqstp == req) {
 		req->rq_received = req->rq_rcv_buf.len = 0;
 		if (task->tk_client->cl_discrtry)
@@ -1290,11 +1289,8 @@ call_refreshresult(struct rpc_task *task)
 	return;
 }
 
-/*
- * Call header serialization
- */
 static __be32 *
-call_header(struct rpc_task *task)
+rpc_encode_header(struct rpc_task *task)
 {
 	struct rpc_clnt *clnt = task->tk_client;
 	struct rpc_rqst	*req = task->tk_rqstp;
@@ -1314,11 +1310,8 @@ call_header(struct rpc_task *task)
 	return p;
 }
 
-/*
- * Reply header verification
- */
 static __be32 *
-call_verify(struct rpc_task *task)
+rpc_verify_header(struct rpc_task *task)
 {
 	struct kvec *iov = &task->tk_rqstp->rq_rcv_buf.head[0];
 	int len = task->tk_rqstp->rq_rcv_buf.len >> 2;
@@ -1392,7 +1385,7 @@ call_verify(struct rpc_task *task)
 			task->tk_action = call_bind;
 			goto out_retry;
 		case RPC_AUTH_TOOWEAK:
-			printk(KERN_NOTICE "call_verify: server %s requires stronger "
+			printk(KERN_NOTICE "RPC: server %s requires stronger "
 			       "authentication.\n", task->tk_client->cl_server);
 			break;
 		default:

