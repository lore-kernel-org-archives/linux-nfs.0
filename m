Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:41456 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbbAVLLa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 06:11:30 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: [PATCH 20/20] xfs: recall pNFS layouts on conflicting access
Date: Thu, 22 Jan 2015 12:10:06 +0100
Message-Id: <1421925006-24231-21-git-send-email-hch@lst.de>
In-Reply-To: <1421925006-24231-1-git-send-email-hch@lst.de>
References: <1421925006-24231-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recall all outstanding pNFS layouts and truncates, writes and similar extent
list modifying operations.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_file.c  | 14 ++++++++++++--
 fs/xfs/xfs_ioctl.c |  9 +++++++--
 fs/xfs/xfs_iops.c  | 11 ++++++++---
 fs/xfs/xfs_pnfs.c  | 31 +++++++++++++++++++++++++++++++
 fs/xfs/xfs_pnfs.h  |  7 +++++++
 5 files changed, 65 insertions(+), 7 deletions(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 712d312..56dcfce 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -36,6 +36,7 @@
 #include "xfs_trace.h"
 #include "xfs_log.h"
 #include "xfs_icache.h"
+#include "xfs_pnfs.h"
 
 #include <linux/aio.h>
 #include <linux/dcache.h>
@@ -554,6 +555,10 @@ restart:
 	if (error)
 		return error;
 
+	error = xfs_break_layouts(inode, iolock);
+	if (error)
+		return error;
+
 	/*
 	 * If the offset is beyond the size of the file, we need to zero any
 	 * blocks that fall between the existing EOF and the start of this
@@ -822,6 +827,7 @@ xfs_file_fallocate(
 	struct xfs_inode	*ip = XFS_I(inode);
 	long			error;
 	enum xfs_prealloc_flags	flags = 0;
+	uint			iolock = XFS_IOLOCK_EXCL;
 	loff_t			new_size = 0;
 
 	if (!S_ISREG(inode->i_mode))
@@ -830,7 +836,11 @@ xfs_file_fallocate(
 		     FALLOC_FL_COLLAPSE_RANGE | FALLOC_FL_ZERO_RANGE))
 		return -EOPNOTSUPP;
 
-	xfs_ilock(ip, XFS_IOLOCK_EXCL);
+	xfs_ilock(ip, iolock);
+	error = xfs_break_layouts(inode, &iolock);
+	if (error)
+		goto out_unlock;
+
 	if (mode & FALLOC_FL_PUNCH_HOLE) {
 		error = xfs_free_file_space(ip, offset, len);
 		if (error)
@@ -894,7 +904,7 @@ xfs_file_fallocate(
 	}
 
 out_unlock:
-	xfs_iunlock(ip, XFS_IOLOCK_EXCL);
+	xfs_iunlock(ip, iolock);
 	return error;
 }
 
diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index d58bcd2..0b64310 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -39,6 +39,7 @@
 #include "xfs_icache.h"
 #include "xfs_symlink.h"
 #include "xfs_trans.h"
+#include "xfs_pnfs.h"
 
 #include <linux/capability.h>
 #include <linux/dcache.h>
@@ -608,6 +609,7 @@ xfs_ioc_space(
 {
 	struct iattr		iattr;
 	enum xfs_prealloc_flags	flags = 0;
+	uint			iolock = XFS_IOLOCK_EXCL;
 	int			error;
 
 	/*
@@ -636,7 +638,10 @@ xfs_ioc_space(
 	if (error)
 		return error;
 
-	xfs_ilock(ip, XFS_IOLOCK_EXCL);
+	xfs_ilock(ip, iolock);
+	error = xfs_break_layouts(inode, &iolock);
+	if (error)
+		goto out_unlock;
 
 	switch (bf->l_whence) {
 	case 0: /*SEEK_SET*/
@@ -725,7 +730,7 @@ xfs_ioc_space(
 	error = xfs_update_prealloc_flags(ip, flags);
 
 out_unlock:
-	xfs_iunlock(ip, XFS_IOLOCK_EXCL);
+	xfs_iunlock(ip, iolock);
 	mnt_drop_write_file(filp);
 	return error;
 }
diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
index 6ff84e8..b1e849a 100644
--- a/fs/xfs/xfs_iops.c
+++ b/fs/xfs/xfs_iops.c
@@ -37,6 +37,7 @@
 #include "xfs_da_btree.h"
 #include "xfs_dir2.h"
 #include "xfs_trans_space.h"
+#include "xfs_pnfs.h"
 
 #include <linux/capability.h>
 #include <linux/xattr.h>
@@ -970,9 +971,13 @@ xfs_vn_setattr(
 	int			error;
 
 	if (iattr->ia_valid & ATTR_SIZE) {
-		xfs_ilock(ip, XFS_IOLOCK_EXCL);
-		error = xfs_setattr_size(ip, iattr);
-		xfs_iunlock(ip, XFS_IOLOCK_EXCL);
+		uint		iolock = XFS_IOLOCK_EXCL;
+
+		xfs_ilock(ip, iolock);
+		error = xfs_break_layouts(dentry->d_inode, &iolock);
+		if (!error)
+			error = xfs_setattr_size(ip, iattr);
+		xfs_iunlock(ip, iolock);
 	} else {
 		error = xfs_setattr_nonsize(ip, iattr, 0);
 	}
diff --git a/fs/xfs/xfs_pnfs.c b/fs/xfs/xfs_pnfs.c
index 5d25f5d..f2bbc2f 100644
--- a/fs/xfs/xfs_pnfs.c
+++ b/fs/xfs/xfs_pnfs.c
@@ -17,6 +17,37 @@
 #include "xfs_shared.h"
 #include "xfs_pnfs.h"
 
+/*
+ * Ensure that we do not have any outstanding pNFS layouts that can be
+ * used by clients to directly read from or write to this inode.
+ * This must be called before every operation that can remove blocks
+ * from the extent map.  Additionally we call it during the write
+ * operation, where aren't concerned about exposing unallocated blocks
+ * but just want to provide basic synchronization between a local
+ * writer and pNFS clients.  mmap writes would also benefit from
+ * this sort of synchronization, but due to the tricky locking
+ * rules in the page fault path we don't bother.
+ */
+int
+xfs_break_layouts(
+	struct inode		*inode,
+	uint			*iolock)
+{
+	struct xfs_inode	*ip = XFS_I(inode);
+	int			error;
+
+	ASSERT(xfs_isilocked(ip, XFS_IOLOCK_SHARED|XFS_IOLOCK_EXCL));
+
+	while ((error = break_layout(inode, false) == -EWOULDBLOCK)) {
+		xfs_iunlock(ip, *iolock);
+		error = break_layout(inode, true);
+		*iolock = XFS_IOLOCK_EXCL;
+		xfs_ilock(ip, *iolock);
+	}
+
+	return error;
+}
+
 int
 xfs_fs_get_uuid(
 	struct super_block	*sb,
diff --git a/fs/xfs/xfs_pnfs.h b/fs/xfs/xfs_pnfs.h
index 0d91255..b7fbfce 100644
--- a/fs/xfs/xfs_pnfs.h
+++ b/fs/xfs/xfs_pnfs.h
@@ -7,5 +7,12 @@ int xfs_fs_map_blocks(struct inode *inode, loff_t offset, u64 length,
 		struct iomap *iomap, bool write, u32 *device_generation);
 int xfs_fs_commit_blocks(struct inode *inode, struct iomap *maps, int nr_maps,
 		struct iattr *iattr);
+
+int xfs_break_layouts(struct inode *inode, uint *iolock);
+#else
+static inline int xfs_break_layouts(struct inode *inode, uint *iolock)
+{
+	return 0;
+}
 #endif /* CONFIG_NFSD_PNFS */
 #endif /* _XFS_PNFS_H */
-- 
1.9.1

