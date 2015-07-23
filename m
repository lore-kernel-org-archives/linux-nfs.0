Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:36533 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752977AbbGWStF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jul 2015 14:49:05 -0400
Received: by obnw1 with SMTP id w1so1279336obn.3
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2015 11:49:05 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFS: Don't revalidate the mapping if both size and change attr are up to date
Date: Thu, 23 Jul 2015 14:48:58 -0400
Message-Id: <1437677341-2943-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1437677341-2943-1-git-send-email-trond.myklebust@primarydata.com>
References: <1437677341-2943-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we've ensured that the size and the change attribute are both correct,
then there is no point in marking those attributes as needing revalidation
again. Only do so if we know the size is incorrect and was not updated.

Fixes: f2467b6f64da ("NFS: Clear NFS_INO_REVAL_PAGECACHE when...")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index b77b328a06d7..d654661defb3 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1244,9 +1244,11 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 	if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
 		cur_size = i_size_read(inode);
 		new_isize = nfs_size_to_loff_t(fattr->size);
-		if (cur_size != new_isize && nfsi->nrequests == 0)
+		if (cur_size != new_isize)
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
 	}
+	if (nfsi->nrequests != 0)
+		invalid &= ~NFS_INO_REVAL_PAGECACHE;
 
 	/* Have any file permissions changed? */
 	if ((fattr->valid & NFS_ATTR_FATTR_MODE) && (inode->i_mode & S_IALLUGO) != (fattr->mode & S_IALLUGO))
@@ -1684,8 +1686,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			invalid |= NFS_INO_INVALID_ATTR
 				| NFS_INO_INVALID_DATA
 				| NFS_INO_INVALID_ACCESS
-				| NFS_INO_INVALID_ACL
-				| NFS_INO_REVAL_PAGECACHE;
+				| NFS_INO_INVALID_ACL;
 			if (S_ISDIR(inode->i_mode))
 				nfs_force_lookup_revalidate(inode);
 			inode->i_version = fattr->change_attr;
@@ -1717,7 +1718,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			if ((nfsi->nrequests == 0) || new_isize > cur_isize) {
 				i_size_write(inode, new_isize);
 				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
-				invalid &= ~NFS_INO_REVAL_PAGECACHE;
 			}
 			dprintk("NFS: isize change on server for file %s/%ld "
 					"(%Ld to %Ld)\n",
-- 
2.4.3

