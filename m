Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58202 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932787AbbFEPBw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2015 11:01:52 -0400
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
Subject: [RFC PATCH 02/18] kthread: Add API for iterant kthreads
Date: Fri,  5 Jun 2015 17:01:01 +0200
Message-Id: <1433516477-5153-3-git-send-email-pmladek@suse.cz>
In-Reply-To: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kthreads are implemented as an infinite loop. They include check points
for termination, freezer, parking, and even signal handling.

In many cases there are some operations done before and after
the main cycle.

We need to touch all kthreads everytime we want to add or
modify the behavior of such checkpoints. It is not easy because
there are several hundreds of kthreads and each of them is
implemented slightly different way.

This anarchy brings potentially broken or non-standard behavior.
For example, few kthreads associated strange behavior to signals.

This patch defines new API that will help to standardize
kthreads and move all checkpoints to a single location.

The initial implementation allows to define functions that are
called before, in, and after the main cycle. It defines the common
checkpoint for freezing and ktherad stopping. The support for
parking and signal handling will be added later.

It will be sufficient for many kthreads. And it is ready for more
features that will be needed for the rest. For example, some kthreads
might want to call special functions after a return from the fridge.

Why new API?

First, we do not want to add yet another API that would need
to be supported. The aim is to _replace_ the current API,
split the monolithic threadfn, and define a standard structure
of the main cycle and standardize the related check points.
Well, the old API would need to stay around for some time until
all kthreads are converted.

Second, there are two more existing alternatives. They fulfill
the needs, will be used for some conversions, but they are not
well usable in all cases. Let's talk more about them.

Workqueue

Workqueues are quite popular and many kthreads have already been
converted into them.

Work queues allow to split the function into even more pieces and
reach the common check point more often. It is especially useful
when a kthread handles more tasks and is waken when some work
is needed. Then we could queue the appropriate work instead
of waking the whole kthread and checking what exactly needs
to be done.

But there are many kthreads that need to cycle many times
until some work is finished, e.g. khugepaged, virtio_balloon,
jffs2_garbage_collect_thread. They would need to queue
the work repeatedly or between more work items. It would be
a strange semantic. Note that we need to queue the work
repeatedly when it needs to be called in a cycle.

Work queues allow to share the same kthread between more users.
It helps to reduce the number of running kthreads. It is especially
useful if you would need a kthread for each CPU.

But this might also be a disadvantage. Just look into the output
of the command "ps" and see the many [kworker*] processes. One
might see this a black hole. If a kworker makes the system busy,
it is less obvious what the problem is in compare with the old
"simple" and dedicated kthreads.

Yes, we could add some debugging tools for work queues but
it would be another non-standard thing that developers and
system administrators would need to understand.

Another thing is that work queues have their own scheduler. If we
move even more tasks there it might need even more love. Anyway,
the extra scheduler adds another level of complexity when
debugging problems.

kthread_worker

kthread_worker is similar to workqueues in many ways. You need to

  + define work functions
  + define and initialize work structs
  + queue work items (structs pointing to the functions and data)

We could repeat here the paragraphs about splitting the work
and sharing the kthread between more users.

The kthread_worker implementation is much simpler than
the one for workqueues. It is more similar to a simple
kthread. Especially, it uses the system scheduler.
But it is still more complex that the simple kthread.

One interesting thing is that kthread_workers add internal work
items into the queue. They typically use a completion. An example
is the flush work. It is a nice trick but you need to be careful.
For example, if you would want to terminate the kthread, you might
want remove some work item from the queue, especially if you need
to break a work item that is called in a cycle (queues itself).
The question is what to do with the internal tasks. If you keep
them, they might wake up sleepers when the work was not really
completed. If you remove them, the counter part might sleep
forever.

Conclusion

The aim of the new API is to provide a simple and straightforward API
to create dedicated kthreads. It will split the current monolithic
function into few well defined pieces. This might look as a small
complication. But it will also move the typical checks into a common
place. This will reduce the complexity of the kthreads and will
allow to do the checks properly and maintain them more easily.

Signed-off-by: Petr Mladek <pmladek@suse.cz>
---
 include/linux/kthread.h | 48 ++++++++++++++++++++++++++++++
 kernel/kthread.c        | 78 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 126 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 13d55206ccf6..06fe9ad192dd 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -4,6 +4,9 @@
 #include <linux/err.h>
 #include <linux/sched.h>
 
+/*
+ * Old API that defines kthreads using a single function.
+ */
 __printf(4, 5)
 struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
 					   void *data,
@@ -37,6 +40,51 @@ struct task_struct *kthread_create_on_cpu(int (*threadfn)(void *data),
 	__k;								   \
 })
 
+/*
+ * New API that allows to create kthreads with a clear semantic. It defines
+ * functions that are called inside the kthread. The functions must return
+ * in a consistent state so that the kthread can get frozen, parked,
+ * and even signals processed between the calls. It means that all locks
+ * must be released and non-interruptible work finished.
+ */
+
+/**
+ * struct kthread_iterant - structure describing the function of the kthread
+ * @data: pointer to a data passed to the functions.
+ * @init: function called when the kthread is created.
+ * @func: function called in the main cycle until the kthread is terminated.
+ * @destroy: function called when the kthread is being terminated.
+ */
+struct kthread_iterant {
+	void *data;
+	void (*init)(void *data);
+	void (*func)(void *data);
+	void (*destroy)(void *data);
+};
+
+__printf(3, 4)
+struct task_struct *
+kthread_iterant_create_on_node(struct kthread_iterant *kti,
+			       int node,
+			       const char namefmt[], ...);
+
+#define kthread_iterant_create(kti, namefmt, arg...)		\
+	kthread_iterant_create_on_node(kti, -1, namefmt, ##arg)
+
+struct task_struct *
+kthread_iterant_create_on_cpu(struct kthread_iterant *kti,
+			      unsigned int cpu,
+			      const char *namefmt);
+
+#define kthread_iterant_run(kti, namefmt, ...)			   \
+({									   \
+	struct task_struct *__k						   \
+		= kthread_iterant_create(kti, namefmt, ## __VA_ARGS__); \
+	if (!IS_ERR(__k))						   \
+		wake_up_process(__k);					   \
+	__k;								   \
+})
+
 void kthread_bind(struct task_struct *k, unsigned int cpu);
 int kthread_stop(struct task_struct *k);
 bool kthread_should_stop(void);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index fca7cd124512..4b2698bcc622 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -393,6 +393,84 @@ struct task_struct *kthread_create_on_cpu(int (*threadfn)(void *data),
 	return p;
 }
 
+/**
+ * kthread_iterant_fn - kthread function to process an iterant kthread
+ * @kti_ptr: pointer to an initialized struct kthread_iterant.
+ *
+ * This function defines the work flow of iterant kthreads. It calls
+ * the given callbacks. Also it defines and implements a common
+ * check point for freezing and stopping.
+ */
+static int kthread_iterant_fn(void *kti_ptr)
+{
+	struct kthread_iterant *kti = kti_ptr;
+	void *data = kti->data;
+
+	if (kti->init)
+		kti->init(data);
+
+	do {
+		if (kti->func)
+			kti->func(data);
+
+	/* this check is safe also for non-freezable kthreads */
+	} while (!kthread_freezable_should_stop(NULL));
+
+	if (kti->destroy)
+		kti->destroy(data);
+
+	return 0;
+}
+
+/**
+ * kthread_iterant_create_on_node - create an iterant kthread.
+ * @kti: structure describing the thread function.
+ * @node: memory node number.
+ * @namefmt: printf-style name for the thread.
+ *
+ * Description: This helper function creates and names an iterant kernel
+ * thread. The thread will be stopped: use wake_up_process() to start
+ * it. See also kthread_iterant_run().
+ *
+ * It behaves the same as kthread_create_on_node(). The only difference
+ * is that the function is described using struct kthread_iterant.
+ */
+struct task_struct *
+kthread_iterant_create_on_node(struct kthread_iterant *kti,
+			       int node,
+			       const char namefmt[], ...)
+{
+	struct task_struct *task;
+	va_list args;
+
+	va_start(args, namefmt);
+	task = __kthread_create_on_node(kthread_iterant_fn, kti, node,
+					namefmt, args);
+	va_end(args);
+
+	return task;
+}
+EXPORT_SYMBOL(kthread_iterant_create_on_node);
+
+/**
+ * kthread_iterant_create_on_cpu - Create a cpu bound iterant kthread
+ * @kti: structure describing the function.
+ * @cpu: The cpu on which the thread should be bound,
+ * @namefmt: printf-style name for the thread. Format is restricted
+ *	to "name.*%u". Code fills in cpu number.
+ *
+ * Description: This helper function creates and names an iterant kernel
+ * thread. The thread will be woken and put into park mode.
+ */
+struct task_struct *
+kthread_iterant_create_on_cpu(struct kthread_iterant *kti,
+			      unsigned int cpu,
+			      const char *namefmt)
+{
+	return kthread_create_on_cpu(kthread_iterant_fn, kti,
+				     cpu, namefmt);
+}
+
 static void __kthread_unpark(struct task_struct *k, struct kthread *kthread)
 {
 	clear_bit(KTHREAD_SHOULD_PARK, &kthread->flags);
-- 
1.8.5.6

