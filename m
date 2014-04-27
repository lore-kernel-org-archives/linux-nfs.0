Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:40760 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753388AbaD0QPq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Apr 2014 12:15:46 -0400
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 28 Apr 2014 02:15:45 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V1 11/22] richacl: Permission mapping functions
Date: Sun, 27 Apr 2014 21:44:42 +0530
Message-Id: <1398615293-22931-12-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

We need to map from POSIX permissions to NFSv4 permissions when a
chmod() is done, from NFSv4 permissions to POSIX permissions when an acl
is set (which implicitly sets the file permission bits), and from the
MAY_READ/MAY_WRITE/MAY_EXEC/MAY_APPEND flags to NFSv4 permissions when
doing an access check in a richacl.

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/richacl_base.c       | 117 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  47 +++++++++++++++++++
 2 files changed, 164 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 689e1a6dace7..bca20936aed1 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -56,6 +56,123 @@ richacl_clone(const struct richacl *acl)
 }
 
 /**
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
+		mode |= MAY_READ;
+	if (mask & ACE4_POSIX_MODE_WRITE)
+		mode |= MAY_WRITE;
+	if (mask & ACE4_POSIX_MODE_EXEC)
+		mode |= MAY_EXEC;
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
+	if (mode & MAY_READ)
+		mask |= ACE4_POSIX_MODE_READ;
+	if (mode & MAY_WRITE)
+		mask |= ACE4_POSIX_MODE_WRITE;
+	if (mode & MAY_EXEC)
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
+
+/**
  * richace_is_same_identifier  -  are both identifiers the same?
  */
 int
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 51d6937651f1..fe875fe24636 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -119,6 +119,49 @@ struct richacl {
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
@@ -234,4 +277,8 @@ richace_is_deny(const struct richace *ace)
 extern struct richacl *richacl_alloc(int);
 extern int richace_is_same_identifier(const struct richace *,
 				      const struct richace *);
+extern int richacl_masks_to_mode(const struct richacl *);
+extern unsigned int richacl_mode_to_mask(mode_t);
+extern unsigned int richacl_want_to_mask(unsigned int);
+
 #endif /* __RICHACL_H */
-- 
1.9.1

