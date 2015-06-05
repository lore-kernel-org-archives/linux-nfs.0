Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58327 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422661AbbFEPCE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2015 11:02:04 -0400
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
Subject: [RFC PATCH 11/18] jffs2: Convert jffs2_gcd_mtd kthread into the iterant API
Date: Fri,  5 Jun 2015 17:01:10 +0200
Message-Id: <1433516477-5153-12-git-send-email-pmladek@suse.cz>
In-Reply-To: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The new iterant kthread API allows to define a common checkpoint for
freezing, parking, termination, and even signal handling. It will allow
to maintain kthreads more easily and make the operations more reliable[*].

The kthread function is split into optional init(), func(), destroy() parts
where func() is called in a cycle. The common check point is after
each func() finishes. See kthread_iterant_fn() for more details.

func() does not need to call schedule(). Instead, we call
set_kthread_iterant_int_sleep() and let the generic code
to handle the sleeping properly.

There are few small functional changes:

  + SIGSTOP uses the standard handler and could not print debug
    messages any longer

  + there is no need to enable or define sighandler for SIGCONT;
    it is handled by prepare_signal() and could not get disabled

  + the debug message for default signal handler was removed; It is
    handled in kernel_do_signal() a standard way. In reality, this
    never happens because all signals are disabled except for the
    four ones enabled by kthread_sigaction();

  + we call complete() instead of complete_and_exit(); do_exit() is
    called in kthread() anyway after the function returns.

[*] In fact, there was a bug in the original code. It tried to process
    a non-existing signal when the system was freezing. See the common
    check for pending signal and freezing.

Signed-off-by: Petr Mladek <pmladek@suse.cz>
---
 fs/jffs2/background.c | 156 ++++++++++++++++++++++++--------------------------
 1 file changed, 74 insertions(+), 82 deletions(-)

diff --git a/fs/jffs2/background.c b/fs/jffs2/background.c
index 6af076b8f60f..50c16048ba2d 100644
--- a/fs/jffs2/background.c
+++ b/fs/jffs2/background.c
@@ -21,99 +21,86 @@
 #include <linux/kthread.h>
 #include "nodelist.h"
 
-static int jffs2_garbage_collect_thread(void *_c)
+static void jffs2_garbage_collect_thread_sighup(int sig)
+{
+	jffs2_dbg(1, "%s(): SIGHUP received\n", __func__);
+}
+
+static void jffs2_garbage_collect_thread_sigkill(int sig)
+{
+	jffs2_dbg(1, "%s(): SIGKILL received\n",  __func__);
+	kthread_stop_current();
+}
+
+static void jffs2_garbage_collect_thread_init(void *_c)
 {
 	struct jffs2_sb_info *c = _c;
-	sigset_t hupmask;
 
-	siginitset(&hupmask, sigmask(SIGHUP));
-	allow_signal(SIGKILL);
-	allow_signal(SIGSTOP);
-	allow_signal(SIGCONT);
-	allow_signal(SIGHUP);
+	kthread_sigaction(SIGKILL, jffs2_garbage_collect_thread_sigkill);
+	kthread_sigaction(SIGHUP, jffs2_garbage_collect_thread_sighup);
+	kthread_sigaction(SIGSTOP, KTHREAD_SIG_DFL);
 
 	c->gc_task = current;
 	complete(&c->gc_thread_start);
 
 	set_user_nice(current, 10);
+};
+
+static void jffs2_garbage_collect_thread_func(void *_c)
+{
+	struct jffs2_sb_info *c = _c;
+	sigset_t hupmask;
+
+	siginitset(&hupmask, sigmask(SIGHUP));
 
-	set_freezable();
-	for (;;) {
-		sigprocmask(SIG_UNBLOCK, &hupmask, NULL);
-	again:
-		spin_lock(&c->erase_completion_lock);
-		if (!jffs2_thread_should_wake(c)) {
-			set_current_state (TASK_INTERRUPTIBLE);
-			spin_unlock(&c->erase_completion_lock);
-			jffs2_dbg(1, "%s(): sleeping...\n", __func__);
-			schedule();
-		} else {
-			spin_unlock(&c->erase_completion_lock);
-		}
-		/* Problem - immediately after bootup, the GCD spends a lot
-		 * of time in places like jffs2_kill_fragtree(); so much so
-		 * that userspace processes (like gdm and X) are starved
-		 * despite plenty of cond_resched()s and renicing.  Yield()
-		 * doesn't help, either (presumably because userspace and GCD
-		 * are generally competing for a higher latency resource -
-		 * disk).
-		 * This forces the GCD to slow the hell down.   Pulling an
-		 * inode in with read_inode() is much preferable to having
-		 * the GC thread get there first. */
-		schedule_timeout_interruptible(msecs_to_jiffies(50));
-
-		if (kthread_should_stop()) {
-			jffs2_dbg(1, "%s(): kthread_stop() called\n", __func__);
-			goto die;
-		}
-
-		/* Put_super will send a SIGKILL and then wait on the sem.
-		 */
-		while (signal_pending(current) || freezing(current)) {
-			siginfo_t info;
-			unsigned long signr;
-
-			if (try_to_freeze())
-				goto again;
-
-			signr = dequeue_signal_lock(current, &current->blocked, &info);
-
-			switch(signr) {
-			case SIGSTOP:
-				jffs2_dbg(1, "%s(): SIGSTOP received\n",
-					  __func__);
-				set_current_state(TASK_STOPPED);
-				schedule();
-				break;
-
-			case SIGKILL:
-				jffs2_dbg(1, "%s(): SIGKILL received\n",
-					  __func__);
-				goto die;
-
-			case SIGHUP:
-				jffs2_dbg(1, "%s(): SIGHUP received\n",
-					  __func__);
-				break;
-			default:
-				jffs2_dbg(1, "%s(): signal %ld received\n",
-					  __func__, signr);
-			}
-		}
-		/* We don't want SIGHUP to interrupt us. STOP and KILL are OK though. */
-		sigprocmask(SIG_BLOCK, &hupmask, NULL);
-
-		jffs2_dbg(1, "%s(): pass\n", __func__);
-		if (jffs2_garbage_collect_pass(c) == -ENOSPC) {
-			pr_notice("No space for garbage collection. Aborting GC thread\n");
-			goto die;
-		}
+	spin_lock(&c->erase_completion_lock);
+	if (!jffs2_thread_should_wake(c)) {
+		set_kthread_iterant_int_sleep();
+		spin_unlock(&c->erase_completion_lock);
+		jffs2_dbg(1, "%s(): sleeping...\n", __func__);
+		return;
+	}
+	spin_unlock(&c->erase_completion_lock);
+
+	/* Problem - immediately after bootup, the GCD spends a lot
+	 * of time in places like jffs2_kill_fragtree(); so much so
+	 * that userspace processes (like gdm and X) are starved
+	 * despite plenty of cond_resched()s and renicing.  Yield()
+	 * doesn't help, either (presumably because userspace and GCD
+	 * are generally competing for a higher latency resource -
+	 * disk).
+	 * This forces the GCD to slow the hell down.   Pulling an
+	 * inode in with read_inode() is much preferable to having
+	 * the GC thread get there first.
+	 */
+	schedule_timeout_interruptible(msecs_to_jiffies(50));
+
+	if (kthread_should_stop()) {
+		jffs2_dbg(1, "%s(): kthread_stop() called\n", __func__);
+		return;
 	}
- die:
+
+	try_to_freeze();
+
+	/* We don't want SIGHUP to interrupt us. STOP and KILL are OK though. */
+	sigprocmask(SIG_BLOCK, &hupmask, NULL);
+
+	jffs2_dbg(1, "%s(): pass\n", __func__);
+	if (jffs2_garbage_collect_pass(c) == -ENOSPC) {
+		pr_notice("No space for garbage collection. Aborting GC thread\n");
+		kthread_stop_current();
+	}
+	sigprocmask(SIG_UNBLOCK, &hupmask, NULL);
+}
+
+static void jffs2_garbage_collect_thread_destroy(void *_c)
+{
+	struct jffs2_sb_info *c = _c;
+
 	spin_lock(&c->erase_completion_lock);
 	c->gc_task = NULL;
 	spin_unlock(&c->erase_completion_lock);
-	complete_and_exit(&c->gc_thread_exit, 0);
+	complete(&c->gc_thread_exit);
 }
 
 void jffs2_garbage_collect_trigger(struct jffs2_sb_info *c)
@@ -126,16 +113,21 @@ void jffs2_garbage_collect_trigger(struct jffs2_sb_info *c)
 /* This must only ever be called when no GC thread is currently running */
 int jffs2_start_garbage_collect_thread(struct jffs2_sb_info *c)
 {
+	static struct kthread_iterant kti = {
+		.init = jffs2_garbage_collect_thread_init,
+		.func = jffs2_garbage_collect_thread_func,
+		.destroy = jffs2_garbage_collect_thread_destroy,
+	};
 	struct task_struct *tsk;
 	int ret = 0;
 
 	BUG_ON(c->gc_task);
 
+	kti.data = c;
 	init_completion(&c->gc_thread_start);
 	init_completion(&c->gc_thread_exit);
 
-	tsk = kthread_run(jffs2_garbage_collect_thread, c,
-			  "jffs2_gcd_mtd%d", c->mtd->index);
+	tsk = kthread_iterant_run(&kti, "jffs2_gcd_mtd%d", c->mtd->index);
 	if (IS_ERR(tsk)) {
 		pr_warn("fork failed for JFFS2 garbage collect thread: %ld\n",
 			-PTR_ERR(tsk));
-- 
1.8.5.6

