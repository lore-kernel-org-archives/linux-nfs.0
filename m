Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58327 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422712AbbFEPCI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2015 11:02:08 -0400
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
Subject: [RFC PATCH 14/18] ring_buffer: Allow to cleanly freeze the ring buffer benchmark kthreads
Date: Fri,  5 Jun 2015 17:01:13 +0200
Message-Id: <1433516477-5153-15-git-send-email-pmladek@suse.cz>
In-Reply-To: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One target of the switch to the kthread iterant API is to make
most kthreads cleanly freezable.

This patch adds try_to_freeze() where appropriate and enables
freezing.

Signed-off-by: Petr Mladek <pmladek@suse.cz>
---
 kernel/trace/ring_buffer_benchmark.c | 34 ++++++++++++++--------------------
 1 file changed, 14 insertions(+), 20 deletions(-)

diff --git a/kernel/trace/ring_buffer_benchmark.c b/kernel/trace/ring_buffer_benchmark.c
index 164f3762cc82..2d276b892aea 100644
--- a/kernel/trace/ring_buffer_benchmark.c
+++ b/kernel/trace/ring_buffer_benchmark.c
@@ -6,6 +6,7 @@
 #include <linux/ring_buffer.h>
 #include <linux/completion.h>
 #include <linux/kthread.h>
+#include <linux/freezer.h>
 #include <linux/module.h>
 #include <linux/ktime.h>
 #include <asm/local.h>
@@ -207,6 +208,7 @@ static void ring_buffer_consumer(void)
 			break;
 
 		schedule();
+		try_to_freeze();
 	}
 	reader_finish = 0;
 	complete(&read_done);
@@ -252,19 +254,21 @@ static void ring_buffer_producer(void)
 		if (consumer && !(cnt % wakeup_interval))
 			wake_up_process(consumer);
 
+		if (cnt % wakeup_interval) {
 #ifndef CONFIG_PREEMPT
-		/*
-		 * If we are a non preempt kernel, the 10 second run will
-		 * stop everything while it runs. Instead, we will call
-		 * cond_resched and also add any time that was lost by a
-		 * rescedule.
-		 *
-		 * Do a cond resched at the same frequency we would wake up
-		 * the reader.
-		 */
-		if (cnt % wakeup_interval)
+			/*
+			 * If we are a non preempt kernel, the 10 second run
+			 * will stop everything while it runs. Instead, we will
+			 * call cond_resched and also add any time that was
+			 * lost by a rescedule.
+			 *
+			 * Do a cond resched at the same frequency we would
+			 * wake up the reader.
+			 */
 			cond_resched();
 #endif
+			try_to_freeze();
+		}
 
 	} while (ktime_before(end_time, timeout) && !kill_test);
 	trace_printk("End ring buffer hammer\n");
@@ -356,12 +360,6 @@ static void ring_buffer_producer(void)
 	}
 }
 
-static void ring_buffer_consumer_thread_init(void *arg)
-{
-	/* it does not matter where we freeze */
-	current->flags |= PF_NOFREEZE;
-}
-
 static void ring_buffer_consumer_thread_func(void *arg)
 {
 	if (kill_test)
@@ -375,9 +373,6 @@ static void ring_buffer_consumer_thread_func(void *arg)
 static void ring_buffer_producer_thread_init(void *arg)
 {
 	init_completion(&read_start);
-
-	/* it does not matter where we freeze */
-	current->flags |= PF_NOFREEZE;
 }
 
 static void ring_buffer_producer_thread_func(void *arg)
@@ -413,7 +408,6 @@ static int __init ring_buffer_benchmark_init(void)
 		return -ENOMEM;
 
 	consumer_kti.type = KTI_INT_SLEEP;
-	consumer_kti.func = ring_buffer_consumer_thread_init;
 	consumer_kti.func = ring_buffer_consumer_thread_func;
 
 	if (!disable_reader) {
-- 
1.8.5.6

