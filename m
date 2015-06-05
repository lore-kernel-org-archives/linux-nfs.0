Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58217 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933451AbbFEPB5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2015 11:01:57 -0400
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
Subject: [RFC PATCH 06/18] signal/kthread: Initial implementation of kthread signal handling
Date: Fri,  5 Jun 2015 17:01:05 +0200
Message-Id: <1433516477-5153-7-git-send-email-pmladek@suse.cz>
In-Reply-To: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Several kthreads already handle signals some way. They do so
in different ways, search for allow_signal().

This patch allows to handle the signals in a more uniform way using
kthread_do_signal().

The main question is how much it should follow POSIX and the signal
handling of user space processes. On one hand, we want to be as close
as possible. On the other hand, we need to be very careful. All signals
were ignored until now, except for the few kthreads that somehow
handled them.

POSIX behavior might cause some surprises and crazy bug reports.
For example, imagine a home user stopping or killing kswapd because
it makes the system too busy. It is like shooting in its own leg.

Also the signals are already used a strange way. For example, klockd
drops all locks when it gets SIGKILL. This was added before initial
git commit, so the archaeology was not easy. The most likely explanation
is that it is used during the system shutdown. It would make sense
to drop all locks when user space processes are killed and before
filesystems get unmounted.

Now, the patch does the following compromise:

  + defines default actions for SIGSTOP, SIGCONT, and fatal signals
  + custom actions can be defined by kthread_sigaction()
  + all signals are still ignored by default

Well, fatal signals do not terminate the kthread immediately. They just
set a flag to terminate the kthread, flush all other pending signals,
and return to the main kthread cycle. The kthread is supposed to check
the flag, leave the main cycle, do some cleanup actions when necessary
and return from the kthread.

Note that kthreads are running in the kernel address space. It makes
the life much easier. The signal handler can be called directly and
we do not need any arch-specific code to process it in the userspace.
Also we do not care about ptrace.

Finally, kthread_do_signal() is called on a safe place in the main
iterant kthread cycle. Then we will not need any special code for
signals when using this kthread API.

This change does not affect any existing kthread. The plan is to
use them only in safe kthreads that can be converted into
the iterant kthread API.

Signed-off-by: Petr Mladek <pmladek@suse.cz>
---
 include/linux/signal.h |  1 +
 kernel/kthread.c       |  3 ++
 kernel/signal.c        | 76 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 80 insertions(+)

diff --git a/include/linux/signal.h b/include/linux/signal.h
index 06e54762c281..41e30310bc3b 100644
--- a/include/linux/signal.h
+++ b/include/linux/signal.h
@@ -294,6 +294,7 @@ extern int get_signal(struct ksignal *ksig);
 extern void signal_setup_done(int failed, struct ksignal *ksig, int stepping);
 extern void exit_signals(struct task_struct *tsk);
 extern void kthread_sigaction(int, __kthread_sighandler_t);
+extern int kthread_do_signal(void);
 
 static inline void allow_signal(int sig)
 {
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 688bb4cfd807..185902d0e293 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -426,6 +426,9 @@ static int kthread_iterant_fn(void *kti_ptr)
 		if (kti->func)
 			kti->func(data);
 
+		if (signal_pending(current))
+			kthread_do_signal();
+
 	/* this check is safe also for non-freezable kthreads */
 	} while (!kthread_freezable_should_stop(NULL));
 
diff --git a/kernel/signal.c b/kernel/signal.c
index ca6bdb411449..cdca53965c3d 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -23,6 +23,7 @@
 #include <linux/ptrace.h>
 #include <linux/signal.h>
 #include <linux/signalfd.h>
+#include <linux/kthread.h>
 #include <linux/ratelimit.h>
 #include <linux/tracehook.h>
 #include <linux/capability.h>
@@ -2365,6 +2366,81 @@ relock:
 }
 
 /**
+ * kthread_do_signal - process signals delivered to kernel threads
+ *
+ * Kthreads are running in the kernel address space. It makes the life
+ * much easier. The signal handler can be called directly and we do not
+ * need any arch-specific code to process it in the userspace.
+ * Also we do not care about ptrace.
+ */
+int kthread_do_signal(void)
+{
+	struct ksignal ksig;
+	struct sighand_struct *sighand = current->sighand;
+	struct signal_struct *signal = current->signal;
+	unsigned long flags;
+	int signr;
+
+	try_to_freeze();
+relock:
+	spin_lock_irqsave(&sighand->siglock, flags);
+
+	if (unlikely(signal->flags & SIGNAL_CLD_MASK)) {
+		WARN(1, "there are no parents for kernel threads\n");
+		signal->flags &= ~SIGNAL_CLD_MASK;
+	}
+
+	for (;;) {
+		struct k_sigaction *ka;
+
+		signr = dequeue_signal(current, &current->blocked, &ksig.info);
+
+		if (!signr)
+			break;
+
+		ka = &sighand->action[signr-1];
+
+		/* Do nothing for ignored signals */
+		if (ka->sa.kthread_sa_handler == KTHREAD_SIG_IGN)
+			continue;
+
+		/* Run the custom handler if any */
+		if (ka->sa.kthread_sa_handler != KTHREAD_SIG_DFL) {
+			ksig.ka = *ka;
+
+			if (ka->sa.sa_flags & SA_ONESHOT)
+				ka->sa.kthread_sa_handler = KTHREAD_SIG_DFL;
+
+			spin_unlock_irqrestore(&sighand->siglock, flags);
+			/* could run directly for kthreads */
+			ksig.ka.sa.kthread_sa_handler(signr);
+			freezable_cond_resched();
+			goto relock;
+		}
+
+		/* Default actions */
+		if (sig_kernel_ignore(signr))
+			continue;
+
+		if (sig_kernel_stop(signr)) {
+			__set_current_state(TASK_STOPPED);
+			spin_unlock_irqrestore(&sighand->siglock, flags);
+			/* Don't run again until woken by SIGCONT or SIGKILL */
+			freezable_schedule();
+			goto relock;
+		}
+
+		/* Death signals, but try to terminate cleanly */
+		kthread_stop_current();
+		__flush_signals(current);
+		break;
+	}
+	spin_unlock_irqrestore(&sighand->siglock, flags);
+
+	return 0;
+}
+
+/**
  * signal_delivered - 
  * @ksig:		kernel signal struct
  * @stepping:		nonzero if debugger single-step or block-step in use
-- 
1.8.5.6

