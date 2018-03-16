Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36360 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752881AbeCPOmk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Mar 2018 10:42:40 -0400
Date: Fri, 16 Mar 2018 10:42:39 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: NeilBrown <neilb@suse.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/3] fs: hide another detail of delegation logic
Message-ID: <20180316144239.GG18719@fieldses.org>
References: <8760d5hol3.fsf@notabene.neil.brown.name>
 <20170830170938.GC24373@parsley.fieldses.org>
 <87wp5kfxi3.fsf@notabene.neil.brown.name>
 <20170831190531.GA8223@parsley.fieldses.org>
 <873787fhc5.fsf@notabene.neil.brown.name>
 <20170901161809.GA22140@parsley.fieldses.org>
 <871snndq04.fsf@notabene.neil.brown.name>
 <20170905195619.GB17828@parsley.fieldses.org>
 <877excde18.fsf@notabene.neil.brown.name>
 <20170906160342.GB28077@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170906160342.GB28077@parsley.fieldses.org>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's taken me a while to get back to this, sorry!  I'll try not to
assume anyone remembers the previous discussion....

On Wed, Sep 06, 2017 at 12:03:42PM -0400, J. Bruce Fields wrote:
> Gah, I hate having to patch every notify_change caller.  But maybe I
> should get over that, the resulting logic is simpler.

I went a little further down that path and now I think that we missed
some callers, and that this is a bigger problem than I previously
thought.

So to decide whether a given file operation conflicts with a
lease/delegation, we need to know "who" is performing the operation.  If
we track that by explicitly passing that "who", then we're adding a new
argument to every vfs function between nfsd and the break_lease call.
That'll only get worse, since:

	1. I want to add write delegations next, and that'll introduce
	   more delegation-breaking operations; and
	2. I imagine we'll want to make this feature available to
	   userspace eventually too (for servers like Samba and Ganesha),
	   and that'll mean propagating this even further.

We also considered doing the lease break in nfsd/vfs.c and adding some
new locking to prevent grants of new leases/delegations over an nfsd
operation.  I haven't tried that yet, but I don't like it being so
nfsd-specific, and I don't like having to do this on each operation.

So, I'm experimenting with passing the identity of the lease breaker in
the task instead--actually the struct cred.  Does that make sense?

It certainly makes for a short patch.  The below applies after a bunch
of nfsd delegation code cleanup.

--b.

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
index 87e546f3f792..5d9e9877a49e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3927,6 +3927,13 @@ nfsd_break_deleg_cb(struct file_lock *fl)
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
@@ -3938,6 +3945,7 @@ nfsd_change_deleg_cb(struct file_lock *onlist, int arg,
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
