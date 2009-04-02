From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 55/67] nfs41: sunrpc: Export the call prepare state for session reset
Date: Thu,  2 Apr 2009 16:58:30 +0300
Message-ID: <1238680710-15121-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:28533 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756964AbZDBN6k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:58:40 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/clnt.h  |    1 +
 include/linux/sunrpc/sched.h |    1 +
 net/sunrpc/clnt.c            |   13 +++++++++++++
 net/sunrpc/sched.c           |    2 +-
 4 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index c39a210..37881f1 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -143,6 +143,7 @@ int		rpc_call_sync(struct rpc_clnt *clnt,
 			      const struct rpc_message *msg, int flags);
 struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred,
 			       int flags);
+void		rpc_restart_call_prepare(struct rpc_task *);
 void		rpc_restart_call(struct rpc_task *);
 void		rpc_setbufsize(struct rpc_clnt *, unsigned int, unsigned int);
 size_t		rpc_max_payload(struct rpc_clnt *);
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 64981a2..1773768 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -237,6 +237,7 @@ void		rpc_show_tasks(void);
 int		rpc_init_mempool(void);
 void		rpc_destroy_mempool(void);
 extern struct workqueue_struct *rpciod_workqueue;
+void		rpc_prepare_task(struct rpc_task *task);
 
 static inline void rpc_exit(struct rpc_task *task, int status)
 {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 5abab09..d00e813 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -695,6 +695,19 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 EXPORT_SYMBOL_GPL(rpc_force_rebind);
 
 /*
+ * Restart an (async) RPC call from the call_prepare state.
+ * Usually called from within the exit handler.
+ */
+void
+rpc_restart_call_prepare(struct rpc_task *task)
+{
+	if (RPC_ASSASSINATED(task))
+		return;
+	task->tk_action = rpc_prepare_task;
+}
+EXPORT_SYMBOL_GPL(rpc_restart_call_prepare);
+
+/*
  * Restart an (async) RPC call. Usually called from within the
  * exit handler.
  */
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index ff50a05..1102ce1 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -569,7 +569,7 @@ EXPORT_SYMBOL_GPL(rpc_delay);
 /*
  * Helper to call task->tk_ops->rpc_call_prepare
  */
-static void rpc_prepare_task(struct rpc_task *task)
+void rpc_prepare_task(struct rpc_task *task)
 {
 	task->tk_ops->rpc_call_prepare(task, task->tk_calldata);
 }
-- 
1.6.2.1

