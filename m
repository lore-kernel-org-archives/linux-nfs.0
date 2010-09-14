Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:18513 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753602Ab0INKx3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Sep 2010 06:53:29 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] SQUASHME: pnfs-post-submit: remove take_ref and only_valid params from pnfs_has_layout
Date: Tue, 14 Sep 2010 12:53:29 +0200
Message-Id: <1284461609-4551-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4C8F53FA.5060308@panasas.com>
References: <4C8F53FA.5060308@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

They are always evaluated to treu and false, respectively as the lseg ptr is
always needed.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   23 ++++++++---------------
 1 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b576470..bc4f0c1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1001,9 +1001,7 @@ has_matching_lseg(struct pnfs_layout_segment *lseg,
  */
 static struct pnfs_layout_segment *
 pnfs_has_layout(struct pnfs_layout_hdr *lo,
-		struct pnfs_layout_range *range,
-		bool take_ref,
-		bool only_valid)
+		struct pnfs_layout_range *range)
 {
 	struct pnfs_layout_segment *lseg, *ret = NULL;
 
@@ -1011,19 +1009,17 @@ pnfs_has_layout(struct pnfs_layout_hdr *lo,
 
 	BUG_ON_UNLOCKED_LO(lo);
 	list_for_each_entry (lseg, &lo->segs, fi_list) {
-		if (has_matching_lseg(lseg, range) &&
-		    (lseg->valid || !only_valid)) {
+		if (has_matching_lseg(lseg, range)) {
 			ret = lseg;
-			if (take_ref)
-				get_lseg(ret);
+			get_lseg(ret);
 			break;
 		}
 		if (cmp_layout(range, &lseg->range) > 0)
 			break;
 	}
 
-	dprintk("%s:Return lseg %p take_ref %d ref %d valid %d\n",
-		__func__, ret, take_ref,
+	dprintk("%s:Return lseg %p ref %d valid %d\n",
+		__func__, ret,
 		ret ? atomic_read(&ret->kref.refcount) : 0,
 		ret ? ret->valid : 0);
 	return ret;
@@ -1050,10 +1046,8 @@ _pnfs_update_layout(struct inode *ino,
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_segment *lseg = NULL;
-	bool take_ref = (lsegpp != NULL);
 
-	if (take_ref)
-		*lsegpp = NULL;
+	*lsegpp = NULL;
 	spin_lock(&ino->i_lock);
 	lo = pnfs_alloc_layout(ino);
 	if (lo == NULL) {
@@ -1062,10 +1056,9 @@ _pnfs_update_layout(struct inode *ino,
 	}
 
 	/* Check to see if the layout for the given range already exists */
-	lseg = pnfs_has_layout(lo, &arg, take_ref, !take_ref);
+	lseg = pnfs_has_layout(lo, &arg);
 	if (lseg && !lseg->valid) {
-		if (take_ref)
-			put_lseg_locked(lseg);
+		put_lseg_locked(lseg);
 		/* someone is cleaning the layout */
 		lseg = NULL;
 		goto out_unlock;
-- 
1.7.2.2

