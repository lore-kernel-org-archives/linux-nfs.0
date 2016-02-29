Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43876 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752661AbcB2ISF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Feb 2016 03:18:05 -0500
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        "Theodore Ts'o" <tytso@mit.edu>, linux-cifs@vger.kernel.org,
        linux-api@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com,
        Christoph Hellwig <hch@infradead.org>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>
Subject: [PATCH v18 09/22] richacl: Permission check algorithm
Date: Mon, 29 Feb 2016 09:17:14 +0100
Message-Id: <1456733847-17982-10-git-send-email-agruenba@redhat.com>
In-Reply-To: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A richacl roughly grants a requested access if the NFSv4 acl in the
richacl grants the requested permissions according to the NFSv4
permission check algorithm and the file mask that applies to the process
includes the requested permissions.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Reviewed-by: "J. Bruce Fields" <bfields@fieldses.org>
---
 fs/Makefile             |   2 +-
 fs/richacl_inode.c      | 149 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |   3 +
 3 files changed, 153 insertions(+), 1 deletion(-)
 create mode 100644 fs/richacl_inode.c

diff --git a/fs/Makefile b/fs/Makefile
index e5994c4..d5b45ca 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -49,7 +49,7 @@ obj-$(CONFIG_SYSCTL)		+= drop_caches.o
 
 obj-$(CONFIG_FHANDLE)		+= fhandle.o
 obj-$(CONFIG_FS_RICHACL)	+= richacl.o
-richacl-y			:= richacl_base.o
+richacl-y			:= richacl_base.o richacl_inode.o
 
 obj-y				+= quota/
 
diff --git a/fs/richacl_inode.c b/fs/richacl_inode.c
new file mode 100644
index 0000000..99b3c93
--- /dev/null
+++ b/fs/richacl_inode.c
@@ -0,0 +1,149 @@
+/*
+ * Copyright (C) 2010  Novell, Inc.
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
+		if ((acl->a_flags & RICHACL_WRITE_THROUGH) &&
+		    uid_eq(current_fsuid(), inode->i_uid)) {
+			denied = requested & ~acl->a_owner_mask;
+			goto out;
+		}
+	} else {
+		/*
+		 * When the acl is not masked, there is no need to determine if
+		 * the process is in the group class and we can break out
+		 * earlier of the loop below.
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
+			goto entry_matches_owner;
+		} else if (richace_is_group(ace)) {
+			if (!in_owning_group)
+				continue;
+		} else if (richace_is_unix_user(ace)) {
+			if (!uid_eq(current_fsuid(), ace->e_id.uid))
+				continue;
+			if (uid_eq(current_fsuid(), inode->i_uid))
+				goto entry_matches_owner;
+		} else if (richace_is_unix_group(ace)) {
+			if (!in_group_p(ace->e_id.gid))
+				continue;
+		} else
+			goto entry_matches_everyone;
+
+		/*
+		 * Apply the group file mask to entries other than owner@ and
+		 * everyone@ or user entries matching the owner.  This ensures
+		 * that we grant the same permissions as the acl computed by
+		 * richacl_apply_masks().
+		 *
+		 * Without this restriction, the following richacl would grant
+		 * rw access to processes which are both the owner and in the
+		 * owning group, but not to other users in the owning group,
+		 * which could not be represented without masks:
+		 *
+		 *  owner:rw::mask
+		 *  group@:rw::allow
+		 */
+		if ((acl->a_flags & RICHACL_MASKED) && richace_is_allow(ace))
+			ace_mask &= acl->a_group_mask;
+
+entry_matches_owner:
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
+		if (uid_eq(current_fsuid(), inode->i_uid))
+			denied |= requested & ~acl->a_owner_mask;
+		else if (in_owner_or_group_class)
+			denied |= requested & ~acl->a_group_mask;
+		else {
+			if (acl->a_flags & RICHACL_WRITE_THROUGH)
+				denied = requested & ~acl->a_other_mask;
+			else
+				denied |= requested & ~acl->a_other_mask;
+		}
+	}
+
+out:
+	return denied ? -EACCES : 0;
+}
+EXPORT_SYMBOL_GPL(richacl_permission);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 3559b2c..1d9f5f7 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -180,4 +180,7 @@ extern unsigned int richacl_mode_to_mask(umode_t);
 extern unsigned int richacl_want_to_mask(unsigned int);
 extern void richacl_compute_max_masks(struct richacl *);
 
+/* richacl_inode.c */
+extern int richacl_permission(struct inode *, const struct richacl *, int);
+
 #endif /* __RICHACL_H */
-- 
2.4.3

