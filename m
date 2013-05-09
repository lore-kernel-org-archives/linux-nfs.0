Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oproxy9.bluehost.com ([69.89.24.6]:51951 "HELO
	oproxy9.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753685Ab3EIQi4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 May 2013 12:38:56 -0400
Message-ID: <1368117530.5695.36.camel@slavad-ubuntu-12.04>
Subject: [PATCH v4 4/5] hfsplus: introduce implementation of the ACLs support
From: Vyacheslav Dubeyko <slava@dubeyko.com>
To: Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        Hin-Tak Leung <htl10@users.sourceforge.net>,
        Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 09 May 2013 20:38:50 +0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Vyacheslav Dubeyko <slava@dubeyko.com>
Subject: [PATCH v4 4/5] hfsplus: introduce implementation of the ACLs support

This patch adds implementation of the ACLs support for hfsplus driver.

Signed-off-by: Vyacheslav Dubeyko <slava@dubeyko.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@redhat.com>
CC: Al Viro <viro@zeniv.linux.org.uk>
CC: Christoph Hellwig <hch@infradead.org>
CC: Hin-Tak Leung <htl10@users.sourceforge.net>
---
 fs/hfsplus/acl.c | 1903 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/hfsplus/acl.h |   96 +++
 2 files changed, 1999 insertions(+)
 create mode 100644 fs/hfsplus/acl.c
 create mode 100644 fs/hfsplus/acl.h

diff --git a/fs/hfsplus/acl.c b/fs/hfsplus/acl.c
new file mode 100644
index 0000000..ce6cfb2
--- /dev/null
+++ b/fs/hfsplus/acl.c
@@ -0,0 +1,1903 @@
+/*
+ * linux/fs/hfsplus/acl.c
+ *
+ * Vyacheslav Dubeyko <slava@dubeyko.com>
+ *
+ * Handler for Posix Access Control Lists (ACLs) support.
+ */
+
+#include <linux/uuid.h>
+
+#include "hfsplus_fs.h"
+#include "xattr.h"
+#include "acl.h"
+
+#define HFSPLUS_ACE_ID_MASK 0xFFFFFFFF
+
+static unsigned char hfsplus_group_fingerprint[] = {0xab, 0xcd, 0xef,
+						    0xab, 0xcd, 0xef,
+						    0xab, 0xcd, 0xef,
+						    0xab, 0xcd, 0xef};
+
+static unsigned char hfsplus_user_fingerprint[] = {0xff, 0xff,
+						   0xee, 0xee,
+						   0xdd, 0xdd,
+						   0xcc, 0xcc,
+						   0xbb, 0xbb,
+						   0xaa, 0xaa};
+
+#define HFSPLUS_FINGERPRINT_SIZE \
+	(HFSPLUS_GUID_SIZE - sizeof(HFSPLUS_ACE_ID_MASK))
+
+#define HFSPLUS_EVERYBODY_ID 0xc
+
+struct hfsplus_nfsv4_mapping_env {
+	struct inode *inode;
+	u8 ace_applicable[HFSPLUS_GUID_SIZE];
+	size_t allocated_acl_size;
+	size_t composed_acl_size;
+};
+
+static uint32_t hfsplus_get_naces(const void *nfsv4_acl)
+{
+	const struct hfsplus_acl_record *raw_acl_rec =
+		(const struct hfsplus_acl_record *)nfsv4_acl;
+	uint32_t entrycount;
+
+	hfs_dbg(ACL_MOD, "[%s]: acl %p\n", __func__, nfsv4_acl);
+
+	entrycount = be32_to_cpu(raw_acl_rec->acl_entrycount);
+
+	hfs_dbg(ACL_MOD, "[%s]: entry_count %u\n",
+			__func__, entrycount);
+
+	return entrycount;
+}
+
+static void *hfsplus_get_ace(const void *nfsv4_acl, uint32_t index)
+{
+	const struct hfsplus_acl_record *raw_acl_rec =
+		(const struct hfsplus_acl_record *)nfsv4_acl;
+	struct hfsplus_acl_entry *ace;
+
+	hfs_dbg(ACL_MOD, "[%s]: acl %p, index %u\n",
+			__func__, nfsv4_acl, index);
+
+	ace = (struct hfsplus_acl_entry *)(raw_acl_rec->acl_ace + index);
+
+	hfs_dbg(ACL_MOD, "[%s]: &ace[0] %p, &ace[index] %p\n",
+			__func__, raw_acl_rec->acl_ace, ace);
+	hfs_dbg_hexdump(ACL_MOD, "ace->ace_applicable: ",
+				ace->ace_applicable, HFSPLUS_GUID_SIZE);
+	hfs_dbg(ACL_MOD, "[%s]: ace->ace_flags %#x, ace->ace_rights %#x\n",
+			__func__,
+			be32_to_cpu(ace->ace_flags),
+			be32_to_cpu(ace->ace_rights));
+
+	return (void *)ace;
+}
+
+static uint32_t hfsplus_get_access_mask(const void *nfsv4_ace)
+{
+	const struct hfsplus_acl_entry *ace =
+		(const struct hfsplus_acl_entry *)nfsv4_ace;
+
+	hfs_dbg(ACL_MOD, "[%s]: ace %p\n", __func__, nfsv4_ace);
+
+	return be32_to_cpu(ace->ace_rights);
+}
+
+static bool hfsplus_ace_type_valid(const void *nfsv4_ace)
+{
+	const struct hfsplus_acl_entry *ace =
+		(const struct hfsplus_acl_entry *)nfsv4_ace;
+	u32 ace_flags = be32_to_cpu(ace->ace_flags);
+	u32 ace_type = ace_flags & HFSPLUS_ACE_KINDMASK;
+
+	hfs_dbg(ACL_MOD, "[%s]: ace %p, ace_flags %#x, ace_type %#x\n",
+			__func__, nfsv4_ace, ace_flags, ace_type);
+
+	return ace_type == HFSPLUS_ACE_PERMIT || ace_type == HFSPLUS_ACE_DENY;
+}
+
+static bool hfsplus_is_allowed_ace_type(const void *nfsv4_ace)
+{
+	const struct hfsplus_acl_entry *ace =
+		(const struct hfsplus_acl_entry *)nfsv4_ace;
+	u32 ace_flags = be32_to_cpu(ace->ace_flags);
+	u32 ace_type = ace_flags & HFSPLUS_ACE_KINDMASK;
+
+	hfs_dbg(ACL_MOD, "[%s]: ace %p, ace_flags %#x, ace_type %#x\n",
+			__func__, nfsv4_ace, ace_flags, ace_type);
+
+	return ace_type == HFSPLUS_ACE_PERMIT;
+}
+
+static unsigned char empty_guid[HFSPLUS_GUID_SIZE] = {0};
+
+static inline int empty_ace(const struct hfsplus_acl_entry *ace)
+{
+	return memcmp(empty_guid, ace->ace_applicable, HFSPLUS_GUID_SIZE) == 0;
+}
+
+#define IS_GROUP_FINGERPRINT(ace_applicable) \
+	(memcmp(ace_applicable, \
+		hfsplus_group_fingerprint, HFSPLUS_FINGERPRINT_SIZE) == 0)
+
+#define IS_USER_FINGERPRINT(ace_applicable) \
+	(memcmp(ace_applicable, \
+		hfsplus_user_fingerprint, HFSPLUS_FINGERPRINT_SIZE) == 0)
+
+static bool hfsplus_is_acl_user_obj(const struct nfsv4_acl_info *nfsv4_acl_info,
+						const void *nfsv4_ace)
+{
+	const struct hfsplus_acl_entry *ace =
+		(const struct hfsplus_acl_entry *)nfsv4_ace;
+
+	hfs_dbg(ACL_MOD, "[%s]: acl_info %p, ace %p\n",
+			__func__, nfsv4_acl_info, nfsv4_ace);
+
+	if (!IS_GROUP_FINGERPRINT(ace->ace_applicable) &&
+			!IS_USER_FINGERPRINT(ace->ace_applicable) &&
+			!empty_ace(ace)) {
+		hfs_dbg(ACL_MOD, "[%s]: found user obj\n", __func__);
+		return true;
+	} else
+		return false;
+}
+
+static bool hfsplus_is_acl_group_obj(
+				const struct nfsv4_acl_info *nfsv4_acl_info,
+				const void *nfsv4_ace)
+{
+	const struct hfsplus_acl_entry *ace =
+		(const struct hfsplus_acl_entry *)nfsv4_ace;
+	int size = HFSPLUS_FINGERPRINT_SIZE;
+	__be32 *raw_gid_ptr;
+	const struct hfsplus_nfsv4_mapping_env *mapping_env =
+	    (const struct hfsplus_nfsv4_mapping_env *)nfsv4_acl_info->private;
+	const struct inode *inode = mapping_env->inode;
+
+	hfs_dbg(ACL_MOD, "[%s]: acl_info %p, ace %p\n",
+			__func__, nfsv4_acl_info, nfsv4_ace);
+
+	if (IS_GROUP_FINGERPRINT(ace->ace_applicable)) {
+		raw_gid_ptr = (__be32 *)&ace->ace_applicable[size];
+		if (be32_to_cpu(*raw_gid_ptr) == i_gid_read(inode)) {
+			hfs_dbg(ACL_MOD, "[%s]: found group obj\n",
+								__func__);
+			return true;
+		}
+	}
+
+	return false;
+}
+
+static bool hfsplus_is_acl_other(const struct nfsv4_acl_info *nfsv4_acl_info,
+						const void *nfsv4_ace)
+{
+	const struct hfsplus_acl_entry *ace =
+		(const struct hfsplus_acl_entry *)nfsv4_ace;
+	int size = HFSPLUS_FINGERPRINT_SIZE;
+	__be32 *raw_id_ptr;
+
+	hfs_dbg(ACL_MOD, "[%s]: acl_info %p, ace %p\n",
+			__func__, nfsv4_acl_info, nfsv4_ace);
+
+	if (IS_GROUP_FINGERPRINT(ace->ace_applicable)) {
+		raw_id_ptr = (__be32 *)&ace->ace_applicable[size];
+		if (be32_to_cpu(*raw_id_ptr) == HFSPLUS_EVERYBODY_ID) {
+			hfs_dbg(ACL_MOD, "[%s]: found other\n", __func__);
+			return true;
+		}
+	}
+
+	return false;
+}
+
+static bool hfsplus_is_acl_user(const struct nfsv4_acl_info *nfsv4_acl_info,
+						const void *nfsv4_ace)
+{
+	const struct hfsplus_acl_entry *ace =
+		(const struct hfsplus_acl_entry *)nfsv4_ace;
+	int size = HFSPLUS_FINGERPRINT_SIZE;
+	__be32 *raw_id_ptr;
+
+	hfs_dbg(ACL_MOD, "[%s]: acl_info %p, ace %p\n",
+			__func__, nfsv4_acl_info, nfsv4_ace);
+
+	if (IS_USER_FINGERPRINT(ace->ace_applicable)) {
+		raw_id_ptr = (__be32 *)&ace->ace_applicable[size];
+		if (be32_to_cpu(*raw_id_ptr) != HFSPLUS_EVERYBODY_ID) {
+			hfs_dbg(ACL_MOD, "[%s]: found user %#x\n",
+					__func__, be32_to_cpu(*raw_id_ptr));
+			return true;
+		}
+	}
+
+	return false;
+}
+
+static bool hfsplus_is_acl_group(const struct nfsv4_acl_info *nfsv4_acl_info,
+						const void *nfsv4_ace)
+{
+	const struct hfsplus_acl_entry *ace =
+		(const struct hfsplus_acl_entry *)nfsv4_ace;
+	int size = HFSPLUS_FINGERPRINT_SIZE;
+	__be32 *raw_id_ptr;
+
+	hfs_dbg(ACL_MOD, "[%s]: acl_info %p, ace %p\n",
+			__func__, nfsv4_acl_info, nfsv4_ace);
+
+	if (IS_GROUP_FINGERPRINT(ace->ace_applicable)) {
+		raw_id_ptr = (__be32 *)&ace->ace_applicable[size];
+		if (be32_to_cpu(*raw_id_ptr) != HFSPLUS_EVERYBODY_ID) {
+			hfs_dbg(ACL_MOD, "[%s]: found group %#x\n",
+					__func__, be32_to_cpu(*raw_id_ptr));
+			return true;
+		}
+	}
+
+	return false;
+}
+
+static bool hfsplus_ace_has_unknown_flags(const void *nfsv4_ace)
+{
+	const struct hfsplus_acl_entry *ace =
+		(const struct hfsplus_acl_entry *)nfsv4_ace;
+	u32 ace_flags = be32_to_cpu(ace->ace_flags);
+	ace_flags &= ~HFSPLUS_ACE_KINDMASK;
+
+	hfs_dbg(ACL_MOD, "[%s]: ace %p, ace_flags %#x\n",
+			__func__, nfsv4_ace, ace_flags);
+
+	return ace_flags & ~HFSPLUS_ACE_INHERIT_CONTROL_FLAGS;
+}
+
+static bool hfsplus_ace_has_inheritance_flags(const void *nfsv4_ace)
+{
+	const struct hfsplus_acl_entry *ace =
+		(const struct hfsplus_acl_entry *)nfsv4_ace;
+	u32 ace_flags = be32_to_cpu(ace->ace_flags);
+	ace_flags &= ~HFSPLUS_ACE_KINDMASK;
+
+	hfs_dbg(ACL_MOD, "[%s]: ace %p, ace_flags %#x\n",
+			__func__, nfsv4_ace, ace_flags);
+
+	return ace_flags & HFSPLUS_ACE_INHERIT_CONTROL_FLAGS;
+}
+
+static bool hfsplus_ace_inherit_only_flag(const void *nfsv4_ace)
+{
+	const struct hfsplus_acl_entry *ace =
+		(const struct hfsplus_acl_entry *)nfsv4_ace;
+	u32 ace_flags = be32_to_cpu(ace->ace_flags);
+	ace_flags &= ~HFSPLUS_ACE_KINDMASK;
+
+	hfs_dbg(ACL_MOD, "[%s]: ace %p, ace_flags %#x\n",
+			__func__, nfsv4_ace, ace_flags);
+
+	return ace_flags & HFSPLUS_ACE_ONLY_INHERIT;
+}
+
+static int hfsplus_check_deny(u32 rights, int isowner)
+{
+	hfs_dbg(ACL_MOD, "[%s]: rights %#x, isowner %u\n",
+			__func__, rights, isowner);
+
+	if (rights & (HFSPLUS_VNODE_READ_ATTRIBUTES |
+			HFSPLUS_VNODE_READ_EXTATTRIBUTES |
+			HFSPLUS_VNODE_READ_SECURITY)) {
+		if (rights & HFSPLUS_VNODE_READ_ATTRIBUTES)
+			pr_warn("can't deny read attr\n");
+		if (rights & HFSPLUS_VNODE_READ_EXTATTRIBUTES)
+			pr_warn("can't deny read xattr\n");
+		if (rights & HFSPLUS_VNODE_READ_SECURITY)
+			pr_warn("can't deny read security\n");
+		return -EINVAL;
+	}
+	if (!isowner)
+		return 0;
+	if (rights & (HFSPLUS_VNODE_WRITE_ATTRIBUTES |
+			HFSPLUS_VNODE_WRITE_EXTATTRIBUTES |
+			HFSPLUS_VNODE_WRITE_SECURITY)) {
+		if (rights & HFSPLUS_VNODE_WRITE_ATTRIBUTES)
+			pr_warn("can't deny write attr\n");
+		if (rights & HFSPLUS_VNODE_WRITE_EXTATTRIBUTES)
+			pr_warn("can't deny write xattr\n");
+		if (rights & HFSPLUS_VNODE_WRITE_SECURITY)
+			pr_warn("can't deny write security\n");
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static void hfsplus_low_mode_from_nfs4(u32 perm, unsigned short *mode,
+						unsigned int flags)
+{
+	u32 write_mode = HFSPLUS_VNODE_WRITE_DATA;
+
+	hfs_dbg(ACL_MOD, "[%s]: perm %#x, mode ptr %p, flags %#x\n",
+			__func__, perm, mode, flags);
+
+	if (flags & NFS4_ACL_DIR)
+		write_mode |= HFSPLUS_VNODE_DELETE_CHILD;
+	*mode = 0;
+	if ((perm & HFSPLUS_VNODE_READ_DATA) == HFSPLUS_VNODE_READ_DATA)
+		*mode |= ACL_READ;
+	if ((perm & write_mode) == write_mode)
+		*mode |= ACL_WRITE;
+	if ((perm & HFSPLUS_VNODE_EXECUTE) == HFSPLUS_VNODE_EXECUTE)
+		*mode |= ACL_EXECUTE;
+
+	hfs_dbg(ACL_MOD, "[%s]: mode %#x\n", __func__, *mode);
+}
+
+static unsigned int hfsplus_calculate_eflag(unsigned int flags)
+{
+	hfs_dbg(ACL_MOD, "[%s]: flags %#x\n", __func__, flags);
+
+	return (flags & NFS4_ACL_TYPE_DEFAULT) ?
+			HFSPLUS_ACE_INHERIT_CONTROL_FLAGS : 0;
+}
+
+static int hfsplus_find_uid(struct posix_acl_state *state,
+					const void *nfsv4_ace)
+{
+	const struct hfsplus_acl_entry *ace =
+		(const struct hfsplus_acl_entry *)nfsv4_ace;
+	struct posix_ace_state_array *a = state->users;
+	int size = HFSPLUS_FINGERPRINT_SIZE;
+	__be32 *raw_id_ptr;
+	kuid_t uid;
+	int i;
+
+	hfs_dbg(ACL_MOD, "[%s]: state %p, ace %p\n",
+			__func__, state, nfsv4_ace);
+
+	if (IS_USER_FINGERPRINT(ace->ace_applicable)) {
+		raw_id_ptr = (__be32 *)&ace->ace_applicable[size];
+		uid = be32_to_cpu(*raw_id_ptr);
+		hfs_dbg(ACL_MOD, "[%s]: uid %#x\n", __func__, uid);
+	} else if (IS_GROUP_FINGERPRINT(ace->ace_applicable)) {
+		pr_warn("can't find group id\n");
+		return -1;
+	} else {
+		hfs_dbg(ACL_MOD, "[%s]: can't convert uid\n", __func__);
+		return -1;
+	}
+
+	for (i = 0; i < a->n; i++) {
+		if (uid_eq(a->aces[i].uid, uid)) {
+			hfs_dbg(ACL_MOD, "[%s]: index %d\n", __func__, i);
+			return i;
+		}
+	}
+	/* Not found: */
+	a->n++;
+	a->aces[i].uid = uid;
+	a->aces[i].perms.allow = state->everyone.allow;
+	a->aces[i].perms.deny  = state->everyone.deny;
+
+	hfs_dbg(ACL_MOD, "[%s]: index %d\n", __func__, i);
+	return i;
+}
+
+static int hfsplus_find_gid(struct posix_acl_state *state,
+					const void *nfsv4_ace)
+{
+	const struct hfsplus_acl_entry *ace =
+		(const struct hfsplus_acl_entry *)nfsv4_ace;
+	struct posix_ace_state_array *a = state->groups;
+	int size = HFSPLUS_FINGERPRINT_SIZE;
+	__be32 *raw_id_ptr;
+	kgid_t gid;
+	int i;
+
+	hfs_dbg(ACL_MOD, "[%s]: state %p, ace %p\n",
+			__func__, state, nfsv4_ace);
+
+	if (IS_GROUP_FINGERPRINT(ace->ace_applicable)) {
+		raw_id_ptr = (__be32 *)&ace->ace_applicable[size];
+		gid = be32_to_cpu(*raw_id_ptr);
+		hfs_dbg(ACL_MOD, "[%s]: gid %#x\n", __func__, gid);
+	} else if (IS_USER_FINGERPRINT(ace->ace_applicable)) {
+		pr_warn("can't find user id\n");
+		return -1;
+	} else {
+		hfs_dbg(ACL_MOD, "[%s]: can't convert uid\n", __func__);
+		return -1;
+	}
+
+	for (i = 0; i < a->n; i++) {
+		if (gid_eq(a->aces[i].gid, gid)) {
+			hfs_dbg(ACL_MOD, "[%s]: index %d\n", __func__, i);
+			return i;
+		}
+	}
+	/* Not found: */
+	a->n++;
+	a->aces[i].gid = gid;
+	a->aces[i].perms.allow = state->everyone.allow;
+	a->aces[i].perms.deny  = state->everyone.deny;
+
+	hfs_dbg(ACL_MOD, "[%s]: index %d\n", __func__, i);
+	return i;
+}
+
+static int hfsplus_set_posix_ace_uid(struct user_namespace *user_ns,
+					struct posix_acl_entry *pace,
+					kuid_t uid)
+{
+	hfs_dbg(ACL_MOD, "[%s]: pace %p, uid %#x\n",
+			__func__, pace, uid);
+
+	pace->e_uid = make_kuid(user_ns, uid);
+	if (!uid_valid(pace->e_uid)) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -EINVAL);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int hfsplus_set_posix_ace_gid(struct user_namespace *user_ns,
+					struct posix_acl_entry *pace,
+					kgid_t gid)
+{
+	hfs_dbg(ACL_MOD, "[%s]: pace %p, gid %#x\n",
+			__func__, pace, gid);
+
+	pace->e_gid = make_kgid(user_ns, gid);
+	if (!gid_valid(pace->e_gid)) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -EINVAL);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+#define HFSPLUS_ACE_SET_OWNER_USER_ID(ace_applicable) \
+	do { \
+		uuid_be generated_uuid; \
+		uuid_be_gen(&generated_uuid); \
+		memcpy(ace_applicable, \
+			generated_uuid.b, sizeof(generated_uuid)); \
+	} while (0)
+
+#define HFSPLUS_ACE_SET_USER_ID(ace_applicable, id) \
+	do { \
+		memset(ace_applicable, 0, HFSPLUS_GUID_SIZE); \
+		memcpy(&ace_applicable[0], \
+			&hfsplus_user_fingerprint[0], \
+			HFSPLUS_FINGERPRINT_SIZE); \
+		(*((__be32 *)&ace_applicable[HFSPLUS_FINGERPRINT_SIZE]) = \
+			cpu_to_be32(id)); \
+	} while (0)
+
+#define HFSPLUS_ACE_SET_GROUP_ID(ace_applicable, id) \
+	do { \
+		memset(ace_applicable, 0, HFSPLUS_GUID_SIZE); \
+		memcpy(&ace_applicable[0], \
+			&hfsplus_group_fingerprint[0], \
+			HFSPLUS_FINGERPRINT_SIZE); \
+		(*((__be32 *)&ace_applicable[HFSPLUS_FINGERPRINT_SIZE]) = \
+			cpu_to_be32(id)); \
+	} while (0)
+
+#define HFSPLUS_COMPOSE_DENY_ACE(ace, ace_applicable_buf, eflag, perms) \
+	do { \
+		memcpy(ace->ace_applicable, \
+				ace_applicable_buf, HFSPLUS_GUID_SIZE); \
+		ace->ace_flags = cpu_to_be32(HFSPLUS_ACE_DENY | eflag); \
+		ace->ace_rights = cpu_to_be32(perms); \
+		hfs_dbg_hexdump(ACL_MOD, "ace_applicable: ", \
+				ace->ace_applicable, HFSPLUS_GUID_SIZE); \
+		hfs_dbg(ACL_MOD, \
+			"[%s]: ace_flags %#x, ace_rights %#x\n", \
+				__func__, be32_to_cpu(ace->ace_flags), \
+				perms); \
+	} while (0)
+
+#define HFSPLUS_COMPOSE_PERMIT_ACE(ace, ace_applicable_buf, eflag, perms) \
+	do { \
+		memcpy(ace->ace_applicable, \
+				ace_applicable_buf, HFSPLUS_GUID_SIZE); \
+		ace->ace_flags = cpu_to_be32(HFSPLUS_ACE_PERMIT | eflag); \
+		ace->ace_rights = cpu_to_be32(perms); \
+		hfs_dbg_hexdump(ACL_MOD, "ace_applicable: ", \
+				ace->ace_applicable, HFSPLUS_GUID_SIZE); \
+		hfs_dbg(ACL_MOD, \
+			"[%s]: ace_flags %#x, ace_rights %#x\n", \
+				__func__, be32_to_cpu(ace->ace_flags), \
+				perms); \
+	} while (0)
+
+static int hfsplus_prepare_nfsv4_acl_mapping(
+				struct nfsv4_acl_info *nfsv4_acl_info,
+				void **nfsv4_ace)
+{
+	struct hfsplus_acl_record *fsec_acl;
+	struct hfsplus_nfsv4_mapping_env *mapping_env;
+	size_t allocated_size;
+	size_t filesec_hdr_size = sizeof(struct hfsplus_filesec);
+
+	hfs_dbg(ACL_MOD, "[%s]: nfsv4_acl_info %p, nfsv4_ace %p\n",
+				__func__, nfsv4_acl_info, nfsv4_ace);
+
+	BUG_ON(!nfsv4_acl_info || !nfsv4_ace);
+
+	fsec_acl = (struct hfsplus_acl_record *)(nfsv4_acl_info->raw_acl);
+	mapping_env =
+		(struct hfsplus_nfsv4_mapping_env *)(nfsv4_acl_info->private);
+
+	hfs_dbg(ACL_MOD, "[%s]: fsec_acl %p, mapping_env %p\n",
+				__func__, fsec_acl, mapping_env);
+
+	BUG_ON(*nfsv4_ace != NULL);
+
+	allocated_size = mapping_env->allocated_acl_size;
+
+	hfs_dbg(ACL_MOD, "[%s]: allocated_size %zu\n",
+			__func__, allocated_size);
+
+	if (allocated_size <= 0 ||
+			allocated_size > HFSPLUS_MAX_INLINE_DATA_SIZE) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -EINVAL);
+		return -EINVAL;
+	}
+
+	if (mapping_env->composed_acl_size != filesec_hdr_size ||
+			mapping_env->composed_acl_size >= allocated_size) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -EINVAL);
+		return -EINVAL;
+	}
+
+	*nfsv4_ace = (void *)fsec_acl->acl_ace;
+	hfs_dbg(ACL_MOD, "[%s]: ace %p\n", __func__, *nfsv4_ace);
+	return 0;
+}
+
+static u32 hfsplus_mask_from_posix(struct nfsv4_acl_info *nfsv4_acl_info,
+					unsigned short perm,
+					unsigned int flags)
+{
+	struct hfsplus_nfsv4_mapping_env *mapping_env =
+		(struct hfsplus_nfsv4_mapping_env *)nfsv4_acl_info->private;
+	int mask = HFSPLUS_VNODE_ANYONE_MODE;
+
+	if (flags & NFS4_ACL_OWNER)
+		mask |= HFSPLUS_VNODE_OWNER_MODE;
+	if (perm & ACL_READ)
+		mask |= HFSPLUS_VNODE_READ_DATA;
+	if (perm & ACL_WRITE)
+		mask |= HFSPLUS_VNODE_WRITE_MODE;
+	if ((perm & ACL_WRITE) && S_ISDIR(mapping_env->inode->i_mode))
+		mask |= HFSPLUS_VNODE_DELETE_CHILD;
+	if (perm & ACL_EXECUTE)
+		mask |= HFSPLUS_VNODE_EXECUTE;
+
+	hfs_dbg(ACL_MOD, "[%s]: perm %#x, mask %#x\n", __func__, perm, mask);
+
+	return mask;
+}
+
+static u32 hfsplus_deny_mask_from_posix(struct nfsv4_acl_info *nfsv4_acl_info,
+					unsigned short perm,
+					unsigned int flags)
+{
+	struct hfsplus_nfsv4_mapping_env *mapping_env =
+		(struct hfsplus_nfsv4_mapping_env *)nfsv4_acl_info->private;
+	u32 mask = 0;
+
+	if (perm & ACL_READ)
+		mask |= HFSPLUS_VNODE_READ_DATA;
+	if (perm & ACL_WRITE)
+		mask |= HFSPLUS_VNODE_WRITE_MODE;
+	if ((perm & ACL_WRITE) && S_ISDIR(mapping_env->inode->i_mode))
+		mask |= HFSPLUS_VNODE_DELETE_CHILD;
+	if (perm & ACL_EXECUTE)
+		mask |= HFSPLUS_VNODE_EXECUTE;
+
+	hfs_dbg(ACL_MOD, "[%s]: perm %#x, mask %#x\n", __func__, perm, mask);
+
+	return mask;
+}
+
+static int hfsplus_map_owner_ace(struct user_namespace *user_ns,
+				    unsigned int eflag,
+				    unsigned int flags,
+				    unsigned short deny,
+				    struct posix_acl_entry *pa,
+				    struct posix_acl_summary *pas,
+				    struct nfsv4_acl_info *nfsv4_acl_info,
+				    void **nfsv4_ace)
+{
+	struct hfsplus_acl_record *fsec_acl =
+		(struct hfsplus_acl_record *)nfsv4_acl_info->raw_acl;
+	struct hfsplus_acl_entry *ace =
+		*(struct hfsplus_acl_entry **)nfsv4_ace;
+	struct hfsplus_nfsv4_mapping_env *mapping_env =
+		(struct hfsplus_nfsv4_mapping_env *)nfsv4_acl_info->private;
+	const size_t allocated_size = mapping_env->allocated_acl_size;
+	size_t ace_size = sizeof(struct hfsplus_acl_entry);
+	u32 ace_entries = be32_to_cpu(fsec_acl->acl_entrycount);
+	u32 rights;
+
+	hfs_dbg(ACL_MOD, "[%s]: eflag %#x, flags %#x, deny %#x\n",
+			__func__, eflag, flags, deny);
+	hfs_dbg(ACL_MOD, "[%s]: pa %p, pas %p\n", __func__, pa, pas);
+	hfs_dbg(ACL_MOD, "[%s]: acl_info %p, nfsv4_ace %p\n",
+			__func__, nfsv4_acl_info, nfsv4_ace);
+
+	BUG_ON(ace == NULL || pa == NULL);
+
+	hfs_dbg(ACL_MOD, "[%s]: ace %p\n", __func__, *nfsv4_ace);
+
+	HFSPLUS_ACE_SET_OWNER_USER_ID(mapping_env->ace_applicable);
+
+	if (deny) {
+		hfs_dbg(ACL_MOD,
+			"[%s]: compose owner (%#x) deny ACE\n",
+			__func__, i_uid_read(mapping_env->inode));
+
+		if ((mapping_env->composed_acl_size + ace_size) >
+					allocated_size) {
+			hfs_dbg(ACL_MOD,
+				"(%s, %d): %s: err %d\n",
+				__FILE__, __LINE__, __func__, -ENOMEM);
+			return -ENOMEM;
+		}
+
+		rights = hfsplus_deny_mask_from_posix(nfsv4_acl_info,
+							deny, flags);
+		HFSPLUS_COMPOSE_DENY_ACE(ace, mapping_env->ace_applicable,
+						eflag, rights);
+		*nfsv4_ace = (void *)(++ace);
+		ace_entries++;
+		mapping_env->composed_acl_size += ace_size;
+	}
+
+	hfs_dbg(ACL_MOD,
+		"[%s]: compose owner (%#x) permit ACE\n",
+		__func__, i_uid_read(mapping_env->inode));
+
+	if ((mapping_env->composed_acl_size + ace_size) > allocated_size) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -ENOMEM);
+		return -ENOMEM;
+	}
+
+	rights = hfsplus_mask_from_posix(nfsv4_acl_info, pa->e_perm,
+						flags | NFS4_ACL_OWNER);
+	HFSPLUS_COMPOSE_PERMIT_ACE(ace, mapping_env->ace_applicable,
+						eflag, rights);
+	*nfsv4_ace = (void *)(++ace);
+	ace_entries++;
+	mapping_env->composed_acl_size += ace_size;
+
+	fsec_acl->acl_entrycount = cpu_to_be32(ace_entries);
+
+	return 0;
+}
+
+static int hfsplus_map_user_ace(struct user_namespace *user_ns,
+				unsigned int eflag,
+				unsigned int flags,
+				unsigned short deny,
+				struct posix_acl_entry *pa,
+				struct posix_acl_summary *pas,
+				struct nfsv4_acl_info *nfsv4_acl_info,
+				void **nfsv4_ace)
+{
+	struct hfsplus_acl_record *fsec_acl =
+		(struct hfsplus_acl_record *)nfsv4_acl_info->raw_acl;
+	struct hfsplus_acl_entry *ace =
+		*(struct hfsplus_acl_entry **)nfsv4_ace;
+	struct hfsplus_nfsv4_mapping_env *mapping_env =
+		(struct hfsplus_nfsv4_mapping_env *)nfsv4_acl_info->private;
+	const size_t allocated_size = mapping_env->allocated_acl_size;
+	size_t ace_size = sizeof(struct hfsplus_acl_entry);
+	u32 ace_entries = be32_to_cpu(fsec_acl->acl_entrycount);
+	u32 rights;
+
+	hfs_dbg(ACL_MOD, "[%s]: eflag %#x, flags %#x, deny %#x\n",
+			__func__, eflag, flags, deny);
+	hfs_dbg(ACL_MOD, "[%s]: pa %p, pas %p\n", __func__, pa, pas);
+	hfs_dbg(ACL_MOD, "[%s]: acl_info %p, nfsv4_ace %p\n",
+			__func__, nfsv4_acl_info, nfsv4_ace);
+
+	BUG_ON(ace == NULL || pa == NULL || pas == NULL);
+
+	hfs_dbg(ACL_MOD, "[%s]: ace %p\n", __func__, *nfsv4_ace);
+
+	HFSPLUS_ACE_SET_USER_ID(mapping_env->ace_applicable,
+			from_kuid_munged(user_ns, pa->e_id));
+
+	if (deny) {
+		hfs_dbg(ACL_MOD,
+			"[%s]: compose user (%#x) deny ACE\n",
+			__func__, from_kuid_munged(user_ns, pa->e_id));
+
+		if ((mapping_env->composed_acl_size + ace_size) >
+					allocated_size) {
+			hfs_dbg(ACL_MOD,
+				"(%s, %d): %s: err %d\n",
+				__FILE__, __LINE__, __func__, -ENOMEM);
+			return -ENOMEM;
+		}
+
+		rights = hfsplus_deny_mask_from_posix(nfsv4_acl_info,
+							deny, flags);
+		HFSPLUS_COMPOSE_DENY_ACE(ace, mapping_env->ace_applicable,
+							eflag, rights);
+		*nfsv4_ace = (void *)(++ace);
+		ace_entries++;
+		mapping_env->composed_acl_size += ace_size;
+	}
+
+	hfs_dbg(ACL_MOD,
+			"[%s]: compose user (%#x) permit ACE\n",
+			__func__, from_kuid_munged(user_ns, pa->e_id));
+
+	if ((mapping_env->composed_acl_size + ace_size) > allocated_size) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -ENOMEM);
+		return -ENOMEM;
+	}
+
+	rights = hfsplus_mask_from_posix(nfsv4_acl_info,
+					pa->e_perm & pas->mask, flags);
+	HFSPLUS_COMPOSE_PERMIT_ACE(ace, mapping_env->ace_applicable,
+					eflag, rights);
+	*nfsv4_ace = (void *)(++ace);
+	ace_entries++;
+	mapping_env->composed_acl_size += ace_size;
+
+	fsec_acl->acl_entrycount = cpu_to_be32(ace_entries);
+
+	return 0;
+}
+
+static int hfsplus_map_group_owner_deny_ace(struct user_namespace *user_ns,
+					unsigned int eflag,
+					unsigned int flags,
+					unsigned short deny,
+					struct posix_acl_entry *pa,
+					struct posix_acl_summary *pas,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace)
+{
+	struct hfsplus_acl_record *fsec_acl =
+		(struct hfsplus_acl_record *)nfsv4_acl_info->raw_acl;
+	struct hfsplus_acl_entry *ace =
+		*(struct hfsplus_acl_entry **)nfsv4_ace;
+	struct hfsplus_nfsv4_mapping_env *mapping_env =
+		(struct hfsplus_nfsv4_mapping_env *)nfsv4_acl_info->private;
+	const size_t allocated_size = mapping_env->allocated_acl_size;
+	size_t ace_size = sizeof(struct hfsplus_acl_entry);
+	u32 ace_entries = be32_to_cpu(fsec_acl->acl_entrycount);
+	u32 rights;
+
+	hfs_dbg(ACL_MOD, "[%s]: eflag %#x, flags %#x, deny %#x\n",
+			__func__, eflag, flags, deny);
+	hfs_dbg(ACL_MOD, "[%s]: pa %p, pas %p\n", __func__, pa, pas);
+	hfs_dbg(ACL_MOD, "[%s]: acl_info %p, nfsv4_ace %p\n",
+			__func__, nfsv4_acl_info, nfsv4_ace);
+
+	BUG_ON(ace == NULL);
+
+	hfs_dbg(ACL_MOD, "[%s]: ace %p\n", __func__, *nfsv4_ace);
+
+	if (deny) {
+		HFSPLUS_ACE_SET_GROUP_ID(mapping_env->ace_applicable,
+					i_gid_read(mapping_env->inode));
+
+		hfs_dbg(ACL_MOD,
+			"[%s]: compose group of owner (%#x) deny ACE\n",
+			__func__, i_gid_read(mapping_env->inode));
+
+		if ((mapping_env->composed_acl_size + ace_size) >
+					allocated_size) {
+			hfs_dbg(ACL_MOD,
+				"(%s, %d): %s: err %d\n",
+				__FILE__, __LINE__, __func__, -ENOMEM);
+			return -ENOMEM;
+		}
+
+		rights = hfsplus_deny_mask_from_posix(nfsv4_acl_info,
+							deny, flags);
+		HFSPLUS_COMPOSE_DENY_ACE(ace, mapping_env->ace_applicable,
+						eflag, rights);
+		*nfsv4_ace = (void *)(++ace);
+		ace_entries++;
+		mapping_env->composed_acl_size += ace_size;
+		fsec_acl->acl_entrycount = cpu_to_be32(ace_entries);
+	}
+
+	return 0;
+}
+
+static int hfsplus_map_group_owner_permit_ace(struct user_namespace *user_ns,
+					unsigned int eflag,
+					unsigned int flags,
+					unsigned short deny,
+					struct posix_acl_entry *pa,
+					struct posix_acl_summary *pas,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace)
+{
+	struct hfsplus_acl_record *fsec_acl =
+		(struct hfsplus_acl_record *)nfsv4_acl_info->raw_acl;
+	struct hfsplus_acl_entry *ace =
+		*(struct hfsplus_acl_entry **)nfsv4_ace;
+	struct hfsplus_nfsv4_mapping_env *mapping_env =
+		(struct hfsplus_nfsv4_mapping_env *)nfsv4_acl_info->private;
+	const size_t allocated_size = mapping_env->allocated_acl_size;
+	size_t ace_size = sizeof(struct hfsplus_acl_entry);
+	u32 ace_entries = be32_to_cpu(fsec_acl->acl_entrycount);
+	u32 rights;
+
+	hfs_dbg(ACL_MOD, "[%s]: eflag %#x, flags %#x, deny %#x\n",
+			__func__, eflag, flags, deny);
+	hfs_dbg(ACL_MOD, "[%s]: pa %p, pas %p\n", __func__, pa, pas);
+	hfs_dbg(ACL_MOD, "[%s]: acl_info %p, nfsv4_ace %p\n",
+			__func__, nfsv4_acl_info, nfsv4_ace);
+
+	BUG_ON(ace == NULL || pas == NULL);
+
+	hfs_dbg(ACL_MOD, "[%s]: ace %p\n", __func__, *nfsv4_ace);
+
+	HFSPLUS_ACE_SET_GROUP_ID(mapping_env->ace_applicable,
+				i_gid_read(mapping_env->inode));
+
+	hfs_dbg(ACL_MOD,
+		"[%s]: compose group of owner (%#x) permit ACE\n",
+		__func__, i_gid_read(mapping_env->inode));
+
+	if ((mapping_env->composed_acl_size + ace_size) >
+				allocated_size) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -ENOMEM);
+		return -ENOMEM;
+	}
+
+	rights = hfsplus_mask_from_posix(nfsv4_acl_info,
+					pas->group, flags);
+	HFSPLUS_COMPOSE_PERMIT_ACE(ace, mapping_env->ace_applicable,
+					eflag, rights);
+	*nfsv4_ace = (void *)(++ace);
+	ace_entries++;
+	mapping_env->composed_acl_size += ace_size;
+
+	fsec_acl->acl_entrycount = cpu_to_be32(ace_entries);
+
+	return 0;
+}
+
+static int hfsplus_map_group_deny_ace(struct user_namespace *user_ns,
+					unsigned int eflag,
+					unsigned int flags,
+					unsigned short deny,
+					struct posix_acl_entry *pa,
+					struct posix_acl_summary *pas,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace)
+{
+	struct hfsplus_acl_record *fsec_acl =
+		(struct hfsplus_acl_record *)nfsv4_acl_info->raw_acl;
+	struct hfsplus_acl_entry *ace =
+		*(struct hfsplus_acl_entry **)nfsv4_ace;
+	struct hfsplus_nfsv4_mapping_env *mapping_env =
+		(struct hfsplus_nfsv4_mapping_env *)nfsv4_acl_info->private;
+	const size_t allocated_size = mapping_env->allocated_acl_size;
+	size_t ace_size = sizeof(struct hfsplus_acl_entry);
+	u32 ace_entries = be32_to_cpu(fsec_acl->acl_entrycount);
+	u32 rights;
+
+	hfs_dbg(ACL_MOD, "[%s]: eflag %#x, flags %#x, deny %#x\n",
+			__func__, eflag, flags, deny);
+	hfs_dbg(ACL_MOD, "[%s]: pa %p, pas %p\n", __func__, pa, pas);
+	hfs_dbg(ACL_MOD, "[%s]: acl_info %p, nfsv4_ace %p\n",
+			__func__, nfsv4_acl_info, nfsv4_ace);
+
+	BUG_ON(ace == NULL || pa == NULL);
+
+	hfs_dbg(ACL_MOD, "[%s]: ace %p\n", __func__, *nfsv4_ace);
+
+	if (deny) {
+		HFSPLUS_ACE_SET_GROUP_ID(mapping_env->ace_applicable,
+				from_kgid_munged(user_ns, pa->e_id));
+
+		hfs_dbg(ACL_MOD,
+			"[%s]: compose group (%#x) deny ACE\n",
+			__func__, from_kgid_munged(user_ns, pa->e_id));
+
+		if ((mapping_env->composed_acl_size + ace_size) >
+					allocated_size) {
+			hfs_dbg(ACL_MOD,
+				"(%s, %d): %s: err %d\n",
+				__FILE__, __LINE__, __func__, -ENOMEM);
+			return -ENOMEM;
+		}
+
+		rights = hfsplus_deny_mask_from_posix(nfsv4_acl_info,
+							deny, flags);
+		HFSPLUS_COMPOSE_DENY_ACE(ace, mapping_env->ace_applicable,
+						eflag, rights);
+		*nfsv4_ace = (void *)(++ace);
+		ace_entries++;
+		mapping_env->composed_acl_size += ace_size;
+		fsec_acl->acl_entrycount = cpu_to_be32(ace_entries);
+	}
+
+	return 0;
+}
+
+static int hfsplus_map_group_permit_ace(struct user_namespace *user_ns,
+					unsigned int eflag,
+					unsigned int flags,
+					unsigned short deny,
+					struct posix_acl_entry *pa,
+					struct posix_acl_summary *pas,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace)
+{
+	struct hfsplus_acl_record *fsec_acl =
+		(struct hfsplus_acl_record *)nfsv4_acl_info->raw_acl;
+	struct hfsplus_acl_entry *ace =
+		*(struct hfsplus_acl_entry **)nfsv4_ace;
+	struct hfsplus_nfsv4_mapping_env *mapping_env =
+		(struct hfsplus_nfsv4_mapping_env *)nfsv4_acl_info->private;
+	const size_t allocated_size = mapping_env->allocated_acl_size;
+	size_t ace_size = sizeof(struct hfsplus_acl_entry);
+	u32 ace_entries = be32_to_cpu(fsec_acl->acl_entrycount);
+	u32 rights;
+
+	hfs_dbg(ACL_MOD, "[%s]: eflag %#x, flags %#x, deny %#x\n",
+			__func__, eflag, flags, deny);
+	hfs_dbg(ACL_MOD, "[%s]: pa %p, pas %p\n", __func__, pa, pas);
+	hfs_dbg(ACL_MOD, "[%s]: acl_info %p, nfsv4_ace %p\n",
+			__func__, nfsv4_acl_info, nfsv4_ace);
+
+	BUG_ON(ace == NULL || pa == NULL || pas == NULL);
+
+	hfs_dbg(ACL_MOD, "[%s]: ace %p\n", __func__, *nfsv4_ace);
+
+	HFSPLUS_ACE_SET_GROUP_ID(mapping_env->ace_applicable,
+				from_kgid_munged(user_ns, pa->e_id));
+
+	hfs_dbg(ACL_MOD,
+		"[%s]: compose group (%#x) permit ACE\n",
+		__func__, from_kgid_munged(user_ns, pa->e_id));
+
+	if ((mapping_env->composed_acl_size + ace_size) >
+				allocated_size) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -ENOMEM);
+		return -ENOMEM;
+	}
+
+	rights = hfsplus_mask_from_posix(nfsv4_acl_info,
+					pa->e_perm & pas->mask, flags);
+	HFSPLUS_COMPOSE_PERMIT_ACE(ace, mapping_env->ace_applicable,
+					eflag, rights);
+	*nfsv4_ace = (void *)(++ace);
+	ace_entries++;
+	mapping_env->composed_acl_size += ace_size;
+
+	fsec_acl->acl_entrycount = cpu_to_be32(ace_entries);
+
+	return 0;
+}
+
+static int hfsplus_map_everyone_permit_ace(unsigned int eflag,
+					unsigned int flags,
+					struct posix_acl_entry *pa,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace)
+{
+	struct hfsplus_acl_record *fsec_acl =
+		(struct hfsplus_acl_record *)nfsv4_acl_info->raw_acl;
+	struct hfsplus_acl_entry *ace =
+		*(struct hfsplus_acl_entry **)nfsv4_ace;
+	struct hfsplus_nfsv4_mapping_env *mapping_env =
+		(struct hfsplus_nfsv4_mapping_env *)nfsv4_acl_info->private;
+	const size_t allocated_size = mapping_env->allocated_acl_size;
+	size_t ace_size = sizeof(struct hfsplus_acl_entry);
+	u32 ace_entries = be32_to_cpu(fsec_acl->acl_entrycount);
+	u32 rights;
+
+	hfs_dbg(ACL_MOD, "[%s]: eflag %#x, flags %#x\n",
+			__func__, eflag, flags);
+	hfs_dbg(ACL_MOD, "[%s]: pa %p\n", __func__, pa);
+	hfs_dbg(ACL_MOD, "[%s]: acl_info %p, nfsv4_ace %p\n",
+			__func__, nfsv4_acl_info, nfsv4_ace);
+
+	BUG_ON(ace == NULL || pa == NULL);
+
+	hfs_dbg(ACL_MOD, "[%s]: ace %p\n", __func__, *nfsv4_ace);
+	hfs_dbg(ACL_MOD, "[%s]: compose EVERYBODY permit ACE\n", __func__);
+
+	HFSPLUS_ACE_SET_GROUP_ID(mapping_env->ace_applicable,
+					HFSPLUS_EVERYBODY_ID);
+
+	if ((mapping_env->composed_acl_size + ace_size) >
+				allocated_size) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -ENOMEM);
+		return -ENOMEM;
+	}
+
+	rights = hfsplus_mask_from_posix(nfsv4_acl_info,
+					pa->e_perm, flags);
+	HFSPLUS_COMPOSE_PERMIT_ACE(ace, mapping_env->ace_applicable,
+					eflag, rights);
+	ace_entries++;
+	mapping_env->composed_acl_size += ace_size;
+
+	fsec_acl->acl_entrycount = cpu_to_be32(ace_entries);
+
+	return 0;
+}
+
+static struct nfsv4_ace_operations hfsplus_ace_ops = {
+	.get_naces = hfsplus_get_naces,
+	.get_ace = hfsplus_get_ace,
+	.get_access_mask = hfsplus_get_access_mask,
+	.ace_type_valid = hfsplus_ace_type_valid,
+	.is_allowed_ace_type = hfsplus_is_allowed_ace_type,
+	.is_acl_user_obj = hfsplus_is_acl_user_obj,
+	.is_acl_group_obj = hfsplus_is_acl_group_obj,
+	.is_acl_other = hfsplus_is_acl_other,
+	.is_acl_user = hfsplus_is_acl_user,
+	.is_acl_group = hfsplus_is_acl_group,
+};
+
+static struct nfsv4_ace_flags_operations hfsplus_ace_flags_ops = {
+	.ace_has_unknown_flags = hfsplus_ace_has_unknown_flags,
+	.ace_has_inheritance_flags = hfsplus_ace_has_inheritance_flags,
+	.ace_inherit_only_flag = hfsplus_ace_inherit_only_flag,
+	.check_deny = hfsplus_check_deny,
+	.low_mode_from_nfs4 = hfsplus_low_mode_from_nfs4,
+	.calculate_eflag = hfsplus_calculate_eflag,
+};
+
+static struct nfsv4_acl_id_operations hfsplus_acl_id_ops = {
+	.find_uid = hfsplus_find_uid,
+	.find_gid = hfsplus_find_gid,
+	.set_posix_ace_uid = hfsplus_set_posix_ace_uid,
+	.set_posix_ace_gid = hfsplus_set_posix_ace_gid,
+};
+
+static struct nfsv4_acl_mapping_operations hfsplus_acl_mapping_ops = {
+	.prepare_nfsv4_acl_mapping = hfsplus_prepare_nfsv4_acl_mapping,
+	.mask_from_posix = hfsplus_mask_from_posix,
+	.deny_mask_from_posix = hfsplus_deny_mask_from_posix,
+	.map_owner_ace = hfsplus_map_owner_ace,
+	.map_user_ace = hfsplus_map_user_ace,
+	.map_group_owner_deny_ace = hfsplus_map_group_owner_deny_ace,
+	.map_group_owner_permit_ace = hfsplus_map_group_owner_permit_ace,
+	.map_group_deny_ace = hfsplus_map_group_deny_ace,
+	.map_group_permit_ace = hfsplus_map_group_permit_ace,
+	.map_everyone_permit_ace = hfsplus_map_everyone_permit_ace,
+};
+
+static struct hfsplus_acl_record *hfsplus_acl_record_from_xattr(
+							void *value,
+							size_t size)
+{
+	struct hfsplus_filesec *filesec_ptr =
+			(struct hfsplus_filesec *)value;
+	struct hfsplus_acl_record *acl_record_ptr = NULL;
+	size_t filesec_hdr_size = offsetof(struct hfsplus_filesec, fsec_acl);
+	size_t acl_record_hdr_size =
+		offsetof(struct hfsplus_acl_record, acl_ace);
+	size_t known_size = filesec_hdr_size;
+	u32 acl_entries_count = 0;
+	u32 acl_entries_size = 0;
+
+	hfs_dbg(ACL_MOD,
+		"[%s]: value %p, size %zu\n",
+		__func__, value, size);
+
+	if (unlikely(size < known_size)) {
+		pr_err("filesec hdr corrupted\n");
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -EINVAL);
+		return ERR_PTR(-EINVAL);
+	}
+
+	if (unlikely(be32_to_cpu(filesec_ptr->fsec_magic) !=
+				HFSPLUS_FILESEC_MAGIC)) {
+		pr_err("invalid fsec_magic\n");
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -EINVAL);
+		return ERR_PTR(-EINVAL);
+	}
+
+	known_size += acl_record_hdr_size;
+
+	if (unlikely(size < known_size)) {
+		pr_err("acl record hdr corrupted\n");
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -EINVAL);
+		return ERR_PTR(-EINVAL);
+	}
+
+	acl_record_ptr = &(filesec_ptr->fsec_acl);
+	acl_entries_count = be32_to_cpu(acl_record_ptr->acl_entrycount);
+	acl_entries_size =
+		acl_entries_count * sizeof(struct hfsplus_acl_entry);
+	known_size += acl_entries_size;
+
+	if (unlikely(size < known_size)) {
+		pr_err("acl entries array corrupted\n");
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -EINVAL);
+		return ERR_PTR(-EINVAL);
+	}
+
+	return acl_record_ptr;
+}
+
+static uid_t extract_uid_from_ace(struct hfsplus_acl_entry *ace)
+{
+	int size = HFSPLUS_FINGERPRINT_SIZE;
+	__be32 *raw_id_ptr;
+	uid_t uid;
+
+	hfs_dbg(ACL_MOD, "[%s]: ace %p\n", __func__, ace);
+
+	if (IS_GROUP_FINGERPRINT(ace->ace_applicable) ||
+			IS_USER_FINGERPRINT(ace->ace_applicable)) {
+		raw_id_ptr = (__be32 *)&ace->ace_applicable[size];
+		uid = be32_to_cpu(*raw_id_ptr);
+		hfs_dbg(ACL_MOD, "[%s]: uid/gid %#x\n", __func__, uid);
+	} else {
+		hfs_dbg(ACL_MOD, "[%s]: uid/gid %#x\n",
+				__func__, ACL_UNDEFINED_ID);
+		return ACL_UNDEFINED_ID;
+	}
+
+	return uid;
+}
+
+/* It is expected that ace is not empty */
+static int compare_ace_type(struct hfsplus_acl_entry *left_ace,
+				struct hfsplus_acl_entry *right_ace)
+{
+	u32 left_ace_flags = be32_to_cpu(left_ace->ace_flags);
+	u32 left_ace_type = left_ace_flags & HFSPLUS_ACE_KINDMASK;
+	u32 right_ace_flags = be32_to_cpu(right_ace->ace_flags);
+	u32 right_ace_type = right_ace_flags & HFSPLUS_ACE_KINDMASK;
+
+	if (left_ace_type == HFSPLUS_ACE_DENY &&
+			right_ace_type == HFSPLUS_ACE_DENY)
+		return 0;
+	else if (left_ace_type == HFSPLUS_ACE_PERMIT &&
+			right_ace_type == HFSPLUS_ACE_PERMIT)
+		return 0;
+	else if (left_ace_type == HFSPLUS_ACE_DENY)
+		return -1;
+	else if (left_ace_type == HFSPLUS_ACE_PERMIT) {
+		if (right_ace_type == HFSPLUS_ACE_DENY)
+			return 1;
+		else
+			return -1;
+	} else if (right_ace_type == HFSPLUS_ACE_DENY ||
+			right_ace_type == HFSPLUS_ACE_PERMIT)
+		return -1;
+
+	return 0;
+}
+
+static int compare_ace(struct nfsv4_acl_info *nfsv4_acl_info,
+			struct hfsplus_acl_entry *left_ace,
+			struct hfsplus_acl_entry *right_ace)
+{
+	uid_t left_uid, right_uid;
+
+	if (empty_ace(left_ace) && empty_ace(right_ace))
+		return 0;
+
+	if (hfsplus_is_acl_user_obj(nfsv4_acl_info, left_ace)) {
+		if (hfsplus_is_acl_user_obj(nfsv4_acl_info, right_ace))
+			return compare_ace_type(left_ace, right_ace);
+		else
+			return -1;
+	} else if (hfsplus_is_acl_user_obj(nfsv4_acl_info, right_ace))
+		return 1;
+
+	if (hfsplus_is_acl_group_obj(nfsv4_acl_info, left_ace)) {
+		if (hfsplus_is_acl_group_obj(nfsv4_acl_info, right_ace))
+			return compare_ace_type(left_ace, right_ace);
+		else
+			return -1;
+	} else if (hfsplus_is_acl_group_obj(nfsv4_acl_info, right_ace))
+		return 1;
+
+	if (hfsplus_is_acl_other(nfsv4_acl_info, left_ace)) {
+		if (hfsplus_is_acl_other(nfsv4_acl_info, right_ace))
+			return compare_ace_type(left_ace, right_ace);
+		else
+			return -1;
+	} else if (hfsplus_is_acl_other(nfsv4_acl_info, right_ace))
+		return 1;
+
+	left_uid = extract_uid_from_ace(left_ace);
+	right_uid = extract_uid_from_ace(right_ace);
+
+	/* ACL_UNDEFINED_ID is greater always */
+	if (left_uid == ACL_UNDEFINED_ID) {
+		if (right_uid == ACL_UNDEFINED_ID)
+			return 0;
+		else
+			return 1;
+	} else if (right_uid == ACL_UNDEFINED_ID)
+		return 1;
+
+	if (left_uid == right_uid)
+		return compare_ace_type(left_ace, right_ace);
+
+	return left_uid < right_uid ? -1 : 1;
+}
+
+/*
+ * Insertion sort.
+ * Algorithm of the method is based on psevdocode from:
+ * http://en.wikipedia.org/wiki/Insertion_sort
+ */
+static int sort_hfsplus_ace(struct nfsv4_acl_info *nfsv4_acl_info)
+{
+	struct hfsplus_acl_record *fsec_acl =
+		(struct hfsplus_acl_record *)nfsv4_acl_info->raw_acl;
+	struct hfsplus_nfsv4_mapping_env *mapping_env =
+		(struct hfsplus_nfsv4_mapping_env *)nfsv4_acl_info->private;
+	struct hfsplus_acl_entry *ace = fsec_acl->acl_ace;
+	struct hfsplus_acl_entry temp_buf;
+	int entries_count = be32_to_cpu(fsec_acl->acl_entrycount);
+	ssize_t calculated_size = sizeof(struct hfsplus_filesec) +
+			(entries_count * sizeof(struct hfsplus_acl_entry));
+	int i;
+
+	if (entries_count == 0)
+		return 0;
+
+	hfs_dbg(ACL_MOD, "[%s]: fsec_acl (%p)\n",
+			__func__, fsec_acl);
+	hfs_dbg(ACL_MOD, "[%s]: calculated_size (%zu)\n",
+			__func__, calculated_size);
+	hfs_dbg(ACL_MOD, "[%s]: composed_acl_size (%zu)\n",
+			__func__, mapping_env->composed_acl_size);
+	hfs_dbg(ACL_MOD, "[%s]: allocated_acl_size (%zu)\n",
+			__func__, mapping_env->allocated_acl_size);
+	hfs_dbg_hexdump(ACL_MOD, "unsorted composed_filesec: ",
+				fsec_acl, mapping_env->composed_acl_size);
+
+	if (calculated_size != mapping_env->composed_acl_size ||
+			calculated_size > mapping_env->allocated_acl_size) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -EINVAL);
+		return -EINVAL;
+	}
+
+	for (i = 1; i < entries_count; i++) {
+		int hole_index = i;
+		memcpy(&temp_buf, &ace[i], sizeof(struct hfsplus_acl_entry));
+
+		while (hole_index > 0 &&
+				(compare_ace(nfsv4_acl_info,
+						&ace[hole_index - 1],
+						&temp_buf) > 0)) {
+			/* move hole to next smaller index */
+			memcpy(&ace[hole_index], &ace[hole_index - 1],
+					sizeof(struct hfsplus_acl_entry));
+			hole_index -= 1;
+		}
+
+		memcpy(&ace[hole_index], &temp_buf,
+				sizeof(struct hfsplus_acl_entry));
+	}
+
+	hfs_dbg_hexdump(ACL_MOD, "sorted composed_filesec: ",
+				fsec_acl, mapping_env->composed_acl_size);
+
+	return 0;
+}
+
+struct posix_acl *hfsplus_posix_acl_from_xattr(struct inode *inode,
+					struct user_namespace *user_ns,
+					void *value,
+					size_t size,
+					int type)
+{
+	int err = 0;
+	struct hfsplus_nfsv4_mapping_env mapping_env = {
+		.inode = inode,
+		.composed_acl_size = 0,
+		.allocated_acl_size = size,
+	};
+	struct nfsv4_acl_info acl_info = {
+		.ace_ops = &hfsplus_ace_ops,
+		.flags_ops = &hfsplus_ace_flags_ops,
+		.id_ops = &hfsplus_acl_id_ops,
+		.mapping_ops = &hfsplus_acl_mapping_ops,
+		.raw_acl = NULL,
+		.private = &mapping_env,
+	};
+	struct posix_acl *pacl = NULL, *dpacl = NULL;
+	struct hfsplus_filesec *filesec =
+			(struct hfsplus_filesec *)value;
+	u32 acl_entries_count = 0;
+	unsigned int flags = 0;
+
+	hfs_dbg(ACL_MOD,
+		"[%s]: ino %lu, value %p, size %zu, type %#x\n",
+		__func__, inode->i_ino, value, size, type);
+
+	if (!value)
+		return NULL;
+
+	if (type != ACL_TYPE_ACCESS && type != ACL_TYPE_DEFAULT)
+		return NULL;
+
+	acl_info.raw_acl = hfsplus_acl_record_from_xattr(value, size);
+	if (unlikely(IS_ERR(acl_info.raw_acl))) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %ld\n",
+			__FILE__, __LINE__, __func__,
+			PTR_ERR(acl_info.raw_acl));
+		return NULL;
+	}
+
+	acl_entries_count = be32_to_cpu(filesec->fsec_acl.acl_entrycount);
+	mapping_env.composed_acl_size = sizeof(struct hfsplus_filesec) +
+		(acl_entries_count * sizeof(struct hfsplus_acl_entry));
+	err = sort_hfsplus_ace(&acl_info);
+	if (unlikely(err)) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, err);
+		return ERR_PTR(err);
+	}
+
+	if (S_ISDIR(inode->i_mode))
+		flags |= NFS4_ACL_DIR;
+
+	err = map_nfsv4_acl_to_posix(user_ns, &acl_info, &pacl, &dpacl, flags);
+	if (unlikely(err)) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, err);
+		goto failed_conversion;
+	}
+
+	switch (type) {
+	case ACL_TYPE_ACCESS:
+		posix_acl_release(dpacl);
+		return pacl;
+
+	case ACL_TYPE_DEFAULT:
+		posix_acl_release(pacl);
+		return dpacl;
+
+	default:
+		BUG();
+	}
+
+failed_conversion:
+	if (pacl)
+		posix_acl_release(pacl);
+	if (dpacl)
+		posix_acl_release(dpacl);
+	return ERR_PTR(err);
+}
+
+static int hfsplus_compose_filesec_from_posix_acl(struct inode *inode,
+						struct user_namespace *user_ns,
+						struct posix_acl *pacl,
+						struct hfsplus_filesec *filesec,
+						size_t allocated_size,
+						int type)
+{
+	int err;
+	struct hfsplus_nfsv4_mapping_env mapping_env = {
+		.inode = inode,
+		.allocated_acl_size = allocated_size,
+		.composed_acl_size = 0,
+	};
+	struct nfsv4_acl_info acl_info = {
+		.ace_ops = &hfsplus_ace_ops,
+		.flags_ops = &hfsplus_ace_flags_ops,
+		.id_ops = &hfsplus_acl_id_ops,
+		.mapping_ops = &hfsplus_acl_mapping_ops,
+		.raw_acl = NULL,
+		.private = &mapping_env,
+	};
+	size_t filesec_hdr_size = sizeof(struct hfsplus_filesec);
+	unsigned int flags = 0;
+
+	hfs_dbg(ACL_MOD,
+		"[%s]: ino %lu, pacl %p, filesec %p, alloc_sz %zu, type %#x\n",
+		__func__, inode->i_ino, pacl, filesec, allocated_size, type);
+
+	BUG_ON(!filesec);
+
+	acl_info.raw_acl = &(filesec->fsec_acl);
+
+	if ((mapping_env.composed_acl_size + filesec_hdr_size) >
+				allocated_size) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -ENOMEM);
+		return -ENOMEM;
+	}
+
+	memset(filesec, 0, sizeof(struct hfsplus_filesec));
+	filesec->fsec_magic = cpu_to_be32(HFSPLUS_FILESEC_MAGIC);
+	mapping_env.composed_acl_size += filesec_hdr_size;
+
+	switch (type) {
+	case ACL_TYPE_ACCESS:
+		flags &= ~NFS4_ACL_TYPE_DEFAULT;
+		break;
+
+	case ACL_TYPE_DEFAULT:
+		flags |= NFS4_ACL_TYPE_DEFAULT;
+		break;
+	}
+
+	err = map_posix_acl_to_nfsv4_one(user_ns, pacl, &acl_info, flags);
+	if (unlikely(err)) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, err);
+		return err;
+	}
+
+	err = sort_hfsplus_ace(&acl_info);
+	if (unlikely(err)) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, err);
+		return err;
+	}
+
+	return 0;
+}
+
+static struct hfsplus_filesec *hfsplus_posix_acl_to_filesec(struct inode *inode,
+						struct user_namespace *user_ns,
+						struct posix_acl *acl,
+						int type)
+{
+	int err = 0;
+	struct hfsplus_filesec *composed_filesec = NULL;
+
+	hfs_dbg(ACL_MOD,
+		"[%s]: ino %lu, type %#x, acl %p\n",
+		__func__, inode->i_ino, type, acl);
+
+	if (posix_acl_valid(acl) < 0) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -EINVAL);
+		return ERR_PTR(-EINVAL);
+	}
+
+	/*
+	 * Mac OS X supports only inline xattr.
+	 * The online xattr can't be greater than
+	 * HFSPLUS_MAX_INLINE_DATA_SIZE (3802) bytes
+	 * in size.
+	 */
+	composed_filesec = kzalloc(HFSPLUS_MAX_INLINE_DATA_SIZE, GFP_KERNEL);
+	if (unlikely(!composed_filesec)) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -ENOMEM);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	err = hfsplus_compose_filesec_from_posix_acl(inode, user_ns,
+						acl, composed_filesec,
+						HFSPLUS_MAX_INLINE_DATA_SIZE,
+						type);
+	if (err) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, err);
+		goto failed_conversion;
+	}
+
+	return composed_filesec;
+
+failed_conversion:
+	kfree(composed_filesec);
+	return ERR_PTR(err);
+}
+
+struct posix_acl *hfsplus_get_acl(struct inode *inode, int type)
+{
+	struct posix_acl *acl;
+	char *xattr_name;
+	char *value = NULL;
+	ssize_t size;
+
+	hfs_dbg(ACL_MOD,
+		"[%s]: ino %lu, type %#x\n",
+		__func__, inode->i_ino, type);
+
+	acl = get_cached_acl(inode, type);
+	if (acl != ACL_NOT_CACHED)
+		return acl;
+
+	switch (type) {
+	case ACL_TYPE_ACCESS:
+	case ACL_TYPE_DEFAULT:
+		xattr_name = HFSPLUS_XATTR_ACL_NAME;
+		break;
+	default:
+		return ERR_PTR(-EINVAL);
+	}
+
+	size = __hfsplus_getxattr(inode, xattr_name, NULL, 0);
+
+	if (size > 0) {
+		value = kzalloc(size, GFP_NOFS);
+		if (unlikely(!value)) {
+			hfs_dbg(ACL_MOD,
+				"(%s, %d): %s: err %d\n",
+				__FILE__, __LINE__, __func__, -ENOMEM);
+			return ERR_PTR(-ENOMEM);
+		}
+		size = __hfsplus_getxattr(inode, xattr_name, value, size);
+	}
+
+	if (size > 0)
+		acl = hfsplus_posix_acl_from_xattr(inode, &init_user_ns,
+							value, size, type);
+	else if (size == -ENODATA)
+		acl = NULL;
+	else {
+		acl = ERR_PTR(size);
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %zd\n",
+			__FILE__, __LINE__, __func__, size);
+	}
+
+	kfree(value);
+
+	if (!IS_ERR(acl))
+		set_cached_acl(inode, type, acl);
+
+	return acl;
+}
+
+static int hfsplus_set_acl(struct inode *inode, int type, struct posix_acl *acl)
+{
+	int err;
+	char *xattr_name = HFSPLUS_XATTR_ACL_NAME;
+	struct hfsplus_filesec *filesec = NULL;
+	size_t size = 0;
+	size_t ace_size = sizeof(struct hfsplus_acl_entry);
+
+	hfs_dbg(ACL_MOD,
+		"[%s]: ino %lu, type %#x, acl %p\n",
+		__func__, inode->i_ino, type, acl);
+
+	if (S_ISLNK(inode->i_mode)) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -EOPNOTSUPP);
+		return -EOPNOTSUPP;
+	}
+
+	switch (type) {
+	case ACL_TYPE_ACCESS:
+		if (acl) {
+			err = posix_acl_equiv_mode(acl, &inode->i_mode);
+			if (err < 0) {
+				hfs_dbg(ACL_MOD,
+					"(%s, %d): %s: err %d\n",
+					__FILE__, __LINE__, __func__, err);
+				return err;
+			}
+		}
+		err = 0;
+		break;
+
+	case ACL_TYPE_DEFAULT:
+		if (!S_ISDIR(inode->i_mode))
+			return acl ? -EACCES : 0;
+		break;
+
+	default:
+		return -EINVAL;
+	}
+
+	if (acl) {
+		filesec = hfsplus_posix_acl_to_filesec(inode, &init_user_ns,
+							acl, type);
+		if (unlikely(!filesec)) {
+			err = -ENOMEM;
+			hfs_dbg(ACL_MOD,
+				"(%s, %d): %s: err %d\n",
+				__FILE__, __LINE__, __func__, err);
+			goto end_set_acl;
+		} else if (IS_ERR(filesec)) {
+			err = PTR_ERR(filesec);
+			hfs_dbg(ACL_MOD,
+				"(%s, %d): %s: err %d\n",
+				__FILE__, __LINE__, __func__, err);
+			goto end_set_acl;
+		}
+
+		size = sizeof(struct hfsplus_filesec) +
+			(be32_to_cpu(filesec->fsec_acl.acl_entrycount) *
+				ace_size);
+		if (unlikely(size > HFSPLUS_MAX_INLINE_DATA_SIZE)) {
+			err = -ENOMEM;
+			hfs_dbg(ACL_MOD,
+				"(%s, %d): %s: err %d\n",
+				__FILE__, __LINE__, __func__, err);
+			goto end_set_acl;
+		}
+	}
+
+	err = __hfsplus_setxattr(inode, xattr_name, filesec, size, 0);
+	if (unlikely(err)) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, err);
+	}
+
+end_set_acl:
+	kfree(filesec);
+
+	if (!err)
+		set_cached_acl(inode, type, acl);
+
+	return err;
+}
+
+int hfsplus_init_acl(struct inode *inode, struct inode *dir)
+{
+	int err = 0;
+	struct posix_acl *acl = NULL;
+
+	hfs_dbg(ACL_MOD,
+		"[%s]: ino %lu, dir->ino %lu\n",
+		__func__, inode->i_ino, dir->i_ino);
+
+	if (S_ISLNK(inode->i_mode))
+		return 0;
+
+	acl = hfsplus_get_acl(dir, ACL_TYPE_DEFAULT);
+	if (IS_ERR(acl)) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %ld\n",
+			__FILE__, __LINE__, __func__, PTR_ERR(acl));
+		return PTR_ERR(acl);
+	}
+
+	if (acl) {
+		if (S_ISDIR(inode->i_mode)) {
+			err = hfsplus_set_acl(inode, ACL_TYPE_DEFAULT, acl);
+			if (unlikely(err)) {
+				hfs_dbg(ACL_MOD,
+					"(%s, %d): %s: err %d\n",
+					__FILE__, __LINE__, __func__, err);
+				goto init_acl_cleanup;
+			}
+		}
+
+		err = posix_acl_create(&acl, GFP_NOFS, &inode->i_mode);
+		if (unlikely(err < 0)) {
+			hfs_dbg(ACL_MOD,
+				"(%s, %d): %s: err %d\n",
+				__FILE__, __LINE__, __func__, err);
+			return err;
+		}
+
+		if (err > 0) {
+			err = hfsplus_set_acl(inode, ACL_TYPE_ACCESS, acl);
+			if (unlikely(err)) {
+				hfs_dbg(ACL_MOD,
+					"(%s, %d): %s: err %d\n",
+					__FILE__, __LINE__, __func__, err);
+			}
+		}
+	} else
+		inode->i_mode &= ~current_umask();
+
+init_acl_cleanup:
+	posix_acl_release(acl);
+	return err;
+}
+
+int hfsplus_acl_chmod(struct inode *inode)
+{
+	int err;
+	struct posix_acl *acl;
+
+	hfs_dbg(ACL_MOD, "[%s]: ino %lu\n", __func__, inode->i_ino);
+
+	if (S_ISLNK(inode->i_mode)) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -EOPNOTSUPP);
+		return -EOPNOTSUPP;
+	}
+
+	acl = hfsplus_get_acl(inode, ACL_TYPE_ACCESS);
+	if (IS_ERR(acl) || !acl) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %ld\n",
+			__FILE__, __LINE__, __func__, PTR_ERR(acl));
+		return PTR_ERR(acl);
+	}
+
+	err = posix_acl_chmod(&acl, GFP_KERNEL, inode->i_mode);
+	if (unlikely(err)) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, err);
+		return err;
+	}
+
+	err = hfsplus_set_acl(inode, ACL_TYPE_ACCESS, acl);
+	if (unlikely(err)) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, err);
+	}
+
+	posix_acl_release(acl);
+	return err;
+}
+
+static int hfsplus_xattr_get_acl(struct dentry *dentry,
+					const char *name,
+					void *buffer,
+					size_t size,
+					int type)
+{
+	int res = 0;
+	struct posix_acl *acl;
+
+	hfs_dbg(ACL_MOD,
+		"[%s]: ino %lu, buffer %p, size %zu, type %#x\n",
+		__func__, dentry->d_inode->i_ino, buffer, size, type);
+
+	if (strcmp(name, "") != 0) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -EINVAL);
+		return -EINVAL;
+	}
+
+	acl = hfsplus_get_acl(dentry->d_inode, type);
+	if (IS_ERR(acl)) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %ld\n",
+			__FILE__, __LINE__, __func__, PTR_ERR(acl));
+		return PTR_ERR(acl);
+	}
+	if (acl == NULL) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -ENODATA);
+		return -ENODATA;
+	}
+
+	res = posix_acl_to_xattr(&init_user_ns, acl, buffer, size);
+	hfs_dbg(ACL_MOD, "[%s]: real_size %d\n", __func__, res);
+
+	posix_acl_release(acl);
+	return res;
+}
+
+static int hfsplus_xattr_set_acl(struct dentry *dentry,
+					const char *name,
+					const void *value,
+					size_t size,
+					int flags,
+					int type)
+{
+	int err = 0;
+	struct inode *inode = dentry->d_inode;
+	struct posix_acl *acl = NULL;
+
+	hfs_dbg(ACL_MOD,
+		"[%s]: ino %lu, value %p, size %zu, flags %#x, type %#x\n",
+		__func__, inode->i_ino, value, size, flags, type);
+
+	if (strcmp(name, "") != 0) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -EINVAL);
+		return -EINVAL;
+	}
+
+	if (!inode_owner_or_capable(inode)) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, -EPERM);
+		return -EPERM;
+	}
+
+	if (value) {
+		acl = posix_acl_from_xattr(&init_user_ns, value, size);
+		if (IS_ERR(acl)) {
+			hfs_dbg(ACL_MOD,
+				"(%s, %d): %s: err %ld\n",
+				__FILE__, __LINE__, __func__, PTR_ERR(acl));
+			return PTR_ERR(acl);
+		} else if (acl) {
+			err = posix_acl_valid(acl);
+			if (err) {
+				hfs_dbg(ACL_MOD,
+					"(%s, %d): %s: err %d\n",
+					__FILE__, __LINE__, __func__, err);
+				goto end_xattr_set_acl;
+			}
+		}
+	}
+
+	err = hfsplus_set_acl(inode, type, acl);
+	if (unlikely(err)) {
+		hfs_dbg(ACL_MOD,
+			"(%s, %d): %s: err %d\n",
+			__FILE__, __LINE__, __func__, err);
+	}
+
+end_xattr_set_acl:
+	posix_acl_release(acl);
+	return err;
+}
+
+static size_t hfsplus_xattr_list_acl(struct dentry *dentry, char *list,
+		size_t list_size, const char *name, size_t name_len, int type)
+{
+	/*
+	 * This method is not used.
+	 * It is used hfsplus_listxattr() instead of generic_listxattr().
+	 */
+	return -EOPNOTSUPP;
+}
+
+const struct xattr_handler hfsplus_xattr_acl_access_handler = {
+	.prefix	= POSIX_ACL_XATTR_ACCESS,
+	.flags	= ACL_TYPE_ACCESS,
+	.list	= hfsplus_xattr_list_acl,
+	.get	= hfsplus_xattr_get_acl,
+	.set	= hfsplus_xattr_set_acl,
+};
+
+const struct xattr_handler hfsplus_xattr_acl_default_handler = {
+	.prefix	= POSIX_ACL_XATTR_DEFAULT,
+	.flags	= ACL_TYPE_DEFAULT,
+	.list	= hfsplus_xattr_list_acl,
+	.get	= hfsplus_xattr_get_acl,
+	.set	= hfsplus_xattr_set_acl,
+};
diff --git a/fs/hfsplus/acl.h b/fs/hfsplus/acl.h
new file mode 100644
index 0000000..a2efb9d
--- /dev/null
+++ b/fs/hfsplus/acl.h
@@ -0,0 +1,96 @@
+/*
+ * linux/fs/hfsplus/acl.h
+ *
+ * Vyacheslav Dubeyko <slava@dubeyko.com>
+ *
+ * Handler for Posix Access Control Lists (ACLs) support.
+ */
+
+#ifndef _LINUX_HFSPLUS_ACL_H
+#define _LINUX_HFSPLUS_ACL_H
+
+#include <linux/nfs4acl.h>
+#include <linux/posix_acl_xattr.h>
+
+/* HFS+ Access Control List Entry (ACE) flags */
+#define HFSPLUS_ACE_KINDMASK		0xf
+#define HFSPLUS_ACE_PERMIT		1
+#define HFSPLUS_ACE_DENY		2
+#define HFSPLUS_ACE_AUDIT		3
+#define HFSPLUS_ACE_ALARM		4
+#define HFSPLUS_ACE_INHERITED		(1<<4)
+#define HFSPLUS_ACE_FILE_INHERIT	(1<<5)
+#define HFSPLUS_ACE_DIRECTORY_INHERIT	(1<<6)
+#define HFSPLUS_ACE_LIMIT_INHERIT	(1<<7)
+#define HFSPLUS_ACE_ONLY_INHERIT	(1<<8)
+#define HFSPLUS_ACE_SUCCESS		(1<<9)
+#define HFSPLUS_ACE_FAILURE		(1<<10)
+
+/* All flag bits controlling ACE inheritance */
+#define HFSPLUS_ACE_INHERIT_CONTROL_FLAGS \
+		(HFSPLUS_ACE_FILE_INHERIT | \
+		 HFSPLUS_ACE_DIRECTORY_INHERIT | \
+		 HFSPLUS_ACE_LIMIT_INHERIT | \
+		 HFSPLUS_ACE_ONLY_INHERIT)
+
+/* HFS+ Access Control List Entry (ACE) rights */
+#define HFSPLUS_VNODE_READ_DATA			(1<<1)
+#define HFSPLUS_VNODE_LIST_DIRECTORY		HFSPLUS_VNODE_READ_DATA
+#define HFSPLUS_VNODE_WRITE_DATA		(1<<2)
+#define HFSPLUS_VNODE_ADD_FILE			HFSPLUS_VNODE_WRITE_DATA
+#define HFSPLUS_VNODE_EXECUTE			(1<<3)
+#define HFSPLUS_VNODE_SEARCH			HFSPLUS_VNODE_EXECUTE
+#define HFSPLUS_VNODE_DELETE			(1<<4)
+#define HFSPLUS_VNODE_APPEND_DATA		(1<<5)
+#define HFSPLUS_VNODE_ADD_SUBDIRECTORY		HFSPLUS_VNODE_APPEND_DATA
+#define HFSPLUS_VNODE_DELETE_CHILD		(1<<6)
+#define HFSPLUS_VNODE_READ_ATTRIBUTES		(1<<7)
+#define HFSPLUS_VNODE_WRITE_ATTRIBUTES		(1<<8)
+#define HFSPLUS_VNODE_READ_EXTATTRIBUTES	(1<<9)
+#define HFSPLUS_VNODE_WRITE_EXTATTRIBUTES	(1<<10)
+#define HFSPLUS_VNODE_READ_SECURITY		(1<<11)
+#define HFSPLUS_VNODE_WRITE_SECURITY		(1<<12)
+#define HFSPLUS_VNODE_TAKE_OWNERSHIP		(1<<13)
+
+#define HFSPLUS_ACE_GENERIC_ALL			(1<<21)
+#define HFSPLUS_ACE_GENERIC_EXECUTE		(1<<22)
+#define HFSPLUS_ACE_GENERIC_WRITE		(1<<23)
+#define HFSPLUS_ACE_GENERIC_READ		(1<<24)
+
+#define HFSPLUS_VNODE_ANYONE_MODE (HFSPLUS_VNODE_READ_ATTRIBUTES | \
+					 HFSPLUS_VNODE_READ_EXTATTRIBUTES | \
+					 HFSPLUS_VNODE_READ_SECURITY)
+
+#define HFSPLUS_VNODE_GENERIC_READ_BITS (HFSPLUS_VNODE_READ_DATA | \
+					 HFSPLUS_VNODE_READ_ATTRIBUTES | \
+					 HFSPLUS_VNODE_READ_EXTATTRIBUTES | \
+					 HFSPLUS_VNODE_READ_SECURITY)
+
+#define HFSPLUS_VNODE_OWNER_MODE (HFSPLUS_VNODE_WRITE_ATTRIBUTES | \
+					 HFSPLUS_VNODE_WRITE_EXTATTRIBUTES | \
+					 HFSPLUS_VNODE_WRITE_SECURITY)
+
+#define HFSPLUS_VNODE_WRITE_MODE (HFSPLUS_VNODE_WRITE_DATA | \
+					  HFSPLUS_VNODE_APPEND_DATA | \
+					  HFSPLUS_VNODE_DELETE)
+
+#define HFSPLUS_VNODE_GENERIC_WRITE_BITS (HFSPLUS_VNODE_WRITE_DATA | \
+					  HFSPLUS_VNODE_APPEND_DATA | \
+					  HFSPLUS_VNODE_DELETE | \
+					  HFSPLUS_VNODE_DELETE_CHILD | \
+					  HFSPLUS_VNODE_WRITE_ATTRIBUTES | \
+					  HFSPLUS_VNODE_WRITE_EXTATTRIBUTES | \
+					  HFSPLUS_VNODE_WRITE_SECURITY)
+
+#define HFSPLUS_VNODE_GENERIC_EXECUTE_BITS (HFSPLUS_VNODE_EXECUTE)
+
+#define HFSPLUS_VNODE_GENERIC_ALL_BITS	(HFSPLUS_VNODE_GENERIC_READ_BITS | \
+					 HFSPLUS_VNODE_GENERIC_WRITE_BITS | \
+					 HFSPLUS_VNODE_GENERIC_EXECUTE_BITS)
+
+/* acl.c */
+struct posix_acl *hfsplus_get_acl(struct inode *inode, int type);
+int hfsplus_acl_chmod(struct inode *inode);
+int hfsplus_init_acl(struct inode *, struct inode *);
+
+#endif
-- 
1.7.9.5



