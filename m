Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36655 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753817AbcLAWT2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:28 -0500
Received: by mail-io0-f194.google.com with SMTP id s82so3820903ioi.3
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:28 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/26] pNFS: Clear NFS_LAYOUT_RETURN_REQUESTED when invalidating the layout stateid
Date: Thu,  1 Dec 2016 17:18:59 -0500
Message-Id: <20161201221922.15657-4-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-3-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must ensure that we don't schedule a layoutreturn if the layout stateid
has been marked as invalid.

Fixes: 2a59a0411671e ("pNFS: Fix pnfs_set_layout_stateid() to clear...")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org # v4.8+
---
 fs/nfs/pnfs.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 09bbb07d0494..d4e06b7459f4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -299,6 +299,14 @@ pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo)
 	}
 }
 
+static void
+pnfs_clear_layoutreturn_info(struct pnfs_layout_hdr *lo)
+{
+	lo->plh_return_iomode = 0;
+	lo->plh_return_seq = 0;
+	clear_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
+}
+
 /*
  * Mark a pnfs_layout_hdr and all associated layout segments as invalid
  *
@@ -317,6 +325,7 @@ pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 	};
 
 	set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
+	pnfs_clear_layoutreturn_info(lo);
 	return pnfs_mark_matching_lsegs_invalid(lo, lseg_list, &range, 0);
 }
 
@@ -818,14 +827,6 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
 	pnfs_destroy_layouts_byclid(clp, false);
 }
 
-static void
-pnfs_clear_layoutreturn_info(struct pnfs_layout_hdr *lo)
-{
-	lo->plh_return_iomode = 0;
-	lo->plh_return_seq = 0;
-	clear_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
-}
-
 /* update lo->plh_stateid with new if is more recent */
 void
 pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
-- 
2.9.3

