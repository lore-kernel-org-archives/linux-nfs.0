Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:64252 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696AbaDRSpV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:21 -0400
Received: by mail-ie0-f173.google.com with SMTP id rl12so1910114iec.18
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:21 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 10/70] NFSd: Avoid taking state_lock while holding inode lock in nfsd_break_one_deleg
Date: Fri, 18 Apr 2014 14:44:04 -0400
Message-Id: <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

state_lock is a heavily contended global lock. We don't want to grab
that while simultaneously holding the inode->i_lock
Instead do the list manipulations from the work queue context prior to
starting the rpc call.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4callback.c | 18 ++++++++++++++++--
 fs/nfsd/nfs4state.c    | 25 +++++++++++++++----------
 fs/nfsd/state.h        |  1 +
 3 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 39c8ef875f91..8626cd6af4d1 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1009,9 +1009,8 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 		run_nfsd4_cb(cb);
 }
 
-static void nfsd4_do_callback_rpc(struct work_struct *w)
+static void nfsd4_run_callback_rpc(struct nfsd4_callback *cb)
 {
-	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback, cb_work);
 	struct nfs4_client *clp = cb->cb_clp;
 	struct rpc_clnt *clnt;
 
@@ -1029,11 +1028,25 @@ static void nfsd4_do_callback_rpc(struct work_struct *w)
 			cb->cb_ops, cb);
 }
 
+static void nfsd4_do_callback_rpc(struct work_struct *w)
+{
+	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback, cb_work);
+	nfsd4_run_callback_rpc(cb);
+}
+
 void nfsd4_init_callback(struct nfsd4_callback *cb)
 {
 	INIT_WORK(&cb->cb_work, nfsd4_do_callback_rpc);
 }
 
+static void nfsd4_do_cb_recall(struct work_struct *w)
+{
+	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback, cb_work);
+
+	nfsd4_prepare_cb_recall(cb->cb_op);
+	nfsd4_run_callback_rpc(cb);
+}
+
 void nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfsd4_callback *cb = &dp->dl_recall;
@@ -1050,6 +1063,7 @@ void nfsd4_cb_recall(struct nfs4_delegation *dp)
 
 	INIT_LIST_HEAD(&cb->cb_per_client);
 	cb->cb_done = true;
+	INIT_WORK(&cb->cb_work, nfsd4_do_cb_recall);
 
 	run_nfsd4_cb(&dp->dl_recall);
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6d691aa2bb27..85fcbc9ebd40 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2743,24 +2743,31 @@ out:
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
 	nfsd4_cb_recall(dp);
 }
 
@@ -2785,11 +2792,9 @@ static void nfsd_break_deleg_cb(struct file_lock *fl)
 	 */
 	fl->fl_break_time = 0;
 
-	spin_lock(&state_lock);
 	fp->fi_had_conflict = true;
 	list_for_each_entry(dp, &fp->fi_delegations, dl_perfile)
 		nfsd_break_one_deleg(dp);
-	spin_unlock(&state_lock);
 }
 
 static
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 1aa22f39fc65..02c5a203c738 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -473,6 +473,7 @@ extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
 extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
+extern void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
-- 
1.9.0

