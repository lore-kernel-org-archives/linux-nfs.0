Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:55131 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932943Ab1JRPfM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Oct 2011 11:35:12 -0400
Received: from /spool/local
	by au.ibm.com with XMail ESMTP
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 18 Oct 2011 15:33:55 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V7 17/26] richacl: Permission check algorithm
Date: Tue, 18 Oct 2011 21:02:52 +0530
Message-Id: <1318951981-5508-18-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

As in the standard POSIX file permission model, each process is the
owner, group, or other file class.  A process is

  - in the owner file class if it owns the file,
  - in the group file class if it is in the file's owning group or it
    matches any of the user or group entries, and
  - in the other file class otherwise.

Each file class is associated with a file mask.

A richacl grants a requested access if the NFSv4 acl in the richacl
grants the requested permissions (according to the NFSv4 permission
check algorithm) and the file mask that applies to the process includes
the requested permissions.

Acked-by: David Howells <dhowells@redhat.com>
Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/richacl_base.c       |   99 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |    2 +
 2 files changed, 101 insertions(+), 0 deletions(-)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index a5f215e..e9c2f30 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -392,3 +392,102 @@ richacl_chmod(struct richacl *acl, mode_t mode)
 	return clone;
 }
 EXPORT_SYMBOL_GPL(richacl_chmod);
+
+/**
+ * richacl_permission  -  richacl permission check algorithm
+ * @inode:	inode to check
+ * @acl:	rich acl of the inode
+ * @mask:	requested access (ACE4_* bitmask)
+ *
+ * Checks if the current process is granted @mask flags in @acl.
+ */
+int
+richacl_permission(struct inode *inode, const struct richacl *acl,
+		   unsigned int mask)
+{
+	const struct richace *ace;
+	unsigned int requested = mask, denied = 0;
+	int in_owning_group = in_group_p(inode->i_gid);
+	int in_owner_or_group_class = in_owning_group;
+
+	/*
+	 * We don't need to know which class the process is in when the acl is
+	 * not masked.
+	 */
+	if (!(acl->a_flags & ACL4_MASKED))
+		in_owner_or_group_class = 1;
+
+	/*
+	 * A process is
+	 *   - in the owner file class if it owns the file,
+	 *   - in the group file class if it is in the file's owning group or
+	 *     it matches any of the user or group entries, and
+	 *   - in the other file class otherwise.
+	 */
+
+	/*
+	 * Check if the acl grants the requested access and determine which
+	 * file class the process is in.
+	 */
+	richacl_for_each_entry(ace, acl) {
+		unsigned int ace_mask = ace->e_mask;
+
+		if (richace_is_inherit_only(ace))
+			continue;
+		if (richace_is_owner(ace)) {
+			if (current_fsuid() != inode->i_uid)
+				continue;
+			goto is_owner;
+		} else if (richace_is_group(ace)) {
+			if (!in_owning_group)
+				continue;
+		} else if (richace_is_unix_id(ace)) {
+			if (ace->e_flags & ACE4_IDENTIFIER_GROUP) {
+				if (!in_group_p(ace->u.e_id))
+					continue;
+			} else {
+				if (current_fsuid() != ace->u.e_id)
+					continue;
+			}
+		} else
+			goto is_everyone;
+
+is_owner:
+		/* The process is in the owner or group file class. */
+		in_owner_or_group_class = 1;
+
+is_everyone:
+		/* Check which mask flags the ACE allows or denies. */
+		if (richace_is_deny(ace))
+			denied |= ace_mask & mask;
+		mask &= ~ace_mask;
+
+		/*
+		 * Keep going until we know which file class
+		 * the process is in.
+		 */
+		if (!mask && in_owner_or_group_class)
+			break;
+	}
+	denied |= mask;
+
+	if (acl->a_flags & ACL4_MASKED) {
+		unsigned int file_mask;
+
+		/*
+		 * The file class a process is in determines which file mask
+		 * applies.  Check if that file mask also grants the requested
+		 * access.
+		 */
+		if (current_fsuid() == inode->i_uid)
+			file_mask = acl->a_owner_mask;
+		else if (in_owner_or_group_class)
+			file_mask = acl->a_group_mask;
+		else
+			file_mask = acl->a_other_mask;
+		denied |= requested & ~file_mask;
+	}
+
+	return denied ? -EACCES : 0;
+}
+EXPORT_SYMBOL_GPL(richacl_permission);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index be7db1f..86f7339 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -289,5 +289,7 @@ extern unsigned int richacl_mode_to_mask(mode_t);
 extern unsigned int richacl_want_to_mask(unsigned int);
 extern void richacl_compute_max_masks(struct richacl *);
 extern struct richacl *richacl_chmod(struct richacl *, mode_t);
+extern int richacl_permission(struct inode *, const struct richacl *,
+			      unsigned int);
 
 #endif /* __RICHACL_H */
-- 
1.7.5.4

