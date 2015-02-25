Return-Path: linux-fsdevel-owner@vger.kernel.org
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 09/21] richacl: Permission mapping functions
Date: Thu, 26 Feb 2015 00:41:30 +0100
Message-Id: <fe15273975043bc6064de8395e41ba3066f8d5d4.1424907511.git.agruenba@redhat.com>
In-Reply-To: <cover.1424907511.git.agruenba@redhat.com>
References: <cover.1424907511.git.agruenba@redhat.com>
In-Reply-To: <cover.1424907511.git.agruenba@redhat.com>
References: <cover.1424907511.git.agruenba@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to map from POSIX permissions to NFSv4 permissions when a
chmod() is done, from NFSv4 permissions to POSIX permissions when an acl
is set (which implicitly sets the file permission bits), and from the
MAY_READ/MAY_WRITE/MAY_EXEC/MAY_APPEND flags to NFSv4 permissions when
doing an access check in a richacl.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 117 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  46 +++++++++++++++++++
 2 files changed, 163 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index abf8bce..83731c7 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -55,3 +55,120 @@ richacl_clone(const struct richacl *acl)
 	}
 	return dup;
 }
+
+/**
+ * richacl_mask_to_mode  -  compute the file permission bits which correspond to @mask
+ * @mask:	%ACE4_* permission mask
+ *
+ * See richacl_masks_to_mode().
+ */
+static int
+richacl_mask_to_mode(unsigned int mask)
+{
+	int mode = 0;
+
+	if (mask & ACE4_POSIX_MODE_READ)
+		mode |= S_IROTH;
+	if (mask & ACE4_POSIX_MODE_WRITE)
+		mode |= S_IWOTH;
+	if (mask & ACE4_POSIX_MODE_EXEC)
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
+ * ACE4_APPEND_DATA even if it does not also contain ACE4_WRITE_DATA.
+ *
+ * Permissions which are not in ACE4_POSIX_MODE_READ, ACE4_POSIX_MODE_WRITE, or
+ * ACE4_POSIX_MODE_EXEC cannot be represented in the file permission bits.
+ * Such permissions can still be effective, but not for new files or after a
+ * chmod(), and only if they were set explicitly, for example, by setting a
+ * richacl.
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
+	unsigned int mask = ACE4_POSIX_ALWAYS_ALLOWED;
+
+	if (mode & S_IROTH)
+		mask |= ACE4_POSIX_MODE_READ;
+	if (mode & S_IWOTH)
+		mask |= ACE4_POSIX_MODE_WRITE;
+	if (mode & S_IXOTH)
+		mask |= ACE4_POSIX_MODE_EXEC;
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
+ * MAY_WRITE to ACE4_ADD_FILE, ACE4_ADD_SUBDIRECTORY, and ACE4_DELETE_CHILD
+ * here.
+ */
+unsigned int
+richacl_want_to_mask(unsigned int want)
+{
+	unsigned int mask = 0;
+
+	if (want & MAY_READ)
+		mask |= ACE4_READ_DATA;
+	if (want & MAY_DELETE_SELF)
+		mask |= ACE4_DELETE;
+	if (want & MAY_TAKE_OWNERSHIP)
+		mask |= ACE4_WRITE_OWNER;
+	if (want & MAY_CHMOD)
+		mask |= ACE4_WRITE_ACL;
+	if (want & MAY_SET_TIMES)
+		mask |= ACE4_WRITE_ATTRIBUTES;
+	if (want & MAY_EXEC)
+		mask |= ACE4_EXECUTE;
+	/*
+	 * differentiate MAY_WRITE from these request
+	 */
+	if (want & (MAY_APPEND |
+		    MAY_CREATE_FILE | MAY_CREATE_DIR |
+		    MAY_DELETE_CHILD)) {
+		if (want & MAY_APPEND)
+			mask |= ACE4_APPEND_DATA;
+		if (want & MAY_CREATE_FILE)
+			mask |= ACE4_ADD_FILE;
+		if (want & MAY_CREATE_DIR)
+			mask |= ACE4_ADD_SUBDIRECTORY;
+		if (want & MAY_DELETE_CHILD)
+			mask |= ACE4_DELETE_CHILD;
+	} else if (want & MAY_WRITE)
+		mask |= ACE4_WRITE_DATA;
+	return mask;
+}
+EXPORT_SYMBOL_GPL(richacl_want_to_mask);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index b16d865..41819f4 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -120,6 +120,49 @@ struct richacl {
 	ACE4_WRITE_OWNER |				\
 	ACE4_SYNCHRONIZE)
 
+/*
+ * The POSIX permissions are supersets of the following NFSv4 permissions:
+ *
+ *  - MAY_READ maps to READ_DATA or LIST_DIRECTORY, depending on the type
+ *    of the file system object.
+ *
+ *  - MAY_WRITE maps to WRITE_DATA or ACE4_APPEND_DATA for files, and to
+ *    ADD_FILE, ACE4_ADD_SUBDIRECTORY, or ACE4_DELETE_CHILD for directories.
+ *
+ *  - MAY_EXECUTE maps to ACE4_EXECUTE.
+ *
+ *  (Some of these NFSv4 permissions have the same bit values.)
+ */
+#define ACE4_POSIX_MODE_READ (			\
+		ACE4_READ_DATA |		\
+		ACE4_LIST_DIRECTORY)
+#define ACE4_POSIX_MODE_WRITE (			\
+		ACE4_WRITE_DATA |		\
+		ACE4_ADD_FILE |			\
+		ACE4_APPEND_DATA |		\
+		ACE4_ADD_SUBDIRECTORY |		\
+		ACE4_DELETE_CHILD)
+#define ACE4_POSIX_MODE_EXEC ACE4_EXECUTE
+#define ACE4_POSIX_MODE_ALL (			\
+		ACE4_POSIX_MODE_READ |		\
+		ACE4_POSIX_MODE_WRITE |		\
+		ACE4_POSIX_MODE_EXEC)
+/*
+ * These permissions are always allowed
+ * no matter what the acl says.
+ */
+#define ACE4_POSIX_ALWAYS_ALLOWED (	\
+		ACE4_SYNCHRONIZE |	\
+		ACE4_READ_ATTRIBUTES |	\
+		ACE4_READ_ACL)
+/*
+ * The owner is implicitly granted
+ * these permissions under POSIX.
+ */
+#define ACE4_POSIX_OWNER_ALLOWED (		\
+		ACE4_WRITE_ATTRIBUTES |		\
+		ACE4_WRITE_OWNER |		\
+		ACE4_WRITE_ACL)
 /**
  * richacl_get  -  grab another reference to a richacl handle
  */
@@ -244,5 +287,8 @@ richace_is_same_identifier(const struct richace *a, const struct richace *b)
 }
 
 extern struct richacl *richacl_alloc(int);
+extern int richacl_masks_to_mode(const struct richacl *);
+extern unsigned int richacl_mode_to_mask(mode_t);
+extern unsigned int richacl_want_to_mask(unsigned int);
 
 #endif /* __RICHACL_H */
-- 
2.1.0

