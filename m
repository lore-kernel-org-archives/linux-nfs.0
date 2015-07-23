Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:35639 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405AbbGWStI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jul 2015 14:49:08 -0400
Received: by obbop1 with SMTP id op1so1359715obb.2
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2015 11:49:07 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFS: nfs_mark_for_revalidate should always set NFS_INO_REVAL_PAGECACHE
Date: Thu, 23 Jul 2015 14:49:01 -0400
Message-Id: <1437677341-2943-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1437677341-2943-4-git-send-email-trond.myklebust@primarydata.com>
References: <1437677341-2943-1-git-send-email-trond.myklebust@primarydata.com>
 <1437677341-2943-2-git-send-email-trond.myklebust@primarydata.com>
 <1437677341-2943-3-git-send-email-trond.myklebust@primarydata.com>
 <1437677341-2943-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm not aware of any existing bugs around this, but the expectation is
that nfs_mark_for_revalidate() should always force a revalidation of
the cached metadata.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/nfs_fs.h | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index f91b5ade30c9..874b77228fb9 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -292,9 +292,12 @@ static inline void nfs_mark_for_revalidate(struct inode *inode)
 	struct nfs_inode *nfsi = NFS_I(inode);
 
 	spin_lock(&inode->i_lock);
-	nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS;
+	nfsi->cache_validity |= NFS_INO_INVALID_ATTR |
+				NFS_INO_REVAL_PAGECACHE |
+				NFS_INO_INVALID_ACCESS |
+				NFS_INO_INVALID_ACL;
 	if (S_ISDIR(inode->i_mode))
-		nfsi->cache_validity |= NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_DATA;
+		nfsi->cache_validity |= NFS_INO_INVALID_DATA;
 	spin_unlock(&inode->i_lock);
 }
 
-- 
2.4.3

