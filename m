Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34453 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab2KLBhK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Nov 2012 20:37:10 -0500
From: ycnian@gmail.com
To: Trond.Myklebust@netapp.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH] nfs: Fix wrong slab cache in nfs_commit_mempool
Date: Mon, 12 Nov 2012 09:27:37 +0800
Message-Id: <1352683657-5191-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

The slab cache in nfs_commit_mempool is wrong, and I think it is just a slip.
I tested it on a x86-32 machine, the size of nfs_write_header is 544, and
the size of nfs_commit_data is 408, so it works fine. It is also true that
sizeof(struct nfs_write_header) > sizeof(struct nfs_commit_data) on other
platforms in my opinoin. Just fix it.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfs/write.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9347ab7..f710e39 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1829,7 +1829,7 @@ int __init nfs_init_writepagecache(void)
 		goto out_destroy_write_mempool;
 
 	nfs_commit_mempool = mempool_create_slab_pool(MIN_POOL_COMMIT,
-						      nfs_wdata_cachep);
+						      nfs_cdata_cachep);
 	if (nfs_commit_mempool == NULL)
 		goto out_destroy_commit_cache;
 
-- 
1.7.4.4

