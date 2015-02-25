Return-Path: linux-fsdevel-owner@vger.kernel.org
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 15/21] richacl: Automatic Inheritance
Date: Thu, 26 Feb 2015 00:41:36 +0100
Message-Id: <39c338514faf1b135b8515db11c58720f6897e9d.1424907511.git.agruenba@redhat.com>
In-Reply-To: <cover.1424907511.git.agruenba@redhat.com>
References: <cover.1424907511.git.agruenba@redhat.com>
In-Reply-To: <cover.1424907511.git.agruenba@redhat.com>
References: <cover.1424907511.git.agruenba@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Automatic Inheritance (AI) allows changes to the acl of a directory to
recursively propagate down to files and directories in the directory.

To implement this, the kernel keeps track of which permissions have been
inherited, and makes sure that permission propagation is turned off when the
file permission bits of a file are changed (upon create or chmod).

The actual permission propagation is implemented in user space.

Automatic Inheritance works as follows:

 - When the ACL4_AUTO_INHERIT flag in the acl of a file is not set, the
   file is not affected by AI.

 - When the ACL4_AUTO_INHERIT flag in the acl of a directory is set and
   a file or subdirectory is created in that directory, files created in
   the directory will have the ACL4_AUTO_INHERIT flag set, and all
   inherited aces will have the ACE4_INHERITED_ACE flag set.  This
   allows user space to distinguish between aces which have been
   inherited and aces which have been explicitly added.

 - When the ACL4_PROTECTED acl flag in the acl of a file is set, AI will
   not modify the acl of the file.  This does not affect propagation of
   permissions from the file to its children (if the file is a
   directory).

Linux does not have a way of creating files without setting the file permission
bits, so all files created inside a directory with ACL4_AUTO_INHERIT set will
also have the ACL4_PROTECTED flag set.  This effectively disables Automatic
Inheritance.

Protocols which support creating files without specifying permissions can
explicitly clear the ACL4_PROTECTED flag after creating a file and reset the
file masks to "undo" applying the create mode; see richacl_compute_max_masks().
This is a workaround; a mechanism that would allow a process to indicate to the
kernel to ignore the create mode when there are inherited permissions would fix
this problem.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 10 +++++++++-
 fs/richacl_inode.c      |  7 ++++++-
 include/linux/richacl.h | 24 +++++++++++++++++++++++-
 3 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index c853f7e..ec570ef 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -324,7 +324,8 @@ richacl_chmod(struct richacl *acl, mode_t mode)
 	if (acl->a_owner_mask == owner_mask &&
 	    acl->a_group_mask == group_mask &&
 	    acl->a_other_mask == other_mask &&
-	    (acl->a_flags & ACL4_MASKED))
+	    (acl->a_flags & ACL4_MASKED) &&
+	    (!richacl_is_auto_inherit(acl) || richacl_is_protected(acl)))
 		return acl;
 
 	clone = richacl_clone(acl);
@@ -336,6 +337,8 @@ richacl_chmod(struct richacl *acl, mode_t mode)
 	clone->a_owner_mask = owner_mask;
 	clone->a_group_mask = group_mask;
 	clone->a_other_mask = other_mask;
+	if (richacl_is_auto_inherit(clone))
+		clone->a_flags |= ACL4_PROTECTED;
 
 	return clone;
 }
@@ -518,6 +521,11 @@ richacl_inherit(const struct richacl *dir_acl, int isdir)
 			ace++;
 		}
 	}
+	if (richacl_is_auto_inherit(dir_acl)) {
+		acl->a_flags = ACL4_AUTO_INHERIT;
+		richacl_for_each_entry(ace, acl)
+			ace->e_flags |= ACE4_INHERITED_ACE;
+	}
 
 	return acl;
 }
diff --git a/fs/richacl_inode.c b/fs/richacl_inode.c
index b95a584..9f96564 100644
--- a/fs/richacl_inode.c
+++ b/fs/richacl_inode.c
@@ -40,9 +40,14 @@ richacl_inherit_inode(const struct richacl *dir_acl, struct inode *inode)
 
 	acl = richacl_inherit(dir_acl, S_ISDIR(inode->i_mode));
 	if (acl) {
+		/*
+		 * We need to set ACL4_PROTECTED because we are
+		 * doing an implicit chmod
+		 */
+		if (richacl_is_auto_inherit(acl))
+			acl->a_flags |= ACL4_PROTECTED;
 
 		richacl_compute_max_masks(acl);
-
 		/*
 		 * Ensure that the acl will not grant any permissions beyond
 		 * the create mode.
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 39072a0..a607d6f 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -49,10 +49,17 @@ struct richacl {
 	     _ace != (_acl)->a_entries - 1; \
 	     _ace--)
 
+/* a_flags values */
+#define ACL4_AUTO_INHERIT		0x01
+#define ACL4_PROTECTED			0x02
+#define ACL4_DEFAULTED			0x04
 /* Flag values defined by richacls */
 #define ACL4_MASKED			0x80
 
 #define ACL4_VALID_FLAGS (			\
+		ACL4_AUTO_INHERIT |		\
+		ACL4_PROTECTED |		\
+		ACL4_DEFAULTED |		\
 		ACL4_MASKED)
 
 /* e_type values */
@@ -69,6 +76,7 @@ struct richacl {
 /*#define ACE4_SUCCESSFUL_ACCESS_ACE_FLAG	0x0010*/
 /*#define ACE4_FAILED_ACCESS_ACE_FLAG	0x0020*/
 #define ACE4_IDENTIFIER_GROUP		0x0040
+#define ACE4_INHERITED_ACE		0x0080
 /* richacl specific flag values */
 #define ACE4_SPECIAL_WHO		0x4000
 
@@ -78,6 +86,7 @@ struct richacl {
 	ACE4_NO_PROPAGATE_INHERIT_ACE |		\
 	ACE4_INHERIT_ONLY_ACE |			\
 	ACE4_IDENTIFIER_GROUP |			\
+	ACE4_INHERITED_ACE |			\
 	ACE4_SPECIAL_WHO)
 
 /* e_mask bitflags */
@@ -184,6 +193,18 @@ richacl_put(struct richacl *acl)
 		kfree(acl);
 }
 
+static inline int
+richacl_is_auto_inherit(const struct richacl *acl)
+{
+	return acl->a_flags & ACL4_AUTO_INHERIT;
+}
+
+static inline int
+richacl_is_protected(const struct richacl *acl)
+{
+	return acl->a_flags & ACL4_PROTECTED;
+}
+
 /**
  * richace_is_owner  -  check if @ace is an OWNER@ entry
  */
@@ -254,7 +275,8 @@ richace_clear_inheritance_flags(struct richace *ace)
 	ace->e_flags &= ~(ACE4_FILE_INHERIT_ACE |
 			  ACE4_DIRECTORY_INHERIT_ACE |
 			  ACE4_NO_PROPAGATE_INHERIT_ACE |
-			  ACE4_INHERIT_ONLY_ACE);
+			  ACE4_INHERIT_ONLY_ACE |
+			  ACE4_INHERITED_ACE);
 }
 
 /**
-- 
2.1.0

