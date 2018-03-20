Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:35456 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751480AbeCTUnt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 16:43:49 -0400
Received: by mail-it0-f44.google.com with SMTP id v194-v6so4116532itb.0
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 13:43:49 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 6/8] NFS: Move the delegation return down into _nfs4_do_setattr()
Date: Tue, 20 Mar 2018 16:43:18 -0400
Message-Id: <20180320204320.93656-7-trond.myklebust@primarydata.com>
In-Reply-To: <20180320204320.93656-6-trond.myklebust@primarydata.com>
References: <20180320204320.93656-1-trond.myklebust@primarydata.com>
 <20180320204320.93656-2-trond.myklebust@primarydata.com>
 <20180320204320.93656-3-trond.myklebust@primarydata.com>
 <20180320204320.93656-4-trond.myklebust@primarydata.com>
 <20180320204320.93656-5-trond.myklebust@primarydata.com>
 <20180320204320.93656-6-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c    | 5 -----
 fs/nfs/nfs4proc.c | 4 ++++
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 7d893543cf3b..9da00b2e26a1 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -613,11 +613,6 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 		goto out;
 	}
 
-	/*
-	 * Return any delegations if we're going to change ACLs
-	 */
-	if ((attr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) != 0)
-		NFS_PROTO(inode)->return_delegation(inode);
 	error = NFS_PROTO(inode)->setattr(dentry, fattr, attr);
 	if (error == 0)
 		error = nfs_refresh_inode(inode, fattr);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2953da680bc7..e1550627c4d5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3875,6 +3875,10 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	if (IS_ERR(label))
 		return PTR_ERR(label);
 
+	/* Return any delegations if we're going to change ACLs */
+	if ((sattr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) != 0)
+		nfs4_inode_return_delegation(inode);
+
 	status = nfs4_do_setattr(inode, cred, fattr, sattr, ctx, NULL, label);
 	if (status == 0) {
 		nfs_setattr_update_inode(inode, sattr, fattr);
-- 
2.14.3

