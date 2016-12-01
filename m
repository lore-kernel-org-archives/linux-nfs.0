Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:32971 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753817AbcLAWT3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:29 -0500
Received: by mail-io0-f195.google.com with SMTP id j92so3934846ioi.0
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:29 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/26] pNFS: Force a retry of LAYOUTGET if the stateid doesn't match our cache
Date: Thu,  1 Dec 2016 17:19:00 -0500
Message-Id: <20161201221922.15657-5-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-4-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server sends us a completely new stateid, and the client thinks
it already holds a layout, then force a retry of the LAYOUTGET after
invalidating the existing layout in order to avoid corruption due to
races.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d4e06b7459f4..9b7e88b7edfc 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1844,7 +1844,10 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		goto out_forget;
 	}
 
-	if (nfs4_stateid_match_other(&lo->plh_stateid, &res->stateid)) {
+	if (!pnfs_layout_is_valid(lo)) {
+		/* We have a completely new layout */
+		pnfs_set_layout_stateid(lo, &res->stateid, true);
+	} else if (nfs4_stateid_match_other(&lo->plh_stateid, &res->stateid)) {
 		/* existing state ID, make sure the sequence number matches. */
 		if (pnfs_layout_stateid_blocked(lo, &res->stateid)) {
 			dprintk("%s forget reply due to sequence\n", __func__);
@@ -1854,12 +1857,10 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	} else {
 		/*
 		 * We got an entirely new state ID.  Mark all segments for the
-		 * inode invalid, and don't bother validating the stateid
-		 * sequence number.
+		 * inode invalid, and retry the layoutget
 		 */
 		pnfs_mark_layout_stateid_invalid(lo, &free_me);
-
-		pnfs_set_layout_stateid(lo, &res->stateid, true);
+		goto out_forget;
 	}
 
 	pnfs_get_lseg(lseg);
-- 
2.9.3

