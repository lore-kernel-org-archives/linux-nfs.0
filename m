Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35799 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753947AbbC0QwC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:52:02 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 17/39] richacl: Check if an acl is equivalent to a file mode
Date: Fri, 27 Mar 2015 17:50:15 +0100
Message-Id: <b9b067b89907ae73114a1f779a142a4edc0df47a.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This function is used to avoid storing richacls if the acl can be computed from
the file permission bits.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 54 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  1 +
 2 files changed, 55 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index d3a5e9b..2e3a2c9 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -485,3 +485,57 @@ richacl_inherit(const struct richacl *dir_acl, int isdir)
 
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
+	    acl->a_flags != RICHACL_MASKED ||
+	    !richace_is_everyone(ace) ||
+	    !richace_is_allow(ace) ||
+	    ace->e_flags & ~RICHACE_SPECIAL_WHO)
+		return -1;
+
+	/*
+	 * Figure out the permissions we care about: RICHACE_DELETE_CHILD is
+	 * meaningless for non-directories, so we ignore it.
+	 */
+	x = ~RICHACE_POSIX_ALWAYS_ALLOWED;
+	if (!S_ISDIR(*mode_p))
+		x &= ~RICHACE_DELETE_CHILD;
+
+	mode = richacl_masks_to_mode(acl);
+	if ((acl->a_group_mask & x) != (richacl_mode_to_mask(mode >> 3) & x) ||
+	    (acl->a_other_mask & x) != (richacl_mode_to_mask(mode) & x))
+		return -1;
+
+	/*
+	 * Ignore permissions which the owner is always allowed.
+	 */
+	x &= ~RICHACE_POSIX_OWNER_ALLOWED;
+	if ((acl->a_owner_mask & x) != (richacl_mode_to_mask(mode >> 6) & x))
+		return -1;
+
+	if ((ace->e_mask & x) != (RICHACE_POSIX_MODE_ALL & x))
+		return -1;
+
+	*mode_p = (*mode_p & ~S_IRWXUGO) | mode;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(richacl_equiv_mode);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 63c787b..4db73aa 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -296,6 +296,7 @@ extern unsigned int richacl_want_to_mask(unsigned int);
 extern void richacl_compute_max_masks(struct richacl *);
 extern struct richacl *richacl_chmod(struct richacl *, mode_t);
 extern struct richacl *richacl_inherit(const struct richacl *, int);
+extern int richacl_equiv_mode(const struct richacl *, mode_t *);
 
 /* richacl_inode.c */
 extern int richacl_permission(struct inode *, const struct richacl *, int);
-- 
2.1.0

