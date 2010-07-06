From: andros@netapp.com
Subject: [PATCH 1/5] SQUASHME pnfs-submit: remove pnfs_init_once
Date: Tue,  6 Jul 2010 17:16:58 -0400
Message-ID: <1278451022-2889-2-git-send-email-andros@netapp.com>
References: <1278451022-2889-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61433 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754046Ab0GFURO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jul 2010 16:17:14 -0400
In-Reply-To: <1278451022-2889-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Place all layout initialization in nfs4_init_once

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/inode.c |   17 ++++++-----------
 1 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 7989dea..231cfa3 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1416,8 +1416,13 @@ void nfs_destroy_inode(struct inode *inode)
 	kmem_cache_free(nfs_inode_cachep, nfsi);
 }
 
-static void pnfs_init_once(struct nfs_inode *nfsi)
+static inline void nfs4_init_once(struct nfs_inode *nfsi)
 {
+#ifdef CONFIG_NFS_V4
+	INIT_LIST_HEAD(&nfsi->open_states);
+	nfsi->delegation = NULL;
+	nfsi->delegation_state = 0;
+	init_rwsem(&nfsi->rwsem);
 #ifdef CONFIG_NFS_V4_1
 	init_waitqueue_head(&nfsi->lo_waitq);
 	seqlock_init(&nfsi->layout.seqlock);
@@ -1426,15 +1431,6 @@ static void pnfs_init_once(struct nfs_inode *nfsi)
 	nfsi->layout.refcount = 0;
 	nfsi->layout.ld_data = NULL;
 #endif /* CONFIG_NFS_V4_1 */
-}
-
-static inline void nfs4_init_once(struct nfs_inode *nfsi)
-{
-#ifdef CONFIG_NFS_V4
-	INIT_LIST_HEAD(&nfsi->open_states);
-	nfsi->delegation = NULL;
-	nfsi->delegation_state = 0;
-	init_rwsem(&nfsi->rwsem);
 #endif
 }
 
@@ -1453,7 +1449,6 @@ static void init_once(void *foo)
 	INIT_HLIST_HEAD(&nfsi->silly_list);
 	init_waitqueue_head(&nfsi->waitqueue);
 	nfs4_init_once(nfsi);
-	pnfs_init_once(nfsi);
 }
 
 static int __init nfs_init_inodecache(void)
-- 
1.6.6

