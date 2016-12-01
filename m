Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34135 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751676AbcLAWGj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:06:39 -0500
Received: by mail-io0-f196.google.com with SMTP id r94so3851590ioe.1
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:06:39 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFSv4: Optimise away forced revalidation when we know the attributes are OK
Date: Thu,  1 Dec 2016 17:06:32 -0500
Message-Id: <20161201220632.12754-6-trond.myklebust@primarydata.com>
In-Reply-To: <20161201220632.12754-5-trond.myklebust@primarydata.com>
References: <20161201220632.12754-1-trond.myklebust@primarydata.com>
 <20161201220632.12754-2-trond.myklebust@primarydata.com>
 <20161201220632.12754-3-trond.myklebust@primarydata.com>
 <20161201220632.12754-4-trond.myklebust@primarydata.com>
 <20161201220632.12754-5-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS_INO_REVAL_FORCED flag needs to be set if we just got a delegation,
and we see that there might still be some ambiguity as to whether or not
our attribute or data cache are valid.
In practice, this means that a call to nfs_check_inode_attributes() will
have noticed a discrepancy between cached attributes and measured ones,
so let's move the setting of NFS_INO_REVAL_FORCED to there.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 4 ----
 fs/nfs/inode.c      | 2 +-
 2 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index dff600ae0d74..d7df5e67b0c1 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -391,10 +391,6 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	rcu_assign_pointer(nfsi->delegation, delegation);
 	delegation = NULL;
 
-	/* Ensure we revalidate the attributes and page cache! */
-	spin_lock(&inode->i_lock);
-	nfsi->cache_validity |= NFS_INO_REVAL_FORCED;
-	spin_unlock(&inode->i_lock);
 	trace_nfs4_set_delegation(inode, res->delegation_type);
 
 out:
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 372bfe98f685..02453d76bfea 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1317,7 +1317,7 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 		invalid |= NFS_INO_INVALID_ATIME;
 
 	if (invalid != 0)
-		nfs_set_cache_invalid(inode, invalid);
+		nfs_set_cache_invalid(inode, invalid | NFS_INO_REVAL_FORCED);
 
 	nfsi->read_cache_jiffies = fattr->time_start;
 	return 0;
-- 
2.9.3

