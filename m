Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:21646 "EHLO SMTP.CITRIX.COM"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934024AbcIPM2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Sep 2016 08:28:42 -0400
From: David Vrabel <david.vrabel@citrix.com>
To: <linux-nfs@vger.kernel.org>
CC: David Vrabel <david.vrabel@citrix.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, <netdev@vger.kernel.org>
Subject: [PATCHv1] sunrpc: fix write space race causing stalls
Date: Fri, 16 Sep 2016 13:28:22 +0100
Message-ID: <1474028902-19838-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Write space becoming available may race with putting the task to sleep
in xprt_wait_for_buffer_space().  The existing mechanism to avoid the
race does not work.

This (edited) partial trace illustrates the problem:

   [1] rpc_task_run_action: task:43546@5 ... action=call_transmit
   [2] xs_write_space <-xs_tcp_write_space
   [3] xprt_write_space <-xs_write_space
   [4] rpc_task_sleep: task:43546@5 ...
   [5] xs_write_space <-xs_tcp_write_space

[1] Task 43546 runs but is out of write space.

[2] Space becomes available, xs_write_space() clears the
    SOCKWQ_ASYNC_NOSPACE bit.

[3] xprt_write_space() attemts to wake xprt->snd_task (== 43546), but
    this has not yet been queued and the wake up is lost.

[4] xs_nospace() is called which calls xprt_wait_for_buffer_space()
    which queues task 43546.

[5] The call to sk->sk_write_space() at the end of xs_nospace() (which
    is supposed to handle the above race) does not call
    xprt_write_space() as the SOCKWQ_ASYNC_NOSPACE bit is clear and
    thus the task is not woken.

Fix the race by have xprt_wait_for_buffer_space() check for write
space after putting the task to sleep.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 include/linux/sunrpc/xprt.h |  1 +
 net/sunrpc/xprt.c           |  4 ++++
 net/sunrpc/xprtsock.c       | 21 +++++++++++++++++++--
 3 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index a16070d..621e74b 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -129,6 +129,7 @@ struct rpc_xprt_ops {
 	void		(*connect)(struct rpc_xprt *xprt, struct rpc_task *task);
 	void *		(*buf_alloc)(struct rpc_task *task, size_t size);
 	void		(*buf_free)(void *buffer);
+	bool            (*have_write_space)(struct rpc_xprt *task);
 	int		(*send_request)(struct rpc_task *task);
 	void		(*set_retrans_timeout)(struct rpc_task *task);
 	void		(*timer)(struct rpc_xprt *xprt, struct rpc_task *task);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index ea244b2..d3c1b1e 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -502,6 +502,10 @@ void xprt_wait_for_buffer_space(struct rpc_task *task, rpc_action action)
 
 	task->tk_timeout = RPC_IS_SOFT(task) ? req->rq_timeout : 0;
 	rpc_sleep_on(&xprt->pending, task, action);
+
+	/* Write space notification may race with putting task to sleep. */
+	if (xprt->ops->have_write_space(xprt))
+		rpc_wake_up_queued_task(&xprt->pending, task);
 }
 EXPORT_SYMBOL_GPL(xprt_wait_for_buffer_space);
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index bf16883..211de5b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -472,8 +472,6 @@ static int xs_nospace(struct rpc_task *task)
 
 	spin_unlock_bh(&xprt->transport_lock);
 
-	/* Race breaker in case memory is freed before above code is called */
-	sk->sk_write_space(sk);
 	return ret;
 }
 
@@ -1679,6 +1677,22 @@ static void xs_tcp_write_space(struct sock *sk)
 	read_unlock_bh(&sk->sk_callback_lock);
 }
 
+static bool xs_udp_have_write_space(struct rpc_xprt *xprt)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	struct sock *sk = transport->inet;
+
+	return sock_writeable(sk);
+}
+
+static bool xs_tcp_have_write_space(struct rpc_xprt *xprt)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	struct sock *sk = transport->inet;
+
+	return sk_stream_is_writeable(sk);
+}
+
 static void xs_udp_do_set_buffer_size(struct rpc_xprt *xprt)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
@@ -2664,6 +2678,7 @@ static struct rpc_xprt_ops xs_local_ops = {
 	.connect		= xs_local_connect,
 	.buf_alloc		= rpc_malloc,
 	.buf_free		= rpc_free,
+	.have_write_space       = xs_udp_have_write_space,
 	.send_request		= xs_local_send_request,
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
 	.close			= xs_close,
@@ -2683,6 +2698,7 @@ static struct rpc_xprt_ops xs_udp_ops = {
 	.connect		= xs_connect,
 	.buf_alloc		= rpc_malloc,
 	.buf_free		= rpc_free,
+	.have_write_space       = xs_udp_have_write_space,
 	.send_request		= xs_udp_send_request,
 	.set_retrans_timeout	= xprt_set_retrans_timeout_rtt,
 	.timer			= xs_udp_timer,
@@ -2704,6 +2720,7 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 	.connect		= xs_connect,
 	.buf_alloc		= rpc_malloc,
 	.buf_free		= rpc_free,
+	.have_write_space       = xs_tcp_have_write_space,
 	.send_request		= xs_tcp_send_request,
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
 	.close			= xs_tcp_shutdown,
-- 
2.1.4

