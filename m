Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oproxy7-pub.bluehost.com ([67.222.55.9]:43987 "HELO
	oproxy7-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752330Ab3EIQhz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 May 2013 12:37:55 -0400
Message-ID: <1368117468.5695.32.camel@slavad-ubuntu-12.04>
Subject: [PATCH v4 1/5] NFSv4: introduce interface of NFSv4 ACLs <-> POSIX
 ACLs mapping
From: Vyacheslav Dubeyko <slava@dubeyko.com>
To: Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        Hin-Tak Leung <htl10@users.sourceforge.net>,
        Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 09 May 2013 20:37:48 +0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Vyacheslav Dubeyko <slava@dubeyko.com>
Subject: [PATCH v4 1/5] NFSv4: introduce interface of NFSv4 ACLs <-> POSIX ACLs mapping

This patch introduces declarations of operations that can be specialized in concrete file system drivers with the purpose of using generalized code of mapping NFSv4 ACLs to POSIX ACLs and vice versa.

The include/linux/nfs4acl.h header file is created with the purpose of sharing declarations and structures that were moved from fs/nfsd/nfs4acl.c and fs/nfsd/acl.h. Moreover, this header file introduces declaration of operations (nfsv4_ace_operations, nfsv4_ace_flags_operations, nfsv4_acl_id_operations, nfsv4_acl_mapping_operations) that can be specialized in concrete file system driver in the case of necessity. Otherwise, it is possible to use generalized mapping code without operations specialization. And, finally, it is declared nfsv4_acl_info structure that includes operations, pointer on mapping NFSv4 ACL and pointer on special mapping environment of concrete file system.

Signed-off-by: Vyacheslav Dubeyko <slava@dubeyko.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@redhat.com>
CC: Al Viro <viro@zeniv.linux.org.uk>
CC: Christoph Hellwig <hch@infradead.org>
CC: Hin-Tak Leung <htl10@users.sourceforge.net>
---
 include/linux/nfs4acl.h |  300 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 300 insertions(+)
 create mode 100644 include/linux/nfs4acl.h

diff --git a/include/linux/nfs4acl.h b/include/linux/nfs4acl.h
new file mode 100644
index 0000000..a3bc765
--- /dev/null
+++ b/include/linux/nfs4acl.h
@@ -0,0 +1,300 @@
+/*
+ *  include/linux/nfs4acl.h
+ *
+ *  Declarations for mapping between NFSv4 and POSIX ACLs.
+ *
+ *  Copyright (c) 2002 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Marius Aamodt Eriksen <marius@umich.edu>
+ *  Jeff Sedlak <jsedlak@umich.edu>
+ *  J. Bruce Fields <bfields@umich.edu>
+ *  Vyacheslav Dubeyko <slava@dubeyko.com>
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the University nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef _LINUX_MAP_NFS4_ACL_H
+#define _LINUX_MAP_NFS4_ACL_H
+
+#include <linux/uidgid.h>
+#include <linux/posix_acl.h>
+#include <linux/nfs4.h>
+
+/* mode bit translations: */
+#define NFS4_READ_MODE (NFS4_ACE_READ_DATA)
+#define NFS4_WRITE_MODE (NFS4_ACE_WRITE_DATA | NFS4_ACE_APPEND_DATA)
+#define NFS4_EXECUTE_MODE NFS4_ACE_EXECUTE
+#define NFS4_ANYONE_MODE (NFS4_ACE_READ_ATTRIBUTES | NFS4_ACE_READ_ACL | \
+				NFS4_ACE_SYNCHRONIZE)
+#define NFS4_OWNER_MODE (NFS4_ACE_WRITE_ATTRIBUTES | NFS4_ACE_WRITE_ACL)
+
+/* We don't support these bits; insist they be neither allowed nor denied */
+#define NFS4_MASK_UNSUPP (NFS4_ACE_DELETE | NFS4_ACE_WRITE_OWNER \
+		| NFS4_ACE_READ_NAMED_ATTRS | NFS4_ACE_WRITE_NAMED_ATTRS)
+
+/* flags used to simulate posix default ACLs */
+#define NFS4_INHERITANCE_FLAGS (NFS4_ACE_FILE_INHERIT_ACE \
+		| NFS4_ACE_DIRECTORY_INHERIT_ACE)
+
+#define NFS4_SUPPORTED_FLAGS (NFS4_INHERITANCE_FLAGS \
+		| NFS4_ACE_INHERIT_ONLY_ACE \
+		| NFS4_ACE_IDENTIFIER_GROUP)
+
+#define MASK_EQUAL(mask1, mask2) \
+	(((mask1) & NFS4_ACE_MASK_ALL) == ((mask2) & NFS4_ACE_MASK_ALL))
+
+#define NFS4_ACL_TYPE_DEFAULT	0x01
+#define NFS4_ACL_DIR		0x02
+#define NFS4_ACL_OWNER		0x04
+
+struct nfsv4_acl_info;
+
+struct posix_acl_summary {
+	unsigned short owner;
+	unsigned short users;
+	unsigned short group;
+	unsigned short groups;
+	unsigned short other;
+	unsigned short mask;
+};
+
+/*
+ * While processing the NFSv4 ACE, this maintains bitmasks representing
+ * which permission bits have been allowed and which denied to a given
+ * entity: */
+struct posix_ace_state {
+	u32 allow;
+	u32 deny;
+};
+
+struct posix_user_ace_state {
+	union {
+		kuid_t uid;
+		kgid_t gid;
+	};
+	struct posix_ace_state perms;
+};
+
+struct posix_ace_state_array {
+	int n;
+	struct posix_user_ace_state aces[];
+};
+
+/*
+ * While processing the NFSv4 ACE, this maintains the partial permissions
+ * calculated so far: */
+
+struct posix_acl_state {
+	int empty;
+	struct posix_ace_state owner;
+	struct posix_ace_state group;
+	struct posix_ace_state other;
+	struct posix_ace_state everyone;
+	struct posix_ace_state mask; /* Deny unused in this case */
+	struct posix_ace_state_array *users;
+	struct posix_ace_state_array *groups;
+};
+
+/*
+ * struct nfsv4_ace_operations - get ACE and ACE's details
+ * @get_naces: get number of ACEs in ACL
+ * @get_ace: get ACE's pointer by index in ACL
+ * @get_access_mask: get ACE's access mask
+ * @ace_type_valid: check that ACE's type field contains supported flags
+ * @is_allowed_ace_type: check that ACE has permit type
+ * @is_acl_user_obj: check that ACE is ACL_USER_OBJ
+ * @is_acl_group_obj: check that ACE is ACL_GROUP_OBJ
+ * @is_acl_other: check that ACE is ACL_OTHER
+ * @is_acl_user: check that ACE is ACL_USER
+ * @is_acl_group: check that ACE is ACL_GROUP
+ */
+struct nfsv4_ace_operations {
+	uint32_t (*get_naces)(const void *nfsv4_acl);
+	void *(*get_ace)(const void *nfsv4_acl, uint32_t index);
+	uint32_t (*get_access_mask)(const void *nfsv4_ace);
+	bool (*ace_type_valid)(const void *nfsv4_ace);
+	bool (*is_allowed_ace_type)(const void *nfsv4_ace);
+	bool (*is_acl_user_obj)(const struct nfsv4_acl_info *nfsv4_acl_info,
+					const void *nfsv4_ace);
+	bool (*is_acl_group_obj)(const struct nfsv4_acl_info *nfsv4_acl_info,
+					const void *nfsv4_ace);
+	bool (*is_acl_other)(const struct nfsv4_acl_info *nfsv4_acl_info,
+					const void *nfsv4_ace);
+	bool (*is_acl_user)(const struct nfsv4_acl_info *nfsv4_acl_info,
+					const void *nfsv4_ace);
+	bool (*is_acl_group)(const struct nfsv4_acl_info *nfsv4_acl_info,
+					const void *nfsv4_ace);
+};
+
+/*
+ * struct nfsv4_ace_flags_operations - check and convert ACE's flags
+ * @ace_has_unknown_flags: check presence of unsupported flags
+ * @ace_has_inheritance_flags: check presence of inheritance flags
+ * @ace_inherit_only_flag: check presence of INHERIT_ONLY_ACE flag
+ * @check_deny: check possibility to compose deny ACE
+ * @low_mode_from_nfs4: convert permissions from NFSv4 ACE into POSIX ACE
+ * @calculate_eflag: calculate effective flag
+ */
+struct nfsv4_ace_flags_operations {
+	bool (*ace_has_unknown_flags)(const void *nfsv4_ace);
+	bool (*ace_has_inheritance_flags)(const void *nfsv4_ace);
+	bool (*ace_inherit_only_flag)(const void *nfsv4_ace);
+	int (*check_deny)(u32 mask, int isowner);
+	void (*low_mode_from_nfs4)(u32 perm, unsigned short *mode,
+						unsigned int flags);
+	unsigned int (*calculate_eflag)(unsigned int flags);
+};
+
+/*
+ * struct nfsv4_acl_id_operations - UID/GID operations
+ * @find_uid: find UID for requested ACE in posix_acl_state
+ * @find_gid: find GID for requested ACE in posix_acl_state
+ * @set_posix_ace_uid: set UID in POSIX ACE
+ * @set_posix_ace_gid: set GID in POSIX ACE
+ */
+struct nfsv4_acl_id_operations {
+	int (*find_uid)(struct posix_acl_state *state, const void *nfsv4_ace);
+	int (*find_gid)(struct posix_acl_state *state, const void *nfsv4_ace);
+	int (*set_posix_ace_uid)(struct user_namespace *user_ns,
+				    struct posix_acl_entry *pace,
+				    kuid_t uid);
+	int (*set_posix_ace_gid)(struct user_namespace *user_ns,
+				    struct posix_acl_entry *pace,
+				    kgid_t gid);
+};
+
+/*
+ * struct nfsv4_acl_mapping_operations - mapping operations
+ * @prepare_nfsv4_acl_mapping: prepare environment for mapping operation
+ * @mask_from_posix: compose permit NFSv4 ACE permissions from POSIX ACE
+ * @deny_mask_from_posix: compose deny NFSv4 ACE permissions from POSIX ACE
+ * @map_owner_ace: map owner POSIX ACE to permit/deny NFSv4 ACE
+ * @map_user_ace: map user POSIX ACE to permit/deny NFSv4 ACE
+ * @map_group_owner_deny_ace: map group owner POSIX ACE to deny NFSv4 ACE
+ * @map_group_owner_permit_ace: map group owner POSIX ACE to permit NFSv4 ACE
+ * @map_group_deny_ace: map group POSIX ACE to deny NFSv4 ACE
+ * @map_group_permit_ace: map group POSIX ACE to permit NFSv4 ACE
+ * @map_everyone_permit_ace: map everyone POSIX ACE to permit NFSv4 ACE
+ */
+struct nfsv4_acl_mapping_operations {
+	int (*prepare_nfsv4_acl_mapping)(struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace);
+	u32 (*mask_from_posix)(struct nfsv4_acl_info *nfsv4_acl_info,
+				unsigned short perm,
+				unsigned int flags);
+	u32 (*deny_mask_from_posix)(struct nfsv4_acl_info *nfsv4_acl_info,
+				unsigned short perm,
+				unsigned int flags);
+	int (*map_owner_ace)(struct user_namespace *user_ns,
+				unsigned int eflag,
+				unsigned int flags,
+				unsigned short deny,
+				struct posix_acl_entry *pa,
+				struct posix_acl_summary *pas,
+				struct nfsv4_acl_info *nfsv4_acl_info,
+				void **nfsv4_ace);
+	int (*map_user_ace)(struct user_namespace *user_ns,
+				unsigned int eflag,
+				unsigned int flags,
+				unsigned short deny,
+				struct posix_acl_entry *pa,
+				struct posix_acl_summary *pas,
+				struct nfsv4_acl_info *nfsv4_acl_info,
+				void **nfsv4_ace);
+	int (*map_group_owner_deny_ace)(struct user_namespace *user_ns,
+					unsigned int eflag,
+					unsigned int flags,
+					unsigned short deny,
+					struct posix_acl_entry *pa,
+					struct posix_acl_summary *pas,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace);
+	int (*map_group_owner_permit_ace)(struct user_namespace *user_ns,
+					unsigned int eflag,
+					unsigned int flags,
+					unsigned short deny,
+					struct posix_acl_entry *pa,
+					struct posix_acl_summary *pas,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace);
+	int (*map_group_deny_ace)(struct user_namespace *user_ns,
+					unsigned int eflag,
+					unsigned int flags,
+					unsigned short deny,
+					struct posix_acl_entry *pa,
+					struct posix_acl_summary *pas,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace);
+	int (*map_group_permit_ace)(struct user_namespace *user_ns,
+					unsigned int eflag,
+					unsigned int flags,
+					unsigned short deny,
+					struct posix_acl_entry *pa,
+					struct posix_acl_summary *pas,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace);
+	int (*map_everyone_permit_ace)(unsigned int eflag,
+					unsigned int flags,
+					struct posix_acl_entry *pa,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace);
+};
+
+/*
+ * struct nfsv4_acl_info
+ * @ace_ops: get ACE and ACE's details operations
+ * @flags_ops: check and convert ACE's flags operations
+ * @id_ops: UID/GID operations
+ * @mapping_ops: mapping operations
+ * @raw_acl: pointer on NFSv4 ACL
+ * @private: pointer on concrete filesystem's mapping environment
+ */
+struct nfsv4_acl_info {
+	struct nfsv4_ace_operations *ace_ops;
+	struct nfsv4_ace_flags_operations *flags_ops;
+	struct nfsv4_acl_id_operations *id_ops;
+	struct nfsv4_acl_mapping_operations *mapping_ops;
+	void *raw_acl;
+	void *private;
+};
+
+short ace2type(const struct nfs4_ace *);
+int map_posix_acl_to_nfsv4_one(struct user_namespace *user_ns,
+				struct posix_acl *pacl,
+				struct nfsv4_acl_info *nfsv4_acl_info,
+				unsigned int flags);
+int map_nfsv4_acl_to_posix(struct user_namespace *user_ns,
+			    struct nfsv4_acl_info *nfsv4_acl_info,
+			    struct posix_acl **pacl,
+			    struct posix_acl **dpacl,
+			    unsigned int flags);
+struct nfs4_acl *nfs4_acl_posix_to_nfsv4(struct posix_acl *,
+				struct posix_acl *, unsigned int flags);
+int nfs4_acl_nfsv4_to_posix(struct nfs4_acl *, struct posix_acl **,
+				struct posix_acl **, unsigned int flags);
+
+#endif /* _LINUX_MAP_NFS4_ACL_H */
-- 
1.7.9.5



