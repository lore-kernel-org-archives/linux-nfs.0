Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35668 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934170AbdGKVyl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Jul 2017 17:54:41 -0400
Received: by mail-io0-f194.google.com with SMTP id 84so484808iop.2
        for <linux-nfs@vger.kernel.org>; Tue, 11 Jul 2017 14:54:41 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] NFS: Store the raw NFS access mask in the inode's access cache
Date: Tue, 11 Jul 2017 17:54:34 -0400
Message-Id: <20170711215435.18736-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170711215435.18736-2-trond.myklebust@primarydata.com>
References: <20170711215435.18736-1-trond.myklebust@primarydata.com>
 <20170711215435.18736-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c           | 9 ++++++---
 include/linux/nfs_fs.h | 2 +-
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 13f9ec3d4d8e..21c2f7918ec7 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2386,7 +2386,7 @@ nfs_access_calc_mask(u32 access_result)
 
 void nfs_access_set_mask(struct nfs_access_entry *entry, u32 access_result)
 {
-	entry->mask = nfs_access_calc_mask(access_result);
+	entry->mask = access_result;
 }
 EXPORT_SYMBOL_GPL(nfs_access_set_mask);
 
@@ -2394,6 +2394,7 @@ static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
 {
 	struct nfs_access_entry cache;
 	bool may_block = (mask & MAY_NOT_BLOCK) == 0;
+	int cache_mask;
 	int status;
 
 	trace_nfs_access_enter(inode);
@@ -2409,7 +2410,8 @@ static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
 		goto out;
 
 	/* Be clever: ask server to check for all possible rights */
-	cache.mask = MAY_EXEC | MAY_WRITE | MAY_READ;
+	cache.mask = NFS_MAY_LOOKUP | NFS_MAY_EXECUTE
+		     | NFS_MAY_WRITE | NFS_MAY_READ;
 	cache.cred = cred;
 	cache.jiffies = jiffies;
 	status = NFS_PROTO(inode)->access(inode, &cache);
@@ -2423,7 +2425,8 @@ static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
 	}
 	nfs_access_add_cache(inode, &cache);
 out_cached:
-	if ((mask & ~cache.mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) != 0)
+	cache_mask = nfs_access_calc_mask(cache.mask);
+	if ((mask & ~cache_mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) != 0)
 		status = -EACCES;
 out:
 	trace_nfs_access_exit(inode, status);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index bb0eb2c9acca..909212fc0dd0 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -51,7 +51,7 @@ struct nfs_access_entry {
 	struct list_head	lru;
 	unsigned long		jiffies;
 	struct rpc_cred *	cred;
-	int			mask;
+	__u32			mask;
 	struct rcu_head		rcu_head;
 };
 
-- 
2.13.0

