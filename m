Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57900 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758310AbbLBNpS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Dec 2015 08:45:18 -0500
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 09/11] nfs: Move call to security_inode_listsecurity into nfs_listxattr
Date: Wed,  2 Dec 2015 14:44:41 +0100
Message-Id: <1449063883-22097-10-git-send-email-agruenba@redhat.com>
In-Reply-To: <1449063883-22097-1-git-send-email-agruenba@redhat.com>
References: <1449063883-22097-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a nfs_listxattr operation.  Move the call to security_inode_listsecurity
from list operation of the "security.*" xattr handler to nfs_listxattr.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
---
 fs/nfs/nfs4proc.c          | 53 +++++++++++++++++++++++++++++++---------------
 security/smack/smack_lsm.c |  2 --
 2 files changed, 36 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f6f40aa..914cb3d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6279,10 +6279,6 @@ static size_t nfs4_xattr_list_nfs4_acl(const struct xattr_handler *handler,
 }
 
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
-static inline int nfs4_server_supports_labels(struct nfs_server *server)
-{
-	return server->caps & NFS_CAP_SECURITY_LABEL;
-}
 
 static int nfs4_xattr_set_nfs4_label(const struct xattr_handler *handler,
 				     struct dentry *dentry, const char *key,
@@ -6304,29 +6300,34 @@ static int nfs4_xattr_get_nfs4_label(const struct xattr_handler *handler,
 	return -EOPNOTSUPP;
 }
 
-static size_t nfs4_xattr_list_nfs4_label(const struct xattr_handler *handler,
-					 struct dentry *dentry, char *list,
-					 size_t list_len, const char *name,
-					 size_t name_len)
+static ssize_t
+nfs4_listxattr_nfs4_label(struct inode *inode, char *list, size_t list_len)
 {
-	size_t len = 0;
+	int len = 0;
 
-	if (nfs_server_capable(d_inode(dentry), NFS_CAP_SECURITY_LABEL)) {
-		len = security_inode_listsecurity(d_inode(dentry), NULL, 0);
-		if (list && len <= list_len)
-			security_inode_listsecurity(d_inode(dentry), list, len);
+	if (nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL)) {
+		len = security_inode_listsecurity(inode, list, len);
+		if (len > list_len)
+			return -ERANGE;
 	}
 	return len;
 }
 
 static const struct xattr_handler nfs4_xattr_nfs4_label_handler = {
 	.prefix = XATTR_SECURITY_PREFIX,
-	.list	= nfs4_xattr_list_nfs4_label,
 	.get	= nfs4_xattr_get_nfs4_label,
 	.set	= nfs4_xattr_set_nfs4_label,
 };
-#endif
 
+#else
+
+static ssize_t
+nfs4_listxattr_nfs4_label(struct inode *inode, char *list, size_t list_len)
+{
+	return 0;
+}
+
+#endif
 
 /*
  * nfs_fhget will use either the mounted_on_fileid or the fileid
@@ -8743,6 +8744,24 @@ const struct nfs4_minor_version_ops *nfs_v4_minor_ops[] = {
 #endif
 };
 
+ssize_t nfs4_listxattr(struct dentry *dentry, char *list, size_t size)
+{
+	ssize_t error, error2;
+
+	error = generic_listxattr(dentry, list, size);
+	if (error < 0)
+		return error;
+	if (list) {
+		list += error;
+		size -= error;
+	}
+
+	error2 = nfs4_listxattr_nfs4_label(d_inode(dentry), list, size);
+	if (error2 < 0)
+		return error2;
+	return error + error2;
+}
+
 static const struct inode_operations nfs4_dir_inode_operations = {
 	.create		= nfs_create,
 	.lookup		= nfs_lookup,
@@ -8759,7 +8778,7 @@ static const struct inode_operations nfs4_dir_inode_operations = {
 	.setattr	= nfs_setattr,
 	.getxattr	= generic_getxattr,
 	.setxattr	= generic_setxattr,
-	.listxattr	= generic_listxattr,
+	.listxattr	= nfs4_listxattr,
 	.removexattr	= generic_removexattr,
 };
 
@@ -8769,7 +8788,7 @@ static const struct inode_operations nfs4_file_inode_operations = {
 	.setattr	= nfs_setattr,
 	.getxattr	= generic_getxattr,
 	.setxattr	= generic_setxattr,
-	.listxattr	= generic_listxattr,
+	.listxattr	= nfs4_listxattr,
 	.removexattr	= generic_removexattr,
 };
 
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index ff81026..37fdd54 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1519,8 +1519,6 @@ static int smack_inode_getsecurity(const struct inode *inode,
  * @inode: the object
  * @buffer: where they go
  * @buffer_size: size of buffer
- *
- * Returns 0 on success, -EINVAL otherwise
  */
 static int smack_inode_listsecurity(struct inode *inode, char *buffer,
 				    size_t buffer_size)
-- 
2.5.0

