Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:46540 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101Ab1IER11 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2011 13:27:27 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V6 14/26] richacl: Permission mapping functions
Date: Mon,  5 Sep 2011 22:55:36 +0530
Message-Id: <1315243548-18664-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andreas Gruenbacher <agruen@kernel.org>

We need to map from POSIX permissions to NFSv4 permissions when a
chmod() is done, from NFSv4 permissions to POSIX permissions when an acl
is set (which implicitly sets the file permission bits), and from the
MAY_READ/MAY_WRITE/MAY_EXEC/MAY_APPEND flags to NFSv4 permissions when
doing an access check in a richacl.

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/richacl_base.c       |  118 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |   46 ++++++++++++++++++
 2 files changed, 164 insertions(+), 0 deletions(-)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 3536626..d55b436 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -69,6 +69,124 @@ richacl_clone(const struct richacl *acl)
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
+richacl_want_to_mask(int want)
+{
+	unsigned int mask = 0;
+
+	if (want & MAY_READ)
+		mask |= ACE4_READ_DATA;
+	if (want & (MAY_APPEND |
+		    MAY_CREATE_FILE | MAY_CREATE_DIR |
+		    MAY_DELETE_CHILD | MAY_DELETE_SELF |
+		    MAY_TAKE_OWNERSHIP | MAY_CHMOD | MAY_SET_TIMES)) {
+		if (want & MAY_APPEND)
+			mask |= ACE4_APPEND_DATA;
+		else if (want & MAY_DELETE_SELF)
+			mask |= ACE4_DELETE;
+		else if (want & MAY_TAKE_OWNERSHIP)
+			mask |= ACE4_WRITE_OWNER;
+		else if (want & MAY_CHMOD)
+			mask |= ACE4_WRITE_ACL;
+		else if (want & MAY_SET_TIMES)
+			mask |= ACE4_WRITE_ATTRIBUTES;
+		else {
+			if (want & MAY_CREATE_FILE)
+				mask |= ACE4_ADD_FILE;
+			if (want & MAY_CREATE_DIR)
+				mask |= ACE4_ADD_SUBDIRECTORY;
+			if (want & MAY_DELETE_CHILD)
+				mask |= ACE4_DELETE_CHILD;
+		}
+	} else if (want & MAY_WRITE)
+		mask |= ACE4_WRITE_DATA;
+	if (want & MAY_EXEC)
+		mask |= ACE4_EXECUTE;
+
+	return mask;
+}
+EXPORT_SYMBOL_GPL(richacl_want_to_mask);
+
+/**
  * richace_is_same_identifier  -  are both identifiers the same?
  */
 int
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 745cfc1..7433ba3 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -117,6 +117,49 @@ struct richacl {
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
@@ -241,5 +284,8 @@ extern struct richacl *richacl_alloc(int);
 extern int richace_is_same_identifier(const struct richace *,
 				      const struct richace *);
 extern int richace_set_who(struct richace *, const char *);
+extern int richacl_masks_to_mode(const struct richacl *);
+extern unsigned int richacl_mode_to_mask(mode_t);
+extern unsigned int richacl_want_to_mask(int);
 
 #endif /* __RICHACL_H */
-- 
1.7.4.1

