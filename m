Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:37999 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637AbbDXLFR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:05:17 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC v3 18/45] richacl: Check if an acl is equivalent to a file mode
Date: Fri, 24 Apr 2015 13:04:15 +0200
Message-Id: <0be8f34af68a3f00810e3a9628ece183338d9d3b.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This function is used to avoid storing richacls if the acl can be computed from
the file permission bits.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  1 +
 2 files changed, 49 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 5d45539..db27542 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -437,3 +437,51 @@ richacl_inherit(const struct richacl *dir_acl, int isdir)
 
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
+	mode_t mask;
+
+	if (acl->a_count != 1 ||
+	    acl->a_flags != RICHACL_MASKED ||
+	    !richace_is_everyone(ace) ||
+	    !richace_is_allow(ace) ||
+	    ace->e_flags & ~RICHACE_SPECIAL_WHO)
+		return -1;
+
+	/* Mask flags we can ignore */
+	x = ~RICHACE_POSIX_ALWAYS_ALLOWED;
+	if (!S_ISDIR(*mode_p))
+		x &= ~RICHACE_DELETE_CHILD;
+
+	mask = richacl_masks_to_mode(acl);
+	if (((acl->a_group_mask ^ richacl_mode_to_mask(mask >> 3)) & x) ||
+	    ((acl->a_other_mask ^ richacl_mode_to_mask(mask)) & x))
+		return -1;
+
+	x &= ~RICHACE_POSIX_OWNER_ALLOWED;
+	if ((acl->a_owner_mask ^ richacl_mode_to_mask(mask >> 6)) & x)
+		return -1;
+
+	if ((ace->e_mask ^ RICHACE_POSIX_MODE_ALL) & x)
+		return -1;
+
+	*mode_p = (*mode_p & ~S_IRWXUGO) | mask;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(richacl_equiv_mode);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index ab9fde1..c6fd0a1 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -297,6 +297,7 @@ extern unsigned int richacl_want_to_mask(unsigned int);
 extern void richacl_compute_max_masks(struct richacl *);
 extern struct richacl *richacl_chmod(struct richacl *, mode_t);
 extern struct richacl *richacl_inherit(const struct richacl *, int);
+extern int richacl_equiv_mode(const struct richacl *, mode_t *);
 
 /* richacl_inode.c */
 extern int richacl_permission(struct inode *, const struct richacl *, int);
-- 
2.1.0

