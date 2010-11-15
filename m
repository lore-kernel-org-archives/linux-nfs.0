Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42482 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757990Ab0KOTBC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Nov 2010 14:01:02 -0500
Received: from localhost.localdomain (vpn2ntap-136191.hq.netapp.com [10.58.56.111])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAFJ0f4f028248
	for <linux-nfs@vger.kernel.org>; Mon, 15 Nov 2010 11:00:43 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] pnfs-submit: move get_lseg into pnfs_has_layout, and rename
Date: Mon, 15 Nov 2010 14:00:38 -0500
Message-Id: <1289847638-12175-4-git-send-email-iisaman@netapp.com>
In-Reply-To: <1289847638-12175-1-git-send-email-iisaman@netapp.com>
References: <1289847638-12175-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

rename pnfs_has_layout to pnfs_find_lseg, and move get_lseg into
the function, only returning valid lsegs.  Additionally, make the
function static, as it now has only a single caller.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   26 +++++++-------------------
 fs/nfs/pnfs.h |    2 --
 2 files changed, 7 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d06bf16..a21debe 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -860,8 +860,8 @@ is_matching_lseg(struct pnfs_layout_segment *lseg,
 /*
  * lookup range in layout
  */
-struct pnfs_layout_segment *
-pnfs_has_layout(struct pnfs_layout_hdr *lo,
+static struct pnfs_layout_segment *
+pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 		struct pnfs_layout_range *range)
 {
 	struct pnfs_layout_segment *lseg, *ret = NULL;
@@ -870,7 +870,8 @@ pnfs_has_layout(struct pnfs_layout_hdr *lo,
 
 	assert_spin_locked(&lo->inode->i_lock);
 	list_for_each_entry(lseg, &lo->segs, fi_list) {
-		if (is_matching_lseg(lseg, range)) {
+		if (lseg->valid && is_matching_lseg(lseg, range)) {
+			get_lseg(lseg);
 			ret = lseg;
 			break;
 		}
@@ -913,22 +914,9 @@ pnfs_update_layout(struct inode *ino,
 	}
 
 	/* Check to see if the layout for the given range already exists */
-	lseg = pnfs_has_layout(lo, &arg);
-	if (lseg) {
-		if (lseg->valid) {
-			dprintk("%s: Using cached lseg %p for %llu@%llu "
-				"iomode %d)\n",
-				__func__,
-				lseg,
-				arg.length,
-				arg.offset,
-				arg.iomode);
-			get_lseg(lseg);
-			goto out_unlock;
-		}
-		/* someone is cleaning the layout */
-		lseg = NULL;
-	}
+	lseg = pnfs_find_lseg(lo, &arg);
+	if (lseg)
+		goto out_unlock;
 
 	/* if LAYOUTGET already failed once we don't try again */
 	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->plh_flags))
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 3314f64..12fe7ab 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -199,8 +199,6 @@ void put_lseg(struct pnfs_layout_segment *lseg);
 bool should_free_lseg(struct pnfs_layout_range *lseg_range,
 		      struct pnfs_layout_range *recall_range);
 struct pnfs_layout_segment *
-pnfs_has_layout(struct pnfs_layout_hdr *lo, struct pnfs_layout_range *range);
-struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
 bool pnfs_return_layout_barrier(struct nfs_inode *, struct pnfs_layout_range *);
-- 
1.7.2.1

