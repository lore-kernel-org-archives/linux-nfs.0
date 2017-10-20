Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10955 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752780AbdJTJzz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Oct 2017 05:55:55 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@poochiereds.net, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 06/11] fs, nfs: convert pnfs_layout_hdr.plh_refcount from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 12:53:33 +0300
Message-Id: <1508493218-27760-7-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1508493218-27760-1-git-send-email-elena.reshetova@intel.com>
References: <1508493218-27760-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable pnfs_layout_hdr.plh_refcount is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 fs/nfs/pnfs.c | 12 ++++++------
 fs/nfs/pnfs.h |  2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 499bb71..4aab53b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -251,7 +251,7 @@ EXPORT_SYMBOL_GPL(pnfs_unregister_layoutdriver);
 void
 pnfs_get_layout_hdr(struct pnfs_layout_hdr *lo)
 {
-	atomic_inc(&lo->plh_refcount);
+	refcount_inc(&lo->plh_refcount);
 }
 
 static struct pnfs_layout_hdr *
@@ -296,7 +296,7 @@ pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo)
 
 	pnfs_layoutreturn_before_put_layout_hdr(lo);
 
-	if (atomic_dec_and_lock(&lo->plh_refcount, &inode->i_lock)) {
+	if (refcount_dec_and_lock(&lo->plh_refcount, &inode->i_lock)) {
 		if (!list_empty(&lo->plh_segs))
 			WARN_ONCE(1, "NFS: BUG unfreed layout segments.\n");
 		pnfs_detach_layout_hdr(lo);
@@ -395,14 +395,14 @@ pnfs_layout_set_fail_bit(struct pnfs_layout_hdr *lo, int fail_bit)
 {
 	lo->plh_retry_timestamp = jiffies;
 	if (!test_and_set_bit(fail_bit, &lo->plh_flags))
-		atomic_inc(&lo->plh_refcount);
+		refcount_inc(&lo->plh_refcount);
 }
 
 static void
 pnfs_layout_clear_fail_bit(struct pnfs_layout_hdr *lo, int fail_bit)
 {
 	if (test_and_clear_bit(fail_bit, &lo->plh_flags))
-		atomic_dec(&lo->plh_refcount);
+		refcount_dec(&lo->plh_refcount);
 }
 
 static void
@@ -472,7 +472,7 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 	WARN_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	list_del_init(&lseg->pls_list);
 	/* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
-	atomic_dec(&lo->plh_refcount);
+	refcount_dec(&lo->plh_refcount);
 	if (test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
 		return;
 	if (list_empty(&lo->plh_segs) &&
@@ -1451,7 +1451,7 @@ alloc_init_layout_hdr(struct inode *ino,
 	lo = pnfs_alloc_layout_hdr(ino, gfp_flags);
 	if (!lo)
 		return NULL;
-	atomic_set(&lo->plh_refcount, 1);
+	refcount_set(&lo->plh_refcount, 1);
 	INIT_LIST_HEAD(&lo->plh_layouts);
 	INIT_LIST_HEAD(&lo->plh_segs);
 	INIT_LIST_HEAD(&lo->plh_return_segs);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f0e98e1..78de7a2 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -180,7 +180,7 @@ struct pnfs_layoutdriver_type {
 };
 
 struct pnfs_layout_hdr {
-	atomic_t		plh_refcount;
+	refcount_t		plh_refcount;
 	atomic_t		plh_outstanding; /* number of RPCs out */
 	struct list_head	plh_layouts;   /* other client layouts */
 	struct list_head	plh_bulk_destroy;
-- 
2.7.4

