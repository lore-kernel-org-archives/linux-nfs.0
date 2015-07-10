Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:9341 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933308AbbGJU74 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 16:59:56 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH 8/9] NFS: Rename nfs_commit_unstable_pages() to nfs_write_inode()
Date: Fri, 10 Jul 2015 16:58:16 -0400
Message-ID: <1436561897-8051-9-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1436561897-8051-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1436561897-8051-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All nfs_write_inode() does is pass its arguments to
nfs_commit_unstable_pages().  Let's cut out the middle man and have
nfs_write_pages() do the work directly.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/write.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 359e9ad..c2dad4f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1789,7 +1789,7 @@ out_mark_dirty:
 	return res;
 }
 
-static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_control *wbc)
+int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int flags = FLUSH_SYNC;
@@ -1824,11 +1824,6 @@ out_mark_dirty:
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 	return ret;
 }
-
-int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
-{
-	return nfs_commit_unstable_pages(inode, wbc);
-}
 EXPORT_SYMBOL_GPL(nfs_write_inode);
 
 /*
-- 
2.4.5

