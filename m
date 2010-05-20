From: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Subject: [PATCH] nfs: avoid possible deadlock bug when setting up
 delegation.
Date: Thu, 20 May 2010 13:42:24 +0800
Message-ID: <20100520054216.GA27457@vmware>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [221.122.61.232] ([221.122.61.232]:48633 "EHLO mx.bwstor.com.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751498Ab0ETFnG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 May 2010 01:43:06 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Unlock clp->cl_lock before taking inode->i_lock when setting up
delegation to avoid possible deadlock bug.

Signed-off-by: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
---
 fs/nfs/delegation.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index ea61d26..0983930 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -233,6 +233,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 		if (memcmp(&delegation->stateid, &old_delegation->stateid,
 					sizeof(old_delegation->stateid)) == 0 &&
 				delegation->type == old_delegation->type) {
+			spin_unlock(&clp->cl_lock);
 			goto out;
 		}
 		/*
@@ -245,6 +246,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 		if (delegation->type <= old_delegation->type) {
 			freeme = delegation;
 			delegation = NULL;
+			spin_unlock(&clp->cl_lock);
 			goto out;
 		}
 		freeme = nfs_detach_delegation_locked(nfsi, NULL, clp);
@@ -253,6 +255,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	nfsi->delegation_state = delegation->type;
 	rcu_assign_pointer(nfsi->delegation, delegation);
 	delegation = NULL;
+	spin_unlock(&clp->cl_lock);
 
 	/* Ensure we revalidate the attributes and page cache! */
 	spin_lock(&inode->i_lock);
@@ -260,7 +263,6 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	spin_unlock(&inode->i_lock);
 
 out:
-	spin_unlock(&clp->cl_lock);
 	if (delegation != NULL)
 		nfs_free_delegation(delegation);
 	if (freeme != NULL)
-- 
1.6.3.3

