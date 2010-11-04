Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33432 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752478Ab0KDPWy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Nov 2010 11:22:54 -0400
Received: from localhost.localdomain (dnsindia.hq.netapp.com [10.58.52.94] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oA4FMYMW029583
	for <linux-nfs@vger.kernel.org>; Thu, 4 Nov 2010 08:22:44 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/18] pnfs-submit: argument to should_free_lseg changed from lseg to range
Date: Thu,  4 Nov 2010 11:22:23 -0400
Message-Id: <1288884151-11128-11-git-send-email-iisaman@netapp.com>
In-Reply-To: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
References: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We only use lseg->range, and we will need the function for
the callback code, where we have only the range, and
not an enclosing lseg.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d9a867f..ca8be8d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -346,11 +346,11 @@ EXPORT_SYMBOL_GPL(put_lseg);
  * READ		RW	false
  */
 static int
-should_free_lseg(struct pnfs_layout_segment *lseg,
-		   struct pnfs_layout_range *range)
+should_free_lseg(struct pnfs_layout_range *lseg_range,
+		 struct pnfs_layout_range *recall_range)
 {
-	return (range->iomode == IOMODE_ANY ||
-		lseg->range.iomode == range->iomode);
+	return (recall_range->iomode == IOMODE_ANY ||
+		lseg_range->iomode == recall_range->iomode);
 }
 
 static void mark_lseg_invalid(struct pnfs_layout_segment *lseg,
@@ -378,7 +378,7 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
 
 	assert_spin_locked(&lo->inode->i_lock);
 	list_for_each_entry_safe(lseg, next, &lo->segs, fi_list)
-		if (should_free_lseg(lseg, range)) {
+		if (should_free_lseg(&lseg->range, range)) {
 			dprintk("%s: freeing lseg %p iomode %d "
 				"offset %llu length %llu\n", __func__,
 				lseg, lseg->range.iomode, lseg->range.offset,
@@ -564,7 +564,7 @@ has_layout_to_return(struct pnfs_layout_hdr *lo,
 
 	assert_spin_locked(&lo->inode->i_lock);
 	list_for_each_entry(lseg, &lo->segs, fi_list)
-		if (should_free_lseg(lseg, range)) {
+		if (should_free_lseg(&lseg->range, range)) {
 			out = lseg;
 			break;
 		}
@@ -586,7 +586,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	list_for_each_entry_safe(lseg, tmp, &nfsi->layout->segs, fi_list)
-		if (should_free_lseg(lseg, range)) {
+		if (should_free_lseg(&lseg->range, range)) {
 			ret = true;
 			break;
 		}
@@ -662,7 +662,7 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 		}
 
 		list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
-			if (should_free_lseg(lseg, &arg))
+			if (should_free_lseg(&lseg->range, &arg))
 				mark_lseg_invalid(lseg, &tmp_list);
 		/* Reference matched in nfs4_layoutreturn_release */
 		get_layout_hdr(lo);
-- 
1.7.2.1

