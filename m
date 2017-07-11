Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36237 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933186AbdGKVyj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Jul 2017 17:54:39 -0400
Received: by mail-io0-f196.google.com with SMTP id h134so488465iof.3
        for <linux-nfs@vger.kernel.org>; Tue, 11 Jul 2017 14:54:39 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] NFS: Refactor NFS access to kernel access mask calculation
Date: Tue, 11 Jul 2017 17:54:32 -0400
Message-Id: <20170711215435.18736-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c | 31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2ac00bf4ecf1..13f9ec3d4d8e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2362,16 +2362,31 @@ void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *set)
 }
 EXPORT_SYMBOL_GPL(nfs_access_add_cache);
 
+#define NFS_MAY_READ (NFS4_ACCESS_READ)
+#define NFS_MAY_WRITE (NFS4_ACCESS_MODIFY | \
+		NFS4_ACCESS_EXTEND | \
+		NFS4_ACCESS_DELETE)
+#define NFS_MAY_LOOKUP (NFS4_ACCESS_LOOKUP)
+#define NFS_MAY_EXECUTE (NFS4_ACCESS_EXECUTE)
+static int
+nfs_access_calc_mask(u32 access_result)
+{
+	int mask = 0;
+
+	if (access_result & NFS_MAY_READ)
+		mask |= MAY_READ;
+	if (access_result & NFS_MAY_WRITE)
+		mask |= MAY_WRITE;
+	if (access_result & NFS_MAY_LOOKUP)
+		mask |= MAY_EXEC;
+	if (access_result & NFS_MAY_EXECUTE)
+		mask |= MAY_EXEC;
+	return mask;
+}
+
 void nfs_access_set_mask(struct nfs_access_entry *entry, u32 access_result)
 {
-	entry->mask = 0;
-	if (access_result & NFS4_ACCESS_READ)
-		entry->mask |= MAY_READ;
-	if (access_result &
-	    (NFS4_ACCESS_MODIFY | NFS4_ACCESS_EXTEND | NFS4_ACCESS_DELETE))
-		entry->mask |= MAY_WRITE;
-	if (access_result & (NFS4_ACCESS_LOOKUP|NFS4_ACCESS_EXECUTE))
-		entry->mask |= MAY_EXEC;
+	entry->mask = nfs_access_calc_mask(access_result);
 }
 EXPORT_SYMBOL_GPL(nfs_access_set_mask);
 
-- 
2.13.0

