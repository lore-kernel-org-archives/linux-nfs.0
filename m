Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:35275 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199AbcBVWva (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Feb 2016 17:51:30 -0500
Received: by mail-io0-f177.google.com with SMTP id g203so194311394iof.2
        for <linux-nfs@vger.kernel.org>; Mon, 22 Feb 2016 14:51:30 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4.x/pnfs: Fix a race between layoutget and bulk recalls
Date: Mon, 22 Feb 2016 17:50:46 -0500
Message-Id: <1456181446-14006-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1456181446-14006-1-git-send-email-trond.myklebust@primarydata.com>
References: <1456181446-14006-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace another case where the layout 'plh_block_lgets' can trigger
infinite loops in send_layoutget().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8a41538f1155..2fa483e6dbe2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -259,7 +259,7 @@ pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo)
  * is required.
  * Note that caller must hold inode->i_lock.
  */
-static void
+static int
 pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 		struct list_head *lseg_list)
 {
@@ -270,7 +270,7 @@ pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 	};
 
 	set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
-	pnfs_mark_matching_lsegs_invalid(lo, lseg_list, &range);
+	return pnfs_mark_matching_lsegs_invalid(lo, lseg_list, &range);
 }
 
 static int
@@ -637,11 +637,6 @@ pnfs_layout_free_bulk_destroy_list(struct list_head *layout_list,
 {
 	struct pnfs_layout_hdr *lo;
 	struct inode *inode;
-	struct pnfs_layout_range range = {
-		.iomode = IOMODE_ANY,
-		.offset = 0,
-		.length = NFS4_MAX_UINT64,
-	};
 	LIST_HEAD(lseg_list);
 	int ret = 0;
 
@@ -656,11 +651,11 @@ pnfs_layout_free_bulk_destroy_list(struct list_head *layout_list,
 
 		spin_lock(&inode->i_lock);
 		list_del_init(&lo->plh_bulk_destroy);
-		lo->plh_block_lgets++; /* permanently block new LAYOUTGETs */
-		if (is_bulk_recall)
-			set_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
-		if (pnfs_mark_matching_lsegs_invalid(lo, &lseg_list, &range))
+		if (pnfs_mark_layout_stateid_invalid(lo, &lseg_list)) {
+			if (is_bulk_recall)
+				set_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
 			ret = -EAGAIN;
+		}
 		spin_unlock(&inode->i_lock);
 		pnfs_free_lseg_list(&lseg_list);
 		/* Free all lsegs that are attached to commit buckets */
-- 
2.5.0

