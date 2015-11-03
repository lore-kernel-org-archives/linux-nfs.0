Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45803 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932384AbbKCPUo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2015 10:20:44 -0500
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
Subject: [PATCH v13 27/51] xfs: Fix richacl access by ioctl
Date: Tue,  3 Nov 2015 16:17:03 +0100
Message-Id: <1446563847-14005-28-git-send-email-agruenba@redhat.com>
In-Reply-To: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
References: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure that the XFS_IOC_ATTRMULTI_BY_HANDLE ioctl exposes richacls in
the same way as the xattr interface: check for mode-equivalent richacls,
update the inode permission bits, and perform user namespace mapping.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/xfs/xfs_ioctl.c   | 27 +++++++++++++++++++++++++++
 fs/xfs/xfs_richacl.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++++----
 fs/xfs/xfs_richacl.h |  3 +++
 3 files changed, 78 insertions(+), 4 deletions(-)

diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index e939c20..deae7df 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -40,6 +40,7 @@
 #include "xfs_symlink.h"
 #include "xfs_trans.h"
 #include "xfs_pnfs.h"
+#include "xfs_richacl.h"
 
 #include <linux/capability.h>
 #include <linux/dcache.h>
@@ -48,6 +49,7 @@
 #include <linux/pagemap.h>
 #include <linux/slab.h>
 #include <linux/exportfs.h>
+#include <linux/xattr.h>
 
 /*
  * xfs_find_handle maps from userspace xfs_fsop_handlereq structure to
@@ -461,10 +463,20 @@ xfs_attrmulti_attr_get(
 	if (!kbuf)
 		return -ENOMEM;
 
+	if (flags & ATTR_ROOT) {
+		if (!strcmp(name, XATTR_RICHACL)) {
+			error = xfs_richacl_get_ioctl(inode, kbuf, (int *)len);
+			if (error)
+				goto out_kfree;
+			goto out_copy;
+		}
+	}
+
 	error = xfs_attr_get(XFS_I(inode), name, kbuf, (int *)len, flags);
 	if (error)
 		goto out_kfree;
 
+out_copy:
 	if (copy_to_user(ubuf, kbuf, *len))
 		error = -EFAULT;
 
@@ -493,7 +505,16 @@ xfs_attrmulti_attr_set(
 	if (IS_ERR(kbuf))
 		return PTR_ERR(kbuf);
 
+	if (flags & ATTR_ROOT) {
+		if (!strcmp(name, XATTR_RICHACL)) {
+			error = xfs_richacl_set_ioctl(inode, kbuf, len, flags);
+			goto out_kfree;
+		}
+	}
+
 	error = xfs_attr_set(XFS_I(inode), name, kbuf, len, flags);
+
+out_kfree:
 	kfree(kbuf);
 	return error;
 }
@@ -506,6 +527,12 @@ xfs_attrmulti_attr_remove(
 {
 	if (IS_IMMUTABLE(inode) || IS_APPEND(inode))
 		return -EPERM;
+
+	if (flags & ATTR_ROOT) {
+		if (!strcmp(name, XATTR_RICHACL))
+			return xfs_richacl_set_ioctl(inode, NULL, 0, flags);
+	}
+
 	return xfs_attr_remove(XFS_I(inode), name, flags);
 }
 
diff --git a/fs/xfs/xfs_richacl.c b/fs/xfs/xfs_richacl.c
index 92a036e..f8f5a62 100644
--- a/fs/xfs/xfs_richacl.c
+++ b/fs/xfs/xfs_richacl.c
@@ -67,8 +67,8 @@ xfs_remove_richacl(struct inode *inode)
 	return error;
 }
 
-int
-xfs_set_richacl(struct inode *inode, struct richacl *acl)
+static int
+__xfs_set_richacl(struct inode *inode, struct richacl *acl, int xflags)
 {
 	struct xfs_inode *ip = XFS_I(inode);
 	umode_t mode = inode->i_mode;
@@ -88,8 +88,7 @@ xfs_set_richacl(struct inode *inode, struct richacl *acl)
 	if (!value)
 		return -ENOMEM;
 	richacl_to_xattr(&init_user_ns, acl, value, size);
-	error = xfs_attr_set(ip, XATTR_RICHACL, value, size,
-			     ATTR_ROOT);
+	error = xfs_attr_set(ip, XATTR_RICHACL, value, size, xflags);
 	kfree(value);
 	if (error)
 		return error;
@@ -101,3 +100,48 @@ xfs_set_richacl(struct inode *inode, struct richacl *acl)
 
 	return 0;
 }
+
+int
+xfs_set_richacl(struct inode *inode, struct richacl *acl)
+{
+	return __xfs_set_richacl(inode, acl, ATTR_ROOT);
+}
+
+int
+xfs_richacl_get_ioctl(struct inode *inode, void *value, int *len)
+{
+	struct user_namespace *user_ns = current_user_ns();
+	struct richacl *acl;
+	int error;
+
+	acl = get_richacl(inode);
+	if (IS_ERR_OR_NULL(acl))
+		return PTR_ERR(acl);
+	error = richacl_to_xattr(user_ns, acl, value, *len);
+	if (error > 0) {
+		*len = error;
+		error = 0;
+	}
+	richacl_put(acl);
+	return error;
+}
+
+int
+xfs_richacl_set_ioctl(struct inode *inode, void *value, unsigned int size,
+		      int xflags)
+{
+	struct user_namespace *user_ns = current_user_ns();
+	struct richacl *acl = NULL;
+	int error;
+
+	if (!IS_RICHACL(inode))
+		return -EOPNOTSUPP;
+	if (value) {
+		acl = richacl_from_xattr(user_ns, value, size);
+		if (IS_ERR(acl))
+			return PTR_ERR(acl);
+	}
+	error = __xfs_set_richacl(inode, acl, xflags);
+	richacl_put(acl);
+	return error;
+}
diff --git a/fs/xfs/xfs_richacl.h b/fs/xfs/xfs_richacl.h
index 431aa25..1fd1fc1 100644
--- a/fs/xfs/xfs_richacl.h
+++ b/fs/xfs/xfs_richacl.h
@@ -20,4 +20,7 @@ struct richacl;
 extern struct richacl *xfs_get_richacl(struct inode *);
 extern int xfs_set_richacl(struct inode *, struct richacl *);
 
+extern int xfs_richacl_get_ioctl(struct inode *, void *, int *);
+extern int xfs_richacl_set_ioctl(struct inode *, void *, int, int);
+
 #endif  /* __FS_XFS_RICHACL_H */
-- 
2.5.0

