Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:52109 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237AbaA3OfV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jan 2014 09:35:21 -0500
Date: Thu, 30 Jan 2014 06:35:18 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: viro@zeniv.linux.org.uk, Chris Mason <clm@fb.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: avoid oops when CONFIG_NFS_V3_ACL is not set
Message-ID: <20140130143518.GA14169@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we don't have s_xattr set we must not call the generic xattr
inode operations:

[  198.564281] BUG: unable to handle kernel NULL pointer dereference at
+(null)
[  198.581957] IP: [<ffffffff811ab510>] generic_getxattr+0x20/0x90
[  198.595266] PGD baaf2067 PUD ba4f4067 PMD 0
[  198.605033] Oops: 0000 [#1] SMP


Signed-off-by: Christoph Hellwig <hch@lst.de>
Reported-by: Chris Mason <clm@fb.com>
Tested-by: Chris Mason <clm@fb.com>

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index d2255d7..aa9bc97 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -924,11 +924,11 @@ static const struct inode_operations nfs3_dir_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
+#ifdef CONFIG_NFS_V3_ACL
 	.listxattr	= generic_listxattr,
 	.getxattr	= generic_getxattr,
 	.setxattr	= generic_setxattr,
 	.removexattr	= generic_removexattr,
-#ifdef CONFIG_NFS_V3_ACL
 	.get_acl	= nfs3_get_acl,
 	.set_acl	= nfs3_set_acl,
 #endif
@@ -938,11 +938,11 @@ static const struct inode_operations nfs3_file_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
+#ifdef CONFIG_NFS_V3_ACL
 	.listxattr	= generic_listxattr,
 	.getxattr	= generic_getxattr,
 	.setxattr	= generic_setxattr,
 	.removexattr	= generic_removexattr,
-#ifdef CONFIG_NFS_V3_ACL
 	.get_acl	= nfs3_get_acl,
 	.set_acl	= nfs3_set_acl,
 #endif
