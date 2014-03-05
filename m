Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52107 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756032AbaCEDCU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2014 22:02:20 -0500
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 05 Mar 2014 14:00:28 +1100
Subject: [PATCH 8/8] NFS: allow lockless access to access_cache
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140305030028.27421.87633.stgit@notabene.brown>
In-Reply-To: <20140305025813.27421.23871.stgit@notabene.brown>
References: <20140305025813.27421.23871.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The access cache is used during RCU-walk path lookups, so it is best
to avoid locking if possible as taking a lock kills concurrency.

The rbtree is not rcu-safe and cannot easily be made so.
Instead we simply check the last (i.e. most recent) entry on the LRU
list.  If this doesn't match, then we return -ECHILD and retry in
lock/refcount mode.

This requires freeing the nfs_access_entry struct with rcu, and
requires using rcu access primates when adding entries to the lru, and
when examining the last entry.

Calling put_rpccred before kfree_rcu looks a bit odd, but as
put_rpccred already provide rcu protection, we know that the cred will
not actually be freed until the next grace period, so any concurrent
access will be safe.

This patch provides about 5% performance improvement on a stat-heavy
synthetic work load with 4 threads on a 2-core CPU.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/dir.c           |   41 +++++++++++++++++++++++++++++++++++++++--
 include/linux/nfs_fs.h |    1 +
 2 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e808db561201..edf0458acd4a 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2011,7 +2011,7 @@ static atomic_long_t nfs_access_nr_entries;
 static void nfs_access_free_entry(struct nfs_access_entry *entry)
 {
 	put_rpccred(entry->cred);
-	kfree(entry);
+	kfree_rcu(entry, rcu_head);
 	smp_mb__before_atomic_dec();
 	atomic_long_dec(&nfs_access_nr_entries);
 	smp_mb__after_atomic_dec();
@@ -2166,6 +2166,36 @@ out_zap:
 	return -ENOENT;
 }
 
+static int nfs_access_get_cached_rcu(struct inode *inode, struct rpc_cred *cred, struct nfs_access_entry *res)
+{
+	/* Only check the most recently returned cache entry,
+	 * but do it without locking.
+	 */
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs_access_entry *cache;
+	int err = -ECHILD;
+	struct list_head *lh;
+
+	if (nfsi->cache_validity & NFS_INO_INVALID_ACCESS)
+		goto out;
+	lh = rcu_dereference(nfsi->access_cache_entry_lru.prev);
+	cache = list_entry(lh, struct nfs_access_entry, lru);
+	if (lh == &nfsi->access_cache_entry_lru ||
+	    cred != cache->cred)
+		cache = NULL;
+	if (cache == NULL)
+		goto out;
+	if (!nfs_have_delegated_attributes(inode) &&
+	    !time_in_range_open(jiffies, cache->jiffies, cache->jiffies + nfsi->attrtimeo))
+		goto out;
+	res->jiffies = cache->jiffies;
+	res->cred = cache->cred;
+	res->mask = cache->mask;
+	err = 0;
+out:
+	return err;
+}
+
 static void nfs_access_add_rbtree(struct inode *inode, struct nfs_access_entry *set)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
@@ -2209,6 +2239,11 @@ void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *set)
 	cache->cred = get_rpccred(set->cred);
 	cache->mask = set->mask;
 
+	/* The above fields assignments must be visible
+	 * before this item appears on the lru.  We cannot easily
+	 * use rcu_assign_pointer, so just force the memory barrier.
+	 */
+	smp_wmb();
 	nfs_access_add_rbtree(inode, cache);
 
 	/* Update accounting */
@@ -2247,7 +2282,9 @@ static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
 
 	trace_nfs_access_enter(inode);
 
-	status = nfs_access_get_cached(inode, cred, &cache);
+	if (!(mask & MAY_NOT_BLOCK) ||
+	    (status = nfs_access_get_cached_rcu(inode, cred, &cache)) != 0)
+		status = nfs_access_get_cached(inode, cred, &cache);
 	if (status == 0)
 		goto out_cached;
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 9e91f2cfcd01..0eaf6c48c826 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -52,6 +52,7 @@ struct nfs_access_entry {
 	unsigned long		jiffies;
 	struct rpc_cred *	cred;
 	int			mask;
+	struct rcu_head		rcu_head;
 };
 
 struct nfs_lockowner {


