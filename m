From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH] Remove redundant NFS_STALE() call in __nfs_revalidate_inode()
Date: Thu,  5 Mar 2009 18:05:57 -0800
Message-ID: <1236305157-10461-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56944 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754450AbZCFCLt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Mar 2009 21:11:49 -0500
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The extra NFS_STALE() invocation is likely the result of a mismerge.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/inode.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0c38168..af77c2d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -667,8 +667,6 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 
 	if (is_bad_inode(inode))
 		goto out;
-	if (NFS_STALE(inode))
-		goto out;
 
 	if (NFS_STALE(inode))
 		goto out;
-- 
1.5.4.3

