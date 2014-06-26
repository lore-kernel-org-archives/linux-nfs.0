Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:35635 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbaFZTOB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:01 -0400
Received: by mail-qg0-f41.google.com with SMTP id i50so3481253qgf.14
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:00 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 010/117] nfsd: Avoid taking state_lock while holding inode lock in nfsd_break_one_deleg
Date: Thu, 26 Jun 2014 15:11:50 -0400
Message-Id: <1403810017-16062-11-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
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
---
 fs/nfsd/nfs4callback.c | 22 ++++++++++++++++++----
 fs/nfsd/nfs4state.c    | 43 ++++++++++++++++++++++++++++---------------
 fs/nfsd/state.h        |  2 ++
 3 files changed, 48 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 00cb9b7a75f6..771323ae1b33 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
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
 
+static void nfsd4_do_callback_rpc(struct work_struct *w)
+{
+	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback,
+							cb_work);
+	nfsd4_run_callback_rpc(cb);
+}
+
+static void nfsd4_do_cb_recall(struct work_struct *w)
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
+	INIT_WORK(&cb->cb_work, nfsd4_do_cb_recall);
 
 	run_nfsd4_cb(&dp->dl_recall);
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b49b46b0ce23..461229a01963 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -513,7 +513,9 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	lockdep_assert_held(&state_lock);
 
 	dp->dl_stid.sc_type = NFS4_DELEG_STID;
+	spin_lock(&fp->fi_lock);
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
+	spin_unlock(&fp->fi_lock);
 	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 }
 
@@ -521,14 +523,18 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 static void
 unhash_delegation(struct nfs4_delegation *dp)
 {
+	struct nfs4_file *fp = dp->dl_file;
+
 	spin_lock(&state_lock);
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
@@ -2612,6 +2618,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 	lockdep_assert_held(&state_lock);
 
 	atomic_set(&fp->fi_ref, 1);
+	spin_lock_init(&fp->fi_lock);
 	INIT_LIST_HEAD(&fp->fi_stateids);
 	INIT_LIST_HEAD(&fp->fi_delegations);
 	ihold(ino);
@@ -2857,26 +2864,32 @@ out:
 	return ret;
 }
 
-static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
+void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfs4_client *clp = dp->dl_stid.sc_client;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
-	lockdep_assert_held(&state_lock);
+	/*
+	 * We can't do this in nfsd_break_deleg_cb because it is
+	 * already holding inode->i_lock
+	 */
+	spin_lock(&state_lock);
+	if (list_empty(&dp->dl_recall_lru)) {
+		dp->dl_time = get_seconds();
+		list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
+	}
+	spin_unlock(&state_lock);
+}
+
+static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
+{
 	/* We're assuming the state code never drops its reference
 	 * without first removing the lease.  Since we're in this lease
 	 * callback (and since the lease code is serialized by the kernel
 	 * lock) we know the server hasn't removed the lease yet, we know
 	 * it's safe to take a reference: */
 	atomic_inc(&dp->dl_count);
-
-	list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
-
-	/* Only place dl_time is set; protected by i_lock: */
-	dp->dl_time = get_seconds();
-
 	block_delegations(&dp->dl_fh);
-
 	nfsd4_cb_recall(dp);
 }
 
@@ -2901,11 +2914,11 @@ static void nfsd_break_deleg_cb(struct file_lock *fl)
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
index 9447f86f2778..7d6ba06c1abe 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -382,6 +382,7 @@ static inline struct nfs4_lockowner * lockowner(struct nfs4_stateowner *so)
 /* nfs4_file: a file opened by some number of (open) nfs4_stateowners. */
 struct nfs4_file {
 	atomic_t		fi_ref;
+	spinlock_t		fi_lock;
 	struct hlist_node       fi_hash;    /* hash by "struct inode *" */
 	struct list_head        fi_stateids;
 	struct list_head	fi_delegations;
@@ -471,6 +472,7 @@ extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
 extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
+extern void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
-- 
1.9.3

