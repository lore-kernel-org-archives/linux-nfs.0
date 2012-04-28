Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57183 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752914Ab2D1TbI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Apr 2012 15:31:08 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 04/10] NFS: Change attribute updates should set NFS_INO_REVAL_PAGECACHE
Date: Sat, 28 Apr 2012 15:30:54 -0400
Message-Id: <1335641460-24839-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335641460-24839-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1335641460-24839-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335641460-24839-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335641460-24839-3-git-send-email-Trond.Myklebust@netapp.com>
 <1335641460-24839-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index fdbf76a..072ff8f 100644
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

