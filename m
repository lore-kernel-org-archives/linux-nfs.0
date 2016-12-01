Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35146 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752472AbcLAWTq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:46 -0500
Received: by mail-io0-f195.google.com with SMTP id h133so4681608ioe.2
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:46 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 23/26] pNFS: Sync the layout state bits in pnfs_cache_lseg_for_layoutreturn
Date: Thu,  1 Dec 2016 17:19:19 -0500
Message-Id: <20161201221922.15657-24-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-23-trond.myklebust@primarydata.com>
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
 <20161201221922.15657-22-trond.myklebust@primarydata.com>
 <20161201221922.15657-23-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that the layout state bits are synced when we cache a layout
segment for layoutreturn using an appropriate call to
pnfs_set_plh_return_info.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a3a51860563c..08acfa49f115 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -306,6 +306,20 @@ pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo)
 }
 
 static void
+pnfs_set_plh_return_info(struct pnfs_layout_hdr *lo, enum pnfs_iomode iomode,
+			 u32 seq)
+{
+	if (lo->plh_return_iomode != 0 && lo->plh_return_iomode != iomode)
+		iomode = IOMODE_ANY;
+	lo->plh_return_iomode = iomode;
+	set_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
+	if (seq != 0) {
+		WARN_ON_ONCE(lo->plh_return_seq != 0 && lo->plh_return_seq != seq);
+		lo->plh_return_seq = seq;
+	}
+}
+
+static void
 pnfs_clear_layoutreturn_info(struct pnfs_layout_hdr *lo)
 {
 	lo->plh_return_iomode = 0;
@@ -456,6 +470,7 @@ pnfs_cache_lseg_for_layoutreturn(struct pnfs_layout_hdr *lo,
 {
 	if (test_and_clear_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags) &&
 	    pnfs_layout_is_valid(lo)) {
+		pnfs_set_plh_return_info(lo, lseg->pls_range.iomode, 0);
 		list_move_tail(&lseg->pls_list, &lo->plh_return_segs);
 		return true;
 	}
@@ -1001,20 +1016,6 @@ void pnfs_layoutreturn_free_lsegs(struct pnfs_layout_hdr *lo,
 
 }
 
-static void
-pnfs_set_plh_return_info(struct pnfs_layout_hdr *lo, enum pnfs_iomode iomode,
-			 u32 seq)
-{
-	if (lo->plh_return_iomode != 0 && lo->plh_return_iomode != iomode)
-		iomode = IOMODE_ANY;
-	lo->plh_return_iomode = iomode;
-	set_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
-	if (seq != 0) {
-		WARN_ON_ONCE(lo->plh_return_seq != 0 && lo->plh_return_seq != seq);
-		lo->plh_return_seq = seq;
-	}
-}
-
 static bool
 pnfs_prepare_layoutreturn(struct pnfs_layout_hdr *lo,
 		nfs4_stateid *stateid,
-- 
2.9.3

