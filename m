Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f193.google.com ([209.85.192.193]:34008 "EHLO
	mail-pd0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576AbbDWJRy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2015 05:17:54 -0400
Received: by pdjp10 with SMTP id p10so4301012pdj.1
        for <linux-nfs@vger.kernel.org>; Thu, 23 Apr 2015 02:17:53 -0700 (PDT)
From: Firo Yang <firogm@gmail.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Firo Yang <firogm@gmail.com>
Subject: [PATCH] nfs: Remove unneeded casts in nfs
Date: Thu, 23 Apr 2015 17:17:51 +0800
Message-Id: <1429780671-5871-1-git-send-email-firogm@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't unnecessarily cast allocation return value in
fs/nfs/inode.c::nfs_alloc_inode().

Signed-off-by: Firo Yang <firogm@gmail.com>
---
 fs/nfs/inode.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index d42dff6..fc47d55 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1819,7 +1819,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 struct inode *nfs_alloc_inode(struct super_block *sb)
 {
 	struct nfs_inode *nfsi;
-	nfsi = (struct nfs_inode *)kmem_cache_alloc(nfs_inode_cachep, GFP_KERNEL);
+	nfsi = kmem_cache_alloc(nfs_inode_cachep, GFP_KERNEL);
 	if (!nfsi)
 		return NULL;
 	nfsi->flags = 0UL;
-- 
2.1.0

