Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:36441 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752744AbbC0QwT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:52:19 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Cc: Andreas Gruenbacher <agruen@kernel.org>
Subject: [RFC 28/39] richacl: Create richacl from mode values
Date: Fri, 27 Mar 2015 17:50:26 +0100
Message-Id: <12503bb14bb098b6b3ad7b1c0bf6de8d05b48d6b.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Create a richacl that corresponds to given file mode permission bits.

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
---
 fs/richacl_compat.c     | 35 +++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  1 +
 2 files changed, 36 insertions(+)

diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
index 981bd49..8454621 100644
--- a/fs/richacl_compat.c
+++ b/fs/richacl_compat.c
@@ -747,3 +747,38 @@ richacl_apply_masks(struct richacl **acl)
 	return retval;
 }
 EXPORT_SYMBOL_GPL(richacl_apply_masks);
+
+/**
+ * richacl_from_mode  -  create an acl which corresponds to @mode
+ * @mode:	file mode including the file type
+ */
+struct richacl *
+richacl_from_mode(mode_t mode)
+{
+	struct richacl *acl;
+	struct richace *ace;
+
+	acl = richacl_alloc(1, GFP_KERNEL);
+	if (!acl)
+		return NULL;
+	acl->a_flags = RICHACL_MASKED;
+	acl->a_owner_mask = richacl_mode_to_mask(mode >> 6) |
+			    RICHACE_POSIX_OWNER_ALLOWED;
+	acl->a_group_mask = richacl_mode_to_mask(mode >> 3);
+	acl->a_other_mask = richacl_mode_to_mask(mode);
+
+	ace = acl->a_entries;
+	ace->e_type  = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
+	ace->e_flags = RICHACE_SPECIAL_WHO;
+	ace->e_mask = RICHACE_POSIX_ALWAYS_ALLOWED |
+		      RICHACE_POSIX_MODE_ALL |
+		      RICHACE_POSIX_OWNER_ALLOWED;
+	/* RICHACE_DELETE_CHILD is meaningless for non-directories. */
+	if (!S_ISDIR(mode))
+		ace->e_mask &= ~RICHACE_DELETE_CHILD;
+	ace->e_id.special = RICHACE_EVERYONE_SPECIAL_ID;
+
+	return acl;
+
+}
+EXPORT_SYMBOL_GPL(richacl_from_mode);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 1a07ea0..cda945a 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -325,5 +325,6 @@ extern struct richacl *richacl_create(struct inode *, struct inode *);
 
 /* richacl_compat.c */
 extern int richacl_apply_masks(struct richacl **);
+extern struct richacl *richacl_from_mode(mode_t);
 
 #endif /* __RICHACL_H */
-- 
2.1.0

