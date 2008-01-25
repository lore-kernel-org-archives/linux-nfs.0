From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 096/100] NLM: Convert lockd to use kthreads
Date: Fri, 25 Jan 2008 18:17:16 -0500
Message-ID: <1201303040-7779-96-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-56-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-59-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-60-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-61-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-62-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-63-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-64-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-65-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-66-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-67-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-68-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-69-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-70-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-71-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-72-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-73-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-74-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-75-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-76-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-77-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-78-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-79-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-80-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-81-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-82-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-83-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-84-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-85-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-86-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-87-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-88-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-89-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-90-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-91-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-92-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-93-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-94-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-95-git-send-email-bfields@citi.umich.edu>
Cc: Jeff Layton <jlayton@redhat.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47575 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762001AbYAYXSj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:18:39 -0500
In-Reply-To: <1201303040-7779-95-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

Have lockd_up start lockd using kthread_run. With this change,
lockd_down now blocks until lockd actually exits, so there's no longer
need for the waitqueue code at the end of lockd_down. This also means
that only one lockd can be running at a time which simplifies the code
within lockd's main loop.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svc.c |  131 ++++++++++++++++++++++++-------------------------------
 1 files changed, 57 insertions(+), 74 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 0822646..5752e1b 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -25,6 +25,7 @@
 #include <linux/smp.h>
 #include <linux/smp_lock.h>
 #include <linux/mutex.h>
+#include <linux/kthread.h>
 #include <linux/freezer.h>
 
 #include <linux/sunrpc/types.h>
@@ -48,14 +49,11 @@ EXPORT_SYMBOL(nlmsvc_ops);
 
 static DEFINE_MUTEX(nlmsvc_mutex);
 static unsigned int		nlmsvc_users;
-static pid_t			nlmsvc_pid;
+static struct task_struct	*nlmsvc_task;
 static struct svc_serv		*nlmsvc_serv;
 int				nlmsvc_grace_period;
 unsigned long			nlmsvc_timeout;
 
-static DECLARE_COMPLETION(lockd_start_done);
-static DECLARE_WAIT_QUEUE_HEAD(lockd_exit);
-
 /*
  * These can be set at insmod time (useful for NFS as root filesystem),
  * and also changed through the sysctl interface.  -- Jamie Lokier, Aug 2003
@@ -111,35 +109,30 @@ static inline void clear_grace_period(void)
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
 
-	/* Lock module and set up kernel thread */
-	/* lockd_up is waiting for us to startup, so will
-	 * be holding a reference to this module, so it
-	 * is safe to just claim another reference
-	 */
-	__module_get(THIS_MODULE);
-	lock_kernel();
-
-	/*
-	 * Let our maker know we're running.
-	 */
-	nlmsvc_pid = current->pid;
-	nlmsvc_serv = rqstp->rq_server;
-	complete(&lockd_start_done);
-
-	daemonize("lockd");
+	/* try_to_freeze() is called from svc_recv() */
 	set_freezable();
 
-	/* Process request with signals blocked, but allow SIGKILL.  */
+	/* Allow SIGKILL to tell lockd to drop all of its locks */
 	allow_signal(SIGKILL);
 
 	dprintk("NFS locking service started (ver " LOCKD_VERSION ").\n");
 
+	/*
+	 * FIXME: it would be nice if lockd didn't spend its entire life
+	 * running under the BKL. At the very least, it would be good to
+	 * have someone clarify what it's intended to protect here. I've
+	 * seen some handwavy posts about posix locking needing to be
+	 * done under the BKL, but it's far from clear.
+	 */
+	lock_kernel();
+
 	if (!nlm_timeout)
 		nlm_timeout = LOCKD_DFLT_TIMEO;
 	nlmsvc_timeout = nlm_timeout * HZ;
@@ -148,10 +141,9 @@ lockd(struct svc_rqst *rqstp)
 
 	/*
 	 * The main request loop. We don't terminate until the last
-	 * NFS mount or NFS daemon has gone away, and we've been sent a
-	 * signal, or else another process has taken over our job.
+	 * NFS mount or NFS daemon has gone away.
 	 */
-	while ((nlmsvc_users || !signalled()) && nlmsvc_pid == current->pid) {
+	while (!kthread_should_stop()) {
 		long timeout = MAX_SCHEDULE_TIMEOUT;
 		char buf[RPC_MAX_ADDRBUFLEN];
 
@@ -195,28 +187,19 @@ lockd(struct svc_rqst *rqstp)
 	}
 
 	flush_signals(current);
+	if (nlmsvc_ops)
+		nlmsvc_invalidate_all();
+	nlm_shutdown_hosts();
 
-	/*
-	 * Check whether there's a new lockd process before
-	 * shutting down the hosts and clearing the slot.
-	 */
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
+	unlock_kernel();
+
+	nlmsvc_task = NULL;
+	nlmsvc_serv = NULL;
 
 	/* Exit the RPC thread */
 	svc_exit_thread(rqstp);
 
-	/* Release module */
-	unlock_kernel();
-	module_put_and_exit(0);
+	return 0;
 }
 
 /*
@@ -261,14 +244,15 @@ static int make_socks(struct svc_serv *serv, int proto)
 int
 lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 {
-	struct svc_serv *	serv;
-	int			error = 0;
+	struct svc_serv *serv;
+	struct svc_rqst *rqstp;
+	int		error = 0;
 
 	mutex_lock(&nlmsvc_mutex);
 	/*
 	 * Check whether we're already up and running.
 	 */
-	if (nlmsvc_pid) {
+	if (nlmsvc_serv) {
 		if (proto)
 			error = make_socks(nlmsvc_serv, proto);
 		goto out;
@@ -295,13 +279,28 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 	/*
 	 * Create the kernel thread and wait for it to start.
 	 */
-	error = svc_create_thread(lockd, serv);
-	if (error) {
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
+	nlmsvc_serv = rqstp->rq_server;
+
+	nlmsvc_task = kthread_run(lockd, rqstp, serv->sv_name);
+	if (IS_ERR(nlmsvc_task)) {
+		error = PTR_ERR(nlmsvc_task);
+		nlmsvc_task = NULL;
+		nlmsvc_serv = NULL;
 		printk(KERN_WARNING
-			"lockd_up: create thread failed, error=%d\n", error);
+			"lockd_up: kthread_run failed, error=%d\n", error);
+		svc_exit_thread(rqstp);
 		goto destroy_and_out;
 	}
-	wait_for_completion(&lockd_start_done);
 
 	/*
 	 * Note: svc_serv structures have an initial use count of 1,
@@ -323,37 +322,21 @@ EXPORT_SYMBOL(lockd_up);
 void
 lockd_down(void)
 {
-	static int warned;
-
 	mutex_lock(&nlmsvc_mutex);
 	if (nlmsvc_users) {
 		if (--nlmsvc_users)
 			goto out;
-	} else
-		printk(KERN_WARNING "lockd_down: no users! pid=%d\n", nlmsvc_pid);
-
-	if (!nlmsvc_pid) {
-		if (warned++ == 0)
-			printk(KERN_WARNING "lockd_down: no lockd running.\n"); 
-		goto out;
+	} else {
+		printk(KERN_ERR "lockd_down: no users! task=%p\n",
+			nlmsvc_task);
+		BUG();
 	}
-	warned = 0;
 
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
+	if (!nlmsvc_task) {
+		printk(KERN_ERR "lockd_down: no lockd running.\n");
+		BUG();
 	}
-	spin_lock_irq(&current->sighand->siglock);
-	recalc_sigpending();
-	spin_unlock_irq(&current->sighand->siglock);
+	kthread_stop(nlmsvc_task);
 out:
 	mutex_unlock(&nlmsvc_mutex);
 }
-- 
1.5.4.rc2.60.gb2e62

