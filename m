Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:1780 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756571Ab2EGOHf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 May 2012 10:07:35 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFS: nfs_inode_return_delegation() should always flush dirty data
Date: Mon,  7 May 2012 10:07:30 -0400
Message-Id: <1336399651-6596-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1336399651-6596-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1336399651-6596-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The assumption is that if you are in a situation where you need to
return the delegation, then you should probably stop caching the
data anyway.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/delegation.c |    6 +++++-
 fs/nfs/delegation.h |    1 +
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 89af1d2..a19cb5a 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -380,6 +380,10 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode)
  * nfs_inode_return_delegation - synchronously return a delegation
  * @inode: inode to process
  *
+ * This routine will always flush any dirty data to disk on the
+ * assumption that if we need to return the delegation, then
+ * we should stop caching.
+ *
  * Returns zero on success, or a negative errno value.
  */
 int nfs_inode_return_delegation(struct inode *inode)
@@ -389,10 +393,10 @@ int nfs_inode_return_delegation(struct inode *inode)
 	struct nfs_delegation *delegation;
 	int err = 0;
 
+	nfs_wb_all(inode);
 	if (rcu_access_pointer(nfsi->delegation) != NULL) {
 		delegation = nfs_detach_delegation(nfsi, server);
 		if (delegation != NULL) {
-			nfs_wb_all(inode);
 			err = __nfs_inode_return_delegation(inode, delegation, 1);
 		}
 	}
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index cd6a7a8..72709c4 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -66,6 +66,7 @@ static inline int nfs_have_delegation(struct inode *inode, fmode_t flags)
 
 static inline int nfs_inode_return_delegation(struct inode *inode)
 {
+	nfs_wb_all(inode);
 	return 0;
 }
 #endif
-- 
1.7.7.6

