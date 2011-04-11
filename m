Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:55250 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750696Ab1DKECn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Apr 2011 00:02:43 -0400
Date: Mon, 11 Apr 2011 14:02:09 +1000
From: Dave Chinner <david@fromorbit.com>
To: Will Simoneau <simoneau@ele.uri.edu>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: lockdep splat: nfsroot on 2.6.39-rc2
Message-ID: <20110411040209.GA21395@dastard>
References: <20110410025502.GA15112@ele.uri.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110410025502.GA15112@ele.uri.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Apr 09, 2011 at 10:55:02PM -0400, Will Simoneau wrote:
> Hi,
> 
> I just got this soft-lockup 3 times in a row and was able to reproduce
> it with lockdep enabled. The kernel is Linus git 94c8a984 plus patches
> to support my hardware. System is a full custom 2-way SMP mipsel/R4K
> clone on an FPGA, I am hoping this is not my fault or the hardware's
> fault though. Root is on NFS (tcp).
> 
> This seems to happen consistently when running "apt-get update". Ideas?
> Known bug?

The bug is in nfs_commit_inode(), where it calls nfs_scan_commit()
with the inode->i_lock held and that calls __mark_inode_dirty()
which takes the inode->i_lock....

The patch below should fix this problem.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com


nfs: don't call __mark_inode_dirty while holding i_lock

From: Dave Chinner <dchinner@redhat.com>

nfs_scan_commit() is called with the inode->i_lock held, but it then calls
__mark_inode_dirty() while still holding the lock. This causes a deadlock.

Move the __mark_inode_dirty() call outside nfs_scan_commit() and the
inode->i_lock to avoid the deadlock.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
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
 
