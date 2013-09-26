Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:50407 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447Ab3IZSkS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:40:18 -0400
Received: by mail-qa0-f45.google.com with SMTP id k4so4622889qaq.18
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:40:18 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 06/49] pnfsd: define pnfs_export_operations
Date: Thu, 26 Sep 2013 14:40:15 -0400
Message-Id: <1380220815-12955-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

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

The following methods are mandatory to be implemented:
layout_type, get_device_info, and layout_get.

Note: define pnfs export operations in a stub form in this patch.
Actual operations are defined along with their usage.

[pnfsd: provide default no-op operations]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: compile fixes for pnfsd branch]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[gfs2: set pnfs_dlm_export_ops only for CONFIG_PNFSD]
[pnfsd: handle s_pnfs_op==NULL]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/export.c                |  2 +-
 include/linux/fs.h              |  2 ++
 include/linux/nfsd/nfsd4_pnfs.h | 14 ++++++++++++++
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 5f38ea3..f26b0b9 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -16,7 +16,7 @@
 #include <linux/module.h>
 #include <linux/exportfs.h>
 #include <linux/sunrpc/svc_xprt.h>
-
+#include <linux/nfsd/nfsd4_pnfs.h>
 #include <net/ipv6.h>
 
 #include "nfsd.h"
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3f40547..d9186a4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -34,6 +34,7 @@
 #include <uapi/linux/fs.h>
 
 struct export_operations;
+struct pnfs_export_operations;
 struct hd_geometry;
 struct iovec;
 struct nameidata;
@@ -1251,6 +1252,7 @@ struct super_block {
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
1.8.3.1

