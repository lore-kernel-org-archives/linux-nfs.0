From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/10] SUNRPC: Convert users of rpc_wake_up_task to use
	rpc_wake_up_queued_task
Date: Tue, 26 Feb 2008 09:23:08 -0800
Message-ID: <20080226172308.10383.97418.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080226172308.10383.49081.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12275 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752868AbYBZXit (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Feb 2008 18:38:49 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m1QNcmwr027332
	for <linux-nfs@vger.kernel.org>; Tue, 26 Feb 2008 15:38:49 -0800 (PST)
In-Reply-To: <20080226172308.10383.49081.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c            |    2 +-
 include/linux/sunrpc/sched.h |    1 -
 net/sunrpc/clnt.c            |    2 +-
 net/sunrpc/sched.c           |    3 +--
 net/sunrpc/xprt.c            |   10 +++++-----
 5 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b6db833..5474339 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2768,7 +2768,7 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server)
 			rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL, NULL);
 			nfs4_schedule_state_recovery(clp);
 			if (test_bit(NFS4CLNT_STATE_RECOVER, &clp->cl_state) == 0)
-				rpc_wake_up_task(task);
+				rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
 			task->tk_status = 0;
 			return -EAGAIN;
 		case -NFS4ERR_DELAY:
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 83f6777..7963ef0 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -232,7 +232,6 @@ void		rpc_init_priority_wait_queue(struct rpc_wait_queue *, const char *);
 void		rpc_init_wait_queue(struct rpc_wait_queue *, const char *);
 void		rpc_sleep_on(struct rpc_wait_queue *, struct rpc_task *,
 					rpc_action action, rpc_action timer);
-void		rpc_wake_up_task(struct rpc_task *);
 void		rpc_wake_up_queued_task(struct rpc_wait_queue *,
 					struct rpc_task *);
 void		rpc_wake_up(struct rpc_wait_queue *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index fe95bd0..0e209af 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1066,7 +1066,7 @@ call_transmit(struct rpc_task *task)
 	if (task->tk_msg.rpc_proc->p_decode != NULL)
 		return;
 	task->tk_action = rpc_exit_task;
-	rpc_wake_up_task(task);
+	rpc_wake_up_queued_task(&task->tk_xprt->pending, task);
 }
 
 /*
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 9233ace..35acdc3 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -417,11 +417,10 @@ EXPORT_SYMBOL_GPL(rpc_wake_up_queued_task);
 /*
  * Wake up the specified task
  */
-void rpc_wake_up_task(struct rpc_task *task)
+static void rpc_wake_up_task(struct rpc_task *task)
 {
 	rpc_wake_up_queued_task(task->tk_waitqueue, task);
 }
-EXPORT_SYMBOL_GPL(rpc_wake_up_task);
 
 /*
  * Wake up the next task on a priority queue.
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 96c212d..6e27722 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -472,7 +472,7 @@ void xprt_write_space(struct rpc_xprt *xprt)
 	if (xprt->snd_task) {
 		dprintk("RPC:       write space: waking waiting task on "
 				"xprt %p\n", xprt);
-		rpc_wake_up_task(xprt->snd_task);
+		rpc_wake_up_queued_task(&xprt->pending, xprt->snd_task);
 	}
 	spin_unlock_bh(&xprt->transport_lock);
 }
@@ -602,8 +602,7 @@ void xprt_force_disconnect(struct rpc_xprt *xprt)
 	/* Try to schedule an autoclose RPC call */
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
 		queue_work(rpciod_workqueue, &xprt->task_cleanup);
-	else if (xprt->snd_task != NULL)
-		rpc_wake_up_task(xprt->snd_task);
+	xprt_wake_pending_tasks(xprt, -ENOTCONN);
 	spin_unlock_bh(&xprt->transport_lock);
 }
 EXPORT_SYMBOL_GPL(xprt_force_disconnect);
@@ -749,18 +748,19 @@ EXPORT_SYMBOL_GPL(xprt_update_rtt);
 void xprt_complete_rqst(struct rpc_task *task, int copied)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_xprt *xprt = req->rq_xprt;
 
 	dprintk("RPC: %5u xid %08x complete (%d bytes received)\n",
 			task->tk_pid, ntohl(req->rq_xid), copied);
 
-	task->tk_xprt->stat.recvs++;
+	xprt->stat.recvs++;
 	task->tk_rtt = (long)jiffies - req->rq_xtime;
 
 	list_del_init(&req->rq_list);
 	/* Ensure all writes are done before we update req->rq_received */
 	smp_wmb();
 	req->rq_received = req->rq_private_buf.len = copied;
-	rpc_wake_up_task(task);
+	rpc_wake_up_queued_task(&xprt->pending, task);
 }
 EXPORT_SYMBOL_GPL(xprt_complete_rqst);
 

