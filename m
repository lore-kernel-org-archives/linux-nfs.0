Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34642 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752554AbcLQS1X (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Dec 2016 13:27:23 -0500
Received: by mail-it0-f65.google.com with SMTP id 75so6187422ite.1
        for <linux-nfs@vger.kernel.org>; Sat, 17 Dec 2016 10:27:23 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 8/9] NFS: Remove unused function nfs_revalidate_inode_rcu()
Date: Sat, 17 Dec 2016 13:27:10 -0500
Message-Id: <20161217182711.10643-9-trond.myklebust@primarydata.com>
In-Reply-To: <20161217182711.10643-8-trond.myklebust@primarydata.com>
References: <20161217182711.10643-1-trond.myklebust@primarydata.com>
 <20161217182711.10643-2-trond.myklebust@primarydata.com>
 <20161217182711.10643-3-trond.myklebust@primarydata.com>
 <20161217182711.10643-4-trond.myklebust@primarydata.com>
 <20161217182711.10643-5-trond.myklebust@primarydata.com>
 <20161217182711.10643-6-trond.myklebust@primarydata.com>
 <20161217182711.10643-7-trond.myklebust@primarydata.com>
 <20161217182711.10643-8-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c         | 9 ---------
 include/linux/nfs_fs.h | 1 -
 2 files changed, 10 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e3194aa797f7..8224e96b5808 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1105,15 +1105,6 @@ int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 }
 EXPORT_SYMBOL_GPL(nfs_revalidate_inode);
 
-int nfs_revalidate_inode_rcu(struct nfs_server *server, struct inode *inode)
-{
-	if (!(NFS_I(inode)->cache_validity &
-			(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_LABEL))
-			&& !nfs_attribute_cache_expired(inode))
-		return NFS_STALE(inode) ? -ESTALE : 0;
-	return -ECHILD;
-}
-
 static int nfs_invalidate_mapping(struct inode *inode, struct address_space *mapping)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index cb631973839a..fe2e7810ae80 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -343,7 +343,6 @@ extern int nfs_open(struct inode *, struct file *);
 extern int nfs_attribute_timeout(struct inode *inode);
 extern int nfs_attribute_cache_expired(struct inode *inode);
 extern int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode);
-extern int nfs_revalidate_inode_rcu(struct nfs_server *server, struct inode *inode);
 extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
 extern bool nfs_mapping_need_revalidate_inode(struct inode *inode);
 extern int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
-- 
2.9.3

