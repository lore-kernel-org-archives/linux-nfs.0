Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:36886 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964967AbbDXLFd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:05:33 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Cc: Andreas Gruenbacher <agruen@kernel.org>
Subject: [RFC v3 30/45] richacl: Create richacl from mode values
Date: Fri, 24 Apr 2015 13:04:27 +0200
Message-Id: <b435787dd651572f42984f9dec2a68cbf38bc7bf.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Create a richacl that corresponds to given file mode permission bits.

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
---
 fs/richacl_compat.c     | 38 ++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  1 +
 2 files changed, 39 insertions(+)

diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
index 49af600..8ebe772 100644
--- a/fs/richacl_compat.c
+++ b/fs/richacl_compat.c
@@ -750,3 +750,41 @@ richacl_apply_masks(struct richacl **acl)
 	return 0;
 }
 EXPORT_SYMBOL_GPL(richacl_apply_masks);
+
+/**
+ * richacl_from_mode_unmasked  -  create an acl which corresponds to @mode
+ *
+ * The resulting acl doesn't have the RICHACL_MASKED flag set.
+ *
+ * @mode:	file mode including the file type
+ */
+struct richacl *
+richacl_from_mode_unmasked(mode_t mode)
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
+EXPORT_SYMBOL_GPL(richacl_from_mode_unmasked);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 6a97dca..25ff4df 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -327,5 +327,6 @@ extern struct richacl *richacl_create(struct inode *, struct inode *);
 
 /* richacl_compat.c */
 extern int richacl_apply_masks(struct richacl **);
+extern struct richacl *richacl_from_mode_unmasked(mode_t);
 
 #endif /* __RICHACL_H */
-- 
2.1.0

