Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:33734 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250AbbFXV5x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2015 17:57:53 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        samba-technical@lists.samba.org, linux-security-module@vger.kernel.org
Subject: [RFC v4 14/31] richacl: Create-time inheritance
Date: Wed, 24 Jun 2015 23:57:03 +0200
Message-Id: <1435183040-22726-15-git-send-email-agruenba@redhat.com>
In-Reply-To: <1435183040-22726-1-git-send-email-agruenba@redhat.com>
References: <1435183040-22726-1-git-send-email-agruenba@redhat.com>
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
 fs/richacl_inode.c      | 62 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  2 ++
 3 files changed, 133 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 1ef3bf3..29d3197 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -460,3 +460,72 @@ richacl_equiv_mode(const struct richacl *acl, mode_t *mode_p)
 	return 0;
 }
 EXPORT_SYMBOL_GPL(richacl_equiv_mode);
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
index 4b06ab3..f233872 100644
--- a/fs/richacl_inode.c
+++ b/fs/richacl_inode.c
@@ -193,3 +193,65 @@ out:
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
+		mask = inode->i_mode;
+		if (richacl_equiv_mode(acl, &mask) == 0) {
+			richacl_put(acl);
+			acl = NULL;
+		} else {
+			richacl_compute_max_masks(acl, inode->i_uid);
+			/*
+			 * Ensure that the acl will not grant any permissions
+			 * beyond the create mode.
+			 */
+			acl->a_flags |= RICHACL_MASKED;
+			acl->a_owner_mask &= richacl_mode_to_mask(inode->i_mode >> 6);
+			acl->a_group_mask &= richacl_mode_to_mask(inode->i_mode >> 3);
+			acl->a_other_mask &= richacl_mode_to_mask(inode->i_mode);
+			mask = ~S_IRWXUGO | richacl_masks_to_mode(acl);
+		}
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
+	} else
+		inode->i_mode &= ~current_umask();
+	return acl;
+}
+EXPORT_SYMBOL_GPL(richacl_create);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 2357d6b..3fcefe3 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -308,8 +308,10 @@ extern unsigned int richacl_want_to_mask(unsigned int);
 extern void richacl_compute_max_masks(struct richacl *, kuid_t);
 extern struct richacl *richacl_chmod(struct richacl *, mode_t);
 extern int richacl_equiv_mode(const struct richacl *, mode_t *);
+extern struct richacl *richacl_inherit(const struct richacl *, int);
 
 /* richacl_inode.c */
 extern int richacl_permission(struct inode *, const struct richacl *, int);
+extern struct richacl *richacl_create(struct inode *, struct inode *);
 
 #endif /* __RICHACL_H */
-- 
2.4.2

