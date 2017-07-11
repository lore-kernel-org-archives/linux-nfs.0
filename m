Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:32943 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933186AbdGKVym (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Jul 2017 17:54:42 -0400
Received: by mail-io0-f195.google.com with SMTP id z62so486878ioi.0
        for <linux-nfs@vger.kernel.org>; Tue, 11 Jul 2017 14:54:41 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] NFS: Be more careful about mapping file permissions
Date: Tue, 11 Jul 2017 17:54:35 -0400
Message-Id: <20170711215435.18736-4-trond.myklebust@primarydata.com>
In-Reply-To: <20170711215435.18736-3-trond.myklebust@primarydata.com>
References: <20170711215435.18736-1-trond.myklebust@primarydata.com>
 <20170711215435.18736-2-trond.myklebust@primarydata.com>
 <20170711215435.18736-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When mapping a directory, we want the MAY_WRITE permissions to reflect
whether or not we have permission to modify, add and delete the directory
entries. MAY_EXEC must map to lookup permissions.

On the other hand, for files, we want MAY_WRITE to reflect a permission
to modify and extend the file.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c | 25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 21c2f7918ec7..a2bd6f03818e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2366,21 +2366,30 @@ EXPORT_SYMBOL_GPL(nfs_access_add_cache);
 #define NFS_MAY_WRITE (NFS4_ACCESS_MODIFY | \
 		NFS4_ACCESS_EXTEND | \
 		NFS4_ACCESS_DELETE)
+#define NFS_FILE_MAY_WRITE (NFS4_ACCESS_MODIFY | \
+		NFS4_ACCESS_EXTEND)
+#define NFS_DIR_MAY_WRITE NFS_MAY_WRITE
 #define NFS_MAY_LOOKUP (NFS4_ACCESS_LOOKUP)
 #define NFS_MAY_EXECUTE (NFS4_ACCESS_EXECUTE)
 static int
-nfs_access_calc_mask(u32 access_result)
+nfs_access_calc_mask(u32 access_result, umode_t umode)
 {
 	int mask = 0;
 
 	if (access_result & NFS_MAY_READ)
 		mask |= MAY_READ;
-	if (access_result & NFS_MAY_WRITE)
-		mask |= MAY_WRITE;
-	if (access_result & NFS_MAY_LOOKUP)
-		mask |= MAY_EXEC;
-	if (access_result & NFS_MAY_EXECUTE)
-		mask |= MAY_EXEC;
+	if (S_ISDIR(umode)) {
+		if ((access_result & NFS_DIR_MAY_WRITE) == NFS_DIR_MAY_WRITE)
+			mask |= MAY_WRITE;
+		if ((access_result & NFS_MAY_LOOKUP) == NFS_MAY_LOOKUP)
+			mask |= MAY_EXEC;
+	} else if (S_ISREG(umode)) {
+		if ((access_result & NFS_FILE_MAY_WRITE) == NFS_FILE_MAY_WRITE)
+			mask |= MAY_WRITE;
+		if ((access_result & NFS_MAY_EXECUTE) == NFS_MAY_EXECUTE)
+			mask |= MAY_EXEC;
+	} else if (access_result & NFS_MAY_WRITE)
+			mask |= MAY_WRITE;
 	return mask;
 }
 
@@ -2425,7 +2434,7 @@ static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
 	}
 	nfs_access_add_cache(inode, &cache);
 out_cached:
-	cache_mask = nfs_access_calc_mask(cache.mask);
+	cache_mask = nfs_access_calc_mask(cache.mask, inode->i_mode);
 	if ((mask & ~cache_mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) != 0)
 		status = -EACCES;
 out:
-- 
2.13.0

