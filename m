Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55610 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753615Ab2D2Uu1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Apr 2012 16:50:27 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 04/15] NFS: Don't force page cache revalidations when holding a delegation
Date: Sun, 29 Apr 2012 16:50:09 -0400
Message-Id: <1335732620-10445-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335732620-10445-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1335732620-10445-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-3-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're holding a delegation, then we already know that our
page cache is valid.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 59a12c6..fed27c0 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -870,6 +870,15 @@ static int nfs_invalidate_mapping(struct inode *inode, struct address_space *map
 	return 0;
 }
 
+static bool nfs_mapping_need_revalidate_inode(struct inode *inode)
+{
+	if (nfs_have_delegated_attributes(inode))
+		return false;
+	return (NFS_I(inode)->cache_validity & NFS_INO_REVAL_PAGECACHE)
+		|| nfs_attribute_timeout(inode)
+		|| NFS_STALE(inode);
+}
+
 /**
  * nfs_revalidate_mapping - Revalidate the pagecache
  * @inode - pointer to host inode
@@ -880,9 +889,7 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int ret = 0;
 
-	if ((nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE)
-			|| nfs_attribute_cache_expired(inode)
-			|| NFS_STALE(inode)) {
+	if (nfs_mapping_need_revalidate_inode(inode)) {
 		ret = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
 		if (ret < 0)
 			goto out;
-- 
1.7.7.6

