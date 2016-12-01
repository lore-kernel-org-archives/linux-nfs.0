Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33037 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752472AbcLAWTj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:39 -0500
Received: by mail-io0-f195.google.com with SMTP id j92so3935563ioi.0
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:39 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 14/26] pNFS: Don't mark layout segments invalid on layoutreturn in pnfs_roc
Date: Thu,  1 Dec 2016 17:19:10 -0500
Message-Id: <20161201221922.15657-15-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-14-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
 <20161201221922.15657-5-trond.myklebust@primarydata.com>
 <20161201221922.15657-6-trond.myklebust@primarydata.com>
 <20161201221922.15657-7-trond.myklebust@primarydata.com>
 <20161201221922.15657-8-trond.myklebust@primarydata.com>
 <20161201221922.15657-9-trond.myklebust@primarydata.com>
 <20161201221922.15657-10-trond.myklebust@primarydata.com>
 <20161201221922.15657-11-trond.myklebust@primarydata.com>
 <20161201221922.15657-12-trond.myklebust@primarydata.com>
 <20161201221922.15657-13-trond.myklebust@primarydata.com>
 <20161201221922.15657-14-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The layoutreturn call will take care of invalidating the layout segments
once the call is successful.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 330f3a012f8e..d7b5ad437b14 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1205,22 +1205,28 @@ bool pnfs_roc(struct inode *ino)
 			goto out_noroc;
 	}
 
-	/* always send layoutreturn if being marked so */
-	if (test_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags))
-		layoutreturn = pnfs_prepare_layoutreturn(lo,
-				&stateid, NULL);
 
-	list_for_each_entry_safe(lseg, tmp, &lo->plh_segs, pls_list)
+	list_for_each_entry_safe(lseg, tmp, &lo->plh_segs, pls_list) {
 		/* If we are sending layoutreturn, invalidate all valid lsegs */
-		if (layoutreturn || test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {
+		if (test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {
 			mark_lseg_invalid(lseg, &tmp_list);
 			found = true;
 		}
+	}
+
+	/* always send layoutreturn if being marked so */
+	if (test_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags)) {
+		layoutreturn = pnfs_prepare_layoutreturn(lo,
+				&stateid, NULL);
+		if (layoutreturn)
+			goto out_noroc;
+	}
+
 	/* ROC in two conditions:
 	 * 1. there are ROC lsegs
 	 * 2. we don't send layoutreturn
 	 */
-	if (found && !layoutreturn) {
+	if (found) {
 		/* lo ref dropped in pnfs_roc_release() */
 		pnfs_get_layout_hdr(lo);
 		roc = true;
-- 
2.9.3

