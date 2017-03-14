Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9169 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751072AbdCNHHs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 03:07:48 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
Subject: [PATCH 06/12] fs, nfs: convert pnfs_layout_hdr.plh_refcount from atomic_t to refcount_t
Date: Tue, 14 Mar 2017 09:07:14 +0200
Message-Id: <1489475240-6594-7-git-send-email-elena.reshetova@intel.com>
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
 fs/nfs/pnfs.c | 12 ++++++------
 fs/nfs/pnfs.h |  2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 155781c..7d39d96 100644
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
@@ -389,14 +389,14 @@ pnfs_layout_set_fail_bit(struct pnfs_layout_hdr *lo, int fail_bit)
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
@@ -466,7 +466,7 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 	WARN_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	list_del_init(&lseg->pls_list);
 	/* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
-	atomic_dec(&lo->plh_refcount);
+	refcount_dec(&lo->plh_refcount);
 	if (test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
 		return;
 	if (list_empty(&lo->plh_segs) &&
@@ -1487,7 +1487,7 @@ alloc_init_layout_hdr(struct inode *ino,
 	lo = pnfs_alloc_layout_hdr(ino, gfp_flags);
 	if (!lo)
 		return NULL;
-	atomic_set(&lo->plh_refcount, 1);
+	refcount_set(&lo->plh_refcount, 1);
 	INIT_LIST_HEAD(&lo->plh_layouts);
 	INIT_LIST_HEAD(&lo->plh_segs);
 	INIT_LIST_HEAD(&lo->plh_return_segs);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 75698fa..61cafea 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -186,7 +186,7 @@ struct pnfs_layoutdriver_type {
 };
 
 struct pnfs_layout_hdr {
-	atomic_t		plh_refcount;
+	refcount_t		plh_refcount;
 	atomic_t		plh_outstanding; /* number of RPCs out */
 	struct list_head	plh_layouts;   /* other client layouts */
 	struct list_head	plh_bulk_destroy;
-- 
2.7.4

