Return-Path: linux-fsdevel-owner@vger.kernel.org
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 14/21] richacl: Check if an acl is equivalent to a file mode
Date: Thu, 26 Feb 2015 00:41:35 +0100
Message-Id: <410d49744f16fb757be06a4c2a9e97b9eb760d70.1424907511.git.agruenba@redhat.com>
In-Reply-To: <cover.1424907511.git.agruenba@redhat.com>
References: <cover.1424907511.git.agruenba@redhat.com>
In-Reply-To: <cover.1424907511.git.agruenba@redhat.com>
References: <cover.1424907511.git.agruenba@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This function is used to avoid storing richacls if the acl can be computed from
the file permission bits.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 54 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  1 +
 2 files changed, 55 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 8d9dc2c..c853f7e 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -521,3 +521,57 @@ richacl_inherit(const struct richacl *dir_acl, int isdir)
 
 	return acl;
 }
+
+/**
+ * richacl_equiv_mode  -  check if @acl is equivalent to file permission bits
+ * @mode_p:	the file mode (including the file type)
+ *
+ * If @acl can be fully represented by file permission bits, this function
+ * returns 0, and the file permission bits in @mode_p are set to the equivalent
+ * of @acl.
+ *
+ * This function is used to avoid storing richacls on disk if the acl can be
+ * computed from the file permission bits.  It allows user-space to make sure
+ * that a file has no explicit richacl set.
+ */
+int
+richacl_equiv_mode(const struct richacl *acl, mode_t *mode_p)
+{
+	const struct richace *ace = acl->a_entries;
+	unsigned int x;
+	mode_t mode;
+
+	if (acl->a_count != 1 ||
+	    acl->a_flags != ACL4_MASKED ||
+	    !richace_is_everyone(ace) ||
+	    !richace_is_allow(ace) ||
+	    ace->e_flags & ~ACE4_SPECIAL_WHO)
+		return -1;
+
+	/*
+	 * Figure out the permissions we care about: ACE4_DELETE_CHILD is
+	 * meaningless for non-directories, so we ignore it.
+	 */
+	x = ~ACE4_POSIX_ALWAYS_ALLOWED;
+	if (!S_ISDIR(*mode_p))
+		x &= ~ACE4_DELETE_CHILD;
+
+	mode = richacl_masks_to_mode(acl);
+	if ((acl->a_group_mask & x) != (richacl_mode_to_mask(mode >> 3) & x) ||
+	    (acl->a_other_mask & x) != (richacl_mode_to_mask(mode) & x))
+		return -1;
+
+	/*
+	 * Ignore permissions which the owner is always allowed.
+	 */
+	x &= ~ACE4_POSIX_OWNER_ALLOWED;
+	if ((acl->a_owner_mask & x) != (richacl_mode_to_mask(mode >> 6) & x))
+		return -1;
+
+	if ((ace->e_mask & x) != (ACE4_POSIX_MODE_ALL & x))
+		return -1;
+
+	*mode_p = (*mode_p & ~S_IRWXUGO) | mode;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(richacl_equiv_mode);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index fd3eeb4..39072a0 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -294,6 +294,7 @@ extern void richacl_compute_max_masks(struct richacl *);
 extern struct richacl *richacl_chmod(struct richacl *, mode_t);
 extern int richacl_permission(struct inode *, const struct richacl *, int);
 extern struct richacl *richacl_inherit(const struct richacl *, int);
+extern int richacl_equiv_mode(const struct richacl *, mode_t *);
 
 /* richacl_inode.c */
 extern struct richacl *richacl_inherit_inode(const struct richacl *,
-- 
2.1.0

