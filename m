From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/14] SUNRPC: Debugging aid
Date: Thu, 18 Jan 2007 18:31:00 -0500
Message-ID: <20070118233100.23310.25683.stgit@localhost.localdomain>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7giu-0002v2-0D
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:31:12 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7giv-0003V2-Ah
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:31:13 -0800
To: trond.myklybust@fys.uio.no
In-Reply-To: <20070118232356.23310.6705.stgit@localhost.localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Add helper functions for tracking the current FSM state for each RPC task.
The FSM state name is now displayed in rpc_show_task instead of the
absolute address of the FSM function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/sched.h |   13 ++++++++++++-
 net/sunrpc/clnt.c            |   35 ++++++++++++++++++++++++++++++++++-
 net/sunrpc/sched.c           |   11 ++++++++---
 3 files changed, 54 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 88e6e39..7732e80 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -95,7 +95,8 @@ #endif
 	long			tk_rtt;		/* round-trip time (jiffies) */
 
 #ifdef RPC_DEBUG
-	unsigned short		tk_pid;		/* debugging aid */
+	unsigned short		tk_pid;
+	const char *		tk_action_name;
 #endif
 };
 #define tk_auth			tk_client->cl_auth
@@ -292,6 +293,16 @@ static inline const char * rpc_qname(str
 {
 	return ((q && q->name) ? q->name : "unknown");
 }
+
+#define __rpc_new_task_state(t, n)				\
+	do {							\
+		t->tk_action_name = n ;				\
+	} while (0)
+#else
+#define __rpc_new_task_state(t, n)	do { } while (0)
 #endif
 
+#define rpc_new_task_state()					\
+	__rpc_new_task_state(task, __FUNCTION__)
+
 #endif /* _LINUX_SUNRPC_SCHED_H_ */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index eafe045..f4d2bc6 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -42,7 +42,7 @@ #endif
 
 #define dprint_status(t)					\
 	dprintk("RPC: %5u %s (status %d)\n", t->tk_pid,		\
-			__FUNCTION__, t->tk_status)
+			__FUNCTION__, t->tk_status)		\
 
 static DECLARE_WAIT_QUEUE_HEAD(destroy_wait);
 
@@ -552,6 +552,8 @@ out_release:
 void
 rpc_call_setup(struct rpc_task *task, struct rpc_message *msg, int flags)
 {
+	rpc_new_task_state();
+
 	task->tk_msg   = *msg;
 	task->tk_flags |= flags;
 	/* Bind the user cred */
@@ -662,6 +664,8 @@ call_start(struct rpc_task *task)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 
+	rpc_new_task_state();
+
 	dprintk("RPC: %5u call_start %s%d proc %d (%s)\n", task->tk_pid,
 			clnt->cl_protname, clnt->cl_vers,
 			task->tk_msg.rpc_proc->p_proc,
@@ -679,6 +683,8 @@ call_start(struct rpc_task *task)
 static void
 call_reserve(struct rpc_task *task)
 {
+	rpc_new_task_state();
+
 	dprint_status(task);
 
 	if (!rpcauth_uptodatecred(task)) {
@@ -699,6 +705,8 @@ call_reserveresult(struct rpc_task *task
 {
 	int status = task->tk_status;
 
+	rpc_new_task_state();
+
 	dprint_status(task);
 
 	/*
@@ -752,6 +760,8 @@ call_allocate(struct rpc_task *task)
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = task->tk_xprt;
 
+	rpc_new_task_state();
+
 	dprint_status(task);
 
 	task->tk_status = 0;
@@ -862,6 +872,8 @@ call_bind(struct rpc_task *task)
 {
 	struct rpc_xprt *xprt = task->tk_xprt;
 
+	rpc_new_task_state();
+
 	dprint_status(task);
 
 	task->tk_action = call_connect;
@@ -880,6 +892,8 @@ call_bind_status(struct rpc_task *task)
 {
 	int status = -EACCES;
 
+	rpc_new_task_state();
+
 	if (task->tk_status >= 0) {
 		dprint_status(task);
 		task->tk_status = 0;
@@ -928,6 +942,8 @@ call_connect(struct rpc_task *task)
 {
 	struct rpc_xprt *xprt = task->tk_xprt;
 
+	rpc_new_task_state();
+
 	dprintk("RPC: %5u call_connect xprt %p %s connected\n",
 			task->tk_pid, xprt,
 			(xprt_connected(xprt) ? "is" : "is not"));
@@ -950,6 +966,8 @@ call_connect_status(struct rpc_task *tas
 	struct rpc_clnt *clnt = task->tk_client;
 	int status = task->tk_status;
 
+	rpc_new_task_state();
+
 	dprint_status(task);
 
 	task->tk_status = 0;
@@ -982,6 +1000,8 @@ call_connect_status(struct rpc_task *tas
 static void
 call_transmit(struct rpc_task *task)
 {
+	rpc_new_task_state();
+
 	dprint_status(task);
 
 	task->tk_action = call_status;
@@ -1019,7 +1039,10 @@ call_transmit(struct rpc_task *task)
 static void
 call_transmit_status(struct rpc_task *task)
 {
+	rpc_new_task_state();
+
 	task->tk_action = call_status;
+
 	/*
 	 * Special case: if we've been waiting on the socket's write_space()
 	 * callback, then don't call xprt_end_transmit().
@@ -1040,6 +1063,8 @@ call_status(struct rpc_task *task)
 	struct rpc_rqst	*req = task->tk_rqstp;
 	int		status;
 
+	rpc_new_task_state();
+
 	if (req->rq_received > 0 && !req->rq_bytes_sent)
 		task->tk_status = req->rq_received;
 
@@ -1093,6 +1118,8 @@ call_timeout(struct rpc_task *task)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 
+	rpc_new_task_state();
+
 	if (xprt_adjust_timeout(task->tk_rqstp) == 0) {
 		dprintk("RPC: %5u call_timeout (minor)\n", task->tk_pid);
 		goto retry;
@@ -1132,6 +1159,8 @@ call_decode(struct rpc_task *task)
 	kxdrproc_t	decode = task->tk_msg.rpc_proc->p_decode;
 	__be32		*p;
 
+	rpc_new_task_state();
+
 	dprintk("RPC: %5u call_decode (status %d)\n",
 			task->tk_pid, task->tk_status);
 
@@ -1194,6 +1223,8 @@ out_retry:
 static void
 call_refresh(struct rpc_task *task)
 {
+	rpc_new_task_state();
+
 	dprint_status(task);
 
 	xprt_release(task);	/* Must do to obtain new XID */
@@ -1211,6 +1242,8 @@ call_refreshresult(struct rpc_task *task
 {
 	int status = task->tk_status;
 
+	rpc_new_task_state();
+
 	dprint_status(task);
 
 	task->tk_status = 0;
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index c689196..b712317 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -590,6 +590,8 @@ void rpc_delay(struct rpc_task *task, un
  */
 static void rpc_prepare_task(struct rpc_task *task)
 {
+	rpc_new_task_state();
+
 	lock_kernel();
 	task->tk_ops->rpc_call_prepare(task, task->tk_calldata);
 	unlock_kernel();
@@ -602,6 +604,7 @@ void rpc_exit_task(struct rpc_task *task
 {
 	task->tk_action = NULL;
 	if (task->tk_ops->rpc_call_done != NULL) {
+		rpc_new_task_state();
 		lock_kernel();
 		task->tk_ops->rpc_call_done(task, task->tk_calldata);
 		unlock_kernel();
@@ -611,6 +614,7 @@ void rpc_exit_task(struct rpc_task *task
 			xprt_release(task);
 		}
 	}
+	__rpc_new_task_state(task, "done");
 }
 EXPORT_SYMBOL(rpc_exit_task);
 
@@ -785,6 +789,7 @@ void rpc_free(struct rpc_task *task, voi
 void rpc_init_task(struct rpc_task *task, struct rpc_clnt *clnt, int flags, const struct rpc_call_ops *tk_ops, void *calldata)
 {
 	memset(task, 0, sizeof(*task));
+	rpc_new_task_state();
 	init_timer(&task->tk_timer);
 	task->tk_timer.data     = (unsigned long) task;
 	task->tk_timer.function = (void (*)(unsigned long)) rpc_run_timer;
@@ -1059,14 +1064,14 @@ void rpc_show_tasks(void)
 		return;
 	}
 	printk("-pid- proc flgs status -client- -prog- --rqstp- -timeout "
-		"-rpcwait -action- ---ops--\n");
+		"---rpcwait-- ---ops-- -----action----- \n");
 	alltask_for_each(t, le, &all_tasks) {
 		const char *rpc_waitq = "none";
 
 		if (RPC_IS_QUEUED(t))
 			rpc_waitq = rpc_qname(t->u.tk_wait.rpc_waitq);
 
-		printk("%5u %04d %04x %6d %8p %6d %8p %8ld %8s %8p %8p\n",
+		printk("%5u %04d %04x %6d %8p %6d %8p %8ld %12.12s %8p %16.16s\n",
 			t->tk_pid,
 			(t->tk_msg.rpc_proc ? t->tk_msg.rpc_proc->p_proc : -1),
 			t->tk_flags, t->tk_status,
@@ -1074,7 +1079,7 @@ void rpc_show_tasks(void)
 			(t->tk_client ? t->tk_client->cl_prog : 0),
 			t->tk_rqstp, t->tk_timeout,
 			rpc_waitq,
-			t->tk_action, t->tk_ops);
+			t->tk_ops, t->tk_action_name);
 	}
 	spin_unlock(&rpc_sched_lock);
 }

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
