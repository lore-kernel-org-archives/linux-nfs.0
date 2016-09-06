Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56402 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754028AbcIFPEw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Sep 2016 11:04:52 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/4] nfsd: add a LRU list for blocked locks
Date: Tue,  6 Sep 2016 11:04:49 -0400
Message-Id: <1473174290-29612-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1473174290-29612-1-git-send-email-jlayton@redhat.com>
References: <1473174290-29612-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible for a client to call in on a lock that is blocked for a
long time, but discontinue polling for it. A malicious client could
even set a lock on a file, and then spam the server with failing lock
requests from different lockowners that pile up in a DoS attack.

Add the blocked lock structures to a per-net namespace LRU when hashing
them, and timestamp them. If the lock request is not revisited after a
lease period, we'll drop it under the assumption that the client is no
longer interested.

This also gives us a mechanism to clean up these objects at server
shutdown time as well.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/netns.h     |  1 +
 fs/nfsd/nfs4state.c | 62 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/state.h     |  2 ++
 3 files changed, 65 insertions(+)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 5fbf3bbd00d0..b10d557f9c9e 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -84,6 +84,7 @@ struct nfsd_net {
 	struct list_head client_lru;
 	struct list_head close_lru;
 	struct list_head del_recall_lru;
+	struct list_head blocked_locks_lru;
 
 	struct delayed_work laundromat_work;
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ca0db4974e5b..6c74d9a45163 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -221,6 +221,7 @@ find_blocked_lock(struct nfs4_lockowner *lo, struct knfsd_fh *fh,
 	list_for_each_entry(cur, &lo->lo_blocked, nbl_list) {
 		if (fh_match(fh, &cur->nbl_fh)) {
 			list_del_init(&cur->nbl_list);
+			list_del_init(&cur->nbl_lru);
 			found = cur;
 			break;
 		}
@@ -4580,6 +4581,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 	struct nfs4_openowner *oo;
 	struct nfs4_delegation *dp;
 	struct nfs4_ol_stateid *stp;
+	struct nfsd4_blocked_lock *nbl;
 	struct list_head *pos, *next, reaplist;
 	time_t cutoff = get_seconds() - nn->nfsd4_lease;
 	time_t t, new_timeo = nn->nfsd4_lease;
@@ -4648,6 +4650,41 @@ nfs4_laundromat(struct nfsd_net *nn)
 	}
 	spin_unlock(&nn->client_lock);
 
+	/*
+	 * It's possible for a client to try and acquire an already held lock
+	 * that is being held for a long time, and then lose interest in it.
+	 * So, we clean out any un-revisited request after a lease period
+	 * under the assumption that the client is no longer interested.
+	 *
+	 * RFC5661, sec. 9.6 states that the client must not rely on getting
+	 * notifications and must continue to poll for locks, even when the
+	 * server supports them. Thus this shouldn't lead to clients blocking
+	 * indefinitely once the lock does become free.
+	 */
+	BUG_ON(!list_empty(&reaplist));
+	spin_lock(&nn->client_lock);
+	while (!list_empty(&nn->blocked_locks_lru)) {
+		nbl = list_first_entry(&nn->blocked_locks_lru,
+					struct nfsd4_blocked_lock, nbl_lru);
+		if (time_after((unsigned long)nbl->nbl_time,
+			       (unsigned long)cutoff)) {
+			t = nbl->nbl_time - cutoff;
+			new_timeo = min(new_timeo, t);
+			break;
+		}
+		list_move(&nbl->nbl_lru, &reaplist);
+		list_del_init(&nbl->nbl_list);
+	}
+	spin_unlock(&nn->client_lock);
+
+	while (!list_empty(&reaplist)) {
+		nbl = list_first_entry(&nn->blocked_locks_lru,
+					struct nfsd4_blocked_lock, nbl_lru);
+		list_del_init(&nbl->nbl_lru);
+		posix_unblock_lock(&nbl->nbl_lock);
+		free_blocked_lock(nbl);
+	}
+
 	new_timeo = max_t(time_t, new_timeo, NFSD_LAUNDROMAT_MINTIMEOUT);
 	return new_timeo;
 }
@@ -5398,9 +5435,11 @@ nfsd4_lm_notify(struct file_lock *fl)
 						struct nfsd4_blocked_lock, nbl_lock);
 	bool queue = false;
 
+	/* An empty list means that something else is going to be using it */
 	spin_lock(&nn->client_lock);
 	if (!list_empty(&nbl->nbl_list)) {
 		list_del_init(&nbl->nbl_list);
+		list_del_init(&nbl->nbl_lru);
 		queue = true;
 	}
 	spin_unlock(&nn->client_lock);
@@ -5825,8 +5864,10 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 
 	if (fl_flags & FL_SLEEP) {
+		nbl->nbl_time = jiffies;
 		spin_lock(&nn->client_lock);
 		list_add_tail(&nbl->nbl_list, &lock_sop->lo_blocked);
+		list_add_tail(&nbl->nbl_lru, &nn->blocked_locks_lru);
 		spin_unlock(&nn->client_lock);
 	}
 
@@ -5858,6 +5899,7 @@ out:
 		if (fl_flags & FL_SLEEP) {
 			spin_lock(&nn->client_lock);
 			list_del_init(&nbl->nbl_list);
+			list_del_init(&nbl->nbl_lru);
 			spin_unlock(&nn->client_lock);
 		}
 		free_blocked_lock(nbl);
@@ -6898,6 +6940,7 @@ static int nfs4_state_create_net(struct net *net)
 	INIT_LIST_HEAD(&nn->client_lru);
 	INIT_LIST_HEAD(&nn->close_lru);
 	INIT_LIST_HEAD(&nn->del_recall_lru);
+	INIT_LIST_HEAD(&nn->blocked_locks_lru);
 	spin_lock_init(&nn->client_lock);
 
 	INIT_DELAYED_WORK(&nn->laundromat_work, laundromat_main);
@@ -6995,6 +7038,7 @@ nfs4_state_shutdown_net(struct net *net)
 	struct nfs4_delegation *dp = NULL;
 	struct list_head *pos, *next, reaplist;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	struct nfsd4_blocked_lock *nbl;
 
 	cancel_delayed_work_sync(&nn->laundromat_work);
 	locks_end_grace(&nn->nfsd4_manager);
@@ -7015,6 +7059,24 @@ nfs4_state_shutdown_net(struct net *net)
 		nfs4_put_stid(&dp->dl_stid);
 	}
 
+	BUG_ON(!list_empty(&reaplist));
+	spin_lock(&nn->client_lock);
+	while (!list_empty(&nn->blocked_locks_lru)) {
+		nbl = list_first_entry(&nn->blocked_locks_lru,
+					struct nfsd4_blocked_lock, nbl_lru);
+		list_move(&nbl->nbl_lru, &reaplist);
+		list_del_init(&nbl->nbl_list);
+	}
+	spin_unlock(&nn->client_lock);
+
+	while (!list_empty(&reaplist)) {
+		nbl = list_first_entry(&nn->blocked_locks_lru,
+					struct nfsd4_blocked_lock, nbl_lru);
+		list_del_init(&nbl->nbl_lru);
+		posix_unblock_lock(&nbl->nbl_lock);
+		free_blocked_lock(nbl);
+	}
+
 	nfsd4_client_tracking_exit(net);
 	nfs4_state_destroy_net(net);
 }
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f6ffeac391f4..abf0fe251f50 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -588,6 +588,8 @@ static inline bool nfsd4_stateid_generation_after(stateid_t *a, stateid_t *b)
  */
 struct nfsd4_blocked_lock {
 	struct list_head	nbl_list;
+	struct list_head	nbl_lru;
+	unsigned long		nbl_time;
 	struct file_lock	nbl_lock;
 	struct knfsd_fh		nbl_fh;
 	struct nfsd4_callback	nbl_cb;
-- 
2.7.4

