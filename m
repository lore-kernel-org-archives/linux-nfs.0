Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53954 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751034AbbF2E0b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Jun 2015 00:26:31 -0400
Date: Mon, 29 Jun 2015 14:26:23 +1000
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] SUNRPC: handle -EAGAIN from socket writes better.
Message-ID: <20150629142623.5afc0e6d@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


We can get -EAGAIN when writing to a socket for one of two reasons.

1/ The accounting done by the network layer reports that the socket has
   used all the buffer space it is allowed
2/ kmalloc failed.

In the first case we are certain to get a ->sk_write_space callback
when space becomes available.  In the second case there is no such
guarantee and we need to wait a short time.
sk_stream_wait_memory does exactly this calculating 'vm_wait' with
a magic formula which this patch copies.

The current code will always check if the socket is writeable after
preparing to receive the ->sk_write_space callback. In the kmalloc-failed
case this is usually true so the task is immediately woken, so it spins until
kmalloc succeeds, causing CPU wastage and soft-lockup messages.

So when calling xs_nospace() we check if the socket is actually writeable.

If it is, we assume a kmalloc failure (which may be inaccurate) and
set a timer for a short random wait after which we try again.  We
always wait in this case, possibly longer than needed, but not very long.

If the socket is not writeable, we follow the current path which will cause
the task to sleep until the socket is writable.

Fixes: 06ea0bfe6e60 ("SUNRPC: Fix races in xs_nospace()")
Signed-off-by: NeilBrown <neilb@suse.com>

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 8b93ef53df3c..146917ab1bcb 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -336,7 +336,7 @@ int			xprt_load_transport(const char *);
 void			xprt_set_retrans_timeout_def(struct rpc_task *task);
 void			xprt_set_retrans_timeout_rtt(struct rpc_task *task);
 void			xprt_wake_pending_tasks(struct rpc_xprt *xprt, int status);
-void			xprt_wait_for_buffer_space(struct rpc_task *task, rpc_action action);
+void			xprt_wait_for_buffer_space(struct rpc_task *task, rpc_action action, int writeable);
 void			xprt_write_space(struct rpc_xprt *xprt);
 void			xprt_adjust_cwnd(struct rpc_xprt *xprt, struct rpc_task *task, int result);
 struct rpc_rqst *	xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 826fecf19350..094f13f908d8 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -492,12 +492,17 @@ EXPORT_SYMBOL_GPL(xprt_wake_pending_tasks);
  * we don't in general want to force a socket disconnection due to
  * an incomplete RPC call transmission.
  */
-void xprt_wait_for_buffer_space(struct rpc_task *task, rpc_action action)
+void xprt_wait_for_buffer_space(struct rpc_task *task, rpc_action action,
+				int writeable)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = req->rq_xprt;
 
 	task->tk_timeout = RPC_IS_SOFT(task) ? req->rq_timeout : 0;
+	if (writeable)
+		/* waiting due to kmalloc failure */
+		/* See sk_stream_wait_memory */
+		task->tk_timeout = (prandom_u32() % (HZ / 5)) + 2;
 	rpc_sleep_on(&xprt->pending, task, action);
 }
 EXPORT_SYMBOL_GPL(xprt_wait_for_buffer_space);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 66891e32c5e3..5a1bd21f5957 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -443,12 +443,22 @@ static void xs_nospace_callback(struct rpc_task *task)
 	clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
 }
 
+static void xs_nomem_callback(struct rpc_task *task)
+{
+	struct sock_xprt *transport = container_of(task->tk_rqstp->rq_xprt, struct sock_xprt, xprt);
+
+	if (task->tk_status == -ETIMEDOUT)
+		task->tk_status = 0;
+	transport->inet->sk_write_pending--;
+	clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
+}
+
 /**
  * xs_nospace - place task on wait queue if transmit was incomplete
  * @task: task to put to sleep
  *
  */
-static int xs_nospace(struct rpc_task *task)
+static int xs_nospace(struct rpc_task *task, int writeable)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = req->rq_xprt;
@@ -473,7 +483,12 @@ static int xs_nospace(struct rpc_task *task)
 			set_bit(SOCK_NOSPACE, &transport->sock->flags);
 			sk->sk_write_pending++;
 			/* ...and wait for more buffer space */
-			xprt_wait_for_buffer_space(task, xs_nospace_callback);
+			if (writeable)
+				xprt_wait_for_buffer_space(
+					task, xs_nomem_callback, 1);
+			else
+				xprt_wait_for_buffer_space(
+					task, xs_nospace_callback, 0);
 		}
 	} else {
 		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
@@ -483,7 +498,8 @@ static int xs_nospace(struct rpc_task *task)
 	spin_unlock_bh(&xprt->transport_lock);
 
 	/* Race breaker in case memory is freed before above code is called */
-	sk->sk_write_space(sk);
+	if (!writeable)
+		sk->sk_write_space(sk);
 	return ret;
 }
 
@@ -540,7 +556,7 @@ static int xs_local_send_request(struct rpc_task *task)
 	switch (status) {
 	case -ENOBUFS:
 	case -EAGAIN:
-		status = xs_nospace(task);
+		status = xs_nospace(task, sock_writeable(transport->inet));
 		break;
 	default:
 		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
@@ -604,7 +620,7 @@ process_status:
 		/* Should we call xs_close() here? */
 		break;
 	case -EAGAIN:
-		status = xs_nospace(task);
+		status = xs_nospace(task, sock_writeable(transport->inet));
 		break;
 	default:
 		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
@@ -712,7 +728,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
 		break;
 	case -ENOBUFS:
 	case -EAGAIN:
-		status = xs_nospace(task);
+		status = xs_nospace(task, sk_stream_is_writeable(transport->inet));
 		break;
 	default:
 		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
