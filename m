Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58232 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933027AbbFEPBz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2015 11:01:55 -0400
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
Subject: [RFC PATCH 04/18] signal: Rename kernel_sigaction() to kthread_sigaction() and clean it up
Date: Fri,  5 Jun 2015 17:01:03 +0200
Message-Id: <1433516477-5153-5-git-send-email-pmladek@suse.cz>
In-Reply-To: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch defines __kthread_sighandler_t so that we do not need to force
a cast from __sighandler_t when passing an address from kernel space.

At the same time, it defines constants for the ignore, default, and
error sigactions that could be used within the kernel space. The __force
is a bit ugly but it is needed because of the ordering of includes.

Finally, the patch renames kernel_sigaction() to kthread_sigaction().
We are going to add proper signal handling to kthreads and this will
help to distinguish the related functions from the user-space
orientated ones. Note that we will just improve the existing
basic support for signals in kthreads.

The patch does not have any runtime effects. It is just a cleanup.

Note that it does not break the compilation with sparse. It warns
when a wrong part or the union is used in a wrong context.

Signed-off-by: Petr Mladek <pmladek@suse.cz>
---
 include/linux/signal.h | 23 ++++++++++++++++++-----
 kernel/kmod.c          |  2 +-
 kernel/signal.c        |  8 ++++----
 3 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/include/linux/signal.h b/include/linux/signal.h
index ab1e0392b5ac..06e54762c281 100644
--- a/include/linux/signal.h
+++ b/include/linux/signal.h
@@ -241,13 +241,26 @@ extern void __set_current_blocked(const sigset_t *);
 extern int show_unhandled_signals;
 extern int sigsuspend(sigset_t *);
 
+typedef __signalfn_t *__kthread_sighandler_t;
+
+/* use the default signal handler for the kthread */
+#define KTHREAD_SIG_DFL ((__force __kthread_sighandler_t)SIG_DFL)
+/* ignore the signal in the kthread */
+#define KTHREAD_SIG_IGN	((__force __kthread_sighandler_t)SIG_IGN)
+
 struct sigaction {
 #ifndef __ARCH_HAS_IRIX_SIGACTION
-	__sighandler_t	sa_handler;
+	union {
+		__sighandler_t		sa_handler;
+		__kthread_sighandler_t	kthread_sa_handler;
+	};
 	unsigned long	sa_flags;
 #else
 	unsigned int	sa_flags;
-	__sighandler_t	sa_handler;
+	union {
+		__sighandler_t		sa_handler;
+		__kthread_sighandler_t	kthread_sa_handler;
+	};
 #endif
 #ifdef __ARCH_HAS_SA_RESTORER
 	__sigrestore_t sa_restorer;
@@ -280,7 +293,7 @@ struct ksignal {
 extern int get_signal(struct ksignal *ksig);
 extern void signal_setup_done(int failed, struct ksignal *ksig, int stepping);
 extern void exit_signals(struct task_struct *tsk);
-extern void kernel_sigaction(int, __sighandler_t);
+extern void kthread_sigaction(int, __kthread_sighandler_t);
 
 static inline void allow_signal(int sig)
 {
@@ -289,12 +302,12 @@ static inline void allow_signal(int sig)
 	 * know it'll be handled, so that they don't get converted to
 	 * SIGKILL or just silently dropped.
 	 */
-	kernel_sigaction(sig, (__force __sighandler_t)2);
+	kthread_sigaction(sig, (__kthread_sighandler_t)2);
 }
 
 static inline void disallow_signal(int sig)
 {
-	kernel_sigaction(sig, SIG_IGN);
+	kthread_sigaction(sig, KTHREAD_SIG_IGN);
 }
 
 extern struct kmem_cache *sighand_cachep;
diff --git a/kernel/kmod.c b/kernel/kmod.c
index 2777f40a9c7b..d45966319bcc 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -273,7 +273,7 @@ static int wait_for_helper(void *data)
 	pid_t pid;
 
 	/* If SIGCLD is ignored sys_wait4 won't populate the status. */
-	kernel_sigaction(SIGCHLD, SIG_DFL);
+	kthread_sigaction(SIGCHLD, KTHREAD_SIG_DFL);
 	pid = kernel_thread(____call_usermodehelper, sub_info, SIGCHLD);
 	if (pid < 0) {
 		sub_info->retval = pid;
diff --git a/kernel/signal.c b/kernel/signal.c
index d51c5ddd855c..ca6bdb411449 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -3077,11 +3077,11 @@ COMPAT_SYSCALL_DEFINE4(rt_tgsigqueueinfo,
 /*
  * For kthreads only, must not be used if cloned with CLONE_SIGHAND
  */
-void kernel_sigaction(int sig, __sighandler_t action)
+void kthread_sigaction(int sig, __kthread_sighandler_t action)
 {
 	spin_lock_irq(&current->sighand->siglock);
-	current->sighand->action[sig - 1].sa.sa_handler = action;
-	if (action == SIG_IGN) {
+	current->sighand->action[sig - 1].sa.kthread_sa_handler = action;
+	if (action == KTHREAD_SIG_IGN) {
 		sigset_t mask;
 
 		sigemptyset(&mask);
@@ -3093,7 +3093,7 @@ void kernel_sigaction(int sig, __sighandler_t action)
 	}
 	spin_unlock_irq(&current->sighand->siglock);
 }
-EXPORT_SYMBOL(kernel_sigaction);
+EXPORT_SYMBOL(kthread_sigaction);
 
 int do_sigaction(int sig, struct k_sigaction *act, struct k_sigaction *oact)
 {
-- 
1.8.5.6

