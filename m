From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 06/30] NFS: Clean up nfs_refresh_inode() and
	nfs_post_op_update_inode()
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.94287.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52974 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754186AbYJGWcu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:50 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m97MWi0Z025764
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2008 15:32:47 -0700 (PDT)
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Try to avoid taking and dropping the inode->i_lock more than once. Do so by
moving the code in nfs_refresh_inode() that needs to be done under the
spinlock into a function nfs_refresh_inode_locked(), and then having both
nfs_refresh_inode() and nfs_post_op_update_inode() call it directly.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 52daefa..f189169 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -948,6 +948,15 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 	return 0;
 }
 
+static int nfs_refresh_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+
+	if (time_after(fattr->time_start, nfsi->last_updated))
+		return nfs_update_inode(inode, fattr);
+	return nfs_check_inode_attributes(inode, fattr);
+}
+
 /**
  * nfs_refresh_inode - try to update the inode attribute cache
  * @inode - pointer to inode
@@ -960,17 +969,12 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
  */
 int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
-	struct nfs_inode *nfsi = NFS_I(inode);
 	int status;
 
 	if ((fattr->valid & NFS_ATTR_FATTR) == 0)
 		return 0;
 	spin_lock(&inode->i_lock);
-	if (time_after(fattr->time_start, nfsi->last_updated))
-		status = nfs_update_inode(inode, fattr);
-	else
-		status = nfs_check_inode_attributes(inode, fattr);
-
+	status = nfs_refresh_inode_locked(inode, fattr);
 	spin_unlock(&inode->i_lock);
 	return status;
 }
@@ -992,13 +996,16 @@ int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr)
 int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
+	int status = 0;
 
 	spin_lock(&inode->i_lock);
 	nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
 	if (S_ISDIR(inode->i_mode))
 		nfsi->cache_validity |= NFS_INO_INVALID_DATA;
+	if ((fattr->valid & NFS_ATTR_FATTR) != 0)
+		status = nfs_refresh_inode_locked(inode, fattr);
 	spin_unlock(&inode->i_lock);
-	return nfs_refresh_inode(inode, fattr);
+	return status;
 }
 
 /**

