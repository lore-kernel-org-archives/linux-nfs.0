Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63543 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751298Ab0EMVI2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 17:08:28 -0400
Received: from localhost.localdomain (heimdal.trondhjem.org [10.58.49.73] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4DL8MCT021257
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 14:08:28 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/15] NFS: Clean up nfs_access_zap_cache()
Date: Thu, 13 May 2010 17:08:16 -0400
Message-Id: <1273784901-25599-10-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1273784901-25599-9-git-send-email-Trond.Myklebust@netapp.com>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-4-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-5-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-6-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-7-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-8-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-9-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |   60 +++++++++++++++++++++++++++++----------------------------
 1 files changed, 31 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index bc136ef..5582e9d 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1697,6 +1697,17 @@ static void nfs_access_free_entry(struct nfs_access_entry *entry)
 	smp_mb__after_atomic_dec();
 }
 
+static void nfs_access_free_list(struct list_head *head)
+{
+	struct nfs_access_entry *cache;
+
+	while (!list_empty(head)) {
+		cache = list_entry(head->next, struct nfs_access_entry, lru);
+		list_del(&cache->lru);
+		nfs_access_free_entry(cache);
+	}
+}
+
 int nfs_access_cache_shrinker(int nr_to_scan, gfp_t gfp_mask)
 {
 	LIST_HEAD(head);
@@ -1743,52 +1754,41 @@ remove_lru_entry:
 		goto restart;
 	}
 	spin_unlock(&nfs_access_lru_lock);
-	while (!list_empty(&head)) {
-		cache = list_entry(head.next, struct nfs_access_entry, lru);
-		list_del(&cache->lru);
-		nfs_access_free_entry(cache);
-	}
+	nfs_access_free_list(&head);
 	return (atomic_long_read(&nfs_access_nr_entries) / 100) * sysctl_vfs_cache_pressure;
 }
 
-static void __nfs_access_zap_cache(struct inode *inode)
+static void __nfs_access_zap_cache(struct nfs_inode *nfsi, struct list_head *head)
 {
-	struct nfs_inode *nfsi = NFS_I(inode);
 	struct rb_root *root_node = &nfsi->access_cache;
-	struct rb_node *n, *dispose = NULL;
+	struct rb_node *n;
 	struct nfs_access_entry *entry;
 
 	/* Unhook entries from the cache */
 	while ((n = rb_first(root_node)) != NULL) {
 		entry = rb_entry(n, struct nfs_access_entry, rb_node);
 		rb_erase(n, root_node);
-		list_del(&entry->lru);
-		n->rb_left = dispose;
-		dispose = n;
+		list_move(&entry->lru, head);
 	}
 	nfsi->cache_validity &= ~NFS_INO_INVALID_ACCESS;
-	spin_unlock(&inode->i_lock);
-
-	/* Now kill them all! */
-	while (dispose != NULL) {
-		n = dispose;
-		dispose = n->rb_left;
-		nfs_access_free_entry(rb_entry(n, struct nfs_access_entry, rb_node));
-	}
 }
 
 void nfs_access_zap_cache(struct inode *inode)
 {
+	LIST_HEAD(head);
+
+	if (test_bit(NFS_INO_ACL_LRU_SET, &NFS_I(inode)->flags) == 0)
+		return;
 	/* Remove from global LRU init */
-	if (test_and_clear_bit(NFS_INO_ACL_LRU_SET, &NFS_I(inode)->flags)) {
-		spin_lock(&nfs_access_lru_lock);
+	spin_lock(&nfs_access_lru_lock);
+	if (test_and_clear_bit(NFS_INO_ACL_LRU_SET, &NFS_I(inode)->flags))
 		list_del_init(&NFS_I(inode)->access_cache_inode_lru);
-		spin_unlock(&nfs_access_lru_lock);
-	}
 
 	spin_lock(&inode->i_lock);
-	/* This will release the spinlock */
-	__nfs_access_zap_cache(inode);
+	__nfs_access_zap_cache(NFS_I(inode), &head);
+	spin_unlock(&inode->i_lock);
+	spin_unlock(&nfs_access_lru_lock);
+	nfs_access_free_list(&head);
 }
 
 static struct nfs_access_entry *nfs_access_search_rbtree(struct inode *inode, struct rpc_cred *cred)
@@ -1839,8 +1839,8 @@ out_stale:
 	nfs_access_free_entry(cache);
 	return -ENOENT;
 out_zap:
-	/* This will release the spinlock */
-	__nfs_access_zap_cache(inode);
+	spin_unlock(&inode->i_lock);
+	nfs_access_zap_cache(inode);
 	return -ENOENT;
 }
 
@@ -1895,9 +1895,11 @@ static void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *s
 	smp_mb__after_atomic_inc();
 
 	/* Add inode to global LRU list */
-	if (!test_and_set_bit(NFS_INO_ACL_LRU_SET, &NFS_I(inode)->flags)) {
+	if (!test_bit(NFS_INO_ACL_LRU_SET, &NFS_I(inode)->flags)) {
 		spin_lock(&nfs_access_lru_lock);
-		list_add_tail(&NFS_I(inode)->access_cache_inode_lru, &nfs_access_lru_list);
+		if (!test_and_set_bit(NFS_INO_ACL_LRU_SET, &NFS_I(inode)->flags))
+			list_add_tail(&NFS_I(inode)->access_cache_inode_lru,
+					&nfs_access_lru_list);
 		spin_unlock(&nfs_access_lru_lock);
 	}
 }
-- 
1.6.6.1

