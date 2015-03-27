Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:33205 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754026AbbC0QwU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:52:20 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 29/39] richacl: Create acl with masks applied in richacl_from_mode()
Date: Fri, 27 Mar 2015 17:50:27 +0100
Message-Id: <77629072ba55ba8e9044bf0775e54fec61dd5a98.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When creating a richacl that represents a particular file mode, one approach is
to create one everyone@ allow entry and set the richacl masks according to the
file mode; when those masks are applied with richacl_apply_masks(), that
everyone@ allow entry gets transformed as needed. The other approach is to
compute the result after richacl_apply_masks() directly; this commit does that.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_compat.c | 85 ++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 68 insertions(+), 17 deletions(-)

diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
index 8454621..9f99e21 100644
--- a/fs/richacl_compat.c
+++ b/fs/richacl_compat.c
@@ -755,30 +755,81 @@ EXPORT_SYMBOL_GPL(richacl_apply_masks);
 struct richacl *
 richacl_from_mode(mode_t mode)
 {
+	unsigned int owner_mask = richacl_mode_to_mask(mode >> 6) |
+				  RICHACE_POSIX_OWNER_ALLOWED;
+	unsigned int group_mask = richacl_mode_to_mask(mode >> 3);
+	unsigned int other_mask = richacl_mode_to_mask(mode);
+	unsigned int denied;
+	unsigned int entries = 0;
 	struct richacl *acl;
 	struct richace *ace;
 
-	acl = richacl_alloc(1, GFP_KERNEL);
+	/* RICHACE_DELETE_CHILD is meaningless for non-directories. */
+	if (!S_ISDIR(mode)) {
+		owner_mask &= ~RICHACE_DELETE_CHILD;
+		group_mask &= ~RICHACE_DELETE_CHILD;
+		other_mask &= ~RICHACE_DELETE_CHILD;
+	}
+
+	if (owner_mask & ~(group_mask & other_mask))
+		entries++;  /* OWNER@ ALLOW entry needed */
+	denied = ~owner_mask & (group_mask | other_mask);
+	if (denied)
+		entries++;  /* OWNER@ DENY entry needed */
+	if (group_mask & ~other_mask)
+		entries++;  /* GROUP@ ALLOW entry needed */
+	denied = ~group_mask & other_mask;
+	if (denied)
+		entries++;  /* GROUP@ DENY entry needed */
+	if (other_mask)
+		entries++;  /* EVERYONE@ ALLOW entry needed */
+
+	acl = richacl_alloc(entries, GFP_KERNEL);
 	if (!acl)
 		return NULL;
-	acl->a_flags = RICHACL_MASKED;
-	acl->a_owner_mask = richacl_mode_to_mask(mode >> 6) |
-			    RICHACE_POSIX_OWNER_ALLOWED;
-	acl->a_group_mask = richacl_mode_to_mask(mode >> 3);
-	acl->a_other_mask = richacl_mode_to_mask(mode);
-
+	acl->a_owner_mask = owner_mask;
+	acl->a_group_mask = group_mask;
+	acl->a_other_mask = other_mask;
 	ace = acl->a_entries;
-	ace->e_type  = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
-	ace->e_flags = RICHACE_SPECIAL_WHO;
-	ace->e_mask = RICHACE_POSIX_ALWAYS_ALLOWED |
-		      RICHACE_POSIX_MODE_ALL |
-		      RICHACE_POSIX_OWNER_ALLOWED;
-	/* RICHACE_DELETE_CHILD is meaningless for non-directories. */
-	if (!S_ISDIR(mode))
-		ace->e_mask &= ~RICHACE_DELETE_CHILD;
-	ace->e_id.special = RICHACE_EVERYONE_SPECIAL_ID;
 
-	return acl;
+	if (owner_mask & ~(group_mask & other_mask)) {
+		ace->e_type = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
+		ace->e_flags = RICHACE_SPECIAL_WHO;
+		ace->e_mask = owner_mask;
+		ace->e_id.special = RICHACE_OWNER_SPECIAL_ID;
+		ace++;
+	}
+	denied = ~owner_mask & (group_mask | other_mask);
+	if (denied) {
+		ace->e_type = RICHACE_ACCESS_DENIED_ACE_TYPE;
+		ace->e_flags = RICHACE_SPECIAL_WHO;
+		ace->e_mask = denied;
+		ace->e_id.special = RICHACE_OWNER_SPECIAL_ID;
+		ace++;
+	}
+	if (group_mask & ~other_mask) {
+		ace->e_type = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
+		ace->e_flags = RICHACE_SPECIAL_WHO;
+		ace->e_mask = group_mask;
+		ace->e_id.special = RICHACE_GROUP_SPECIAL_ID;
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
+	if (other_mask) {
+		ace->e_type = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
+		ace->e_flags = RICHACE_SPECIAL_WHO;
+		ace->e_mask = other_mask;
+		ace->e_id.special = RICHACE_EVERYONE_SPECIAL_ID;
+		ace++;
+	}
 
+	return acl;
 }
 EXPORT_SYMBOL_GPL(richacl_from_mode);
-- 
2.1.0

