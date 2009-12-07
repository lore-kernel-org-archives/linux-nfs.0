From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 07/35] pnfsd: define pnfs_export_operations
Date: Mon,  7 Dec 2009 11:31:17 +0200
Message-ID: <1260178277-14887-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	Fred Isaman <iisaman@citi.umich.edu>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

struct pnfs_export_operations defines the VFS level API for pNFS,
not including callbacks.  A pnfs-exportable filesystem sets
a pointer to its pnfs export vector in its struct super_block.s_pnfs_op.

The file system provides the per-superblock layout_type method that
determines if it supports pnfs for the filesystem identified by
the superblock, and if so, with which layout type (only one per-sb is
supported).

Device ops:
get_device_iter is used to fill-in the device list for GETDEVICELIST
and get_device_info is used to encode the device info for GETDEVICEINFO.

Layout ops:
layout_get, layout_commit, and layout_return implement the file system- and
layout type- specific parts of their respective protocol operations: LAYOUTGET,
LAYOUTCOMMIT, and LAYOUTRETURN.

Note: define pnfs export operations in a stub form in this patch.
Actual operations are defined along with their usage.

Note: the following methods are mandatory to be implemented:
layout_type, get_device_info, and layout_get.

[pnfsd: provide default no-op operations]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: compile fixes for pnfsd branch]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[gfs2: set pnfs_dlm_export_ops only for CONFIG_PNFSD]
[pnfsd: handle s_pnfs_op==NULL]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/export.c                |    1 +
 include/linux/fs.h              |    2 ++
 include/linux/nfsd/nfsd4_pnfs.h |   14 ++++++++++++++
 3 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index cd377a7..f82ed90 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -18,6 +18,7 @@
 #include <linux/module.h>
 #include <linux/exportfs.h>
 
+#include <linux/nfsd/nfsd4_pnfs.h>
 #include <linux/nfsd/syscall.h>
 #include <net/ipv6.h>
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2620a8c..9a9beb8 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -382,6 +382,7 @@ struct inodes_stat_t {
 #include <asm/byteorder.h>
 
 struct export_operations;
+struct pnfs_export_operations;
 struct hd_geometry;
 struct iovec;
 struct nameidata;
@@ -1325,6 +1326,7 @@ struct super_block {
 	const struct dquot_operations	*dq_op;
 	const struct quotactl_ops	*s_qcop;
 	const struct export_operations *s_export_op;
+	const struct pnfs_export_operations *s_pnfs_op;
 	unsigned long		s_flags;
 	unsigned long		s_magic;
 	struct dentry		*s_root;
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index 9e7d95e..ff6613e 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -34,4 +34,18 @@
 #ifndef _LINUX_NFSD_NFSD4_PNFS_H
 #define _LINUX_NFSD_NFSD4_PNFS_H
 
+/*
+ * pNFS export operations vector.
+ *
+ * The filesystem must implement the following methods:
+ *   layout_type
+ *   get_device_info
+ *   layout_get
+ *
+ * All other methods are optional and can be set to NULL if not implemented.
+ */
+struct pnfs_export_operations {
+	/* stub */
+};
+
 #endif /* _LINUX_NFSD_NFSD4_PNFS_H */
-- 
1.6.5.1

