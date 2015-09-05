Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57601 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752022AbbIEK2W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Sep 2015 06:28:22 -0400
From: Andreas Gruenbacher <agruenba@redhat.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Subject: [RFC v7 23/41] richacl: Set the owner permissions to the owner mask
Date: Sat,  5 Sep 2015 12:27:18 +0200
Message-Id: <1441448856-13478-24-git-send-email-agruenba@redhat.com>
In-Reply-To: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the acl so that owner@ is granted the permissions set in the
owner mask.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_compat.c | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
index 9b76fc0..14a1b4b 100644
--- a/fs/richacl_compat.c
+++ b/fs/richacl_compat.c
@@ -413,3 +413,49 @@ richacl_propagate_everyone(struct richacl_alloc *alloc)
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
+	if (!((alloc->acl->a_flags & RICHACL_WRITE_THROUGH) &&
+	      (alloc->acl->a_flags & RICHACL_MASKED)))
+		return 0;
+
+	richacl_for_each_entry(ace, alloc->acl) {
+		if (richace_is_owner(ace)) {
+			if (richace_is_allow(ace) && !(owner_mask & denied)) {
+				richace_change_mask(alloc, &ace, owner_mask);
+				owner_mask = 0;
+			} else
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
2.4.3

