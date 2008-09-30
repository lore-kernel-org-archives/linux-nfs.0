From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/3] nfsd: common grace period control
Date: Mon, 29 Sep 2008 22:44:01 -0400
Message-ID: <1222742643-31541-2-git-send-email-bfields@citi.umich.edu>
References: <1222742643-31541-1-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47558 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171AbYI3CoR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2008 22:44:17 -0400
In-Reply-To: <1222742643-31541-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rewrite grace period code to unify management of grace period across
lockd and nfsd.  The current code has lockd and nfsd cooperate to
compute a grace period which is satisfactory to them both, and then
individually enforce it.  This creates a slight race condition, since
the enforcement is not coordinated.  It's also more complicated than
necessary.

Here instead we have lockd and nfsd each inform common code when they
enter the grace period, and when they're ready to leave the grace
period, and allow normal locking only after both of them are ready to
leave.

We also expect the locks_start_grace()/locks_end_grace() interface here
to be simpler to build on for future cluster/high-availability work,
which may require (for example) putting individual filesystems into
grace, or enforcing grace periods across multiple cluster nodes.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/Makefile          |    2 +-
 fs/lockd/grace.c           |   60 ++++++++++++++++++++++++++++++++++++++++++++
 fs/lockd/svc.c             |   20 +++-----------
 fs/lockd/svc4proc.c        |   12 ++++----
 fs/lockd/svcproc.c         |   12 ++++----
 fs/nfsd/lockd.c            |    1 -
 fs/nfsd/nfs4proc.c         |    8 +++---
 fs/nfsd/nfs4state.c        |   34 +++++++++++--------------
 include/linux/fs.h         |    8 ++++++
 include/linux/lockd/bind.h |    9 ------
 10 files changed, 105 insertions(+), 61 deletions(-)
 create mode 100644 fs/lockd/grace.c

diff --git a/fs/lockd/Makefile b/fs/lockd/Makefile
index 7725a0a..97f6073 100644
--- a/fs/lockd/Makefile
+++ b/fs/lockd/Makefile
@@ -5,6 +5,6 @@
 obj-$(CONFIG_LOCKD) += lockd.o
 
 lockd-objs-y := clntlock.o clntproc.o host.o svc.o svclock.o svcshare.o \
-	        svcproc.o svcsubs.o mon.o xdr.o
+	        svcproc.o svcsubs.o mon.o xdr.o grace.o
 lockd-objs-$(CONFIG_LOCKD_V4) += xdr4.o svc4proc.o
 lockd-objs		      := $(lockd-objs-y)
diff --git a/fs/lockd/grace.c b/fs/lockd/grace.c
new file mode 100644
index 0000000..41c0e36
--- /dev/null
+++ b/fs/lockd/grace.c
@@ -0,0 +1,60 @@
+/*
+ * Common code for control of lockd and nfsv4 grace periods.
+ */
+
+#include <linux/module.h>
+#include <linux/lockd/bind.h>
+
+/* list manipulations are all made under BKL */
+static LIST_HEAD(grace_list);
+static DEFINE_SPINLOCK(grace_lock);
+
+/**
+ * locks_start_grace
+ * @lm: who this grace period is for
+ *
+ * A grace period is a period during which locks should not be given
+ * out.  Currently grace periods are only enforced by the two lock
+ * managers (lockd and nfsd), using the locks_in_grace() function to
+ * check when they are in a grace period.
+ *
+ * This function is called to start a grace period.
+ */
+void locks_start_grace(struct lock_manager *lm)
+{
+	spin_lock(&grace_lock);
+	list_add(&lm->list, &grace_list);
+	spin_unlock(&grace_lock);
+}
+EXPORT_SYMBOL_GPL(locks_start_grace);
+
+/**
+ * locks_end_grace
+ * @lm: who this grace period is for
+ *
+ * Call this function to state that the given lock manager is ready to
+ * resume regular locking.  The grace period will not end until all lock
+ * managers that called locks_start_grace() also call locks_end_grace().
+ * Note that callers count on it being safe to call this more than once,
+ * and the second call should be a no-op.
+ */
+void locks_end_grace(struct lock_manager *lm)
+{
+	spin_lock(&grace_lock);
+	list_del_init(&lm->list);
+	spin_unlock(&grace_lock);
+}
+EXPORT_SYMBOL_GPL(locks_end_grace);
+
+/**
+ * locks_in_grace
+ *
+ * Lock managers call this function to determine when it is OK for them
+ * to answer ordinary lock requests, and when they should accept only
+ * lock reclaims.
+ */
+int locks_in_grace(void)
+{
+	return !list_empty(&grace_list);
+}
+EXPORT_SYMBOL_GPL(locks_in_grace);
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index f345ef7..f013aed 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -51,7 +51,6 @@ static DEFINE_MUTEX(nlmsvc_mutex);
 static unsigned int		nlmsvc_users;
 static struct task_struct	*nlmsvc_task;
 static struct svc_rqst		*nlmsvc_rqst;
-int				nlmsvc_grace_period;
 unsigned long			nlmsvc_timeout;
 
 /*
@@ -85,30 +84,21 @@ static unsigned long get_lockd_grace_period(void)
 		return nlm_timeout * 5 * HZ;
 }
 
-unsigned long get_nfs_grace_period(void)
-{
-	unsigned long lockdgrace = get_lockd_grace_period();
-	unsigned long nfsdgrace = 0;
-
-	if (nlmsvc_ops)
-		nfsdgrace = nlmsvc_ops->get_grace_period();
-
-	return max(lockdgrace, nfsdgrace);
-}
-EXPORT_SYMBOL(get_nfs_grace_period);
+static struct lock_manager lockd_manager = {
+};
 
 static void grace_ender(struct work_struct *not_used)
 {
-	nlmsvc_grace_period = 0;
+	locks_end_grace(&lockd_manager);
 }
 
 static DECLARE_DELAYED_WORK(grace_period_end, grace_ender);
 
 static void set_grace_period(void)
 {
-	unsigned long grace_period = get_nfs_grace_period() + jiffies;
+	unsigned long grace_period = get_lockd_grace_period();
 
-	nlmsvc_grace_period = 1;
+	locks_start_grace(&lockd_manager);
 	cancel_delayed_work_sync(&grace_period_end);
 	schedule_delayed_work(&grace_period_end, grace_period);
 }
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 4a714f6..7ca6173 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -89,7 +89,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->cookie = argp->cookie;
 
 	/* Don't accept test requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (locks_in_grace()) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rc;
 	}
@@ -123,7 +123,7 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period && !argp->reclaim) {
+	if (locks_in_grace() && !argp->reclaim) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rc;
 	}
@@ -169,7 +169,7 @@ nlm4svc_proc_cancel(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->cookie = argp->cookie;
 
 	/* Don't accept requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (locks_in_grace()) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -202,7 +202,7 @@ nlm4svc_proc_unlock(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (locks_in_grace()) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -341,7 +341,7 @@ nlm4svc_proc_share(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period && !argp->reclaim) {
+	if (locks_in_grace() && !argp->reclaim) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -374,7 +374,7 @@ nlm4svc_proc_unshare(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->cookie = argp->cookie;
 
 	/* Don't accept requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (locks_in_grace()) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 76262c1..1b013e1 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -118,7 +118,7 @@ nlmsvc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->cookie = argp->cookie;
 
 	/* Don't accept test requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (locks_in_grace()) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rc;
 	}
@@ -153,7 +153,7 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period && !argp->reclaim) {
+	if (locks_in_grace() && !argp->reclaim) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rc;
 	}
@@ -199,7 +199,7 @@ nlmsvc_proc_cancel(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->cookie = argp->cookie;
 
 	/* Don't accept requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (locks_in_grace()) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -232,7 +232,7 @@ nlmsvc_proc_unlock(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (locks_in_grace()) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -373,7 +373,7 @@ nlmsvc_proc_share(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period && !argp->reclaim) {
+	if (locks_in_grace() && !argp->reclaim) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -406,7 +406,7 @@ nlmsvc_proc_unshare(struct svc_rqst *rqstp, struct nlm_args *argp,
 	resp->cookie = argp->cookie;
 
 	/* Don't accept requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (locks_in_grace()) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
diff --git a/fs/nfsd/lockd.c b/fs/nfsd/lockd.c
index 15c6fae..b2786a5 100644
--- a/fs/nfsd/lockd.c
+++ b/fs/nfsd/lockd.c
@@ -70,7 +70,6 @@ nlm_fclose(struct file *filp)
 static struct nlmsvc_binding	nfsd_nlm_ops = {
 	.fopen		= nlm_fopen,		/* open file for locking */
 	.fclose		= nlm_fclose,		/* close file */
-	.get_grace_period = get_nfs4_grace_period,
 };
 
 void
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e5b51ff..669461e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -201,10 +201,10 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/* Openowner is now set, so sequence id will get bumped.  Now we need
 	 * these checks before we do any creates: */
 	status = nfserr_grace;
-	if (nfs4_in_grace() && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
+	if (locks_in_grace() && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
 		goto out;
 	status = nfserr_no_grace;
-	if (!nfs4_in_grace() && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
+	if (!locks_in_grace() && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
 		goto out;
 
 	switch (open->op_claim_type) {
@@ -575,7 +575,7 @@ nfsd4_remove(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	__be32 status;
 
-	if (nfs4_in_grace())
+	if (locks_in_grace())
 		return nfserr_grace;
 	status = nfsd_unlink(rqstp, &cstate->current_fh, 0,
 			     remove->rm_name, remove->rm_namelen);
@@ -596,7 +596,7 @@ nfsd4_rename(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	if (!cstate->save_fh.fh_dentry)
 		return status;
-	if (nfs4_in_grace() && !(cstate->save_fh.fh_export->ex_flags
+	if (locks_in_grace() && !(cstate->save_fh.fh_export->ex_flags
 					& NFSEXP_NOSUBTREECHECK))
 		return nfserr_grace;
 	status = nfsd_rename(rqstp, &cstate->save_fh, rename->rn_sname,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1578d7a..0cc7ff5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -61,7 +61,6 @@
 static time_t lease_time = 90;     /* default lease time */
 static time_t user_lease_time = 90;
 static time_t boot_time;
-static int in_grace = 1;
 static u32 current_ownerid = 1;
 static u32 current_fileid = 1;
 static u32 current_delegid = 1;
@@ -1640,7 +1639,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 		case NFS4_OPEN_CLAIM_NULL:
 			/* Let's not give out any delegations till everyone's
 			 * had the chance to reclaim theirs.... */
-			if (nfs4_in_grace())
+			if (locks_in_grace())
 				goto out;
 			if (!atomic_read(&cb->cb_set) || !sop->so_confirmed)
 				goto out;
@@ -1816,12 +1815,15 @@ out:
 	return status;
 }
 
+struct lock_manager nfsd4_manager = {
+};
+
 static void
-end_grace(void)
+nfsd4_end_grace(void)
 {
 	dprintk("NFSD: end of grace period\n");
 	nfsd4_recdir_purge_old();
-	in_grace = 0;
+	locks_end_grace(&nfsd4_manager);
 }
 
 static time_t
@@ -1838,8 +1840,8 @@ nfs4_laundromat(void)
 	nfs4_lock_state();
 
 	dprintk("NFSD: laundromat service - starting\n");
-	if (in_grace)
-		end_grace();
+	if (locks_in_grace())
+		nfsd4_end_grace();
 	list_for_each_safe(pos, next, &client_lru) {
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 		if (time_after((unsigned long)clp->cl_time, (unsigned long)cutoff)) {
@@ -1974,7 +1976,7 @@ check_special_stateids(svc_fh *current_fh, stateid_t *stateid, int flags)
 		return nfserr_bad_stateid;
 	else if (ONE_STATEID(stateid) && (flags & RD_STATE))
 		return nfs_ok;
-	else if (nfs4_in_grace()) {
+	else if (locks_in_grace()) {
 		/* Answer in remaining cases depends on existance of
 		 * conflicting state; so we must wait out the grace period. */
 		return nfserr_grace;
@@ -1993,7 +1995,7 @@ check_special_stateids(svc_fh *current_fh, stateid_t *stateid, int flags)
 static inline int
 io_during_grace_disallowed(struct inode *inode, int flags)
 {
-	return nfs4_in_grace() && (flags & (RD_STATE | WR_STATE))
+	return locks_in_grace() && (flags & (RD_STATE | WR_STATE))
 		&& mandatory_lock(inode);
 }
 
@@ -2693,10 +2695,10 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	filp = lock_stp->st_vfs_file;
 
 	status = nfserr_grace;
-	if (nfs4_in_grace() && !lock->lk_reclaim)
+	if (locks_in_grace() && !lock->lk_reclaim)
 		goto out;
 	status = nfserr_no_grace;
-	if (!nfs4_in_grace() && lock->lk_reclaim)
+	if (!locks_in_grace() && lock->lk_reclaim)
 		goto out;
 
 	locks_init_lock(&file_lock);
@@ -2779,7 +2781,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	int error;
 	__be32 status;
 
-	if (nfs4_in_grace())
+	if (locks_in_grace())
 		return nfserr_grace;
 
 	if (check_lock_length(lockt->lt_offset, lockt->lt_length))
@@ -3192,9 +3194,9 @@ __nfs4_state_start(void)
 	unsigned long grace_time;
 
 	boot_time = get_seconds();
-	grace_time = get_nfs_grace_period();
+	grace_time = get_nfs4_grace_period();
 	lease_time = user_lease_time;
-	in_grace = 1;
+	locks_start_grace(&nfsd4_manager);
 	printk(KERN_INFO "NFSD: starting %ld-second grace period\n",
 	       grace_time/HZ);
 	laundry_wq = create_singlethread_workqueue("nfsd4");
@@ -3213,12 +3215,6 @@ nfs4_state_start(void)
 	return;
 }
 
-int
-nfs4_in_grace(void)
-{
-	return in_grace;
-}
-
 time_t
 nfs4_lease_time(void)
 {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9f54016..27cfa72 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -942,6 +942,14 @@ struct lock_manager_operations {
 	int (*fl_change)(struct file_lock **, int);
 };
 
+struct lock_manager {
+	struct list_head list;
+};
+
+void locks_start_grace(struct lock_manager *);
+void locks_end_grace(struct lock_manager *);
+int locks_in_grace(void);
+
 /* that will die - we need it for nfs_lock_info */
 #include <linux/nfs_fs_i.h>
 
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index 3d25bcd..1f0465c 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -27,7 +27,6 @@ struct nlmsvc_binding {
 						struct nfs_fh *,
 						struct file **);
 	void			(*fclose)(struct file *);
-	unsigned long		(*get_grace_period)(void);
 };
 
 extern struct nlmsvc_binding *	nlmsvc_ops;
@@ -56,12 +55,4 @@ extern int	nlmclnt_proc(struct nlm_host *host, int cmd,
 extern int	lockd_up(int proto);
 extern void	lockd_down(void);
 
-unsigned long get_nfs_grace_period(void);
-
-#ifdef CONFIG_NFSD_V4
-unsigned long get_nfs4_grace_period(void);
-#else
-static inline unsigned long get_nfs4_grace_period(void) {return 0;}
-#endif
-
 #endif /* LINUX_LOCKD_BIND_H */
-- 
1.5.5.rc1

