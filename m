Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34280 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbcLDVwS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2016 16:52:18 -0500
Received: by mail-io0-f193.google.com with SMTP id r94so18765631ioe.1
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2016 13:52:18 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix incorrect mapping revalidation when holding a delegation
Date: Sun,  4 Dec 2016 16:52:14 -0500
Message-Id: <20161204215214.24024-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We should only care about checking the attributes if the page cache
is marked as dubious (using NFS_INO_REVAL_PAGECACHE) and the
NFS_INO_REVAL_FORCED flag is set.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 75f5a9cb2e66..df4d7ec348ed 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1114,9 +1114,15 @@ static int nfs_invalidate_mapping(struct inode *inode, struct address_space *map
 
 static bool nfs_mapping_need_revalidate_inode(struct inode *inode)
 {
-	if (nfs_have_delegated_attributes(inode))
-		return false;
-	return (NFS_I(inode)->cache_validity & NFS_INO_REVAL_PAGECACHE)
+	unsigned long cache_validity = NFS_I(inode)->cache_validity;
+
+	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_READ)) {
+		const unsigned long force_reval =
+			NFS_INO_REVAL_PAGECACHE|NFS_INO_REVAL_FORCED;
+		return (cache_validity & force_reval) == force_reval;
+	}
+
+	return (cache_validity & NFS_INO_REVAL_PAGECACHE)
 		|| nfs_attribute_timeout(inode)
 		|| NFS_STALE(inode);
 }
-- 
2.9.3

