Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:34550 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376Ab1IER2p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2011 13:28:45 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V6 16/26] richacl: Update the file masks in chmod()
Date: Mon,  5 Sep 2011 22:55:38 +0530
Message-Id: <1315243548-18664-17-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andreas Gruenbacher <agruen@kernel.org>

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

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/richacl_base.c       |   40 ++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |    1 +
 2 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 84a5698..60a65d7 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -353,3 +353,43 @@ restart:
 	acl->a_flags &= ~ACL4_MASKED;
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
+		     ACE4_POSIX_OWNER_ALLOWED;
+	group_mask = richacl_mode_to_mask(mode >> 3);
+	other_mask = richacl_mode_to_mask(mode);
+
+	if (acl->a_owner_mask == owner_mask &&
+	    acl->a_group_mask == group_mask &&
+	    acl->a_other_mask == other_mask &&
+	    (acl->a_flags & ACL4_MASKED))
+		return acl;
+
+	clone = richacl_clone(acl);
+	richacl_put(acl);
+	if (!clone)
+		return ERR_PTR(-ENOMEM);
+
+	clone->a_flags |= ACL4_MASKED;
+	clone->a_owner_mask = owner_mask;
+	clone->a_group_mask = group_mask;
+	clone->a_other_mask = other_mask;
+
+	return clone;
+}
+EXPORT_SYMBOL_GPL(richacl_chmod);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 102a58c..6dd8eb2 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -288,5 +288,6 @@ extern int richacl_masks_to_mode(const struct richacl *);
 extern unsigned int richacl_mode_to_mask(mode_t);
 extern unsigned int richacl_want_to_mask(int);
 extern void richacl_compute_max_masks(struct richacl *);
+extern struct richacl *richacl_chmod(struct richacl *, mode_t);
 
 #endif /* __RICHACL_H */
-- 
1.7.4.1

