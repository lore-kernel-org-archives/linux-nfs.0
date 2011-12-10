Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4676 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751256Ab1LJDKX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Dec 2011 22:10:23 -0500
Message-ID: <1323486601.32695.2.camel@lade.trondhjem.org>
Subject: Re: 3.1.4: NFSv3 RPC scheduling issue?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Frank van Maarseveen <frankvm@frankvm.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Date: Fri, 09 Dec 2011 22:10:01 -0500
In-Reply-To: <20111207134359.GA29828@janus>
References: <20111205165021.GA24165@janus>
	 <1323128376.7237.7.camel@lade.trondhjem.org> <20111206081115.GA3570@janus>
	 <1323201463.3199.18.camel@lade.trondhjem.org>
	 <20111207134359.GA29828@janus>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2011-12-07 at 14:43 +0100, Frank van Maarseveen wrote: 
> I did three more 'echo 0 > /proc/sys/sunrpc/rpc_debug' before repairing
> the mount and outputs differ slightly (file '1' contains above dump, 2,
> 3 and 4 are the others):
> 
> diff 1 2:
> | 58d57
> | < 21609 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
> diff 1 3:
> | 47d46
> | < 36566 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
> | 58c57
> | < 21609 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
> | ---
> | > 33046 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
> diff 1 4:
> | 16d15
> | < 36496 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 GETATTR a:call_reserveresult q:xprt_sending
> | 47d45
> | < 36566 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
> | 58c56,57
> | < 21609 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
> | ---
> | > 33046 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
> | > 34798 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending

I'm still mystified as to what is going on here...

Would it be possible to upgrade some of your clients to 3.1.5 (which
contains a fix for a sunrpc socket buffer problem) and then to add the
following patch?

Cheers
  Trond

8<------------------------------------------------------------------------------- 
>From 72a29422b5d4e00c5aae6466b415cb5b075bb032 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Fri, 9 Dec 2011 13:40:57 -0500
Subject: [PATCH 1/2] debugging

- Ensure that we clean up in case the call to queue xprt->task_cleanup
  fails (although it is hard to see how it could).
- Ensure that we don't hold onto a UDP congestion slot if we're queued up
  waiting for the socket lock.
- Add debugging printks to check for the above two conditions.

- Add further debugging printks to track slot allocation
---
 net/sunrpc/xprt.c |   56 +++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 42 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index c64c0ef..284eb42 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -44,6 +44,8 @@
 #include <linux/workqueue.h>
 #include <linux/net.h>
 #include <linux/ktime.h>
+#include <linux/ratelimit.h>
+#include <linux/printk.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/metrics.h>
@@ -66,6 +68,7 @@ static void	 xprt_init(struct rpc_xprt *xprt, struct net *net);
 static void	xprt_request_init(struct rpc_task *, struct rpc_xprt *);
 static void	xprt_connect_status(struct rpc_task *task);
 static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
+static void	__xprt_put_cong(struct rpc_xprt *, struct rpc_rqst *);
 
 static DEFINE_SPINLOCK(xprt_list_lock);
 static LIST_HEAD(xprt_list);
@@ -227,15 +230,28 @@ out_sleep:
 }
 EXPORT_SYMBOL_GPL(xprt_reserve_xprt);
 
+static void __xprt_clear_locked(struct rpc_xprt *xprt)
+{
+	smp_mb__before_clear_bit();
+	clear_bit(XPRT_LOCKED, &xprt->state);
+	smp_mb__after_clear_bit();
+}
+
+static void xprt_run_task_cleanup(struct rpc_xprt *xprt)
+{
+	if (queue_work(rpciod_workqueue, &xprt->task_cleanup) == 0) {
+		__xprt_clear_locked(xprt);
+		pr_err("%s: RPC task cleanup failed to start!\n", __func__);
+	}
+}
+
 static void xprt_clear_locked(struct rpc_xprt *xprt)
 {
 	xprt->snd_task = NULL;
-	if (!test_bit(XPRT_CLOSE_WAIT, &xprt->state) || xprt->shutdown) {
-		smp_mb__before_clear_bit();
-		clear_bit(XPRT_LOCKED, &xprt->state);
-		smp_mb__after_clear_bit();
-	} else
-		queue_work(rpciod_workqueue, &xprt->task_cleanup);
+	if (test_bit(XPRT_CLOSE_WAIT, &xprt->state) && !xprt->shutdown)
+		xprt_run_task_cleanup(xprt);
+	else
+		__xprt_clear_locked(xprt);
 }
 
 /*
@@ -271,12 +287,18 @@ out_sleep:
 	dprintk("RPC: %5u failed to lock transport %p\n", task->tk_pid, xprt);
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
-	if (req == NULL)
-		priority = RPC_PRIORITY_LOW;
-	else if (!req->rq_ntrans)
+	priority = RPC_PRIORITY_LOW;
+	if (req != NULL) {
 		priority = RPC_PRIORITY_NORMAL;
-	else
-		priority = RPC_PRIORITY_HIGH;
+		if (req->rq_ntrans)
+			priority = RPC_PRIORITY_HIGH;
+		if (req->rq_cong) {
+			__xprt_put_cong(xprt, req);
+			pr_err("%s: don't wait for a transport write lock "
+					"while holding a congestion slot.\n",
+					__func__);
+		}
+	}
 	rpc_sleep_on_priority(&xprt->sending, task, NULL, priority);
 	return 0;
 }
@@ -636,7 +658,7 @@ void xprt_force_disconnect(struct rpc_xprt *xprt)
 	set_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	/* Try to schedule an autoclose RPC call */
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
-		queue_work(rpciod_workqueue, &xprt->task_cleanup);
+		xprt_run_task_cleanup(xprt);
 	xprt_wake_pending_tasks(xprt, -EAGAIN);
 	spin_unlock_bh(&xprt->transport_lock);
 }
@@ -663,7 +685,7 @@ void xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie)
 	set_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	/* Try to schedule an autoclose RPC call */
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
-		queue_work(rpciod_workqueue, &xprt->task_cleanup);
+		xprt_run_task_cleanup(xprt);
 	xprt_wake_pending_tasks(xprt, -EAGAIN);
 out:
 	spin_unlock_bh(&xprt->transport_lock);
@@ -681,7 +703,7 @@ xprt_init_autodisconnect(unsigned long data)
 		goto out_abort;
 	spin_unlock(&xprt->transport_lock);
 	set_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
-	queue_work(rpciod_workqueue, &xprt->task_cleanup);
+	xprt_run_task_cleanup(xprt);
 	return;
 out_abort:
 	spin_unlock(&xprt->transport_lock);
@@ -942,6 +964,8 @@ static struct rpc_rqst *xprt_dynamic_alloc_slot(struct rpc_xprt *xprt, gfp_t gfp
 {
 	struct rpc_rqst *req = ERR_PTR(-EAGAIN);
 
+	if (atomic_read(&xprt->num_reqs) > xprt->max_reqs)
+		pr_err_ratelimited("%s: xprt->num_reqs is out of range!\n", __func__);
 	if (!atomic_add_unless(&xprt->num_reqs, 1, xprt->max_reqs))
 		goto out;
 	req = kzalloc(sizeof(struct rpc_rqst), gfp_flags);
@@ -955,6 +979,8 @@ out:
 
 static bool xprt_dynamic_free_slot(struct rpc_xprt *xprt, struct rpc_rqst *req)
 {
+	if (atomic_read(&xprt->num_reqs) < xprt->min_reqs)
+		pr_err_ratelimited("%s: xprt->num_reqs is out of range!\n", __func__);
 	if (atomic_add_unless(&xprt->num_reqs, -1, xprt->min_reqs)) {
 		kfree(req);
 		return true;
@@ -1042,6 +1068,8 @@ struct rpc_xprt *xprt_alloc(struct net *net, size_t size,
 		xprt->max_reqs = num_prealloc;
 	xprt->min_reqs = num_prealloc;
 	atomic_set(&xprt->num_reqs, num_prealloc);
+	if (num_prealloc < 1)
+		pr_err("%s: too few preallocated slots!\n", __func__);
 
 	return xprt;
 
-- 
1.7.7.3



-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

