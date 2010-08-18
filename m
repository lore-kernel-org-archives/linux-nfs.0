Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6955 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753082Ab0HROoe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 10:44:34 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 09/11] SQUASHME pnfs_submit rename pnfs_layout_type 9
Date: Wed, 18 Aug 2010 10:44:16 -0400
Message-Id: <1282142658-21579-10-git-send-email-andros@netapp.com>
In-Reply-To: <1282142658-21579-9-git-send-email-andros@netapp.com>
References: <1282142658-21579-1-git-send-email-andros@netapp.com>
 <1282142658-21579-2-git-send-email-andros@netapp.com>
 <1282142658-21579-3-git-send-email-andros@netapp.com>
 <1282142658-21579-4-git-send-email-andros@netapp.com>
 <1282142658-21579-5-git-send-email-andros@netapp.com>
 <1282142658-21579-6-git-send-email-andros@netapp.com>
 <1282142658-21579-7-git-send-email-andros@netapp.com>
 <1282142658-21579-8-git-send-email-andros@netapp.com>
 <1282142658-21579-9-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit-pageio-helpers

Signed-of-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c             |    6 +++---
 include/linux/nfs4_pnfs.h |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b9bf9d6..52d1a79 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1163,14 +1163,14 @@ out:
 void
 pnfs_set_pg_test(struct inode *inode, struct nfs_pageio_descriptor *pgio)
 {
-	struct pnfs_layout_type *laytype;
+	struct pnfs_layout_hdr *lo;
 	struct pnfs_layoutdriver_type *ld;
 
 	pgio->pg_test = NULL;
 
-	laytype = NFS_I(inode)->layout;
+	lo = NFS_I(inode)->layout;
 	ld = NFS_SERVER(inode)->pnfs_curr_ld;
-	if (!pnfs_enabled_sb(NFS_SERVER(inode)) || !laytype)
+	if (!pnfs_enabled_sb(NFS_SERVER(inode)) || !lo)
 		return;
 
 	if (ld->ld_policy_ops)
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 89d0e7e..cbb98f1 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -148,7 +148,7 @@ struct layoutdriver_io_operations {
 
 struct layoutdriver_policy_operations {
 	/* The stripe size of the file system */
-	ssize_t (*get_stripesize) (struct pnfs_layout_type *layoutid);
+	ssize_t (*get_stripesize) (struct pnfs_layout_hdr *layoutid);
 
 	/* test for nfs page cache coalescing */
 	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
-- 
1.6.2.5

