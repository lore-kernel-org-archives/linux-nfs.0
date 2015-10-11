Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964822AbbJKXC0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Oct 2015 19:02:26 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org
Cc: Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH v10 28/46] richacl: Set the owner permissions to the owner mask
Date: Mon, 12 Oct 2015 00:58:39 +0200
Message-Id: <1444604337-17651-29-git-send-email-andreas.gruenbacher@gmail.com>
In-Reply-To: <1444604337-17651-1-git-send-email-andreas.gruenbacher@gmail.com>
References: <1444604337-17651-1-git-send-email-andreas.gruenbacher@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruenba@redhat.com>

In the write-through case, change the acl so that owner@ is granted the
permissions set in the owner mask (to match what the permission check
algorithm grants the owner).

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Reviewed-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/richacl_compat.c | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
index 7d007d7..16deeb4 100644
--- a/fs/richacl_compat.c
+++ b/fs/richacl_compat.c
@@ -416,3 +416,49 @@ richacl_propagate_everyone(struct richacl_alloc *alloc)
 	}
 	return 0;
 }
+
+/**
+ * richacl_set_owner_permissions  -  set the owner permissions to the owner mask
+ *
+ * In the write-through case, change the acl so that owner@ is granted the
+ * permissions set in the owner mask (to match what the permission check
+ * algorithm grants the owner).  This leaves at most one efective owner@ allow
+ * entry at the beginning of the acl.
+ */
+static int
+richacl_set_owner_permissions(struct richacl_alloc *alloc)
+{
+	unsigned int x = RICHACE_POSIX_ALWAYS_ALLOWED;
+	unsigned int owner_mask = alloc->acl->a_owner_mask & ~x;
+	unsigned int denied = 0;
+	struct richace *ace;
+
+	if (!((alloc->acl->a_flags & RICHACL_WRITE_THROUGH)))
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
2.5.0

