From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 05/25] SUNRPC: Support for RPC child tasks no longer
	needed
Date: Wed, 09 Aug 2006 10:59:01 -0400
Message-ID: <20060809145901.3914.74335.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApWW-0008L8-64
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 07:59:08 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApWW-0000zo-Gt
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 07:59:08 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
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

The previous patches removed the last user of RPC child tasks, so we can
remove support for child tasks from net/sunrpc/sched.c now.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/sched.h |    5 ---
 net/sunrpc/sched.c           |   82 ------------------------------------------
 2 files changed, 0 insertions(+), 87 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 82a91bb..f399c13 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -127,7 +127,6 @@ struct rpc_call_ops {
  */
 #define RPC_TASK_ASYNC		0x0001		/* is an async task */
 #define RPC_TASK_SWAPPER	0x0002		/* is swapping in/out */
-#define RPC_TASK_CHILD		0x0008		/* is child of other task */
 #define RPC_CALL_MAJORSEEN	0x0020		/* major timeout seen */
 #define RPC_TASK_ROOTCREDS	0x0040		/* force root creds */
 #define RPC_TASK_DYNAMIC	0x0080		/* task was kmalloc'ed */
@@ -136,7 +135,6 @@ #define RPC_TASK_SOFT		0x0200		/* Use so
 #define RPC_TASK_NOINTR		0x0400		/* uninterruptible task */
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
-#define RPC_IS_CHILD(t)		((t)->tk_flags & RPC_TASK_CHILD)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
 #define RPC_DO_ROOTOVERRIDE(t)	((t)->tk_flags & RPC_TASK_ROOTCREDS)
 #define RPC_ASSASSINATED(t)	((t)->tk_flags & RPC_TASK_KILLED)
@@ -253,7 +251,6 @@ struct rpc_task *rpc_new_task(struct rpc
 				const struct rpc_call_ops *ops, void *data);
 struct rpc_task *rpc_run_task(struct rpc_clnt *clnt, int flags,
 				const struct rpc_call_ops *ops, void *data);
-struct rpc_task *rpc_new_child(struct rpc_clnt *, struct rpc_task *parent);
 void		rpc_init_task(struct rpc_task *task, struct rpc_clnt *clnt,
 				int flags, const struct rpc_call_ops *ops,
 				void *data);
@@ -261,8 +258,6 @@ void		rpc_release_task(struct rpc_task *
 void		rpc_exit_task(struct rpc_task *);
 void		rpc_killall_tasks(struct rpc_clnt *);
 int		rpc_execute(struct rpc_task *);
-void		rpc_run_child(struct rpc_task *parent, struct rpc_task *child,
-					rpc_action action);
 void		rpc_init_priority_wait_queue(struct rpc_wait_queue *, const char *);
 void		rpc_init_wait_queue(struct rpc_wait_queue *, const char *);
 void		rpc_sleep_on(struct rpc_wait_queue *, struct rpc_task *,
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 5c3eee7..015ffe4 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -45,12 +45,6 @@ static void			rpciod_killall(void);
 static void			rpc_async_schedule(void *);
 
 /*
- * RPC tasks that create another task (e.g. for contacting the portmapper)
- * will wait on this queue for their child's completion
- */
-static RPC_WAITQ(childq, "childq");
-
-/*
  * RPC tasks sit here while waiting for conditions to improve.
  */
 static RPC_WAITQ(delay_queue, "delayq");
@@ -324,16 +318,6 @@ static void rpc_make_runnable(struct rpc
 }
 
 /*
- * Place a newly initialized task on the workqueue.
- */
-static inline void
-rpc_schedule_run(struct rpc_task *task)
-{
-	rpc_set_active(task);
-	rpc_make_runnable(task);
-}
-
-/*
  * Prepare for sleeping on a wait queue.
  * By always appending tasks to the list we ensure FIFO behavior.
  * NB: An RPC task will only receive interrupt-driven events as long
@@ -933,72 +917,6 @@ struct rpc_task *rpc_run_task(struct rpc
 }
 EXPORT_SYMBOL(rpc_run_task);
 
-/**
- * rpc_find_parent - find the parent of a child task.
- * @child: child task
- * @parent: parent task
- *
- * Checks that the parent task is still sleeping on the
- * queue 'childq'. If so returns a pointer to the parent.
- * Upon failure returns NULL.
- *
- * Caller must hold childq.lock
- */
-static inline struct rpc_task *rpc_find_parent(struct rpc_task *child, struct rpc_task *parent)
-{
-	struct rpc_task	*task;
-	struct list_head *le;
-
-	task_for_each(task, le, &childq.tasks[0])
-		if (task == parent)
-			return parent;
-
-	return NULL;
-}
-
-static void rpc_child_exit(struct rpc_task *child, void *calldata)
-{
-	struct rpc_task	*parent;
-
-	spin_lock_bh(&childq.lock);
-	if ((parent = rpc_find_parent(child, calldata)) != NULL) {
-		parent->tk_status = child->tk_status;
-		__rpc_wake_up_task(parent);
-	}
-	spin_unlock_bh(&childq.lock);
-}
-
-static const struct rpc_call_ops rpc_child_ops = {
-	.rpc_call_done = rpc_child_exit,
-};
-
-/*
- * Note: rpc_new_task releases the client after a failure.
- */
-struct rpc_task *
-rpc_new_child(struct rpc_clnt *clnt, struct rpc_task *parent)
-{
-	struct rpc_task	*task;
-
-	task = rpc_new_task(clnt, RPC_TASK_ASYNC | RPC_TASK_CHILD, &rpc_child_ops, parent);
-	if (!task)
-		goto fail;
-	return task;
-
-fail:
-	parent->tk_status = -ENOMEM;
-	return NULL;
-}
-
-void rpc_run_child(struct rpc_task *task, struct rpc_task *child, rpc_action func)
-{
-	spin_lock_bh(&childq.lock);
-	/* N.B. Is it possible for the child to have already finished? */
-	__rpc_sleep_on(&childq, task, func, NULL);
-	rpc_schedule_run(child);
-	spin_unlock_bh(&childq.lock);
-}
-
 /*
  * Kill all tasks for the given client.
  * XXX: kill their descendants as well?

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
