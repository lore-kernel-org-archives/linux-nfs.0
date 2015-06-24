Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:36630 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463AbbFXV6H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2015 17:58:07 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        samba-technical@lists.samba.org, linux-security-module@vger.kernel.org
Subject: [RFC v4 23/31] richacl: Set the owner permissions to the owner mask
Date: Wed, 24 Jun 2015 23:57:12 +0200
Message-Id: <1435183040-22726-24-git-send-email-agruenba@redhat.com>
In-Reply-To: <1435183040-22726-1-git-send-email-agruenba@redhat.com>
References: <1435183040-22726-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the acl so that owner@ is granted the permissions set in the owner mask.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_compat.c | 42 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
index c6db72a..882c2f1 100644
--- a/fs/richacl_compat.c
+++ b/fs/richacl_compat.c
@@ -405,3 +405,45 @@ richacl_propagate_everyone(struct richacl_alloc *alloc)
 	}
 	return 0;
 }
+
+/**
+ * richacl_set_owner_permissions  -  set the owner permissions to the owner mask
+ *
+ * Change the acl so that owner@ is granted the permissions set in the owner
+ * mask.  This leaves at most one efective owner@ allow entry at the beginning
+ * of the acl.
+ */
+static int
+richacl_set_owner_permissions(struct richacl_alloc *alloc)
+{
+	unsigned int x = RICHACE_POSIX_ALWAYS_ALLOWED;
+	unsigned int owner_mask = alloc->acl->a_owner_mask & ~x;
+	unsigned int denied = 0;
+	struct richace *ace;
+
+	if (!owner_mask)
+		return 0;
+
+	richacl_for_each_entry(ace, alloc->acl) {
+		if (richace_is_owner(ace)) {
+			if (!richace_is_inherit_only(ace))
+				richace_change_mask(alloc, &ace, 0);
+		} else {
+			if (richace_is_deny(ace))
+				denied |= ace->e_mask;
+		}
+	}
+
+	if (owner_mask & (denied |
+			  ~alloc->acl->a_other_mask |
+			  ~alloc->acl->a_group_mask)) {
+		ace = alloc->acl->a_entries;
+		if (richacl_insert_entry(alloc, &ace))
+			return -1;
+		ace->e_type = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
+		ace->e_flags = RICHACE_SPECIAL_WHO;
+		ace->e_mask = owner_mask;
+		ace->e_id.special = RICHACE_OWNER_SPECIAL_ID;
+	}
+	return 0;
+}
-- 
2.4.2

