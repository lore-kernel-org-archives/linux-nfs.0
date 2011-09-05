Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:46935 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285Ab1IER2x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2011 13:28:53 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V6 21/26] richacl: xattr mapping functions
Date: Mon,  5 Sep 2011 22:55:43 +0530
Message-Id: <1315243548-18664-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andreas Gruenbacher <agruen@kernel.org>

Map between "system.richacl" xattrs and the in-kernel representation.

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/Makefile                   |    2 +-
 fs/richacl_xattr.c            |  156 +++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl_xattr.h |   47 ++++++++++++
 3 files changed, 204 insertions(+), 1 deletions(-)
 create mode 100644 fs/richacl_xattr.c
 create mode 100644 include/linux/richacl_xattr.h

diff --git a/fs/Makefile b/fs/Makefile
index 1ecf9f2..e217c65 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -49,7 +49,7 @@ obj-$(CONFIG_GENERIC_ACL)	+= generic_acl.o
 
 obj-$(CONFIG_FHANDLE)		+= fhandle.o
 obj-$(CONFIG_FS_RICHACL)	+= richacl.o
-richacl-y			:= richacl_base.o richacl_inode.o
+richacl-y			:= richacl_base.o richacl_inode.o richacl_xattr.o
 
 obj-y				+= quota/
 
diff --git a/fs/richacl_xattr.c b/fs/richacl_xattr.c
new file mode 100644
index 0000000..02a7986
--- /dev/null
+++ b/fs/richacl_xattr.c
@@ -0,0 +1,156 @@
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
+#include <linux/kernel.h>
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
+richacl_from_xattr(const void *value, size_t size)
+{
+	const struct richacl_xattr *xattr_acl = value;
+	const struct richace_xattr *xattr_ace = (void *)(xattr_acl + 1);
+	struct richacl *acl;
+	struct richace *ace;
+	int count;
+
+	if (size < sizeof(struct richacl_xattr) ||
+	    xattr_acl->a_version != ACL4_XATTR_VERSION ||
+	    (xattr_acl->a_flags & ~ACL4_VALID_FLAGS))
+		return ERR_PTR(-EINVAL);
+
+	count = le16_to_cpu(xattr_acl->a_count);
+	if (count > ACL4_XATTR_MAX_COUNT)
+		return ERR_PTR(-EINVAL);
+
+	acl = richacl_alloc(count);
+	if (!acl)
+		return ERR_PTR(-ENOMEM);
+
+	acl->a_flags = xattr_acl->a_flags;
+	acl->a_owner_mask = le32_to_cpu(xattr_acl->a_owner_mask);
+	if (acl->a_owner_mask & ~ACE4_VALID_MASK)
+		goto fail_einval;
+	acl->a_group_mask = le32_to_cpu(xattr_acl->a_group_mask);
+	if (acl->a_group_mask & ~ACE4_VALID_MASK)
+		goto fail_einval;
+	acl->a_other_mask = le32_to_cpu(xattr_acl->a_other_mask);
+	if (acl->a_other_mask & ~ACE4_VALID_MASK)
+		goto fail_einval;
+
+	richacl_for_each_entry(ace, acl) {
+		const char *who = (void *)(xattr_ace + 1), *end;
+		ssize_t used = (void *)who - value;
+
+		if (used > size)
+			goto fail_einval;
+		end = memchr(who, 0, size - used);
+		if (!end)
+			goto fail_einval;
+
+		ace->e_type = le16_to_cpu(xattr_ace->e_type);
+		ace->e_flags = le16_to_cpu(xattr_ace->e_flags);
+		ace->e_mask = le32_to_cpu(xattr_ace->e_mask);
+		ace->u.e_id = le32_to_cpu(xattr_ace->e_id);
+
+		if (ace->e_flags & ~ACE4_VALID_FLAGS)
+			goto fail_einval;
+		if (ace->e_type > ACE4_ACCESS_DENIED_ACE_TYPE ||
+		    (ace->e_mask & ~ACE4_VALID_MASK))
+			goto fail_einval;
+
+		if (who == end) {
+			if (ace->u.e_id == -1)
+				goto fail_einval;  /* uid/gid needed */
+		} else if (richace_set_who(ace, who))
+			goto fail_einval;
+
+		xattr_ace = (void *)who + ALIGN(end - who + 1, 4);
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
+	const struct richace *ace;
+
+	richacl_for_each_entry(ace, acl) {
+		size += sizeof(struct richace_xattr) +
+			(richace_is_unix_id(ace) ? 4 :
+			 ALIGN(strlen(ace->u.e_who) + 1, 4));
+	}
+	return size;
+}
+EXPORT_SYMBOL_GPL(richacl_xattr_size);
+
+/**
+ * richacl_to_xattr  -  convert @acl into its xattr representation
+ * @acl:	the richacl to convert
+ * @buffer:	buffer of size richacl_xattr_size(@acl) for the result
+ */
+void
+richacl_to_xattr(const struct richacl *acl, void *buffer)
+{
+	struct richacl_xattr *xattr_acl = buffer;
+	struct richace_xattr *xattr_ace;
+	const struct richace *ace;
+
+	xattr_acl->a_version = ACL4_XATTR_VERSION;
+	xattr_acl->a_flags = acl->a_flags;
+	xattr_acl->a_count = cpu_to_le16(acl->a_count);
+
+	xattr_acl->a_owner_mask = cpu_to_le32(acl->a_owner_mask);
+	xattr_acl->a_group_mask = cpu_to_le32(acl->a_group_mask);
+	xattr_acl->a_other_mask = cpu_to_le32(acl->a_other_mask);
+
+	xattr_ace = (void *)(xattr_acl + 1);
+	richacl_for_each_entry(ace, acl) {
+		xattr_ace->e_type = cpu_to_le16(ace->e_type);
+		xattr_ace->e_flags = cpu_to_le16(ace->e_flags &
+						 ACE4_VALID_FLAGS);
+		xattr_ace->e_mask = cpu_to_le32(ace->e_mask);
+		if (richace_is_unix_id(ace)) {
+			xattr_ace->e_id = cpu_to_le32(ace->u.e_id);
+			memset(xattr_ace->e_who, 0, 4);
+			xattr_ace = (void *)xattr_ace->e_who + 4;
+		} else {
+			int sz = ALIGN(strlen(ace->u.e_who) + 1, 4);
+
+			xattr_ace->e_id = cpu_to_le32(-1);
+			memset(xattr_ace->e_who + sz - 4, 0, 4);
+			strcpy(xattr_ace->e_who, ace->u.e_who);
+			xattr_ace = (void *)xattr_ace->e_who + sz;
+		}
+	}
+}
+EXPORT_SYMBOL_GPL(richacl_to_xattr);
diff --git a/include/linux/richacl_xattr.h b/include/linux/richacl_xattr.h
new file mode 100644
index 0000000..f79ec12
--- /dev/null
+++ b/include/linux/richacl_xattr.h
@@ -0,0 +1,47 @@
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
+	char		e_who[0];
+};
+
+struct richacl_xattr {
+	unsigned char	a_version;
+	unsigned char	a_flags;
+	__le16		a_count;
+	__le32		a_owner_mask;
+	__le32		a_group_mask;
+	__le32		a_other_mask;
+};
+
+#define ACL4_XATTR_VERSION	0
+#define ACL4_XATTR_MAX_COUNT	1024
+
+extern struct richacl *richacl_from_xattr(const void *, size_t);
+extern size_t richacl_xattr_size(const struct richacl *acl);
+extern void richacl_to_xattr(const struct richacl *, void *);
+
+#endif /* __RICHACL_XATTR_H */
-- 
1.7.4.1

