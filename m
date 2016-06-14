Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34782 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741AbcFNTEi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 15:04:38 -0400
Received: by mail-it0-f67.google.com with SMTP id d71so419355ith.1
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 12:04:37 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] SUNRPC: RPC transport queue must be low latency
Date: Tue, 14 Jun 2016 15:04:04 -0400
Message-Id: <1465931046-30696-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1465931046-30696-2-git-send-email-trond.myklebust@primarydata.com>
References: <1465931046-30696-1-git-send-email-trond.myklebust@primarydata.com>
 <1465931046-30696-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpciod can easily get congested due to the long list of queued rpc_tasks.
Having the receive queue wait in turn for those tasks to complete can
therefore be a bottleneck.

Address the problem by separating the workqueues into:
- rpciod: manages rpc_tasks
- xprtiod: manages transport related work.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/sched.h |  1 +
 net/sunrpc/sched.c           | 24 ++++++++++++++++++++----
 net/sunrpc/xprt.c            |  8 ++++----
 net/sunrpc/xprtsock.c        |  6 +++---
 4 files changed, 28 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 05a1809c44d9..ef780b3b5e31 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -247,6 +247,7 @@ void		rpc_show_tasks(struct net *);
 int		rpc_init_mempool(void);
 void		rpc_destroy_mempool(void);
 extern struct workqueue_struct *rpciod_workqueue;
+extern struct workqueue_struct *xprtiod_workqueue;
 void		rpc_prepare_task(struct rpc_task *task);
 
 static inline int rpc_wait_for_completion_task(struct rpc_task *task)
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index fcfd48d263f6..a9f786247ffb 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -54,7 +54,8 @@ static struct rpc_wait_queue delay_queue;
 /*
  * rpciod-related stuff
  */
-struct workqueue_struct *rpciod_workqueue;
+struct workqueue_struct *rpciod_workqueue __read_mostly;
+struct workqueue_struct *xprtiod_workqueue __read_mostly;
 
 /*
  * Disable the timer for a given RPC task. Should be called with
@@ -1071,10 +1072,22 @@ static int rpciod_start(void)
 	 * Create the rpciod thread and wait for it to start.
 	 */
 	dprintk("RPC:       creating workqueue rpciod\n");
-	/* Note: highpri because network receive is latency sensitive */
-	wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_HIGHPRI, 0);
+	wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM, 0);
+	if (!wq)
+		goto out_failed;
 	rpciod_workqueue = wq;
-	return rpciod_workqueue != NULL;
+	/* Note: highpri because network receive is latency sensitive */
+	wq = alloc_workqueue("xprtiod", WQ_MEM_RECLAIM | WQ_HIGHPRI, 0);
+	if (!wq)
+		goto free_rpciod;
+	xprtiod_workqueue = wq;
+	return 1;
+free_rpciod:
+	wq = rpciod_workqueue;
+	rpciod_workqueue = NULL;
+	destroy_workqueue(wq);
+out_failed:
+	return 0;
 }
 
 static void rpciod_stop(void)
@@ -1088,6 +1101,9 @@ static void rpciod_stop(void)
 	wq = rpciod_workqueue;
 	rpciod_workqueue = NULL;
 	destroy_workqueue(wq);
+	wq = xprtiod_workqueue;
+	xprtiod_workqueue = NULL;
+	destroy_workqueue(wq);
 }
 
 void
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 216a1385718a..71df082b84a9 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -220,7 +220,7 @@ static void xprt_clear_locked(struct rpc_xprt *xprt)
 		clear_bit(XPRT_LOCKED, &xprt->state);
 		smp_mb__after_atomic();
 	} else
-		queue_work(rpciod_workqueue, &xprt->task_cleanup);
+		queue_work(xprtiod_workqueue, &xprt->task_cleanup);
 }
 
 /*
@@ -645,7 +645,7 @@ void xprt_force_disconnect(struct rpc_xprt *xprt)
 	set_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	/* Try to schedule an autoclose RPC call */
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
-		queue_work(rpciod_workqueue, &xprt->task_cleanup);
+		queue_work(xprtiod_workqueue, &xprt->task_cleanup);
 	xprt_wake_pending_tasks(xprt, -EAGAIN);
 	spin_unlock_bh(&xprt->transport_lock);
 }
@@ -672,7 +672,7 @@ void xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie)
 	set_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	/* Try to schedule an autoclose RPC call */
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
-		queue_work(rpciod_workqueue, &xprt->task_cleanup);
+		queue_work(xprtiod_workqueue, &xprt->task_cleanup);
 	xprt_wake_pending_tasks(xprt, -EAGAIN);
 out:
 	spin_unlock_bh(&xprt->transport_lock);
@@ -689,7 +689,7 @@ xprt_init_autodisconnect(unsigned long data)
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state))
 		goto out_abort;
 	spin_unlock(&xprt->transport_lock);
-	queue_work(rpciod_workqueue, &xprt->task_cleanup);
+	queue_work(xprtiod_workqueue, &xprt->task_cleanup);
 	return;
 out_abort:
 	spin_unlock(&xprt->transport_lock);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 62b4f5a2a331..646170d0cb86 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1095,7 +1095,7 @@ static void xs_data_ready(struct sock *sk)
 		if (xprt->reestablish_timeout)
 			xprt->reestablish_timeout = 0;
 		if (!test_and_set_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
-			queue_work(rpciod_workqueue, &transport->recv_worker);
+			queue_work(xprtiod_workqueue, &transport->recv_worker);
 	}
 	read_unlock_bh(&sk->sk_callback_lock);
 }
@@ -2378,7 +2378,7 @@ static void xs_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 		/* Start by resetting any existing state */
 		xs_reset_transport(transport);
 
-		queue_delayed_work(rpciod_workqueue,
+		queue_delayed_work(xprtiod_workqueue,
 				   &transport->connect_worker,
 				   xprt->reestablish_timeout);
 		xprt->reestablish_timeout <<= 1;
@@ -2388,7 +2388,7 @@ static void xs_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
 	} else {
 		dprintk("RPC:       xs_connect scheduled xprt %p\n", xprt);
-		queue_delayed_work(rpciod_workqueue,
+		queue_delayed_work(xprtiod_workqueue,
 				   &transport->connect_worker, 0);
 	}
 }
-- 
2.5.5

