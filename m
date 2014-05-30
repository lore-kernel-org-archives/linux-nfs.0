Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f49.google.com ([209.85.192.49]:42408 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932498AbaE3NJ6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 May 2014 09:09:58 -0400
Received: by mail-qg0-f49.google.com with SMTP id a108so5113934qge.8
        for <linux-nfs@vger.kernel.org>; Fri, 30 May 2014 06:09:57 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, bhalevy@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH 9/9] NFSd: protect delegation setup with the i_lock
Date: Fri, 30 May 2014 09:09:33 -0400
Message-Id: <1401455373-18207-10-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
References: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

state_lock is a heavily contended global lock. We don't want to grab
that while simultaneously holding the inode->i_lock. Avoid doing that in
the delegation break callback by ensuring that we add/remove the
dl_perfile under the inode->i_lock.

This however, can cause an ABBA deadlock between the state_lock and the
i_lock. Work around that by doing the list manipulation in the delegation
recall from the workqueue context prior to starting the rpc call.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4callback.c | 18 ++++++++++++++++--
 fs/nfsd/nfs4state.c    | 41 +++++++++++++++++++++++++++--------------
 fs/nfsd/state.h        |  1 +
 3 files changed, 44 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 2c73cae9899d..3d67bbf26cee 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1011,9 +1011,8 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 		run_nfsd4_cb(cb);
 }
 
-static void nfsd4_do_callback_rpc(struct work_struct *w)
+static void nfsd4_run_callback_rpc(struct nfsd4_callback *cb)
 {
-	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback, cb_work);
 	struct nfs4_client *clp = cb->cb_clp;
 	struct rpc_clnt *clnt;
 
@@ -1031,11 +1030,25 @@ static void nfsd4_do_callback_rpc(struct work_struct *w)
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
@@ -1052,6 +1065,7 @@ void nfsd4_cb_recall(struct nfs4_delegation *dp)
 
 	INIT_LIST_HEAD(&cb->cb_per_client);
 	cb->cb_done = true;
+	INIT_WORK(&cb->cb_work, nfsd4_do_cb_recall);
 
 	run_nfsd4_cb(&dp->dl_recall);
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 553c2d6d48dc..c249c5261640 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -438,7 +438,9 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	lockdep_assert_held(&state_lock);
 
 	dp->dl_stid.sc_type = NFS4_DELEG_STID;
+	spin_lock(&fp->fi_inode->i_lock);
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
+	spin_unlock(&fp->fi_inode->i_lock);
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
+		spin_lock(&fp->fi_inode->i_lock);
+		list_del_init(&dp->dl_perfile);
+		spin_unlock(&fp->fi_inode->i_lock);
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
@@ -2766,24 +2774,31 @@ out:
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
 
@@ -2808,11 +2823,9 @@ static void nfsd_break_deleg_cb(struct file_lock *fl)
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
index 374c66283ac5..aacccb2a476c 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -472,6 +472,7 @@ extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
 extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
+extern void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
-- 
1.9.3

