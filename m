From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NLM: Add lockd reference counting and clean up lockd startup and shutdown
Date: Sat,  8 Dec 2007 08:02:12 -0500
Message-ID: <1197118932-4512-1-git-send-email-jlayton@redhat.com>
Cc: nfsv4@linux-nfs.org, linux-kernel@vger.kernel.org,
	Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751001AbXLHNCP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 8 Dec 2007 08:02:15 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a lock that a client is blocking on comes free, lockd does this in
nlmsvc_grant_blocked():

    nlm_async_call(block->b_call, NLMPROC_GRANTED_MSG, &nlmsvc_grant_ops);

the callback from this call is nlmsvc_grant_callback(). That function
does this at the end to wake up lockd:

    svc_wake_up(block->b_daemon);

However there is no guarantee that lockd will be up when this happens.
If someone shuts down or restarts lockd before the async call completes,
then the b_daemon pointer will point to freed memory and the kernel
may oops.

I first noticed this on older kernels and had mistakenly thought that
newer kernels weren't susceptible, but that's not correct. There's a bit
of a race to make sure that the nlm_host is bound when the async call is
done, but I can now reproduce this at will on current kernels.

This patch is based on Trond's suggestion to add a new reference counter
to lockd, and only allows lockd to go down when it reaches 0. With this
change, continuing to allow a new lockd to replace one that's still
running will leave the kernel susceptible to the original oops. So the
patch also ensures that only one lockd can be running at a time.

It does this by having lockd take the nlmsvc_mutex when checking the
nlmsvc_ref and holding it until exit if the ref has gone to 0. With
this, there's no reason to have lockd_down wait for lockd to come down,
so it now returns immediately after sending the signal.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svc.c              |   70 +++++++++++++++++++++---------------------
 fs/lockd/svclock.c          |    4 ++
 include/linux/lockd/lockd.h |    1 +
 3 files changed, 40 insertions(+), 35 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 82e2192..22f3a5d 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -49,12 +49,12 @@ EXPORT_SYMBOL(nlmsvc_ops);
 static DEFINE_MUTEX(nlmsvc_mutex);
 static unsigned int		nlmsvc_users;
 static pid_t			nlmsvc_pid;
+atomic_t			nlmsvc_ref = ATOMIC_INIT(0);
 static struct svc_serv		*nlmsvc_serv;
 int				nlmsvc_grace_period;
 unsigned long			nlmsvc_timeout;
 
 static DECLARE_COMPLETION(lockd_start_done);
-static DECLARE_WAIT_QUEUE_HEAD(lockd_exit);
 
 /*
  * These can be set at insmod time (useful for NFS as root filesystem),
@@ -148,13 +148,17 @@ lockd(struct svc_rqst *rqstp)
 
 	/*
 	 * The main request loop. We don't terminate until the last
-	 * NFS mount or NFS daemon has gone away, and we've been sent a
-	 * signal, or else another process has taken over our job.
+	 * NFS mount or NFS daemon has gone away, and the nlm_blocked
+	 * list is empty. The nlmsvc_mutex ensures that we prevent 
+	 * a new lockd from being started before the old lockd is
+	 * down when lockd is restarted.
 	 */
-	while ((nlmsvc_users || !signalled()) && nlmsvc_pid == current->pid) {
+	mutex_lock(&nlmsvc_mutex);
+	while (atomic_read(&nlmsvc_ref) != 0) {
 		long timeout = MAX_SCHEDULE_TIMEOUT;
 		char buf[RPC_MAX_ADDRBUFLEN];
 
+		mutex_unlock(&nlmsvc_mutex);
 		if (signalled()) {
 			flush_signals(current);
 			if (nlmsvc_ops) {
@@ -180,11 +184,11 @@ lockd(struct svc_rqst *rqstp)
 		 */
 		err = svc_recv(rqstp, timeout);
 		if (err == -EAGAIN || err == -EINTR)
-			continue;
+			goto again;
 		if (err < 0) {
 			printk(KERN_WARNING
-			       "lockd: terminating on error %d\n",
-			       -err);
+			       "lockd: terminating on error %d\n", -err);
+			mutex_lock(&nlmsvc_mutex);
 			break;
 		}
 
@@ -192,24 +196,23 @@ lockd(struct svc_rqst *rqstp)
 				svc_print_addr(rqstp, buf, sizeof(buf)));
 
 		svc_process(rqstp);
+again:
+		mutex_lock(&nlmsvc_mutex);
 	}
 
-	flush_signals(current);
-
 	/*
-	 * Check whether there's a new lockd process before
-	 * shutting down the hosts and clearing the slot.
+	 * at this point lockd is committed to going down. We hold the
+	 * nlmsvc_mutex until just before exit to prevent a new one
+	 * from starting before it's down.
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
+	flush_signals(current);
+
+	if (nlmsvc_ops)
+		nlmsvc_invalidate_all();
+	nlm_shutdown_hosts();
+	nlmsvc_pid = 0;
+	nlmsvc_serv = NULL;
+	mutex_unlock(&nlmsvc_mutex);
 
 	/* Exit the RPC thread */
 	svc_exit_thread(rqstp);
@@ -270,6 +273,10 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 	int			error = 0;
 
 	mutex_lock(&nlmsvc_mutex);
+
+	if (!nlmsvc_users)
+		atomic_inc(&nlmsvc_ref);
+
 	/*
 	 * Check whether we're already up and running.
 	 */
@@ -315,6 +322,12 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 destroy_and_out:
 	svc_destroy(serv);
 out:
+	/*
+	 * don't leave refcount high if there were already users, or if there
+	 * was an error in starting up lockd
+	 */
+	if (!nlmsvc_users && error)
+		atomic_dec(&nlmsvc_ref);
 	if (!error)
 		nlmsvc_users++;
 	mutex_unlock(&nlmsvc_mutex);
@@ -344,21 +357,8 @@ lockd_down(void)
 	}
 	warned = 0;
 
+	atomic_dec(&nlmsvc_ref);
 	kill_proc(nlmsvc_pid, SIGKILL, 1);
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
 out:
 	mutex_unlock(&nlmsvc_mutex);
 }
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index d120ec3..fcb1054 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -61,6 +61,8 @@ nlmsvc_insert_block(struct nlm_block *block, unsigned long when)
 	struct list_head *pos;
 
 	dprintk("lockd: nlmsvc_insert_block(%p, %ld)\n", block, when);
+	if (list_empty(&nlm_blocked))
+		atomic_inc(&nlmsvc_ref);
 	if (list_empty(&block->b_list)) {
 		kref_get(&block->b_count);
 	} else {
@@ -239,6 +241,8 @@ static int nlmsvc_unlink_block(struct nlm_block *block)
 	/* Remove block from list */
 	status = posix_unblock_lock(block->b_file->f_file, &block->b_call->a_args.lock.fl);
 	nlmsvc_remove_block(block);
+	if (list_empty(&nlm_blocked))
+		atomic_dec(&nlmsvc_ref);
 	return status;
 }
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index e2d1ce3..a165193 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -151,6 +151,7 @@ extern struct svc_procedure	nlmsvc_procedures[];
 #ifdef CONFIG_LOCKD_V4
 extern struct svc_procedure	nlmsvc_procedures4[];
 #endif
+extern atomic_t			nlmsvc_ref;
 extern int			nlmsvc_grace_period;
 extern unsigned long		nlmsvc_timeout;
 extern int			nsm_use_hostnames;
-- 
1.5.3.3

