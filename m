Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:38375 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755206AbaGUTLl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 15:11:41 -0400
Received: by mail-ie0-f170.google.com with SMTP id rl12so7252468iec.15
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 12:11:41 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Enforce an upper limit on the number of cached access call
Date: Mon, 21 Jul 2014 15:11:42 -0400
Message-Id: <1405969902-11477-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1405969902-11477-1-git-send-email-trond.myklebust@primarydata.com>
References: <1405969902-11477-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This may be used to limit the number of cached credentials building up
inside the access cache.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c | 40 ++++++++++++++++++++++++++++++++++------
 1 file changed, 34 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4a3d4ef76127..285392e2c946 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2028,6 +2028,10 @@ static DEFINE_SPINLOCK(nfs_access_lru_lock);
 static LIST_HEAD(nfs_access_lru_list);
 static atomic_long_t nfs_access_nr_entries;
 
+static unsigned long nfs_access_max_cachesize = ULONG_MAX;
+module_param(nfs_access_max_cachesize, ulong, 0644);
+MODULE_PARM_DESC(nfs_access_max_cachesize, "NFS access maximum total cache length");
+
 static void nfs_access_free_entry(struct nfs_access_entry *entry)
 {
 	put_rpccred(entry->cred);
@@ -2049,18 +2053,13 @@ static void nfs_access_free_list(struct list_head *head)
 }
 
 unsigned long
-nfs_access_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
+nfs_do_access_cache_scan(unsigned int nr_to_scan)
 {
 	LIST_HEAD(head);
 	struct nfs_inode *nfsi, *next;
 	struct nfs_access_entry *cache;
-	int nr_to_scan = sc->nr_to_scan;
-	gfp_t gfp_mask = sc->gfp_mask;
 	long freed = 0;
 
-	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
-		return SHRINK_STOP;
-
 	spin_lock(&nfs_access_lru_lock);
 	list_for_each_entry_safe(nfsi, next, &nfs_access_lru_list, access_cache_inode_lru) {
 		struct inode *inode;
@@ -2094,11 +2093,39 @@ remove_lru_entry:
 }
 
 unsigned long
+nfs_access_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
+{
+	int nr_to_scan = sc->nr_to_scan;
+	gfp_t gfp_mask = sc->gfp_mask;
+
+	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
+		return SHRINK_STOP;
+	return nfs_do_access_cache_scan(nr_to_scan);
+}
+
+
+unsigned long
 nfs_access_cache_count(struct shrinker *shrink, struct shrink_control *sc)
 {
 	return vfs_pressure_ratio(atomic_long_read(&nfs_access_nr_entries));
 }
 
+static void
+nfs_access_cache_enforce_limit(void)
+{
+	long nr_entries = atomic_long_read(&nfs_access_nr_entries);
+	unsigned long diff;
+	unsigned int nr_to_scan;
+
+	if (nr_entries < 0 || nr_entries <= nfs_access_max_cachesize)
+		return;
+	nr_to_scan = 100;
+	diff = nr_entries - nfs_access_max_cachesize;
+	if (diff < nr_to_scan)
+		nr_to_scan = diff;
+	nfs_do_access_cache_scan(nr_to_scan);
+}
+
 static void __nfs_access_zap_cache(struct nfs_inode *nfsi, struct list_head *head)
 {
 	struct rb_root *root_node = &nfsi->access_cache;
@@ -2244,6 +2271,7 @@ void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *set)
 					&nfs_access_lru_list);
 		spin_unlock(&nfs_access_lru_lock);
 	}
+	nfs_access_cache_enforce_limit();
 }
 EXPORT_SYMBOL_GPL(nfs_access_add_cache);
 
-- 
1.9.3

