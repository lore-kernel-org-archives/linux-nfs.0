From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/2] NFS: Always fake wcc pre_op_attrs on write replies
Date: Mon, 10 Mar 2008 13:08:45 -0400
Message-ID: <1205168926-14373-2-git-send-email-jlayton@redhat.com>
References: <1205168926-14373-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35062 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751148AbYCJRJD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Mar 2008 13:09:03 -0400
In-Reply-To: <1205168926-14373-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Write replies don't necessarily come in the same order that they are
committed to disk. It's easily possible for the wcc pre_op_attrs to not
match the current mtime on the file, even if there are no other writers.
When this happens, it can cause the pre_op_attr mtime to bounce around
which can confuse the client revalidation logic and make it invalidate
the cache, even when it's clearly the only writer to the file.

This patch attempts to reduce the amount of cache invalidations due to
post-op-attr updates by having post_op_update_inode_force_wcc() always
fake up wcc pre_op_attrs on write replies, even when the server has sent
us valid ones.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/inode.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index a4c7cf2..e5dbe75 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -954,13 +954,11 @@ int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr)
  */
 int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fattr)
 {
-	if ((fattr->valid & NFS_ATTR_FATTR_V4) != 0 &&
-			(fattr->valid & NFS_ATTR_WCC_V4) == 0) {
+	if ((fattr->valid & NFS_ATTR_FATTR_V4) != 0) {
 		fattr->pre_change_attr = NFS_I(inode)->change_attr;
 		fattr->valid |= NFS_ATTR_WCC_V4;
 	}
-	if ((fattr->valid & NFS_ATTR_FATTR) != 0 &&
-			(fattr->valid & NFS_ATTR_WCC) == 0) {
+	if ((fattr->valid & NFS_ATTR_FATTR) != 0) {
 		memcpy(&fattr->pre_ctime, &inode->i_ctime, sizeof(fattr->pre_ctime));
 		memcpy(&fattr->pre_mtime, &inode->i_mtime, sizeof(fattr->pre_mtime));
 		fattr->pre_size = inode->i_size;
-- 
1.5.3.6

