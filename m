Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:33015 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752469AbcBOSNq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Feb 2016 13:13:46 -0500
Received: by mail-ig0-f170.google.com with SMTP id y8so80364000igp.0
        for <linux-nfs@vger.kernel.org>; Mon, 15 Feb 2016 10:13:46 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] pNFS: Fix pnfs_mark_matching_lsegs_return()
Date: Mon, 15 Feb 2016 13:13:02 -0500
Message-Id: <1455559983-11808-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't need to schedule a layoutreturn if the layout segment can
be freed immediately.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 482b6e94bb37..8d9fa4e40e89 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1740,6 +1740,16 @@ pnfs_set_plh_return_iomode(struct pnfs_layout_hdr *lo, enum pnfs_iomode iomode)
 	lo->plh_return_iomode = iomode;
 }
 
+/**
+ * pnfs_mark_matching_lsegs_return - Free or return matching layout segments
+ * @lo: pointer to layout header
+ * @tmp_list: list header to be used with pnfs_free_lseg_list()
+ * @return_range: describe layout segment ranges to be returned
+ *
+ * This function is mainly intended for use by layoutrecall. It attempts
+ * to free the layout segment immediately, or else to mark it for return
+ * as soon as its reference count drops to zero.
+ */
 int
 pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
@@ -1762,10 +1772,11 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				lseg, lseg->pls_range.iomode,
 				lseg->pls_range.offset,
 				lseg->pls_range.length);
+			if (mark_lseg_invalid(lseg, tmp_list))
+				continue;
+			remaining++;
 			set_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags);
 			pnfs_set_plh_return_iomode(lo, return_range->iomode);
-			if (!mark_lseg_invalid(lseg, tmp_list))
-				remaining++;
 			set_bit(NFS_LAYOUT_RETURN_REQUESTED,
 					&lo->plh_flags);
 		}
-- 
2.5.0

