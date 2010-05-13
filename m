Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63543 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753389Ab0EMVI3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 17:08:29 -0400
Received: from localhost.localdomain (heimdal.trondhjem.org [10.58.49.73] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4DL8MCU021257
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 14:08:28 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/15] NFS: Don't call iput() in nfs_access_cache_shrinker
Date: Thu, 13 May 2010 17:08:17 -0400
Message-Id: <1273784901-25599-11-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1273784901-25599-10-git-send-email-Trond.Myklebust@netapp.com>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-4-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-5-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-6-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-7-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-8-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-9-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-10-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

iput() can potentially attempt to allocate memory, so we should avoid
calling it in a memory shrinker. Instead, rely on the fact that iput() will
call nfs_access_zap_cache().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |   19 ++++---------------
 1 files changed, 4 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 5582e9d..7bf20be 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1716,22 +1716,14 @@ int nfs_access_cache_shrinker(int nr_to_scan, gfp_t gfp_mask)
 
 	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
 		return -1;
-restart:
+
 	spin_lock(&nfs_access_lru_lock);
 	list_for_each_entry(nfsi, &nfs_access_lru_list, access_cache_inode_lru) {
-		struct rw_semaphore *s_umount;
 		struct inode *inode;
 
 		if (nr_to_scan-- == 0)
 			break;
-		s_umount = &nfsi->vfs_inode.i_sb->s_umount;
-		if (!down_read_trylock(s_umount))
-			continue;
-		inode = igrab(&nfsi->vfs_inode);
-		if (inode == NULL) {
-			up_read(s_umount);
-			continue;
-		}
+		inode = &nfsi->vfs_inode;
 		spin_lock(&inode->i_lock);
 		if (list_empty(&nfsi->access_cache_entry_lru))
 			goto remove_lru_entry;
@@ -1745,13 +1737,10 @@ restart:
 		else {
 remove_lru_entry:
 			list_del_init(&nfsi->access_cache_inode_lru);
+			smp_mb__before_clear_bit();
 			clear_bit(NFS_INO_ACL_LRU_SET, &nfsi->flags);
+			smp_mb__after_clear_bit();
 		}
-		spin_unlock(&inode->i_lock);
-		spin_unlock(&nfs_access_lru_lock);
-		iput(inode);
-		up_read(s_umount);
-		goto restart;
 	}
 	spin_unlock(&nfs_access_lru_lock);
 	nfs_access_free_list(&head);
-- 
1.6.6.1

