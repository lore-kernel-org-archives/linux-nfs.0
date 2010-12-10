Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25679 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751857Ab0LJGIy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:54 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLt023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:53 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 18/22] pnfs-submit: wave2: change lseg->valid from bool to a bit flag
Date: Thu,  9 Dec 2010 20:22:53 -0500
Message-Id: <1291944177-7819-19-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This makes way for adding roc bit to lseg

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   18 ++++++++++--------
 fs/nfs/pnfs.h |    6 +++++-
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 27a1973..69f5e7b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -276,7 +276,7 @@ init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 	INIT_LIST_HEAD(&lseg->fi_list);
 	atomic_set(&lseg->pls_refcount, 1);
 	smp_mb();
-	lseg->valid = true;
+	set_bit(NFS_LSEG_VALID, &lseg->pls_flags);
 	lseg->layout = lo;
 	lseg->pls_notify_count = 0;
 }
@@ -286,7 +286,7 @@ _put_lseg_common(struct pnfs_layout_segment *lseg)
 {
 	struct inode *ino = lseg->layout->inode;
 
-	BUG_ON(lseg->valid == true);
+	BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	list_del(&lseg->fi_list);
 	if (list_empty(&lseg->layout->segs)) {
 		struct nfs_client *clp;
@@ -309,7 +309,8 @@ put_lseg_locked(struct pnfs_layout_segment *lseg,
 		struct list_head *tmp_list)
 {
 	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
-		atomic_read(&lseg->pls_refcount), lseg->valid);
+		atomic_read(&lseg->pls_refcount),
+		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	if (atomic_dec_and_test(&lseg->pls_refcount)) {
 		_put_lseg_common(lseg);
 		list_add(&lseg->fi_list, tmp_list);
@@ -325,7 +326,8 @@ put_lseg(struct pnfs_layout_segment *lseg)
 		return;
 
 	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
-		atomic_read(&lseg->pls_refcount), lseg->valid);
+		atomic_read(&lseg->pls_refcount),
+		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	ino = lseg->layout->inode;
 	if (atomic_dec_and_lock(&lseg->pls_refcount, &ino->i_lock)) {
 		int count = lseg->pls_notify_count;
@@ -363,8 +365,7 @@ static void mark_lseg_invalid(struct pnfs_layout_segment *lseg,
 			      struct list_head *tmp_list)
 {
 	assert_spin_locked(&lseg->layout->inode->i_lock);
-	if (lseg->valid) {
-		lseg->valid = false;
+	if (test_and_clear_bit(NFS_LSEG_VALID, &lseg->pls_flags)) {
 		/* Remove the reference keeping the lseg in the
 		 * list.  It will now be removed when all
 		 * outstanding io is finished.
@@ -809,7 +810,8 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 
 	assert_spin_locked(&lo->inode->i_lock);
 	list_for_each_entry(lseg, &lo->segs, fi_list) {
-		if (lseg->valid && is_matching_lseg(lseg, range)) {
+		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
+		    is_matching_lseg(lseg, range)) {
 			get_lseg(lseg);
 			ret = lseg;
 			break;
@@ -820,7 +822,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 
 	dprintk("%s:Return lseg %p ref %d valid %d\n",
 		__func__, ret, ret ? atomic_read(&ret->pls_refcount) : 0,
-		ret ? ret->valid : 0);
+		ret ? test_bit(NFS_LSEG_VALID, &ret->pls_flags) : 0);
 	return ret;
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b5a30b8..82b9a7e 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -33,11 +33,15 @@
 #include <linux/nfs_page.h>
 #include "callback.h" /* for cb_layoutrecallargs */
 
+enum {
+	NFS_LSEG_VALID = 0,	/* cleared when lseg is recalled/returned */
+};
+
 struct pnfs_layout_segment {
 	struct list_head fi_list;
 	struct pnfs_layout_range range;
 	atomic_t pls_refcount;
-	bool valid;
+	unsigned long pls_flags;
 	struct pnfs_layout_hdr *layout;
 	int pls_notify_count;
 };
-- 
1.7.2.1

