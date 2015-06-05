Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58232 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933469AbbFEPCB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2015 11:02:01 -0400
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
Subject: [RFC PATCH 09/18] kthread: Make it easier to correctly sleep in iterant kthreads
Date: Fri,  5 Jun 2015 17:01:08 +0200
Message-Id: <1433516477-5153-10-git-send-email-pmladek@suse.cz>
In-Reply-To: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Many kthreads go into an interruptible sleep when there is nothing
to do. They should check if anyone did not requested the kthread
to terminate, freeze, or park in the meantime. It is easy to do
it a wrong way.

This patch adds an API to do the sleep easier and correct way.
The big advantage is that we will have all the checks on a single
place and will be able to fix all broken threads easily.

We need two steps. set_current_state(TASK_INTERRUPTIBLE)
is typically called under some lock together with a check for
a pending work. While schedule() has to be called outside
the lock.

We use the freezable variants of kthread_should_stop(), schedule(),
and cond_resched(). They are needed in freezable kthreads and they
do the right job also in non-freezable ones.

The API is ready to support more sleeping variants, e.g.
wait_event_freezable(), wait_event_freezable_timeout(). Well,
we will need to add some more items into the struct kthread_iterant
for them.

Signed-off-by: Petr Mladek <pmladek@suse.cz>
---
 include/linux/kthread.h | 13 +++++++++
 kernel/kthread.c        | 76 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 89 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 100c1e006729..415178c20cde 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -48,14 +48,25 @@ struct task_struct *kthread_create_on_cpu(int (*threadfn)(void *data),
  * must be released and non-interruptible work finished.
  */
 
+/* Flags that modify the default behavior of iterant kthreads. */
+/* Reset pause flags for the next iteration. */
+#define KTI_PAUSE_ONCE		0x00000001
+/* Do interruptible sleep between iterations. */
+#define KTI_INT_SLEEP		0x00000002
+
+#define KTI_PAUSE_MASK		(KTI_INT_SLEEP | \
+				 KTI_PAUSE_ONCE)
+
 /**
  * struct kthread_iterant - structure describing the function of the kthread
+ * @type: modifies the kthread behavior using extra flags.
  * @data: pointer to a data passed to the functions.
  * @init: function called when the kthread is created.
  * @func: function called in the main cycle until the kthread is terminated.
  * @destroy: function called when the kthread is being terminated.
  */
 struct kthread_iterant {
+	unsigned int type;
 	void *data;
 	void (*init)(void *data);
 	void (*func)(void *data);
@@ -85,6 +96,8 @@ kthread_iterant_create_on_cpu(struct kthread_iterant *kti,
 	__k;								   \
 })
 
+void set_kthread_iterant_int_sleep(void);
+
 void kthread_bind(struct task_struct *k, unsigned int cpu);
 void kthread_stop_current(void);
 int kthread_stop(struct task_struct *k);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 41fb6a43a1f1..fa40fb549e22 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -414,6 +414,80 @@ struct task_struct *kthread_create_on_cpu(int (*threadfn)(void *data),
 }
 
 /**
+ * set_kthread_iterant_pause_type - set the type of the pause before
+ *	the next iteration
+ * @type: flags that define the type of the pause; they are the same
+ *	  as the flags used for @type in struct kthread_iterant
+ */
+static void set_kthread_iterant_pause_type(struct kthread_iterant *kti,
+					   unsigned int type)
+{
+	WARN_ONCE(type & ~KTI_PAUSE_MASK,
+		  "unknown pause type: 0x%x\n", type);
+	type &= KTI_PAUSE_MASK;
+
+	kti->type &= ~KTI_PAUSE_MASK;
+	kti->type |= type;
+	/* this function set the pause only for the next iteration */
+	kti->type |= KTI_PAUSE_ONCE;
+}
+
+/**
+ * set_kthread_iterant_int_sleep - do interruptible sleep before
+ *	the next iteration
+ *
+ * This function is typically called under a lock when the main func()
+ * checks for the pending work.
+ *
+ * Kthreads should pause between iterations only when there is no work,
+ * signal pending, freezing, parking, or termination. We want to do most
+ * of these checks properly on a single place: kthread_iterant_fn().
+ * Only the checks for pending work need to be done in the main func()
+ * because they are not generic.
+ */
+void set_kthread_iterant_int_sleep(void)
+{
+	struct kthread_iterant *kti = to_kthread_iterant(current);
+
+	set_kthread_iterant_pause_type(kti, KTI_INT_SLEEP);
+	set_current_state(TASK_INTERRUPTIBLE);
+}
+EXPORT_SYMBOL(set_kthread_iterant_int_sleep);
+
+/**
+ * do_kthread_iterant_pause - do the selected pause before next iteration
+ *
+ * Most kthreads sleep or wait between iterations. This function
+ * allows to do it the right way. The particular pause variant
+ * is defined by @type flags in struct kthread_iterant. Anyway,
+ * this is a safe place to call cond_resched().
+ */
+static void do_kthread_iterant_pause(struct kthread_iterant *kti)
+{
+	unsigned int type = kti->type;
+
+	/*
+	 * Explicitly set the task state when it was not set by
+	 * set_kthread_iterant_int_sleep*() functions.
+	 */
+	if (!(type & KTI_PAUSE_ONCE) && (type & KTI_INT_SLEEP))
+		set_current_state(TASK_INTERRUPTIBLE);
+
+	if (kthread_freezable_should_stop(NULL)) {
+		set_current_state(TASK_RUNNING);
+		return;
+	}
+
+	if (type & KTI_INT_SLEEP)
+		freezable_schedule();
+	else
+		freezable_cond_resched();
+
+	if (type & KTI_PAUSE_ONCE)
+		kti->type &= ~KTI_PAUSE_MASK;
+}
+
+/**
  * kthread_iterant_fn - kthread function to process an iterant kthread
  * @kti_ptr: pointer to an initialized struct kthread_iterant.
  *
@@ -443,6 +517,8 @@ static int kthread_iterant_fn(void *kti_ptr)
 		if (kti->func)
 			kti->func(data);
 
+		do_kthread_iterant_pause(kti);
+
 		if (signal_pending(current))
 			kthread_do_signal();
 
-- 
1.8.5.6

