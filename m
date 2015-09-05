Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57604 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752032AbbIEK20 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Sep 2015 06:28:26 -0400
From: Andreas Gruenbacher <agruenba@redhat.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: Andreas Gruenbacher <agruen@kernel.org>
Subject: [RFC v7 25/41] richacl: Isolate the owner and group classes
Date: Sat,  5 Sep 2015 12:27:20 +0200
Message-Id: <1441448856-13478-26-git-send-email-agruenba@redhat.com>
In-Reply-To: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When applying the file masks to an acl, we need to ensure that no
process gets more permissions than allowed by its file mask.

This may require inserting an owner@ deny ace to ensure this if the
owner mask contains fewer permissions than the group or other mask.  For
example, when applying mode 0466 to the following acl:

   everyone@:rw::allow

A deny ace needs to be inserted so that the owner won't get elevated
write access:

   owner@:w::deny
   everyone@:rw::allow

Likewise, we may need to insert group class deny aces if the group mask
contains fewer permissions than the other mask.  For example, when
applying mode 0646 to the following acl:

   owner@:rw::allow
   everyone@:rw::allow

A deny ace needs to be inserted so that the owning group won't get
elevated write access:

   owner@:rw::allow
   group@:w::deny
   everyone@:rw::allow

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
---
 fs/richacl_compat.c | 236 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 236 insertions(+)

diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
index 30bdc95..412844c 100644
--- a/fs/richacl_compat.c
+++ b/fs/richacl_compat.c
@@ -494,3 +494,239 @@ richacl_set_other_permissions(struct richacl_alloc *alloc)
 		richace_change_mask(alloc, &ace, other_mask);
 	return 0;
 }
+
+/**
+ * richacl_max_allowed  -  maximum permissions that anybody is allowed
+ */
+static unsigned int
+richacl_max_allowed(struct richacl *acl)
+{
+	struct richace *ace;
+	unsigned int allowed = 0;
+
+	richacl_for_each_entry_reverse(ace, acl) {
+		if (richace_is_inherit_only(ace))
+			continue;
+		if (richace_is_allow(ace))
+			allowed |= ace->e_mask;
+		else if (richace_is_deny(ace)) {
+			if (richace_is_everyone(ace))
+				allowed &= ~ace->e_mask;
+		}
+	}
+	return allowed;
+}
+
+/**
+ * richacl_isolate_owner_class  -  limit the owner class to the owner file mask
+ * @alloc:	acl and number of allocated entries
+ *
+ * POSIX requires that after a chmod, the owner class is granted no more
+ * permissions than the owner file permission bits.  For richacls, this
+ * means that the owner class must not be granted any permissions that the
+ * owner mask does not include.
+ *
+ * When we apply file masks to an acl which grant more permissions to the group
+ * or other class than to the owner class, we may end up in a situation where
+ * the owner is granted additional permissions from other aces.  For example,
+ * given this acl:
+ *
+ *    everyone:rwx::allow
+ *
+ * when file masks corresponding to mode 0466 are applied, after
+ * richacl_propagate_everyone() and __richacl_apply_masks(), we end up with:
+ *
+ *    owner@:r::allow
+ *    everyone@:rw::allow
+ *
+ * This acl still grants the owner rw access through the everyone@ allow ace.
+ * To fix this, we must deny the owner w access:
+ *
+ *    owner@:w::deny
+ *    owner@:r::allow
+ *    everyone@:rw::allow
+ */
+static int
+richacl_isolate_owner_class(struct richacl_alloc *alloc)
+{
+	struct richace *ace;
+	unsigned int allowed = 0;
+
+	allowed = richacl_max_allowed(alloc->acl);
+	if (allowed & ~alloc->acl->a_owner_mask) {
+		/*
+		 * Figure out if we can update an existig OWNER@ DENY entry.
+		 */
+		richacl_for_each_entry(ace, alloc->acl) {
+			if (richace_is_inherit_only(ace))
+				continue;
+			if (richace_is_deny(ace)) {
+				if (richace_is_owner(ace))
+					break;
+			} else if (richace_is_allow(ace)) {
+				ace = alloc->acl->a_entries +
+				      alloc->acl->a_count;
+				break;
+			}
+		}
+		if (ace != alloc->acl->a_entries + alloc->acl->a_count) {
+			if (richace_change_mask(alloc, &ace, ace->e_mask |
+					(allowed & ~alloc->acl->a_owner_mask)))
+				return -1;
+		} else {
+			/* Insert an owner@ deny entry at the front. */
+			ace = alloc->acl->a_entries;
+			if (richacl_insert_entry(alloc, &ace))
+				return -1;
+			ace->e_type = RICHACE_ACCESS_DENIED_ACE_TYPE;
+			ace->e_flags = RICHACE_SPECIAL_WHO;
+			ace->e_mask = allowed & ~alloc->acl->a_owner_mask;
+			ace->e_id.special = RICHACE_OWNER_SPECIAL_ID;
+		}
+	}
+	return 0;
+}
+
+/**
+ * __richacl_isolate_who  -  isolate entry from everyone@ allow entry
+ * @alloc:	acl and number of allocated entries
+ * @who:	identifier to isolate
+ * @deny:	permissions this identifier should not be allowed
+ *
+ * See richacl_isolate_group_class().
+ */
+static int
+__richacl_isolate_who(struct richacl_alloc *alloc, struct richace *who,
+		      unsigned int deny)
+{
+	struct richacl *acl = alloc->acl;
+	struct richace *ace;
+	int n;
+	/*
+	 * Compute the permissions already denied to @who.
+	 */
+	richacl_for_each_entry(ace, acl) {
+		if (richace_is_inherit_only(ace))
+			continue;
+		if (richace_is_same_identifier(ace, who) &&
+		    richace_is_deny(ace))
+			deny &= ~ace->e_mask;
+	}
+	if (!deny)
+		return 0;
+
+	/*
+	 * Figure out if we can update an existig deny entry.  Start from the
+	 * entry before the trailing everyone@ allow entry. We will not hit
+	 * everyone@ entries in the loop.
+	 */
+	for (n = acl->a_count - 2; n != -1; n--) {
+		ace = acl->a_entries + n;
+		if (richace_is_inherit_only(ace))
+			continue;
+		if (richace_is_deny(ace)) {
+			if (richace_is_same_identifier(ace, who))
+				break;
+		} else if (richace_is_allow(ace) &&
+			   (ace->e_mask & deny)) {
+			n = -1;
+			break;
+		}
+	}
+	if (n != -1) {
+		if (richace_change_mask(alloc, &ace, ace->e_mask | deny))
+			return -1;
+	} else {
+		/*
+		 * Insert a new entry before the trailing everyone@ deny entry.
+		 */
+		struct richace who_copy;
+
+		richace_copy(&who_copy, who);
+		ace = acl->a_entries + acl->a_count - 1;
+		if (richacl_insert_entry(alloc, &ace))
+			return -1;
+		richace_copy(ace, &who_copy);
+		ace->e_type = RICHACE_ACCESS_DENIED_ACE_TYPE;
+		ace->e_flags &= ~RICHACE_INHERITANCE_FLAGS;
+		ace->e_mask = deny;
+	}
+	return 0;
+}
+
+/**
+ * richacl_isolate_group_class  -  limit the group class to the group file mask
+ * @alloc:	acl and number of allocated entries
+ *
+ * POSIX requires that after a chmod, the group class is granted no more
+ * permissions than the group file permission bits.  For richacls, this
+ * means that the group class must not be granted any permissions that the
+ * group mask does not include.
+ *
+ * When we apply file masks to an acl which grant more permissions to the other
+ * class than to the group class, we may end up in a situation where processes
+ * in the group class are granted additional permission from other aces.  For
+ * example, given this acl:
+ *
+ *    joe:rwx::allow
+ *    everyone:rwx::allow
+ *
+ * when file masks corresponding to mode 0646 are applied, after
+ * richacl_propagate_everyone() and __richacl_apply_masks(), we end up with:
+ *
+ *    joe:r::allow
+ *    owner@:rw::allow
+ *    group@:r::allow
+ *    everyone@:rw::allow
+ *
+ * This acl still grants joe and group@ rw access through the everyone@ allow
+ * ace.  To fix this, we must deny w access to group class aces before the
+ * everyone@ allow ace at the end of the acl:
+ *
+ *    joe:r::allow
+ *    owner@:rw::allow
+ *    group@:r::allow
+ *    joe:w::deny
+ *    group@:w::deny
+ *    everyone@:rw::allow
+ */
+static int
+richacl_isolate_group_class(struct richacl_alloc *alloc)
+{
+	struct richace who = {
+		.e_flags = RICHACE_SPECIAL_WHO,
+		.e_id.special = RICHACE_GROUP_SPECIAL_ID,
+	};
+	struct richace *ace;
+	unsigned int deny;
+
+	if (!alloc->acl->a_count)
+		return 0;
+	ace = alloc->acl->a_entries + alloc->acl->a_count - 1;
+	if (richace_is_inherit_only(ace) || !richace_is_everyone(ace))
+		return 0;
+	deny = ace->e_mask & ~alloc->acl->a_group_mask;
+
+	if (deny) {
+		unsigned int n;
+
+		if (__richacl_isolate_who(alloc, &who, deny))
+			return -1;
+		/*
+		 * Start from the entry before the trailing everyone@ allow
+		 * entry.  We will not hit everyone@ entries in the loop.
+		 */
+		for (n = alloc->acl->a_count - 2; n != -1; n--) {
+			ace = alloc->acl->a_entries + n;
+
+			if (richace_is_inherit_only(ace) ||
+			    richace_is_owner(ace) ||
+			    richace_is_group(ace) ||
+			    richace_is_everyone(ace))
+				continue;
+			if (__richacl_isolate_who(alloc, ace, deny))
+				return -1;
+		}
+	}
+	return 0;
+}
-- 
2.4.3

