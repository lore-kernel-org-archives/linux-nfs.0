Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:37982 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189AbbFXV5r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2015 17:57:47 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        samba-technical@lists.samba.org, linux-security-module@vger.kernel.org
Subject: [RFC v4 10/31] richacl: Permission check algorithm
Date: Wed, 24 Jun 2015 23:56:59 +0200
Message-Id: <1435183040-22726-11-git-send-email-agruenba@redhat.com>
In-Reply-To: <1435183040-22726-1-git-send-email-agruenba@redhat.com>
References: <1435183040-22726-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A richacl roughly grants a requested access if the NFSv4 acl in the richacl
grants the requested permissions according to the NFSv4 permission check
algorithm and the file mask that applies to the process includes the requested
permissions.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/Makefile             |   2 +-
 fs/richacl_inode.c      | 122 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |   3 ++
 3 files changed, 126 insertions(+), 1 deletion(-)
 create mode 100644 fs/richacl_inode.c

diff --git a/fs/Makefile b/fs/Makefile
index 654e716..c3602b7 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -48,7 +48,7 @@ obj-$(CONFIG_SYSCTL)		+= drop_caches.o
 
 obj-$(CONFIG_FHANDLE)		+= fhandle.o
 obj-$(CONFIG_FS_RICHACL)	+= richacl.o
-richacl-y			:= richacl_base.o
+richacl-y			:= richacl_base.o richacl_inode.o
 
 obj-y				+= quota/
 
diff --git a/fs/richacl_inode.c b/fs/richacl_inode.c
new file mode 100644
index 0000000..159510b
--- /dev/null
+++ b/fs/richacl_inode.c
@@ -0,0 +1,122 @@
+/*
+ * Copyright (C) 2010  Novell, Inc.
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
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/slab.h>
+#include <linux/richacl.h>
+
+/**
+ * richacl_permission  -  richacl permission check algorithm
+ * @inode:	inode to check
+ * @acl:	rich acl of the inode
+ * @want:	requested access (MAY_* flags)
+ *
+ * Checks if the current process is granted @mask flags in @acl.
+ */
+int
+richacl_permission(struct inode *inode, const struct richacl *acl,
+		   int want)
+{
+	const struct richace *ace;
+	unsigned int mask = richacl_want_to_mask(want);
+	unsigned int requested = mask, denied = 0;
+	int in_owning_group = in_group_p(inode->i_gid);
+	int in_owner_or_group_class = in_owning_group;
+
+	/*
+	 * A process is
+	 *   - in the owner file class if it owns the file,
+	 *   - in the group file class if it is in the file's owning group or
+	 *     it matches any of the user or group entries, and
+	 *   - in the other file class otherwise.
+	 * The file class is only relevant for determining which file mask to
+	 * apply, which only happens for masked acls.
+	 */
+	if (acl->a_flags & RICHACL_MASKED) {
+		if (uid_eq(current_fsuid(), inode->i_uid)) {
+			denied = requested & ~acl->a_owner_mask;
+			goto out;
+		}
+	} else {
+		/*
+		 * We don't care which class the process is in when the acl is
+		 * not masked.
+		 */
+		in_owner_or_group_class = 1;
+	}
+
+	/*
+	 * Check if the acl grants the requested access and determine which
+	 * file class the process is in.
+	 */
+	richacl_for_each_entry(ace, acl) {
+		unsigned int ace_mask = ace->e_mask;
+
+		if (richace_is_inherit_only(ace))
+			continue;
+		if (richace_is_owner(ace)) {
+			if (!uid_eq(current_fsuid(), inode->i_uid))
+				continue;
+		} else if (richace_is_group(ace)) {
+			if (!in_owning_group)
+				continue;
+		} else if (richace_is_unix_user(ace)) {
+			kuid_t uid = current_fsuid();
+
+			if (!uid_eq(uid, ace->e_id.uid))
+				continue;
+		} else if (richace_is_unix_group(ace)) {
+			if (!in_group_p(ace->e_id.gid))
+				continue;
+		} else
+			goto entry_matches_everyone;
+
+		/* The process is in the owner or group file class. */
+		in_owner_or_group_class = 1;
+
+entry_matches_everyone:
+		/* Check which mask flags the ACE allows or denies. */
+		if (richace_is_deny(ace))
+			denied |= ace_mask & mask;
+		mask &= ~ace_mask;
+
+		/*
+		 * Keep going until we know which file class
+		 * the process is in.
+		 */
+		if (!mask && in_owner_or_group_class)
+			break;
+	}
+	denied |= mask;
+
+	if (acl->a_flags & RICHACL_MASKED) {
+		/*
+		 * The file class a process is in determines which file mask
+		 * applies.  Check if that file mask also grants the requested
+		 * access.
+		 */
+		if (in_owner_or_group_class)
+			denied |= requested & ~acl->a_group_mask;
+		else
+			denied = requested & ~acl->a_other_mask;
+	}
+
+out:
+	return denied ? -EACCES : 0;
+}
+EXPORT_SYMBOL_GPL(richacl_permission);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index c2a10b5..b828615 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -303,4 +303,7 @@ extern unsigned int richacl_want_to_mask(unsigned int);
 extern void richacl_compute_max_masks(struct richacl *, kuid_t);
 extern struct richacl *richacl_chmod(struct richacl *, mode_t);
 
+/* richacl_inode.c */
+extern int richacl_permission(struct inode *, const struct richacl *, int);
+
 #endif /* __RICHACL_H */
-- 
2.4.2

