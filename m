From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 6/6] NLM: Add reference counting to lockd
Date: Thu, 13 Dec 2007 15:40:28 -0500
Message-ID: <1197578428-26815-7-git-send-email-jlayton@redhat.com>
References: <1197578428-26815-1-git-send-email-jlayton@redhat.com>
 <1197578428-26815-2-git-send-email-jlayton@redhat.com>
 <1197578428-26815-3-git-send-email-jlayton@redhat.com>
 <1197578428-26815-4-git-send-email-jlayton@redhat.com>
 <1197578428-26815-5-git-send-email-jlayton@redhat.com>
 <1197578428-26815-6-git-send-email-jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, nfsv4@linux-nfs.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37472 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758618AbXLMUkc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2007 15:40:32 -0500
In-Reply-To: <1197578428-26815-6-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and only have lockd exit when the last reference is dropped. This
means that we can't use kthread_stop here. nlmsvc_unlink_block is called
by lockd and a kthread can't call kthread_stop on itself. So, change
lockd to check the refcount itself and to return if it goes to 0. We do
the checking and exit while holding the nlmsvc_mutex to make sure that a
new lockd is not started until the old one is down.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svc.c              |   51 ++++++++++++++++++++++++++++++++----------
 fs/lockd/svclock.c          |    5 ++++
 include/linux/lockd/lockd.h |    1 +
 3 files changed, 45 insertions(+), 12 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 1303ce8..05d2317 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -51,6 +51,7 @@ static DEFINE_MUTEX(nlmsvc_mutex);
 static unsigned int		nlmsvc_users;
 static struct task_struct *	nlmsvc_task;
 static struct svc_serv *	nlmsvc_serv;
+atomic_t			nlmsvc_ref = ATOMIC_INIT(0);
 int				nlmsvc_grace_period;
 unsigned long			nlmsvc_timeout;
 
@@ -134,7 +135,10 @@ lockd(struct svc_rqst *rqstp)
 
 	set_freezable();
 
-	/* Process request with signals blocked, but allow SIGKILL.  */
+	/*
+	 * Process request with signals blocked, but allow SIGKILL which
+	 * signifies that lockd should drop all of its locks.
+	 */
 	allow_signal(SIGKILL);
 
 	dprintk("NFS locking service started (ver " LOCKD_VERSION ").\n");
@@ -147,15 +151,19 @@ lockd(struct svc_rqst *rqstp)
 
 	/*
 	 * The main request loop. We don't terminate until the last
-	 * NFS mount or NFS daemon has gone away, and we've been sent a
-	 * signal, or else another process has taken over our job.
+	 * NFS mount or NFS daemon has gone away, and the nlm_blocked
+	 * list is empty. The nlmsvc_mutex ensures that we prevent a
+	 * new lockd from being started before the old one is down.
 	 */
-	while (!kthread_should_stop()) {
+	mutex_lock(&nlmsvc_mutex);
+	while (atomic_read(&nlmsvc_ref) != 0) {
 		long timeout = MAX_SCHEDULE_TIMEOUT;
 		char buf[RPC_MAX_ADDRBUFLEN];
 
+		mutex_unlock(&nlmsvc_mutex);
+
 		if (try_to_freeze())
-			continue;
+			goto again;
 
 		if (signalled()) {
 			flush_signals(current);
@@ -182,11 +190,12 @@ lockd(struct svc_rqst *rqstp)
 		 */
 		err = svc_recv(rqstp, timeout);
 		if (err == -EAGAIN || err == -EINTR)
-			continue;
+			goto again;
 		if (err < 0) {
 			printk(KERN_WARNING
 			       "lockd: terminating on error %d\n",
 			       -err);
+			mutex_lock(&nlmsvc_mutex);
 			break;
 		}
 
@@ -194,19 +203,22 @@ lockd(struct svc_rqst *rqstp)
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
-	 */
+	 * at this point lockd is committed to going down. We hold the
+	 * nlmsvc_mutex until just before exit to prevent a new one
+	 * from starting before it's down.
+ 	 */
+	flush_signals(current);
 	if (nlmsvc_ops)
 		nlmsvc_invalidate_all();
 	nlm_shutdown_hosts();
 	nlmsvc_task = NULL;
 	nlmsvc_serv = NULL;
+	mutex_unlock(&nlmsvc_mutex);
 
 	/* Exit the RPC thread */
 	svc_exit_thread(rqstp);
@@ -267,6 +279,10 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 	int			error = 0;
 
 	mutex_lock(&nlmsvc_mutex);
+
+	if (!nlmsvc_users)
+		atomic_inc(&nlmsvc_ref);
+
 	/*
 	 * Check whether we're already up and running.
 	 */
@@ -313,6 +329,8 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 destroy_and_out:
 	svc_destroy(serv);
 out:
+	if (!nlmsvc_users && error)
+		atomic_dec(&nlmsvc_ref);
 	if (!error)
 		nlmsvc_users++;
 	mutex_unlock(&nlmsvc_mutex);
@@ -341,7 +359,16 @@ lockd_down(void)
 		goto out;
 	}
 	warned = 0;
-	kthread_stop(nlmsvc_task);
+	atomic_dec(&nlmsvc_ref);
+
+	/*
+	 * Sending a signal is necessary here. If we get to this point and
+	 * nlm_blocked isn't empty then lockd may be held hostage by clients
+	 * that are still blocking. Sending the signal makes sure that lockd
+	 * invalidates all of its locks so that it's just waiting on RPC
+	 * callbacks to complete
+	 */
+	kill_proc(nlmsvc_task->pid, SIGKILL, 1);
 out:
 	mutex_unlock(&nlmsvc_mutex);
 }
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index d120ec3..b8fbda3 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -61,6 +61,9 @@ nlmsvc_insert_block(struct nlm_block *block, unsigned long when)
 	struct list_head *pos;
 
 	dprintk("lockd: nlmsvc_insert_block(%p, %ld)\n", block, when);
+	if (list_empty(&nlm_blocked))
+		atomic_inc(&nlmsvc_ref);
+
 	if (list_empty(&block->b_list)) {
 		kref_get(&block->b_count);
 	} else {
@@ -239,6 +242,8 @@ static int nlmsvc_unlink_block(struct nlm_block *block)
 	/* Remove block from list */
 	status = posix_unblock_lock(block->b_file->f_file, &block->b_call->a_args.lock.fl);
 	nlmsvc_remove_block(block);
+	if (list_empty(&nlm_blocked))
+		atomic_dec(&nlmsvc_ref);
 	return status;
 }
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index e2d1ce3..7389553 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -154,6 +154,7 @@ extern struct svc_procedure	nlmsvc_procedures4[];
 extern int			nlmsvc_grace_period;
 extern unsigned long		nlmsvc_timeout;
 extern int			nsm_use_hostnames;
+extern atomic_t			nlmsvc_ref;
 
 /*
  * Lockd client functions
-- 
1.5.3.3

