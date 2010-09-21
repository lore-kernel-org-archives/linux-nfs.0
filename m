Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41499 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753038Ab0IUUiL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 16:38:11 -0400
Received: from [10.58.49.15] (manju-lxp.hq.netapp.com [10.58.49.15])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o8LKc9aH007966
	for <linux-nfs@vger.kernel.org>; Tue, 21 Sep 2010 13:38:10 -0700 (PDT)
Message-ID: <4C9917B1.9050301@netapp.com>
Date: Tue, 21 Sep 2010 16:38:09 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] lockd: Remove BKL from the client
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

lockd: Remove BKL from the client

This patch removes all calls to lock_kernel() from the client.  This patch
should be applied after the "fs/lock.c prepare for BKL removal" patch submitted
by Arnd Bergmann on September 18.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 64fd427..d5bb868 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -42,6 +42,7 @@ struct nlm_wait {
 };
 
 static LIST_HEAD(nlm_blocked);
+static DEFINE_SPINLOCK(nlm_blocked_lock);
 
 /**
  * nlmclnt_init - Set up per-NFS mount point lockd data structures
@@ -97,7 +98,10 @@ struct nlm_wait *nlmclnt_prepare_block(struct nlm_host *host, struct file_lock *
 		block->b_lock = fl;
 		init_waitqueue_head(&block->b_wait);
 		block->b_status = nlm_lck_blocked;
+
+		spin_lock(&nlm_blocked_lock);
 		list_add(&block->b_list, &nlm_blocked);
+		spin_unlock(&nlm_blocked_lock);
 	}
 	return block;
 }
@@ -106,7 +110,9 @@ void nlmclnt_finish_block(struct nlm_wait *block)
 {
 	if (block == NULL)
 		return;
+	spin_lock(&nlm_blocked_lock);
 	list_del(&block->b_list);
+	spin_unlock(&nlm_blocked_lock);
 	kfree(block);
 }
 
@@ -154,6 +160,7 @@ __be32 nlmclnt_grant(const struct sockaddr *addr, const struct nlm_lock *lock)
 	 * Look up blocked request based on arguments. 
 	 * Warning: must not use cookie to match it!
 	 */
+	spin_lock(&nlm_blocked_lock);
 	list_for_each_entry(block, &nlm_blocked, b_list) {
 		struct file_lock *fl_blocked = block->b_lock;
 
@@ -178,6 +185,7 @@ __be32 nlmclnt_grant(const struct sockaddr *addr, const struct nlm_lock *lock)
 		wake_up(&block->b_wait);
 		res = nlm_granted;
 	}
+	spin_unlock(&nlm_blocked_lock);
 	return res;
 }
 
@@ -216,10 +224,6 @@ reclaimer(void *ptr)
 	allow_signal(SIGKILL);
 
 	down_write(&host->h_rwsem);
-
-	/* This one ensures that our parent doesn't terminate while the
-	 * reclaim is in progress */
-	lock_kernel();
 	lockd_up();	/* note: this cannot fail as lockd is already running */
 
 	dprintk("lockd: reclaiming locks for host %s\n", host->h_name);
@@ -260,16 +264,17 @@ restart:
 	dprintk("NLM: done reclaiming locks for host %s\n", host->h_name);
 
 	/* Now, wake up all processes that sleep on a blocked lock */
+	spin_lock(&nlm_blocked_lock);
 	list_for_each_entry(block, &nlm_blocked, b_list) {
 		if (block->b_host == host) {
 			block->b_status = nlm_lck_denied_grace_period;
 			wake_up(&block->b_wait);
 		}
 	}
+	spin_unlock(&nlm_blocked_lock);
 
 	/* Release host handle after use */
 	nlm_release_host(host);
 	lockd_down();
-	unlock_kernel();
 	return 0;
 }
diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 7932c39..47ea1e1 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -166,7 +166,6 @@ int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
 	/* Set up the argument struct */
 	nlmclnt_setlockargs(call, fl);
 
-	lock_kernel();
 	if (IS_SETLK(cmd) || IS_SETLKW(cmd)) {
 		if (fl->fl_type != F_UNLCK) {
 			call->a_args.block = IS_SETLKW(cmd) ? 1 : 0;
@@ -177,10 +176,8 @@ int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
 		status = nlmclnt_test(call, fl);
 	else
 		status = -EINVAL;
-
 	fl->fl_ops->fl_release_private(fl);
 	fl->fl_ops = NULL;
-	unlock_kernel();
 
 	dprintk("lockd: clnt proc returns %d\n", status);
 	return status;
@@ -226,9 +223,7 @@ void nlm_release_call(struct nlm_rqst *call)
 
 static void nlmclnt_rpc_release(void *data)
 {
-	lock_kernel();
 	nlm_release_call(data);
-	unlock_kernel();
 }
 
 static int nlm_wait_on_grace(wait_queue_head_t *queue)
@@ -448,14 +443,18 @@ out:
 
 static void nlmclnt_locks_copy_lock(struct file_lock *new, struct file_lock *fl)
 {
+	spin_lock(&fl->fl_u.nfs_fl.owner->host->h_lock);
 	new->fl_u.nfs_fl.state = fl->fl_u.nfs_fl.state;
 	new->fl_u.nfs_fl.owner = nlm_get_lockowner(fl->fl_u.nfs_fl.owner);
 	list_add_tail(&new->fl_u.nfs_fl.list, &fl->fl_u.nfs_fl.owner->host->h_granted);
+	spin_unlock(&fl->fl_u.nfs_fl.owner->host->h_lock);
 }
 
 static void nlmclnt_locks_release_private(struct file_lock *fl)
 {
+	spin_lock(&fl->fl_u.nfs_fl.owner->host->h_lock);
 	list_del(&fl->fl_u.nfs_fl.list);
+	spin_unlock(&fl->fl_u.nfs_fl.owner->host->h_lock);
 	nlm_put_lockowner(fl->fl_u.nfs_fl.owner);
 }
 
@@ -721,9 +720,7 @@ static void nlmclnt_unlock_callback(struct rpc_task *task, void *data)
 die:
 	return;
  retry_rebind:
-	lock_kernel();
 	nlm_rebind_host(req->a_host);
-	unlock_kernel();
  retry_unlock:
 	rpc_restart_call(task);
 }
@@ -801,9 +798,7 @@ retry_cancel:
 	/* Don't ever retry more than 3 times */
 	if (req->a_retries++ >= NLMCLNT_MAX_RETRIES)
 		goto die;
-	lock_kernel();
 	nlm_rebind_host(req->a_host);
-	unlock_kernel();
 	rpc_restart_call(task);
 	rpc_delay(task, 30 * HZ);
 }
