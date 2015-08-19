Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33380 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605AbbHSFt2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Aug 2015 01:49:28 -0400
Received: by pabyb7 with SMTP id yb7so149603194pab.0
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2015 22:49:28 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH] NFS41: make sure sending LAYOUTRETURN before close if marked so
Date: Wed, 19 Aug 2015 13:49:19 +0800
Message-Id: <1439963359-17186-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If layout is marked by NFS_LAYOUT_RETURN_BEFORE_CLOSE, we should always
send LAYOUTRETURN before close, and we don't need to do ROC drain if we
do send LAYOUTRETURN.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/pnfs.c | 51 ++++++++++++++++++++++++++++-----------------------
 1 file changed, 28 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6aabbb6..e101a49 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1064,7 +1064,7 @@ bool pnfs_roc(struct inode *ino)
 	struct pnfs_layout_segment *lseg, *tmp;
 	nfs4_stateid stateid;
 	LIST_HEAD(tmp_list);
-	bool found = false, layoutreturn = false;
+	bool found = false, layoutreturn = false, roc = false;
 
 	spin_lock(&ino->i_lock);
 	lo = nfsi->layout;
@@ -1072,7 +1072,7 @@ bool pnfs_roc(struct inode *ino)
 	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
 		goto out_noroc;
 
-	/* Don't return layout if we hold a delegation */
+	/* no roc if we hold a delegation */
 	if (nfs4_check_delegation(ino, FMODE_READ))
 		goto out_noroc;
 
@@ -1083,36 +1083,41 @@ bool pnfs_roc(struct inode *ino)
 			goto out_noroc;
 	}
 
+	stateid = lo->plh_stateid;
+	/* always send layoutreturn if being marked so */
+	if (test_and_clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
+				   &lo->plh_flags))
+		layoutreturn = pnfs_prepare_layoutreturn(lo);
+
 	pnfs_clear_retry_layoutget(lo);
 	list_for_each_entry_safe(lseg, tmp, &lo->plh_segs, pls_list)
-		if (test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {
+		/* If we are sending layoutreturn, invalidate all valid lsegs */
+		if (layoutreturn || test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {
 			mark_lseg_invalid(lseg, &tmp_list);
 			found = true;
 		}
-	if (!found)
-		goto out_noroc;
-	if (test_and_set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
-		goto out_noroc;
-	lo->plh_return_iomode = IOMODE_ANY;
-	pnfs_get_layout_hdr(lo); /* matched in pnfs_roc_release */
-	spin_unlock(&ino->i_lock);
-	pnfs_free_lseg_list(&tmp_list);
-	pnfs_layoutcommit_inode(ino, true);
-	return true;
+	/* pnfs_prepare_layoutreturn() grabs lo ref and it will be put
+	 * in pnfs_roc_release(). We don't really send a layoutreturn but
+	 * still want others to view us like we are sending one!
+	 *
+	 * If pnfs_prepare_layoutreturn() fails, it means someone else is doing
+	 * LAYOUTRETURN, so we proceed like there are no layouts to return.
+	 *
+	 * ROC in three conditions:
+	 * 1. there are ROC lsegs
+	 * 2. we don't send layoutreturn
+	 * 3. no others are sending layoutreturn
+	 */
+	if (found && !layoutreturn && pnfs_prepare_layoutreturn(lo))
+		roc = true;
 
 out_noroc:
-	if (lo) {
-		stateid = lo->plh_stateid;
-		if (test_and_clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
-					   &lo->plh_flags))
-			layoutreturn = pnfs_prepare_layoutreturn(lo);
-	}
 	spin_unlock(&ino->i_lock);
-	if (layoutreturn) {
-		pnfs_layoutcommit_inode(ino, true);
+	pnfs_free_lseg_list(&tmp_list);
+	pnfs_layoutcommit_inode(ino, true);
+	if (layoutreturn)
 		pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, true);
-	}
-	return false;
+	return roc;
 }
 
 void pnfs_roc_release(struct inode *ino)
-- 
1.8.3.1

