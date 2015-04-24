Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:34135 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754601AbbDXLFI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:05:08 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC v3 12/45] richacl: Compute maximum file masks from an acl
Date: Fri, 24 Apr 2015 13:04:09 +0200
Message-Id: <922da02afd085be0d28d3c76f0b4fcb3b2e811f3.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
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
 fs/richacl_base.c       | 154 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |   1 +
 2 files changed, 155 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 978f221..1e14c38 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -172,3 +172,157 @@ richacl_want_to_mask(unsigned int want)
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
+ * richacl_group_class_allowed  -  maximum permissions the group class is allowed
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
+ * the mask flags allowed by the acl are disabled (for any choice of the
+ * file owner or group membership).
+ */
+void richacl_compute_max_masks(struct richacl *acl)
+{
+	unsigned int gmask = ~0;
+	struct richace *ace;
+
+	/*
+	 * @gmask contains all permissions which the group class is ever
+	 * allowed.  We use it to avoid adding permissions to the group mask
+	 * from everyone@ allow aces which the group class is always denied
+	 * through other aces.  For example, the following acl would otherwise
+	 * result in a group mask or rw:
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
+		if (richace_is_owner(ace)) {
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
+	acl->a_flags &= ~RICHACL_MASKED;
+}
+EXPORT_SYMBOL_GPL(richacl_compute_max_masks);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index d19843b..cd0cdaa 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -289,5 +289,6 @@ extern struct richacl *richacl_clone(const struct richacl *, gfp_t);
 extern int richacl_masks_to_mode(const struct richacl *);
 extern unsigned int richacl_mode_to_mask(mode_t);
 extern unsigned int richacl_want_to_mask(unsigned int);
+extern void richacl_compute_max_masks(struct richacl *);
 
 #endif /* __RICHACL_H */
-- 
2.1.0

