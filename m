Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9169 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751028AbdCNHHm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 03:07:42 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
Subject: [PATCH 05/12] fs, nfs: convert pnfs_layout_segment.pls_refcount from atomic_t to refcount_t
Date: Tue, 14 Mar 2017 09:07:13 +0200
Message-Id: <1489475240-6594-6-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
References: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 fs/nfs/pnfs.c | 16 ++++++++--------
 fs/nfs/pnfs.h |  4 ++--
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index dd04249..155781c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -444,7 +444,7 @@ pnfs_init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg,
 {
 	INIT_LIST_HEAD(&lseg->pls_list);
 	INIT_LIST_HEAD(&lseg->pls_lc_list);
-	atomic_set(&lseg->pls_refcount, 1);
+	refcount_set(&lseg->pls_refcount, 1);
 	set_bit(NFS_LSEG_VALID, &lseg->pls_flags);
 	lseg->pls_layout = lo;
 	lseg->pls_range = *range;
@@ -501,13 +501,13 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 		return;
 
 	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
-		atomic_read(&lseg->pls_refcount),
+		refcount_read(&lseg->pls_refcount),
 		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 
 	lo = lseg->pls_layout;
 	inode = lo->plh_inode;
 
-	if (atomic_dec_and_lock(&lseg->pls_refcount, &inode->i_lock)) {
+	if (refcount_dec_and_lock(&lseg->pls_refcount, &inode->i_lock)) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags)) {
 			spin_unlock(&inode->i_lock);
 			return;
@@ -550,9 +550,9 @@ pnfs_put_lseg_locked(struct pnfs_layout_segment *lseg)
 	assert_spin_locked(&lseg->pls_layout->plh_inode->i_lock);
 
 	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
-		atomic_read(&lseg->pls_refcount),
+		refcount_read(&lseg->pls_refcount),
 		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
-	if (atomic_dec_and_test(&lseg->pls_refcount)) {
+	if (refcount_dec_and_test(&lseg->pls_refcount)) {
 		struct pnfs_layout_hdr *lo = lseg->pls_layout;
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags))
 			return;
@@ -587,7 +587,7 @@ pnfs_lseg_range_contained(const struct pnfs_layout_range *l1,
 static bool pnfs_lseg_dec_and_remove_zero(struct pnfs_layout_segment *lseg,
 		struct list_head *tmp_list)
 {
-	if (!atomic_dec_and_test(&lseg->pls_refcount))
+	if (!refcount_dec_and_test(&lseg->pls_refcount))
 		return false;
 	pnfs_layout_remove_lseg(lseg->pls_layout, lseg);
 	list_add(&lseg->pls_list, tmp_list);
@@ -606,7 +606,7 @@ static int mark_lseg_invalid(struct pnfs_layout_segment *lseg,
 		 * outstanding io is finished.
 		 */
 		dprintk("%s: lseg %p ref %d\n", __func__, lseg,
-			atomic_read(&lseg->pls_refcount));
+			refcount_read(&lseg->pls_refcount));
 		if (pnfs_lseg_dec_and_remove_zero(lseg, tmp_list))
 			rv = 1;
 	}
@@ -1582,7 +1582,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 	}
 
 	dprintk("%s:Return lseg %p ref %d\n",
-		__func__, ret, ret ? atomic_read(&ret->pls_refcount) : 0);
+		__func__, ret, ret ? refcount_read(&ret->pls_refcount) : 0);
 	return ret;
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 0411bb0..75698fa 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -64,7 +64,7 @@ struct pnfs_layout_segment {
 	struct list_head pls_list;
 	struct list_head pls_lc_list;
 	struct pnfs_layout_range pls_range;
-	atomic_t pls_refcount;
+	refcount_t pls_refcount;
 	u32 pls_seq;
 	unsigned long pls_flags;
 	struct pnfs_layout_hdr *pls_layout;
@@ -400,7 +400,7 @@ static inline struct pnfs_layout_segment *
 pnfs_get_lseg(struct pnfs_layout_segment *lseg)
 {
 	if (lseg) {
-		atomic_inc(&lseg->pls_refcount);
+		refcount_inc(&lseg->pls_refcount);
 		smp_mb__after_atomic();
 	}
 	return lseg;
-- 
2.7.4

