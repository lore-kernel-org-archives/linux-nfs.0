Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20049 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753079AbaFMSSL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2014 14:18:11 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC] nfs:  ensure cached data is correct before using delegation
Date: Fri, 13 Jun 2014 14:18:08 -0400
Message-Id: <1402683488-23725-2-git-send-email-smayhew@redhat.com>
In-Reply-To: <1402683488-23725-1-git-send-email-smayhew@redhat.com>
References: <1402683488-23725-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_write_pageuptodate()  bypasses the cache_validity flags whenever we
have a delegation... but in order to do that we need to be sure our
cached data is correct to begin with.
---
 fs/nfs/delegation.c | 1 +
 fs/nfs/inode.c      | 1 +
 fs/nfs/nfs4proc.c   | 5 +++--
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 5d8ccec..12f3eca 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -167,6 +167,7 @@ void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
 			spin_unlock(&delegation->lock);
 			rcu_read_unlock();
 			nfs_inode_set_delegation(inode, cred, res);
+			nfs_revalidate_mapping(inode, inode->i_mapping);
 		}
 	} else {
 		rcu_read_unlock();
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c496f8a..95a9d21 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1090,6 +1090,7 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
 out:
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_revalidate_mapping);
 
 static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 285ad53..a538aac 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1361,11 +1361,12 @@ nfs4_opendata_check_deleg(struct nfs4_opendata *data, struct nfs4_state *state)
 				   "returning a delegation for "
 				   "OPEN(CLAIM_DELEGATE_CUR)\n",
 				   clp->cl_hostname);
-	} else if ((delegation_flags & 1UL<<NFS_DELEGATION_NEED_RECLAIM) == 0)
+	} else if ((delegation_flags & 1UL<<NFS_DELEGATION_NEED_RECLAIM) == 0) {
 		nfs_inode_set_delegation(state->inode,
 					 data->owner->so_cred,
 					 &data->o_res);
-	else
+		nfs_revalidate_mapping(state->inode, state->inode->i_mapping);
+	} else
 		nfs_inode_reclaim_delegation(state->inode,
 					     data->owner->so_cred,
 					     &data->o_res);
-- 
1.9.3

