Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:36071 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933484AbbHDLz1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 07:55:27 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Andreas Gruenbacher <agruen@kernel.org>
Subject: [RFC v6 26/40] richacl: Apply the file masks to a richacl
Date: Tue,  4 Aug 2015 13:53:24 +0200
Message-Id: <1438689218-6921-27-git-send-email-agruenba@redhat.com>
In-Reply-To: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Put all the pieces of the acl transformation puzzle together for
computing a richacl which has the file masks "applied" so that the
standard nfsv4 access check algorithm can be used on the richacl.

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
---
 fs/richacl_compat.c     | 110 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |   3 ++
 2 files changed, 113 insertions(+)

diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
index d708603..e552c95 100644
--- a/fs/richacl_compat.c
+++ b/fs/richacl_compat.c
@@ -729,3 +729,113 @@ richacl_isolate_group_class(struct richacl_alloc *alloc)
 	}
 	return 0;
 }
+
+/**
+ * __richacl_apply_masks  -  apply the file masks to all aces
+ * @alloc:	acl and number of allocated entries
+ *
+ * Apply the owner mask to owner@ aces, the other mask to
+ * everyone@ aces, and the group mask to all other aces.
+ *
+ * The previous transformations have brought the acl into a
+ * form in which applying the masks will not lead to the
+ * accidental loss of permissions anymore.
+ */
+static int
+__richacl_apply_masks(struct richacl_alloc *alloc, kuid_t owner)
+{
+	struct richace *ace;
+
+	richacl_for_each_entry(ace, alloc->acl) {
+		unsigned int mask;
+
+		if (richace_is_inherit_only(ace) || !richace_is_allow(ace))
+			continue;
+		if (richace_is_owner(ace) ||
+		    (richace_is_unix_user(ace) && uid_eq(owner, ace->e_id.uid)))
+			mask = alloc->acl->a_owner_mask;
+		else if (richace_is_everyone(ace))
+			mask = alloc->acl->a_other_mask;
+		else
+			mask = alloc->acl->a_group_mask;
+		if (richace_change_mask(alloc, &ace, ace->e_mask & mask))
+			return -1;
+	}
+	return 0;
+}
+
+/**
+ * richacl_apply_masks  -  apply the masks to the acl
+ *
+ * Transform @acl so that the standard NFSv4 permission check algorithm (which
+ * is not aware of file masks) will compute the same access decisions as the
+ * richacl permission check algorithm (which looks at the acl and the file
+ * masks).
+ *
+ * This algorithm is split into several steps:
+ *
+ *   - Move everyone@ aces to the end of the acl.  This simplifies the other
+ *     transformations, and allows the everyone@ allow ace at the end of the
+ *     acl to eventually allow permissions to the other class only.
+ *
+ *   - Propagate everyone@ permissions up the acl.  This transformation makes
+ *     sure that the owner and group class aces won't lose any permissions when
+ *     we apply the other mask to the everyone@ allow ace at the end of the acl.
+ *
+ *   - Apply the file masks to all aces.
+ *
+ *   - Make sure the owner is granted the owner mask permissions.
+ *
+ *   - Make sure everyone is granted the other mask permissions.
+ *
+ *   - Make sure that the owner is not granted any permissions beyond the owner
+ *     mask from group class aces or from everyone@.
+ *
+ *   - Make sure that the group class is not granted any permissions from
+ *     everyone@.
+ *
+ * The algorithm is exact except for richacls which cannot be represented as an
+ * acl alone: for example, given this acl:
+ *
+ *    group@:rw::allow
+ *
+ * when file masks corresponding to mode 0600 are applied, the owner would only
+ * get rw access if he is a member of the owning group.  This algorithm would
+ * produce an empty acl in this case.  We fix this case by modifying
+ * richacl_permission() so that the group mask is always applied to group class
+ * aces.  With this fix, the owner would not have any access (beyond the
+ * implicit permissions always granted to owners).
+ *
+ * NOTE: Depending on the acl and file masks, this algorithm can increase the
+ * number of aces by almost a factor of three in the worst case. This may make
+ * the acl too large for some purposes.
+ */
+int
+richacl_apply_masks(struct richacl **acl, kuid_t owner)
+{
+	if ((*acl)->a_flags & RICHACL_MASKED) {
+		struct richacl_alloc alloc = {
+			.acl = richacl_clone(*acl, GFP_KERNEL),
+			.count = (*acl)->a_count,
+		};
+		if (!alloc.acl)
+			return -ENOMEM;
+
+		if (richacl_move_everyone_aces_down(&alloc) ||
+		    richacl_propagate_everyone(&alloc) ||
+		    __richacl_apply_masks(&alloc, owner) ||
+		    richacl_set_owner_permissions(&alloc) ||
+		    richacl_set_other_permissions(&alloc) ||
+		    richacl_isolate_owner_class(&alloc) ||
+		    richacl_isolate_group_class(&alloc)) {
+			richacl_put(alloc.acl);
+			return -ENOMEM;
+		}
+
+		alloc.acl->a_flags &= ~(RICHACL_WRITE_THROUGH | RICHACL_MASKED);
+		richacl_put(*acl);
+		*acl = alloc.acl;
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(richacl_apply_masks);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 565f12f..8723ec9 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -338,4 +338,7 @@ extern struct richacl *richacl_inherit(const struct richacl *, int);
 extern int richacl_permission(struct inode *, const struct richacl *, int);
 extern struct richacl *richacl_create(struct inode *, struct inode *);
 
+/* richacl_compat.c */
+extern int richacl_apply_masks(struct richacl **, kuid_t);
+
 #endif /* __RICHACL_H */
-- 
2.5.0

