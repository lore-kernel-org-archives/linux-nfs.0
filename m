Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36789 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756832AbbGVNEb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 09:04:31 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, samba-technical@lists.samba.org,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Andreas Gruenbacher <agruen@kernel.org>
Subject: [PATCH v5 21/39] richacl: Move everyone@ aces down the acl
Date: Wed, 22 Jul 2015 15:03:11 +0200
Message-Id: <1437570209-29832-22-git-send-email-andreas.gruenbacher@gmail.com>
In-Reply-To: <1437570209-29832-1-git-send-email-andreas.gruenbacher@gmail.com>
References: <1437570209-29832-1-git-send-email-andreas.gruenbacher@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruenba@redhat.com>

The POSIX standard puts processes which are not the owner or a member in
the owning group or which match any ace other then everyone@ on the
other file class.  We only know if a process is in the other class after
processing the entire acl.

Move all everyone@ aces in the acl down in the acl so that at most a
single everyone@ allow ace remains at the end.  Permissions which are
not explicitly allowed are implicitly denied, so an everyone@ deny ace is
unneeded.

The everyone@ aces can be moved down the acl without changing the
permissions that the acl grants.  This transformation simplifies the
following algorithms, and eventually allows us to turn the final
everyone@ allow ace into an entry for the other class.

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
---
 fs/richacl_compat.c | 65 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 65 insertions(+)

diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
index 5bbf993..e10ead3 100644
--- a/fs/richacl_compat.c
+++ b/fs/richacl_compat.c
@@ -152,3 +152,68 @@ richace_change_mask(struct richacl_alloc *alloc, struct richace **ace,
 	}
 	return 0;
 }
+
+/**
+ * richacl_move_everyone_aces_down  -  move everyone@ aces to the end of the acl
+ * @alloc:	acl and number of allocated entries
+ *
+ * Move all everyone aces to the end of the acl so that only a single everyone@
+ * allow ace remains at the end, and update the mask fields of all aces on the
+ * way.  The last ace of the resulting acl will be an everyone@ allow ace only
+ * if @acl grants any permissions to @everyone.  No @everyone deny aces will
+ * remain.
+ *
+ * This transformation does not alter the permissions that the acl grants.
+ * Having at most one everyone@ allow ace at the end of the acl helps us in the
+ * following algorithms.
+ */
+static int
+richacl_move_everyone_aces_down(struct richacl_alloc *alloc)
+{
+	struct richace *ace;
+	unsigned int allowed = 0, denied = 0;
+
+	richacl_for_each_entry(ace, alloc->acl) {
+		if (richace_is_inherit_only(ace))
+			continue;
+		if (richace_is_everyone(ace)) {
+			if (richace_is_allow(ace))
+				allowed |= (ace->e_mask & ~denied);
+			else if (richace_is_deny(ace))
+				denied |= (ace->e_mask & ~allowed);
+			else
+				continue;
+			if (richace_change_mask(alloc, &ace, 0))
+				return -1;
+		} else {
+			if (richace_is_allow(ace)) {
+				if (richace_change_mask(alloc, &ace, allowed |
+						(ace->e_mask & ~denied)))
+					return -1;
+			} else if (richace_is_deny(ace)) {
+				if (richace_change_mask(alloc, &ace, denied |
+						(ace->e_mask & ~allowed)))
+					return -1;
+			}
+		}
+	}
+	if (allowed & ~RICHACE_POSIX_ALWAYS_ALLOWED) {
+		struct richace *last_ace = ace - 1;
+
+		if (alloc->acl->a_entries &&
+		    richace_is_everyone(last_ace) &&
+		    richace_is_allow(last_ace) &&
+		    richace_is_inherit_only(last_ace) &&
+		    last_ace->e_mask == allowed)
+			last_ace->e_flags &= ~RICHACE_INHERIT_ONLY_ACE;
+		else {
+			if (richacl_insert_entry(alloc, &ace))
+				return -1;
+			ace->e_type = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
+			ace->e_flags = RICHACE_SPECIAL_WHO;
+			ace->e_mask = allowed;
+			ace->e_id.special = RICHACE_EVERYONE_SPECIAL_ID;
+		}
+	}
+	return 0;
+}
-- 
2.4.3

