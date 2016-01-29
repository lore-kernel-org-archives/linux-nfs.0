Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33117 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668AbcA2Edx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jan 2016 23:33:53 -0500
Received: by mail-ig0-f174.google.com with SMTP id z14so28972354igp.0
        for <linux-nfs@vger.kernel.org>; Thu, 28 Jan 2016 20:33:53 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Cleanup - rename NFS_LAYOUT_RETURN_BEFORE_CLOSE
Date: Thu, 28 Jan 2016 23:33:14 -0500
Message-Id: <1454041994-58090-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1454041994-58090-1-git-send-email-trond.myklebust@primarydata.com>
References: <1454041994-58090-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS_LAYOUT_RETURN_BEFORE_CLOSE is being used to signal that a
layoutreturn is needed, either due to a layout recall or to a
layout error. Rename it to NFS_LAYOUT_RETURN_REQUESTED in order
to clarify its purpose.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    |  2 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  2 +-
 fs/nfs/pnfs.c                             | 10 +++++-----
 fs/nfs/pnfs.h                             |  4 ++--
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 5bcd92d50e82..0cb1abd535e3 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1215,7 +1215,7 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 					hdr->pgio_mirror_idx + 1,
 					&hdr->pgio_mirror_idx))
 			goto out_eagain;
-		set_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
+		set_bit(NFS_LAYOUT_RETURN_REQUESTED,
 			&hdr->lseg->pls_layout->plh_flags);
 		pnfs_read_resend_pnfs(hdr);
 		return task->tk_status;
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 29898a9550fa..eb370460ce20 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -412,7 +412,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 					 OP_ILLEGAL, GFP_NOIO);
 		if (!fail_return) {
 			if (ff_layout_has_available_ds(lseg))
-				set_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
+				set_bit(NFS_LAYOUT_RETURN_REQUESTED,
 					&lseg->pls_layout->plh_flags);
 			else
 				pnfs_error_mark_layout_for_return(ino, lseg);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9c20685d4961..482b6e94bb37 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -885,7 +885,7 @@ pnfs_prepare_layoutreturn(struct pnfs_layout_hdr *lo)
 		return false;
 	lo->plh_return_iomode = 0;
 	pnfs_get_layout_hdr(lo);
-	clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE, &lo->plh_flags);
+	clear_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
 	return true;
 }
 
@@ -929,7 +929,7 @@ pnfs_layout_need_return(struct pnfs_layout_hdr *lo)
 {
 	struct pnfs_layout_segment *s;
 
-	if (!test_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE, &lo->plh_flags))
+	if (!test_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags))
 		return false;
 
 	/* Defer layoutreturn until all lsegs are done */
@@ -945,7 +945,7 @@ static void pnfs_layoutreturn_before_put_layout_hdr(struct pnfs_layout_hdr *lo)
 {
 	struct inode *inode= lo->plh_inode;
 
-	if (!test_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE, &lo->plh_flags))
+	if (!test_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags))
 		return;
 	spin_lock(&inode->i_lock);
 	if (pnfs_layout_need_return(lo)) {
@@ -1085,7 +1085,7 @@ bool pnfs_roc(struct inode *ino)
 
 	nfs4_stateid_copy(&stateid, &lo->plh_stateid);
 	/* always send layoutreturn if being marked so */
-	if (test_and_clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
+	if (test_and_clear_bit(NFS_LAYOUT_RETURN_REQUESTED,
 				   &lo->plh_flags))
 		layoutreturn = pnfs_prepare_layoutreturn(lo);
 
@@ -1766,7 +1766,7 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 			pnfs_set_plh_return_iomode(lo, return_range->iomode);
 			if (!mark_lseg_invalid(lseg, tmp_list))
 				remaining++;
-			set_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
+			set_bit(NFS_LAYOUT_RETURN_REQUESTED,
 					&lo->plh_flags);
 		}
 	return remaining;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9f4e2a47f4aa..1ac1db5f6dad 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -94,8 +94,8 @@ enum {
 	NFS_LAYOUT_RO_FAILED = 0,	/* get ro layout failed stop trying */
 	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
 	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
-	NFS_LAYOUT_RETURN,		/* Return this layout ASAP */
-	NFS_LAYOUT_RETURN_BEFORE_CLOSE,	/* Return this layout before close */
+	NFS_LAYOUT_RETURN,		/* layoutreturn in progress */
+	NFS_LAYOUT_RETURN_REQUESTED,	/* Return this layout ASAP */
 	NFS_LAYOUT_INVALID_STID,	/* layout stateid id is invalid */
 	NFS_LAYOUT_FIRST_LAYOUTGET,	/* Serialize first layoutget */
 };
-- 
2.5.0

