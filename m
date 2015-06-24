Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37753 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145AbbFXV5p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2015 17:57:45 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        samba-technical@lists.samba.org, linux-security-module@vger.kernel.org
Subject: [RFC v4 09/31] richacl: Update the file masks in chmod()
Date: Wed, 24 Jun 2015 23:56:58 +0200
Message-Id: <1435183040-22726-10-git-send-email-agruenba@redhat.com>
In-Reply-To: <1435183040-22726-1-git-send-email-agruenba@redhat.com>
References: <1435183040-22726-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Doing a chmod() sets the file mode, which includes the file permission
bits.  When a file has a richacl, the permissions that the richacl
grants need to be limited to what the new file permission bits allow.

This is done by setting the file masks in the richacl to what the file
permission bits map to.  The richacl access check algorithm takes the
file masks into account, which ensures that the richacl cannot grant too
many permissions.

It is possible to explicitly add permissions to the file masks which go
beyond what the file permission bits can grant (like the RICHACE_WRITE_ACL
permission).  The POSIX.1 standard calls this an alternate file access
control mechanism.  A subsequent chmod() would ensure that those
permissions are disabled again.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 40 ++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  1 +
 2 files changed, 41 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index fda0568..162794b 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -325,3 +325,43 @@ restart:
 	acl->a_flags &= ~RICHACL_MASKED;
 }
 EXPORT_SYMBOL_GPL(richacl_compute_max_masks);
+
+/**
+ * richacl_chmod  -  update the file masks to reflect the new mode
+ * @mode:	new file permission bits including the file type
+ *
+ * Return a copy of @acl where the file masks have been replaced by the file
+ * masks corresponding to the file permission bits in @mode, or returns @acl
+ * itself if the file masks are already up to date.  Takes over a reference
+ * to @acl.
+ */
+struct richacl *
+richacl_chmod(struct richacl *acl, mode_t mode)
+{
+	unsigned int x = S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD;
+	unsigned int owner_mask, group_mask, other_mask;
+	struct richacl *clone;
+
+	owner_mask = richacl_mode_to_mask(mode >> 6) & ~x;
+	group_mask = richacl_mode_to_mask(mode >> 3) & ~x;
+	other_mask = richacl_mode_to_mask(mode)      & ~x;
+
+	if (acl->a_owner_mask == owner_mask &&
+	    acl->a_group_mask == group_mask &&
+	    acl->a_other_mask == other_mask &&
+	    (acl->a_flags & RICHACL_MASKED))
+		return acl;
+
+	clone = richacl_clone(acl, GFP_KERNEL);
+	richacl_put(acl);
+	if (!clone)
+		return ERR_PTR(-ENOMEM);
+
+	clone->a_flags |= RICHACL_MASKED;
+	clone->a_owner_mask = owner_mask;
+	clone->a_group_mask = group_mask;
+	clone->a_other_mask = other_mask;
+
+	return clone;
+}
+EXPORT_SYMBOL_GPL(richacl_chmod);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 3cea47a..c2a10b5 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -301,5 +301,6 @@ extern int richacl_masks_to_mode(const struct richacl *);
 extern unsigned int richacl_mode_to_mask(mode_t);
 extern unsigned int richacl_want_to_mask(unsigned int);
 extern void richacl_compute_max_masks(struct richacl *, kuid_t);
+extern struct richacl *richacl_chmod(struct richacl *, mode_t);
 
 #endif /* __RICHACL_H */
-- 
2.4.2

