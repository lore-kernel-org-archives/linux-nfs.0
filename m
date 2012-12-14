Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:6615 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932395Ab2LNWzj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Dec 2012 17:55:39 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: nfs_lookup_revalidate should not trust an inode with i_nlink == 0
Date: Fri, 14 Dec 2012 17:55:33 -0500
Message-Id: <1355525733-53242-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the inode has no links, then we should force a new lookup.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index a46a746..d8e58ed 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -978,10 +978,11 @@ static int nfs_is_exclusive_create(struct inode *dir, unsigned int flags)
  * particular file and the "nocto" mount flag is not set.
  *
  */
-static inline
+static
 int nfs_lookup_verify_inode(struct inode *inode, unsigned int flags)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
+	int ret;
 
 	if (IS_AUTOMOUNT(inode))
 		return 0;
@@ -992,9 +993,13 @@ int nfs_lookup_verify_inode(struct inode *inode, unsigned int flags)
 	if ((flags & LOOKUP_OPEN) && !(server->flags & NFS_MOUNT_NOCTO) &&
 	    (S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)))
 		goto out_force;
-	return 0;
+out:
+	return (inode->i_nlink == 0) ? -ENOENT : 0;
 out_force:
-	return __nfs_revalidate_inode(server, inode);
+	ret = __nfs_revalidate_inode(server, inode);
+	if (ret != 0)
+		return ret;
+	goto out;
 }
 
 /*
-- 
1.7.11.7

