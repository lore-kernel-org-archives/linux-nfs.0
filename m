Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35973 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933662AbbHDLzX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 07:55:23 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: [RFC v6 24/40] richacl: Set the other permissions to the other mask
Date: Tue,  4 Aug 2015 13:53:22 +0200
Message-Id: <1438689218-6921-25-git-send-email-agruenba@redhat.com>
In-Reply-To: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the acl so that everyone@ is granted the permissions set in the
other mask.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_compat.c | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
index 807372d..76d5ab9 100644
--- a/fs/richacl_compat.c
+++ b/fs/richacl_compat.c
@@ -458,3 +458,38 @@ richacl_set_owner_permissions(struct richacl_alloc *alloc)
 	}
 	return 0;
 }
+
+/**
+ * richacl_set_other_permissions  -  set the other permissions to the other mask
+ *
+ * Change the acl so that everyone@ is granted the permissions set in the other
+ * mask.  This leaves at most one efective everyone@ allow entry at the end of
+ * the acl.
+ */
+static int
+richacl_set_other_permissions(struct richacl_alloc *alloc)
+{
+	struct richacl *acl = alloc->acl;
+	unsigned int x = RICHACE_POSIX_ALWAYS_ALLOWED;
+	unsigned int other_mask = acl->a_other_mask & ~x;
+	struct richace *ace = acl->a_entries + acl->a_count - 1;
+
+	if (!(other_mask &&
+	      (acl->a_flags & RICHACL_WRITE_THROUGH) &&
+	      (acl->a_flags & RICHACL_MASKED)))
+		return 0;
+
+	if (acl->a_count == 0 ||
+	    !richace_is_everyone(ace) ||
+	    richace_is_inherit_only(ace)) {
+		ace++;
+		if (richacl_insert_entry(alloc, &ace))
+			return -1;
+		ace->e_type = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
+		ace->e_flags = RICHACE_SPECIAL_WHO;
+		ace->e_mask = other_mask;
+		ace->e_id.special = RICHACE_EVERYONE_SPECIAL_ID;
+	} else
+		richace_change_mask(alloc, &ace, other_mask);
+	return 0;
+}
-- 
2.5.0

