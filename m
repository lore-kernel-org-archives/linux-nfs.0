Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34675 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbG3Nl4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:41:56 -0400
Received: by pacan13 with SMTP id an13so24306224pac.1
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:41:55 -0700 (PDT)
Message-ID: <55BA2996.9030804@gmail.com>
Date: Thu, 30 Jul 2015 21:41:42 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 3/7 v2] NFS: Check size by inode_newsize_ok in nfs_setattr
References: <55BA290B.2020704@gmail.com> <55BA2936.4030404@gmail.com>
In-Reply-To: <55BA2936.4030404@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set rlimit for NFS's files is useless right now.
For local process's rlimit, it should be checked by nfs client.

The same, CIFS also call inode_change_ok checking rlimit at its client
in cifs_setattr_nounix() and cifs_setattr_unix().

v2, same as v1.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/inode.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0adc7d2..9304dfd 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
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
-- 
2.4.3

