Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:52707 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932188Ab1BWNyd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 08:54:33 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: sfrench@us.ibm.com, agruen@linbit.com, dilger.kernel@dilger.ca,
        sandeen@redhat.com, tytso@mit.edu, bfields@fieldses.org,
        jlayton@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, Andreas Gruenbacher <agruen@suse.de>
Subject: [PATCH -V5 23/24] ext4: Implement rich acl for ext4
Date: Wed, 23 Feb 2011 19:22:10 +0530
Message-Id: <1298469131-16555-24-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Support the richacl permission model in ext4.  The richacls are stored
in "system.richacl" xattrs.This need to be enabled by tune2fs or during
mkfs.ext4

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Andreas Gruenbacher <agruen@suse.de>
---
 fs/ext4/Kconfig   |   15 +++
 fs/ext4/Makefile  |    3 +-
 fs/ext4/acl.c     |    2 +-
 fs/ext4/acl.h     |    3 +-
 fs/ext4/acls.c    |   20 ++++
 fs/ext4/ext4.h    |    6 ++
 fs/ext4/file.c    |    1 +
 fs/ext4/ialloc.c  |    7 ++-
 fs/ext4/inode.c   |   10 ++-
 fs/ext4/richacl.c |  255 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/ext4/richacl.h |   45 ++++++++++
 fs/ext4/xattr.c   |    6 ++
 fs/ext4/xattr.h   |    2 +
 13 files changed, 367 insertions(+), 8 deletions(-)
 create mode 100644 fs/ext4/acls.c
 create mode 100644 fs/ext4/richacl.c
 create mode 100644 fs/ext4/richacl.h

diff --git a/fs/ext4/Kconfig b/fs/ext4/Kconfig
index 9ed1bb1..a22b8f1 100644
--- a/fs/ext4/Kconfig
+++ b/fs/ext4/Kconfig
@@ -83,3 +83,18 @@ config EXT4_DEBUG
 
 	  If you select Y here, then you will be able to turn on debugging
 	  with a command such as "echo 1 > /sys/kernel/debug/ext4/mballoc-debug"
+
+config EXT4_FS_RICHACL
+      bool "Ext4 Rich Access Control Lists (EXPERIMENTAL)"
+      depends on EXT4_FS_XATTR && EXPERIMENTAL
+      select FS_RICHACL
+      help
+	Rich ACLs are an implementation of NFSv4 ACLs, extended by file masks
+	to fit into the standard POSIX file permission model.  They are
+	designed to work seamlessly locally as well as across the NFSv4 and
+	CIFS/SMB2 network file system protocols.
+
+	To learn more about Rich ACL, visit
+	http://acl.bestbits.at/richacl/
+
+	If you don't know what Rich ACLs are, say N
diff --git a/fs/ext4/Makefile b/fs/ext4/Makefile
index c947e36..a37e439 100644
--- a/fs/ext4/Makefile
+++ b/fs/ext4/Makefile
@@ -9,5 +9,6 @@ ext4-y	:= balloc.o bitmap.o dir.o file.o fsync.o ialloc.o inode.o page-io.o \
 		ext4_jbd2.o migrate.o mballoc.o block_validity.o move_extent.o
 
 ext4-$(CONFIG_EXT4_FS_XATTR)		+= xattr.o xattr_user.o xattr_trusted.o
-ext4-$(CONFIG_EXT4_FS_POSIX_ACL)	+= acl.o
+ext4-$(CONFIG_EXT4_FS_POSIX_ACL)	+= acls.o acl.o
 ext4-$(CONFIG_EXT4_FS_SECURITY)		+= xattr_security.o
+ext4-$(CONFIG_EXT4_FS_RICHACL)  	+= acls.o richacl.o
diff --git a/fs/ext4/acl.c b/fs/ext4/acl.c
index 364514c..aa9257e 100644
--- a/fs/ext4/acl.c
+++ b/fs/ext4/acl.c
@@ -238,7 +238,7 @@ ext4_set_acl(handle_t *handle, struct inode *inode, int type,
 }
 
 int
-ext4_check_acl(struct inode *inode, int mask, unsigned int flags)
+ext4_check_posix_acl(struct inode *inode, int mask, unsigned int flags)
 {
 	struct posix_acl *acl;
 
diff --git a/fs/ext4/acl.h b/fs/ext4/acl.h
index dec8211..296ee5b 100644
--- a/fs/ext4/acl.h
+++ b/fs/ext4/acl.h
@@ -54,13 +54,12 @@ static inline int ext4_acl_count(size_t size)
 #ifdef CONFIG_EXT4_FS_POSIX_ACL
 
 /* acl.c */
-extern int ext4_check_acl(struct inode *, int, unsigned int);
+extern int ext4_check_posix_acl(struct inode *, int, unsigned int);
 extern int ext4_acl_chmod(struct inode *);
 extern int ext4_init_acl(handle_t *, struct inode *, struct inode *);
 
 #else  /* CONFIG_EXT4_FS_POSIX_ACL */
 #include <linux/sched.h>
-#define ext4_check_acl NULL
 
 static inline int
 ext4_acl_chmod(struct inode *inode)
diff --git a/fs/ext4/acls.c b/fs/ext4/acls.c
new file mode 100644
index 0000000..c23fcef
--- /dev/null
+++ b/fs/ext4/acls.c
@@ -0,0 +1,20 @@
+#include <linux/fs.h>
+#include "ext4.h"
+#include "acl.h"
+#include "richacl.h"
+
+int
+ext4_check_acl(struct inode *inode, int mask, unsigned int flags)
+{
+#ifdef CONFIG_EXT4_FS_POSIX_ACL
+	if (IS_POSIXACL(inode))
+		return ext4_check_posix_acl(inode, mask, flags);
+	else
+#endif
+#ifdef CONFIG_EXT4_FS_RICHACL
+	if (IS_RICHACL(inode))
+		return ext4_check_richacl(inode, mask, flags);
+	else
+#endif
+		return -EAGAIN;
+}
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 5d1f56a..f0e09ba 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -1754,6 +1754,12 @@ extern int ext4_orphan_del(handle_t *, struct inode *);
 extern int ext4_htree_fill_tree(struct file *dir_file, __u32 start_hash,
 				__u32 start_minor_hash, __u32 *next_hash);
 
+#if defined(CONFIG_EXT4_FS_POSIX_ACL) || defined(CONFIG_EXT4_FS_RICHACL)
+extern int ext4_check_acl(struct inode *, int, unsigned int);
+#else
+# define ext4_check_acl NULL
+#endif
+
 /* resize.c */
 extern int ext4_group_add(struct super_block *sb,
 				struct ext4_new_group_data *input);
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 7b80d54..0df1da6 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -28,6 +28,7 @@
 #include "ext4_jbd2.h"
 #include "xattr.h"
 #include "acl.h"
+#include "richacl.h"
 
 /*
  * Called when an inode is released. Note that this is different
diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
index eb9097a..245e22f 100644
--- a/fs/ext4/ialloc.c
+++ b/fs/ext4/ialloc.c
@@ -28,6 +28,7 @@
 #include "ext4_jbd2.h"
 #include "xattr.h"
 #include "acl.h"
+#include "richacl.h"
 
 #include <trace/events/ext4.h>
 
@@ -1038,7 +1039,11 @@ got:
 	if (err)
 		goto fail_drop;
 
-	err = ext4_init_acl(handle, inode, dir);
+	if (EXT4_IS_RICHACL(dir))
+		err = ext4_init_richacl(handle, inode, dir);
+	else
+		err = ext4_init_acl(handle, inode, dir);
+
 	if (err)
 		goto fail_free_drop;
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 9f7f9e4..7fb0920 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -47,6 +47,7 @@
 #include "xattr.h"
 #include "acl.h"
 #include "ext4_extents.h"
+#include "richacl.h"
 
 #include <trace/events/ext4.h>
 
@@ -5417,9 +5418,12 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
 	if (orphan && inode->i_nlink)
 		ext4_orphan_del(NULL, inode);
 
-	if (!rc && (ia_valid & ATTR_MODE))
-		rc = ext4_acl_chmod(inode);
-
+	if (!rc && (ia_valid & ATTR_MODE)) {
+		if (EXT4_IS_RICHACL(inode))
+			rc = ext4_richacl_chmod(inode);
+		else
+			rc = ext4_acl_chmod(inode);
+	}
 err_out:
 	ext4_std_error(inode->i_sb, error);
 	if (!error)
diff --git a/fs/ext4/richacl.c b/fs/ext4/richacl.c
new file mode 100644
index 0000000..5547fa5
--- /dev/null
+++ b/fs/ext4/richacl.c
@@ -0,0 +1,255 @@
+/*
+ * Copyright IBM Corporation, 2010
+ * Author Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2.1 of the GNU Lesser General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it would be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/fs.h>
+#include <linux/richacl_xattr.h>
+
+#include "ext4.h"
+#include "ext4_jbd2.h"
+#include "xattr.h"
+#include "acl.h"
+#include "richacl.h"
+
+static struct richacl *
+ext4_get_richacl(struct inode *inode)
+{
+	const int name_index = EXT4_XATTR_INDEX_RICHACL;
+	void *value = NULL;
+	struct richacl *acl;
+	int retval;
+
+	if (!IS_RICHACL(inode))
+		return ERR_PTR(-EOPNOTSUPP);
+	acl = get_cached_richacl(inode);
+	if (acl != ACL_NOT_CACHED)
+		return acl;
+	retval = ext4_xattr_get(inode, name_index, "", NULL, 0);
+	if (retval > 0) {
+		value = kmalloc(retval, GFP_KERNEL);
+		if (!value)
+			return ERR_PTR(-ENOMEM);
+		retval = ext4_xattr_get(inode, name_index, "", value, retval);
+	}
+	if (retval > 0) {
+		acl = richacl_from_xattr(value, retval);
+		if (acl == ERR_PTR(-EINVAL))
+			acl = ERR_PTR(-EIO);
+	} else if (retval == -ENODATA || retval == -ENOSYS)
+		acl = NULL;
+	else
+		acl = ERR_PTR(retval);
+	kfree(value);
+
+	if (!IS_ERR_OR_NULL(acl))
+		set_cached_richacl(inode, acl);
+
+	return acl;
+}
+
+static int
+ext4_set_richacl(handle_t *handle, struct inode *inode, struct richacl *acl)
+{
+	const int name_index = EXT4_XATTR_INDEX_RICHACL;
+	size_t size = 0;
+	void *value = NULL;
+	int retval;
+
+	if (acl) {
+		mode_t mode = inode->i_mode;
+		if (richacl_equiv_mode(acl, &mode) == 0) {
+			inode->i_mode = mode;
+			ext4_mark_inode_dirty(handle, inode);
+			acl = NULL;
+		}
+	}
+	if (acl) {
+		size = richacl_xattr_size(acl);
+		value = kmalloc(size, GFP_KERNEL);
+		if (!value)
+			return -ENOMEM;
+		richacl_to_xattr(acl, value);
+	}
+	if (handle)
+		retval = ext4_xattr_set_handle(handle, inode, name_index, "",
+					       value, size, 0);
+	else
+		retval = ext4_xattr_set(inode, name_index, "", value, size, 0);
+	kfree(value);
+	if (!retval)
+		set_cached_richacl(inode, acl);
+
+	return retval;
+}
+
+static int
+__ext4_check_richacl(struct inode *inode, unsigned int mask)
+{
+	struct richacl *acl = ext4_get_richacl(inode);
+
+	if (IS_ERR(acl))
+		return PTR_ERR(acl);
+	if (acl) {
+		int error = richacl_permission(inode, acl, mask);
+		richacl_put(acl);
+		return error;
+	}
+
+	return -EAGAIN;
+}
+
+int
+ext4_check_richacl(struct inode *inode, int want, unsigned int flags)
+{
+	if (flags & IPERM_FLAG_RCU) {
+		if (!negative_cached_richacl(inode))
+			return -ECHILD;
+		return -EAGAIN;
+	}
+	return __ext4_check_richacl(inode, richacl_want_to_mask(want));
+}
+
+int
+ext4_init_richacl(handle_t *handle, struct inode *inode, struct inode *dir)
+{
+	struct richacl *dir_acl = NULL;
+
+	if (!S_ISLNK(inode->i_mode)) {
+		dir_acl = ext4_get_richacl(dir);
+		if (IS_ERR(dir_acl))
+			return PTR_ERR(dir_acl);
+	}
+	if (dir_acl) {
+		struct richacl *acl;
+		int retval;
+
+		acl = richacl_inherit_inode(dir_acl, inode);
+		richacl_put(dir_acl);
+
+		retval = PTR_ERR(acl);
+		if (acl && !IS_ERR(acl)) {
+			retval = ext4_set_richacl(handle, inode, acl);
+			richacl_put(acl);
+		}
+		return retval;
+	} else {
+		inode->i_mode &= ~current_umask();
+		return 0;
+	}
+}
+
+int
+ext4_richacl_chmod(struct inode *inode)
+{
+	struct richacl *acl;
+	int retval;
+
+	if (S_ISLNK(inode->i_mode))
+		return -EOPNOTSUPP;
+	acl = ext4_get_richacl(inode);
+	if (IS_ERR_OR_NULL(acl))
+		return PTR_ERR(acl);
+	acl = richacl_chmod(acl, inode->i_mode);
+	if (IS_ERR(acl))
+		return PTR_ERR(acl);
+	retval = ext4_set_richacl(NULL, inode, acl);
+	richacl_put(acl);
+
+	return retval;
+}
+
+static size_t
+ext4_xattr_list_richacl(struct dentry *dentry, char *list, size_t list_len,
+			const char *name, size_t name_len, int type)
+{
+	const size_t size = sizeof(RICHACL_XATTR);
+	if (!IS_RICHACL(dentry->d_inode))
+		return 0;
+	if (list && size <= list_len)
+		memcpy(list, RICHACL_XATTR, size);
+	return size;
+}
+
+static int
+ext4_xattr_get_richacl(struct dentry *dentry, const char *name, void *buffer,
+		size_t buffer_size, int type)
+{
+	struct richacl *acl;
+	size_t size;
+
+	if (strcmp(name, "") != 0)
+		return -EINVAL;
+	acl = ext4_get_richacl(dentry->d_inode);
+	if (IS_ERR(acl))
+		return PTR_ERR(acl);
+	if (acl == NULL)
+		return -ENODATA;
+	size = richacl_xattr_size(acl);
+	if (buffer) {
+		if (size > buffer_size)
+			return -ERANGE;
+		richacl_to_xattr(acl, buffer);
+	}
+	richacl_put(acl);
+
+	return size;
+}
+
+static int
+ext4_xattr_set_richacl(struct dentry *dentry, const char *name,
+		const void *value, size_t size, int flags, int type)
+{
+	handle_t *handle;
+	struct richacl *acl = NULL;
+	int retval, retries = 0;
+	struct inode *inode = dentry->d_inode;
+
+	if (!IS_RICHACL(dentry->d_inode))
+		return -EOPNOTSUPP;
+	if (S_ISLNK(inode->i_mode))
+		return -EOPNOTSUPP;
+	if (strcmp(name, "") != 0)
+		return -EINVAL;
+	if (current_fsuid() != inode->i_uid &&
+	    __ext4_check_richacl(inode, ACE4_WRITE_ACL) &&
+	    !capable(CAP_FOWNER))
+		return -EPERM;
+	if (value) {
+		acl = richacl_from_xattr(value, size);
+		if (IS_ERR(acl))
+			return PTR_ERR(acl);
+
+		inode->i_mode &= ~S_IRWXUGO;
+		inode->i_mode |= richacl_masks_to_mode(acl);
+	}
+
+retry:
+	handle = ext4_journal_start(inode, EXT4_DATA_TRANS_BLOCKS(inode->i_sb));
+	if (IS_ERR(handle))
+		return PTR_ERR(handle);
+	ext4_mark_inode_dirty(handle, inode);
+	retval = ext4_set_richacl(handle, inode, acl);
+	ext4_journal_stop(handle);
+	if (retval == ENOSPC && ext4_should_retry_alloc(inode->i_sb, &retries))
+		goto retry;
+	richacl_put(acl);
+	return retval;
+}
+
+const struct xattr_handler ext4_richacl_xattr_handler = {
+	.prefix	= RICHACL_XATTR,
+	.list	= ext4_xattr_list_richacl,
+	.get	= ext4_xattr_get_richacl,
+	.set	= ext4_xattr_set_richacl,
+};
diff --git a/fs/ext4/richacl.h b/fs/ext4/richacl.h
new file mode 100644
index 0000000..c71a02d
--- /dev/null
+++ b/fs/ext4/richacl.h
@@ -0,0 +1,45 @@
+/*
+ * Copyright IBM Corporation, 2010
+ * Author Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2.1 of the GNU Lesser General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it would be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ *
+ */
+
+#ifndef __FS_EXT4_RICHACL_H
+#define __FS_EXT4_RICHACL_H
+
+#include <linux/richacl.h>
+
+#ifdef CONFIG_EXT4_FS_RICHACL
+
+# define EXT4_IS_RICHACL(inode) IS_RICHACL(inode)
+
+extern int ext4_check_richacl(struct inode *, int, unsigned int);
+extern int ext4_init_richacl(handle_t *, struct inode *, struct inode *);
+extern int ext4_richacl_chmod(struct inode *);
+
+#else  /* CONFIG_FS_EXT4_RICHACL */
+
+# define EXT4_IS_RICHACL(inode) (0)
+
+static inline int
+ext4_init_richacl(handle_t *handle, struct inode *inode, struct inode *dir)
+{
+	return 0;
+}
+
+static inline int
+ext4_richacl_chmod(struct inode *inode)
+{
+	return 0;
+}
+
+#endif  /* CONFIG_FS_EXT4_RICHACL */
+#endif  /* __FS_EXT4_RICHACL_H */
diff --git a/fs/ext4/xattr.c b/fs/ext4/xattr.c
index fc32176..1984bb9 100644
--- a/fs/ext4/xattr.c
+++ b/fs/ext4/xattr.c
@@ -107,6 +107,9 @@ static const struct xattr_handler *ext4_xattr_handler_map[] = {
 #ifdef CONFIG_EXT4_FS_SECURITY
 	[EXT4_XATTR_INDEX_SECURITY]	     = &ext4_xattr_security_handler,
 #endif
+#ifdef CONFIG_EXT4_FS_RICHACL
+	[EXT4_XATTR_INDEX_RICHACL]           = &ext4_richacl_xattr_handler,
+#endif
 };
 
 const struct xattr_handler *ext4_xattr_handlers[] = {
@@ -119,6 +122,9 @@ const struct xattr_handler *ext4_xattr_handlers[] = {
 #ifdef CONFIG_EXT4_FS_SECURITY
 	&ext4_xattr_security_handler,
 #endif
+#ifdef CONFIG_EXT4_FS_RICHACL
+	&ext4_richacl_xattr_handler,
+#endif
 	NULL
 };
 
diff --git a/fs/ext4/xattr.h b/fs/ext4/xattr.h
index 1ef1652..5cede1a 100644
--- a/fs/ext4/xattr.h
+++ b/fs/ext4/xattr.h
@@ -21,6 +21,7 @@
 #define EXT4_XATTR_INDEX_TRUSTED		4
 #define	EXT4_XATTR_INDEX_LUSTRE			5
 #define EXT4_XATTR_INDEX_SECURITY	        6
+#define EXT4_XATTR_INDEX_RICHACL		7
 
 struct ext4_xattr_header {
 	__le32	h_magic;	/* magic number for identification */
@@ -70,6 +71,7 @@ extern const struct xattr_handler ext4_xattr_trusted_handler;
 extern const struct xattr_handler ext4_xattr_acl_access_handler;
 extern const struct xattr_handler ext4_xattr_acl_default_handler;
 extern const struct xattr_handler ext4_xattr_security_handler;
+extern const struct xattr_handler ext4_richacl_xattr_handler;
 
 extern ssize_t ext4_listxattr(struct dentry *, char *, size_t);
 
-- 
1.7.1

