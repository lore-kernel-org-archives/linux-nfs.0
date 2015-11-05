Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1032029AbbKELmB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Nov 2015 06:42:01 -0500
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org
Cc: Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH v14 19/22] richacl: Add richacl xattr handler
Date: Thu,  5 Nov 2015 12:39:37 +0100
Message-Id: <1446723580-3747-20-git-send-email-agruenba@redhat.com>
In-Reply-To: <1446723580-3747-1-git-send-email-agruenba@redhat.com>
References: <1446723580-3747-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add richacl xattr handler implementing the xattr operations based on the
get_richacl and set_richacl inode operations.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_xattr.c            | 78 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl_xattr.h |  2 ++
 2 files changed, 80 insertions(+)

diff --git a/fs/richacl_xattr.c b/fs/richacl_xattr.c
index 38473b6..767c1f7 100644
--- a/fs/richacl_xattr.c
+++ b/fs/richacl_xattr.c
@@ -18,7 +18,9 @@
 #include <linux/fs.h>
 #include <linux/slab.h>
 #include <linux/module.h>
+#include <linux/xattr.h>
 #include <linux/richacl_xattr.h>
+#include <uapi/linux/xattr.h>
 
 MODULE_LICENSE("GPL");
 
@@ -161,6 +163,82 @@ richacl_to_xattr(struct user_namespace *user_ns,
 }
 EXPORT_SYMBOL_GPL(richacl_to_xattr);
 
+static size_t
+richacl_xattr_list(struct dentry *dentry, char *list, size_t list_len,
+		   const char *name, size_t name_len, int handler_flags)
+{
+	const size_t size = sizeof(XATTR_NAME_RICHACL);
+
+	if (!IS_RICHACL(d_backing_inode(dentry)))
+		return 0;
+	if (list && size <= list_len)
+		memcpy(list, XATTR_NAME_RICHACL, size);
+	return size;
+}
+
+static int
+richacl_xattr_get(struct dentry *dentry, const char *name, void *buffer,
+		  size_t buffer_size, int handler_flags)
+{
+	struct inode *inode = d_backing_inode(dentry);
+	struct richacl *acl;
+	int error;
+
+	if (strcmp(name, "") != 0)
+		return -EINVAL;
+	if (!IS_RICHACL(inode))
+		return EOPNOTSUPP;
+	if (S_ISLNK(inode->i_mode))
+		return -EOPNOTSUPP;
+	acl = get_richacl(inode);
+	if (IS_ERR(acl))
+		return PTR_ERR(acl);
+	if (acl == NULL)
+		return -ENODATA;
+	error = richacl_to_xattr(&init_user_ns, acl, buffer, buffer_size);
+	richacl_put(acl);
+	return error;
+}
+
+static int
+richacl_xattr_set(struct dentry *dentry, const char *name,
+		  const void *value, size_t size, int flags, int handler_flags)
+{
+	struct inode *inode = d_backing_inode(dentry);
+	struct richacl *acl = NULL;
+	int ret;
+
+	if (strcmp(name, "") != 0)
+		return -EINVAL;
+	if (!IS_RICHACL(inode))
+		return -EOPNOTSUPP;
+	if (!inode->i_op->set_richacl)
+		return -EOPNOTSUPP;
+
+	if (!uid_eq(current_fsuid(), inode->i_uid) &&
+	    inode_permission(inode, MAY_CHMOD) &&
+	    !capable(CAP_FOWNER))
+		return -EPERM;
+
+	if (value) {
+		acl = richacl_from_xattr(&init_user_ns, value, size);
+		if (IS_ERR(acl))
+			return PTR_ERR(acl);
+	}
+
+	ret = inode->i_op->set_richacl(inode, acl);
+	richacl_put(acl);
+	return ret;
+}
+
+struct xattr_handler richacl_xattr_handler = {
+	.prefix = XATTR_NAME_RICHACL,
+	.list = richacl_xattr_list,
+	.get = richacl_xattr_get,
+	.set = richacl_xattr_set,
+};
+EXPORT_SYMBOL(richacl_xattr_handler);
+
 /*
  * Fix up the uids and gids in richacl extended attributes in place.
  */
diff --git a/include/linux/richacl_xattr.h b/include/linux/richacl_xattr.h
index 7fc5ca8..45ec27a 100644
--- a/include/linux/richacl_xattr.h
+++ b/include/linux/richacl_xattr.h
@@ -39,4 +39,6 @@ static inline void richacl_fix_xattr_to_user(void *value, size_t size)
 }
 #endif
 
+extern struct xattr_handler richacl_xattr_handler;
+
 #endif /* __RICHACL_XATTR_H */
-- 
2.5.0

