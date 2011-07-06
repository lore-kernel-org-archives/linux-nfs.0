Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52534 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894Ab1GFWtt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2011 18:49:49 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC] sunrpc:  Fix race between work-queue and rpc_killall_tasks.
Date: Wed,  6 Jul 2011 15:49:41 -0700
Message-Id: <1309992581-25199-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

The rpc_killall_tasks logic is not locked against
the work-queue thread, but it still directly modifies
function pointers and data in the task objects.

This patch changes the killall-tasks logic to set a flag
that tells the work-queue thread to terminate the task
instead of directly calling the terminate logic.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---

NOTE:  This needs review, as I am still struggling to understand
the rpc code, and it's quite possible this patch either doesn't
fully fix the problem or actually causes other issues.  That said,
my nfs stress test seems to run a bit more stable with this patch applied.

:100644 100644 fe2d8e6... b238944... M	include/linux/sunrpc/sched.h
:100644 100644 8c91415... 6851f84... M	net/sunrpc/clnt.c
:100644 100644 1cbbed5... 0fc559e... M	net/sunrpc/sched.c
 include/linux/sunrpc/sched.h |   10 ++++++++++
 net/sunrpc/clnt.c            |    3 +--
 net/sunrpc/sched.c           |    6 ++++++
 3 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index fe2d8e6..b238944 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -76,6 +76,7 @@ struct rpc_task {
 
 	pid_t			tk_owner;	/* Process id for batching tasks */
 	int			tk_status;	/* result of last operation */
+	int			tk_killme_errno;/* For RPC_TASK_KILLME */
 	unsigned short		tk_flags;	/* misc flags */
 	unsigned short		tk_timeouts;	/* maj timeouts */
 
@@ -130,6 +131,7 @@ struct rpc_task_setup {
 #define RPC_TASK_SOFTCONN	0x0400		/* Fail if can't connect */
 #define RPC_TASK_SENT		0x0800		/* message was sent */
 #define RPC_TASK_TIMEOUT	0x1000		/* fail with ETIMEDOUT on timeout */
+#define RPC_TASK_KILLME		0x2000		/* Need to die ASAP. */
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
@@ -138,6 +140,7 @@ struct rpc_task_setup {
 #define RPC_IS_SOFT(t)		((t)->tk_flags & (RPC_TASK_SOFT|RPC_TASK_TIMEOUT))
 #define RPC_IS_SOFTCONN(t)	((t)->tk_flags & RPC_TASK_SOFTCONN)
 #define RPC_WAS_SENT(t)		((t)->tk_flags & RPC_TASK_SENT)
+#define RPC_SHOULD_KILLME(t)	((t)->tk_flags & RPC_TASK_KILLME)
 
 #define RPC_TASK_RUNNING	0
 #define RPC_TASK_QUEUED		1
@@ -269,4 +272,11 @@ static inline const char * rpc_qname(struct rpc_wait_queue *q)
 }
 #endif
 
+static inline void rpc_task_killme(struct rpc_task *task, int exit_errno)
+{
+	task->tk_killme_errno = exit_errno;
+	task->tk_flags |= RPC_TASK_KILLME;
+}
+
+
 #endif /* _LINUX_SUNRPC_SCHED_H_ */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8c91415..6851f84 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -437,8 +437,7 @@ void rpc_killall_tasks(struct rpc_clnt *clnt)
 		if (!RPC_IS_ACTIVATED(rovr))
 			continue;
 		if (!(rovr->tk_flags & RPC_TASK_KILLED)) {
-			rovr->tk_flags |= RPC_TASK_KILLED;
-			rpc_exit(rovr, -EIO);
+			rpc_task_killme(rovr, -EIO);
 			if (RPC_IS_QUEUED(rovr))
 				rpc_wake_up_queued_task(rovr->tk_waitqueue,
 							rovr);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 1cbbed5..0fc559e 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -646,6 +646,12 @@ static void __rpc_execute(struct rpc_task *task)
 			task->tk_action(task);
 		}
 
+		/* If we should die, do it now. */
+		if (RPC_SHOULD_KILLME(task)) {
+			task->tk_flags |= RPC_TASK_KILLED;
+			rpc_exit(task, task->tk_killme_errno);
+		}
+
 		/*
 		 * Lockless check for whether task is sleeping or not.
 		 */
-- 
1.7.3.4

