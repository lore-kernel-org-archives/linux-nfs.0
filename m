Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53704 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759076Ab2JYSHN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Oct 2012 14:07:13 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS: fix comment describing nfs_kill_super
Date: Thu, 25 Oct 2012 14:07:13 -0400
Message-Id: <1351188433-10164-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_kill_super is also used by v4.x

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/super.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e831bce..5c8249a 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2499,7 +2499,7 @@ void nfs_put_super(struct super_block *s)
 EXPORT_SYMBOL_GPL(nfs_put_super);
 
 /*
- * Destroy an NFS2/3 superblock
+ * Destroy an NFS superblock
  */
 void nfs_kill_super(struct super_block *s)
 {
-- 
1.7.9.6 (Apple Git-31.1)

