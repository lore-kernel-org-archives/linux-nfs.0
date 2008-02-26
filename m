From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 08/10] SUNRPC: Eliminate the now-redundant
	rpc_start_wakeup()
Date: Tue, 26 Feb 2008 09:23:08 -0800
Message-ID: <20080226172308.10383.3217.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080226172308.10383.49081.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48032 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752438AbYBZXit (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Feb 2008 18:38:49 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m1QNcmFn013361
	for <linux-nfs@vger.kernel.org>; Tue, 26 Feb 2008 15:38:48 -0800 (PST)
In-Reply-To: <20080226172308.10383.49081.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/sched.h |   12 +-----------
 net/sunrpc/sched.c           |    8 ++------
 2 files changed, 3 insertions(+), 17 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 0d7be16..bf69fce 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -142,8 +142,7 @@ struct rpc_task_setup {
 
 #define RPC_TASK_RUNNING	0
 #define RPC_TASK_QUEUED		1
-#define RPC_TASK_WAKEUP		2
-#define RPC_TASK_ACTIVE		3
+#define RPC_TASK_ACTIVE		2
 
 #define RPC_IS_RUNNING(t)	test_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
 #define rpc_set_running(t)	set_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
@@ -165,15 +164,6 @@ struct rpc_task_setup {
 		smp_mb__after_clear_bit(); \
 	} while (0)
 
-#define rpc_start_wakeup(t) \
-	(test_and_set_bit(RPC_TASK_WAKEUP, &(t)->tk_runstate) == 0)
-#define rpc_finish_wakeup(t) \
-	do { \
-		smp_mb__before_clear_bit(); \
-		clear_bit(RPC_TASK_WAKEUP, &(t)->tk_runstate); \
-		smp_mb__after_clear_bit(); \
-	} while (0)
-
 #define RPC_IS_ACTIVATED(t)	test_bit(RPC_TASK_ACTIVE, &(t)->tk_runstate)
 
 /*
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index bb58eb4..0c6fb50 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -376,12 +376,8 @@ static void __rpc_do_wake_up_task(struct rpc_wait_queue *queue, struct rpc_task
  */
 static void rpc_wake_up_task_queue_locked(struct rpc_wait_queue *queue, struct rpc_task *task)
 {
-	if (!RPC_IS_QUEUED(task) || task->tk_waitqueue != queue)
-		return;
-	if (rpc_start_wakeup(task)) {
-			__rpc_do_wake_up_task(queue, task);
-		rpc_finish_wakeup(task);
-	}
+	if (RPC_IS_QUEUED(task) && task->tk_waitqueue == queue)
+		__rpc_do_wake_up_task(queue, task);
 }
 
 /*

