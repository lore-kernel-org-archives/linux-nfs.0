Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:9888 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752173AbdHBUvt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Aug 2017 16:51:49 -0400
From: Anna.Schumaker@Netapp.com
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] NFS: Create NFS_ACCESS_* flags
Date: Wed,  2 Aug 2017 16:51:25 -0400
Message-ID: <20170802205126.23239-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Passing the NFS v4 flags into the v3 code seems weird to me, even if
they are defined to the same values.  This patch adds in generic flags
to help me feel better

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/dir.c           | 16 ++++++++--------
 include/linux/nfs_fs.h | 10 ++++++++++
 2 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3522b1249019..84de36be286d 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2372,15 +2372,15 @@ void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *set)
 }
 EXPORT_SYMBOL_GPL(nfs_access_add_cache);
 
-#define NFS_MAY_READ (NFS4_ACCESS_READ)
-#define NFS_MAY_WRITE (NFS4_ACCESS_MODIFY | \
-		NFS4_ACCESS_EXTEND | \
-		NFS4_ACCESS_DELETE)
-#define NFS_FILE_MAY_WRITE (NFS4_ACCESS_MODIFY | \
-		NFS4_ACCESS_EXTEND)
+#define NFS_MAY_READ (NFS_ACCESS_READ)
+#define NFS_MAY_WRITE (NFS_ACCESS_MODIFY | \
+		NFS_ACCESS_EXTEND | \
+		NFS_ACCESS_DELETE)
+#define NFS_FILE_MAY_WRITE (NFS_ACCESS_MODIFY | \
+		NFS_ACCESS_EXTEND)
 #define NFS_DIR_MAY_WRITE NFS_MAY_WRITE
-#define NFS_MAY_LOOKUP (NFS4_ACCESS_LOOKUP)
-#define NFS_MAY_EXECUTE (NFS4_ACCESS_EXECUTE)
+#define NFS_MAY_LOOKUP (NFS_ACCESS_LOOKUP)
+#define NFS_MAY_EXECUTE (NFS_ACCESS_EXECUTE)
 static int
 nfs_access_calc_mask(u32 access_result, umode_t umode)
 {
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 5cc91d6381a3..d8f3879854a1 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -184,6 +184,16 @@ struct nfs_inode {
 };
 
 /*
+ * Access bit flags
+ */
+#define NFS_ACCESS_READ        0x0001
+#define NFS_ACCESS_LOOKUP      0x0002
+#define NFS_ACCESS_MODIFY      0x0004
+#define NFS_ACCESS_EXTEND      0x0008
+#define NFS_ACCESS_DELETE      0x0010
+#define NFS_ACCESS_EXECUTE     0x0020
+
+/*
  * Cache validity bit flags
  */
 #define NFS_INO_INVALID_ATTR	0x0001		/* cached attrs are invalid */
-- 
2.13.3

