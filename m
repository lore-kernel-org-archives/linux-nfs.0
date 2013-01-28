Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f180.google.com ([209.85.160.180]:38152 "EHLO
	mail-gh0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181Ab3A1TtF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:49:05 -0500
Received: by mail-gh0-f180.google.com with SMTP id f13so467096ghb.25
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:49:04 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 13/16] nfsd: add recurring workqueue job to clean the cache
Date: Mon, 28 Jan 2013 14:41:19 -0500
Message-Id: <1359402082-29195-14-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's not sufficient to only clean the cache when requests come in. What
if we have a flurry of activity and then the server goes idle? Add a
workqueue job that will clean the cache every RC_EXPIRE period.

Care is taken to only run this when we expect to have entries expiring.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 50 +++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 47 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 6b4693c..896e1c0 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -33,6 +33,7 @@ static inline u32 request_hash(u32 xid)
 }
 
 static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
+static void	cache_cleaner_func(struct work_struct *unused);
 
 /*
  * locking for the reply cache:
@@ -40,6 +41,7 @@ static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
  * Otherwise, it when accessing _prev or _next, the lock must be held.
  */
 static DEFINE_SPINLOCK(cache_lock);
+static DECLARE_DELAYED_WORK(cache_cleaner, cache_cleaner_func);
 
 static struct svc_cacherep *
 nfsd_reply_cache_alloc(void)
@@ -97,6 +99,8 @@ void nfsd_reply_cache_shutdown(void)
 {
 	struct svc_cacherep	*rp;
 
+	cancel_delayed_work_sync(&cache_cleaner);
+
 	while (!list_empty(&lru_head)) {
 		rp = list_entry(lru_head.next, struct svc_cacherep, c_lru);
 		nfsd_reply_cache_free_locked(rp);
@@ -112,13 +116,15 @@ void nfsd_reply_cache_shutdown(void)
 }
 
 /*
- * Move cache entry to end of LRU list
+ * Move cache entry to end of LRU list, and queue the cleaner to run if it's
+ * not already scheduled.
  */
 static void
 lru_put_end(struct svc_cacherep *rp)
 {
 	rp->c_timestamp = jiffies;
 	list_move_tail(&rp->c_lru, &lru_head);
+	schedule_delayed_work(&cache_cleaner, RC_EXPIRE);
 }
 
 /*
@@ -139,6 +145,42 @@ nfsd_cache_entry_expired(struct svc_cacherep *rp)
 }
 
 /*
+ * Walk the LRU list and prune off entries that are older than RC_EXPIRE
+ * if we hit one that isn't old enough, then we can stop the walking. Must
+ * be called with cache_lock held.
+ */
+static void
+prune_old_cache_entries(void)
+{
+	struct svc_cacherep *rp, *tmp;
+
+	list_for_each_entry_safe(rp, tmp, &lru_head, c_lru) {
+		if (!nfsd_cache_entry_expired(rp))
+			break;
+		nfsd_reply_cache_free_locked(rp);
+	}
+
+	/*
+	 * Conditionally rearm the job. If we cleaned out the list, then
+	 * cancel any pending run (since there won't be any work to do).
+	 * Otherwise, we rearm the job or modify the existing one to run in
+	 * RC_EXPIRE since we know that nothing will expire until then.
+	 */
+	if (list_empty(&lru_head))
+		cancel_delayed_work(&cache_cleaner);
+	else
+		mod_delayed_work(system_wq, &cache_cleaner, RC_EXPIRE);
+}
+
+static void
+cache_cleaner_func(struct work_struct *unused)
+{
+	spin_lock(&cache_lock);
+	prune_old_cache_entries();
+	spin_unlock(&cache_lock);
+}
+
+/*
  * Search the request hash for an entry that matches the given rqstp.
  * Must be called with cache_lock held. Returns the found entry or
  * NULL on failure.
@@ -158,7 +200,6 @@ nfsd_cache_search(struct svc_rqst *rqstp)
 	hlist_for_each_entry(rp, hn, rh, c_hash) {
 		if (xid == rp->c_xid && proc == rp->c_proc &&
 		    proto == rp->c_prot && vers == rp->c_vers &&
-		    !nfsd_cache_entry_expired(rp) &&
 		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
 		    rpc_get_port(svc_addr(rqstp)) == rpc_get_port((struct sockaddr *)&rp->c_addr))
 			return rp;
@@ -202,8 +243,11 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	 */
 	if (!list_empty(&lru_head)) {
 		rp = list_first_entry(&lru_head, struct svc_cacherep, c_lru);
-		if (nfsd_cache_entry_expired(rp))
+		if (nfsd_cache_entry_expired(rp)) {
+			lru_put_end(rp);
+			prune_old_cache_entries();
 			goto setup_entry;
+		}
 	}
 
 	spin_unlock(&cache_lock);
-- 
1.7.11.7

