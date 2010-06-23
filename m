From: andros@netapp.com
Subject: [PATCH 09/10] SQUASHME: pnfs-submit: don't re-initialize i_lock
Date: Wed, 23 Jun 2010 15:21:17 -0400
Message-ID: <1277320878-3726-10-git-send-email-andros@netapp.com>
References: <1277320878-3726-1-git-send-email-andros@netapp.com>
 <1277320878-3726-2-git-send-email-andros@netapp.com>
 <1277320878-3726-3-git-send-email-andros@netapp.com>
 <1277320878-3726-4-git-send-email-andros@netapp.com>
 <1277320878-3726-5-git-send-email-andros@netapp.com>
 <1277320878-3726-6-git-send-email-andros@netapp.com>
 <1277320878-3726-7-git-send-email-andros@netapp.com>
 <1277320878-3726-8-git-send-email-andros@netapp.com>
 <1277320878-3726-9-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5004 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449Ab0FWTWa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jun 2010 15:22:30 -0400
In-Reply-To: <1277320878-3726-9-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Initialized in the VFS (inode_init_always)

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/inode.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index d6dd6e5..7989dea 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1420,7 +1420,6 @@ static void pnfs_init_once(struct nfs_inode *nfsi)
 {
 #ifdef CONFIG_NFS_V4_1
 	init_waitqueue_head(&nfsi->lo_waitq);
-	spin_lock_init(&nfsi->vfs_inode.i_lock);
 	seqlock_init(&nfsi->layout.seqlock);
 	INIT_LIST_HEAD(&nfsi->layout.lo_layouts);
 	INIT_LIST_HEAD(&nfsi->layout.segs);
-- 
1.6.6

