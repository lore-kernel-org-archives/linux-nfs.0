Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:24139 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755165Ab1EPN74 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 09:59:56 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/4] SQUASHME: pnfs: clean up pnfs_find_lseg lseg arg
Date: Mon, 16 May 2011 06:59:44 -0700
Message-Id: <1305554384-29198-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DCC715C.1090101@panasas.com>
References: <4DCC715C.1090101@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9d41cab..9b67b1c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -790,20 +790,20 @@ pnfs_find_alloc_layout(struct inode *ino)
  * READ		RW	true
  */
 static int
-is_matching_lseg(struct pnfs_layout_segment *lseg,
+is_matching_lseg(struct pnfs_layout_range *ls_range,
 		 struct pnfs_layout_range *range)
 {
 	struct pnfs_layout_range range1;
 
 	if ((range->iomode == IOMODE_RW &&
-	     lseg->pls_range.iomode != IOMODE_RW) ||
-	    !lo_seg_intersecting(&lseg->pls_range, range))
+	     ls_range->iomode != IOMODE_RW) ||
+	    !lo_seg_intersecting(ls_range, range))
 		return 0;
 
 	/* range1 covers only the first byte in the range */
 	range1 = *range;
 	range1.length = 1;
-	return lo_seg_contained(&lseg->pls_range, &range1);
+	return lo_seg_contained(ls_range, &range1);
 }
 
 /*
@@ -820,7 +820,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 	assert_spin_locked(&lo->plh_inode->i_lock);
 	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
-		    is_matching_lseg(lseg, range)) {
+		    is_matching_lseg(&lseg->pls_range, range)) {
 			ret = get_lseg(lseg);
 			break;
 		}
-- 
1.7.3.4

