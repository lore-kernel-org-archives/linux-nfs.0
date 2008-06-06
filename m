From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/5] knfsd: convert knfsd to kthread API
Date: Fri,  6 Jun 2008 11:12:50 -0400
Message-ID: <1212765171-26042-5-git-send-email-jlayton@redhat.com>
References: <1212765171-26042-1-git-send-email-jlayton@redhat.com>
 <1212765171-26042-2-git-send-email-jlayton@redhat.com>
 <1212765171-26042-3-git-send-email-jlayton@redhat.com>
 <1212765171-26042-4-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, neilb@suse.de,
	gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49161 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757694AbYFFPM5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Jun 2008 11:12:57 -0400
In-Reply-To: <1212765171-26042-4-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch is rather large, but I couldn't figure out a way to break it
up that would remain bisectable. It does several things:

- change svc_thread_fn typedef to better match what kthread_create expects
- change svc_pool_map_set_cpumask to be more kthread friendly. Make it
  take a task arg and and get rid of the "oldmask"
- have svc_set_num_threads call kthread_create directly
- eliminate __svc_create_thread

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfssvc.c           |   52 ++++++++++++++--------
 include/linux/sunrpc/svc.h |    2 +-
 net/sunrpc/svc.c           |  102 +++++++++++++++-----------------------------
 3 files changed, 68 insertions(+), 88 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 6339cb7..fe62ec8 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -21,6 +21,7 @@
 #include <linux/smp_lock.h>
 #include <linux/freezer.h>
 #include <linux/fs_struct.h>
+#include <linux/kthread.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/stats.h>
@@ -46,7 +47,7 @@
 #define SHUTDOWN_SIGS	(sigmask(SIGKILL) | sigmask(SIGHUP) | sigmask(SIGINT) | sigmask(SIGQUIT))
 
 extern struct svc_program	nfsd_program;
-static void			nfsd(struct svc_rqst *rqstp);
+static int			nfsd(void *vrqstp);
 struct timeval			nfssvc_boot;
 static atomic_t			nfsd_busy;
 static unsigned long		nfsd_last_call;
@@ -407,18 +408,19 @@ update_thread_usage(int busy_threads)
 /*
  * This is the NFS server kernel thread
  */
-static void
-nfsd(struct svc_rqst *rqstp)
+static int
+nfsd(void *vrqstp)
 {
+	struct svc_rqst *rqstp = (struct svc_rqst *) vrqstp;
 	struct fs_struct *fsp;
-	int		err;
 	sigset_t shutdown_mask, allowed_mask;
+	int err, preverr = 0;
+	unsigned int signo;
 
 	/* Lock module and set up kernel thread */
 	mutex_lock(&nfsd_mutex);
-	daemonize("nfsd");
 
-	/* After daemonize() this kernel thread shares current->fs
+	/* At this point, the thread shares current->fs
 	 * with the init process. We need to create files with a
 	 * umask of 0 instead of init's umask. */
 	fsp = copy_fs_struct(current->fs);
@@ -433,14 +435,18 @@ nfsd(struct svc_rqst *rqstp)
 	siginitsetinv(&shutdown_mask, SHUTDOWN_SIGS);
 	siginitsetinv(&allowed_mask, ALLOWED_SIGS);
 
+	/*
+	 * thread is spawned with all signals set to SIG_IGN, re-enable
+	 * the ones that matter
+	 */
+	for (signo = 1; signo <= _NSIG; signo++) {
+		if (!sigismember(&shutdown_mask, signo))
+			allow_signal(signo);
+	}
 
 	nfsdstats.th_cnt++;
-
-	rqstp->rq_task = current;
-
 	mutex_unlock(&nfsd_mutex);
 
-
 	/*
 	 * We want less throttling in balance_dirty_pages() so that nfs to
 	 * localhost doesn't cause nfsd to lock up due to all the client's
@@ -462,15 +468,25 @@ nfsd(struct svc_rqst *rqstp)
 		 */
 		while ((err = svc_recv(rqstp, 60*60*HZ)) == -EAGAIN)
 			;
-		if (err < 0)
+		if (err == -EINTR)
 			break;
+		else if (err < 0) {
+			if (err != preverr) {
+				printk(KERN_WARNING "%s: unexpected error "
+					"from svc_recv (%d)\n", __func__, -err);
+				preverr = err;
+			}
+			schedule_timeout_uninterruptible(HZ);
+			continue;
+		}
+
 		update_thread_usage(atomic_read(&nfsd_busy));
 		atomic_inc(&nfsd_busy);
 
 		/* Lock the export hash tables for reading. */
 		exp_readlock();
 
-		/* Process request with signals blocked.  */
+		/* Process request with signals blocked. */
 		sigprocmask(SIG_SETMASK, &allowed_mask, NULL);
 
 		svc_process(rqstp);
@@ -479,25 +495,23 @@ nfsd(struct svc_rqst *rqstp)
 		exp_readunlock();
 		update_thread_usage(atomic_read(&nfsd_busy));
 		atomic_dec(&nfsd_busy);
-	}
 
-	if (err != -EINTR)
-		printk(KERN_WARNING "nfsd: terminating on error %d\n", -err);
+		/* reset err in case kthread_stop is called */
+		err = 0;
+	}
 
 	/* Clear signals before calling svc_exit_thread() */
 	flush_signals(current);
 
 	mutex_lock(&nfsd_mutex);
-
 	nfsdstats.th_cnt --;
 
 out:
 	/* Release the thread */
 	svc_exit_thread(rqstp);
-
-	/* Release module */
 	mutex_unlock(&nfsd_mutex);
-	module_put_and_exit(0);
+
+	return 0;
 }
 
 static __be32 map_new_errors(u32 vers, __be32 nfserr)
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 4b54c5f..011d6d8 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -22,7 +22,7 @@
 /*
  * This is the RPC server thread function prototype
  */
-typedef void		(*svc_thread_fn)(struct svc_rqst *);
+typedef int		(*svc_thread_fn)(void *);
 
 /*
  *
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 7bffaff..f461da2 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -18,6 +18,7 @@
 #include <linux/mm.h>
 #include <linux/interrupt.h>
 #include <linux/module.h>
+#include <linux/kthread.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
@@ -291,15 +292,14 @@ svc_pool_map_put(void)
 
 
 /*
- * Set the current thread's cpus_allowed mask so that it
+ * Set the given thread's cpus_allowed mask so that it
  * will only run on cpus in the given pool.
- *
- * Returns 1 and fills in oldmask iff a cpumask was applied.
  */
-static inline int
-svc_pool_map_set_cpumask(unsigned int pidx, cpumask_t *oldmask)
+static inline void
+svc_pool_map_set_cpumask(struct task_struct *task, unsigned int pidx)
 {
 	struct svc_pool_map *m = &svc_pool_map;
+	unsigned int node = m->pool_to[pidx];
 
 	/*
 	 * The caller checks for sv_nrpools > 1, which
@@ -307,26 +307,17 @@ svc_pool_map_set_cpumask(unsigned int pidx, cpumask_t *oldmask)
 	 */
 	BUG_ON(m->count == 0);
 
-	switch (m->mode)
-	{
-	default:
-		return 0;
+	switch (m->mode) {
 	case SVC_POOL_PERCPU:
 	{
-		unsigned int cpu = m->pool_to[pidx];
-
-		*oldmask = current->cpus_allowed;
-		set_cpus_allowed_ptr(current, &cpumask_of_cpu(cpu));
-		return 1;
+		set_cpus_allowed_ptr(task, &cpumask_of_cpu(node));
+		break;
 	}
 	case SVC_POOL_PERNODE:
 	{
-		unsigned int node = m->pool_to[pidx];
 		node_to_cpumask_ptr(nodecpumask, node);
-
-		*oldmask = current->cpus_allowed;
-		set_cpus_allowed_ptr(current, nodecpumask);
-		return 1;
+		set_cpus_allowed_ptr(task, nodecpumask);
+		break;
 	}
 	}
 }
@@ -579,47 +570,6 @@ out_enomem:
 EXPORT_SYMBOL(svc_prepare_thread);
 
 /*
- * Create a thread in the given pool.  Caller must hold BKL or another lock to
- * serialize access to the svc_serv struct. On a NUMA or SMP machine, with a
- * multi-pool serv, the thread will be restricted to run on the cpus belonging
- * to the pool.
- */
-static int
-__svc_create_thread(svc_thread_fn func, struct svc_serv *serv,
-		    struct svc_pool *pool)
-{
-	struct svc_rqst	*rqstp;
-	int		error = -ENOMEM;
-	int		have_oldmask = 0;
-	cpumask_t	uninitialized_var(oldmask);
-
-	rqstp = svc_prepare_thread(serv, pool);
-	if (IS_ERR(rqstp)) {
-		error = PTR_ERR(rqstp);
-		goto out;
-	}
-
-	if (serv->sv_nrpools > 1)
-		have_oldmask = svc_pool_map_set_cpumask(pool->sp_id, &oldmask);
-
-	error = kernel_thread((int (*)(void *)) func, rqstp, 0);
-
-	if (have_oldmask)
-		set_cpus_allowed(current, oldmask);
-
-	if (error < 0)
-		goto out_thread;
-	svc_sock_update_bufs(serv);
-	error = 0;
-out:
-	return error;
-
-out_thread:
-	svc_exit_thread(rqstp);
-	goto out;
-}
-
-/*
  * Choose a pool in which to create a new thread, for svc_set_num_threads
  */
 static inline struct svc_pool *
@@ -688,7 +638,9 @@ found_pool:
 int
 svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
 {
-	struct task_struct *victim;
+	struct svc_rqst	*rqstp;
+	struct task_struct *task;
+	struct svc_pool *chosen_pool;
 	int error = 0;
 	unsigned int state = serv->sv_nrthreads-1;
 
@@ -704,18 +656,32 @@ svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
 	/* create new threads */
 	while (nrservs > 0) {
 		nrservs--;
-		__module_get(serv->sv_module);
-		error = __svc_create_thread(serv->sv_function, serv,
-					    choose_pool(serv, pool, &state));
-		if (error < 0) {
-			module_put(serv->sv_module);
+		chosen_pool = choose_pool(serv, pool, &state);
+
+		rqstp = svc_prepare_thread(serv, chosen_pool);
+		if (IS_ERR(rqstp)) {
+			error = PTR_ERR(rqstp);
 			break;
 		}
+
+		task = kthread_create(serv->sv_function, rqstp, serv->sv_name);
+		if (IS_ERR(task)) {
+			error = PTR_ERR(task);
+			svc_exit_thread(rqstp);
+			break;
+		}
+
+		rqstp->rq_task = task;
+		if (serv->sv_nrpools > 1)
+			svc_pool_map_set_cpumask(task, chosen_pool->sp_id);
+
+		svc_sock_update_bufs(serv);
+		wake_up_process(task);
 	}
 	/* destroy old threads */
 	while (nrservs < 0 &&
-	       (victim = choose_victim(serv, pool, &state)) != NULL) {
-		send_sig(serv->sv_kill_signal, victim, 1);
+	       (task = choose_victim(serv, pool, &state)) != NULL) {
+		send_sig(serv->sv_kill_signal, task, 1);
 		nrservs++;
 	}
 
-- 
1.5.3.6

