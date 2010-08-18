Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6955 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752227Ab0HROoZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 10:44:25 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 03/11] SQUASHME pnfs-submit rename pnfs_layout_type 3
Date: Wed, 18 Aug 2010 10:44:10 -0400
Message-Id: <1282142658-21579-4-git-send-email-andros@netapp.com>
In-Reply-To: <1282142658-21579-3-git-send-email-andros@netapp.com>
References: <1282142658-21579-1-git-send-email-andros@netapp.com>
 <1282142658-21579-2-git-send-email-andros@netapp.com>
 <1282142658-21579-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit: layout segment alloc, reference, destroy

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c             |    2 +-
 include/linux/nfs4_pnfs.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bf86975..98f53c2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -412,7 +412,7 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
 }
 
 static inline void
-init_lseg(struct pnfs_layout_type *lo, struct pnfs_layout_segment *lseg)
+init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 {
 	INIT_LIST_HEAD(&lseg->fi_list);
 	kref_init(&lseg->kref);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 59a1a12..89d0e7e 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -137,7 +137,7 @@ struct layoutdriver_io_operations {
 	 * a set_layout call to set the opaque layout in the layout driver.*/
 	struct pnfs_layout_hdr * (*alloc_layout) (struct inode *inode);
 	void (*free_layout) (struct pnfs_layout_hdr *);
-	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_type *layoutid, struct nfs4_pnfs_layoutget_res *lgr);
+	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_pnfs_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
 	/* Registration information for a new mounted file system
-- 
1.6.2.5

