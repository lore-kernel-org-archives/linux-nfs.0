From: andros@netapp.com
Subject: [PATCH 01/10] SQUASHME: pnfs-submit remove unused filelayout_mount_type
Date: Wed, 23 Jun 2010 15:21:09 -0400
Message-ID: <1277320878-3726-2-git-send-email-andros@netapp.com>
References: <1277320878-3726-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5004 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753409Ab0FWTW1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jun 2010 15:22:27 -0400
In-Reply-To: <1277320878-3726-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.h |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 29e481d..de8391f 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -24,8 +24,6 @@
 #define NFS4_PNFS_MAX_MULTI_CNT  64 /* 256 fit into a u8 stripe_index */
 #define NFS4_PNFS_MAX_MULTI_DS   2
 
-#define FILE_MT(inode) ((struct filelayout_mount_type *) \
-			(NFS_SERVER(inode)->pnfs_mountid->mountid))
 #define FILE_DSADDR(lseg) (container_of(lseg->deviceid, \
 					struct nfs4_file_layout_dsaddr, \
 					deviceid))
@@ -76,10 +74,6 @@ struct nfs4_filelayout {
 	u32 stripe_unit;
 };
 
-struct filelayout_mount_type {
-	struct super_block *fl_sb;
-};
-
 extern struct nfs_fh *
 nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, loff_t offset);
 
-- 
1.6.6

