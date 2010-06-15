From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 04/10] pnfs-submit: add backpointer to pnfs_layout_type
Date: Mon, 14 Jun 2010 21:46:09 -0400
Message-ID: <1276566375-24566-5-git-send-email-iisaman@netapp.com>
References: <1276566375-24566-1-git-send-email-iisaman@netapp.com>
 <1276566375-24566-2-git-send-email-iisaman@netapp.com>
 <1276566375-24566-3-git-send-email-iisaman@netapp.com>
 <1276566375-24566-4-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:52266 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932181Ab0FOO3E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 10:29:04 -0400
Received: from localhost.localdomain (netapp-61.citi.umich.edu [141.212.112.250])
	by citi.umich.edu (Postfix) with ESMTP id 4AB2618165
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jun 2010 10:20:11 -0400 (EDT)
In-Reply-To: <1276566375-24566-4-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Note: This should be avoided by passing struct inode instead of struct
pnfs_layout_type in all layoutdriver_io_operaitons.(which i suggest we do)

In preparation to changing the nfs_inode->layout to be a pointer to
struct pnfs_layout_type and allocate it in the alloc_layout layoutdriver io
operation.

-->Andy Adamson <andros@netapp.com>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/inode.c            |    1 +
 include/linux/nfs4_pnfs.h |    4 ++--
 include/linux/nfs_fs.h    |    1 +
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index cdec539..be25ffc 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1423,6 +1423,7 @@ static void pnfs_init_once(struct nfs_inode *nfsi)
 	INIT_LIST_HEAD(&nfsi->layout.segs);
 	nfsi->layout.refcount = 0;
 	nfsi->layout.ld_data = NULL;
+	nfsi->layout.lo_inode = &nfsi->vfs_inode;
 #endif /* CONFIG_NFS_V4_1 */
 }
 
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index a88cd69..9dac941 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -35,13 +35,13 @@ struct pnfs_layoutdriver_type {
 static inline struct nfs_inode *
 PNFS_NFS_INODE(struct pnfs_layout_type *lo)
 {
-	return container_of(lo, struct nfs_inode, layout);
+	return NFS_I(lo->lo_inode);
 }
 
 static inline struct inode *
 PNFS_INODE(struct pnfs_layout_type *lo)
 {
-	return &PNFS_NFS_INODE(lo)->vfs_inode;
+	return lo->lo_inode;
 }
 
 static inline struct nfs_server *
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 41026cb..95d8d53 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -116,6 +116,7 @@ struct pnfs_layout_type {
 	 */
 	loff_t                  pnfs_write_begin_pos;
 	loff_t                  pnfs_write_end_pos;
+	struct inode		*lo_inode;
 };
 
 /*
-- 
1.6.6.1

