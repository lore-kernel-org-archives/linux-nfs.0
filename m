Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33487 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750789AbdEBQlJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 May 2017 12:41:09 -0400
Received: by mail-it0-f66.google.com with SMTP id v135so3038990itv.0
        for <linux-nfs@vger.kernel.org>; Tue, 02 May 2017 09:41:08 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] pNFS: Don't clear the layout return info if there are segments to return
Date: Tue,  2 May 2017 12:41:03 -0400
Message-Id: <20170502164105.6373-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170502164105.6373-1-trond.myklebust@primarydata.com>
References: <20170502164105.6373-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In pnfs_clear_layoutreturn_info, ensure that we don't clear the layout
return info if there are new segments queued for return due to, for
instance, a race between a LAYOUTRETURN and a failed I/O attempt.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 140ecd7d350f..cea1e838efae 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -322,9 +322,15 @@ pnfs_set_plh_return_info(struct pnfs_layout_hdr *lo, enum pnfs_iomode iomode,
 static void
 pnfs_clear_layoutreturn_info(struct pnfs_layout_hdr *lo)
 {
+	struct pnfs_layout_segment *lseg;
 	lo->plh_return_iomode = 0;
 	lo->plh_return_seq = 0;
 	clear_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
+	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
+		if (!test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
+			continue;
+		pnfs_set_plh_return_info(lo, lseg->pls_range.iomode, 0);
+	}
 }
 
 static void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo)
@@ -367,9 +373,9 @@ pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 	struct pnfs_layout_segment *lseg, *next;
 
 	set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
-	pnfs_clear_layoutreturn_info(lo);
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
 		pnfs_clear_lseg_state(lseg, lseg_list);
+	pnfs_clear_layoutreturn_info(lo);
 	pnfs_free_returned_lsegs(lo, lseg_list, &range, 0);
 	if (test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags) &&
 	    !test_and_set_bit(NFS_LAYOUT_RETURN_LOCK, &lo->plh_flags))
-- 
2.9.3

