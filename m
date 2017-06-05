Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:56368 "EHLO m12-13.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751336AbdFEICv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Jun 2017 04:02:51 -0400
From: Jia-Ju Bai <baijiaju1990@163.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] fs: nfs: Fix a sleep-in-atomic bug in nfs_access_add_cache
Date: Mon,  5 Jun 2017 16:05:04 +0800
Message-Id: <1496649904-1855-1-git-send-email-baijiaju1990@163.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The driver may sleep under a rcu read lock, and function call path is:
nfs_permission (acquire the lock by rcu_read_lock)
  nfs_do_access
    nfs_access_add_cache
      kmalloc(GFP_KERNEL) --> may sleep

To fix it, "GFP_KERNEL" is replaced with "GFP_ATOMIC".

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 fs/nfs/dir.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 32ccd77..7a074db 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2333,7 +2333,7 @@ static void nfs_access_add_rbtree(struct inode *inode, struct nfs_access_entry *
 
 void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *set)
 {
-	struct nfs_access_entry *cache = kmalloc(sizeof(*cache), GFP_KERNEL);
+	struct nfs_access_entry *cache = kmalloc(sizeof(*cache), GFP_ATOMIC);
 	if (cache == NULL)
 		return;
 	RB_CLEAR_NODE(&cache->rb_node);
-- 
1.7.9.5


