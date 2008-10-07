From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 08/30] NFS: Fix nfs_post_op_update_inode_force_wcc()
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.54810.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35670 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756236AbYJGWcx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:53 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m97MWkwA026300
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2008 15:32:49 -0700 (PDT)
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we believe that the attributes are old (see nfs_refresh_inode()), then
we shouldn't force an update.
Also ensure that we hold the inode->i_lock across attribute checks and the
call to nfs_refresh_inode_locked() to ensure that we don't race with other
attribute updates.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |   35 +++++++++++++++++++++++++++--------
 1 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 8c514a1..610d022 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1017,6 +1017,18 @@ int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr)
 	return status;
 }
 
+static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+
+	nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
+	if (S_ISDIR(inode->i_mode))
+		nfsi->cache_validity |= NFS_INO_INVALID_DATA;
+	if ((fattr->valid & NFS_ATTR_FATTR) == 0)
+		return 0;
+	return nfs_refresh_inode_locked(inode, fattr);
+}
+
 /**
  * nfs_post_op_update_inode - try to update the inode attribute cache
  * @inode - pointer to inode
@@ -1033,15 +1045,10 @@ int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr)
  */
 int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
-	struct nfs_inode *nfsi = NFS_I(inode);
-	int status = 0;
+	int status;
 
 	spin_lock(&inode->i_lock);
-	nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
-	if (S_ISDIR(inode->i_mode))
-		nfsi->cache_validity |= NFS_INO_INVALID_DATA;
-	if ((fattr->valid & NFS_ATTR_FATTR) != 0)
-		status = nfs_refresh_inode_locked(inode, fattr);
+	status = nfs_post_op_update_inode_locked(inode, fattr);
 	spin_unlock(&inode->i_lock);
 	return status;
 }
@@ -1059,6 +1066,15 @@ int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr)
  */
 int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fattr)
 {
+	int status;
+
+	spin_lock(&inode->i_lock);
+	/* Don't do a WCC update if these attributes are already stale */
+	if ((fattr->valid & NFS_ATTR_FATTR) == 0 ||
+			!nfs_inode_attrs_need_update(inode, fattr)) {
+		fattr->valid &= ~(NFS_ATTR_WCC_V4|NFS_ATTR_WCC);
+		goto out_noforce;
+	}
 	if ((fattr->valid & NFS_ATTR_FATTR_V4) != 0 &&
 			(fattr->valid & NFS_ATTR_WCC_V4) == 0) {
 		fattr->pre_change_attr = NFS_I(inode)->change_attr;
@@ -1071,7 +1087,10 @@ int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fa
 		fattr->pre_size = i_size_read(inode);
 		fattr->valid |= NFS_ATTR_WCC;
 	}
-	return nfs_post_op_update_inode(inode, fattr);
+out_noforce:
+	status = nfs_post_op_update_inode_locked(inode, fattr);
+	spin_unlock(&inode->i_lock);
+	return status;
 }
 
 /*

