Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58232 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422698AbbFEPCG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2015 11:02:06 -0400
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
Subject: [RFC PATCH 13/18] ring_buffer: Use iterant kthreads API in the ring buffer benchmark
Date: Fri,  5 Jun 2015 17:01:12 +0200
Message-Id: <1433516477-5153-14-git-send-email-pmladek@suse.cz>
In-Reply-To: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The new iterant kthread API allows to define a common checkpoint for
freezing, parking, termination, and even signal handling. It will allow
to maintain kthreads more easily and make the operations more reliable.

The kthread function is split into optional init(), func(), destroy() parts
where func() is called in a cycle. The common check point is after
each func() function finishes. See kthread_iterant_fn() for more details.

This patch removes the wait_to_die() cycle. Instead it uses
the main cycle and func() does nothing in the kill_test state.

The threads are not safe for freezing because there is used schedule()
without try_to_freeze() inside the kthread. Let's fix it in separate
patch. In the meantime, we need to disable it explicitly in the init()
function.

Consumer does not need to call schedule in func(). Instead, it sets
KTI_INT_SLEEP type and lets the kthread iterant framework to do the sleep
between iterations.

On the other hand, the producer still need to implement the sleeping
in func() because the iterant kthread framework does not support
this type of sleep. But the plan is to make it possible later.

Signed-off-by: Petr Mladek <pmladek@suse.cz>
---
 kernel/trace/ring_buffer_benchmark.c | 81 +++++++++++++++++-------------------
 1 file changed, 39 insertions(+), 42 deletions(-)

diff --git a/kernel/trace/ring_buffer_benchmark.c b/kernel/trace/ring_buffer_benchmark.c
index 13d945c0d03f..164f3762cc82 100644
--- a/kernel/trace/ring_buffer_benchmark.c
+++ b/kernel/trace/ring_buffer_benchmark.c
@@ -30,6 +30,8 @@ static struct completion read_done;
 static struct ring_buffer *buffer;
 static struct task_struct *producer;
 static struct task_struct *consumer;
+static struct kthread_iterant producer_kti;
+static struct kthread_iterant consumer_kti;
 static unsigned long read;
 
 static int disable_reader;
@@ -354,61 +356,51 @@ static void ring_buffer_producer(void)
 	}
 }
 
-static void wait_to_die(void)
+static void ring_buffer_consumer_thread_init(void *arg)
 {
-	set_current_state(TASK_INTERRUPTIBLE);
-	while (!kthread_should_stop()) {
-		schedule();
-		set_current_state(TASK_INTERRUPTIBLE);
-	}
-	__set_current_state(TASK_RUNNING);
+	/* it does not matter where we freeze */
+	current->flags |= PF_NOFREEZE;
 }
 
-static int ring_buffer_consumer_thread(void *arg)
+static void ring_buffer_consumer_thread_func(void *arg)
 {
-	while (!kthread_should_stop() && !kill_test) {
-		complete(&read_start);
-
-		ring_buffer_consumer();
-
-		set_current_state(TASK_INTERRUPTIBLE);
-		if (kthread_should_stop() || kill_test)
-			break;
-
-		schedule();
-	}
-	__set_current_state(TASK_RUNNING);
-
 	if (kill_test)
-		wait_to_die();
+		return;
 
-	return 0;
+	complete(&read_start);
+
+	ring_buffer_consumer();
 }
 
-static int ring_buffer_producer_thread(void *arg)
+static void ring_buffer_producer_thread_init(void *arg)
 {
 	init_completion(&read_start);
 
-	while (!kthread_should_stop() && !kill_test) {
-		ring_buffer_reset(buffer);
+	/* it does not matter where we freeze */
+	current->flags |= PF_NOFREEZE;
+}
 
-		if (consumer) {
-			smp_wmb();
-			wake_up_process(consumer);
-			wait_for_completion(&read_start);
-		}
+static void ring_buffer_producer_thread_func(void *arg)
+{
+	if (kill_test) {
+		set_kthread_iterant_int_sleep();
+		return;
+	}
 
-		ring_buffer_producer();
+	ring_buffer_reset(buffer);
 
-		trace_printk("Sleeping for 10 secs\n");
-		set_current_state(TASK_INTERRUPTIBLE);
-		schedule_timeout(HZ * SLEEP_TIME);
+	if (consumer) {
+		/* reset ring buffer before waking up the consumer */
+		smp_wmb();
+		wake_up_process(consumer);
+		wait_for_completion(&read_start);
 	}
 
-	if (kill_test)
-		wait_to_die();
+	ring_buffer_producer();
 
-	return 0;
+	trace_printk("Sleeping for 10 secs\n");
+	set_current_state(TASK_INTERRUPTIBLE);
+	schedule_timeout(HZ * SLEEP_TIME);
 }
 
 static int __init ring_buffer_benchmark_init(void)
@@ -420,16 +412,21 @@ static int __init ring_buffer_benchmark_init(void)
 	if (!buffer)
 		return -ENOMEM;
 
+	consumer_kti.type = KTI_INT_SLEEP;
+	consumer_kti.func = ring_buffer_consumer_thread_init;
+	consumer_kti.func = ring_buffer_consumer_thread_func;
+
 	if (!disable_reader) {
-		consumer = kthread_create(ring_buffer_consumer_thread,
-					  NULL, "rb_consumer");
+		consumer = kthread_iterant_create(&consumer_kti, "rb_consumer");
 		ret = PTR_ERR(consumer);
 		if (IS_ERR(consumer))
 			goto out_fail;
 	}
 
-	producer = kthread_run(ring_buffer_producer_thread,
-			       NULL, "rb_producer");
+	producer_kti.init = ring_buffer_producer_thread_init;
+	producer_kti.func = ring_buffer_producer_thread_func;
+
+	producer = kthread_iterant_run(&producer_kti, "rb_producer");
 	ret = PTR_ERR(producer);
 
 	if (IS_ERR(producer))
-- 
1.8.5.6

