Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:39353 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751541AbeCTUx5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 16:53:57 -0400
Received: by mail-io0-f195.google.com with SMTP id v13so4037660iob.6
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 13:53:57 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] NFS: Convert NFS_INO_INVALID flags to unsigned long
Date: Tue, 20 Mar 2018 16:53:27 -0400
Message-Id: <20180320205332.94132-2-trond.myklebust@primarydata.com>
In-Reply-To: <20180320205332.94132-1-trond.myklebust@primarydata.com>
References: <20180320205332.94132-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The cache validity attribute is unsigned long, so make sure that
the flags are too.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/nfs_fs.h | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 38187c68063d..4afb11be73f4 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -198,14 +198,14 @@ struct nfs_inode {
 /*
  * Cache validity bit flags
  */
-#define NFS_INO_INVALID_ATTR	0x0001		/* cached attrs are invalid */
-#define NFS_INO_INVALID_DATA	0x0002		/* cached data is invalid */
-#define NFS_INO_INVALID_ATIME	0x0004		/* cached atime is invalid */
-#define NFS_INO_INVALID_ACCESS	0x0008		/* cached access cred invalid */
-#define NFS_INO_INVALID_ACL	0x0010		/* cached acls are invalid */
-#define NFS_INO_REVAL_PAGECACHE	0x0020		/* must revalidate pagecache */
-#define NFS_INO_REVAL_FORCED	0x0040		/* force revalidation ignoring a delegation */
-#define NFS_INO_INVALID_LABEL	0x0080		/* cached label is invalid */
+#define NFS_INO_INVALID_ATTR	BIT(0)		/* cached attrs are invalid */
+#define NFS_INO_INVALID_DATA	BIT(1)		/* cached data is invalid */
+#define NFS_INO_INVALID_ATIME	BIT(2)		/* cached atime is invalid */
+#define NFS_INO_INVALID_ACCESS	BIT(3)		/* cached access cred invalid */
+#define NFS_INO_INVALID_ACL	BIT(4)		/* cached acls are invalid */
+#define NFS_INO_REVAL_PAGECACHE	BIT(5)		/* must revalidate pagecache */
+#define NFS_INO_REVAL_FORCED	BIT(6)		/* force revalidation ignoring a delegation */
+#define NFS_INO_INVALID_LABEL	BIT(7)		/* cached label is invalid */
 
 /*
  * Bit offsets in flags field
-- 
2.14.3

