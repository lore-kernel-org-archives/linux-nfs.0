Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:40395 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366AbaD0QPo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Apr 2014 12:15:44 -0400
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 28 Apr 2014 02:15:42 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V1 10/22] richacl: In-memory representation and helper functions
Date: Sun, 27 Apr 2014 21:44:41 +0530
Message-Id: <1398615293-22931-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

A richacl consists of an NFSv4 acl and an owner, group, and other mask.
These three masks correspond to the owner, group, and other file
permission bits, but they contain NFSv4 permissions instead of POSIX
permissions.

Each entry in the NFSv4 acl applies to the file owner (OWNER@), the
owning group (GROUP@), literally everyone (EVERYONE@), or to a specific
uid or gid.

As in the standard POSIX file permission model, each process is the
owner, group, or other file class.  A richacl grants a requested access
only if the NFSv4 acl in the richacl grants the access (according to the
NFSv4 permission check algorithm), and the file mask that applies to the
process includes the requested permissions.

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/Makefile             |   2 +
 fs/richacl_base.c       |  69 ++++++++++++++
 include/linux/richacl.h | 237 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 308 insertions(+)
 create mode 100644 fs/richacl_base.c
 create mode 100644 include/linux/richacl.h

diff --git a/fs/Makefile b/fs/Makefile
index f9cb9876e466..5b7ed5d022ec 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -48,6 +48,8 @@ obj-$(CONFIG_COREDUMP)		+= coredump.o
 obj-$(CONFIG_SYSCTL)		+= drop_caches.o
 
 obj-$(CONFIG_FHANDLE)		+= fhandle.o
+obj-$(CONFIG_FS_RICHACL)	+= richacl.o
+richacl-y			:= richacl_base.o
 
 obj-y				+= quota/
 
diff --git a/fs/richacl_base.c b/fs/richacl_base.c
new file mode 100644
index 000000000000..689e1a6dace7
--- /dev/null
+++ b/fs/richacl_base.c
@@ -0,0 +1,69 @@
+/*
+ * Copyright (C) 2006, 2010  Novell, Inc.
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
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/richacl.h>
+
+MODULE_LICENSE("GPL");
+
+/**
+ * richacl_alloc  -  allocate a richacl
+ * @count:	number of entries
+ */
+struct richacl *
+richacl_alloc(int count)
+{
+	size_t size = sizeof(struct richacl) + count * sizeof(struct richace);
+	struct richacl *acl = kzalloc(size, GFP_KERNEL);
+
+	if (acl) {
+		atomic_set(&acl->a_refcount, 1);
+		acl->a_count = count;
+	}
+	return acl;
+}
+EXPORT_SYMBOL_GPL(richacl_alloc);
+
+/**
+ * richacl_clone  -  create a copy of a richacl
+ */
+static struct richacl *
+richacl_clone(const struct richacl *acl)
+{
+	int count = acl->a_count;
+	size_t size = sizeof(struct richacl) + count * sizeof(struct richace);
+	struct richacl *dup = kmalloc(size, GFP_KERNEL);
+
+	if (dup) {
+		memcpy(dup, acl, size);
+		atomic_set(&dup->a_refcount, 1);
+	}
+	return dup;
+}
+
+/**
+ * richace_is_same_identifier  -  are both identifiers the same?
+ */
+int
+richace_is_same_identifier(const struct richace *a, const struct richace *b)
+{
+#define WHO_FLAGS (ACE4_SPECIAL_WHO | ACE4_IDENTIFIER_GROUP)
+	if ((a->e_flags & WHO_FLAGS) != (b->e_flags & WHO_FLAGS))
+		return 0;
+	return a->e_id == b->e_id;
+#undef WHO_FLAGS
+}
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
new file mode 100644
index 000000000000..51d6937651f1
--- /dev/null
+++ b/include/linux/richacl.h
@@ -0,0 +1,237 @@
+/*
+ * Copyright (C) 2006, 2010  Novell, Inc.
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
+#ifndef __RICHACL_H
+#define __RICHACL_H
+#include <linux/slab.h>
+
+#define ACE_OWNER_ID		130
+#define ACE_GROUP_ID		131
+#define ACE_EVERYONE_ID		110
+
+struct richace {
+	unsigned short	e_type;
+	unsigned short	e_flags;
+	unsigned int	e_mask;
+	unsigned int	e_id;
+};
+
+struct richacl {
+	atomic_t	a_refcount;
+	unsigned int	a_owner_mask;
+	unsigned int	a_group_mask;
+	unsigned int	a_other_mask;
+	unsigned short	a_count;
+	unsigned short	a_flags;
+	struct richace	a_entries[0];
+};
+
+#define richacl_for_each_entry(_ace, _acl) \
+	for (_ace = _acl->a_entries; \
+	     _ace != _acl->a_entries + _acl->a_count; \
+	     _ace++)
+
+#define richacl_for_each_entry_reverse(_ace, _acl) \
+	for (_ace = _acl->a_entries + _acl->a_count - 1; \
+	     _ace != _acl->a_entries - 1; \
+	     _ace--)
+
+/* Flag values defined by rich-acl */
+#define ACL4_MASKED			0x80
+
+#define ACL4_VALID_FLAGS (			\
+		ACL4_MASKED)
+
+/* e_type values */
+#define ACE4_ACCESS_ALLOWED_ACE_TYPE	0x0000
+#define ACE4_ACCESS_DENIED_ACE_TYPE	0x0001
+/*#define ACE4_SYSTEM_AUDIT_ACE_TYPE	0x0002*/
+/*#define ACE4_SYSTEM_ALARM_ACE_TYPE	0x0003*/
+
+/* e_flags bitflags */
+#define ACE4_FILE_INHERIT_ACE		0x0001
+#define ACE4_DIRECTORY_INHERIT_ACE	0x0002
+#define ACE4_NO_PROPAGATE_INHERIT_ACE	0x0004
+#define ACE4_INHERIT_ONLY_ACE		0x0008
+/*#define ACE4_SUCCESSFUL_ACCESS_ACE_FLAG	0x0010*/
+/*#define ACE4_FAILED_ACCESS_ACE_FLAG	0x0020*/
+#define ACE4_IDENTIFIER_GROUP		0x0040
+/* richacl specific flag values */
+#define ACE4_SPECIAL_WHO		0x4000
+
+#define ACE4_VALID_FLAGS (			\
+	ACE4_FILE_INHERIT_ACE |			\
+	ACE4_DIRECTORY_INHERIT_ACE |		\
+	ACE4_NO_PROPAGATE_INHERIT_ACE |		\
+	ACE4_INHERIT_ONLY_ACE |			\
+	ACE4_IDENTIFIER_GROUP |			\
+	ACE4_SPECIAL_WHO)
+
+/* e_mask bitflags */
+#define ACE4_READ_DATA			0x00000001
+#define ACE4_LIST_DIRECTORY		0x00000001
+#define ACE4_WRITE_DATA			0x00000002
+#define ACE4_ADD_FILE			0x00000002
+#define ACE4_APPEND_DATA		0x00000004
+#define ACE4_ADD_SUBDIRECTORY		0x00000004
+#define ACE4_READ_NAMED_ATTRS		0x00000008
+#define ACE4_WRITE_NAMED_ATTRS		0x00000010
+#define ACE4_EXECUTE			0x00000020
+#define ACE4_DELETE_CHILD		0x00000040
+#define ACE4_READ_ATTRIBUTES		0x00000080
+#define ACE4_WRITE_ATTRIBUTES		0x00000100
+#define ACE4_WRITE_RETENTION		0x00000200
+#define ACE4_WRITE_RETENTION_HOLD	0x00000400
+#define ACE4_DELETE			0x00010000
+#define ACE4_READ_ACL			0x00020000
+#define ACE4_WRITE_ACL			0x00040000
+#define ACE4_WRITE_OWNER		0x00080000
+#define ACE4_SYNCHRONIZE		0x00100000
+
+/* Valid ACE4_* flags for directories and non-directories */
+#define ACE4_VALID_MASK (				\
+	ACE4_READ_DATA | ACE4_LIST_DIRECTORY |		\
+	ACE4_WRITE_DATA | ACE4_ADD_FILE |		\
+	ACE4_APPEND_DATA | ACE4_ADD_SUBDIRECTORY |	\
+	ACE4_READ_NAMED_ATTRS |				\
+	ACE4_WRITE_NAMED_ATTRS |			\
+	ACE4_EXECUTE |					\
+	ACE4_DELETE_CHILD |				\
+	ACE4_READ_ATTRIBUTES |				\
+	ACE4_WRITE_ATTRIBUTES |				\
+	ACE4_WRITE_RETENTION |				\
+	ACE4_WRITE_RETENTION_HOLD |			\
+	ACE4_DELETE |					\
+	ACE4_READ_ACL |					\
+	ACE4_WRITE_ACL |				\
+	ACE4_WRITE_OWNER |				\
+	ACE4_SYNCHRONIZE)
+
+/**
+ * richacl_get  -  grab another reference to a richacl handle
+ */
+static inline struct richacl *
+richacl_get(struct richacl *acl)
+{
+	if (acl)
+		atomic_inc(&acl->a_refcount);
+	return acl;
+}
+
+/**
+ * richacl_put  -  free a richacl handle
+ */
+static inline void
+richacl_put(struct richacl *acl)
+{
+	if (acl && atomic_dec_and_test(&acl->a_refcount))
+		kfree(acl);
+}
+
+/**
+ * richace_is_owner  -  check if @ace is an OWNER@ entry
+ */
+static inline int
+richace_is_owner(const struct richace *ace)
+{
+	return (ace->e_flags & ACE4_SPECIAL_WHO) &&
+	       ace->e_id == ACE_OWNER_ID;
+}
+
+/**
+ * richace_is_group  -  check if @ace is a GROUP@ entry
+ */
+static inline int
+richace_is_group(const struct richace *ace)
+{
+	return (ace->e_flags & ACE4_SPECIAL_WHO) &&
+	       ace->e_id == ACE_GROUP_ID;
+}
+
+/**
+ * richace_is_everyone  -  check if @ace is an EVERYONE@ entry
+ */
+static inline int
+richace_is_everyone(const struct richace *ace)
+{
+	return (ace->e_flags & ACE4_SPECIAL_WHO) &&
+	       ace->e_id == ACE_EVERYONE_ID;
+}
+
+/**
+ * richace_is_unix_id  -  check if @ace applies to a specific uid or gid
+ */
+static inline int
+richace_is_unix_id(const struct richace *ace)
+{
+	return !(ace->e_flags & ACE4_SPECIAL_WHO);
+}
+
+/**
+ * richace_is_inherit_only  -  check if @ace is for inheritance only
+ *
+ * ACEs with the %ACE4_INHERIT_ONLY_ACE flag set have no effect during
+ * permission checking.
+ */
+static inline int
+richace_is_inherit_only(const struct richace *ace)
+{
+	return ace->e_flags & ACE4_INHERIT_ONLY_ACE;
+}
+
+/**
+ * richace_is_inheritable  -  check if @ace is inheritable
+ */
+static inline int
+richace_is_inheritable(const struct richace *ace)
+{
+	return ace->e_flags & (ACE4_FILE_INHERIT_ACE |
+			       ACE4_DIRECTORY_INHERIT_ACE);
+}
+
+/**
+ * richace_clear_inheritance_flags  - clear all inheritance flags in @ace
+ */
+static inline void
+richace_clear_inheritance_flags(struct richace *ace)
+{
+	ace->e_flags &= ~(ACE4_FILE_INHERIT_ACE |
+			  ACE4_DIRECTORY_INHERIT_ACE |
+			  ACE4_NO_PROPAGATE_INHERIT_ACE |
+			  ACE4_INHERIT_ONLY_ACE);
+}
+
+/**
+ * richace_is_allow  -  check if @ace is an %ALLOW type entry
+ */
+static inline int
+richace_is_allow(const struct richace *ace)
+{
+	return ace->e_type == ACE4_ACCESS_ALLOWED_ACE_TYPE;
+}
+
+/**
+ * richace_is_deny  -  check if @ace is a %DENY type entry
+ */
+static inline int
+richace_is_deny(const struct richace *ace)
+{
+	return ace->e_type == ACE4_ACCESS_DENIED_ACE_TYPE;
+}
+
+extern struct richacl *richacl_alloc(int);
+extern int richace_is_same_identifier(const struct richace *,
+				      const struct richace *);
+#endif /* __RICHACL_H */
-- 
1.9.1

