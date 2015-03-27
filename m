Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38573 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753988AbbC0QwL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:52:11 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Cc: Andreas Gruenbacher <agruen@kernel.org>
Subject: [RFC 23/39] richacl: acl editing helper functions
Date: Fri, 27 Mar 2015 17:50:21 +0100
Message-Id: <147aeaac8b254d02de01bc9db5b61bc713d1bf1a.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The file masks in richacls make chmod and creating new files more
efficient than having to apply file permission bits to the acl directly.
They also allow us to regain permissions from an acl even after a
restrictive chmod, because the permissions in the acl itself are not
being destroyed.  In POSIX ACLs, the mask entry has a similar function.

Protocols like nfsv4 do not understand file masks.  For those protocols,
we need to compute nfs4 acls which represent the effective permissions
granted by a richacl: we need to "apply" the file masks to the acl.

This is the first in a series of richacl transformation patches; it
implements basic richacl editing functions.  The following patches
implement algorithms for transforming a richacl so that it can be
evaluated as a plain nfs4 acl, with identical permission check results.

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
---
 fs/Makefile                    |   3 +-
 fs/richacl_compat.c            | 161 +++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl_compat.h |  40 ++++++++++
 3 files changed, 203 insertions(+), 1 deletion(-)
 create mode 100644 fs/richacl_compat.c
 create mode 100644 include/linux/richacl_compat.h

diff --git a/fs/Makefile b/fs/Makefile
index 6155cc4..5983276 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -48,7 +48,8 @@ obj-$(CONFIG_SYSCTL)		+= drop_caches.o
 
 obj-$(CONFIG_FHANDLE)		+= fhandle.o
 obj-$(CONFIG_FS_RICHACL)	+= richacl.o
-richacl-y			:= richacl_base.o richacl_inode.o richacl_xattr.o
+richacl-y			:= richacl_base.o richacl_inode.o \
+				   richacl_xattr.o richacl_compat.o
 
 obj-y				+= quota/
 
diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
new file mode 100644
index 0000000..5053a49e
--- /dev/null
+++ b/fs/richacl_compat.c
@@ -0,0 +1,161 @@
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
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/slab.h>
+#include <linux/richacl_compat.h>
+
+/**
+ * richacl_prepare  -  allocate richacl being constructed
+ *
+ * Allocate a richacl which can hold @count entries but which is initially
+ * empty.
+ */
+struct richacl *richacl_prepare(struct richacl_alloc *x, unsigned int count)
+{
+	x->acl = richacl_alloc(count, GFP_KERNEL);
+	if (!x->acl)
+		return NULL;
+	x->acl->a_count = 0;
+	x->count = count;
+	return x->acl;
+}
+EXPORT_SYMBOL(richacl_prepare);
+
+/**
+ * richacl_delete_entry  -  delete an entry in an acl
+ * @x:		acl and number of allocated entries
+ * @ace:	an entry in @x->acl
+ *
+ * Updates @ace so that it points to the entry before the deleted entry
+ * on return. (When deleting the first entry, @ace will point to the
+ * (non-existant) entry before the first entry). This behavior is the
+ * expected behavior when deleting entries while forward iterating over
+ * an acl.
+ */
+void
+richacl_delete_entry(struct richacl_alloc *x, struct richace **ace)
+{
+	void *end = x->acl->a_entries + x->acl->a_count;
+
+	memmove(*ace, *ace + 1, end - (void *)(*ace + 1));
+	(*ace)--;
+	x->acl->a_count--;
+}
+EXPORT_SYMBOL(richacl_delete_entry);
+
+/**
+ * richacl_insert_entry  -  insert an entry in an acl
+ * @x:		acl and number of allocated entries
+ * @ace:	entry before which the new entry shall be inserted
+ *
+ * Insert a new entry in @x->acl at position @ace and zero-initialize
+ * it.  This may require reallocating @x->acl.
+ */
+int
+richacl_insert_entry(struct richacl_alloc *x, struct richace **ace)
+{
+	if (x->count == x->acl->a_count) {
+		int n = *ace - x->acl->a_entries;
+		struct richacl *acl2;
+
+		acl2 = richacl_alloc(x->acl->a_count + 1, GFP_KERNEL);
+		if (!acl2)
+			return -1;
+		acl2->a_flags = x->acl->a_flags;
+		acl2->a_owner_mask = x->acl->a_owner_mask;
+		acl2->a_group_mask = x->acl->a_group_mask;
+		acl2->a_other_mask = x->acl->a_other_mask;
+		memcpy(acl2->a_entries, x->acl->a_entries,
+		       n * sizeof(struct richace));
+		memcpy(acl2->a_entries + n + 1, *ace,
+		       (x->acl->a_count - n) * sizeof(struct richace));
+		kfree(x->acl);
+		x->acl = acl2;
+		x->count = acl2->a_count;
+		*ace = acl2->a_entries + n;
+	} else {
+		void *end = x->acl->a_entries + x->acl->a_count;
+
+		memmove(*ace + 1, *ace, end - (void *)*ace);
+		x->acl->a_count++;
+	}
+	memset(*ace, 0, sizeof(struct richace));
+	return 0;
+}
+EXPORT_SYMBOL(richacl_insert_entry);
+
+/**
+ * richacl_append_entry  -  append an entry to an acl
+ * @x:		acl and number of allocated entries
+ *
+ * This may require reallocating @x->acl.
+ */
+struct richace *richacl_append_entry(struct richacl_alloc *x)
+{
+	struct richacl *acl = x->acl;
+	struct richace *ace = acl->a_entries + acl->a_count;
+
+	if (x->count > x->acl->a_count) {
+		acl->a_count++;
+		return ace;
+	}
+	return richacl_insert_entry(x, &ace) ? NULL : ace;
+}
+EXPORT_SYMBOL(richacl_append_entry);
+
+/**
+ * richace_change_mask  -  set the mask of @ace to @mask
+ * @x:		acl and number of allocated entries
+ * @ace:	entry to modify
+ * @mask:	new mask for @ace
+ *
+ * If @ace is inheritable, a inherit-only ace is inserted before @ace which
+ * includes the inheritable permissions of @ace and the inheritance flags of
+ * @ace are cleared before changing the mask.
+ *
+ * If @mode is 0, the original ace is turned into an inherit-only entry if
+ * there are any inheritable permissions, and removed otherwise.
+ *
+ * The returned @ace points to the modified or inserted effective-only acl
+ * entry if that entry exists, to the entry that has become inheritable-only,
+ * or else to the previous entry in the acl.
+ */
+static int
+richace_change_mask(struct richacl_alloc *x, struct richace **ace,
+			   unsigned int mask)
+{
+	if (mask && (*ace)->e_mask == mask)
+		return 0;
+	if (mask & ~RICHACE_POSIX_ALWAYS_ALLOWED) {
+		if (richace_is_inheritable(*ace)) {
+			if (richacl_insert_entry(x, ace))
+				return -1;
+			memcpy(*ace, *ace + 1, sizeof(struct richace));
+			(*ace)->e_flags |= RICHACE_INHERIT_ONLY_ACE;
+			(*ace)++;
+			richace_clear_inheritance_flags(*ace);
+		}
+		(*ace)->e_mask = mask;
+	} else {
+		if (richace_is_inheritable(*ace))
+			(*ace)->e_flags |= RICHACE_INHERIT_ONLY_ACE;
+		else
+			richacl_delete_entry(x, ace);
+	}
+	return 0;
+}
diff --git a/include/linux/richacl_compat.h b/include/linux/richacl_compat.h
new file mode 100644
index 0000000..a9ff630
--- /dev/null
+++ b/include/linux/richacl_compat.h
@@ -0,0 +1,40 @@
+/*
+ * Copyright (C) 2015  Red Hat, Inc.
+ * Written by Andreas Gruenbacher <agruenba@redhat.com>
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
+#ifndef __RICHACL_COMPAT_H
+#define __RICHACL_COMPAT_H
+
+#include <linux/richacl.h>
+
+/**
+ * struct richacl_alloc  -  remember how many entries are actually allocated
+ * @acl:	acl with a_count <= @count
+ * @count:	the actual number of entries allocated in @acl
+ *
+ * We pass around this structure while modifying an acl so that we do
+ * not have to reallocate when we remove existing entries followed by
+ * adding new entries.
+ */
+struct richacl_alloc {
+	struct richacl *acl;
+	unsigned int count;
+};
+
+struct richacl *richacl_prepare(struct richacl_alloc *, unsigned int);
+struct richace *richacl_append_entry(struct richacl_alloc *);
+int richacl_insert_entry(struct richacl_alloc *, struct richace **);
+void richacl_delete_entry(struct richacl_alloc *, struct richace **);
+
+#endif  /* __RICHACL_COMPAT_H */
-- 
2.1.0

