Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:36951 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474AbbFXV6H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2015 17:58:07 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        samba-technical@lists.samba.org, linux-security-module@vger.kernel.org
Subject: [RFC v4 24/31] richacl: Set the other permissions to the other mask
Date: Wed, 24 Jun 2015 23:57:13 +0200
Message-Id: <1435183040-22726-25-git-send-email-agruenba@redhat.com>
In-Reply-To: <1435183040-22726-1-git-send-email-agruenba@redhat.com>
References: <1435183040-22726-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the acl so that everyone@ is granted the permissions set in the other
mask.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_compat.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
index 882c2f1..b699cd3 100644
--- a/fs/richacl_compat.c
+++ b/fs/richacl_compat.c
@@ -447,3 +447,36 @@ richacl_set_owner_permissions(struct richacl_alloc *alloc)
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
+	if (!other_mask)
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
2.4.2

