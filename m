Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:36421 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932910AbbDXLF3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:05:29 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Cc: Andreas Gruenbacher <agruen@kernel.org>
Subject: [RFC v3 27/45] richacl: Propagate everyone@ permissions to other aces
Date: Fri, 24 Apr 2015 13:04:24 +0200
Message-Id: <93925a334bfd554616ab0ff9986dd8ddf88d1e9a.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The trailing everyone@ allow ace can grant permissions to all file
classes including the owner and group class.  Before we can apply the
other mask to this entry to turn it into an "other class" entry, we need
to ensure that members of the owner or group class will not lose any
permissions from that ace.

Conceptually, we do this by inserting additional <who>:<allow>::allow
entries before the trailing everyone@ allow ace with the same
permissions as the trailing everyone@ allow ace for owner@, group@, and
all explicitly mentioned users and groups.  (In practice, we will rarely
need to insert any additional aces in this step.)

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
---
 fs/richacl_compat.c | 190 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 190 insertions(+)

diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
index 63f4373..f43d007 100644
--- a/fs/richacl_compat.c
+++ b/fs/richacl_compat.c
@@ -224,3 +224,193 @@ richacl_move_everyone_aces_down(struct richacl_alloc *x)
 	}
 	return 0;
 }
+
+/**
+ * __richacl_propagate_everyone  -  propagate everyone@ permissions up for @who
+ * @x:		acl and number of allocated entries
+ * @who:	identifier to propagate permissions for
+ * @allow:	permissions to propagate up
+ *
+ * Propagate the permissions in @allow up from the end of the acl to the start
+ * for the specified principal @who.
+ *
+ * The simplest possible approach to achieve this would be to insert a
+ * "<who>:<allow>::allow" ace before the final everyone@ allow ace.  Since this
+ * would often result in aces which are not needed or which could be merged
+ * with an existing ace, we make the following optimizations:
+ *
+ *   - We go through the acl and determine which permissions are already
+ *     allowed or denied to @who, and we remove those permissions from
+ *     @allow.
+ *
+ *   - If the acl contains an allow ace for @who and no aces after this entry
+ *     deny permissions in @allow, we add the permissions in @allow to this
+ *     ace.  (Propagating permissions across a deny ace which can match the
+ *     process can elevate permissions.)
+ *
+ * This transformation does not alter the permissions that the acl grants.
+ */
+static int
+__richacl_propagate_everyone(struct richacl_alloc *x, struct richace *who,
+			  unsigned int allow)
+{
+	struct richace *allow_last = NULL, *ace;
+
+	/*
+	 * Remove the permissions from allow that are already determined for
+	 * this who value, and figure out if there is an allow entry for
+	 * this who value that is "reachable" from the trailing everyone@
+	 * allow ace.
+	 */
+	richacl_for_each_entry(ace, x->acl) {
+		if (richace_is_inherit_only(ace))
+			continue;
+		if (richace_is_allow(ace)) {
+			if (richace_is_same_identifier(ace, who)) {
+				allow &= ~ace->e_mask;
+				allow_last = ace;
+			}
+		} else if (richace_is_deny(ace)) {
+			if (richace_is_same_identifier(ace, who))
+				allow &= ~ace->e_mask;
+			else if (allow & ace->e_mask)
+				allow_last = NULL;
+		}
+	}
+	if (allow) {
+		if (allow_last)
+			return richace_change_mask(x, &allow_last,
+						   allow_last->e_mask | allow);
+		else {
+			struct richace who_copy;
+
+			ace = x->acl->a_entries + x->acl->a_count - 1;
+			memcpy(&who_copy, who, sizeof(struct richace));
+			if (richacl_insert_entry(x, &ace))
+				return -1;
+			memcpy(ace, &who_copy, sizeof(struct richace));
+			ace->e_type = RICHACE_ACCESS_ALLOWED_ACE_TYPE;
+			richace_clear_inheritance_flags(ace);
+			ace->e_mask = allow;
+		}
+	}
+	return 0;
+}
+
+/**
+ * richacl_propagate_everyone  -  propagate everyone@ permissions up the acl
+ * @x:		acl and number of allocated entries
+ *
+ * Make sure that owner@, group@, and all other users and groups mentioned in
+ * the acl will not lose any permissions when finally applying the other mask
+ * to the everyone@ allow ace at the end of the acl.  If one of those
+ * principals is not granted some of those permissions, insert an additional
+ * allow ace for that principal into the acl before the final everyone@ allow
+ * ace.
+ *
+ * For example, the following acl implicitly grants everyone rwx access:
+ *
+ *    joe:r::allow
+ *    everyone@:rwx::allow
+ *
+ * When applying mode 0660 to this acl, owner@ and group@ would lose rw access,
+ * and joe would lose w access even though the mode does not exclude those
+ * permissions.  To fix this problem, we insert additional allow aces into the
+ * acl.  The result after applying mode 0660 is:
+ *
+ *    joe:rw::allow
+ *    owner@:rw::allow
+ *    group@:rw::allow
+ *
+ * Deny aces complicate the matter.  For example, the following acl grants
+ * everyone but joe write access:
+ *
+ *    joe:w::deny
+ *    everyone@:rwx::allow
+ *
+ * When applying mode 0660 to this acl, owner@ and group@ would lose rw access,
+ * and joe would lose r access.  The result after inserting additional allow
+ * aces and applying mode 0660 is:
+ *
+ *    joe:w::deny
+ *    owner@:rw::allow
+ *    group@:rw::allow
+ *    joe:r::allow
+ *
+ * Inserting the additional aces does not alter the permissions that the acl
+ * grants.
+ */
+static int
+richacl_propagate_everyone(struct richacl_alloc *x)
+{
+	struct richace who = { .e_flags = RICHACE_SPECIAL_WHO };
+	struct richacl *acl = x->acl;
+	struct richace *ace;
+	unsigned int owner_allow, group_allow;
+
+	/*
+	 * If the owner mask contains permissions which are not in
+	 * the group mask, the group mask contains permissions which
+	 * are not in the other mask, or the owner class contains
+	 * permissions which are not in the other mask,	we may need
+	 * to propagate permissions up from the everyone@ allow ace.
+	 * The third condition is implied by the first two.
+	 */
+	if (!((acl->a_owner_mask & ~acl->a_group_mask) ||
+	      (acl->a_group_mask & ~acl->a_other_mask)))
+		return 0;
+	if (!acl->a_count)
+		return 0;
+	ace = acl->a_entries + acl->a_count - 1;
+	if (richace_is_inherit_only(ace) || !richace_is_everyone(ace))
+		return 0;
+	if (!(ace->e_mask & ~(acl->a_group_mask & acl->a_other_mask)))
+		/*
+		 * None of the allowed permissions will get masked.
+		 */
+		return 0;
+	owner_allow = (ace->e_mask & acl->a_owner_mask) |
+		      RICHACE_POSIX_OWNER_ALLOWED;
+	group_allow = ace->e_mask & acl->a_group_mask;
+
+	/* Propagate everyone@ permissions through to owner@. */
+	if (owner_allow & ~(acl->a_group_mask & acl->a_other_mask)) {
+		who.e_id.special = RICHACE_OWNER_SPECIAL_ID;
+		if (__richacl_propagate_everyone(x, &who, owner_allow))
+			return -1;
+		acl = x->acl;
+	}
+
+	if (group_allow & ~acl->a_other_mask) {
+		int n;
+
+		/* Propagate everyone@ permissions through to group@. */
+		who.e_id.special = RICHACE_GROUP_SPECIAL_ID;
+		if (__richacl_propagate_everyone(x, &who, group_allow))
+			return -1;
+		acl = x->acl;
+
+		/*
+		 * Start from the entry before the trailing everyone@ allow
+		 * entry. We will not hit everyone@ entries in the loop.
+		 */
+		for (n = acl->a_count - 2; n != -1; n--) {
+			ace = acl->a_entries + n;
+
+			if (richace_is_inherit_only(ace) ||
+			    richace_is_owner(ace) ||
+			    richace_is_group(ace))
+				continue;
+			if (richace_is_allow(ace) || richace_is_deny(ace)) {
+				/*
+				 * Any inserted entry will end up below the
+				 * current entry
+				 */
+				if (__richacl_propagate_everyone(x, ace,
+								 group_allow))
+					return -1;
+			}
+		}
+	}
+	return 0;
+}
-- 
2.1.0

