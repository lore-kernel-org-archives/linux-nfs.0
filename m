From: andros@netapp.com
Subject: [PATCH 07/16] SQUASHME pnfs_submit: don't get a reference on boundary calculation
Date: Wed,  7 Jul 2010 18:34:14 -0400
Message-ID: <1278542063-4009-8-git-send-email-andros@netapp.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>
 <1278542063-4009-2-git-send-email-andros@netapp.com>
 <1278542063-4009-3-git-send-email-andros@netapp.com>
 <1278542063-4009-4-git-send-email-andros@netapp.com>
 <1278542063-4009-5-git-send-email-andros@netapp.com>
 <1278542063-4009-6-git-send-email-andros@netapp.com>
 <1278542063-4009-7-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43252 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756887Ab0GGWe1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 18:34:27 -0400
In-Reply-To: <1278542063-4009-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The i_lock needs to be held because in the write path, we don't know if any
of the pages served by the pgio have a layout segment.

FIXME: Review when we calculate the boundary in the write path, perhaps
delaying until we know if pNFS I/O is to occur (at least one page is
referencing a layout segment).

Signed-off-by: Andy Adamon <andros@netapp.com>
---
 fs/nfs/pnfs.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7219d2b..18ebde9 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1302,8 +1302,6 @@ pnfs_getboundary(struct inode *inode)
 	u32 stripe_size = 0;
 	struct nfs_server *nfss = NFS_SERVER(inode);
 	struct layoutdriver_policy_operations *policy_ops;
-	struct nfs_inode *nfsi;
-	struct pnfs_layout_type *lo;
 
 	if (!nfss->pnfs_curr_ld)
 		goto out;
@@ -1316,13 +1314,9 @@ pnfs_getboundary(struct inode *inode)
 	if (pnfs_ld_gather_across_stripes(nfss->pnfs_curr_ld))
 		goto out;
 
-	nfsi = NFS_I(inode);
 	spin_lock(&inode->i_lock);
-	lo = grab_current_layout(nfsi);;
-	if (lo) {
-		stripe_size = policy_ops->get_stripesize(lo);
-		put_layout(lo);
-	}
+	if (NFS_I(inode)->layout)
+		stripe_size = policy_ops->get_stripesize(NFS_I(inode)->layout);
 	spin_unlock(&inode->i_lock);
 out:
 	return stripe_size;
-- 
1.6.6

