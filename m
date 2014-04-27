Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:60180 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753498AbaD0QQC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Apr 2014 12:16:02 -0400
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 28 Apr 2014 02:16:01 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V1 16/22] richacl: Check if an acl is equivalent to a file mode
Date: Sun, 27 Apr 2014 21:44:47 +0530
Message-Id: <1398615293-22931-17-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

This function is used to avoid storing richacls on disk if the acl can
be computed from the file permission bits.

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/richacl_base.c       | 54 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  1 +
 2 files changed, 55 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 29ffea8e56d7..5d777f6b8a61 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -523,3 +523,57 @@ richacl_inherit(const struct richacl *dir_acl, int isdir)
 
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
index 47855ec8db4d..7ac6587cb166 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -285,6 +285,7 @@ extern struct richacl *richacl_chmod(struct richacl *, mode_t);
 extern int richacl_permission(struct inode *, const struct richacl *,
 			      unsigned int);
 extern struct richacl *richacl_inherit(const struct richacl *, int);
+extern int richacl_equiv_mode(const struct richacl *, mode_t *);
 
 /* richacl_inode.c */
 extern struct richacl *richacl_inherit_inode(const struct richacl *,
-- 
1.9.1

