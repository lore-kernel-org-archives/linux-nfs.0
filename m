Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:36014 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754734AbbDXLFR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:05:17 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC v3 19/45] richacl: Also recognize nontrivial mode-equivalent acls
Date: Fri, 24 Apr 2015 13:04:16 +0200
Message-Id: <5e9ee3b123b3d648487cd18dc906b6a2cd23085b.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So far, richacl_equiv_mode() is relatively limited in the types of acl it
considers equivalent to a file mode: it only accepts masked acls with a single
everyone@:rwpxd::allow entry.

Change this to consider all acls equivalent to file modes if they only consist
of owner@, group@, and everyone@ entries and the owner@ permissions do not
depend on whether the owner is a member in the owning group.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 150 ++++++++++++++++++++++++++++++++++++++----------
 include/linux/richacl.h |   1 +
 2 files changed, 122 insertions(+), 29 deletions(-)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index db27542..54cb482 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -439,49 +439,141 @@ richacl_inherit(const struct richacl *dir_acl, int isdir)
 }
 
 /**
- * richacl_equiv_mode  -  check if @acl is equivalent to file permission bits
- * @mode_p:	the file mode (including the file type)
+ * __richacl_equiv_mode  -  compute the mode equivalent of @acl
  *
- * If @acl can be fully represented by file permission bits, this function
- * returns 0, and the file permission bits in @mode_p are set to the equivalent
- * of @acl.
+ * This function does not consider the masks in @acl.
  *
- * This function is used to avoid storing richacls on disk if the acl can be
- * computed from the file permission bits.  It allows user-space to make sure
- * that a file has no explicit richacl set.
+ * An acl is considered equivalent to a file mode if it only consists of
+ * owner@, group@, and everyone@ entries and the owner@ permissions do not
+ * depend on whether the owner is a member in the owning group.
  */
 int
-richacl_equiv_mode(const struct richacl *acl, mode_t *mode_p)
+__richacl_equiv_mode(const struct richacl *acl, mode_t *mode_p)
 {
-	const struct richace *ace = acl->a_entries;
-	unsigned int x;
-	mode_t mask;
-
-	if (acl->a_count != 1 ||
-	    acl->a_flags != RICHACL_MASKED ||
-	    !richace_is_everyone(ace) ||
-	    !richace_is_allow(ace) ||
-	    ace->e_flags & ~RICHACE_SPECIAL_WHO)
+	mode_t mode = *mode_p;
+
+	/*
+	 * The RICHACE_DELETE_CHILD flag is meaningless for non-directories, so
+	 * we ignore it.
+	 */
+	unsigned int x = S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD;
+	struct {
+		unsigned int allowed;
+		unsigned int defined;  /* allowed or denied */
+	} owner = {
+		.allowed = RICHACE_POSIX_ALWAYS_ALLOWED,
+		.defined = RICHACE_POSIX_ALWAYS_ALLOWED | RICHACE_POSIX_OWNER_ALLOWED | x,
+	}, group = {
+		.allowed = RICHACE_POSIX_ALWAYS_ALLOWED,
+		.defined = RICHACE_POSIX_ALWAYS_ALLOWED | x,
+	}, everyone = {
+		.allowed = RICHACE_POSIX_ALWAYS_ALLOWED,
+		.defined = RICHACE_POSIX_ALWAYS_ALLOWED | x,
+	};
+	const struct richace *ace;
+
+	richacl_for_each_entry(ace, acl) {
+		if (ace->e_flags & ~RICHACE_SPECIAL_WHO)
+			return -1;
+
+		if (richace_is_owner(ace) || richace_is_everyone(ace)) {
+			x = ace->e_mask & ~owner.defined;
+			if (richace_is_allow(ace)) {
+				unsigned int group_denied = group.defined & ~group.allowed;
+
+				if (x & group_denied)
+					return -1;
+				owner.allowed |= x;
+			} else /* if (richace_is_deny(ace)) */ {
+				if (x & group.allowed)
+					return -1;
+			}
+			owner.defined |= x;
+
+			if (richace_is_everyone(ace)) {
+				x = ace->e_mask;
+				if (richace_is_allow(ace)) {
+					group.allowed |= x & ~group.defined;
+					everyone.allowed |= x & ~everyone.defined;
+				}
+				group.defined |= x;
+				everyone.defined |= x;
+			}
+		} else if (richace_is_group(ace)) {
+			x = ace->e_mask & ~group.defined;
+			if (richace_is_allow(ace))
+				group.allowed |= x;
+			group.defined |= x;
+		} else
+			return -1;
+	}
+
+	if (group.allowed & ~owner.defined)
 		return -1;
 
-	/* Mask flags we can ignore */
-	x = ~RICHACE_POSIX_ALWAYS_ALLOWED;
-	if (!S_ISDIR(*mode_p))
-		x &= ~RICHACE_DELETE_CHILD;
+	if (acl->a_flags & RICHACL_MASKED) {
+		owner.allowed &= acl->a_owner_mask;
+		group.allowed &= acl->a_group_mask;
+		everyone.allowed &= acl->a_other_mask;
+	}
 
-	mask = richacl_masks_to_mode(acl);
-	if (((acl->a_group_mask ^ richacl_mode_to_mask(mask >> 3)) & x) ||
-	    ((acl->a_other_mask ^ richacl_mode_to_mask(mask)) & x))
+	mode = (mode & ~S_IRWXUGO) |
+	       (richacl_mask_to_mode(owner.allowed) << 6) |
+	       (richacl_mask_to_mode(group.allowed) << 3) |
+		richacl_mask_to_mode(everyone.allowed);
+
+	/* Mask flags we can ignore */
+	x = ~(S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD);
+	if (((richacl_mode_to_mask(mode >> 6) ^ owner.allowed) & x) ||
+	    ((richacl_mode_to_mask(mode >> 3) ^ group.allowed) & x) ||
+	    ((richacl_mode_to_mask(mode)      ^ everyone.allowed) & x))
 		return -1;
 
-	x &= ~RICHACE_POSIX_OWNER_ALLOWED;
-	if ((acl->a_owner_mask ^ richacl_mode_to_mask(mask >> 6)) & x)
+	*mode_p = mode;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(__richacl_equiv_mode);
+
+/**
+ * richacl_equiv_mode  -  determine if @acl is equivalent to a file mode
+ * @mode_p:	the file mode
+ *
+ * The file type in @mode_p must be set when calling richacl_equiv_mode().
+ *
+ * Returns with 0 if @acl is equivalent to a file mode; in that case, the
+ * file permission bits in @mode_p are set to the mode equivalent of @acl.
+ */
+int
+richacl_equiv_mode(const struct richacl *acl, mode_t *mode_p)
+{
+	mode_t mode = *mode_p;
+
+	if (acl->a_flags & ~RICHACL_MASKED)
 		return -1;
 
-	if ((ace->e_mask ^ RICHACE_POSIX_MODE_ALL) & x)
+	if (__richacl_equiv_mode(acl, &mode))
 		return -1;
 
-	*mode_p = (*mode_p & ~S_IRWXUGO) | mask;
+	if (acl->a_flags & RICHACL_MASKED) {
+		mode_t mask = richacl_masks_to_mode(acl);
+		unsigned int x;
+
+		/* Mask flags we can ignore */
+		x = ~(RICHACE_POSIX_ALWAYS_ALLOWED |
+		      (S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD));
+
+		if (((acl->a_group_mask ^ richacl_mode_to_mask(mask >> 3)) & x) ||
+		    ((acl->a_other_mask ^ richacl_mode_to_mask(mask)) & x))
+			return -1;
+
+		x &= ~RICHACE_POSIX_OWNER_ALLOWED;
+		if ((acl->a_owner_mask ^ richacl_mode_to_mask(mask >> 6)) & x)
+			return -1;
+
+		mode &= ~S_IRWXUGO | mask;
+	}
+
+	*mode_p = mode;
 	return 0;
 }
 EXPORT_SYMBOL_GPL(richacl_equiv_mode);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index c6fd0a1..8a92b89 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -297,6 +297,7 @@ extern unsigned int richacl_want_to_mask(unsigned int);
 extern void richacl_compute_max_masks(struct richacl *);
 extern struct richacl *richacl_chmod(struct richacl *, mode_t);
 extern struct richacl *richacl_inherit(const struct richacl *, int);
+extern int __richacl_equiv_mode(const struct richacl *, mode_t *);
 extern int richacl_equiv_mode(const struct richacl *, mode_t *);
 
 /* richacl_inode.c */
-- 
2.1.0

