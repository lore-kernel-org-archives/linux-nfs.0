Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:38638 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933615AbbHDLy4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 07:54:56 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: [RFC v6 13/40] richacl: Check if an acl is equivalent to a file mode
Date: Tue,  4 Aug 2015 13:53:11 +0200
Message-Id: <1438689218-6921-14-git-send-email-agruenba@redhat.com>
In-Reply-To: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ACLs are considered equivalent to file modes if they only consist of
owner@, group@, and everyone@ entries, the owner@ permissions do not
depend on whether the owner is a member in the owning group, and no
inheritance flags are set.  This test is used to avoid storing richacls
if the acl can be computed from the file permission bits.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 104 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |   1 +
 2 files changed, 105 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index e703f7d..3e9ef9e 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -378,3 +378,107 @@ richacl_chmod(struct richacl *acl, mode_t mode)
 	return clone;
 }
 EXPORT_SYMBOL_GPL(richacl_chmod);
+
+/**
+ * richacl_equiv_mode  -  compute the mode equivalent of @acl
+ *
+ * An acl is considered equivalent to a file mode if it only consists of
+ * owner@, group@, and everyone@ entries and the owner@ permissions do not
+ * depend on whether the owner is a member in the owning group.
+ */
+int
+richacl_equiv_mode(const struct richacl *acl, mode_t *mode_p)
+{
+	mode_t mode = *mode_p;
+
+	/*
+	 * The RICHACE_DELETE_CHILD flag is meaningless for non-directories, so
+	 * we ignore it.
+	 */
+	unsigned int x = S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD;
+	struct {
+		unsigned int allowed;
+		unsigned int defined;  /* allowed or denied */
+	} owner = {
+		.defined = RICHACE_POSIX_ALWAYS_ALLOWED |
+			   RICHACE_POSIX_OWNER_ALLOWED  | x,
+	}, group = {
+		.defined = RICHACE_POSIX_ALWAYS_ALLOWED | x,
+	}, everyone = {
+		.defined = RICHACE_POSIX_ALWAYS_ALLOWED | x,
+	};
+	const struct richace *ace;
+
+	if (acl->a_flags & ~(RICHACL_WRITE_THROUGH | RICHACL_MASKED))
+		return -1;
+
+	richacl_for_each_entry(ace, acl) {
+		if (ace->e_flags & ~RICHACE_SPECIAL_WHO)
+			return -1;
+
+		if (richace_is_owner(ace) || richace_is_everyone(ace)) {
+			x = ace->e_mask & ~owner.defined;
+			if (richace_is_allow(ace)) {
+				unsigned int group_denied =
+					group.defined & ~group.allowed;
+
+				if (x & group_denied)
+					return -1;
+				owner.allowed |= x;
+			} else /* if (richace_is_deny(ace)) */ {
+				if (x & group.allowed)
+					return -1;
+			}
+			owner.defined |= x;
+
+			if (richace_is_everyone(ace)) {
+				x = ace->e_mask;
+				if (richace_is_allow(ace)) {
+					group.allowed |=
+						x & ~group.defined;
+					everyone.allowed |=
+						x & ~everyone.defined;
+				}
+				group.defined |= x;
+				everyone.defined |= x;
+			}
+		} else if (richace_is_group(ace)) {
+			x = ace->e_mask & ~group.defined;
+			if (richace_is_allow(ace))
+				group.allowed |= x;
+			group.defined |= x;
+		} else
+			return -1;
+	}
+
+	if (group.allowed & ~owner.defined)
+		return -1;
+
+	if (acl->a_flags & RICHACL_MASKED) {
+		if (acl->a_flags & RICHACL_WRITE_THROUGH) {
+			owner.allowed = acl->a_owner_mask;
+			everyone.allowed = acl->a_other_mask;
+		} else {
+			owner.allowed &= acl->a_owner_mask;
+			everyone.allowed &= acl->a_other_mask;
+		}
+		group.allowed &= acl->a_group_mask;
+	}
+
+	mode = (mode & ~S_IRWXUGO) |
+	       (richacl_mask_to_mode(owner.allowed) << 6) |
+	       (richacl_mask_to_mode(group.allowed) << 3) |
+		richacl_mask_to_mode(everyone.allowed);
+
+	/* Mask flags we can ignore */
+	x = S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD;
+
+	if (((richacl_mode_to_mask(mode >> 6) ^ owner.allowed)    & ~x) ||
+	    ((richacl_mode_to_mask(mode >> 3) ^ group.allowed)    & ~x) ||
+	    ((richacl_mode_to_mask(mode)      ^ everyone.allowed) & ~x))
+		return -1;
+
+	*mode_p = mode;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(richacl_equiv_mode);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index a7b413f..6a2ba34 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -310,6 +310,7 @@ extern unsigned int richacl_mode_to_mask(mode_t);
 extern unsigned int richacl_want_to_mask(unsigned int);
 extern void richacl_compute_max_masks(struct richacl *, kuid_t);
 extern struct richacl *richacl_chmod(struct richacl *, mode_t);
+extern int richacl_equiv_mode(const struct richacl *, mode_t *);
 
 /* richacl_inode.c */
 extern int richacl_permission(struct inode *, const struct richacl *, int);
-- 
2.5.0

