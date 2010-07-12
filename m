Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16076 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043Ab0GLWKV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jul 2010 18:10:21 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/3] NFS: Clean up the callers of nfs_wb_all()
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 12 Jul 2010 18:09:33 -0400
Message-ID: <20100712220932.20019.74781.stgit@heimdal.trondhjem.org>
In-Reply-To: <20100712220932.20019.21170.stgit@heimdal.trondhjem.org>
References: <20100712220932.20019.21170.stgit@heimdal.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

There is no need to flush out writes before calling nfs_wb_all().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/delegation.c |   10 +---------
 fs/nfs/inode.c      |    4 +---
 2 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index f34f4ac..b9c3c43 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -268,14 +268,6 @@ out:
 	return status;
 }
 
-/* Sync all data to disk upon delegation return */
-static void nfs_msync_inode(struct inode *inode)
-{
-	filemap_fdatawrite(inode->i_mapping);
-	nfs_wb_all(inode);
-	filemap_fdatawait(inode->i_mapping);
-}
-
 /*
  * Basic procedure for returning a delegation to the server
  */
@@ -367,7 +359,7 @@ int nfs_inode_return_delegation(struct inode *inode)
 		delegation = nfs_detach_delegation_locked(nfsi, NULL, clp);
 		spin_unlock(&clp->cl_lock);
 		if (delegation != NULL) {
-			nfs_msync_inode(inode);
+			nfs_wb_all(inode);
 			err = __nfs_inode_return_delegation(inode, delegation, 1);
 		}
 	}
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index ec7a8f9..581d8f0 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -413,10 +413,8 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 		return 0;
 
 	/* Write all dirty data */
-	if (S_ISREG(inode->i_mode)) {
-		filemap_write_and_wait(inode->i_mapping);
+	if (S_ISREG(inode->i_mode))
 		nfs_wb_all(inode);
-	}
 
 	fattr = nfs_alloc_fattr();
 	if (fattr == NULL)

