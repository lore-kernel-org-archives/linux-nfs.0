Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:37678 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929AbbGVNEY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 09:04:24 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, samba-technical@lists.samba.org,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH v5 15/39] richacl: Automatic Inheritance
Date: Wed, 22 Jul 2015 15:03:05 +0200
Message-Id: <1437570209-29832-16-git-send-email-andreas.gruenbacher@gmail.com>
In-Reply-To: <1437570209-29832-1-git-send-email-andreas.gruenbacher@gmail.com>
References: <1437570209-29832-1-git-send-email-andreas.gruenbacher@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruenba@redhat.com>

Automatic Inheritance (AI) allows changes to the acl of a directory to
propagate down to children.

This is mostly implemented in user space: when a process changes the
permissions of a directory and Automatic Inheritance is enabled for that
directory, the process must propagate those changes to all children,
recursively.

The kernel enables this by keeping track of which permissions have been
inherited at file create time.  In addition, it makes sure that permission
propagation is turned off when the permissions of a file are set explicitly
(for example, upon create or chmod).

Automatic Inheritance works as follows:

 - When the RICHACL_AUTO_INHERIT flag in the acl of a file is not set,
   the file is not affected by AI.

 - When the RICHACL_AUTO_INHERIT flag in the acl of a directory is set
   and a file or subdirectory is created in that directory, the
   inherited acl will have the RICHACL_AUTO_INHERIT flag set, and all
   inherited aces will have the RICHACE_INHERITED_ACE flag set.  This
   allows user space to distinguish between aces which have been
   inherited and aces which have been explicitly added.

 - When the RICHACL_PROTECTED acl flag in the acl of a file is set, AI
   will not modify the acl of the file.  This does not affect
   propagation of permissions from the file to its children (if the
   file is a directory).

Linux does not have a way of creating files without setting the file
permission bits, so all files created inside a directory with
RICHACL_AUTO_INHERIT set will have the RICHACL_PROTECTED flag set.  This
effectively disables Automatic Inheritance.

Protocols which support creating files without specifying permissions can
explicitly clear the RICHACL_PROTECTED flag after creating a file and
reset the file masks to "undo" applying the create mode; see
richacl_compute_max_masks().  They should set the RICHACL_DEFAULTED flag.
This is a workaround; a mechanism that would allow a process to indicate
to the kernel to ignore the create mode when there are inherited
permissions would fix this problem.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 10 +++++++++-
 fs/richacl_inode.c      |  7 +++++++
 include/linux/richacl.h | 25 +++++++++++++++++++++++--
 3 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index ae224b1..7d17279 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -358,7 +358,8 @@ richacl_chmod(struct richacl *acl, mode_t mode)
 	if (acl->a_owner_mask == owner_mask &&
 	    acl->a_group_mask == group_mask &&
 	    acl->a_other_mask == other_mask &&
-	    (acl->a_flags & RICHACL_MASKED))
+	    (acl->a_flags & RICHACL_MASKED) &&
+	    (!richacl_is_auto_inherit(acl) || richacl_is_protected(acl)))
 		return acl;
 
 	clone = richacl_clone(acl, GFP_KERNEL);
@@ -370,6 +371,8 @@ richacl_chmod(struct richacl *acl, mode_t mode)
 	clone->a_owner_mask = owner_mask;
 	clone->a_group_mask = group_mask;
 	clone->a_other_mask = other_mask;
+	if (richacl_is_auto_inherit(clone))
+		clone->a_flags |= RICHACL_PROTECTED;
 
 	return clone;
 }
@@ -535,6 +538,11 @@ richacl_inherit(const struct richacl *dir_acl, int isdir)
 			ace++;
 		}
 	}
+	if (richacl_is_auto_inherit(dir_acl)) {
+		acl->a_flags = RICHACL_AUTO_INHERIT;
+		richacl_for_each_entry(ace, acl)
+			ace->e_flags |= RICHACE_INHERITED_ACE;
+	}
 
 	return acl;
 }
diff --git a/fs/richacl_inode.c b/fs/richacl_inode.c
index fd6f710..686a6c9 100644
--- a/fs/richacl_inode.c
+++ b/fs/richacl_inode.c
@@ -218,6 +218,13 @@ richacl_inherit_inode(const struct richacl *dir_acl, struct inode *inode)
 			richacl_put(acl);
 			acl = NULL;
 		} else {
+			/*
+			 * We need to set RICHACL_PROTECTED because we are
+			 * doing an implicit chmod
+			 */
+			if (richacl_is_auto_inherit(acl))
+				acl->a_flags |= RICHACL_PROTECTED;
+
 			richacl_compute_max_masks(acl, inode->i_uid);
 			/*
 			 * Ensure that the acl will not grant any permissions
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index e00bcb4..49d7207 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -53,9 +53,15 @@ struct richacl {
 	     _ace--)
 
 /* a_flag values */
+#define RICHACL_AUTO_INHERIT			0x01
+#define RICHACL_PROTECTED			0x02
+#define RICHACL_DEFAULTED			0x04
 #define RICHACL_MASKED				0x80
 
-#define RICHACL_VALID_FLAGS (					\
+#define RICHACL_VALID_FLAGS (			\
+		RICHACL_AUTO_INHERIT |		\
+		RICHACL_PROTECTED |		\
+		RICHACL_DEFAULTED |		\
 		RICHACL_MASKED)
 
 /* e_type values */
@@ -68,6 +74,7 @@ struct richacl {
 #define RICHACE_NO_PROPAGATE_INHERIT_ACE	0x0004
 #define RICHACE_INHERIT_ONLY_ACE		0x0008
 #define RICHACE_IDENTIFIER_GROUP		0x0040
+#define RICHACE_INHERITED_ACE			0x0080
 #define RICHACE_SPECIAL_WHO			0x4000
 
 #define RICHACE_VALID_FLAGS (					\
@@ -76,6 +83,7 @@ struct richacl {
 	RICHACE_NO_PROPAGATE_INHERIT_ACE |			\
 	RICHACE_INHERIT_ONLY_ACE |				\
 	RICHACE_IDENTIFIER_GROUP |				\
+	RICHACE_INHERITED_ACE |					\
 	RICHACE_SPECIAL_WHO)
 
 /* e_mask bitflags */
@@ -187,6 +195,18 @@ extern void set_cached_richacl(struct inode *, struct richacl *);
 extern void forget_cached_richacl(struct inode *);
 extern struct richacl *get_richacl(struct inode *);
 
+static inline int
+richacl_is_auto_inherit(const struct richacl *acl)
+{
+	return acl->a_flags & RICHACL_AUTO_INHERIT;
+}
+
+static inline int
+richacl_is_protected(const struct richacl *acl)
+{
+	return acl->a_flags & RICHACL_PROTECTED;
+}
+
 /**
  * richace_is_owner  -  check if @ace is an OWNER@ entry
  */
@@ -268,7 +288,8 @@ richace_clear_inheritance_flags(struct richace *ace)
 	ace->e_flags &= ~(RICHACE_FILE_INHERIT_ACE |
 			  RICHACE_DIRECTORY_INHERIT_ACE |
 			  RICHACE_NO_PROPAGATE_INHERIT_ACE |
-			  RICHACE_INHERIT_ONLY_ACE);
+			  RICHACE_INHERIT_ONLY_ACE |
+			  RICHACE_INHERITED_ACE);
 }
 
 /**
-- 
2.4.3

