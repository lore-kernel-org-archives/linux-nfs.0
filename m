Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57183 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752982Ab2D1TbK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Apr 2012 15:31:10 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 06/10] NFS: Simplify the cache invalidation code
Date: Sat, 28 Apr 2012 15:30:56 -0400
Message-Id: <1335641460-24839-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335641460-24839-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1335641460-24839-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335641460-24839-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335641460-24839-3-git-send-email-Trond.Myklebust@netapp.com>
 <1335641460-24839-4-git-send-email-Trond.Myklebust@netapp.com>
 <1335641460-24839-5-git-send-email-Trond.Myklebust@netapp.com>
 <1335641460-24839-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that NFSv2 and NFSv3 have simulated change attributes,
instead of using all three of mtime, ctime and change attribute to
manage data cache consistency, we can simplify the code to just use
the change attribute.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c |   29 +++--------------------------
 1 files changed, 3 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 072ff8f..8bfe9bf 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -949,7 +949,7 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 
 	/* Verify a few of the more important attributes */
 	if ((fattr->valid & NFS_ATTR_FATTR_MTIME) && !timespec_equal(&inode->i_mtime, &fattr->mtime))
-		invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
+		invalid |= NFS_INO_INVALID_ATTR;
 
 	if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
 		cur_size = i_size_read(inode);
@@ -1316,38 +1316,15 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		invalid |= save_cache_validity;
 
 	if (fattr->valid & NFS_ATTR_FATTR_MTIME) {
-		/* NFSv2/v3: Check if the mtime agrees */
-		if (!timespec_equal(&inode->i_mtime, &fattr->mtime)) {
-			dprintk("NFS: mtime change on server for file %s/%ld\n",
-					inode->i_sb->s_id, inode->i_ino);
-			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
-			if (S_ISDIR(inode->i_mode))
-				nfs_force_lookup_revalidate(inode);
-			memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
-		}
+		memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
 	} else if (server->caps & NFS_CAP_MTIME)
 		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
-				| NFS_INO_INVALID_DATA
-				| NFS_INO_REVAL_PAGECACHE
 				| NFS_INO_REVAL_FORCED);
 
 	if (fattr->valid & NFS_ATTR_FATTR_CTIME) {
-		/* If ctime has changed we should definitely clear access+acl caches */
-		if (!timespec_equal(&inode->i_ctime, &fattr->ctime)) {
-			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
-			/* and probably clear data for a directory too as utimes can cause
-			 * havoc with our cache.
-			 */
-			if (S_ISDIR(inode->i_mode)) {
-				invalid |= NFS_INO_INVALID_DATA;
-				nfs_force_lookup_revalidate(inode);
-			}
-			memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
-		}
+		memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
 	} else if (server->caps & NFS_CAP_CTIME)
 		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
-				| NFS_INO_INVALID_ACCESS
-				| NFS_INO_INVALID_ACL
 				| NFS_INO_REVAL_FORCED);
 
 	/* Check if our cached file size is stale */
-- 
1.7.7.6

