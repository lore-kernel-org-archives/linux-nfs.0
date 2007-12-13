From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 5/6] NLM: Convert lockd to use kthreads
Date: Thu, 13 Dec 2007 15:40:27 -0500
Message-ID: <1197578428-26815-6-git-send-email-jlayton@redhat.com>
References: <1197578428-26815-1-git-send-email-jlayton@redhat.com>
 <1197578428-26815-2-git-send-email-jlayton@redhat.com>
 <1197578428-26815-3-git-send-email-jlayton@redhat.com>
 <1197578428-26815-4-git-send-email-jlayton@redhat.com>
 <1197578428-26815-5-git-send-email-jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, nfsv4@linux-nfs.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37470 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757831AbXLMUkb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2007 15:40:31 -0500
In-Reply-To: <1197578428-26815-5-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have lockd_up start lockd using svc_create_kthread. With this change,
lockd_down now blocks until lockd actually exits, so there's no longer
need for the waitqueue code at the end of lockd_down. This also means
that only one lockd can be running at a time which simplifies the code
within lockd's main loop a bit.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svc.c |   53 ++++++++++++++++-------------------------------------
 1 files changed, 16 insertions(+), 37 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 03a83a0..1303ce8 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -25,6 +25,7 @@
 #include <linux/smp.h>
 #include <linux/smp_lock.h>
 #include <linux/mutex.h>
+#include <linux/kthread.h>
 #include <linux/freezer.h>
 
 #include <linux/sunrpc/types.h>
@@ -48,13 +49,12 @@ EXPORT_SYMBOL(nlmsvc_ops);
 
 static DEFINE_MUTEX(nlmsvc_mutex);
 static unsigned int		nlmsvc_users;
-static pid_t			nlmsvc_pid;
-static struct svc_serv		*nlmsvc_serv;
+static struct task_struct *	nlmsvc_task;
+static struct svc_serv *	nlmsvc_serv;
 int				nlmsvc_grace_period;
 unsigned long			nlmsvc_timeout;
 
 static DECLARE_COMPLETION(lockd_start_done);
-static DECLARE_WAIT_QUEUE_HEAD(lockd_exit);
 
 /*
  * These can be set at insmod time (useful for NFS as root filesystem),
@@ -128,11 +128,10 @@ lockd(struct svc_rqst *rqstp)
 	/*
 	 * Let our maker know we're running.
 	 */
-	nlmsvc_pid = current->pid;
+	nlmsvc_task = current;
 	nlmsvc_serv = rqstp->rq_server;
 	complete(&lockd_start_done);
 
-	daemonize("lockd");
 	set_freezable();
 
 	/* Process request with signals blocked, but allow SIGKILL.  */
@@ -151,7 +150,7 @@ lockd(struct svc_rqst *rqstp)
 	 * NFS mount or NFS daemon has gone away, and we've been sent a
 	 * signal, or else another process has taken over our job.
 	 */
-	while ((nlmsvc_users || !signalled()) && nlmsvc_pid == current->pid) {
+	while (!kthread_should_stop()) {
 		long timeout = MAX_SCHEDULE_TIMEOUT;
 		char buf[RPC_MAX_ADDRBUFLEN];
 
@@ -203,23 +202,18 @@ lockd(struct svc_rqst *rqstp)
 	 * Check whether there's a new lockd process before
 	 * shutting down the hosts and clearing the slot.
 	 */
-	if (!nlmsvc_pid || current->pid == nlmsvc_pid) {
-		if (nlmsvc_ops)
-			nlmsvc_invalidate_all();
-		nlm_shutdown_hosts();
-		nlmsvc_pid = 0;
-		nlmsvc_serv = NULL;
-	} else
-		printk(KERN_DEBUG
-			"lockd: new process, skipping host shutdown\n");
-	wake_up(&lockd_exit);
+	if (nlmsvc_ops)
+		nlmsvc_invalidate_all();
+	nlm_shutdown_hosts();
+	nlmsvc_task = NULL;
+	nlmsvc_serv = NULL;
 
 	/* Exit the RPC thread */
 	svc_exit_thread(rqstp);
 
 	/* Release module */
 	unlock_kernel();
-	module_put_and_exit(0);
+	module_put(THIS_MODULE);
 }
 
 
@@ -276,7 +270,7 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 	/*
 	 * Check whether we're already up and running.
 	 */
-	if (nlmsvc_pid) {
+	if (nlmsvc_task) {
 		if (proto)
 			error = make_socks(nlmsvc_serv, proto);
 		goto out;
@@ -304,7 +298,7 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 	 * Create the kernel thread and wait for it to start.
 	 */
 	init_completion(&lockd_start_done);
-	error = svc_create_thread(lockd, serv);
+	error = svc_create_kthread(lockd, serv, &serv->sv_pools[0]);
 	if (error) {
 		printk(KERN_WARNING
 			"lockd_up: create thread failed, error=%d\n", error);
@@ -339,30 +333,15 @@ lockd_down(void)
 		if (--nlmsvc_users)
 			goto out;
 	} else
-		printk(KERN_WARNING "lockd_down: no users! pid=%d\n", nlmsvc_pid);
+		printk(KERN_WARNING "lockd_down: no users! task=%p\n", nlmsvc_task);
 
-	if (!nlmsvc_pid) {
+	if (!nlmsvc_task) {
 		if (warned++ == 0)
 			printk(KERN_WARNING "lockd_down: no lockd running.\n"); 
 		goto out;
 	}
 	warned = 0;
-
-	kill_proc(nlmsvc_pid, SIGKILL, 1);
-	/*
-	 * Wait for the lockd process to exit, but since we're holding
-	 * the lockd semaphore, we can't wait around forever ...
-	 */
-	clear_thread_flag(TIF_SIGPENDING);
-	interruptible_sleep_on_timeout(&lockd_exit, HZ);
-	if (nlmsvc_pid) {
-		printk(KERN_WARNING 
-			"lockd_down: lockd failed to exit, clearing pid\n");
-		nlmsvc_pid = 0;
-	}
-	spin_lock_irq(&current->sighand->siglock);
-	recalc_sigpending();
-	spin_unlock_irq(&current->sighand->siglock);
+	kthread_stop(nlmsvc_task);
 out:
 	mutex_unlock(&nlmsvc_mutex);
 }
-- 
1.5.3.3

