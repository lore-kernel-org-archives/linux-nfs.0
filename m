Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12976 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754526Ab2DZVDl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 17:03:41 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/8] NFS: Change attribute updates should set NFS_INO_REVAL_PAGECACHE
Date: Thu, 26 Apr 2012 17:03:30 -0400
Message-Id: <1335474215-29127-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335474215-29127-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1335474215-29127-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5f5fb72..a54dbce 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1303,7 +1303,11 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		if (inode->i_version != fattr->change_attr) {
 			dprintk("NFS: change_attr change on server for file %s/%ld\n",
 					inode->i_sb->s_id, inode->i_ino);
-			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
+			invalid |= NFS_INO_INVALID_ATTR
+				| NFS_INO_INVALID_DATA
+				| NFS_INO_INVALID_ACCESS
+				| NFS_INO_INVALID_ACL
+				| NFS_INO_REVAL_PAGECACHE;
 			if (S_ISDIR(inode->i_mode))
 				nfs_force_lookup_revalidate(inode);
 			inode->i_version = fattr->change_attr;
-- 
1.7.7.6

