Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 183.141.211.66.inaddr.G4.NET ([66.211.141.183]:54629 "EHLO
	Dobby.4dicksons.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078Ab3AVN6Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2013 08:58:25 -0500
From: Steve Dickson <steved@redhat.com>
To: David Quigley <selinux@davequigley.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 14/14] lnfs: Do not sleep holding the inode spin lock.
Date: Tue, 22 Jan 2013 08:40:42 -0500
Message-Id: <1358862042-27520-15-git-send-email-steved@redhat.com>
In-Reply-To: <1358862042-27520-1-git-send-email-steved@redhat.com>
References: <1358862042-27520-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfs_setsecurity code can sleep while allocating memory
so the inode spin lock can not be held while during this call.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/inode.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 56cd542..e5b030a 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1295,6 +1295,10 @@ int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr, struct nfs4_
 	status = nfs_refresh_inode_locked(inode, fattr, label);
 	spin_unlock(&inode->i_lock);
 
+	if (nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL)) {
+		if (label && !status)
+			nfs_setsecurity(inode, fattr, label);
+	}
 	return status;
 }
 EXPORT_SYMBOL_GPL(nfs_refresh_inode);
@@ -1334,6 +1338,11 @@ int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr, struc
 	spin_lock(&inode->i_lock);
 	status = nfs_post_op_update_inode_locked(inode, fattr, label);
 	spin_unlock(&inode->i_lock);
+
+	if (nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL)) {
+		if (label && !status)
+			nfs_setsecurity(inode, fattr, label);
+	}
 	return status;
 }
 EXPORT_SYMBOL_GPL(nfs_post_op_update_inode);
@@ -1553,9 +1562,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr, struct
 				| NFS_INO_INVALID_ACL
 				| NFS_INO_REVAL_FORCED);
 
-	if (label && (server->caps & NFS_CAP_SECURITY_LABEL))
-		nfs_setsecurity(inode, fattr, label);
-
 	if (fattr->valid & NFS_ATTR_FATTR_NLINK) {
 		if (inode->i_nlink != fattr->nlink) {
 			invalid |= NFS_INO_INVALID_ATTR;
-- 
1.8.1

