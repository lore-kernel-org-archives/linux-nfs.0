Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f53.google.com ([209.85.213.53]:36768 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753264Ab3A1TuL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:50:11 -0500
Received: by mail-yh0-f53.google.com with SMTP id q3so469286yhf.12
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:50:11 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 15/16] nfsd: register a shrinker for DRC cache entries
Date: Mon, 28 Jan 2013 14:41:21 -0500
Message-Id: <1359402082-29195-16-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since we dynamically allocate them now, allow the system to call us
up to release them if we get low on memory.

We set the "seeks" value very high, to discourage it and release
them in LRU order. We may end up releasing some prematurely if the
box is really low on memory.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 54 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 53 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index bd21230..27edd47 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -35,6 +35,18 @@ static inline u32 request_hash(u32 xid)
 
 static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
 static void	cache_cleaner_func(struct work_struct *unused);
+static int 	nfsd_reply_cache_shrink(struct shrinker *shrink,
+					struct shrink_control *sc);
+
+/*
+ * We set "seeks" to a large value here since we really can't recreate these
+ * entries. We're just gambling that they won't actually be needed if and
+ * when the box comes under memory pressure.
+ */
+struct shrinker nfsd_reply_cache_shrinker = {
+	.shrink	= nfsd_reply_cache_shrink,
+	.seeks	= 64,
+};
 
 /*
  * locking for the reply cache:
@@ -80,6 +92,7 @@ nfsd_reply_cache_free(struct svc_cacherep *rp)
 
 int nfsd_reply_cache_init(void)
 {
+	register_shrinker(&nfsd_reply_cache_shrinker);
 	drc_slab = kmem_cache_create("nfsd_drc", sizeof(struct svc_cacherep),
 					0, 0, NULL);
 	if (!drc_slab)
@@ -102,6 +115,7 @@ void nfsd_reply_cache_shutdown(void)
 {
 	struct svc_cacherep	*rp;
 
+	unregister_shrinker(&nfsd_reply_cache_shrinker);
 	cancel_delayed_work_sync(&cache_cleaner);
 
 	while (!list_empty(&lru_head)) {
@@ -152,15 +166,17 @@ nfsd_cache_entry_expired(struct svc_cacherep *rp)
  * if we hit one that isn't old enough, then we can stop the walking. Must
  * be called with cache_lock held.
  */
-static void
+static int
 prune_old_cache_entries(void)
 {
+	int freed = 0;
 	struct svc_cacherep *rp, *tmp;
 
 	list_for_each_entry_safe(rp, tmp, &lru_head, c_lru) {
 		if (!nfsd_cache_entry_expired(rp))
 			break;
 		nfsd_reply_cache_free_locked(rp);
+		++freed;
 	}
 
 	/*
@@ -173,6 +189,8 @@ prune_old_cache_entries(void)
 		cancel_delayed_work(&cache_cleaner);
 	else
 		mod_delayed_work(system_wq, &cache_cleaner, RC_EXPIRE);
+
+	return freed;
 }
 
 static void
@@ -183,6 +201,40 @@ cache_cleaner_func(struct work_struct *unused)
 	spin_unlock(&cache_lock);
 }
 
+static int
+nfsd_reply_cache_shrink(struct shrinker *shrink, struct shrink_control *sc)
+{
+	int nr_to_scan = sc->nr_to_scan;
+	unsigned int num;
+
+	spin_lock(&cache_lock);
+	if (!nr_to_scan)
+		goto out;
+
+	nr_to_scan -= prune_old_cache_entries();
+
+	/*
+	 * If that didn't free enough, then keep going. It's better to free
+	 * some prematurely than to have the box keel over due to lack of
+	 * memory.
+	 */
+	while (nr_to_scan > 0) {
+		struct svc_cacherep *rp;
+
+		if (list_empty(&lru_head))
+			break;
+		rp = list_first_entry(&lru_head, struct svc_cacherep, c_lru);
+		nfsd_reply_cache_free_locked(rp);
+		--nr_to_scan;
+	}
+
+out:
+	num = num_drc_entries;
+	spin_unlock(&cache_lock);
+
+	return num;
+}
+
 /*
  * Search the request hash for an entry that matches the given rqstp.
  * Must be called with cache_lock held. Returns the found entry or
-- 
1.7.11.7

