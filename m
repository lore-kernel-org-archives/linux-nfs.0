Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33741 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756130AbbHZNLH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2015 09:11:07 -0400
Received: by pacti10 with SMTP id ti10so88106329pac.0
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2015 06:11:07 -0700 (PDT)
Subject: [PATCH 1/5 v3] NFS: Check size by inode_newsize_ok in nfs_setattr
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <55DDBA9E.1040008@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55DDBADF.2040602@gmail.com>
Date: Wed, 26 Aug 2015 21:10:55 +0800
MIME-Version: 1.0
In-Reply-To: <55DDBA9E.1040008@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set rlimit for NFS's files is useless right now.
For local process's rlimit, it should be checked by nfs client.

The same, CIFS also call inode_change_ok checking rlimit at its client
in cifs_setattr_nounix() and cifs_setattr_unix().

v3, fix bad using of error

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/inode.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0adc7d2..a8b7ae8 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -504,7 +504,7 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 {
 	struct inode *inode = d_inode(dentry);
 	struct nfs_fattr *fattr;
-	int error = -ENOMEM;
+	int error = 0;
 
 	nfs_inc_stats(inode, NFSIOS_VFSSETATTR);
 
@@ -513,15 +513,14 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 		attr->ia_valid &= ~ATTR_MODE;
 
 	if (attr->ia_valid & ATTR_SIZE) {
-		loff_t i_size;
-
 		BUG_ON(!S_ISREG(inode->i_mode));
 
-		i_size = i_size_read(inode);
-		if (attr->ia_size == i_size)
+		error = inode_newsize_ok(inode, attr->ia_size);
+		if (error)
+			return error;
+
+		if (attr->ia_size == i_size_read(inode))
 			attr->ia_valid &= ~ATTR_SIZE;
-		else if (attr->ia_size < i_size && IS_SWAPFILE(inode))
-			return -ETXTBSY;
 	}
 
 	/* Optimization: if the end result is no change, don't RPC */
@@ -536,8 +535,11 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 		nfs_sync_inode(inode);
 
 	fattr = nfs_alloc_fattr();
-	if (fattr == NULL)
+	if (fattr == NULL) {
+		error = -ENOMEM;
 		goto out;
+	}
+
 	/*
 	 * Return any delegations if we're going to change ACLs
 	 */
-- 
2.4.3

