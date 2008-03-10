From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/2] NFS: When faking pre_op_attrs, don't allow backward mtime updates
Date: Mon, 10 Mar 2008 13:08:46 -0400
Message-ID: <1205168926-14373-3-git-send-email-jlayton@redhat.com>
References: <1205168926-14373-1-git-send-email-jlayton@redhat.com>
 <1205168926-14373-2-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35064 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751165AbYCJRJD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Mar 2008 13:09:03 -0400
In-Reply-To: <1205168926-14373-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since write replies don't necessarily come back in the order that they
were committed to disk, the post_op_attr mtime can sometimes jump
forward and backward. When this happens, it can make the client
invalidate the cache, even in situations when it's clear there are
no other writers.

In the situation where we're faking up pre_op_attrs, take extra care
to not allow the post_op_attrs to roll the mtime backward. If we get
a fattr with a mtime that's older the one currently on the inode,
assume that we've already previously updated the mtime and the one
currently on the inode is the correct one.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/inode.c          |   13 ++++++++++---
 include/linux/nfs_xdr.h |    1 +
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e5dbe75..c502494 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -816,7 +816,14 @@ static void nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		if (timespec_equal(&inode->i_ctime, &fattr->pre_ctime))
 			memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
 		if (timespec_equal(&inode->i_mtime, &fattr->pre_mtime)) {
-			memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
+			if ((fattr->valid & NFS_ATTR_WCC_FAKE) &&
+			    timespec_compare(&inode->i_mtime,
+					     &fattr->mtime) > 0)
+				memcpy(&fattr->mtime, &inode->i_mtime,
+					sizeof(fattr->mtime));
+			else
+				memcpy(&inode->i_mtime, &fattr->mtime,
+					sizeof(inode->i_mtime));
 			if (S_ISDIR(inode->i_mode))
 				nfsi->cache_validity |= NFS_INO_INVALID_DATA;
 		}
@@ -956,13 +963,13 @@ int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fa
 {
 	if ((fattr->valid & NFS_ATTR_FATTR_V4) != 0) {
 		fattr->pre_change_attr = NFS_I(inode)->change_attr;
-		fattr->valid |= NFS_ATTR_WCC_V4;
+		fattr->valid |= (NFS_ATTR_WCC_V4|NFS_ATTR_WCC_FAKE);
 	}
 	if ((fattr->valid & NFS_ATTR_FATTR) != 0) {
 		memcpy(&fattr->pre_ctime, &inode->i_ctime, sizeof(fattr->pre_ctime));
 		memcpy(&fattr->pre_mtime, &inode->i_mtime, sizeof(fattr->pre_mtime));
 		fattr->pre_size = inode->i_size;
-		fattr->valid |= NFS_ATTR_WCC;
+		fattr->valid |= (NFS_ATTR_WCC|NFS_ATTR_WCC_FAKE);
 	}
 	return nfs_post_op_update_inode(inode, fattr);
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index f301d0b..6715a67 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -64,6 +64,7 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_V4	0x0008		/* NFSv4 change attribute */
 #define NFS_ATTR_WCC_V4		0x0010		/* pre-op change attribute */
 #define NFS_ATTR_FATTR_V4_REFERRAL	0x0020		/* NFSv4 referral */
+#define NFS_ATTR_WCC_FAKE	0x0040		/* pre-op attrs are faked */
 
 /*
  * Info on the file system
-- 
1.5.3.6

