Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51867 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751623Ab2CQQrN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 Mar 2012 12:47:13 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH] NFS: Use cond_resched_lock() to reduce latencies in the commit scans
Date: Sat, 17 Mar 2012 12:47:05 -0400
Message-Id: <1332002825-8557-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we conditionally drop the inode->i_lock when it is safe
to do so in the commit loops.
We do so after locking the nfs_page, but before removing it from the
commit list. We can then use list_safe_reset_next to recover the loop
after the lock is retaken.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    8 ++++++--
 fs/nfs/write.c          |    8 ++++++--
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e0bdbf4..7a162ad 100644
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
@@ -972,7 +975,8 @@ static int filelayout_scan_commit_lists(struct inode *inode, int max)
 	if (fl->commit_through_mds)
 		goto out_done;
 	for (i = 0; i < fl->number_of_buckets && max != 0; i++) {
-		cnt = filelayout_scan_ds_commit_list(&fl->commit_buckets[i], max);
+		cnt = filelayout_scan_ds_commit_list(&fl->commit_buckets[i],
+				max, &inode->i_lock);
 		max -= cnt;
 		rv += cnt;
 	}
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0de19f4..83e0027 100644
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
@@ -597,7 +600,8 @@ nfs_scan_commit(struct inode *inode, struct list_head *dst)
 		const int max = INT_MAX;
 		int pnfs_ret;
 
-		ret = nfs_scan_commit_list(&nfsi->commit_list, dst, max);
+		ret = nfs_scan_commit_list(&nfsi->commit_list, dst, max,
+				&inode->i_lock);
 		pnfs_ret = pnfs_scan_commit_lists(inode, max - ret);
 		ret += pnfs_ret;
 		nfsi->ncommit -= ret;
-- 
1.7.7.6

