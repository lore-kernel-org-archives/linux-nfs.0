Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:55283 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966094Ab2ERUQe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2012 16:16:34 -0400
Received: by qabj40 with SMTP id j40so660260qab.1
        for <linux-nfs@vger.kernel.org>; Fri, 18 May 2012 13:16:33 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: andros@netapp.com, linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: fix loss of task->tk_status after rpc_delay call in xprt_alloc_slot
Date: Fri, 18 May 2012 16:16:28 -0400
Message-Id: <1337372188-5565-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xprt_alloc_slot will call rpc_delay() to make the task wait a bit before
retrying when it gets back an -ENOMEM error from xprt_dynamic_alloc_slot.

The problem there is that rpc_delay does this:

    rpc_sleep_on(&delay_queue, task, __rpc_atrun);

...and __rpc_atrun will reset the task->tk_status back to 0 when the
task wakes back up. This makes call_reserveresult abort the task with
-EIO.

The RH QA group discovered this problem when testing with low-memory
clients and this patch fixed it:

    https://bugzilla.redhat.com/show_bug.cgi?id=822189

Fix this by adding a new rpc_delay_action() variant that makes allows
us to pass in a rpc_action to reset the status back to -EAGAIN instead.

Cc: Andy Adamson <andros@netapp.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/sched.h |    1 +
 net/sunrpc/sched.c           |    9 +++++++--
 net/sunrpc/xprt.c            |    7 ++++++-
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index dc0c3cc..6cafdbb 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -241,6 +241,7 @@ struct rpc_task *rpc_wake_up_first(struct rpc_wait_queue *,
 					void *);
 void		rpc_wake_up_status(struct rpc_wait_queue *, int);
 int		rpc_queue_empty(struct rpc_wait_queue *);
+void		rpc_delay_action(struct rpc_task *, unsigned long, rpc_action);
 void		rpc_delay(struct rpc_task *, unsigned long);
 void *		rpc_malloc(struct rpc_task *, size_t);
 void		rpc_free(void *);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 994cfea..f2ff98d 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -613,13 +613,18 @@ static void __rpc_atrun(struct rpc_task *task)
 	task->tk_status = 0;
 }
 
+void rpc_delay_action(struct rpc_task *task, unsigned long delay, rpc_action action)
+{
+	task->tk_timeout = delay;
+	rpc_sleep_on(&delay_queue, task, action);
+}
+
 /*
  * Run a task at a later time
  */
 void rpc_delay(struct rpc_task *task, unsigned long delay)
 {
-	task->tk_timeout = delay;
-	rpc_sleep_on(&delay_queue, task, __rpc_atrun);
+	rpc_delay_action(task, delay, __rpc_atrun);
 }
 EXPORT_SYMBOL_GPL(rpc_delay);
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index b239e75..a5dc816 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -969,6 +969,11 @@ static bool xprt_dynamic_free_slot(struct rpc_xprt *xprt, struct rpc_rqst *req)
 	return false;
 }
 
+static void xprt_alloc_delay_reset_status(struct rpc_task *task)
+{
+	task->tk_status = -EAGAIN;
+}
+
 static void xprt_alloc_slot(struct rpc_task *task)
 {
 	struct rpc_xprt	*xprt = task->tk_xprt;
@@ -984,7 +989,7 @@ static void xprt_alloc_slot(struct rpc_task *task)
 		goto out_init_req;
 	switch (PTR_ERR(req)) {
 	case -ENOMEM:
-		rpc_delay(task, HZ >> 2);
+		rpc_delay_action(task, HZ >> 2, xprt_alloc_delay_reset_status);
 		dprintk("RPC:       dynamic allocation of request slot "
 				"failed! Retrying\n");
 		break;
-- 
1.7.7.6

