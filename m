From: andros@netapp.com
Subject: [PATCH 1/4] SQUASHME pnfs-submit remove unused pnfs_return_layout_done
Date: Thu, 15 Jul 2010 12:33:47 -0400
Message-ID: <1279211630-6039-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2923 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933695Ab0GOQd0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 12:33:26 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Not used by any layout driver

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |   15 ---------------
 1 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7327cb2..b9ada8e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -761,21 +761,6 @@ out_put:
 	goto out;
 }
 
-void
-pnfs_return_layout_done(struct pnfs_layout_type *lo,
-		     struct nfs4_pnfs_layoutreturn *lrp,
-		     int rpc_status)
-{
-	dprintk("--> %s\n", __func__);
-
-	/* FIX-ME: If layoutreturn failed, we have already removed the
-	 * lseg from the cache...
-	 */
-	pnfs_set_layout_stateid(lo, &lrp->res.stateid);
-
-	dprintk("<-- %s\n", __func__);
-}
-
 /*
  * cmp two layout segments for sorting into layout cache
  */
-- 
1.6.6

