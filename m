From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: kernel BUG at kernel/workqueue.c:291
Date: Tue, 03 Mar 2009 16:21:48 -0500
Message-ID: <1236115308.9631.97.camel@heimdal.trondhjem.org>
References: <49A84376.6030800@aei.mpg.de> <49ABBA44.1060302@aei.mpg.de>
	 <20090302232643.7c7ca284.akpm@linux-foundation.org>
	 <1236093413.9631.58.camel@heimdal.trondhjem.org>
	 <49AD4B55.5060504@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:45647 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752944AbZCCVV4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2009 16:21:56 -0500
In-Reply-To: <49AD4B55.5060504-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-03-03 at 16:23 +0100, Carsten Aulbert wrote:
> Hi Trond,
> 
> Trond Myklebust schrieb:
> > struct rpc_task does admittedly share storage for the work queue and the
> > rpc wait queue links, but if that were to be causing the reported
> > corruption, then it would mean that an rpc_task is simultaneously on a
> > wait queue and trying to execute on a work queue. I have no history of
> > that ever having happened.
> 
> Anything I might be able to give to you helping you to narrow it down
> somewhat? As written I suspect a certain type of user jobs, but since
> literally 1000s of these ran over the course of several days it might be
> hard to trigger this reliably again.

Could you try triggering it after applying the following patch? I think
I've spotted a potential race condition.

Cheers
  Trond
---------------------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
SUNRPC: Tighten up the task locking rules in __rpc_execute()

We should probably not be testing any flags after we've cleared the
RPC_TASK_RUNNING flag, since rpc_make_runnable() is then free to assign the
rpc_task to another workqueue, which may then destroy it.

We can fix any races with rpc_make_runnable() by ensuring that we only
clear the RPC_TASK_RUNNING flag while holding the rpc_wait_queue->lock that
the task is supposed to be sleeping on (and then checking whether or not
the task really is sleeping).

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/sched.c |   33 ++++++++++++++++++++-------------
 1 files changed, 20 insertions(+), 13 deletions(-)


diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 385f427..ff50a05 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -293,11 +293,6 @@ static void rpc_make_runnable(struct rpc_task *task)
 	rpc_clear_queued(task);
 	if (rpc_test_and_set_running(task))
 		return;
-	/* We might have raced */
-	if (RPC_IS_QUEUED(task)) {
-		rpc_clear_running(task);
-		return;
-	}
 	if (RPC_IS_ASYNC(task)) {
 		int status;
 
@@ -607,7 +602,9 @@ void rpc_release_calldata(const struct rpc_call_ops *ops, void *calldata)
  */
 static void __rpc_execute(struct rpc_task *task)
 {
-	int		status = 0;
+	struct rpc_wait_queue *queue;
+	int task_is_async = RPC_IS_ASYNC(task);
+	int status = 0;
 
 	dprintk("RPC: %5u __rpc_execute flags=0x%x\n",
 			task->tk_pid, task->tk_flags);
@@ -647,15 +644,25 @@ static void __rpc_execute(struct rpc_task *task)
 		 */
 		if (!RPC_IS_QUEUED(task))
 			continue;
-		rpc_clear_running(task);
-		if (RPC_IS_ASYNC(task)) {
-			/* Careful! we may have raced... */
-			if (RPC_IS_QUEUED(task))
-				return;
-			if (rpc_test_and_set_running(task))
-				return;
+		/*
+		 * The queue->lock protects against races with
+		 * rpc_make_runnable().
+		 *
+		 * Note that once we clear RPC_TASK_RUNNING on an asynchronous
+		 * rpc_task, rpc_make_runnable() can assign it to a
+		 * different workqueue. We therefore cannot assume that the
+		 * rpc_task pointer may still be dereferenced.
+		 */
+		queue = task->tk_waitqueue;
+		spin_lock_bh(&queue->lock);
+		if (!RPC_IS_QUEUED(task)) {
+			spin_unlock_bh(&queue->lock);
 			continue;
 		}
+		rpc_clear_running(task);
+		spin_unlock_bh(&queue->lock);
+		if (task_is_async)
+			return;
 
 		/* sync task: sleep here */
 		dprintk("RPC: %5u sync task going to sleep\n", task->tk_pid);


