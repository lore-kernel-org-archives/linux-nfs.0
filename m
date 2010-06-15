From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 1/1] pnfs-submit: test for sending LAYOUTRETURN was reversed
Date: Tue, 15 Jun 2010 01:01:57 -0400
Message-ID: <1276578117-22597-1-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:60652 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754358Ab0FORfy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 13:35:54 -0400
Received: from localhost.localdomain (netapp-61.citi.umich.edu [141.212.112.250])
	by citi.umich.edu (Postfix) with ESMTP id A04091810E
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jun 2010 13:35:53 -0400 (EDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Setting this correctly also simplifies the call to layout_return.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index edffee3..56d2932 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -731,7 +731,6 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 
 static int
 return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
-	      const nfs4_stateid *stateid, /* optional */
 	      enum pnfs_layoutreturn_type type, struct pnfs_layout_type *lo,
 	      bool wait)
 {
@@ -755,10 +754,7 @@ return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 	lrp->args.lseg = *range;
 	lrp->args.inode = ino;
 	lrp->lo = lo;
-	if (stateid)
-		lrp->args.stateid = *stateid;
-	else if (lo)
-		pnfs_get_layout_stateid(&lrp->args.stateid, lo);
+	pnfs_get_layout_stateid(&lrp->args.stateid, lo);
 
 	status = pnfs4_proc_layoutreturn(lrp, wait);
 out:
@@ -830,9 +826,8 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 			}
 		}
 
-		if (stateid && wait)
-			status = return_layout(ino, &arg, stateid, type,
-					       lo, wait);
+		if (!stateid)
+			status = return_layout(ino, &arg, type, lo, wait);
 		else
 			pnfs_layout_release(lo, &arg);
 	}
-- 
1.6.6.1

