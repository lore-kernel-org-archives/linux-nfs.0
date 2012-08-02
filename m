Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:36320 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039Ab2HBSbD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Aug 2012 14:31:03 -0400
Received: by yhmm54 with SMTP id m54so9066694yhm.19
        for <linux-nfs@vger.kernel.org>; Thu, 02 Aug 2012 11:31:02 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: bjschuma@netapp.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: tear down caches in nfs_init_writepagecache when allocation fails
Date: Thu,  2 Aug 2012 14:30:56 -0400
Message-Id: <1343932256-14217-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and ensure that we tear down the nfs_commit_data cache too when
unloading the module.

Cc: Bryan Schumaker <bjschuma@netapp.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/write.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 6106ae6..e1f717d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1835,19 +1835,19 @@ int __init nfs_init_writepagecache(void)
 	nfs_wdata_mempool = mempool_create_slab_pool(MIN_POOL_WRITE,
 						     nfs_wdata_cachep);
 	if (nfs_wdata_mempool == NULL)
-		return -ENOMEM;
+		goto out_destroy_write_cache;
 
 	nfs_cdata_cachep = kmem_cache_create("nfs_commit_data",
 					     sizeof(struct nfs_commit_data),
 					     0, SLAB_HWCACHE_ALIGN,
 					     NULL);
 	if (nfs_cdata_cachep == NULL)
-		return -ENOMEM;
+		goto out_destroy_write_mempool;
 
 	nfs_commit_mempool = mempool_create_slab_pool(MIN_POOL_COMMIT,
 						      nfs_wdata_cachep);
 	if (nfs_commit_mempool == NULL)
-		return -ENOMEM;
+		goto out_destroy_commit_cache;
 
 	/*
 	 * NFS congestion size, scale with available memory.
@@ -1870,11 +1870,20 @@ int __init nfs_init_writepagecache(void)
 		nfs_congestion_kb = 256*1024;
 
 	return 0;
+
+out_destroy_commit_cache:
+	kmem_cache_destroy(nfs_cdata_cachep);
+out_destroy_write_mempool:
+	mempool_destroy(nfs_wdata_mempool);
+out_destroy_write_cache:
+	kmem_cache_destroy(nfs_wdata_cachep);
+	return -ENOMEM;
 }
 
 void nfs_destroy_writepagecache(void)
 {
 	mempool_destroy(nfs_commit_mempool);
+	kmem_cache_destroy(nfs_cdata_cachep);
 	mempool_destroy(nfs_wdata_mempool);
 	kmem_cache_destroy(nfs_wdata_cachep);
 }
-- 
1.7.11.2

