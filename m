From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/2] NLM: Convert lockd to use kthreads
Date: Wed,  6 Feb 2008 13:21:43 -0500
Message-ID: <1202322103-13716-3-git-send-email-jlayton@redhat.com>
References: <1202322103-13716-1-git-send-email-jlayton@redhat.com>
 <1202322103-13716-2-git-send-email-jlayton@redhat.com>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60953 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754792AbYBFSVr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 13:21:47 -0500
In-Reply-To: <1202322103-13716-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have lockd_up start lockd using kthread_run. With this change,
lockd_down now blocks until lockd actually exits, so there's no longer
need for the waitqueue code at the end of lockd_down. This also means
that only one lockd can be running at a time which simplifies the code
within lockd's main loop.

This also adds a check for kthread_should_stop in the main loop of
nlmsvc_retry_blocked and after that function returns. There's no sense
continuing to retry blocks if lockd is coming down anyway.

The main difference between this patch and earlier ones is that it
changes lockd_down to again send SIGKILL to lockd when it's coming
down. svc_recv() uses schedule_timeout, so we can end up blocking there
for a long time if we end up calling into it after kthread_stop wakes
up lockd. Sending a SIGKILL should help ensure that svc_recv returns
quickly if this occurs.

Because kthread_stop blocks until the kthread actually goes down,
we have to send the signal before calling it. This means that there
is a very small race window like this where lockd_down could block
for a long time:

lockd_down signals lockd
				lockd invalidates locks
				lockd flushes signals
				lockd checks kthread_should_stop
lockd_down calls kthread_stop
				lockd calls svc_recv

...and lockd blocks until svc_recv returns. I think this is a
pretty unlikely scenario though. This doesn't appear to be fixable
without changing the kthread_stop machinery to send a signal.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svc.c     |  144 +++++++++++++++++++++++++---------------------------
 fs/lockd/svclock.c |    3 +-
 2 files changed, 72 insertions(+), 75 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 0822646..35e5ae2 100644
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
 
@@ -161,6 +153,7 @@ lockd(struct svc_rqst *rqstp)
 				nlmsvc_invalidate_all();
 				grace_period_expire = set_grace_period();
 			}
+			continue;
 		}
 
 		/*
@@ -174,6 +167,10 @@ lockd(struct svc_rqst *rqstp)
 		} else if (time_before(grace_period_expire, jiffies))
 			clear_grace_period();
 
+		/* nlmsvc_retry_blocked can block, so check for kthread_stop */
+		if (kthread_should_stop())
+			break;
+
 		/*
 		 * Find a socket with data available and call its
 		 * recvfrom routine.
@@ -195,28 +192,19 @@ lockd(struct svc_rqst *rqstp)
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
@@ -261,14 +249,15 @@ static int make_socks(struct svc_serv *serv, int proto)
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
@@ -295,13 +284,28 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
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
@@ -323,37 +327,29 @@ EXPORT_SYMBOL(lockd_up);
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
+	 /*
+	  * send a signal to prevent lockd blocking in svc_recv(). This is
+	  * "best effort". It's possible (though unlikely) that lockd will
+	  * flush the signal and be woken up by kthread stop just before it
+	  * calls into svc_recv. If that happens lockd can block for a long
+	  * time -- possibly until a packet hits one of its sockets.
+	  */
+	send_sig(SIGKILL, nlmsvc_task, 1);
+	kthread_stop(nlmsvc_task);
 out:
 	mutex_unlock(&nlmsvc_mutex);
 }
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 2f4d8fa..d8324b6 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -29,6 +29,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/nlm.h>
 #include <linux/lockd/lockd.h>
+#include <linux/kthread.h>
 
 #define NLMDBG_FACILITY		NLMDBG_SVCLOCK
 
@@ -867,7 +868,7 @@ nlmsvc_retry_blocked(void)
 	unsigned long	timeout = MAX_SCHEDULE_TIMEOUT;
 	struct nlm_block *block;
 
-	while (!list_empty(&nlm_blocked)) {
+	while (!list_empty(&nlm_blocked) && !kthread_should_stop()) {
 		block = list_entry(nlm_blocked.next, struct nlm_block, b_list);
 
 		if (block->b_when == NLM_NEVER)
-- 
1.5.3.8

