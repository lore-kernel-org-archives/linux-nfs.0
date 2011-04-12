Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:52350 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753303Ab1DLJSU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Apr 2011 05:18:20 -0400
From: Dave Chinner <david@fromorbit.com>
To: torvalds@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        simoneau@ele.uri.edu
Subject: [PATCH] nfs: don't call __mark_inode_dirty while holding i_lock
Date: Tue, 12 Apr 2011 19:18:08 +1000
Message-Id: <1302599888-21458-1-git-send-email-david@fromorbit.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Dave Chinner <dchinner@redhat.com>

nfs_scan_commit() is called with the inode->i_lock held, but it then
calls __mark_inode_dirty() while still holding the lock. This causes
a deadlock.

Push the inode->i_lock into nfs_scan_commit() so it can protect only
the parts of the code it needs to and can be dropped before the call
to __mark_inode_dirty() to avoid the deadlock.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
Tested-by: Will Simoneau <simoneau@ele.uri.edu>
---
 fs/nfs/write.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index af0c627..e4cbc11 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -542,11 +542,15 @@ nfs_scan_commit(struct inode *inode, struct list_head *dst, pgoff_t idx_start, u
 	if (!nfs_need_commit(nfsi))
 		return 0;
 
+	spin_lock(&inode->i_lock);
 	ret = nfs_scan_list(nfsi, dst, idx_start, npages, NFS_PAGE_TAG_COMMIT);
 	if (ret > 0)
 		nfsi->ncommit -= ret;
+	spin_unlock(&inode->i_lock);
+
 	if (nfs_need_commit(NFS_I(inode)))
 		__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
+
 	return ret;
 }
 #else
@@ -1483,9 +1487,7 @@ int nfs_commit_inode(struct inode *inode, int how)
 	res = nfs_commit_set_lock(NFS_I(inode), may_wait);
 	if (res <= 0)
 		goto out_mark_dirty;
-	spin_lock(&inode->i_lock);
 	res = nfs_scan_commit(inode, &head, 0, 0);
-	spin_unlock(&inode->i_lock);
 	if (res) {
 		int error;
 
-- 
1.7.2.3

