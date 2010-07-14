From: andros@netapp.com
Subject: [PATCH 2/5] SQUASHME pnfs-submit remove gather_across_stripes policy
Date: Wed, 14 Jul 2010 15:43:55 -0400
Message-ID: <1279136638-3097-2-git-send-email-andros@netapp.com>
References: <1279136638-3097-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57527 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754258Ab0GNTn4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jul 2010 15:43:56 -0400
In-Reply-To: <1279136638-3097-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Unused by the file layout. Will restore.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c             |    4 ----
 include/linux/nfs4_pnfs.h |   10 ----------
 2 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 56c3af4..d3df8df 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1191,10 +1191,6 @@ pnfs_getboundary(struct inode *inode)
 	if (!policy_ops || !policy_ops->get_stripesize)
 		goto out;
 
-	/* The default is to not gather across stripes */
-	if (pnfs_ld_gather_across_stripes(nfss->pnfs_curr_ld))
-		goto out;
-
 	spin_lock(&inode->i_lock);
 	if (NFS_I(inode)->layout)
 		stripe_size = policy_ops->get_stripesize(NFS_I(inode)->layout);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 9eebbdd..eb9dfe4 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -156,9 +156,6 @@ struct layoutdriver_io_operations {
 };
 
 enum layoutdriver_policy_flags {
-	/* Should the NFS req. gather algorithm cross stripe boundaries? */
-	PNFS_GATHER_ACROSS_STRIPES	= 1 << 1,
-
 	/* Should the pNFS client commit and return the layout upon a setattr */
 	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 3,
 };
@@ -173,13 +170,6 @@ struct layoutdriver_policy_operations {
 	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 };
 
-/* Should the NFS req. gather algorithm cross stripe boundaries? */
-static inline int
-pnfs_ld_gather_across_stripes(struct pnfs_layoutdriver_type *ld)
-{
-	return ld->ld_policy_ops->flags & PNFS_GATHER_ACROSS_STRIPES;
-}
-
 struct pnfs_device {
 	struct pnfs_deviceid dev_id;
 	unsigned int  layout_type;
-- 
1.6.6

