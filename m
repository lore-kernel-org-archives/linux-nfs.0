Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:1780 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756766Ab2EGOHg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 May 2012 10:07:36 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFSv4: nfs_client_return_marked_delegations can't flush data
Date: Mon,  7 May 2012 10:07:31 -0400
Message-Id: <1336399651-6596-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1336399651-6596-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1336399651-6596-1-git-send-email-Trond.Myklebust@netapp.com>
 <1336399651-6596-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since even filemap_flush() needs to lock pages that are dirty, we
cannot risk calling it from the state manager context. Therefore,
we need to move the call to filemap_flush() to
nfs_async_inode_return_delegation().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/delegation.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index a19cb5a..bd3a960 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -316,6 +316,10 @@ out:
  * nfs_client_return_marked_delegations - return previously marked delegations
  * @clp: nfs_client to process
  *
+ * Note that this function is designed to be called by the state
+ * manager thread. For this reason, it cannot flush the dirty data,
+ * since that could deadlock in case of a state recovery error.
+ *
  * Returns zero on success, or a negative errno value.
  */
 int nfs_client_return_marked_delegations(struct nfs_client *clp)
@@ -340,11 +344,9 @@ restart:
 								server);
 			rcu_read_unlock();
 
-			if (delegation != NULL) {
-				filemap_flush(inode->i_mapping);
+			if (delegation != NULL)
 				err = __nfs_inode_return_delegation(inode,
 								delegation, 0);
-			}
 			iput(inode);
 			if (!err)
 				goto restart;
@@ -542,6 +544,8 @@ int nfs_async_inode_return_delegation(struct inode *inode,
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs_delegation *delegation;
 
+	filemap_flush(inode->i_mapping);
+
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
 
-- 
1.7.7.6

