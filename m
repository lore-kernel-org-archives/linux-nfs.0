Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:56148 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474AbaGHSEl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:04:41 -0400
Received: by mail-qa0-f45.google.com with SMTP id s7so1164787qap.4
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:04:40 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 004/100] nfsd: Avoid taking state_lock while holding inode lock in nfsd_break_one_deleg
Date: Tue,  8 Jul 2014 14:02:52 -0400
Message-Id: <1404842668-22521-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

state_lock is a heavily contended global lock. We don't want to grab
that while simultaneously holding the inode->i_lock.

Add a new per-nfs4_file lock that we can use to protect the
per-nfs4_file delegation list. Hold that while walking the list in the
break_deleg callback and queue the workqueue job for each one.

The workqueue job can then take the state_lock and do the list
manipulations without the i_lock being held prior to starting the
rpc call.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4callback.c | 28 +++++++++++++++++++-------
 fs/nfsd/nfs4state.c    | 53 +++++++++++++++++++++++++++++++++-----------------
 fs/nfsd/state.h        |  2 ++
 3 files changed, 58 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 00cb9b7a75f6..cba4ca375f5e 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -43,7 +43,7 @@
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
 static void nfsd4_mark_cb_fault(struct nfs4_client *, int reason);
-static void nfsd4_do_callback_rpc(struct work_struct *w);
+static void nfsd4_run_cb_null(struct work_struct *w);
 
 #define NFSPROC4_CB_NULL 0
 #define NFSPROC4_CB_COMPOUND 1
@@ -764,7 +764,7 @@ static void do_probe_callback(struct nfs4_client *clp)
 
 	cb->cb_ops = &nfsd4_cb_probe_ops;
 
-	INIT_WORK(&cb->cb_work, nfsd4_do_callback_rpc);
+	INIT_WORK(&cb->cb_work, nfsd4_run_cb_null);
 
 	run_nfsd4_cb(cb);
 }
@@ -936,7 +936,7 @@ void nfsd4_shutdown_callback(struct nfs4_client *clp)
 	set_bit(NFSD4_CLIENT_CB_KILL, &clp->cl_flags);
 	/*
 	 * Note this won't actually result in a null callback;
-	 * instead, nfsd4_do_callback_rpc() will detect the killed
+	 * instead, nfsd4_run_cb_null() will detect the killed
 	 * client, destroy the rpc client, and stop:
 	 */
 	do_probe_callback(clp);
@@ -1014,9 +1014,8 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 		run_nfsd4_cb(cb);
 }
 
-static void nfsd4_do_callback_rpc(struct work_struct *w)
+static void nfsd4_run_callback_rpc(struct nfsd4_callback *cb)
 {
-	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback, cb_work);
 	struct nfs4_client *clp = cb->cb_clp;
 	struct rpc_clnt *clnt;
 
@@ -1034,6 +1033,22 @@ static void nfsd4_do_callback_rpc(struct work_struct *w)
 			cb->cb_ops, cb);
 }
 
+static void nfsd4_run_cb_null(struct work_struct *w)
+{
+	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback,
+							cb_work);
+	nfsd4_run_callback_rpc(cb);
+}
+
+static void nfsd4_run_cb_recall(struct work_struct *w)
+{
+	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback,
+							cb_work);
+
+	nfsd4_prepare_cb_recall(cb->cb_op);
+	nfsd4_run_callback_rpc(cb);
+}
+
 void nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfsd4_callback *cb = &dp->dl_recall;
@@ -1050,8 +1065,7 @@ void nfsd4_cb_recall(struct nfs4_delegation *dp)
 
 	INIT_LIST_HEAD(&cb->cb_per_client);
 	cb->cb_done = true;
-
-	INIT_WORK(&cb->cb_work, nfsd4_do_callback_rpc);
+	INIT_WORK(&cb->cb_work, nfsd4_run_cb_recall);
 
 	run_nfsd4_cb(&dp->dl_recall);
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 15d59e063885..b77e34aca8bf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -254,6 +254,8 @@ static void nfsd4_free_file(struct nfs4_file *f)
 static inline void
 put_nfs4_file(struct nfs4_file *fi)
 {
+	might_lock(&state_lock);
+
 	if (atomic_dec_and_lock(&fi->fi_ref, &state_lock)) {
 		hlist_del(&fi->fi_hash);
 		spin_unlock(&state_lock);
@@ -446,6 +448,8 @@ static void block_delegations(struct knfsd_fh *fh)
 	u32 hash;
 	struct bloom_pair *bd = &blocked_delegations;
 
+	lockdep_assert_held(&state_lock);
+
 	hash = arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
 
 	__set_bit(hash&255, bd->set[bd->new]);
@@ -532,7 +536,9 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	lockdep_assert_held(&state_lock);
 
 	dp->dl_stid.sc_type = NFS4_DELEG_STID;
+	spin_lock(&fp->fi_lock);
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
+	spin_unlock(&fp->fi_lock);
 	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 }
 
@@ -540,15 +546,19 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 static void
 unhash_delegation(struct nfs4_delegation *dp)
 {
+	struct nfs4_file *fp = dp->dl_file;
+
 	spin_lock(&state_lock);
 	dp->dl_stid.sc_type = NFS4_CLOSED_DELEG_STID;
 	list_del_init(&dp->dl_perclnt);
-	list_del_init(&dp->dl_perfile);
 	list_del_init(&dp->dl_recall_lru);
+	spin_lock(&fp->fi_lock);
+	list_del_init(&dp->dl_perfile);
+	spin_unlock(&fp->fi_lock);
 	spin_unlock(&state_lock);
-	if (dp->dl_file) {
-		nfs4_put_deleg_lease(dp->dl_file);
-		put_nfs4_file(dp->dl_file);
+	if (fp) {
+		nfs4_put_deleg_lease(fp);
+		put_nfs4_file(fp);
 		dp->dl_file = NULL;
 	}
 }
@@ -2671,6 +2681,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 	lockdep_assert_held(&state_lock);
 
 	atomic_set(&fp->fi_ref, 1);
+	spin_lock_init(&fp->fi_lock);
 	INIT_LIST_HEAD(&fp->fi_stateids);
 	INIT_LIST_HEAD(&fp->fi_delegations);
 	ihold(ino);
@@ -2921,30 +2932,36 @@ out:
 	return ret;
 }
 
-static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
+void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfs4_client *clp = dp->dl_stid.sc_client;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
-	lockdep_assert_held(&state_lock);
-	/* We're assuming the state code never drops its reference
-	 * without first removing the lease.  Since we're in this lease
-	 * callback (and since the lease code is serialized by the kernel
-	 * lock) we know the server hasn't removed the lease yet, we know
-	 * it's safe to take a reference: */
-	atomic_inc(&dp->dl_count);
-
+	/*
+	 * We can't do this in nfsd_break_deleg_cb because it is
+	 * already holding inode->i_lock
+	 */
+	spin_lock(&state_lock);
+	block_delegations(&dp->dl_fh);
 	/*
 	 * If the dl_time != 0, then we know that it has already been
 	 * queued for a lease break. Don't queue it again.
 	 */
 	if (dp->dl_time == 0) {
-		list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
 		dp->dl_time = get_seconds();
+		list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
 	}
+	spin_unlock(&state_lock);
+}
 
-	block_delegations(&dp->dl_fh);
-
+static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
+{
+	/* We're assuming the state code never drops its reference
+	 * without first removing the lease.  Since we're in this lease
+	 * callback (and since the lease code is serialized by the kernel
+	 * lock) we know the server hasn't removed the lease yet, we know
+	 * it's safe to take a reference: */
+	atomic_inc(&dp->dl_count);
 	nfsd4_cb_recall(dp);
 }
 
@@ -2969,11 +2986,11 @@ static void nfsd_break_deleg_cb(struct file_lock *fl)
 	 */
 	fl->fl_break_time = 0;
 
-	spin_lock(&state_lock);
 	fp->fi_had_conflict = true;
+	spin_lock(&fp->fi_lock);
 	list_for_each_entry(dp, &fp->fi_delegations, dl_perfile)
 		nfsd_break_one_deleg(dp);
-	spin_unlock(&state_lock);
+	spin_unlock(&fp->fi_lock);
 }
 
 static
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 0776e7c4c10a..1ba175ce3d09 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -378,6 +378,7 @@ static inline struct nfs4_lockowner * lockowner(struct nfs4_stateowner *so)
 /* nfs4_file: a file opened by some number of (open) nfs4_stateowners. */
 struct nfs4_file {
 	atomic_t		fi_ref;
+	spinlock_t		fi_lock;
 	struct hlist_node       fi_hash;    /* hash by "struct inode *" */
 	struct list_head        fi_stateids;
 	struct list_head	fi_delegations;
@@ -468,6 +469,7 @@ extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
 extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
+extern void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
-- 
1.9.3

