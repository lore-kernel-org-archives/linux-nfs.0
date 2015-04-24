Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35262 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699AbbDXLFJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:05:09 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC v3 13/45] richacl: Update the file masks in chmod()
Date: Fri, 24 Apr 2015 13:04:10 +0200
Message-Id: <b98c8f35704ab7ec3c10f25fe2d749936f13e4ca.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
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
beyond what the file permission bits can grant (like the ACE4_WRITE_ACL
permission).  The POSIX.1 standard calls this an alternate file access
control mechanism.  A subsequent chmod() would ensure that those
permissions are disabled again.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 40 ++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  1 +
 2 files changed, 41 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 1e14c38..261ddd2 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -326,3 +326,43 @@ restart:
 	acl->a_flags &= ~RICHACL_MASKED;
 }
 EXPORT_SYMBOL_GPL(richacl_compute_max_masks);
+
+/**
+ * richacl_chmod  -  update the file masks to reflect the new mode
+ * @mode:	new file permission bits
+ *
+ * Return a copy of @acl where the file masks have been replaced by the file
+ * masks corresponding to the file permission bits in @mode, or returns @acl
+ * itself if the file masks are already up to date.  Takes over a reference
+ * to @acl.
+ */
+struct richacl *
+richacl_chmod(struct richacl *acl, mode_t mode)
+{
+	unsigned int owner_mask, group_mask, other_mask;
+	struct richacl *clone;
+
+	owner_mask = richacl_mode_to_mask(mode >> 6) |
+		     RICHACE_POSIX_OWNER_ALLOWED;
+	group_mask = richacl_mode_to_mask(mode >> 3);
+	other_mask = richacl_mode_to_mask(mode);
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
index cd0cdaa..a27ff10 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -290,5 +290,6 @@ extern int richacl_masks_to_mode(const struct richacl *);
 extern unsigned int richacl_mode_to_mask(mode_t);
 extern unsigned int richacl_want_to_mask(unsigned int);
 extern void richacl_compute_max_masks(struct richacl *);
+extern struct richacl *richacl_chmod(struct richacl *, mode_t);
 
 #endif /* __RICHACL_H */
-- 
2.1.0

