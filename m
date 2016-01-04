Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36080 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390AbcADSVz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 13:21:55 -0500
Received: by mail-ig0-f181.google.com with SMTP id ph11so250741607igc.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 10:21:55 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 13/18] NFSv4.1/pNFS: pnfs_mark_matching_lsegs_return() should set the iomode
Date: Mon,  4 Jan 2016 13:21:11 -0500
Message-Id: <1451931676-68481-13-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451931676-68481-12-git-send-email-trond.myklebust@primarydata.com>
References: <1451931676-68481-1-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-2-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-3-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-4-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-5-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-6-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-7-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-8-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-9-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-10-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-11-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-12-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If pnfs_mark_matching_lsegs_return() needs to mark a layout segment for
return, then it must also set the return iomode.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7e0f2b9a9b10..449c4782cab3 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1758,6 +1758,16 @@ out_forget_reply:
 	goto out;
 }
 
+static void
+pnfs_set_plh_return_iomode(struct pnfs_layout_hdr *lo, enum pnfs_iomode iomode)
+{
+	if (lo->plh_return_iomode == iomode)
+		return;
+	if (lo->plh_return_iomode != 0)
+		iomode = IOMODE_ANY;
+	lo->plh_return_iomode = iomode;
+}
+
 void
 pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
@@ -1780,6 +1790,7 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				lseg->pls_range.offset,
 				lseg->pls_range.length);
 			set_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags);
+			pnfs_set_plh_return_iomode(lo, return_range->iomode);
 			mark_lseg_invalid(lseg, tmp_list);
 			set_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
 					&lo->plh_flags);
@@ -1801,10 +1812,7 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 	spin_lock(&inode->i_lock);
 	/* set failure bit so that pnfs path will be retried later */
 	pnfs_layout_set_fail_bit(lo, iomode);
-	if (lo->plh_return_iomode == 0)
-		lo->plh_return_iomode = range.iomode;
-	else if (lo->plh_return_iomode != range.iomode)
-		lo->plh_return_iomode = IOMODE_ANY;
+	pnfs_set_plh_return_iomode(lo, range.iomode);
 	/*
 	 * mark all matching lsegs so that we are sure to have no live
 	 * segments at hand when sending layoutreturn. See pnfs_put_lseg()
-- 
2.5.0

