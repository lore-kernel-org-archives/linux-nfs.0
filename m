Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:35518 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753929AbbC0QwB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:52:01 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 16/39] richacl: Create-time inheritance
Date: Fri, 27 Mar 2015 17:50:14 +0100
Message-Id: <f2dcc109e5e79d97dcde166b0df783b12d30cea8.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
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
 fs/richacl_base.c       | 69 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/richacl_inode.c      | 60 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  2 ++
 3 files changed, 131 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 5903994..d3a5e9b 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -416,3 +416,72 @@ richacl_chmod(struct richacl *acl, mode_t mode)
 	return clone;
 }
 EXPORT_SYMBOL_GPL(richacl_chmod);
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
+		acl = richacl_alloc(count, GFP_KERNEL);
+		if (!acl)
+			return ERR_PTR(-ENOMEM);
+		ace = acl->a_entries;
+		richacl_for_each_entry(dir_ace, dir_acl) {
+			if (!richace_is_inheritable(dir_ace))
+				continue;
+			memcpy(ace, dir_ace, sizeof(struct richace));
+			if (dir_ace->e_flags & RICHACE_NO_PROPAGATE_INHERIT_ACE)
+				richace_clear_inheritance_flags(ace);
+			if ((dir_ace->e_flags & RICHACE_FILE_INHERIT_ACE) &&
+			    !(dir_ace->e_flags & RICHACE_DIRECTORY_INHERIT_ACE))
+				ace->e_flags |= RICHACE_INHERIT_ONLY_ACE;
+			ace++;
+		}
+	} else {
+		richacl_for_each_entry(dir_ace, dir_acl) {
+			if (!(dir_ace->e_flags & RICHACE_FILE_INHERIT_ACE))
+				continue;
+			count++;
+		}
+		if (!count)
+			return NULL;
+		acl = richacl_alloc(count, GFP_KERNEL);
+		if (!acl)
+			return ERR_PTR(-ENOMEM);
+		ace = acl->a_entries;
+		richacl_for_each_entry(dir_ace, dir_acl) {
+			if (!(dir_ace->e_flags & RICHACE_FILE_INHERIT_ACE))
+				continue;
+			memcpy(ace, dir_ace, sizeof(struct richace));
+			richace_clear_inheritance_flags(ace);
+			/*
+			 * RICHACE_DELETE_CHILD is meaningless for
+			 * non-directories, so clear it.
+			 */
+			ace->e_mask &= ~RICHACE_DELETE_CHILD;
+			ace++;
+		}
+	}
+
+	return acl;
+}
diff --git a/fs/richacl_inode.c b/fs/richacl_inode.c
index 33e591a..fb5e172 100644
--- a/fs/richacl_inode.c
+++ b/fs/richacl_inode.c
@@ -128,3 +128,63 @@ is_everyone:
 	return denied ? -EACCES : 0;
 }
 EXPORT_SYMBOL_GPL(richacl_permission);
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
+static struct richacl *
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
+		acl->a_flags |= RICHACL_MASKED;
+		acl->a_owner_mask &= richacl_mode_to_mask(inode->i_mode >> 6) |
+				     RICHACE_POSIX_OWNER_ALLOWED;
+		acl->a_group_mask &= richacl_mode_to_mask(inode->i_mode >> 3);
+		acl->a_other_mask &= richacl_mode_to_mask(inode->i_mode);
+		mask = ~S_IRWXUGO | richacl_masks_to_mode(acl);
+	} else
+		mask = ~current_umask();
+
+	inode->i_mode &= mask;
+	return acl;
+}
+
+struct richacl *richacl_create(struct inode *inode, struct inode *dir)
+{
+	struct richacl *dir_acl, *acl = NULL;
+
+	if (S_ISLNK(inode->i_mode))
+		return NULL;
+	dir_acl = get_richacl(dir);
+	if (dir_acl) {
+		if (IS_ERR(dir_acl))
+			return dir_acl;
+		acl = richacl_inherit_inode(dir_acl, inode);
+		richacl_put(dir_acl);
+	}
+	if (!acl)
+		inode->i_mode &= ~current_umask();
+	return acl;
+}
+EXPORT_SYMBOL(richacl_create);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 81b7a9e..63c787b 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -295,8 +295,10 @@ extern unsigned int richacl_mode_to_mask(mode_t);
 extern unsigned int richacl_want_to_mask(unsigned int);
 extern void richacl_compute_max_masks(struct richacl *);
 extern struct richacl *richacl_chmod(struct richacl *, mode_t);
+extern struct richacl *richacl_inherit(const struct richacl *, int);
 
 /* richacl_inode.c */
 extern int richacl_permission(struct inode *, const struct richacl *, int);
+extern struct richacl *richacl_create(struct inode *, struct inode *);
 
 #endif /* __RICHACL_H */
-- 
2.1.0

