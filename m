Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10485 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965104Ab2CVTTr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Mar 2012 15:19:47 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 11/11] NFSv4.1 check for NULL pnfs_layout_hdr in pnfs scan commit lists
Date: Thu, 22 Mar 2012 15:19:39 -0400
Message-Id: <1332443979-2302-12-git-send-email-andros@netapp.com>
In-Reply-To: <1332443979-2302-1-git-send-email-andros@netapp.com>
References: <1332443979-2302-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 442ebf6..3bd7e87 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -296,9 +296,10 @@ static inline int
 pnfs_scan_commit_lists(struct inode *inode, int max, spinlock_t *lock)
 {
 	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
+	struct pnfs_layout_hdr *lh = NFS_I(inode)->layout;
 	int ret;
 
-	if (ld == NULL || ld->scan_commit_lists == NULL)
+	if (ld == NULL || ld->scan_commit_lists == NULL || lh == NULL)
 		return 0;
 	ret = ld->scan_commit_lists(inode, max, lock);
 	if (ret != 0)
-- 
1.7.6.4

