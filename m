Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp02.au.ibm.com ([202.81.31.144]:55940 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753565AbaD0QQT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Apr 2014 12:16:19 -0400
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 28 Apr 2014 02:16:17 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V1 21/22] ext4: Implement rich acl for ext4
Date: Sun, 27 Apr 2014 21:44:52 +0530
Message-Id: <1398615293-22931-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Support the richacl permission model in ext4.  The richacls are stored
in "system.richacl" xattrs.This need to be enabled by tune2fs or during
mkfs.ext4

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/ext4/Kconfig   |  15 ++++
 fs/ext4/Makefile  |   1 +
 fs/ext4/acl.c     |   7 +-
 fs/ext4/acl.h     |  12 +--
 fs/ext4/file.c    |   6 +-
 fs/ext4/ialloc.c  |   7 +-
 fs/ext4/inode.c   |  10 ++-
 fs/ext4/namei.c   |  11 ++-
 fs/ext4/richacl.c | 228 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/ext4/richacl.h |  46 +++++++++++
 fs/ext4/xattr.c   |   6 ++
 fs/ext4/xattr.h   |   1 +
 12 files changed, 330 insertions(+), 20 deletions(-)
 create mode 100644 fs/ext4/richacl.c
 create mode 100644 fs/ext4/richacl.h

diff --git a/fs/ext4/Kconfig b/fs/ext4/Kconfig
index efea5d5c44ce..8c821d221de6 100644
--- a/fs/ext4/Kconfig
+++ b/fs/ext4/Kconfig
@@ -73,3 +73,18 @@ config EXT4_DEBUG
 	  If you select Y here, then you will be able to turn on debugging
 	  with a command such as:
 		echo 1 > /sys/module/ext4/parameters/mballoc_debug
+
+config EXT4_FS_RICHACL
+	bool "Ext4 Rich Access Control Lists (EXPERIMENTAL)"
+	depends on EXT4_FS
+	select FS_RICHACL
+	help
+	  Rich ACLs are an implementation of NFSv4 ACLs, extended by file masks
+	  to fit into the standard POSIX file permission model.  They are
+	  designed to work seamlessly locally as well as across the NFSv4 and
+	  CIFS/SMB2 network file system protocols.
+
+	  To learn more about Rich ACL, visit
+	  http://acl.bestbits.at/richacl/
+
+	  If you don't know what Rich ACLs are, say N
diff --git a/fs/ext4/Makefile b/fs/ext4/Makefile
index 0310fec2ee3d..b9a3e2ee47c9 100644
--- a/fs/ext4/Makefile
+++ b/fs/ext4/Makefile
@@ -12,3 +12,4 @@ ext4-y	:= balloc.o bitmap.o dir.o file.o fsync.o ialloc.o inode.o page-io.o \
 
 ext4-$(CONFIG_EXT4_FS_POSIX_ACL)	+= acl.o
 ext4-$(CONFIG_EXT4_FS_SECURITY)		+= xattr_security.o
+ext4-$(CONFIG_EXT4_FS_RICHACL) 		+= richacl.o
diff --git a/fs/ext4/acl.c b/fs/ext4/acl.c
index d40c8dbbb0d6..7c508f7037fe 100644
--- a/fs/ext4/acl.c
+++ b/fs/ext4/acl.c
@@ -144,8 +144,7 @@ fail:
  *
  * inode->i_mutex: don't care
  */
-struct posix_acl *
-ext4_get_acl(struct inode *inode, int type)
+struct posix_acl *ext4_get_posix_acl(struct inode *inode, int type)
 {
 	int name_index;
 	char *value = NULL;
@@ -239,7 +238,7 @@ __ext4_set_acl(handle_t *handle, struct inode *inode, int type,
 }
 
 int
-ext4_set_acl(struct inode *inode, struct posix_acl *acl, int type)
+ext4_set_posix_acl(struct inode *inode, struct posix_acl *acl, int type)
 {
 	handle_t *handle;
 	int error, retries = 0;
@@ -264,7 +263,7 @@ retry:
  * inode->i_mutex: up (access to inode is still exclusive)
  */
 int
-ext4_init_acl(handle_t *handle, struct inode *inode, struct inode *dir)
+ext4_init_posix_acl(handle_t *handle, struct inode *inode, struct inode *dir)
 {
 	struct posix_acl *default_acl, *acl;
 	int error;
diff --git a/fs/ext4/acl.h b/fs/ext4/acl.h
index da2c79577d72..450b4d18ad9e 100644
--- a/fs/ext4/acl.h
+++ b/fs/ext4/acl.h
@@ -54,17 +54,17 @@ static inline int ext4_acl_count(size_t size)
 #ifdef CONFIG_EXT4_FS_POSIX_ACL
 
 /* acl.c */
-struct posix_acl *ext4_get_acl(struct inode *inode, int type);
-int ext4_set_acl(struct inode *inode, struct posix_acl *acl, int type);
-extern int ext4_init_acl(handle_t *, struct inode *, struct inode *);
+struct posix_acl *ext4_get_posix_acl(struct inode *inode, int type);
+int ext4_set_posix_acl(struct inode *inode, struct posix_acl *acl, int type);
+extern int ext4_init_posix_acl(handle_t *, struct inode *, struct inode *);
 
 #else  /* CONFIG_EXT4_FS_POSIX_ACL */
 #include <linux/sched.h>
-#define ext4_get_acl NULL
-#define ext4_set_acl NULL
+#define ext4_get_posix_acl NULL
+#define ext4_set_posix_acl NULL
 
 static inline int
-ext4_init_acl(handle_t *handle, struct inode *inode, struct inode *dir)
+ext4_init_posix_acl(handle_t *handle, struct inode *inode, struct inode *dir)
 {
 	return 0;
 }
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 063fc1538355..fddca0ed81d1 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -30,6 +30,7 @@
 #include "ext4_jbd2.h"
 #include "xattr.h"
 #include "acl.h"
+#include "richacl.h"
 
 /*
  * Called when an inode is released. Note that this is different
@@ -617,8 +618,9 @@ const struct inode_operations ext4_file_inode_operations = {
 	.getxattr	= generic_getxattr,
 	.listxattr	= ext4_listxattr,
 	.removexattr	= generic_removexattr,
-	.get_acl	= ext4_get_acl,
-	.set_acl	= ext4_set_acl,
+	.get_acl	= ext4_get_posix_acl,
+	.set_acl	= ext4_set_posix_acl,
+	.get_richacl	= ext4_get_richacl,
 	.fiemap		= ext4_fiemap,
 };
 
diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
index 0ee59a6644e2..a05b1dcf991f 100644
--- a/fs/ext4/ialloc.c
+++ b/fs/ext4/ialloc.c
@@ -28,6 +28,7 @@
 #include "ext4_jbd2.h"
 #include "xattr.h"
 #include "acl.h"
+#include "richacl.h"
 
 #include <trace/events/ext4.h>
 
@@ -1013,7 +1014,11 @@ got:
 	if (err)
 		goto fail_drop;
 
-	err = ext4_init_acl(handle, inode, dir);
+	if (EXT4_IS_RICHACL(dir))
+		err = ext4_init_richacl(handle, inode, dir);
+	else
+		err = ext4_init_posix_acl(handle, inode, dir);
+
 	if (err)
 		goto fail_free_drop;
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index d7b7462a0e13..3c74f7a9765e 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -44,6 +44,7 @@
 #include "xattr.h"
 #include "acl.h"
 #include "truncate.h"
+#include "richacl.h"
 
 #include <trace/events/ext4.h>
 
@@ -4697,9 +4698,12 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
 	if (orphan && inode->i_nlink)
 		ext4_orphan_del(NULL, inode);
 
-	if (!rc && (ia_valid & ATTR_MODE))
-		rc = posix_acl_chmod(inode, inode->i_mode);
-
+	if (!rc && (ia_valid & ATTR_MODE)) {
+		if (EXT4_IS_RICHACL(inode))
+			rc = ext4_richacl_chmod(inode);
+		else
+			rc = posix_acl_chmod(inode, inode->i_mode);
+	}
 err_out:
 	ext4_std_error(inode->i_sb, error);
 	if (!error)
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index 1cb84f78909e..4f293601abbd 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -39,6 +39,7 @@
 
 #include "xattr.h"
 #include "acl.h"
+#include "richacl.h"
 
 #include <trace/events/ext4.h>
 /*
@@ -3441,8 +3442,9 @@ const struct inode_operations ext4_dir_inode_operations = {
 	.getxattr	= generic_getxattr,
 	.listxattr	= ext4_listxattr,
 	.removexattr	= generic_removexattr,
-	.get_acl	= ext4_get_acl,
-	.set_acl	= ext4_set_acl,
+	.get_acl	= ext4_get_posix_acl,
+	.set_acl	= ext4_set_posix_acl,
+	.get_richacl	= ext4_get_richacl,
 	.fiemap         = ext4_fiemap,
 };
 
@@ -3452,6 +3454,7 @@ const struct inode_operations ext4_special_inode_operations = {
 	.getxattr	= generic_getxattr,
 	.listxattr	= ext4_listxattr,
 	.removexattr	= generic_removexattr,
-	.get_acl	= ext4_get_acl,
-	.set_acl	= ext4_set_acl,
+	.get_acl	= ext4_get_posix_acl,
+	.set_acl	= ext4_set_posix_acl,
+	.get_richacl	= ext4_get_richacl,
 };
diff --git a/fs/ext4/richacl.c b/fs/ext4/richacl.c
new file mode 100644
index 000000000000..bf5faf27790e
--- /dev/null
+++ b/fs/ext4/richacl.c
@@ -0,0 +1,228 @@
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
+struct richacl *
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
+	if (!uid_eq(current_fsuid(), inode->i_uid) &&
+	    richacl_check_acl(inode, ACE4_WRITE_ACL) &&
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
+	handle = ext4_journal_start(inode, EXT4_HT_XATTR,
+				    EXT4_DATA_TRANS_BLOCKS(inode->i_sb));
+	if (IS_ERR(handle))
+		return PTR_ERR(handle);
+	retval = ext4_set_richacl(handle, inode, acl);
+	ext4_journal_stop(handle);
+	if (retval == -ENOSPC && ext4_should_retry_alloc(inode->i_sb, &retries))
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
index 000000000000..2577c34e2741
--- /dev/null
+++ b/fs/ext4/richacl.h
@@ -0,0 +1,46 @@
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
+#define EXT4_IS_RICHACL(inode) IS_RICHACL(inode)
+
+extern struct richacl *ext4_get_richacl(struct inode *);
+extern int ext4_init_richacl(handle_t *, struct inode *, struct inode *);
+extern int ext4_richacl_chmod(struct inode *);
+
+#else  /* CONFIG_FS_EXT4_RICHACL */
+
+#define EXT4_IS_RICHACL(inode) (0)
+#define ext4_get_richacl   NULL
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
index 4eec399ec807..5c47540697db 100644
--- a/fs/ext4/xattr.c
+++ b/fs/ext4/xattr.c
@@ -100,6 +100,9 @@ static const struct xattr_handler *ext4_xattr_handler_map[] = {
 #ifdef CONFIG_EXT4_FS_SECURITY
 	[EXT4_XATTR_INDEX_SECURITY]	     = &ext4_xattr_security_handler,
 #endif
+#ifdef CONFIG_EXT4_FS_RICHACL
+	[EXT4_XATTR_INDEX_RICHACL]           = &ext4_richacl_xattr_handler,
+#endif
 };
 
 const struct xattr_handler *ext4_xattr_handlers[] = {
@@ -112,6 +115,9 @@ const struct xattr_handler *ext4_xattr_handlers[] = {
 #ifdef CONFIG_EXT4_FS_SECURITY
 	&ext4_xattr_security_handler,
 #endif
+#ifdef CONFIG_EXT4_FS_RICHACL
+	&ext4_richacl_xattr_handler,
+#endif
 	NULL
 };
 
diff --git a/fs/ext4/xattr.h b/fs/ext4/xattr.h
index 29bedf5589f6..065821e814f2 100644
--- a/fs/ext4/xattr.h
+++ b/fs/ext4/xattr.h
@@ -97,6 +97,7 @@ struct ext4_xattr_ibody_find {
 extern const struct xattr_handler ext4_xattr_user_handler;
 extern const struct xattr_handler ext4_xattr_trusted_handler;
 extern const struct xattr_handler ext4_xattr_security_handler;
+extern const struct xattr_handler ext4_richacl_xattr_handler;
 
 extern ssize_t ext4_listxattr(struct dentry *, char *, size_t);
 
-- 
1.9.1

