Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36622 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932443AbbG1LNP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2015 07:13:15 -0400
Received: by pachj5 with SMTP id hj5so68359444pac.3
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2015 04:13:15 -0700 (PDT)
Message-ID: <55B763BE.5060405@gmail.com>
Date: Tue, 28 Jul 2015 19:13:02 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: osandov@osandov.com, kinglongmee@gmail.com
Subject: [PATCH 3/5] NFS: Check size by inode_newsize_ok in nfs_setattr
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set rlimit for NFS's files is useless right now.
For local process's rlimit, it should be checked by nfs client.

The same, CIFS also call inode_change_ok checking rlimit at its client
in cifs_setattr_nounix() and cifs_setattr_unix().

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/inode.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index b77b328..eed6104 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -512,15 +512,14 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
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
-- 
2.4.3

