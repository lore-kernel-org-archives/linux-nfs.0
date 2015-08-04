Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33042 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933570AbbHDLyp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 07:54:45 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: [RFC v6 08/40] richacl: Compute maximum file masks from an acl
Date: Tue,  4 Aug 2015 13:53:06 +0200
Message-Id: <1438689218-6921-9-git-send-email-agruenba@redhat.com>
In-Reply-To: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Compute upper bound owner, group, and other file masks with as few
permissions as possible without denying any permissions that the NFSv4
acl in a richacl grants.

This algorithm is used when a file inherits an acl at create time and
when an acl is set via a mechanism that does not provide file masks
(such as setting an acl via nfsd).  When user-space sets an acl via
setxattr, the extended attribute already includes the file masks.

Setting an acl also sets the file mode permission bits: they are
determined by the file masks; see richacl_masks_to_mode().

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Reviewed-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/richacl_base.c       | 156 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |   1 +
 2 files changed, 157 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 063dbe4..8426600 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -182,3 +182,159 @@ richacl_want_to_mask(unsigned int want)
 	return mask;
 }
 EXPORT_SYMBOL_GPL(richacl_want_to_mask);
+
+/*
+ * Note: functions like richacl_allowed_to_who(), richacl_group_class_allowed(),
+ * and richacl_compute_max_masks() iterate through the entire acl in reverse
+ * order as an optimization.
+ *
+ * In the standard algorithm, aces are considered in forward order.  When a
+ * process matches an ace, the permissions in the ace are either allowed or
+ * denied depending on the ace type.  Once a permission has been allowed or
+ * denied, it is no longer considered in further aces.
+ *
+ * By iterating through the acl in reverse order, we can compute the same
+ * result without having to keep track of which permissions have been allowed
+ * and denied already.
+ */
+
+/**
+ * richacl_allowed_to_who  -  permissions allowed to a specific who value
+ *
+ * Compute the maximum mask values allowed to a specific who value, taking
+ * everyone@ aces into account.
+ */
+static unsigned int richacl_allowed_to_who(struct richacl *acl,
+					   struct richace *who)
+{
+	struct richace *ace;
+	unsigned int allowed = 0;
+
+	richacl_for_each_entry_reverse(ace, acl) {
+		if (richace_is_inherit_only(ace))
+			continue;
+		if (richace_is_same_identifier(ace, who) ||
+		    richace_is_everyone(ace)) {
+			if (richace_is_allow(ace))
+				allowed |= ace->e_mask;
+			else if (richace_is_deny(ace))
+				allowed &= ~ace->e_mask;
+		}
+	}
+	return allowed;
+}
+
+/**
+ * richacl_group_class_allowed  -  maximum permissions of the group class
+ *
+ * Compute the maximum mask values allowed to a process in the group class
+ * (i.e., a process which is not the owner but is in the owning group or
+ * matches a user or group acl entry).  This includes permissions granted or
+ * denied by everyone@ aces.
+ *
+ * See richacl_compute_max_masks().
+ */
+static unsigned int richacl_group_class_allowed(struct richacl *acl)
+{
+	struct richace *ace;
+	unsigned int everyone_allowed = 0, group_class_allowed = 0;
+	int had_group_ace = 0;
+
+	richacl_for_each_entry_reverse(ace, acl) {
+		if (richace_is_inherit_only(ace) ||
+		    richace_is_owner(ace))
+			continue;
+
+		if (richace_is_everyone(ace)) {
+			if (richace_is_allow(ace))
+				everyone_allowed |= ace->e_mask;
+			else if (richace_is_deny(ace))
+				everyone_allowed &= ~ace->e_mask;
+		} else {
+			group_class_allowed |=
+				richacl_allowed_to_who(acl, ace);
+
+			if (richace_is_group(ace))
+				had_group_ace = 1;
+		}
+	}
+	/*
+	 * If the acl doesn't contain any group@ aces, richacl_allowed_to_who()
+	 * wasn't called for the owning group.  We could make that call now, but
+	 * we already know the result (everyone_allowed).
+	 */
+	if (!had_group_ace)
+		group_class_allowed |= everyone_allowed;
+	return group_class_allowed;
+}
+
+/**
+ * richacl_compute_max_masks  -  compute upper bound masks
+ *
+ * Computes upper bound owner, group, and other masks so that none of
+ * the mask flags allowed by the acl are disabled (for any user with any
+ * group membership).
+ */
+void richacl_compute_max_masks(struct richacl *acl, kuid_t owner)
+{
+	unsigned int gmask = ~0;
+	struct richace *ace;
+
+	/*
+	 * @gmask contains all permissions which the group class is ever
+	 * allowed.  We use it to avoid adding permissions to the group mask
+	 * from everyone@ allow aces which the group class is always denied
+	 * through other aces.  For example, the following acl would otherwise
+	 * result in a group mask of rw:
+	 *
+	 *	group@:w::deny
+	 *	everyone@:rw::allow
+	 *
+	 * Avoid computing @gmask for acls which do not include any group class
+	 * deny aces: in such acls, the group class is never denied any
+	 * permissions from everyone@ allow aces, and the group class cannot
+	 * have fewer permissions than the other class.
+	 */
+
+restart:
+	acl->a_owner_mask = 0;
+	acl->a_group_mask = 0;
+	acl->a_other_mask = 0;
+
+	richacl_for_each_entry_reverse(ace, acl) {
+		if (richace_is_inherit_only(ace))
+			continue;
+
+		if (richace_is_owner(ace) ||
+		    (richace_is_unix_user(ace) &&
+		     uid_eq(ace->e_id.uid, owner))) {
+			if (richace_is_allow(ace))
+				acl->a_owner_mask |= ace->e_mask;
+			else if (richace_is_deny(ace))
+				acl->a_owner_mask &= ~ace->e_mask;
+		} else if (richace_is_everyone(ace)) {
+			if (richace_is_allow(ace)) {
+				acl->a_owner_mask |= ace->e_mask;
+				acl->a_group_mask |= ace->e_mask & gmask;
+				acl->a_other_mask |= ace->e_mask;
+			} else if (richace_is_deny(ace)) {
+				acl->a_owner_mask &= ~ace->e_mask;
+				acl->a_group_mask &= ~ace->e_mask;
+				acl->a_other_mask &= ~ace->e_mask;
+			}
+		} else {
+			if (richace_is_allow(ace)) {
+				acl->a_owner_mask |= ace->e_mask & gmask;
+				acl->a_group_mask |= ace->e_mask & gmask;
+			} else if (richace_is_deny(ace) && gmask == ~0) {
+				gmask = richacl_group_class_allowed(acl);
+				if (likely(gmask != ~0))
+					/* should always be true */
+					goto restart;
+			}
+		}
+	}
+
+	acl->a_flags &= ~(RICHACL_WRITE_THROUGH | RICHACL_MASKED);
+}
+EXPORT_SYMBOL_GPL(richacl_compute_max_masks);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index f4ba113..3d719db 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -303,5 +303,6 @@ extern void richace_copy(struct richace *, const struct richace *);
 extern int richacl_masks_to_mode(const struct richacl *);
 extern unsigned int richacl_mode_to_mask(mode_t);
 extern unsigned int richacl_want_to_mask(unsigned int);
+extern void richacl_compute_max_masks(struct richacl *, kuid_t);
 
 #endif /* __RICHACL_H */
-- 
2.5.0

