Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46873 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759341AbcCDTqX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2016 14:46:23 -0500
From: Christoph Hellwig <hch@lst.de>
To: trond.myklebust@primarydata.com, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] nfsd: add a new config option for the block layout driver
Date: Fri,  4 Mar 2016 20:46:16 +0100
Message-Id: <1457120777-30687-4-git-send-email-hch@lst.de>
In-Reply-To: <1457120777-30687-1-git-send-email-hch@lst.de>
References: <1457120777-30687-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split the config symbols into a generic pNFS one, which is invisible
and gets selected by the layout drivers, and one for the block layout
driver.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/Kconfig       | 13 +++++++++----
 fs/nfsd/Makefile      |  3 ++-
 fs/nfsd/nfs4layouts.c |  4 ++++
 fs/nfsd/pnfs.h        |  2 ++
 fs/xfs/Makefile       |  2 +-
 fs/xfs/xfs_export.c   |  2 +-
 fs/xfs/xfs_pnfs.h     |  2 +-
 7 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index a0b77fc..eb70d91 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -84,12 +84,17 @@ config NFSD_V4
 	  If unsure, say N.
 
 config NFSD_PNFS
-	bool "NFSv4.1 server support for Parallel NFS (pNFS)"
+	bool
+
+config NFSD_BLOCKLAYOUT
+	bool "NFSv4.1 server support for pNFS block layouts"
 	depends on NFSD_V4
+	select NFSD_PNFS
 	help
-	  This option enables support for the parallel NFS features of the
-	  minor version 1 of the NFSv4 protocol (RFC5661) in the kernel's NFS
-	  server.
+	  This option enables support for the exporting pNFS block layouts
+	  in the kernel's NFS server. The pNFS block layout enables NFS
+	  clients to directly perform I/O to block devices accesible to both
+	  the server and the clients.  See RFC 5663 for more details.
 
 	  If unsure, say N.
 
diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index 9a6028e..679cdc6 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -17,4 +17,5 @@ nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
 nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
 nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
 			   nfs4acl.o nfs4callback.o nfs4recover.o
-nfsd-$(CONFIG_NFSD_PNFS) += nfs4layouts.o blocklayout.o blocklayoutxdr.o
+nfsd-$(CONFIG_NFSD_PNFS) += nfs4layouts.o
+nfsd-$(CONFIG_NFSD_BLOCKLAYOUT) += blocklayout.o blocklayoutxdr.o
diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index ce2d010..4e4def7 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -26,7 +26,9 @@ static const struct nfsd4_callback_ops nfsd4_cb_layout_ops;
 static const struct lock_manager_operations nfsd4_layouts_lm_ops;
 
 const struct nfsd4_layout_ops *nfsd4_layout_ops[LAYOUT_TYPE_MAX] =  {
+#ifdef CONFIG_NFSD_BLOCKLAYOUT
 	[LAYOUT_BLOCK_VOLUME]	= &bl_layout_ops,
+#endif
 };
 
 /* pNFS device ID to export fsid mapping */
@@ -121,10 +123,12 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
 	if (!(exp->ex_flags & NFSEXP_PNFS))
 		return;
 
+#ifdef CONFIG_NFSD_BLOCKLAYOUT
 	if (sb->s_export_op->get_uuid &&
 	    sb->s_export_op->map_blocks &&
 	    sb->s_export_op->commit_blocks)
 		exp->ex_layout_type = LAYOUT_BLOCK_VOLUME;
+#endif
 }
 
 static void
diff --git a/fs/nfsd/pnfs.h b/fs/nfsd/pnfs.h
index d4c4453..ff50bfa 100644
--- a/fs/nfsd/pnfs.h
+++ b/fs/nfsd/pnfs.h
@@ -35,7 +35,9 @@ struct nfsd4_layout_ops {
 };
 
 extern const struct nfsd4_layout_ops *nfsd4_layout_ops[];
+#ifdef CONFIG_NFSD_BLOCKLAYOUT
 extern const struct nfsd4_layout_ops bl_layout_ops;
+#endif
 
 __be32 nfsd4_preprocess_layout_stateid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *cstate, stateid_t *stateid,
diff --git a/fs/xfs/Makefile b/fs/xfs/Makefile
index f646391..d68b62a 100644
--- a/fs/xfs/Makefile
+++ b/fs/xfs/Makefile
@@ -121,4 +121,4 @@ xfs-$(CONFIG_XFS_RT)		+= xfs_rtalloc.o
 xfs-$(CONFIG_XFS_POSIX_ACL)	+= xfs_acl.o
 xfs-$(CONFIG_SYSCTL)		+= xfs_sysctl.o
 xfs-$(CONFIG_COMPAT)		+= xfs_ioctl32.o
-xfs-$(CONFIG_NFSD_PNFS)		+= xfs_pnfs.o
+xfs-$(CONFIG_NFSD_BLOCKLAYOUT)	+= xfs_pnfs.o
diff --git a/fs/xfs/xfs_export.c b/fs/xfs/xfs_export.c
index 652cd3c..0492b82 100644
--- a/fs/xfs/xfs_export.c
+++ b/fs/xfs/xfs_export.c
@@ -246,7 +246,7 @@ const struct export_operations xfs_export_operations = {
 	.fh_to_parent		= xfs_fs_fh_to_parent,
 	.get_parent		= xfs_fs_get_parent,
 	.commit_metadata	= xfs_fs_nfs_commit_metadata,
-#ifdef CONFIG_NFSD_PNFS
+#ifdef CONFIG_NFSD_BLOCKLAYOUT
 	.get_uuid		= xfs_fs_get_uuid,
 	.map_blocks		= xfs_fs_map_blocks,
 	.commit_blocks		= xfs_fs_commit_blocks,
diff --git a/fs/xfs/xfs_pnfs.h b/fs/xfs/xfs_pnfs.h
index 8147ac1..d85529c 100644
--- a/fs/xfs/xfs_pnfs.h
+++ b/fs/xfs/xfs_pnfs.h
@@ -1,7 +1,7 @@
 #ifndef _XFS_PNFS_H
 #define _XFS_PNFS_H 1
 
-#ifdef CONFIG_NFSD_PNFS
+#ifdef CONFIG_NFSD_BLOCKLAYOUT
 int xfs_fs_get_uuid(struct super_block *sb, u8 *buf, u32 *len, u64 *offset);
 int xfs_fs_map_blocks(struct inode *inode, loff_t offset, u64 length,
 		struct iomap *iomap, bool write, u32 *device_generation);
-- 
2.1.4

