From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 42/85] nfs41: sunrpc: Export the call prepare state for session reset
Date: Mon, 10 Nov 2008 22:25:35 +0200
Message-ID: <1226348735-8625-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48838 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbYKJUZl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:25:41 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
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
index 77c03a4..c6a1179 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -151,6 +151,7 @@ int		rpc_call_sync(struct rpc_clnt *clnt,
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
index 0c8e5f1..c31ded3 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -684,6 +684,19 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
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
index 385f427..e476aae 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -574,7 +574,7 @@ EXPORT_SYMBOL_GPL(rpc_delay);
 /*
  * Helper to call task->tk_ops->rpc_call_prepare
  */
-static void rpc_prepare_task(struct rpc_task *task)
+void rpc_prepare_task(struct rpc_task *task)
 {
 	task->tk_ops->rpc_call_prepare(task, task->tk_calldata);
 }
-- 
1.6.0.2

