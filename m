Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:33714 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932603AbbDXLFU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:05:20 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC v3 21/45] richacl: xattr mapping functions
Date: Fri, 24 Apr 2015 13:04:18 +0200
Message-Id: <beceaa556feee4b6afe7035d2f41607251f46990.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Map between "system.richacl" xattrs and the in-kernel representation.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/Makefile                   |   2 +-
 fs/richacl_xattr.c            | 210 ++++++++++++++++++++++++++++++++++++++++++
 fs/xattr.c                    |  34 +++++--
 include/linux/richacl_xattr.h |  52 +++++++++++
 include/uapi/linux/xattr.h    |   2 +
 5 files changed, 293 insertions(+), 7 deletions(-)
 create mode 100644 fs/richacl_xattr.c
 create mode 100644 include/linux/richacl_xattr.h

diff --git a/fs/Makefile b/fs/Makefile
index bb96ad7..6155cc4 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -48,7 +48,7 @@ obj-$(CONFIG_SYSCTL)		+= drop_caches.o
 
 obj-$(CONFIG_FHANDLE)		+= fhandle.o
 obj-$(CONFIG_FS_RICHACL)	+= richacl.o
-richacl-y			:= richacl_base.o richacl_inode.o
+richacl-y			:= richacl_base.o richacl_inode.o richacl_xattr.o
 
 obj-y				+= quota/
 
diff --git a/fs/richacl_xattr.c b/fs/richacl_xattr.c
new file mode 100644
index 0000000..1fb5b36
--- /dev/null
+++ b/fs/richacl_xattr.c
@@ -0,0 +1,210 @@
+/*
+ * Copyright (C) 2006, 2010  Novell, Inc.
+ * Copyright (C) 2015  Red Hat, Inc.
+ * Written by Andreas Gruenbacher <agruen@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2, or (at your option) any
+ * later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+#include <linux/sched.h>
+#include <linux/fs.h>
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/richacl_xattr.h>
+
+MODULE_LICENSE("GPL");
+
+/**
+ * richacl_from_xattr  -  convert a richacl xattr into the in-memory representation
+ */
+struct richacl *
+richacl_from_xattr(struct user_namespace *user_ns,
+		   const void *value, size_t size)
+{
+	const struct richacl_xattr *xattr_acl = value;
+	const struct richace_xattr *xattr_ace = (void *)(xattr_acl + 1);
+	struct richacl *acl;
+	struct richace *ace;
+	int count;
+
+	if (size < sizeof(*xattr_acl) ||
+	    xattr_acl->a_version != RICHACL_XATTR_VERSION ||
+	    (xattr_acl->a_flags & ~RICHACL_VALID_FLAGS) ||
+	    xattr_acl->a_unused != 0)
+		return ERR_PTR(-EINVAL);
+	size -= sizeof(*xattr_acl);
+	if (size % sizeof(*xattr_ace))
+		return ERR_PTR(-EINVAL);
+	count = size / sizeof(*xattr_ace);
+	if (count > RICHACL_XATTR_MAX_COUNT)
+		return ERR_PTR(-EINVAL);
+
+	acl = richacl_alloc(count, GFP_NOFS);
+	if (!acl)
+		return ERR_PTR(-ENOMEM);
+
+	acl->a_flags = xattr_acl->a_flags;
+	acl->a_owner_mask = le32_to_cpu(xattr_acl->a_owner_mask);
+	if (acl->a_owner_mask & ~RICHACE_VALID_MASK)
+		goto fail_einval;
+	acl->a_group_mask = le32_to_cpu(xattr_acl->a_group_mask);
+	if (acl->a_group_mask & ~RICHACE_VALID_MASK)
+		goto fail_einval;
+	acl->a_other_mask = le32_to_cpu(xattr_acl->a_other_mask);
+	if (acl->a_other_mask & ~RICHACE_VALID_MASK)
+		goto fail_einval;
+
+	richacl_for_each_entry(ace, acl) {
+		ace->e_type  = le16_to_cpu(xattr_ace->e_type);
+		ace->e_flags = le16_to_cpu(xattr_ace->e_flags);
+		ace->e_mask  = le32_to_cpu(xattr_ace->e_mask);
+
+		if (ace->e_flags & ~RICHACE_VALID_FLAGS)
+			goto fail_einval;
+		if (ace->e_flags & RICHACE_SPECIAL_WHO) {
+			ace->e_id.special = le32_to_cpu(xattr_ace->e_id);
+			if (ace->e_id.special > RICHACE_EVERYONE_SPECIAL_ID)
+				goto fail_einval;
+		} else if (ace->e_flags & RICHACE_IDENTIFIER_GROUP) {
+			ace->e_id.gid = make_kgid(user_ns, le32_to_cpu(xattr_ace->e_id));
+			if (!gid_valid(ace->e_id.gid))
+				goto fail_einval;
+		} else {
+			ace->e_id.uid = make_kuid(user_ns, le32_to_cpu(xattr_ace->e_id));
+			if (!uid_valid(ace->e_id.uid))
+				goto fail_einval;
+		}
+		if (ace->e_type > RICHACE_ACCESS_DENIED_ACE_TYPE ||
+		    (ace->e_mask & ~RICHACE_VALID_MASK))
+			goto fail_einval;
+
+		xattr_ace++;
+	}
+
+	return acl;
+
+fail_einval:
+	richacl_put(acl);
+	return ERR_PTR(-EINVAL);
+}
+EXPORT_SYMBOL_GPL(richacl_from_xattr);
+
+/**
+ * richacl_xattr_size  -  compute the size of the xattr representation of @acl
+ */
+size_t
+richacl_xattr_size(const struct richacl *acl)
+{
+	size_t size = sizeof(struct richacl_xattr);
+
+	size += sizeof(struct richace_xattr) * acl->a_count;
+	return size;
+}
+EXPORT_SYMBOL_GPL(richacl_xattr_size);
+
+/**
+ * richacl_to_xattr  -  convert @acl into its xattr representation
+ * @acl:	the richacl to convert
+ * @buffer:	buffer for the result
+ * @size:	size of @buffer
+ */
+int
+richacl_to_xattr(struct user_namespace *user_ns,
+		 const struct richacl *acl, void *buffer, size_t size)
+{
+	struct richacl_xattr *xattr_acl = buffer;
+	struct richace_xattr *xattr_ace;
+	const struct richace *ace;
+	size_t real_size;
+
+	real_size = richacl_xattr_size(acl);
+	if (!buffer)
+		return real_size;
+	if (real_size > size)
+		return -ERANGE;
+
+	xattr_acl->a_version = RICHACL_XATTR_VERSION;
+	xattr_acl->a_flags = acl->a_flags;
+	xattr_acl->a_unused = 0;
+
+	xattr_acl->a_owner_mask = cpu_to_le32(acl->a_owner_mask);
+	xattr_acl->a_group_mask = cpu_to_le32(acl->a_group_mask);
+	xattr_acl->a_other_mask = cpu_to_le32(acl->a_other_mask);
+
+	xattr_ace = (void *)(xattr_acl + 1);
+	richacl_for_each_entry(ace, acl) {
+		xattr_ace->e_type = cpu_to_le16(ace->e_type);
+		xattr_ace->e_flags = cpu_to_le16(ace->e_flags);
+		xattr_ace->e_mask = cpu_to_le32(ace->e_mask);
+		if (ace->e_flags & RICHACE_SPECIAL_WHO)
+			xattr_ace->e_id = cpu_to_le32(ace->e_id.special);
+		else if (ace->e_flags & RICHACE_IDENTIFIER_GROUP)
+			xattr_ace->e_id =
+				cpu_to_le32(from_kgid(user_ns, ace->e_id.gid));
+		else
+			xattr_ace->e_id =
+				cpu_to_le32(from_kuid(user_ns, ace->e_id.uid));
+		xattr_ace++;
+	}
+	return real_size;
+}
+EXPORT_SYMBOL_GPL(richacl_to_xattr);
+
+/*
+ * Fix up the uids and gids in richacl extended attributes in place.
+ */
+static void richacl_fix_xattr_userns(
+	struct user_namespace *to, struct user_namespace *from,
+	void *value, size_t size)
+{
+	struct richacl_xattr *xattr_acl = value;
+	struct richace_xattr *xattr_ace =
+		(struct richace_xattr *)(xattr_acl + 1);
+	unsigned int count;
+
+	if (!value)
+		return;
+	if (size < sizeof(*xattr_acl))
+		return;
+	if (xattr_acl->a_version != cpu_to_le32(RICHACL_XATTR_VERSION))
+		return;
+	size -= sizeof(*xattr_acl);
+	if (size % sizeof(*xattr_ace))
+		return;
+	count = size / sizeof(*xattr_ace);
+	for (; count; count--, xattr_ace++) {
+		if (xattr_ace->e_flags & cpu_to_le16(RICHACE_SPECIAL_WHO))
+			continue;
+		if (xattr_ace->e_flags & cpu_to_le16(RICHACE_IDENTIFIER_GROUP)) {
+			kgid_t gid = make_kgid(from, le32_to_cpu(xattr_ace->e_id));
+			xattr_ace->e_id = cpu_to_le32(from_kgid(to, gid));
+		} else {
+			kuid_t uid = make_kuid(from, le32_to_cpu(xattr_ace->e_id));
+			xattr_ace->e_id = cpu_to_le32(from_kuid(to, uid));
+		}
+	}
+}
+
+void richacl_fix_xattr_from_user(void *value, size_t size)
+{
+	struct user_namespace *user_ns = current_user_ns();
+	if (user_ns == &init_user_ns)
+		return;
+	richacl_fix_xattr_userns(&init_user_ns, user_ns, value, size);
+}
+
+void richacl_fix_xattr_to_user(void *value, size_t size)
+{
+	struct user_namespace *user_ns = current_user_ns();
+	if (user_ns == &init_user_ns)
+		return;
+	richacl_fix_xattr_userns(user_ns, &init_user_ns, value, size);
+}
diff --git a/fs/xattr.c b/fs/xattr.c
index 4ef6985..a09e654 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -21,6 +21,7 @@
 #include <linux/audit.h>
 #include <linux/vmalloc.h>
 #include <linux/posix_acl_xattr.h>
+#include <linux/richacl_xattr.h>
 
 #include <asm/uaccess.h>
 
@@ -314,6 +315,18 @@ vfs_removexattr(struct dentry *dentry, const char *name)
 }
 EXPORT_SYMBOL_GPL(vfs_removexattr);
 
+static void
+fix_xattr_from_user(const char *kname, void *kvalue, size_t size)
+{
+	if (strncmp(kname, XATTR_SYSTEM_PREFIX, XATTR_SYSTEM_PREFIX_LEN))
+		return;
+	kname += XATTR_SYSTEM_PREFIX_LEN;
+	if (!strcmp(kname, XATTR_POSIX_ACL_ACCESS) ||
+	    !strcmp(kname, XATTR_POSIX_ACL_DEFAULT))
+		posix_acl_fix_xattr_from_user(kvalue, size);
+	else if (!strcmp(kname, XATTR_RICHACL))
+		richacl_fix_xattr_from_user(kvalue, size);
+}
 
 /*
  * Extended attribute SET operations
@@ -350,9 +363,7 @@ setxattr(struct dentry *d, const char __user *name, const void __user *value,
 			error = -EFAULT;
 			goto out;
 		}
-		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
-		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
-			posix_acl_fix_xattr_from_user(kvalue, size);
+		fix_xattr_from_user(kname, kvalue, size);
 	}
 
 	error = vfs_setxattr(d, kname, kvalue, size, flags);
@@ -419,6 +430,19 @@ SYSCALL_DEFINE5(fsetxattr, int, fd, const char __user *, name,
 	return error;
 }
 
+static void
+fix_xattr_to_user(const char *kname, void *kvalue, size_t size)
+{
+	if (strncmp(kname, XATTR_SYSTEM_PREFIX, XATTR_SYSTEM_PREFIX_LEN))
+		return;
+	kname += XATTR_SYSTEM_PREFIX_LEN;
+	if (!strcmp(kname, XATTR_POSIX_ACL_ACCESS) ||
+	    !strcmp(kname, XATTR_POSIX_ACL_DEFAULT))
+		posix_acl_fix_xattr_to_user(kvalue, size);
+	else if (!strcmp(kname, XATTR_RICHACL))
+		richacl_fix_xattr_to_user(kvalue, size);
+}
+
 /*
  * Extended attribute GET operations
  */
@@ -451,9 +475,7 @@ getxattr(struct dentry *d, const char __user *name, void __user *value,
 
 	error = vfs_getxattr(d, kname, kvalue, size);
 	if (error > 0) {
-		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
-		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
-			posix_acl_fix_xattr_to_user(kvalue, size);
+		fix_xattr_to_user(kname, kvalue, size);
 		if (size && copy_to_user(value, kvalue, error))
 			error = -EFAULT;
 	} else if (error == -ERANGE && size >= XATTR_SIZE_MAX) {
diff --git a/include/linux/richacl_xattr.h b/include/linux/richacl_xattr.h
new file mode 100644
index 0000000..13cf746
--- /dev/null
+++ b/include/linux/richacl_xattr.h
@@ -0,0 +1,52 @@
+/*
+ * Copyright (C) 2006, 2010  Novell, Inc.
+ * Copyright (C) 2015  Red Hat, Inc.
+ * Written by Andreas Gruenbacher <agruen@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2, or (at your option) any
+ * later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+#ifndef __RICHACL_XATTR_H
+#define __RICHACL_XATTR_H
+
+#include <linux/richacl.h>
+
+#define RICHACL_XATTR "system.richacl"
+
+struct richace_xattr {
+	__le16		e_type;
+	__le16		e_flags;
+	__le32		e_mask;
+	__le32		e_id;
+};
+
+struct richacl_xattr {
+	unsigned char	a_version;
+	unsigned char	a_flags;
+	__le16		a_unused;
+	__le32		a_owner_mask;
+	__le32		a_group_mask;
+	__le32		a_other_mask;
+};
+
+#define RICHACL_XATTR_VERSION	0
+#define RICHACL_XATTR_MAX_COUNT \
+	((XATTR_SIZE_MAX - sizeof(struct richacl_xattr)) / \
+	 sizeof(struct richace_xattr))
+
+extern struct richacl *richacl_from_xattr(struct user_namespace *, const void *, size_t);
+extern size_t richacl_xattr_size(const struct richacl *);
+extern int richacl_to_xattr(struct user_namespace *, const struct richacl *, void *, size_t);
+
+extern void richacl_fix_xattr_from_user(void *, size_t);
+extern void richacl_fix_xattr_to_user(void *, size_t);
+
+#endif /* __RICHACL_XATTR_H */
diff --git a/include/uapi/linux/xattr.h b/include/uapi/linux/xattr.h
index 1590c49..1996903 100644
--- a/include/uapi/linux/xattr.h
+++ b/include/uapi/linux/xattr.h
@@ -73,5 +73,7 @@
 #define XATTR_POSIX_ACL_DEFAULT  "posix_acl_default"
 #define XATTR_NAME_POSIX_ACL_DEFAULT XATTR_SYSTEM_PREFIX XATTR_POSIX_ACL_DEFAULT
 
+#define XATTR_RICHACL "richacl"
+#define XATTR_NAME_RICHACL XATTR_SYSTEM_PREFIX XATTR_RICHACL
 
 #endif /* _UAPI_LINUX_XATTR_H */
-- 
2.1.0

