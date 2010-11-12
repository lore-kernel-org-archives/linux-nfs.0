Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65354 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755416Ab0KLItY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Nov 2010 03:49:24 -0500
Received: from localhost.localdomain (hess01-lxp.hq.netapp.com [10.58.60.52] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAC8n7fE025967
	for <linux-nfs@vger.kernel.org>; Fri, 12 Nov 2010 00:49:10 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/22] pnfs-submit: argument to should_free_lseg changed from lseg to range
Date: Fri, 12 Nov 2010 03:48:26 -0500
Message-Id: <1289551724-18575-5-git-send-email-iisaman@netapp.com>
In-Reply-To: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We only use lseg->range, and we will need the function for
the callback code, where we have only the range, and
not an enclosing lseg.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 149f95e..ec291d3 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -316,11 +316,11 @@ EXPORT_SYMBOL_GPL(put_lseg);
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
 
 static bool
@@ -340,7 +340,7 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
 
 	assert_spin_locked(&lo->inode->i_lock);
 	list_for_each_entry_safe(lseg, next, &lo->segs, fi_list) {
-		if (!should_free_lseg(lseg, range) ||
+		if (!should_free_lseg(&lseg->range, range) ||
 		    !_pnfs_can_return_lseg(lseg))
 			continue;
 		dprintk("%s: freeing lseg %p iomode %d "
@@ -546,7 +546,7 @@ has_layout_to_return(struct pnfs_layout_hdr *lo,
 
 	assert_spin_locked(&lo->inode->i_lock);
 	list_for_each_entry(lseg, &lo->segs, fi_list)
-		if (should_free_lseg(lseg, range)) {
+		if (should_free_lseg(&lseg->range, range)) {
 			out = lseg;
 			break;
 		}
@@ -564,7 +564,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	list_for_each_entry(lseg, &nfsi->layout->segs, fi_list) {
-		if (!should_free_lseg(lseg, range))
+		if (!should_free_lseg(&lseg->range, range))
 			continue;
 		lseg->valid = false;
 		if (!_pnfs_can_return_lseg(lseg)) {
-- 
1.7.2.1

