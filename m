Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:54507 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932831Ab3LTNZY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Dec 2013 08:25:24 -0500
Message-Id: <20131220132521.330228004@bombadil.infradead.org>
Date: Fri, 20 Dec 2013 05:16:37 -0800
From: Christoph Hellwig <hch@infradead.org>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, Mark Fasheh <mfasheh@suse.com>,
        Joel Becker <jlbec@evilplan.org>, reiserfs-devel@vger.kernel.org,
        xfs@oss.sgi.com, jfs-discussion@lists.sourceforge.net,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        Andreas Gruenbacher <andreas.gruenbacher@linbit.com>
Subject: [PATCH 02/21] fs: merge xattr_acl.c into posix_acl.c
References: <20131220131635.650823732@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/Makefile    |    2 +-
 fs/posix_acl.c |  180 +++++++++++++++++++++++++++++++++++++++++++++++++++++---
 fs/xattr_acl.c |  180 --------------------------------------------------------
 3 files changed, 174 insertions(+), 188 deletions(-)
 delete mode 100644 fs/xattr_acl.c

diff --git a/fs/Makefile b/fs/Makefile
index 4fe6df3..f2c1843 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -42,7 +42,7 @@ obj-$(CONFIG_BINFMT_SOM)	+= binfmt_som.o
 obj-$(CONFIG_BINFMT_FLAT)	+= binfmt_flat.o
 
 obj-$(CONFIG_FS_MBCACHE)	+= mbcache.o
-obj-$(CONFIG_FS_POSIX_ACL)	+= posix_acl.o xattr_acl.o
+obj-$(CONFIG_FS_POSIX_ACL)	+= posix_acl.o
 obj-$(CONFIG_NFS_COMMON)	+= nfs_common/
 obj-$(CONFIG_GENERIC_ACL)	+= generic_acl.o
 obj-$(CONFIG_COREDUMP)		+= coredump.o
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 8bd2135..359d70b 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -1,10 +1,8 @@
 /*
- * linux/fs/posix_acl.c
+ * Copyright (C) 2002,2003 by Andreas Gruenbacher <a.gruenbacher@computer.org>
  *
- *  Copyright (C) 2002 by Andreas Gruenbacher <a.gruenbacher@computer.org>
- *
- *  Fixes from William Schumacher incorporated on 15 March 2001.
- *     (Reported by Charles Bertsch, <CBertsch@microtest.com>).
+ * Fixes from William Schumacher incorporated on 15 March 2001.
+ *    (Reported by Charles Bertsch, <CBertsch@microtest.com>).
  */
 
 /*
@@ -18,9 +16,9 @@
 #include <linux/fs.h>
 #include <linux/sched.h>
 #include <linux/posix_acl.h>
+#include <linux/posix_acl_xattr.h>
 #include <linux/export.h>
-
-#include <linux/errno.h>
+#include <linux/user_namespace.h>
 
 EXPORT_SYMBOL(posix_acl_init);
 EXPORT_SYMBOL(posix_acl_alloc);
@@ -418,3 +416,171 @@ posix_acl_chmod(struct posix_acl **acl, gfp_t gfp, umode_t mode)
 	return err;
 }
 EXPORT_SYMBOL(posix_acl_chmod);
+
+/*
+ * Fix up the uids and gids in posix acl extended attributes in place.
+ */
+static void posix_acl_fix_xattr_userns(
+	struct user_namespace *to, struct user_namespace *from,
+	void *value, size_t size)
+{
+	posix_acl_xattr_header *header = (posix_acl_xattr_header *)value;
+	posix_acl_xattr_entry *entry = (posix_acl_xattr_entry *)(header+1), *end;
+	int count;
+	kuid_t uid;
+	kgid_t gid;
+
+	if (!value)
+		return;
+	if (size < sizeof(posix_acl_xattr_header))
+		return;
+	if (header->a_version != cpu_to_le32(POSIX_ACL_XATTR_VERSION))
+		return;
+
+	count = posix_acl_xattr_count(size);
+	if (count < 0)
+		return;
+	if (count == 0)
+		return;
+
+	for (end = entry + count; entry != end; entry++) {
+		switch(le16_to_cpu(entry->e_tag)) {
+		case ACL_USER:
+			uid = make_kuid(from, le32_to_cpu(entry->e_id));
+			entry->e_id = cpu_to_le32(from_kuid(to, uid));
+			break;
+		case ACL_GROUP:
+			gid = make_kgid(from, le32_to_cpu(entry->e_id));
+			entry->e_id = cpu_to_le32(from_kgid(to, gid));
+			break;
+		default:
+			break;
+		}
+	}
+}
+
+void posix_acl_fix_xattr_from_user(void *value, size_t size)
+{
+	struct user_namespace *user_ns = current_user_ns();
+	if (user_ns == &init_user_ns)
+		return;
+	posix_acl_fix_xattr_userns(&init_user_ns, user_ns, value, size);
+}
+
+void posix_acl_fix_xattr_to_user(void *value, size_t size)
+{
+	struct user_namespace *user_ns = current_user_ns();
+	if (user_ns == &init_user_ns)
+		return;
+	posix_acl_fix_xattr_userns(user_ns, &init_user_ns, value, size);
+}
+
+/*
+ * Convert from extended attribute to in-memory representation.
+ */
+struct posix_acl *
+posix_acl_from_xattr(struct user_namespace *user_ns,
+		     const void *value, size_t size)
+{
+	posix_acl_xattr_header *header = (posix_acl_xattr_header *)value;
+	posix_acl_xattr_entry *entry = (posix_acl_xattr_entry *)(header+1), *end;
+	int count;
+	struct posix_acl *acl;
+	struct posix_acl_entry *acl_e;
+
+	if (!value)
+		return NULL;
+	if (size < sizeof(posix_acl_xattr_header))
+		 return ERR_PTR(-EINVAL);
+	if (header->a_version != cpu_to_le32(POSIX_ACL_XATTR_VERSION))
+		return ERR_PTR(-EOPNOTSUPP);
+
+	count = posix_acl_xattr_count(size);
+	if (count < 0)
+		return ERR_PTR(-EINVAL);
+	if (count == 0)
+		return NULL;
+	
+	acl = posix_acl_alloc(count, GFP_NOFS);
+	if (!acl)
+		return ERR_PTR(-ENOMEM);
+	acl_e = acl->a_entries;
+	
+	for (end = entry + count; entry != end; acl_e++, entry++) {
+		acl_e->e_tag  = le16_to_cpu(entry->e_tag);
+		acl_e->e_perm = le16_to_cpu(entry->e_perm);
+
+		switch(acl_e->e_tag) {
+			case ACL_USER_OBJ:
+			case ACL_GROUP_OBJ:
+			case ACL_MASK:
+			case ACL_OTHER:
+				break;
+
+			case ACL_USER:
+				acl_e->e_uid =
+					make_kuid(user_ns,
+						  le32_to_cpu(entry->e_id));
+				if (!uid_valid(acl_e->e_uid))
+					goto fail;
+				break;
+			case ACL_GROUP:
+				acl_e->e_gid =
+					make_kgid(user_ns,
+						  le32_to_cpu(entry->e_id));
+				if (!gid_valid(acl_e->e_gid))
+					goto fail;
+				break;
+
+			default:
+				goto fail;
+		}
+	}
+	return acl;
+
+fail:
+	posix_acl_release(acl);
+	return ERR_PTR(-EINVAL);
+}
+EXPORT_SYMBOL (posix_acl_from_xattr);
+
+/*
+ * Convert from in-memory to extended attribute representation.
+ */
+int
+posix_acl_to_xattr(struct user_namespace *user_ns, const struct posix_acl *acl,
+		   void *buffer, size_t size)
+{
+	posix_acl_xattr_header *ext_acl = (posix_acl_xattr_header *)buffer;
+	posix_acl_xattr_entry *ext_entry = ext_acl->a_entries;
+	int real_size, n;
+
+	real_size = posix_acl_xattr_size(acl->a_count);
+	if (!buffer)
+		return real_size;
+	if (real_size > size)
+		return -ERANGE;
+	
+	ext_acl->a_version = cpu_to_le32(POSIX_ACL_XATTR_VERSION);
+
+	for (n=0; n < acl->a_count; n++, ext_entry++) {
+		const struct posix_acl_entry *acl_e = &acl->a_entries[n];
+		ext_entry->e_tag  = cpu_to_le16(acl_e->e_tag);
+		ext_entry->e_perm = cpu_to_le16(acl_e->e_perm);
+		switch(acl_e->e_tag) {
+		case ACL_USER:
+			ext_entry->e_id =
+				cpu_to_le32(from_kuid(user_ns, acl_e->e_uid));
+			break;
+		case ACL_GROUP:
+			ext_entry->e_id =
+				cpu_to_le32(from_kgid(user_ns, acl_e->e_gid));
+			break;
+		default:
+			ext_entry->e_id = cpu_to_le32(ACL_UNDEFINED_ID);
+			break;
+		}
+	}
+	return real_size;
+}
+EXPORT_SYMBOL (posix_acl_to_xattr);
diff --git a/fs/xattr_acl.c b/fs/xattr_acl.c
deleted file mode 100644
index 9fbea87..0000000
--- a/fs/xattr_acl.c
+++ /dev/null
@@ -1,180 +0,0 @@
-/*
- * linux/fs/xattr_acl.c
- *
- * Almost all from linux/fs/ext2/acl.c:
- * Copyright (C) 2001 by Andreas Gruenbacher, <a.gruenbacher@computer.org>
- */
-
-#include <linux/export.h>
-#include <linux/fs.h>
-#include <linux/posix_acl_xattr.h>
-#include <linux/gfp.h>
-#include <linux/user_namespace.h>
-
-/*
- * Fix up the uids and gids in posix acl extended attributes in place.
- */
-static void posix_acl_fix_xattr_userns(
-	struct user_namespace *to, struct user_namespace *from,
-	void *value, size_t size)
-{
-	posix_acl_xattr_header *header = (posix_acl_xattr_header *)value;
-	posix_acl_xattr_entry *entry = (posix_acl_xattr_entry *)(header+1), *end;
-	int count;
-	kuid_t uid;
-	kgid_t gid;
-
-	if (!value)
-		return;
-	if (size < sizeof(posix_acl_xattr_header))
-		return;
-	if (header->a_version != cpu_to_le32(POSIX_ACL_XATTR_VERSION))
-		return;
-
-	count = posix_acl_xattr_count(size);
-	if (count < 0)
-		return;
-	if (count == 0)
-		return;
-
-	for (end = entry + count; entry != end; entry++) {
-		switch(le16_to_cpu(entry->e_tag)) {
-		case ACL_USER:
-			uid = make_kuid(from, le32_to_cpu(entry->e_id));
-			entry->e_id = cpu_to_le32(from_kuid(to, uid));
-			break;
-		case ACL_GROUP:
-			gid = make_kgid(from, le32_to_cpu(entry->e_id));
-			entry->e_id = cpu_to_le32(from_kgid(to, gid));
-			break;
-		default:
-			break;
-		}
-	}
-}
-
-void posix_acl_fix_xattr_from_user(void *value, size_t size)
-{
-	struct user_namespace *user_ns = current_user_ns();
-	if (user_ns == &init_user_ns)
-		return;
-	posix_acl_fix_xattr_userns(&init_user_ns, user_ns, value, size);
-}
-
-void posix_acl_fix_xattr_to_user(void *value, size_t size)
-{
-	struct user_namespace *user_ns = current_user_ns();
-	if (user_ns == &init_user_ns)
-		return;
-	posix_acl_fix_xattr_userns(user_ns, &init_user_ns, value, size);
-}
-
-/*
- * Convert from extended attribute to in-memory representation.
- */
-struct posix_acl *
-posix_acl_from_xattr(struct user_namespace *user_ns,
-		     const void *value, size_t size)
-{
-	posix_acl_xattr_header *header = (posix_acl_xattr_header *)value;
-	posix_acl_xattr_entry *entry = (posix_acl_xattr_entry *)(header+1), *end;
-	int count;
-	struct posix_acl *acl;
-	struct posix_acl_entry *acl_e;
-
-	if (!value)
-		return NULL;
-	if (size < sizeof(posix_acl_xattr_header))
-		 return ERR_PTR(-EINVAL);
-	if (header->a_version != cpu_to_le32(POSIX_ACL_XATTR_VERSION))
-		return ERR_PTR(-EOPNOTSUPP);
-
-	count = posix_acl_xattr_count(size);
-	if (count < 0)
-		return ERR_PTR(-EINVAL);
-	if (count == 0)
-		return NULL;
-	
-	acl = posix_acl_alloc(count, GFP_NOFS);
-	if (!acl)
-		return ERR_PTR(-ENOMEM);
-	acl_e = acl->a_entries;
-	
-	for (end = entry + count; entry != end; acl_e++, entry++) {
-		acl_e->e_tag  = le16_to_cpu(entry->e_tag);
-		acl_e->e_perm = le16_to_cpu(entry->e_perm);
-
-		switch(acl_e->e_tag) {
-			case ACL_USER_OBJ:
-			case ACL_GROUP_OBJ:
-			case ACL_MASK:
-			case ACL_OTHER:
-				break;
-
-			case ACL_USER:
-				acl_e->e_uid =
-					make_kuid(user_ns,
-						  le32_to_cpu(entry->e_id));
-				if (!uid_valid(acl_e->e_uid))
-					goto fail;
-				break;
-			case ACL_GROUP:
-				acl_e->e_gid =
-					make_kgid(user_ns,
-						  le32_to_cpu(entry->e_id));
-				if (!gid_valid(acl_e->e_gid))
-					goto fail;
-				break;
-
-			default:
-				goto fail;
-		}
-	}
-	return acl;
-
-fail:
-	posix_acl_release(acl);
-	return ERR_PTR(-EINVAL);
-}
-EXPORT_SYMBOL (posix_acl_from_xattr);
-
-/*
- * Convert from in-memory to extended attribute representation.
- */
-int
-posix_acl_to_xattr(struct user_namespace *user_ns, const struct posix_acl *acl,
-		   void *buffer, size_t size)
-{
-	posix_acl_xattr_header *ext_acl = (posix_acl_xattr_header *)buffer;
-	posix_acl_xattr_entry *ext_entry = ext_acl->a_entries;
-	int real_size, n;
-
-	real_size = posix_acl_xattr_size(acl->a_count);
-	if (!buffer)
-		return real_size;
-	if (real_size > size)
-		return -ERANGE;
-	
-	ext_acl->a_version = cpu_to_le32(POSIX_ACL_XATTR_VERSION);
-
-	for (n=0; n < acl->a_count; n++, ext_entry++) {
-		const struct posix_acl_entry *acl_e = &acl->a_entries[n];
-		ext_entry->e_tag  = cpu_to_le16(acl_e->e_tag);
-		ext_entry->e_perm = cpu_to_le16(acl_e->e_perm);
-		switch(acl_e->e_tag) {
-		case ACL_USER:
-			ext_entry->e_id =
-				cpu_to_le32(from_kuid(user_ns, acl_e->e_uid));
-			break;
-		case ACL_GROUP:
-			ext_entry->e_id =
-				cpu_to_le32(from_kgid(user_ns, acl_e->e_gid));
-			break;
-		default:
-			ext_entry->e_id = cpu_to_le32(ACL_UNDEFINED_ID);
-			break;
-		}
-	}
-	return real_size;
-}
-EXPORT_SYMBOL (posix_acl_to_xattr);
-- 
1.7.10.4


