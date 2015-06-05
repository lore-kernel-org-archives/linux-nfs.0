Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58187 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932631AbbFEPBu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2015 11:01:50 -0400
From: Petr Mladek <pmladek@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>
Cc: Richard Weinberger <richard@nod.at>, Steven Rostedt <rostedt@goodmis.org>,
        David Woodhouse <dwmw2@infradead.org>, linux-mtd@lists.infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        Chris Mason <clm@fb.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>,
        Michal Hocko <mhocko@suse.cz>, live-patching@vger.kernel.org,
        linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
        Petr Mladek <pmladek@suse.cz>
Subject: [RFC PATCH 01/18] kthread: Allow to call __kthread_create_on_node() with va_list args
Date: Fri,  5 Jun 2015 17:01:00 +0200
Message-Id: <1433516477-5153-2-git-send-email-pmladek@suse.cz>
In-Reply-To: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

kthread_create_on_node() implements a bunch of logic to create
the kthread. It is already called by kthread_create_on_cpu().

We are going to add a new API that will allow to standardize kthreads
and define safe points for termination, freezing, parking, and even
signal handling. It will want to call kthread_create_on_node()
with va_list args.

This patch does only a refactoring and does not modify the existing
behavior.

Signed-off-by: Petr Mladek <pmladek@suse.cz>
---
 kernel/kthread.c | 71 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 42 insertions(+), 29 deletions(-)

diff --git a/kernel/kthread.c b/kernel/kthread.c
index 10e489c448fe..fca7cd124512 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -242,32 +242,10 @@ static void create_kthread(struct kthread_create_info *create)
 	}
 }
 
-/**
- * kthread_create_on_node - create a kthread.
- * @threadfn: the function to run until signal_pending(current).
- * @data: data ptr for @threadfn.
- * @node: memory node number.
- * @namefmt: printf-style name for the thread.
- *
- * Description: This helper function creates and names a kernel
- * thread.  The thread will be stopped: use wake_up_process() to start
- * it.  See also kthread_run().
- *
- * If thread is going to be bound on a particular cpu, give its node
- * in @node, to get NUMA affinity for kthread stack, or else give -1.
- * When woken, the thread will run @threadfn() with @data as its
- * argument. @threadfn() can either call do_exit() directly if it is a
- * standalone thread for which no one will call kthread_stop(), or
- * return when 'kthread_should_stop()' is true (which means
- * kthread_stop() has been called).  The return value should be zero
- * or a negative error number; it will be passed to kthread_stop().
- *
- * Returns a task_struct or ERR_PTR(-ENOMEM) or ERR_PTR(-EINTR).
- */
-struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
-					   void *data, int node,
-					   const char namefmt[],
-					   ...)
+static struct task_struct *__kthread_create_on_node(int (*threadfn)(void *data),
+						    void *data, int node,
+						    const char namefmt[],
+						    va_list args)
 {
 	DECLARE_COMPLETION_ONSTACK(done);
 	struct task_struct *task;
@@ -308,11 +286,8 @@ struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
 	task = create->result;
 	if (!IS_ERR(task)) {
 		static const struct sched_param param = { .sched_priority = 0 };
-		va_list args;
 
-		va_start(args, namefmt);
 		vsnprintf(task->comm, sizeof(task->comm), namefmt, args);
-		va_end(args);
 		/*
 		 * root may have changed our (kthreadd's) priority or CPU mask.
 		 * The kernel thread should not inherit these properties.
@@ -323,6 +298,44 @@ struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
 	kfree(create);
 	return task;
 }
+
+
+/**
+ * kthread_create_on_node - create a kthread.
+ * @threadfn: the function to run until signal_pending(current).
+ * @data: data ptr for @threadfn.
+ * @node: memory node number.
+ * @namefmt: printf-style name for the thread.
+ *
+ * Description: This helper function creates and names a kernel
+ * thread.  The thread will be stopped: use wake_up_process() to start
+ * it.  See also kthread_run().
+ *
+ * If thread is going to be bound on a particular cpu, give its node
+ * in @node, to get NUMA affinity for kthread stack, or else give -1.
+ * When woken, the thread will run @threadfn() with @data as its
+ * argument. @threadfn() can either call do_exit() directly if it is a
+ * standalone thread for which no one will call kthread_stop(), or
+ * return when 'kthread_should_stop()' is true (which means
+ * kthread_stop() has been called).  The return value should be zero
+ * or a negative error number; it will be passed to kthread_stop().
+ *
+ * Returns a task_struct or ERR_PTR(-ENOMEM) or ERR_PTR(-EINTR).
+ */
+struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
+					   void *data, int node,
+					   const char namefmt[],
+					   ...)
+{
+	struct task_struct *task;
+	va_list args;
+
+	va_start(args, namefmt);
+	task = __kthread_create_on_node(threadfn, data, node, namefmt, args);
+	va_end(args);
+
+	return task;
+}
 EXPORT_SYMBOL(kthread_create_on_node);
 
 static void __kthread_bind(struct task_struct *p, unsigned int cpu, long state)
-- 
1.8.5.6

