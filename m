Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34692 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759828AbcLAWTp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:45 -0500
Received: by mail-io0-f196.google.com with SMTP id r94so3917939ioe.1
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:44 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 21/26] pNFS: Clear all layout segment state in pnfs_mark_layout_stateid_invalid
Date: Thu,  1 Dec 2016 17:19:17 -0500
Message-Id: <20161201221922.15657-22-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-21-trond.myklebust@primarydata.com>
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
 <20161201221922.15657-15-trond.myklebust@primarydata.com>
 <20161201221922.15657-16-trond.myklebust@primarydata.com>
 <20161201221922.15657-17-trond.myklebust@primarydata.com>
 <20161201221922.15657-18-trond.myklebust@primarydata.com>
 <20161201221922.15657-19-trond.myklebust@primarydata.com>
 <20161201221922.15657-20-trond.myklebust@primarydata.com>
 <20161201221922.15657-21-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the layout state is invalidated, then so is the layout segment
state, and hence we do need to clean up the state bits.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f61cb81eb5ab..76b18518881e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -58,6 +58,8 @@ static void pnfs_free_returned_lsegs(struct pnfs_layout_hdr *lo,
 		struct list_head *free_me,
 		const struct pnfs_layout_range *range,
 		u32 seq);
+static bool pnfs_lseg_dec_and_remove_zero(struct pnfs_layout_segment *lseg,
+		                struct list_head *tmp_list);
 
 /* Return the registered pnfs layout driver module matching given id */
 static struct pnfs_layoutdriver_type *
@@ -311,6 +313,18 @@ pnfs_clear_layoutreturn_info(struct pnfs_layout_hdr *lo)
 	clear_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
 }
 
+static void
+pnfs_clear_lseg_state(struct pnfs_layout_segment *lseg,
+		struct list_head *free_me)
+{
+	clear_bit(NFS_LSEG_ROC, &lseg->pls_flags);
+	clear_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags);
+	if (test_and_clear_bit(NFS_LSEG_VALID, &lseg->pls_flags))
+		pnfs_lseg_dec_and_remove_zero(lseg, free_me);
+	if (test_and_clear_bit(NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags))
+		pnfs_lseg_dec_and_remove_zero(lseg, free_me);
+}
+
 /*
  * Mark a pnfs_layout_hdr and all associated layout segments as invalid
  *
@@ -327,11 +341,14 @@ pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 		.offset = 0,
 		.length = NFS4_MAX_UINT64,
 	};
+	struct pnfs_layout_segment *lseg, *next;
 
 	set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
 	pnfs_clear_layoutreturn_info(lo);
+	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
+		pnfs_clear_lseg_state(lseg, lseg_list);
 	pnfs_free_returned_lsegs(lo, lseg_list, &range, 0);
-	return pnfs_mark_matching_lsegs_invalid(lo, lseg_list, &range, 0);
+	return !list_empty(&lo->plh_segs);
 }
 
 static int
-- 
2.9.3

