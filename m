Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:39205 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753914AbbBYXm0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Feb 2015 18:42:26 -0500
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 13/21] richacl: Create-time inheritance
Date: Thu, 26 Feb 2015 00:41:34 +0100
Message-Id: <213ba5b03fffbcf6a7ff78a3585568eff7b43527.1424907511.git.agruenba@redhat.com>
In-Reply-To: <cover.1424907511.git.agruenba@redhat.com>
References: <cover.1424907511.git.agruenba@redhat.com>
In-Reply-To: <cover.1424907511.git.agruenba@redhat.com>
References: <cover.1424907511.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a new file is created, it can inherit an acl from its parent
directory; this is similar to how default acls work in POSIX (draft)
ACLs.

As with POSIX ACLs, if a file inherits an acl from its parent directory,
the intersection between the create mode and the permissions granted by
the inherited acl determines the file masks and file permission bits,
and the umask is ignored.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/Makefile             |  2 +-
 fs/richacl_base.c       | 69 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/richacl_inode.c      | 62 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  4 +++
 4 files changed, 136 insertions(+), 1 deletion(-)
 create mode 100644 fs/richacl_inode.c

diff --git a/fs/Makefile b/fs/Makefile
index 8f0a59c..bb96ad7 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -48,7 +48,7 @@ obj-$(CONFIG_SYSCTL)		+= drop_caches.o
 
 obj-$(CONFIG_FHANDLE)		+= fhandle.o
 obj-$(CONFIG_FS_RICHACL)	+= richacl.o
-richacl-y			:= richacl_base.o
+richacl-y			:= richacl_base.o richacl_inode.o
 
 obj-y				+= quota/
 
diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 7723bc8..8d9dc2c 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -452,3 +452,72 @@ is_everyone:
 	return denied ? -EACCES : 0;
 }
 EXPORT_SYMBOL_GPL(richacl_permission);
+
+/**
+ * richacl_inherit  -  compute the inherited acl of a new file
+ * @dir_acl:	acl of the containing directory
+ * @isdir:	inherit by a directory or non-directory?
+ *
+ * A directory can have acl entries which files and/or directories created
+ * inside the directory will inherit.  This function computes the acl for such
+ * a new file.  If there is no inheritable acl, it will return %NULL.
+ */
+struct richacl *
+richacl_inherit(const struct richacl *dir_acl, int isdir)
+{
+	const struct richace *dir_ace;
+	struct richacl *acl = NULL;
+	struct richace *ace;
+	int count = 0;
+
+	if (isdir) {
+		richacl_for_each_entry(dir_ace, dir_acl) {
+			if (!richace_is_inheritable(dir_ace))
+				continue;
+			count++;
+		}
+		if (!count)
+			return NULL;
+		acl = richacl_alloc(count);
+		if (!acl)
+			return ERR_PTR(-ENOMEM);
+		ace = acl->a_entries;
+		richacl_for_each_entry(dir_ace, dir_acl) {
+			if (!richace_is_inheritable(dir_ace))
+				continue;
+			memcpy(ace, dir_ace, sizeof(struct richace));
+			if (dir_ace->e_flags & ACE4_NO_PROPAGATE_INHERIT_ACE)
+				richace_clear_inheritance_flags(ace);
+			if ((dir_ace->e_flags & ACE4_FILE_INHERIT_ACE) &&
+			    !(dir_ace->e_flags & ACE4_DIRECTORY_INHERIT_ACE))
+				ace->e_flags |= ACE4_INHERIT_ONLY_ACE;
+			ace++;
+		}
+	} else {
+		richacl_for_each_entry(dir_ace, dir_acl) {
+			if (!(dir_ace->e_flags & ACE4_FILE_INHERIT_ACE))
+				continue;
+			count++;
+		}
+		if (!count)
+			return NULL;
+		acl = richacl_alloc(count);
+		if (!acl)
+			return ERR_PTR(-ENOMEM);
+		ace = acl->a_entries;
+		richacl_for_each_entry(dir_ace, dir_acl) {
+			if (!(dir_ace->e_flags & ACE4_FILE_INHERIT_ACE))
+				continue;
+			memcpy(ace, dir_ace, sizeof(struct richace));
+			richace_clear_inheritance_flags(ace);
+			/*
+			 * ACE4_DELETE_CHILD is meaningless for
+			 * non-directories, so clear it.
+			 */
+			ace->e_mask &= ~ACE4_DELETE_CHILD;
+			ace++;
+		}
+	}
+
+	return acl;
+}
diff --git a/fs/richacl_inode.c b/fs/richacl_inode.c
new file mode 100644
index 0000000..b95a584
--- /dev/null
+++ b/fs/richacl_inode.c
@@ -0,0 +1,62 @@
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
+#include <linux/richacl.h>
+
+/**
+ * richacl_inherit_inode  -  compute inherited acl and file mode
+ * @dir_acl:	acl of the containing directory
+ * @inode:	inode of the new file (create mode in i_mode)
+ *
+ * The file permission bits in inode->i_mode must be set to the create mode by
+ * the caller.
+ *
+ * If there is an inheritable acl, the maximum permissions that the acl grants
+ * will be computed and permissions not granted by the acl will be removed from
+ * inode->i_mode.  If there is no inheritable acl, the umask will be applied
+ * instead.
+ */
+struct richacl *
+richacl_inherit_inode(const struct richacl *dir_acl, struct inode *inode)
+{
+	struct richacl *acl;
+	mode_t mask;
+
+	acl = richacl_inherit(dir_acl, S_ISDIR(inode->i_mode));
+	if (acl) {
+
+		richacl_compute_max_masks(acl);
+
+		/*
+		 * Ensure that the acl will not grant any permissions beyond
+		 * the create mode.
+		 */
+		acl->a_flags |= ACL4_MASKED;
+		acl->a_owner_mask &= richacl_mode_to_mask(inode->i_mode >> 6) |
+				     ACE4_POSIX_OWNER_ALLOWED;
+		acl->a_group_mask &= richacl_mode_to_mask(inode->i_mode >> 3);
+		acl->a_other_mask &= richacl_mode_to_mask(inode->i_mode);
+		mask = ~S_IRWXUGO | richacl_masks_to_mode(acl);
+	} else
+		mask = ~current_umask();
+
+	inode->i_mode &= mask;
+	return acl;
+}
+EXPORT_SYMBOL_GPL(richacl_inherit_inode);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index d92e1c2..fd3eeb4 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -293,5 +293,9 @@ extern unsigned int richacl_want_to_mask(unsigned int);
 extern void richacl_compute_max_masks(struct richacl *);
 extern struct richacl *richacl_chmod(struct richacl *, mode_t);
 extern int richacl_permission(struct inode *, const struct richacl *, int);
+extern struct richacl *richacl_inherit(const struct richacl *, int);
 
+/* richacl_inode.c */
+extern struct richacl *richacl_inherit_inode(const struct richacl *,
+					     struct inode *);
 #endif /* __RICHACL_H */
-- 
2.1.0

