Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31072 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946469Ab3BHMji (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2013 07:39:38 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 12/15] lnfs: Do not sleep holding the inode spin lock
Date: Fri,  8 Feb 2013 07:39:20 -0500
Message-Id: <1360327163-20360-13-git-send-email-SteveD@redhat.com>
In-Reply-To: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Dave Quigley <dpquigl@taiga.selinuxproject.org>

The nfs_setsecurity code can sleep while allocating memory
so the inode spin lock can not be held while during this call.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/inode.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0d412c4..65bf9ca 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1285,6 +1285,9 @@ int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr, struct nfs4_
 	status = nfs_refresh_inode_locked(inode, fattr, label);
 	spin_unlock(&inode->i_lock);
 
+	if (label && !status)
+		nfs_setsecurity(inode, fattr, label);
+
 	return status;
 }
 EXPORT_SYMBOL_GPL(nfs_refresh_inode);
@@ -1324,6 +1327,10 @@ int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr, struc
 	spin_lock(&inode->i_lock);
 	status = nfs_post_op_update_inode_locked(inode, fattr, label);
 	spin_unlock(&inode->i_lock);
+	if (nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL)) {
+		if (label && !status)
+			nfs_setsecurity(inode, fattr, label);
+	}
 	return status;
 }
 EXPORT_SYMBOL_GPL(nfs_post_op_update_inode);
@@ -1543,9 +1550,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr, struct
 				| NFS_INO_INVALID_ACL
 				| NFS_INO_REVAL_FORCED);
 
-	if (label && (server->caps & NFS_CAP_SECURITY_LABEL))
-		nfs_setsecurity(inode, fattr, label);
-
 	if (fattr->valid & NFS_ATTR_FATTR_NLINK) {
 		if (inode->i_nlink != fattr->nlink) {
 			invalid |= NFS_INO_INVALID_ATTR;
-- 
1.7.11.7

