From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 6/7] NLM: Convert lockd to use kthreads
Date: Tue, 18 Dec 2007 15:19:41 -0500
Message-ID: <1198009182-27895-7-git-send-email-jlayton@redhat.com>
References: <1198009182-27895-1-git-send-email-jlayton@redhat.com>
 <1198009182-27895-2-git-send-email-jlayton@redhat.com>
 <1198009182-27895-3-git-send-email-jlayton@redhat.com>
 <1198009182-27895-4-git-send-email-jlayton@redhat.com>
 <1198009182-27895-5-git-send-email-jlayton@redhat.com>
 <1198009182-27895-6-git-send-email-jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, nfsv4@linux-nfs.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37250 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751758AbXLRUTo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Dec 2007 15:19:44 -0500
In-Reply-To: <1198009182-27895-6-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have lockd_up start lockd using svc_create_kthread. With this change,
lockd_down now blocks until lockd actually exits, so there's no longer
need for the waitqueue code at the end of lockd_down. This also means
that only one lockd can be running at a time which simplifies the code
within lockd's main loop a bit.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svc.c |   76 +++++++++++++++++++++++++------------------------------
 1 files changed, 35 insertions(+), 41 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 03a83a0..bb98711 100644
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
@@ -111,10 +111,11 @@ static inline void clear_grace_period(void)
 /*
  * This is the lockd kernel thread
  */
-static void
-lockd(struct svc_rqst *rqstp)
+static int
+lockd(void *vrqstp)
 {
 	int		err = 0;
+	struct svc_rqst *rqstp = vrqstp;
 	unsigned long grace_period_expire;
 
 	/* Lock module and set up kernel thread */
@@ -128,11 +129,9 @@ lockd(struct svc_rqst *rqstp)
 	/*
 	 * Let our maker know we're running.
 	 */
-	nlmsvc_pid = current->pid;
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
 
@@ -203,23 +202,19 @@ lockd(struct svc_rqst *rqstp)
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
+	return 0;
 }
 
 
@@ -270,13 +265,14 @@ int
 lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 {
 	struct svc_serv *	serv;
+	struct svc_rqst *	rqstp;
 	int			error = 0;
 
 	mutex_lock(&nlmsvc_mutex);
 	/*
 	 * Check whether we're already up and running.
 	 */
-	if (nlmsvc_pid) {
+	if (nlmsvc_task) {
 		if (proto)
 			error = make_socks(nlmsvc_serv, proto);
 		goto out;
@@ -303,11 +299,24 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 	/*
 	 * Create the kernel thread and wait for it to start.
 	 */
+	rqstp = svc_prepare_thread(serv, &serv->sv_pools[0]);
+	if (IS_ERR(rqstp)) {
+		error = PTR_ERR(rqstp);
+		printk(KERN_WARNING
+			"lockd_up: svc_rqst allocation failed, error=%d\n",
+			error);
+		goto destroy_and_out;
+	}
+
+	svc_sock_update_bufs(serv);
 	init_completion(&lockd_start_done);
-	error = svc_create_thread(lockd, serv);
-	if (error) {
+	nlmsvc_task = kthread_run(lockd, rqstp, serv->sv_name);
+	if (IS_ERR(nlmsvc_task)) {
+		error = PTR_ERR(nlmsvc_task);
+		nlmsvc_task = NULL;
 		printk(KERN_WARNING
-			"lockd_up: create thread failed, error=%d\n", error);
+			"lockd_up: kthread_run failed, error=%d\n", error);
+		svc_exit_thread(rqstp);
 		goto destroy_and_out;
 	}
 	wait_for_completion(&lockd_start_done);
@@ -339,30 +348,15 @@ lockd_down(void)
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

