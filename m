Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53778 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932356AbbKCPVT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2015 10:21:19 -0500
From: Andreas Gruenbacher <agruenba@redhat.com>
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
Subject: [PATCH v13 32/51] richacl: Set the other permissions to the other mask
Date: Tue,  3 Nov 2015 16:17:08 +0100
Message-Id: <1446563847-14005-33-git-send-email-agruenba@redhat.com>
In-Reply-To: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
References: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the acl so that everyone@ is granted the permissions set in the
other mask.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Reviewed-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/richacl_compat.c | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
index d9fee8b..76183c9 100644
--- a/fs/richacl_compat.c
+++ b/fs/richacl_compat.c
@@ -462,3 +462,44 @@ richacl_set_owner_permissions(struct richacl_alloc *alloc)
 	}
 	return 0;
 }
+
+/**
+ * richacl_set_other_permissions  -  set the other permissions to the other mask
+ * @alloc:	acl and number of allocated entries
+ * @added:	permissions added for everyone@
+ *
+ * Change the acl so that everyone@ is granted the permissions set in the other
+ * mask.  This leaves at most one efective everyone@ allow entry at the end of
+ * the acl.  If everyone@ end up being granted additional permissions, these
+ * permissions are returned in @added.
+ */
+static int
+richacl_set_other_permissions(struct richacl_alloc *alloc, unsigned int *added)
+{
+	struct richacl *acl = alloc->acl;
+	unsigned int x = RICHACE_POSIX_ALWAYS_ALLOWED;
+	unsigned int other_mask = acl->a_other_mask & ~x;
+	struct richace *ace;
+
+	if (!(other_mask &&
+	      (acl->a_flags & RICHACL_WRITE_THROUGH)))
+		return 0;
+
+	*added = other_mask;
+	ace = acl->a_entries + acl->a_count - 1;
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
+	} else {
+		*added &= ~ace->e_mask;
+		richace_change_mask(alloc, &ace, other_mask);
+	}
+	return 0;
+}
-- 
2.5.0

