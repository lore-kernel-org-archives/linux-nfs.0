Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f54.google.com ([209.85.192.54]:44445 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbaFFNHW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jun 2014 09:07:22 -0400
Received: by mail-qg0-f54.google.com with SMTP id q108so4344465qgd.13
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jun 2014 06:07:21 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        hch@infradead.org
Subject: [PATCH v2 2/2] nfsd: avoid taking the state_lock while holding the i_lock
Date: Fri,  6 Jun 2014 09:07:06 -0400
Message-Id: <1402060026-26511-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1402060026-26511-1-git-send-email-jlayton@primarydata.com>
References: <1402060026-26511-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

state_lock is a heavily contended global lock. We don't want to grab
that while simultaneously holding the inode->i_lock. Avoid doing that in
the delegation break callback by ensuring that we add/remove the
dl_perfile under a new per-nfs4_file fi_lock, and hold that while walking
the fi_delegations list.

We still do need to queue the delegations to the global del_recall_lru
list. Do that in the rpc_prepare op for the delegation recall RPC. It's
possible though that the allocation of the rpc_task will fail, which
would cause the delegation to be leaked.

If that occurs rpc_release is still called, so we also do it there if
the rpc_task failed to run. This brings up another dilemma -- how do
we know whether it got queued in rpc_prepare or not?

In order to determine that, we set the dl_time to 0 in the delegation
break callback from the VFS and only set it when we queue it to the
list. If it's still zero by the time we get to rpc_release, then we know
that it never got queued and we can do it then.

Cc: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4callback.c |  9 ++++--
 fs/nfsd/nfs4state.c    | 74 +++++++++++++++++++++++++++++++++++++-------------
 fs/nfsd/state.h        |  2 ++
 3 files changed, 64 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 2c73cae9899d..3d01637d950c 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -810,12 +810,15 @@ static bool nfsd41_cb_get_slot(struct nfs4_client *clp, struct rpc_task *task)
  * TODO: cb_sequence should support referring call lists, cachethis, multiple
  * slots, and mark callback channel down on communication errors.
  */
-static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
+static void nfsd4_cb_recall_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfsd4_callback *cb = calldata;
 	struct nfs4_client *clp = cb->cb_clp;
+	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
 	u32 minorversion = clp->cl_minorversion;
 
+	nfsd4_queue_to_del_recall_lru(dp);
+
 	cb->cb_minorversion = minorversion;
 	if (minorversion) {
 		if (!nfsd41_cb_get_slot(clp, task))
@@ -900,6 +903,8 @@ static void nfsd4_cb_recall_release(void *calldata)
 	struct nfs4_client *clp = cb->cb_clp;
 	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
 
+	nfsd4_queue_to_del_recall_lru(dp);
+
 	if (cb->cb_done) {
 		spin_lock(&clp->cl_lock);
 		list_del(&cb->cb_per_client);
@@ -909,7 +914,7 @@ static void nfsd4_cb_recall_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfsd4_cb_recall_ops = {
-	.rpc_call_prepare = nfsd4_cb_prepare,
+	.rpc_call_prepare = nfsd4_cb_recall_prepare,
 	.rpc_call_done = nfsd4_cb_recall_done,
 	.rpc_release = nfsd4_cb_recall_release,
 };
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cbec573e9445..f429883fb4bb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -438,7 +438,9 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	lockdep_assert_held(&state_lock);
 
 	dp->dl_stid.sc_type = NFS4_DELEG_STID;
+	spin_lock(&fp->fi_lock);
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
+	spin_unlock(&fp->fi_lock);
 	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 }
 
@@ -446,14 +448,20 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 static void
 unhash_delegation(struct nfs4_delegation *dp)
 {
+	struct nfs4_file *fp = dp->dl_file;
+
 	spin_lock(&state_lock);
 	list_del_init(&dp->dl_perclnt);
-	list_del_init(&dp->dl_perfile);
 	list_del_init(&dp->dl_recall_lru);
+	if (!list_empty(&dp->dl_perfile)) {
+		spin_lock(&fp->fi_lock);
+		list_del_init(&dp->dl_perfile);
+		spin_unlock(&fp->fi_lock);
+	}
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
@@ -2522,6 +2530,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 	lockdep_assert_held(&state_lock);
 
 	atomic_set(&fp->fi_ref, 1);
+	spin_lock_init(&fp->fi_lock);
 	INIT_LIST_HEAD(&fp->fi_stateids);
 	INIT_LIST_HEAD(&fp->fi_delegations);
 	ihold(ino);
@@ -2767,23 +2776,49 @@ out:
 	return ret;
 }
 
+/*
+ * We use a dl_time of 0 as an indicator that the delegation is "disconnected"
+ * from the client lists. If we find that that's the case, set the dl_time and
+ * then queue it to the list.
+ */
+void
+nfsd4_queue_to_del_recall_lru(struct nfs4_delegation *dp)
+{
+	struct nfs4_file *fp = dp->dl_file;
+	struct nfsd_net *nn = net_generic(dp->dl_stid.sc_client->net, nfsd_net_id);
+
+	spin_lock(&fp->fi_lock);
+	if (dp->dl_time) {
+		dp->dl_time = get_seconds();
+		spin_unlock(&fp->fi_lock);
+		spin_lock(&state_lock);
+		list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
+		spin_unlock(&state_lock);
+	} else {
+		spin_unlock(&fp->fi_lock);
+	}
+}
+
 static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 {
-	struct nfs4_client *clp = dp->dl_stid.sc_client;
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	lockdep_assert_held(&dp->dl_file->fi_lock);
 
-	lockdep_assert_held(&state_lock);
-	/* We're assuming the state code never drops its reference
+	/*
+	 * We're assuming the state code never drops its reference
 	 * without first removing the lease.  Since we're in this lease
-	 * callback (and since the lease code is serialized by the kernel
-	 * lock) we know the server hasn't removed the lease yet, we know
-	 * it's safe to take a reference: */
+	 * callback (and since the lease code is serialized by the i_lock
+	 * we know the server hasn't removed the lease yet, we know it's
+	 * safe to take a reference.
+	 */
 	atomic_inc(&dp->dl_count);
 
-	list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
-
-	/* Only place dl_time is set; protected by i_lock: */
-	dp->dl_time = get_seconds();
+	/*
+	 * We use a dl_time of 0 to indicate that the delegation has
+	 * not yet been queued to the nn->del_recall_lru list. That's
+	 * done in the rpc_prepare or rpc_release operations (depending
+	 * on which one gets there first).
+	 */
+	dp->dl_time = 0;
 
 	nfsd4_cb_recall(dp);
 }
@@ -2809,11 +2844,11 @@ static void nfsd_break_deleg_cb(struct file_lock *fl)
 	 */
 	fl->fl_break_time = 0;
 
-	spin_lock(&state_lock);
+	spin_lock(&fp->fi_lock);
 	fp->fi_had_conflict = true;
 	list_for_each_entry(dp, &fp->fi_delegations, dl_perfile)
 		nfsd_break_one_deleg(dp);
-	spin_unlock(&state_lock);
+	spin_unlock(&fp->fi_lock);
 }
 
 static
@@ -3454,8 +3489,9 @@ nfs4_laundromat(struct nfsd_net *nn)
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		if (net_generic(dp->dl_stid.sc_client->net, nfsd_net_id) != nn)
 			continue;
-		if (time_after((unsigned long)dp->dl_time, (unsigned long)cutoff)) {
-			t = dp->dl_time - cutoff;
+		t = dp->dl_time;
+		if (time_after((unsigned long)t, (unsigned long)cutoff)) {
+			t -= cutoff;
 			new_timeo = min(new_timeo, t);
 			break;
 		}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 374c66283ac5..eae4fcaa5fd4 100644
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
@@ -472,6 +473,7 @@ extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
 extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
+extern void nfsd4_queue_to_del_recall_lru(struct nfs4_delegation *);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
-- 
1.9.3

