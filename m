Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:37342 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933729AbbHDLz3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 07:55:29 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: [RFC v6 27/40] richacl: Create richacl from mode values
Date: Tue,  4 Aug 2015 13:53:25 +0200
Message-Id: <1438689218-6921-28-git-send-email-agruenba@redhat.com>
In-Reply-To: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A file can have "no acl" in the sense that only the file mode permission
bits determine access.  In that case, the getxattr system call fails with
errno == ENODATA (No such attribute).

Over the NFSv4 protocol, a file always has an acl, and we convert the file
mode permission bits into an equivalent acl with richacl_from_mode.  Such
"trivial" acls can be converted back to a file mode with
richacl_equiv_mode.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_compat.c     | 88 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  1 +
 2 files changed, 89 insertions(+)

diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
index e552c95..50839a1 100644
--- a/fs/richacl_compat.c
+++ b/fs/richacl_compat.c
@@ -839,3 +839,91 @@ richacl_apply_masks(struct richacl **acl, kuid_t owner)
 	return 0;
 }
 EXPORT_SYMBOL_GPL(richacl_apply_masks);
+
+/**
+ * richacl_from_mode  -  create an acl which corresponds to @mode
+ *
+ * The resulting acl doesn't have the RICHACL_MASKED flag set.
+ *
+ * @mode:	file mode including the file type
+ */
+struct richacl *
+richacl_from_mode(mode_t mode)
+{
+	unsigned int owner_mask = richacl_mode_to_mask(mode >> 6);
+	unsigned int group_mask = richacl_mode_to_mask(mode >> 3);
+	unsigned int other_mask = richacl_mode_to_mask(mode);
+	unsigned int denied;
+	unsigned int entries = 0;
+	struct richacl *acl;
+	struct richace *ace;
+
+	/* RICHACE_DELETE_CHILD is meaningless for non-directories. */
+	if (!S_ISDIR(mode)) {
+		owner_mask &= ~RICHACE_DELETE_CHILD;
+		group_mask &= ~RICHACE_DELETE_CHILD;
+		other_mask &= ~RICHACE_DELETE_CHILD;
+	}
+
+	denied = ~owner_mask & (group_mask | other_mask);
+	if (denied)
+		entries++;  /* owner@ deny entry needed */
+	if (owner_mask & ~(group_mask & other_mask))
+		entries++;  /* owner@ allow entry needed */
+	denied = ~group_mask & other_mask;
+	if (denied)
+		entries++;  /* group@ deny entry needed */
+	if (group_mask & ~other_mask)
+		entries++;  /* group@ allow entry needed */
+	if (other_mask)
+		entries++;  /* everyone@ allow entry needed */
+
+	acl = richacl_alloc(entries, GFP_KERNEL);
+	if (!acl)
+		return NULL;
+	acl->a_owner_mask = owner_mask;
+	acl->a_group_mask = group_mask;
+	acl->a_other_mask = other_mask;
+	ace = acl->a_entries;
+
+	denied = ~owner_mask & (group_mask | other_mask);
+	if (denied) {
+		ace->e_type = RICHACE_ACCESS_DENIED_ACE_TYPE;
+		ace->e_flags = RICHACE_SPECIAL_WHO;
+		ace->e_mask = denied;
+		ace->e_id.special = RICHACE_OWNER_SPECIAL_ID;
+		ace++;
+	}
+	if (owner_mask & ~(group_mask & other_mask)) {
+		ace->e_type = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
+		ace->e_flags = RICHACE_SPECIAL_WHO;
+		ace->e_mask = owner_mask;
+		ace->e_id.special = RICHACE_OWNER_SPECIAL_ID;
+		ace++;
+	}
+	denied = ~group_mask & other_mask;
+	if (denied) {
+		ace->e_type = RICHACE_ACCESS_DENIED_ACE_TYPE;
+		ace->e_flags = RICHACE_SPECIAL_WHO;
+		ace->e_mask = denied;
+		ace->e_id.special = RICHACE_GROUP_SPECIAL_ID;
+		ace++;
+	}
+	if (group_mask & ~other_mask) {
+		ace->e_type = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
+		ace->e_flags = RICHACE_SPECIAL_WHO;
+		ace->e_mask = group_mask;
+		ace->e_id.special = RICHACE_GROUP_SPECIAL_ID;
+		ace++;
+	}
+	if (other_mask) {
+		ace->e_type = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
+		ace->e_flags = RICHACE_SPECIAL_WHO;
+		ace->e_mask = other_mask;
+		ace->e_id.special = RICHACE_EVERYONE_SPECIAL_ID;
+		ace++;
+	}
+
+	return acl;
+}
+EXPORT_SYMBOL_GPL(richacl_from_mode);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 8723ec9..fce5d84 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -340,5 +340,6 @@ extern struct richacl *richacl_create(struct inode *, struct inode *);
 
 /* richacl_compat.c */
 extern int richacl_apply_masks(struct richacl **, kuid_t);
+extern struct richacl *richacl_from_mode(mode_t);
 
 #endif /* __RICHACL_H */
-- 
2.5.0

