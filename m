Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34906 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932755AbcKNUzr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2016 15:55:47 -0500
Received: by mail-it0-f67.google.com with SMTP id b123so16823696itb.2
        for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2016 12:55:47 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/5] NFSv4: Optimise away forced revalidation when we know the attributes are OK
Date: Mon, 14 Nov 2016 15:55:35 -0500
Message-Id: <1479156935-34479-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1479156935-34479-5-git-send-email-trond.myklebust@primarydata.com>
References: <1479156935-34479-1-git-send-email-trond.myklebust@primarydata.com>
 <1479156935-34479-2-git-send-email-trond.myklebust@primarydata.com>
 <1479156935-34479-3-git-send-email-trond.myklebust@primarydata.com>
 <1479156935-34479-4-git-send-email-trond.myklebust@primarydata.com>
 <1479156935-34479-5-git-send-email-trond.myklebust@primarydata.com>
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
index bf4ec5ecc97e..3575e3408bd7 100644
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
2.7.4

