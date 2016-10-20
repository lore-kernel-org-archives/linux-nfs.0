Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55968 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751741AbcJTPoA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Oct 2016 11:44:00 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: move blocked lock handling under a dedicated spinlock
Date: Thu, 20 Oct 2016 11:43:58 -0400
Message-Id: <1476978238-2449-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce was hitting some lockdep warnings in testing, showing that we
could hit a deadlock with the new CB_NOTIFY_LOCK handling, in a
rather complex situation involving four different spinlocks.

The crux of the matter is that we end up taking the nn->client_lock in
the lm_notify handler, while we're already holding the global
blocked_lock_lock. The simplest fix is to just declare a new
per-nfsd_net spinlock to protect the new CB_NOTIFY_LOCK structures.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/netns.h     |  5 +++++
 fs/nfsd/nfs4state.c | 28 +++++++++++++++-------------
 fs/nfsd/state.h     |  2 +-
 3 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index b10d557f9c9e..ee36efd5aece 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -84,6 +84,8 @@ struct nfsd_net {
 	struct list_head client_lru;
 	struct list_head close_lru;
 	struct list_head del_recall_lru;
+
+	/* protected by blocked_locks_lock */
 	struct list_head blocked_locks_lru;
 
 	struct delayed_work laundromat_work;
@@ -91,6 +93,9 @@ struct nfsd_net {
 	/* client_lock protects the client lru list and session hash table */
 	spinlock_t client_lock;
 
+	/* protects blocked_locks_lru */
+	spinlock_t blocked_locks_lock;
+
 	struct file *rec_file;
 	bool in_grace;
 	const struct nfsd4_client_tracking_ops *client_tracking_ops;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9752beb78659..95474196a17e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -217,7 +217,7 @@ find_blocked_lock(struct nfs4_lockowner *lo, struct knfsd_fh *fh,
 {
 	struct nfsd4_blocked_lock *cur, *found = NULL;
 
-	spin_lock(&nn->client_lock);
+	spin_lock(&nn->blocked_locks_lock);
 	list_for_each_entry(cur, &lo->lo_blocked, nbl_list) {
 		if (fh_match(fh, &cur->nbl_fh)) {
 			list_del_init(&cur->nbl_list);
@@ -226,7 +226,7 @@ find_blocked_lock(struct nfs4_lockowner *lo, struct knfsd_fh *fh,
 			break;
 		}
 	}
-	spin_unlock(&nn->client_lock);
+	spin_unlock(&nn->blocked_locks_lock);
 	if (found)
 		posix_unblock_lock(&found->nbl_lock);
 	return found;
@@ -4665,7 +4665,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 	 * indefinitely once the lock does become free.
 	 */
 	BUG_ON(!list_empty(&reaplist));
-	spin_lock(&nn->client_lock);
+	spin_lock(&nn->blocked_locks_lock);
 	while (!list_empty(&nn->blocked_locks_lru)) {
 		nbl = list_first_entry(&nn->blocked_locks_lru,
 					struct nfsd4_blocked_lock, nbl_lru);
@@ -4678,7 +4678,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 		list_move(&nbl->nbl_lru, &reaplist);
 		list_del_init(&nbl->nbl_list);
 	}
-	spin_unlock(&nn->client_lock);
+	spin_unlock(&nn->blocked_locks_lock);
 
 	while (!list_empty(&reaplist)) {
 		nbl = list_first_entry(&nn->blocked_locks_lru,
@@ -5439,13 +5439,13 @@ nfsd4_lm_notify(struct file_lock *fl)
 	bool queue = false;
 
 	/* An empty list means that something else is going to be using it */
-	spin_lock(&nn->client_lock);
+	spin_lock(&nn->blocked_locks_lock);
 	if (!list_empty(&nbl->nbl_list)) {
 		list_del_init(&nbl->nbl_list);
 		list_del_init(&nbl->nbl_lru);
 		queue = true;
 	}
-	spin_unlock(&nn->client_lock);
+	spin_unlock(&nn->blocked_locks_lock);
 
 	if (queue)
 		nfsd4_run_cb(&nbl->nbl_cb);
@@ -5868,10 +5868,10 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	if (fl_flags & FL_SLEEP) {
 		nbl->nbl_time = jiffies;
-		spin_lock(&nn->client_lock);
+		spin_lock(&nn->blocked_locks_lock);
 		list_add_tail(&nbl->nbl_list, &lock_sop->lo_blocked);
 		list_add_tail(&nbl->nbl_lru, &nn->blocked_locks_lru);
-		spin_unlock(&nn->client_lock);
+		spin_unlock(&nn->blocked_locks_lock);
 	}
 
 	err = vfs_lock_file(filp, F_SETLK, file_lock, conflock);
@@ -5900,10 +5900,10 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (nbl) {
 		/* dequeue it if we queued it before */
 		if (fl_flags & FL_SLEEP) {
-			spin_lock(&nn->client_lock);
+			spin_lock(&nn->blocked_locks_lock);
 			list_del_init(&nbl->nbl_list);
 			list_del_init(&nbl->nbl_lru);
-			spin_unlock(&nn->client_lock);
+			spin_unlock(&nn->blocked_locks_lock);
 		}
 		free_blocked_lock(nbl);
 	}
@@ -6943,9 +6943,11 @@ static int nfs4_state_create_net(struct net *net)
 	INIT_LIST_HEAD(&nn->client_lru);
 	INIT_LIST_HEAD(&nn->close_lru);
 	INIT_LIST_HEAD(&nn->del_recall_lru);
-	INIT_LIST_HEAD(&nn->blocked_locks_lru);
 	spin_lock_init(&nn->client_lock);
 
+	spin_lock_init(&nn->blocked_locks_lock);
+	INIT_LIST_HEAD(&nn->blocked_locks_lru);
+
 	INIT_DELAYED_WORK(&nn->laundromat_work, laundromat_main);
 	get_net(net);
 
@@ -7063,14 +7065,14 @@ nfs4_state_shutdown_net(struct net *net)
 	}
 
 	BUG_ON(!list_empty(&reaplist));
-	spin_lock(&nn->client_lock);
+	spin_lock(&nn->blocked_locks_lock);
 	while (!list_empty(&nn->blocked_locks_lru)) {
 		nbl = list_first_entry(&nn->blocked_locks_lru,
 					struct nfsd4_blocked_lock, nbl_lru);
 		list_move(&nbl->nbl_lru, &reaplist);
 		list_del_init(&nbl->nbl_list);
 	}
-	spin_unlock(&nn->client_lock);
+	spin_unlock(&nn->blocked_locks_lock);
 
 	while (!list_empty(&reaplist)) {
 		nbl = list_first_entry(&nn->blocked_locks_lru,
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index c9399366f9df..bccdbe0f63d9 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -444,7 +444,7 @@ struct nfs4_openowner {
  */
 struct nfs4_lockowner {
 	struct nfs4_stateowner	lo_owner;	/* must be first element */
-	struct list_head	lo_blocked;	/* blocked file_locks */
+	struct list_head	lo_blocked;	/* protected by nn->blocked_locks_lock */
 };
 
 static inline struct nfs4_openowner * openowner(struct nfs4_stateowner *so)
-- 
2.7.4

