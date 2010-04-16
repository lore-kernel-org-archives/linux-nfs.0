From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 21/24] NFS: Reduce stack footprint of nfs_setattr()
Date: Fri, 16 Apr 2010 16:31:19 -0400
Message-ID: <1271449882-8580-22-git-send-email-Trond.Myklebust@netapp.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-6-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-7-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-8-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-9-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-10-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-11-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-12-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-13-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-14-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-15-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-16-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-17-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-18-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-19-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-20-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-21-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16405 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932477Ab0DPUbg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:36 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMlG026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:36 -0700 (PDT)
In-Reply-To: <1271449882-8580-21-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e20acdd..f132059 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -393,8 +393,8 @@ int
 nfs_setattr(struct dentry *dentry, struct iattr *attr)
 {
 	struct inode *inode = dentry->d_inode;
-	struct nfs_fattr fattr;
-	int error;
+	struct nfs_fattr *fattr;
+	int error = -ENOMEM;
 
 	nfs_inc_stats(inode, NFSIOS_VFSSETATTR);
 
@@ -417,14 +417,20 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 		filemap_write_and_wait(inode->i_mapping);
 		nfs_wb_all(inode);
 	}
+
+	fattr = nfs_alloc_fattr();
+	if (fattr == NULL)
+		goto out;
 	/*
 	 * Return any delegations if we're going to change ACLs
 	 */
 	if ((attr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) != 0)
 		nfs_inode_return_delegation(inode);
-	error = NFS_PROTO(inode)->setattr(dentry, &fattr, attr);
+	error = NFS_PROTO(inode)->setattr(dentry, fattr, attr);
 	if (error == 0)
-		nfs_refresh_inode(inode, &fattr);
+		nfs_refresh_inode(inode, fattr);
+	nfs_free_fattr(fattr);
+out:
 	return error;
 }
 
-- 
1.6.6.1

