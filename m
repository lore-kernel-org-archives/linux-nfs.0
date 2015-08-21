Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36364 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbbHUEuE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2015 00:50:04 -0400
Received: by pawq9 with SMTP id q9so43708755paw.3
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 21:50:03 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@primarydata.com>,
        stable@vger.kernel.org
Subject: [PATCH] NFS41: remove NFS_LAYOUT_ROC flag
Date: Fri, 21 Aug 2015 12:49:44 +0800
Message-Id: <1440132584-50156-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we return delegation before closing, we fail to do roc check
during close because NFS_LAYOUT_ROC is cleared by delegreturn
and it causes layouts to be still hanging around after delegreturn
+ close, which is a voilation against protocol.

Cc: stable@vger.kernel.org
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/pnfs.c | 7 ++-----
 fs/nfs/pnfs.h | 1 -
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index cf90eed..247c5a5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1068,8 +1068,7 @@ bool pnfs_roc(struct inode *ino)
 
 	spin_lock(&ino->i_lock);
 	lo = nfsi->layout;
-	if (!lo || !test_and_clear_bit(NFS_LAYOUT_ROC, &lo->plh_flags) ||
-	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
+	if (!lo || test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
 		goto out_noroc;
 
 	/* no roc if we hold a delegation */
@@ -1617,10 +1616,8 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	pnfs_get_lseg(lseg);
 	pnfs_layout_insert_lseg(lo, lseg);
 
-	if (res->return_on_close) {
+	if (res->return_on_close)
 		set_bit(NFS_LSEG_ROC, &lseg->pls_flags);
-		set_bit(NFS_LAYOUT_ROC, &lo->plh_flags);
-	}
 
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index a3d57a8..02c27f9 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -94,7 +94,6 @@ enum {
 	NFS_LAYOUT_RO_FAILED = 0,	/* get ro layout failed stop trying */
 	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
 	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
-	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
 	NFS_LAYOUT_RETURN,		/* Return this layout ASAP */
 	NFS_LAYOUT_RETURN_BEFORE_CLOSE,	/* Return this layout before close */
 	NFS_LAYOUT_INVALID_STID,	/* layout stateid id is invalid */
-- 
1.8.3.1

