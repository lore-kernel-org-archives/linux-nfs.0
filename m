Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31117 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030590Ab2CTQZu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Mar 2012 12:25:50 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/2] NFS: ncommit count is being double decremented
Date: Tue, 20 Mar 2012 12:25:46 -0400
Message-Id: <1332260746-8351-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1332260746-8351-1-git-send-email-iisaman@netapp.com>
References: <1332260746-8351-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The decrement is handled by each call to nfs_request_remove_commit_list,
no need to do it again in nfs_scan_commit.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0de19f4..e39ddfd 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -595,12 +595,9 @@ nfs_scan_commit(struct inode *inode, struct list_head *dst)
 	spin_lock(&inode->i_lock);
 	if (nfsi->ncommit > 0) {
 		const int max = INT_MAX;
-		int pnfs_ret;
 
 		ret = nfs_scan_commit_list(&nfsi->commit_list, dst, max);
-		pnfs_ret = pnfs_scan_commit_lists(inode, max - ret);
-		ret += pnfs_ret;
-		nfsi->ncommit -= ret;
+		pnfs_scan_commit_lists(inode, max - ret);
 	}
 	spin_unlock(&inode->i_lock);
 	return ret;
-- 
1.7.2.1

