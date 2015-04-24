Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:36041 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754670AbbDXLFH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:05:07 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC v3 11/45] richacl: Permission mapping functions
Date: Fri, 24 Apr 2015 13:04:08 +0200
Message-Id: <3c47aff8235025acfc8df84e354a799a4159a048.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to map from POSIX permissions to NFSv4 permissions when a
chmod() is done, from NFSv4 permissions to POSIX permissions when an acl
is set (which implicitly sets the file permission bits), and from the
MAY_READ/MAY_WRITE/MAY_EXEC/MAY_APPEND flags to NFSv4 permissions when
doing an access check in a richacl.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 116 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  46 +++++++++++++++++++
 2 files changed, 162 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 164b902..978f221 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -56,3 +56,119 @@ richacl_clone(const struct richacl *acl, gfp_t gfp)
 	}
 	return dup;
 }
+
+/**
+ * richacl_mask_to_mode  -  compute the file permission bits which correspond to @mask
+ * @mask:	%RICHACE_* permission mask
+ *
+ * See richacl_masks_to_mode().
+ */
+static int
+richacl_mask_to_mode(unsigned int mask)
+{
+	int mode = 0;
+
+	if (mask & RICHACE_POSIX_MODE_READ)
+		mode |= S_IROTH;
+	if (mask & RICHACE_POSIX_MODE_WRITE)
+		mode |= S_IWOTH;
+	if (mask & RICHACE_POSIX_MODE_EXEC)
+		mode |= S_IXOTH;
+
+	return mode;
+}
+
+/**
+ * richacl_masks_to_mode  -  compute the file permission bits from the file masks
+ *
+ * When setting a richacl, we set the file permission bits to indicate maximum
+ * permissions: for example, we set the Write permission when a mask contains
+ * RICHACE_APPEND_DATA even if it does not also contain RICHACE_WRITE_DATA.
+ *
+ * Permissions which are not in RICHACE_POSIX_MODE_READ, RICHACE_POSIX_MODE_WRITE, or
+ * RICHACE_POSIX_MODE_EXEC cannot be represented in the file permission bits.
+ * Such permissions can still be effective, but not for new files or after a
+ * chmod(); they must be explicitly enabled in the richacl.
+ */
+int
+richacl_masks_to_mode(const struct richacl *acl)
+{
+	return richacl_mask_to_mode(acl->a_owner_mask) << 6 |
+	       richacl_mask_to_mode(acl->a_group_mask) << 3 |
+	       richacl_mask_to_mode(acl->a_other_mask);
+}
+EXPORT_SYMBOL_GPL(richacl_masks_to_mode);
+
+/**
+ * richacl_mode_to_mask  - compute a file mask from the lowest three mode bits
+ *
+ * When the file permission bits of a file are set with chmod(), this specifies
+ * the maximum permissions that processes will get.  All permissions beyond
+ * that will be removed from the file masks, and become ineffective.
+ *
+ * We also add in the permissions which are always allowed no matter what the
+ * acl says.
+ */
+unsigned int
+richacl_mode_to_mask(mode_t mode)
+{
+	unsigned int mask = RICHACE_POSIX_ALWAYS_ALLOWED;
+
+	if (mode & S_IROTH)
+		mask |= RICHACE_POSIX_MODE_READ;
+	if (mode & S_IWOTH)
+		mask |= RICHACE_POSIX_MODE_WRITE;
+	if (mode & S_IXOTH)
+		mask |= RICHACE_POSIX_MODE_EXEC;
+
+	return mask;
+}
+
+/**
+ * richacl_want_to_mask  - convert the iop->permission want argument to a mask
+ * @want:	@want argument of the permission inode operation
+ *
+ * When checking for append, @want is (MAY_WRITE | MAY_APPEND).
+ *
+ * Richacls use the iop->may_create and iop->may_delete hooks which are
+ * used for checking if creating and deleting files is allowed.  These hooks do
+ * not use richacl_want_to_mask(), so we do not have to deal with mapping
+ * MAY_WRITE to RICHACE_ADD_FILE, RICHACE_ADD_SUBDIRECTORY, and RICHACE_DELETE_CHILD
+ * here.
+ */
+unsigned int
+richacl_want_to_mask(unsigned int want)
+{
+	unsigned int mask = 0;
+
+	if (want & MAY_READ)
+		mask |= RICHACE_READ_DATA;
+	if (want & MAY_DELETE_SELF)
+		mask |= RICHACE_DELETE;
+	if (want & MAY_TAKE_OWNERSHIP)
+		mask |= RICHACE_WRITE_OWNER;
+	if (want & MAY_CHMOD)
+		mask |= RICHACE_WRITE_ACL;
+	if (want & MAY_SET_TIMES)
+		mask |= RICHACE_WRITE_ATTRIBUTES;
+	if (want & MAY_EXEC)
+		mask |= RICHACE_EXECUTE;
+	/*
+	 * differentiate MAY_WRITE from these request
+	 */
+	if (want & (MAY_APPEND |
+		    MAY_CREATE_FILE | MAY_CREATE_DIR |
+		    MAY_DELETE_CHILD)) {
+		if (want & MAY_APPEND)
+			mask |= RICHACE_APPEND_DATA;
+		if (want & MAY_CREATE_FILE)
+			mask |= RICHACE_ADD_FILE;
+		if (want & MAY_CREATE_DIR)
+			mask |= RICHACE_ADD_SUBDIRECTORY;
+		if (want & MAY_DELETE_CHILD)
+			mask |= RICHACE_DELETE_CHILD;
+	} else if (want & MAY_WRITE)
+		mask |= RICHACE_WRITE_DATA;
+	return mask;
+}
+EXPORT_SYMBOL_GPL(richacl_want_to_mask);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 1499e7d..d19843b 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -118,6 +118,49 @@ struct richacl {
 	RICHACE_WRITE_OWNER |					\
 	RICHACE_SYNCHRONIZE)
 
+/*
+ * The POSIX permissions are supersets of the following NFSv4 permissions:
+ *
+ *  - MAY_READ maps to READ_DATA or LIST_DIRECTORY, depending on the type
+ *    of the file system object.
+ *
+ *  - MAY_WRITE maps to WRITE_DATA or RICHACE_APPEND_DATA for files, and to
+ *    ADD_FILE, RICHACE_ADD_SUBDIRECTORY, or RICHACE_DELETE_CHILD for directories.
+ *
+ *  - MAY_EXECUTE maps to RICHACE_EXECUTE.
+ *
+ *  (Some of these NFSv4 permissions have the same bit values.)
+ */
+#define RICHACE_POSIX_MODE_READ (			\
+		RICHACE_READ_DATA |		\
+		RICHACE_LIST_DIRECTORY)
+#define RICHACE_POSIX_MODE_WRITE (			\
+		RICHACE_WRITE_DATA |		\
+		RICHACE_ADD_FILE |			\
+		RICHACE_APPEND_DATA |		\
+		RICHACE_ADD_SUBDIRECTORY |		\
+		RICHACE_DELETE_CHILD)
+#define RICHACE_POSIX_MODE_EXEC RICHACE_EXECUTE
+#define RICHACE_POSIX_MODE_ALL (			\
+		RICHACE_POSIX_MODE_READ |		\
+		RICHACE_POSIX_MODE_WRITE |		\
+		RICHACE_POSIX_MODE_EXEC)
+/*
+ * These permissions are always allowed
+ * no matter what the acl says.
+ */
+#define RICHACE_POSIX_ALWAYS_ALLOWED (	\
+		RICHACE_SYNCHRONIZE |	\
+		RICHACE_READ_ATTRIBUTES |	\
+		RICHACE_READ_ACL)
+/*
+ * The owner is implicitly granted
+ * these permissions under POSIX.
+ */
+#define RICHACE_POSIX_OWNER_ALLOWED (		\
+		RICHACE_WRITE_ATTRIBUTES |		\
+		RICHACE_WRITE_OWNER |		\
+		RICHACE_WRITE_ACL)
 /**
  * richacl_get  -  grab another reference to a richacl handle
  */
@@ -243,5 +286,8 @@ richace_is_same_identifier(const struct richace *a, const struct richace *b)
 
 extern struct richacl *richacl_alloc(int, gfp_t);
 extern struct richacl *richacl_clone(const struct richacl *, gfp_t);
+extern int richacl_masks_to_mode(const struct richacl *);
+extern unsigned int richacl_mode_to_mask(mode_t);
+extern unsigned int richacl_want_to_mask(unsigned int);
 
 #endif /* __RICHACL_H */
-- 
2.1.0

