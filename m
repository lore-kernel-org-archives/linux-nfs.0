Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46125 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966820AbaFTMpD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jun 2014 08:45:03 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: Fix handling of change_attr updates in nfs_update_inode()
Date: Fri, 20 Jun 2014 08:45:01 -0400
Message-Id: <1403268301-29719-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we detect that the change attribute has changed on the server, it's
only necessary to invalidate our caches if we're not holding a write
delegation.  Otherwise, the change attribute is changing as the result
of our modifications and we can just silently update our copy.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/inode.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c496f8a..186562d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1563,15 +1563,17 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	/* More cache consistency checks */
 	if (fattr->valid & NFS_ATTR_FATTR_CHANGE) {
 		if (inode->i_version != fattr->change_attr) {
-			dprintk("NFS: change_attr change on server for file %s/%ld\n",
-					inode->i_sb->s_id, inode->i_ino);
-			invalid |= NFS_INO_INVALID_ATTR
-				| NFS_INO_INVALID_DATA
-				| NFS_INO_INVALID_ACCESS
-				| NFS_INO_INVALID_ACL
-				| NFS_INO_REVAL_PAGECACHE;
-			if (S_ISDIR(inode->i_mode))
-				nfs_force_lookup_revalidate(inode);
+			if (!NFS_PROTO(inode)->have_delegation(inode, FMODE_WRITE)) {
+				dprintk("NFS: change_attr change on server for file %s/%ld\n",
+						inode->i_sb->s_id, inode->i_ino);
+				invalid |= NFS_INO_INVALID_ATTR
+					| NFS_INO_INVALID_DATA
+					| NFS_INO_INVALID_ACCESS
+					| NFS_INO_INVALID_ACL
+					| NFS_INO_REVAL_PAGECACHE;
+				if (S_ISDIR(inode->i_mode))
+					nfs_force_lookup_revalidate(inode);
+			}
 			inode->i_version = fattr->change_attr;
 		}
 	} else if (server->caps & NFS_CAP_CHANGE_ATTR)
-- 
1.9.3

