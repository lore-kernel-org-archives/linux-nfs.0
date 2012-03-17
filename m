Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21986 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752773Ab2CQQ6o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 Mar 2012 12:58:44 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH v2] NFS: Use cond_resched_lock() to reduce latencies in the commit scans
Date: Sat, 17 Mar 2012 12:58:38 -0400
Message-Id: <1332003518-9785-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we conditionally drop the inode->i_lock when it is safe
to do so in the commit loops.
We do so after locking the nfs_page, but before removing it from the
commit list. We can then use list_safe_reset_next to recover the loop
after the lock is retaken.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
v2: Make pnfs_scan_commit_list() take the lock argument too.

 fs/nfs/nfs4filelayout.c |   11 ++++++++---
 fs/nfs/pnfs.h           |    8 ++++----
 fs/nfs/write.c          |   11 ++++++++---
 3 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e0bdbf4..634c0bc 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -936,7 +936,8 @@ static struct pnfs_layout_segment *find_only_write_lseg(struct inode *inode)
 }
 
 static int
-filelayout_scan_ds_commit_list(struct nfs4_fl_commit_bucket *bucket, int max)
+filelayout_scan_ds_commit_list(struct nfs4_fl_commit_bucket *bucket, int max,
+		spinlock_t *lock)
 {
 	struct list_head *src = &bucket->written;
 	struct list_head *dst = &bucket->committing;
@@ -946,6 +947,8 @@ filelayout_scan_ds_commit_list(struct nfs4_fl_commit_bucket *bucket, int max)
 	list_for_each_entry_safe(req, tmp, src, wb_list) {
 		if (!nfs_lock_request(req))
 			continue;
+		if (cond_resched_lock(lock))
+			list_safe_reset_next(req, tmp, wb_list);
 		nfs_request_remove_commit_list(req);
 		clear_bit(PG_COMMIT_TO_DS, &req->wb_flags);
 		nfs_list_add_request(req, dst);
@@ -959,7 +962,8 @@ filelayout_scan_ds_commit_list(struct nfs4_fl_commit_bucket *bucket, int max)
 /* Move reqs from written to committing lists, returning count of number moved.
  * Note called with i_lock held.
  */
-static int filelayout_scan_commit_lists(struct inode *inode, int max)
+static int filelayout_scan_commit_lists(struct inode *inode, int max,
+		spinlock_t *lock)
 {
 	struct pnfs_layout_segment *lseg;
 	struct nfs4_filelayout_segment *fl;
@@ -972,7 +976,8 @@ static int filelayout_scan_commit_lists(struct inode *inode, int max)
 	if (fl->commit_through_mds)
 		goto out_done;
 	for (i = 0; i < fl->number_of_buckets && max != 0; i++) {
-		cnt = filelayout_scan_ds_commit_list(&fl->commit_buckets[i], max);
+		cnt = filelayout_scan_ds_commit_list(&fl->commit_buckets[i],
+				max, lock);
 		max -= cnt;
 		rv += cnt;
 	}
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index e98ff30..0780265 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -97,7 +97,7 @@ struct pnfs_layoutdriver_type {
 	void (*mark_request_commit) (struct nfs_page *req,
 					struct pnfs_layout_segment *lseg);
 	void (*clear_request_commit) (struct nfs_page *req);
-	int (*scan_commit_lists) (struct inode *inode, int max);
+	int (*scan_commit_lists) (struct inode *inode, int max, spinlock_t *lock);
 	int (*commit_pagelist)(struct inode *inode, struct list_head *mds_pages, int how);
 
 	/*
@@ -294,14 +294,14 @@ pnfs_clear_request_commit(struct nfs_page *req)
 }
 
 static inline int
-pnfs_scan_commit_lists(struct inode *inode, int max)
+pnfs_scan_commit_lists(struct inode *inode, int max, spinlock_t *lock)
 {
 	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
 	int ret;
 
 	if (ld == NULL || ld->scan_commit_lists == NULL)
 		return 0;
-	ret = ld->scan_commit_lists(inode, max);
+	ret = ld->scan_commit_lists(inode, max, lock);
 	if (ret != 0)
 		set_bit(NFS_INO_PNFS_COMMIT, &NFS_I(inode)->flags);
 	return ret;
@@ -419,7 +419,7 @@ pnfs_clear_request_commit(struct nfs_page *req)
 }
 
 static inline int
-pnfs_scan_commit_lists(struct inode *inode, int max)
+pnfs_scan_commit_lists(struct inode *inode, int max, spinlock_t *lock)
 {
 	return 0;
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0de19f4..52e8e09 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -561,7 +561,8 @@ nfs_need_commit(struct nfs_inode *nfsi)
 
 /* i_lock held by caller */
 static int
-nfs_scan_commit_list(struct list_head *src, struct list_head *dst, int max)
+nfs_scan_commit_list(struct list_head *src, struct list_head *dst, int max,
+		spinlock_t *lock)
 {
 	struct nfs_page *req, *tmp;
 	int ret = 0;
@@ -569,6 +570,8 @@ nfs_scan_commit_list(struct list_head *src, struct list_head *dst, int max)
 	list_for_each_entry_safe(req, tmp, src, wb_list) {
 		if (!nfs_lock_request(req))
 			continue;
+		if (cond_resched_lock(lock))
+			list_safe_reset_next(req, tmp, wb_list);
 		nfs_request_remove_commit_list(req);
 		nfs_list_add_request(req, dst);
 		ret++;
@@ -597,8 +600,10 @@ nfs_scan_commit(struct inode *inode, struct list_head *dst)
 		const int max = INT_MAX;
 		int pnfs_ret;
 
-		ret = nfs_scan_commit_list(&nfsi->commit_list, dst, max);
-		pnfs_ret = pnfs_scan_commit_lists(inode, max - ret);
+		ret = nfs_scan_commit_list(&nfsi->commit_list, dst, max,
+				&inode->i_lock);
+		pnfs_ret = pnfs_scan_commit_lists(inode, max - ret,
+				&inode->i_lock);
 		ret += pnfs_ret;
 		nfsi->ncommit -= ret;
 	}
-- 
1.7.7.6

