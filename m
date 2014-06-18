Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:53644 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933182AbaFRJEu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jun 2014 05:04:50 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Philippe Troin <phil@fifi.org>, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: only show Posix ACLs in listxattr if actually present
Date: Wed, 18 Jun 2014 11:07:03 +0200
Message-Id: <1403082423-13131-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The big ACL switched nfs to use generic_listxattr, which calls all existing
->list handlers.  Add a custom .listxattr implementation that only lists
the ACLs if they actually are present on the given inode.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reported-by: Philippe Troin <phil@fifi.org>
Tested-by: Philippe Troin <phil@fifi.org>
---
 fs/nfs/nfs3acl.c  |   43 +++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs3proc.c |    4 ++--
 2 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 871d6ed..8f854dd 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -247,3 +247,46 @@ const struct xattr_handler *nfs3_xattr_handlers[] = {
 	&posix_acl_default_xattr_handler,
 	NULL,
 };
+
+static int
+nfs3_list_one_acl(struct inode *inode, int type, const char *name, void *data,
+		size_t size, ssize_t *result)
+{
+	struct posix_acl *acl;
+	char *p = data + *result;
+
+	acl = get_acl(inode, type);
+	if (!acl)
+		return 0;
+
+	posix_acl_release(acl);
+
+	*result += strlen(name);
+	*result += 1;
+	if (!size)
+		return 0;
+	if (*result > size)
+		return -ERANGE;
+
+	strcpy(p, name);
+	return 0;
+}
+
+ssize_t
+nfs3_listxattr(struct dentry *dentry, char *data, size_t size)
+{
+	struct inode *inode = dentry->d_inode;
+	ssize_t result = 0;
+	int error;
+
+	error = nfs3_list_one_acl(inode, ACL_TYPE_ACCESS,
+			POSIX_ACL_XATTR_ACCESS, data, size, &result);
+	if (error)
+		return error;
+
+	error = nfs3_list_one_acl(inode, ACL_TYPE_DEFAULT,
+			POSIX_ACL_XATTR_DEFAULT, data, size, &result);
+	if (error)
+		return error;
+	return result;
+}
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index e7daa42..f0afa29 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -885,7 +885,7 @@ static const struct inode_operations nfs3_dir_inode_operations = {
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
 #ifdef CONFIG_NFS_V3_ACL
-	.listxattr	= generic_listxattr,
+	.listxattr	= nfs3_listxattr,
 	.getxattr	= generic_getxattr,
 	.setxattr	= generic_setxattr,
 	.removexattr	= generic_removexattr,
@@ -899,7 +899,7 @@ static const struct inode_operations nfs3_file_inode_operations = {
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
 #ifdef CONFIG_NFS_V3_ACL
-	.listxattr	= generic_listxattr,
+	.listxattr	= nfs3_listxattr,
 	.getxattr	= generic_getxattr,
 	.setxattr	= generic_setxattr,
 	.removexattr	= generic_removexattr,
-- 
1.7.10.4

