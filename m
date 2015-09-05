Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59498 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752096AbbIEK2k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Sep 2015 06:28:40 -0400
From: Andreas Gruenbacher <agruenba@redhat.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Subject: [RFC v7 33/41] richacl: Add support for unmapped identifiers
Date: Sat,  5 Sep 2015 12:27:28 +0200
Message-Id: <1441448856-13478-34-git-send-email-agruenba@redhat.com>
In-Reply-To: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some remote file systems like nfs may return user or group identifiers
that cannot be mapped to local uids / gids.  Allow to represent such
unmapped identifiers in richacls.  (We still cannot represent unmapped
owners and owning groups, however.)

In the in-memory representation, the richacl is followed by a list of
NUL-terminated strings, with no padding.  Entries with an unmapped
identifier have the RICHACE_UNMAPPED_WHO flag set, and ace->e_id.offs
specifies the offset into this list.  Multiple entries can refer to the
same offset.

The xattr representation is similar, but ace->e_id is ignored, and the
list of unmapped identifier strings contains a string for each acl entry
whose RICHACE_UNMAPPED_WHO flag is set.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 139 ++++++++++++++++++++++++++++++++++++++++++++----
 fs/richacl_compat.c     |  18 +++----
 fs/richacl_inode.c      |   4 +-
 fs/richacl_xattr.c      |  69 ++++++++++++++++++++----
 include/linux/richacl.h |  33 ++++++++++--
 5 files changed, 227 insertions(+), 36 deletions(-)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index a85b7a3..281e396 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -23,22 +23,25 @@
 MODULE_LICENSE("GPL");
 
 /**
- * richacl_alloc  -  allocate a richacl
+ * __richacl_alloc  -  allocate a richacl
  * @count:	number of entries
+ * @unmapped_size:	size to reserve for unmapped identifiers
  */
 struct richacl *
-richacl_alloc(int count, gfp_t gfp)
+__richacl_alloc(unsigned int count, size_t unmapped_size, gfp_t gfp)
 {
-	size_t size = sizeof(struct richacl) + count * sizeof(struct richace);
+	size_t size = sizeof(struct richacl) + count * sizeof(struct richace) +
+		      unmapped_size;
 	struct richacl *acl = kzalloc(size, gfp);
 
 	if (acl) {
 		atomic_set(&acl->a_base.ba_refcount, 1);
 		acl->a_count = count;
+		acl->a_unmapped_size = unmapped_size;
 	}
 	return acl;
 }
-EXPORT_SYMBOL_GPL(richacl_alloc);
+EXPORT_SYMBOL_GPL(__richacl_alloc);
 
 /**
  * richacl_clone  -  create a copy of a richacl
@@ -47,7 +50,8 @@ struct richacl *
 richacl_clone(const struct richacl *acl, gfp_t gfp)
 {
 	int count = acl->a_count;
-	size_t size = sizeof(struct richacl) + count * sizeof(struct richace);
+	size_t size = sizeof(struct richacl) + count * sizeof(struct richace) +
+		      acl->a_unmapped_size;
 	struct richacl *dup = kmalloc(size, gfp);
 
 	if (dup) {
@@ -59,6 +63,9 @@ richacl_clone(const struct richacl *acl, gfp_t gfp)
 
 /**
  * richace_copy  -  copy an acl entry
+ *
+ * If @from has an unmapped who value (from->e_flags & RICHACE_UNMAPPED_WHO),
+ * it can only be copied within the same acl!
  */
 void
 richace_copy(struct richace *to, const struct richace *from)
@@ -66,6 +73,82 @@ richace_copy(struct richace *to, const struct richace *from)
 	memcpy(to, from, sizeof(struct richace));
 }
 
+/**
+ * richacl_add_unmapped_identifier
+ * @pacl:	Pointer to an acl
+ * @pace:	acl entry within @acl
+ * @who:	unmapped identifier
+ * @len:	length of @who
+ * @gfp:	memory allocation flags
+ *
+ * Add an unmapped identifier to an acl, possibly reallocating the acl.
+ */
+int richacl_add_unmapped_identifier(struct richacl **pacl,
+				    struct richace **pace,
+				    const char *who,
+				    unsigned int len, gfp_t gfp)
+{
+	struct richacl *acl = *pacl;
+	size_t size = sizeof(struct richacl) +
+		      acl->a_count * sizeof(struct richace) +
+		      acl->a_unmapped_size + len + 1;
+	unsigned int index = *pace - acl->a_entries;
+
+	acl = krealloc(*pacl, size, gfp);
+	if (acl) {
+		char *unmapped = (char *)(acl->a_entries + acl->a_count);
+		struct richace *ace = acl->a_entries + index;
+
+		ace->e_flags |= RICHACE_UNMAPPED_WHO;
+		ace->e_flags &= ~RICHACE_SPECIAL_WHO;
+		ace->e_id.offs = acl->a_unmapped_size;
+		memcpy(unmapped + ace->e_id.offs, who, len);
+		unmapped[ace->e_id.offs + len] = 0;
+		acl->a_unmapped_size += len + 1;
+		*pace = ace;
+		*pacl = acl;
+		return 0;
+	}
+	return -1;
+}
+EXPORT_SYMBOL_GPL(richacl_add_unmapped_identifier);
+
+/**
+ * richace_unmapped_identifier  -  get unmapped identifier
+ * @acl:	acl containing @ace
+ * @ace:	acl entry
+ *
+ * Get the unmapped identifier of @ace as a NUL-terminated string, or NULL if
+ * @ace doesn't have an unmapped identifier.
+ */
+const char *richace_unmapped_identifier(const struct richace *ace,
+					const struct richacl *acl)
+{
+	const char *unmapped = (char *)(acl->a_entries + acl->a_count);
+
+	if (!(ace->e_flags & RICHACE_UNMAPPED_WHO))
+		return NULL;
+	return unmapped + ace->e_id.offs;
+}
+EXPORT_SYMBOL(richace_unmapped_identifier);
+
+/**
+ * richacl_has_unmapped_identifiers
+ *
+ * Check if an acl has unmapped identifiers.
+ */
+bool richacl_has_unmapped_identifiers(struct richacl *acl)
+{
+	struct richace *ace;
+
+	richacl_for_each_entry(ace, acl) {
+		if (ace->e_flags & RICHACE_UNMAPPED_WHO)
+			return true;
+	}
+	return false;
+}
+EXPORT_SYMBOL_GPL(richacl_has_unmapped_identifiers);
+
 /*
  * richacl_mask_to_mode  -  compute the file permission bits from mask
  * @mask:	%RICHACE_* permission mask
@@ -213,7 +296,7 @@ static unsigned int richacl_allowed_to_who(struct richacl *acl,
 	richacl_for_each_entry_reverse(ace, acl) {
 		if (richace_is_inherit_only(ace))
 			continue;
-		if (richace_is_same_identifier(ace, who) ||
+		if (richace_is_same_identifier(acl, ace, who) ||
 		    richace_is_everyone(ace)) {
 			if (richace_is_allow(ace))
 				allowed |= ace->e_mask;
@@ -502,46 +585,73 @@ richacl_inherit(const struct richacl *dir_acl, int isdir)
 	const struct richace *dir_ace;
 	struct richacl *acl = NULL;
 	struct richace *ace;
-	int count = 0;
+	unsigned int count = 0, unmapped_size = 0, offset = 0;
+	const char *dir_unmapped;
+	char *unmapped;
 
 	if (isdir) {
 		richacl_for_each_entry(dir_ace, dir_acl) {
 			if (!richace_is_inheritable(dir_ace))
 				continue;
+
 			count++;
+			dir_unmapped =
+				richace_unmapped_identifier(dir_ace, dir_acl);
+			if (dir_unmapped)
+				unmapped_size += strlen(dir_unmapped) + 1;
 		}
 		if (!count)
 			return NULL;
-		acl = richacl_alloc(count, GFP_KERNEL);
+		acl = __richacl_alloc(count, unmapped_size, GFP_KERNEL);
 		if (!acl)
 			return ERR_PTR(-ENOMEM);
 		ace = acl->a_entries;
+		unmapped = (char *)(acl->a_entries + acl->a_count);
 		richacl_for_each_entry(dir_ace, dir_acl) {
 			if (!richace_is_inheritable(dir_ace))
 				continue;
+
 			richace_copy(ace, dir_ace);
 			if (dir_ace->e_flags & RICHACE_NO_PROPAGATE_INHERIT_ACE)
 				ace->e_flags &= ~RICHACE_INHERITANCE_FLAGS;
 			else if ((dir_ace->e_flags & RICHACE_FILE_INHERIT_ACE) &&
 				 !(dir_ace->e_flags & RICHACE_DIRECTORY_INHERIT_ACE))
 				ace->e_flags |= RICHACE_INHERIT_ONLY_ACE;
+
+			dir_unmapped =
+				richace_unmapped_identifier(dir_ace, dir_acl);
+			if (dir_unmapped) {
+				size_t sz = strlen(dir_unmapped) + 1;
+
+				ace->e_id.offs = offset;
+				memcpy(unmapped, dir_unmapped, sz);
+				unmapped += sz;
+				offset += sz;
+			}
 			ace++;
 		}
 	} else {
 		richacl_for_each_entry(dir_ace, dir_acl) {
 			if (!(dir_ace->e_flags & RICHACE_FILE_INHERIT_ACE))
 				continue;
+
 			count++;
+			dir_unmapped =
+				richace_unmapped_identifier(dir_ace, dir_acl);
+			if (dir_unmapped)
+				unmapped_size += strlen(dir_unmapped) + 1;
 		}
 		if (!count)
 			return NULL;
-		acl = richacl_alloc(count, GFP_KERNEL);
+		acl = __richacl_alloc(count, unmapped_size, GFP_KERNEL);
 		if (!acl)
 			return ERR_PTR(-ENOMEM);
 		ace = acl->a_entries;
+		unmapped = (char *)(acl->a_entries + acl->a_count);
 		richacl_for_each_entry(dir_ace, dir_acl) {
 			if (!(dir_ace->e_flags & RICHACE_FILE_INHERIT_ACE))
 				continue;
+
 			richace_copy(ace, dir_ace);
 			ace->e_flags &= ~RICHACE_INHERITANCE_FLAGS;
 			/*
@@ -549,6 +659,17 @@ richacl_inherit(const struct richacl *dir_acl, int isdir)
 			 * non-directories, so clear it.
 			 */
 			ace->e_mask &= ~RICHACE_DELETE_CHILD;
+
+			dir_unmapped =
+				richace_unmapped_identifier(dir_ace, dir_acl);
+			if (dir_unmapped) {
+				size_t sz = strlen(dir_unmapped) + 1;
+
+				ace->e_id.offs = offset;
+				memcpy(unmapped, dir_unmapped, sz);
+				unmapped += sz;
+				offset += sz;
+			}
 			ace++;
 		}
 	}
diff --git a/fs/richacl_compat.c b/fs/richacl_compat.c
index 632409f..8aeafa8 100644
--- a/fs/richacl_compat.c
+++ b/fs/richacl_compat.c
@@ -71,11 +71,13 @@ richacl_insert_entry(struct richacl_alloc *alloc, struct richace **ace)
 {
 	struct richacl *acl = alloc->acl;
 	unsigned int index = *ace - acl->a_entries;
-	size_t tail_size = (acl->a_count - index) * sizeof(struct richace);
+	size_t tail_size = (acl->a_count - index) * sizeof(struct richace) +
+			   acl->a_unmapped_size;
 
 	if (alloc->count == acl->a_count) {
 		size_t new_size = sizeof(struct richacl) +
-			(acl->a_count + 1) * sizeof(struct richace);
+			(acl->a_count + 1) * sizeof(struct richace) +
+			acl->a_unmapped_size;
 
 		acl = krealloc(acl, new_size, GFP_KERNEL);
 		if (!acl)
@@ -103,10 +105,6 @@ struct richace *richacl_append_entry(struct richacl_alloc *alloc)
 	struct richacl *acl = alloc->acl;
 	struct richace *ace = acl->a_entries + acl->a_count;
 
-	if (alloc->count > alloc->acl->a_count) {
-		acl->a_count++;
-		return ace;
-	}
 	return richacl_insert_entry(alloc, &ace) ? NULL : ace;
 }
 EXPORT_SYMBOL_GPL(richacl_append_entry);
@@ -261,12 +259,12 @@ __richacl_propagate_everyone(struct richacl_alloc *alloc, struct richace *who,
 		if (richace_is_inherit_only(ace))
 			continue;
 		if (richace_is_allow(ace)) {
-			if (richace_is_same_identifier(ace, who)) {
+			if (richace_is_same_identifier(acl, ace, who)) {
 				allow &= ~ace->e_mask;
 				allow_last = ace;
 			}
 		} else if (richace_is_deny(ace)) {
-			if (richace_is_same_identifier(ace, who))
+			if (richace_is_same_identifier(acl, ace, who))
 				allow &= ~ace->e_mask;
 			else if (allow & ace->e_mask)
 				allow_last = NULL;
@@ -608,7 +606,7 @@ __richacl_isolate_who(struct richacl_alloc *alloc, struct richace *who,
 	richacl_for_each_entry(ace, acl) {
 		if (richace_is_inherit_only(ace))
 			continue;
-		if (richace_is_same_identifier(ace, who) &&
+		if (richace_is_same_identifier(acl, ace, who) &&
 		    richace_is_deny(ace))
 			deny &= ~ace->e_mask;
 	}
@@ -625,7 +623,7 @@ __richacl_isolate_who(struct richacl_alloc *alloc, struct richace *who,
 		if (richace_is_inherit_only(ace))
 			continue;
 		if (richace_is_deny(ace)) {
-			if (richace_is_same_identifier(ace, who))
+			if (richace_is_same_identifier(acl, ace, who))
 				break;
 		} else if (richace_is_allow(ace) &&
 			   (ace->e_mask & deny)) {
diff --git a/fs/richacl_inode.c b/fs/richacl_inode.c
index df175c1..ff8b192 100644
--- a/fs/richacl_inode.c
+++ b/fs/richacl_inode.c
@@ -159,8 +159,10 @@ richacl_permission(struct inode *inode, const struct richacl *acl,
 		} else if (richace_is_unix_group(ace)) {
 			if (!in_group_p(ace->e_id.gid))
 				continue;
-		} else
+		} else if (richace_is_everyone(ace))
 			goto entry_matches_everyone;
+		else
+			continue;
 
 		/*
 		 * Apply the group file mask to entries other than owner@ and
diff --git a/fs/richacl_xattr.c b/fs/richacl_xattr.c
index cd9979d..e9622f6 100644
--- a/fs/richacl_xattr.c
+++ b/fs/richacl_xattr.c
@@ -33,7 +33,8 @@ richacl_from_xattr(struct user_namespace *user_ns,
 	const struct richace_xattr *xattr_ace = (void *)(xattr_acl + 1);
 	struct richacl *acl;
 	struct richace *ace;
-	int count;
+	unsigned int count, offset;
+	char *unmapped;
 
 	if (size < sizeof(*xattr_acl) ||
 	    xattr_acl->a_version != RICHACL_XATTR_VERSION ||
@@ -43,10 +44,11 @@ richacl_from_xattr(struct user_namespace *user_ns,
 	count = le16_to_cpu(xattr_acl->a_count);
 	if (count > RICHACL_XATTR_MAX_COUNT)
 		return ERR_PTR(-EINVAL);
-	if (size != count * sizeof(*xattr_ace))
+	if (size < count * sizeof(*xattr_ace))
 		return ERR_PTR(-EINVAL);
+	size -= count * sizeof(*xattr_ace);
 
-	acl = richacl_alloc(count, GFP_NOFS);
+	acl = __richacl_alloc(count, size, GFP_NOFS);
 	if (!acl)
 		return ERR_PTR(-ENOMEM);
 
@@ -61,6 +63,16 @@ richacl_from_xattr(struct user_namespace *user_ns,
 	if (acl->a_other_mask & ~RICHACE_VALID_MASK)
 		goto fail_einval;
 
+	unmapped = (char *)(acl->a_entries + count);
+	if (size) {
+		char *xattr_unmapped = (char *)(xattr_ace + count);
+
+		if (xattr_unmapped[size - 1] != 0)
+			goto fail_einval;
+		memcpy(unmapped, xattr_unmapped, size);
+	}
+	offset = 0;
+
 	richacl_for_each_entry(ace, acl) {
 		ace->e_type  = le16_to_cpu(xattr_ace->e_type);
 		ace->e_flags = le16_to_cpu(xattr_ace->e_flags);
@@ -72,6 +84,15 @@ richacl_from_xattr(struct user_namespace *user_ns,
 			ace->e_id.special = le32_to_cpu(xattr_ace->e_id);
 			if (ace->e_id.special > RICHACE_EVERYONE_SPECIAL_ID)
 				goto fail_einval;
+		} else if (ace->e_flags & RICHACE_UNMAPPED_WHO) {
+			size_t sz;
+
+			if (offset == size)
+				goto fail_einval;
+			ace->e_id.offs = offset;
+			sz = strlen(unmapped) + 1;
+			unmapped += sz;
+			offset += sz;
 		} else if (ace->e_flags & RICHACE_IDENTIFIER_GROUP) {
 			u32 id = le32_to_cpu(xattr_ace->e_id);
 
@@ -88,10 +109,12 @@ richacl_from_xattr(struct user_namespace *user_ns,
 		if (ace->e_type > RICHACE_ACCESS_DENIED_ACE_TYPE ||
 		    (ace->e_mask & ~RICHACE_VALID_MASK))
 			goto fail_einval;
-
 		xattr_ace++;
 	}
 
+	if (offset != size)
+		goto fail_einval;
+
 	return acl;
 
 fail_einval:
@@ -107,8 +130,15 @@ size_t
 richacl_xattr_size(const struct richacl *acl)
 {
 	size_t size = sizeof(struct richacl_xattr);
+	const struct richace *ace;
 
 	size += sizeof(struct richace_xattr) * acl->a_count;
+	richacl_for_each_entry(ace, acl) {
+		const char *unmapped = richace_unmapped_identifier(ace, acl);
+
+		if (unmapped)
+			size += strlen(unmapped) + 1;
+	}
 	return size;
 }
 EXPORT_SYMBOL_GPL(richacl_xattr_size);
@@ -127,6 +157,7 @@ richacl_to_xattr(struct user_namespace *user_ns,
 	struct richace_xattr *xattr_ace;
 	const struct richace *ace;
 	size_t real_size;
+	char *xattr_unmapped;
 
 	real_size = richacl_xattr_size(acl);
 	if (!buffer)
@@ -143,18 +174,33 @@ richacl_to_xattr(struct user_namespace *user_ns,
 	xattr_acl->a_other_mask = cpu_to_le32(acl->a_other_mask);
 
 	xattr_ace = (void *)(xattr_acl + 1);
+	xattr_unmapped = (char *)(xattr_ace + acl->a_count);
 	richacl_for_each_entry(ace, acl) {
+		const char *who;
+
 		xattr_ace->e_type = cpu_to_le16(ace->e_type);
 		xattr_ace->e_flags = cpu_to_le16(ace->e_flags);
 		xattr_ace->e_mask = cpu_to_le32(ace->e_mask);
 		if (ace->e_flags & RICHACE_SPECIAL_WHO)
 			xattr_ace->e_id = cpu_to_le32(ace->e_id.special);
-		else if (ace->e_flags & RICHACE_IDENTIFIER_GROUP)
-			xattr_ace->e_id =
-				cpu_to_le32(from_kgid(user_ns, ace->e_id.gid));
-		else
-			xattr_ace->e_id =
-				cpu_to_le32(from_kuid(user_ns, ace->e_id.uid));
+		else {
+			who = richace_unmapped_identifier(ace, acl);
+			if (who) {
+				size_t sz = strlen(who) + 1;
+
+				xattr_ace->e_id = 0;
+				memcpy(xattr_unmapped, who, sz);
+				xattr_unmapped += sz;
+			} else if (ace->e_flags & RICHACE_IDENTIFIER_GROUP) {
+				u32 id = from_kgid(user_ns, ace->e_id.gid);
+
+				xattr_ace->e_id = cpu_to_le32(id);
+			} else {
+				u32 id = from_kuid(user_ns, ace->e_id.uid);
+
+				xattr_ace->e_id = cpu_to_le32(id);
+			}
+		}
 		xattr_ace++;
 	}
 	return real_size;
@@ -184,7 +230,8 @@ static void richacl_fix_xattr_userns(
 		return;
 	count = size / sizeof(*xattr_ace);
 	for (; count; count--, xattr_ace++) {
-		if (xattr_ace->e_flags & cpu_to_le16(RICHACE_SPECIAL_WHO))
+		if (xattr_ace->e_flags & cpu_to_le16(RICHACE_SPECIAL_WHO |
+						     RICHACE_UNMAPPED_WHO))
 			continue;
 		if (xattr_ace->e_flags &
 		    cpu_to_le16(RICHACE_IDENTIFIER_GROUP)) {
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index f48c04e..1822666 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -29,6 +29,7 @@ struct richace {
 		kuid_t		uid;
 		kgid_t		gid;
 		unsigned int	special;
+		unsigned short	offs;  /* unmapped offset */
 	} e_id;
 };
 
@@ -39,6 +40,7 @@ struct richacl {
 	unsigned int	a_other_mask;
 	unsigned short	a_count;
 	unsigned short	a_flags;
+	unsigned short	a_unmapped_size;
 	struct richace	a_entries[0];
 };
 
@@ -77,6 +79,7 @@ struct richacl {
 #define RICHACE_INHERIT_ONLY_ACE		0x0008
 #define RICHACE_IDENTIFIER_GROUP		0x0040
 #define RICHACE_INHERITED_ACE			0x0080
+#define RICHACE_UNMAPPED_WHO			0x2000
 #define RICHACE_SPECIAL_WHO			0x4000
 
 #define RICHACE_VALID_FLAGS (					\
@@ -86,6 +89,7 @@ struct richacl {
 	RICHACE_INHERIT_ONLY_ACE |				\
 	RICHACE_IDENTIFIER_GROUP |				\
 	RICHACE_INHERITED_ACE |					\
+	RICHACE_UNMAPPED_WHO |					\
 	RICHACE_SPECIAL_WHO)
 
 #define RICHACE_INHERITANCE_FLAGS (				\
@@ -310,14 +314,28 @@ richace_is_deny(const struct richace *ace)
  * richace_is_same_identifier  -  are both identifiers the same?
  */
 static inline bool
-richace_is_same_identifier(const struct richace *a, const struct richace *b)
+richace_is_same_identifier(const struct richacl *acl,
+			   const struct richace *ace1,
+			   const struct richace *ace2)
 {
-	return !((a->e_flags ^ b->e_flags) &
-		 (RICHACE_SPECIAL_WHO | RICHACE_IDENTIFIER_GROUP)) &&
-	       !memcmp(&a->e_id, &b->e_id, sizeof(a->e_id));
+	const char *unmapped = (char *)(acl->a_entries + acl->a_count);
+
+	return !((ace1->e_flags ^ ace2->e_flags) &
+		 (RICHACE_SPECIAL_WHO |
+		  RICHACE_IDENTIFIER_GROUP |
+		  RICHACE_UNMAPPED_WHO)) &&
+	       ((ace1->e_flags & RICHACE_UNMAPPED_WHO) ?
+		!strcmp(unmapped + ace1->e_id.offs,
+			unmapped + ace2->e_id.offs) :
+		!memcmp(&ace1->e_id, &ace2->e_id, sizeof(ace1->e_id)));
+}
+
+extern struct richacl *__richacl_alloc(unsigned int, size_t, gfp_t);
+static inline struct richacl *richacl_alloc(unsigned int count, gfp_t gfp)
+{
+	return __richacl_alloc(count, 0, gfp);
 }
 
-extern struct richacl *richacl_alloc(int, gfp_t);
 extern struct richacl *richacl_clone(const struct richacl *, gfp_t);
 extern void richace_copy(struct richace *, const struct richace *);
 extern int richacl_masks_to_mode(const struct richacl *);
@@ -327,6 +345,11 @@ extern void richacl_compute_max_masks(struct richacl *);
 extern struct richacl *richacl_chmod(struct richacl *, mode_t);
 extern int richacl_equiv_mode(const struct richacl *, mode_t *);
 extern struct richacl *richacl_inherit(const struct richacl *, int);
+extern int richacl_add_unmapped_identifier(struct richacl **, struct richace **,
+					   const char *, unsigned int, gfp_t);
+extern const char *richace_unmapped_identifier(const struct richace *,
+					       const struct richacl *);
+extern bool richacl_has_unmapped_identifiers(struct richacl *);
 
 /* richacl_inode.c */
 extern int richacl_permission(struct inode *, const struct richacl *, int);
-- 
2.4.3

