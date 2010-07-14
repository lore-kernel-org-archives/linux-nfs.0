From: andros@netapp.com
Subject: [PATCH 5/5] pnfs post-submit: restore gather_across_stripes policy
Date: Wed, 14 Jul 2010 15:43:58 -0400
Message-ID: <1279136638-3097-5-git-send-email-andros@netapp.com>
References: <1279136638-3097-1-git-send-email-andros@netapp.com>
 <1279136638-3097-2-git-send-email-andros@netapp.com>
 <1279136638-3097-3-git-send-email-andros@netapp.com>
 <1279136638-3097-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57527 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754981Ab0GNTn6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jul 2010 15:43:58 -0400
In-Reply-To: <1279136638-3097-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c             |    4 ++++
 include/linux/nfs4_pnfs.h |   10 ++++++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d3df8df..56c3af4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1191,6 +1191,10 @@ pnfs_getboundary(struct inode *inode)
 	if (!policy_ops || !policy_ops->get_stripesize)
 		goto out;
 
+	/* The default is to not gather across stripes */
+	if (pnfs_ld_gather_across_stripes(nfss->pnfs_curr_ld))
+		goto out;
+
 	spin_lock(&inode->i_lock);
 	if (NFS_I(inode)->layout)
 		stripe_size = policy_ops->get_stripesize(NFS_I(inode)->layout);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index eb9dfe4..9eebbdd 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -156,6 +156,9 @@ struct layoutdriver_io_operations {
 };
 
 enum layoutdriver_policy_flags {
+	/* Should the NFS req. gather algorithm cross stripe boundaries? */
+	PNFS_GATHER_ACROSS_STRIPES	= 1 << 1,
+
 	/* Should the pNFS client commit and return the layout upon a setattr */
 	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 3,
 };
@@ -170,6 +173,13 @@ struct layoutdriver_policy_operations {
 	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 };
 
+/* Should the NFS req. gather algorithm cross stripe boundaries? */
+static inline int
+pnfs_ld_gather_across_stripes(struct pnfs_layoutdriver_type *ld)
+{
+	return ld->ld_policy_ops->flags & PNFS_GATHER_ACROSS_STRIPES;
+}
+
 struct pnfs_device {
 	struct pnfs_deviceid dev_id;
 	unsigned int  layout_type;
-- 
1.6.6

