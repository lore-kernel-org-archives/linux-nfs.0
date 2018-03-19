Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41700 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755762AbeCSOgr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Mar 2018 10:36:47 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 10/10] nfsd: clients don't need to break their own delegations
Date: Mon, 19 Mar 2018 10:36:34 -0400
Message-Id: <1521470194-24840-11-git-send-email-bfields@redhat.com>
In-Reply-To: <1521470194-24840-1-git-send-email-bfields@redhat.com>
References: <1521470194-24840-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We currently revoke read delegations on any write open or any operation
that modifies file data or metadata (including rename, link, and
unlink).  But if the delegation in question is the only read delegation
and is held by the client performing the operation, that's not really
necessary.

It's not always possible to prevent this in the NFSv4.0 case, because
there's not always a way to determine which client an NFSv4.0 delegation
came from.  (In theory we could try to guess this from the transport
layer, e.g., by assuming all traffic on a given TCP connection comes
from the same client.  But that's not really correct.)

In the NFSv4.1 case the session layer always tells us the client.

This patch should remove such self-conflicts in all cases where we can
reliably determine the client from the compound.

To do that we need to track "who" is performing a given (possibly
lease-breaking) file operation.  There are a lot of those.  So it seems
simpler to pass this in struct task; this patch uses a new field in
struct cred.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 Documentation/filesystems/Locking | 2 ++
 fs/locks.c                        | 4 ++++
 fs/nfsd/auth.c                    | 2 ++
 fs/nfsd/nfs4proc.c                | 1 +
 fs/nfsd/nfs4state.c               | 8 ++++++++
 fs/nfsd/nfssvc.c                  | 1 +
 include/linux/cred.h              | 3 +++
 include/linux/fs.h                | 1 +
 include/linux/sunrpc/svc.h        | 1 +
 9 files changed, 23 insertions(+)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 75d2d57e2c44..739c55825330 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -366,6 +366,7 @@ prototypes:
 	int (*lm_grant)(struct file_lock *, struct file_lock *, int);
 	void (*lm_break)(struct file_lock *); /* break_lease callback */
 	int (*lm_change)(struct file_lock **, int);
+	bool (*lm_breaker_owns_lease)(void *, struct file_lock *);
 
 locking rules:
 
@@ -376,6 +377,7 @@ lm_notify:		yes		yes			no
 lm_grant:		no		no			no
 lm_break:		yes		no			no
 lm_change		yes		no			no
+lm_breaker_owns_lease:	no		no			no
 
 [1]:	->lm_compare_owner and ->lm_owner_key are generally called with
 *an* inode->i_lock held. It may not be the i_lock of the inode
diff --git a/fs/locks.c b/fs/locks.c
index 63aa52bcdf5a..22ed02b20559 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1414,6 +1414,9 @@ static void time_out_leases(struct inode *inode, struct list_head *dispose)
 
 static bool leases_conflict(struct file_lock *lease, struct file_lock *breaker)
 {
+	if (lease->fl_lmops->lm_breaker_owns_lease && breaker->fl_owner &&
+	    lease->fl_lmops->lm_breaker_owns_lease(breaker->fl_owner, lease))
+		return false;
 	if ((breaker->fl_flags & FL_LAYOUT) != (lease->fl_flags & FL_LAYOUT))
 		return false;
 	if ((breaker->fl_flags & FL_DELEG) && (lease->fl_flags & FL_LEASE))
@@ -1462,6 +1465,7 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 	if (IS_ERR(new_fl))
 		return PTR_ERR(new_fl);
 	new_fl->fl_flags = type;
+	new_fl->fl_owner = current_cred()->lease_breaker;
 
 	/* typically we will check that ctx is non-NULL before calling */
 	ctx = smp_load_acquire(&inode->i_flctx);
diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
index fdf2aad73470..d2562ae21b8e 100644
--- a/fs/nfsd/auth.c
+++ b/fs/nfsd/auth.c
@@ -81,6 +81,8 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
 	else
 		new->cap_effective = cap_raise_nfsd_set(new->cap_effective,
 							new->cap_permitted);
+	if (rqstp->rq_lease_breaker)
+		new->lease_breaker = *rqstp->rq_lease_breaker;
 	validate_process_creds();
 	put_cred(override_creds(new));
 	put_cred(new);
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a0bed2b2004d..e1341dbaf657 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1713,6 +1713,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 		op->status = status;
 		goto encode_op;
 	}
+	rqstp->rq_lease_breaker = (void **)&cstate->clp;
 
 	while (!status && resp->opcnt < args->opcnt) {
 		op = &args->ops[resp->opcnt++];
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ca8a5644d9ff..4036544b5b66 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3926,6 +3926,13 @@ nfsd_break_deleg_cb(struct file_lock *fl)
 	return ret;
 }
 
+static bool nfsd_breaker_owns_lease(void *breaker, struct file_lock *fl)
+{
+	struct nfs4_delegation *dl = fl->fl_owner;
+
+	return dl->dl_stid.sc_client == breaker;
+}
+
 static int
 nfsd_change_deleg_cb(struct file_lock *onlist, int arg,
 		     struct list_head *dispose)
@@ -3937,6 +3944,7 @@ nfsd_change_deleg_cb(struct file_lock *onlist, int arg,
 }
 
 static const struct lock_manager_operations nfsd_lease_mng_ops = {
+	.lm_breaker_owns_lease = nfsd_breaker_owns_lease,
 	.lm_break = nfsd_break_deleg_cb,
 	.lm_change = nfsd_change_deleg_cb,
 };
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 89cb484f1cfb..c4e86a0a8dd3 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -803,6 +803,7 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 		*statp = rpc_garbage_args;
 		return 1;
 	}
+	rqstp->rq_lease_breaker = NULL;
 	/*
 	 * Give the xdr decoder a chance to change this if it wants
 	 * (necessary in the NFSv4.0 compound case)
diff --git a/include/linux/cred.h b/include/linux/cred.h
index 631286535d0f..d567c27eebae 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -139,6 +139,9 @@ struct cred {
 	struct key	*thread_keyring; /* keyring private to this thread */
 	struct key	*request_key_auth; /* assumed request_key authority */
 #endif
+#ifdef CONFIG_FILE_LOCKING
+	void		*lease_breaker; /* identify NFS client breaking a delegation */
+#endif
 #ifdef CONFIG_SECURITY
 	void		*security;	/* subjective LSM security */
 #endif
diff --git a/include/linux/fs.h b/include/linux/fs.h
index ef9269bf7e69..43e1d2f47cb3 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -959,6 +959,7 @@ struct lock_manager_operations {
 	bool (*lm_break)(struct file_lock *);
 	int (*lm_change)(struct file_lock *, int, struct list_head *);
 	void (*lm_setup)(struct file_lock *, void **);
+	bool (*lm_breaker_owns_lease)(void *, struct file_lock *);
 };
 
 struct lock_manager {
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 786ae2255f05..f2bbfee1662a 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -293,6 +293,7 @@ struct svc_rqst {
 	struct svc_cacherep *	rq_cacherep;	/* cache info */
 	struct task_struct	*rq_task;	/* service thread */
 	spinlock_t		rq_lock;	/* per-request lock */
+	void **			rq_lease_breaker; /* The v4 client breaking a lease */
 };
 
 #define SVC_NET(svc_rqst)	(svc_rqst->rq_xprt->xpt_net)
-- 
2.14.3

