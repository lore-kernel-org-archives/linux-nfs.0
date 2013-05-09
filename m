Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oproxy14-pub.unifiedlayer.com ([67.222.51.224]:60574 "HELO
	oproxy14-pub.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754518Ab3EIQlS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 May 2013 12:41:18 -0400
Message-ID: <1368117491.5695.33.camel@slavad-ubuntu-12.04>
Subject: [PATCH v4 2/5] nfsd: introduce generalization of NFSv4 ACLs <->
 POSIX ACLs mapping algorithms
From: Vyacheslav Dubeyko <slava@dubeyko.com>
To: Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        Hin-Tak Leung <htl10@users.sourceforge.net>,
        Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 09 May 2013 20:38:11 +0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Vyacheslav Dubeyko <slava@dubeyko.com>
Subject: [PATCH v4 2/5] nfsd: introduce generalization of NFSv4 ACLs <-> POSIX ACLs mapping algorithms

This patch introduces generalization of mapping algorithms from NFSv4 ACLs to POSIX ACLs and vice versa. The essence of mapping algorithms (located in fs/nfsd/nfs4acl.c, previously) were generalized and moved in fs/nfs4acl.c with the purpose of sharing between file system drivers.

A concrete file system driver can use mapping code by means of map_posix_acl_to_nfsv4_one(), map_nfsv4_acl_to_posix(), nfs4_acl_posix_to_nfsv4(), nfs4_acl_nfsv4_to_posix() methods. Also, it is possible to specialize internal mapping operations in the case of very special way of operations under raw structures for concrete file system driver case.

Signed-off-by: Vyacheslav Dubeyko <slava@dubeyko.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@redhat.com>
CC: Al Viro <viro@zeniv.linux.org.uk>
CC: Christoph Hellwig <hch@infradead.org>
CC: Hin-Tak Leung <htl10@users.sourceforge.net>
---
 fs/Makefile       |    2 +-
 fs/nfs4acl.c      | 1261 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/acl.h     |   11 +-
 fs/nfsd/nfs4acl.c |  782 ++-------------------------------
 4 files changed, 1303 insertions(+), 753 deletions(-)
 create mode 100644 fs/nfs4acl.c

diff --git a/fs/Makefile b/fs/Makefile
index 4fe6df3..1aa279f 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -11,7 +11,7 @@ obj-y :=	open.o read_write.o file_table.o super.o \
 		attr.o bad_inode.o file.o filesystems.o namespace.o \
 		seq_file.o xattr.o libfs.o fs-writeback.o \
 		pnode.o splice.o sync.o utimes.o \
-		stack.o fs_struct.o statfs.o
+		stack.o fs_struct.o statfs.o nfs4acl.o
 
 ifeq ($(CONFIG_BLOCK),y)
 obj-y +=	buffer.o bio.o block_dev.o direct-io.o mpage.o ioprio.o
diff --git a/fs/nfs4acl.c b/fs/nfs4acl.c
new file mode 100644
index 0000000..df5a90d
--- /dev/null
+++ b/fs/nfs4acl.c
@@ -0,0 +1,1261 @@
+/*
+ *  Common NFSv4 ACL handling code.
+ *
+ *  Copyright (c) 2002, 2003 The Regents of the University of Michigan.
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
+#include <linux/fs.h>
+#include <linux/nfs4acl.h>
+#include <linux/export.h>
+
+static inline u32 nfsv4_mask_from_posix(unsigned short perm,
+					unsigned int flags);
+static inline u32 nfsv4_deny_mask_from_posix(unsigned short perm,
+						unsigned int flags);
+
+static inline unsigned int nfsv4_calculate_eflag(unsigned int flags)
+{
+	return (flags & NFS4_ACL_TYPE_DEFAULT) ?
+		NFS4_INHERITANCE_FLAGS | NFS4_ACE_INHERIT_ONLY_ACE : 0;
+}
+
+static inline unsigned int __calculate_eflag(
+				const struct nfsv4_acl_info *nfsv4_acl_info,
+				unsigned int flags)
+{
+	struct nfsv4_ace_flags_operations *flags_ops = NULL;
+
+	BUG_ON(!nfsv4_acl_info);
+	flags_ops = nfsv4_acl_info->flags_ops;
+
+	if (flags_ops && flags_ops->calculate_eflag)
+		return flags_ops->calculate_eflag(flags);
+
+	return nfsv4_calculate_eflag(flags);
+}
+
+static inline int nfsv4_prepare_nfsv4_acl_mapping(
+				struct nfsv4_acl_info *nfsv4_acl_info,
+				void **nfsv4_ace)
+{
+	struct nfs4_acl *acl = (struct nfs4_acl *)nfsv4_acl_info->raw_acl;
+
+	BUG_ON(*nfsv4_ace != NULL);
+	*nfsv4_ace = (void *)(acl->aces + acl->naces);
+
+	return 0;
+}
+
+static inline int __prepare_nfsv4_acl_mapping(
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace)
+{
+	struct nfsv4_acl_mapping_operations *mapping_ops = NULL;
+
+	BUG_ON(!nfsv4_acl_info);
+	mapping_ops = nfsv4_acl_info->mapping_ops;
+
+	if (mapping_ops && mapping_ops->prepare_nfsv4_acl_mapping)
+		return mapping_ops->prepare_nfsv4_acl_mapping(nfsv4_acl_info,
+								nfsv4_ace);
+
+	return nfsv4_prepare_nfsv4_acl_mapping(nfsv4_acl_info, nfsv4_ace);
+}
+
+static int nfsv4_map_owner_ace(struct user_namespace *user_ns,
+				unsigned int eflag,
+				unsigned int flags,
+				unsigned short deny,
+				struct posix_acl_entry *pa,
+				struct posix_acl_summary *pas,
+				struct nfsv4_acl_info *nfsv4_acl_info,
+				void **nfsv4_ace)
+{
+	struct nfs4_acl *acl = (struct nfs4_acl *)nfsv4_acl_info->raw_acl;
+	struct nfs4_ace *ace = *(struct nfs4_ace **)nfsv4_ace;
+
+	BUG_ON(ace == NULL || pa == NULL);
+
+	if (deny) {
+		ace->type = NFS4_ACE_ACCESS_DENIED_ACE_TYPE;
+		ace->flag = eflag;
+		ace->access_mask = nfsv4_deny_mask_from_posix(deny, flags);
+		ace->whotype = NFS4_ACL_WHO_OWNER;
+		*nfsv4_ace = (void *)(++ace);
+		acl->naces++;
+	}
+
+	ace->type = NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE;
+	ace->flag = eflag;
+	ace->access_mask = nfsv4_mask_from_posix(pa->e_perm,
+						flags | NFS4_ACL_OWNER);
+	ace->whotype = NFS4_ACL_WHO_OWNER;
+	*nfsv4_ace = (void *)(++ace);
+	acl->naces++;
+
+	return 0;
+}
+
+static int nfsv4_map_user_ace(struct user_namespace *user_ns,
+				unsigned int eflag,
+				unsigned int flags,
+				unsigned short deny,
+				struct posix_acl_entry *pa,
+				struct posix_acl_summary *pas,
+				struct nfsv4_acl_info *nfsv4_acl_info,
+				void **nfsv4_ace)
+{
+	struct nfs4_acl *acl = (struct nfs4_acl *)nfsv4_acl_info->raw_acl;
+	struct nfs4_ace *ace = *(struct nfs4_ace **)nfsv4_ace;
+
+	BUG_ON(ace == NULL || pa == NULL || pas == NULL);
+
+	if (deny) {
+		ace->type = NFS4_ACE_ACCESS_DENIED_ACE_TYPE;
+		ace->flag = eflag;
+		ace->access_mask = nfsv4_deny_mask_from_posix(deny, flags);
+		ace->whotype = NFS4_ACL_WHO_NAMED;
+		ace->who_uid = pa->e_uid;
+		*nfsv4_ace = (void *)(++ace);
+		acl->naces++;
+	}
+
+	ace->type = NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE;
+	ace->flag = eflag;
+	ace->access_mask = nfsv4_mask_from_posix(pa->e_perm & pas->mask,
+							flags);
+	ace->whotype = NFS4_ACL_WHO_NAMED;
+	ace->who_uid = pa->e_uid;
+	*nfsv4_ace = (void *)(++ace);
+	acl->naces++;
+
+	return 0;
+}
+
+static int nfsv4_map_group_owner_deny_ace(struct user_namespace *user_ns,
+					unsigned int eflag,
+					unsigned int flags,
+					unsigned short deny,
+					struct posix_acl_entry *pa,
+					struct posix_acl_summary *pas,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace)
+{
+	struct nfs4_acl *acl = (struct nfs4_acl *)nfsv4_acl_info->raw_acl;
+	struct nfs4_ace *ace = *(struct nfs4_ace **)nfsv4_ace;
+
+	BUG_ON(ace == NULL);
+
+	if (deny) {
+		ace->type = NFS4_ACE_ACCESS_DENIED_ACE_TYPE;
+		ace->flag = eflag;
+		ace->access_mask = nfsv4_deny_mask_from_posix(deny, flags);
+		ace->whotype = NFS4_ACL_WHO_GROUP;
+		*nfsv4_ace = (void *)(++ace);
+		acl->naces++;
+	}
+
+	return 0;
+}
+
+static int nfsv4_map_group_owner_permit_ace(struct user_namespace *user_ns,
+					unsigned int eflag,
+					unsigned int flags,
+					unsigned short deny,
+					struct posix_acl_entry *pa,
+					struct posix_acl_summary *pas,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace)
+{
+	struct nfs4_acl *acl = (struct nfs4_acl *)nfsv4_acl_info->raw_acl;
+	struct nfs4_ace *ace = *(struct nfs4_ace **)nfsv4_ace;
+
+	BUG_ON(ace == NULL || pas == NULL);
+
+	ace->type = NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE;
+	ace->flag = eflag;
+	ace->access_mask = nfsv4_mask_from_posix(pas->group, flags);
+	ace->whotype = NFS4_ACL_WHO_GROUP;
+	*nfsv4_ace = (void *)(++ace);
+	acl->naces++;
+
+	return 0;
+}
+
+static int nfsv4_map_group_deny_ace(struct user_namespace *user_ns,
+					unsigned int eflag,
+					unsigned int flags,
+					unsigned short deny,
+					struct posix_acl_entry *pa,
+					struct posix_acl_summary *pas,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace)
+{
+	struct nfs4_acl *acl = (struct nfs4_acl *)nfsv4_acl_info->raw_acl;
+	struct nfs4_ace *ace = *(struct nfs4_ace **)nfsv4_ace;
+
+	BUG_ON(ace == NULL || pa == NULL);
+
+	if (deny) {
+		ace->type = NFS4_ACE_ACCESS_DENIED_ACE_TYPE;
+		ace->flag = eflag | NFS4_ACE_IDENTIFIER_GROUP;
+		ace->access_mask = nfsv4_deny_mask_from_posix(deny, flags);
+		ace->whotype = NFS4_ACL_WHO_NAMED;
+		ace->who_gid = pa->e_gid;
+		*nfsv4_ace = (void *)(++ace);
+		acl->naces++;
+	}
+
+	return 0;
+}
+
+static int nfsv4_map_group_permit_ace(struct user_namespace *user_ns,
+					unsigned int eflag,
+					unsigned int flags,
+					unsigned short deny,
+					struct posix_acl_entry *pa,
+					struct posix_acl_summary *pas,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace)
+{
+	struct nfs4_acl *acl = (struct nfs4_acl *)nfsv4_acl_info->raw_acl;
+	struct nfs4_ace *ace = *(struct nfs4_ace **)nfsv4_ace;
+
+	BUG_ON(ace == NULL || pa == NULL || pas == NULL);
+
+	ace->type = NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE;
+	ace->flag = eflag | NFS4_ACE_IDENTIFIER_GROUP;
+	ace->access_mask = nfsv4_mask_from_posix(pa->e_perm & pas->mask,
+							flags);
+	ace->whotype = NFS4_ACL_WHO_NAMED;
+	ace->who_gid = pa->e_gid;
+	*nfsv4_ace = (void *)(++ace);
+	acl->naces++;
+
+	return 0;
+}
+
+#define NFSV4_MAP_ACE_FNS(name) \
+static inline int __map_##name(struct user_namespace *user_ns, \
+					unsigned int eflag, \
+					unsigned int flags, \
+					unsigned short deny, \
+					struct posix_acl_entry *pa, \
+					struct posix_acl_summary *pas, \
+					struct nfsv4_acl_info *nfsv4_acl_info, \
+					void **nfsv4_ace) \
+{ \
+	struct nfsv4_acl_mapping_operations *mapping_ops = NULL; \
+	BUG_ON(!nfsv4_acl_info); \
+	mapping_ops = nfsv4_acl_info->mapping_ops; \
+	if (mapping_ops && mapping_ops->map_##name) \
+		return mapping_ops->map_##name(user_ns, eflag, \
+					flags, deny, pa, pas, \
+					nfsv4_acl_info, nfsv4_ace); \
+	return nfsv4_map_##name(user_ns, eflag, flags, deny, pa, pas, \
+					nfsv4_acl_info, nfsv4_ace); \
+}
+
+NFSV4_MAP_ACE_FNS(owner_ace)
+NFSV4_MAP_ACE_FNS(user_ace)
+NFSV4_MAP_ACE_FNS(group_owner_deny_ace)
+NFSV4_MAP_ACE_FNS(group_owner_permit_ace)
+NFSV4_MAP_ACE_FNS(group_deny_ace)
+NFSV4_MAP_ACE_FNS(group_permit_ace)
+
+static int nfsv4_map_everyone_permit_ace(unsigned int eflag,
+					unsigned int flags,
+					struct posix_acl_entry *pa,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace)
+{
+	struct nfs4_acl *acl = (struct nfs4_acl *)nfsv4_acl_info->raw_acl;
+	struct nfs4_ace *ace = *(struct nfs4_ace **)nfsv4_ace;
+
+	BUG_ON(ace == NULL || pa == NULL);
+
+	ace->type = NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE;
+	ace->flag = eflag;
+	ace->access_mask = nfsv4_mask_from_posix(pa->e_perm, flags);
+	ace->whotype = NFS4_ACL_WHO_EVERYONE;
+	acl->naces++;
+
+	return 0;
+}
+
+static inline int __map_everyone_permit_ace(unsigned int eflag,
+					unsigned int flags,
+					struct posix_acl_entry *pa,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					void **nfsv4_ace)
+{
+	struct nfsv4_acl_mapping_operations *mapping_ops = NULL;
+
+	BUG_ON(!nfsv4_acl_info);
+	mapping_ops = nfsv4_acl_info->mapping_ops;
+
+	if (mapping_ops && mapping_ops->map_everyone_permit_ace)
+		return mapping_ops->map_everyone_permit_ace(eflag, flags, pa,
+						nfsv4_acl_info, nfsv4_ace);
+	return nfsv4_map_everyone_permit_ace(eflag, flags, pa,
+						nfsv4_acl_info, nfsv4_ace);
+}
+
+static inline int nfsv4_set_posix_ace_uid(struct user_namespace *user_ns,
+					    struct posix_acl_entry *pace,
+					    kuid_t uid)
+{
+	pace->e_uid = uid;
+	return 0;
+}
+
+static inline int nfsv4_set_posix_ace_gid(struct user_namespace *user_ns,
+					    struct posix_acl_entry *pace,
+					    kgid_t gid)
+{
+	pace->e_gid = gid;
+	return 0;
+}
+
+static inline int __set_posix_ace_uid(struct user_namespace *user_ns,
+				const struct nfsv4_acl_info *nfsv4_acl_info,
+				struct posix_acl_entry *pace,
+				kuid_t id)
+{
+	struct nfsv4_acl_id_operations *id_ops = NULL;
+	BUG_ON(!nfsv4_acl_info);
+	id_ops = nfsv4_acl_info->id_ops;
+	if (id_ops && id_ops->set_posix_ace_uid)
+		return id_ops->set_posix_ace_uid(user_ns, pace, id);
+	return nfsv4_set_posix_ace_uid(user_ns, pace, id);
+}
+
+static inline int __set_posix_ace_gid(struct user_namespace *user_ns,
+				const struct nfsv4_acl_info *nfsv4_acl_info,
+				struct posix_acl_entry *pace,
+				kgid_t id)
+{
+	const struct nfsv4_acl_id_operations *id_ops = NULL;
+	BUG_ON(!nfsv4_acl_info);
+	id_ops = nfsv4_acl_info->id_ops;
+	if (id_ops && id_ops->set_posix_ace_gid)
+		return id_ops->set_posix_ace_gid(user_ns, pace, id);
+	return nfsv4_set_posix_ace_gid(user_ns, pace, id);
+}
+
+static inline uint32_t nfsv4_get_access_mask(const void *nfsv4_ace)
+{
+	const struct nfs4_ace *ace = (const struct nfs4_ace *)nfsv4_ace;
+	return ace->access_mask;
+}
+
+static inline uint32_t __get_access_mask(
+				const struct nfsv4_acl_info *nfsv4_acl_info,
+				const void *nfsv4_ace)
+{
+	struct nfsv4_ace_operations *ace_ops = NULL;
+
+	BUG_ON(!nfsv4_acl_info);
+	ace_ops = nfsv4_acl_info->ace_ops;
+
+	if (ace_ops && ace_ops->get_access_mask)
+		return ace_ops->get_access_mask(nfsv4_ace);
+
+	return nfsv4_get_access_mask(nfsv4_ace);
+}
+
+static inline bool nfsv4_is_acl_user_obj(const void *nfsv4_ace)
+{
+	const struct nfs4_ace *ace = (const struct nfs4_ace *)nfsv4_ace;
+	return ace2type(ace) == ACL_USER_OBJ;
+}
+
+static inline bool nfsv4_is_acl_group_obj(const void *nfsv4_ace)
+{
+	const struct nfs4_ace *ace = (const struct nfs4_ace *)nfsv4_ace;
+	return ace2type(ace) == ACL_GROUP_OBJ;
+}
+
+static inline bool nfsv4_is_acl_other(const void *nfsv4_ace)
+{
+	const struct nfs4_ace *ace = (const struct nfs4_ace *)nfsv4_ace;
+	return ace2type(ace) == ACL_OTHER;
+}
+
+static inline bool nfsv4_is_acl_user(const void *nfsv4_ace)
+{
+	const struct nfs4_ace *ace = (const struct nfs4_ace *)nfsv4_ace;
+	return ace2type(ace) == ACL_USER;
+}
+
+static inline bool nfsv4_is_acl_group(const void *nfsv4_ace)
+{
+	const struct nfs4_ace *ace = (const struct nfs4_ace *)nfsv4_ace;
+	return ace2type(ace) == ACL_GROUP;
+}
+
+#define NFSV4_ACE_OPS_FNS(name) \
+static inline bool __is_##name(const struct nfsv4_acl_info *nfsv4_acl_info, \
+				const void *nfsv4_ace) \
+{ \
+	struct nfsv4_ace_operations *ace_ops = NULL; \
+	BUG_ON(!nfsv4_acl_info); \
+	ace_ops = nfsv4_acl_info->ace_ops; \
+	if (ace_ops && ace_ops->is_##name) \
+		return ace_ops->is_##name(nfsv4_acl_info, nfsv4_ace); \
+	return nfsv4_is_##name(nfsv4_ace); \
+}
+
+NFSV4_ACE_OPS_FNS(acl_user_obj)
+NFSV4_ACE_OPS_FNS(acl_group_obj)
+NFSV4_ACE_OPS_FNS(acl_other)
+NFSV4_ACE_OPS_FNS(acl_user)
+NFSV4_ACE_OPS_FNS(acl_group)
+
+static inline bool nfsv4_is_allowed_ace_type(const void *nfsv4_ace)
+{
+	const struct nfs4_ace *ace = (const struct nfs4_ace *)nfsv4_ace;
+	return ace->type == NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE;
+}
+
+static inline bool __is_allowed_ace_type(
+				const struct nfsv4_acl_info *nfsv4_acl_info,
+				const void *nfsv4_ace)
+{
+	struct nfsv4_ace_operations *ace_ops = NULL;
+
+	BUG_ON(!nfsv4_acl_info);
+	ace_ops = nfsv4_acl_info->ace_ops;
+
+	if (ace_ops && ace_ops->is_allowed_ace_type)
+		return ace_ops->is_allowed_ace_type(nfsv4_ace);
+
+	return nfsv4_is_allowed_ace_type(nfsv4_ace);
+}
+
+static inline uint32_t nfsv4_get_naces(const void *nfsv4_acl)
+{
+	const struct nfs4_acl *acl = (const struct nfs4_acl *)nfsv4_acl;
+	return acl->naces;
+}
+
+static inline uint32_t __get_naces(const struct nfsv4_acl_info *nfsv4_acl_info)
+{
+	struct nfsv4_ace_operations *ace_ops = NULL;
+
+	BUG_ON(!nfsv4_acl_info);
+	ace_ops = nfsv4_acl_info->ace_ops;
+
+	if (ace_ops && ace_ops->get_naces)
+		return ace_ops->get_naces(nfsv4_acl_info->raw_acl);
+
+	return nfsv4_get_naces(nfsv4_acl_info->raw_acl);
+}
+
+static inline void *nfsv4_get_ace(const void *nfsv4_acl, uint32_t index)
+{
+	const struct nfs4_acl *acl = (const struct nfs4_acl *)nfsv4_acl;
+	return (void *)(acl->aces + index);
+}
+
+static inline void *__get_ace(const struct nfsv4_acl_info *nfsv4_acl_info,
+				uint32_t index)
+{
+	struct nfsv4_ace_operations *ace_ops = NULL;
+
+	BUG_ON(!nfsv4_acl_info);
+	ace_ops = nfsv4_acl_info->ace_ops;
+
+	if (ace_ops && ace_ops->get_ace)
+		return ace_ops->get_ace(nfsv4_acl_info->raw_acl, index);
+
+	return nfsv4_get_ace(nfsv4_acl_info->raw_acl, index);
+}
+
+static inline bool nfsv4_ace_type_valid(const void *nfsv4_ace)
+{
+	const struct nfs4_ace *ace = (const struct nfs4_ace *)nfsv4_ace;
+
+	return ace->type == NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE ||
+			ace->type == NFS4_ACE_ACCESS_DENIED_ACE_TYPE;
+}
+
+static inline bool __ace_type_valid(
+				const struct nfsv4_acl_info *nfsv4_acl_info,
+				const void *nfsv4_ace)
+{
+	struct nfsv4_ace_operations *ace_ops = NULL;
+
+	BUG_ON(!nfsv4_acl_info);
+	ace_ops = nfsv4_acl_info->ace_ops;
+
+	if (ace_ops && ace_ops->ace_type_valid)
+		return ace_ops->ace_type_valid(nfsv4_ace);
+
+	return nfsv4_ace_type_valid(nfsv4_ace);
+}
+
+static inline bool nfsv4_ace_has_unknown_flags(const void *nfsv4_ace)
+{
+	const struct nfs4_ace *ace = (const struct nfs4_ace *)nfsv4_ace;
+	return ace->flag & ~NFS4_SUPPORTED_FLAGS;
+}
+
+static inline bool nfsv4_ace_has_inheritance_flags(const void *nfsv4_ace)
+{
+	const struct nfs4_ace *ace = (const struct nfs4_ace *)nfsv4_ace;
+	return ace->flag & NFS4_INHERITANCE_FLAGS;
+}
+
+static inline bool nfsv4_ace_inherit_only_flag(const void *nfsv4_ace)
+{
+	const struct nfs4_ace *ace = (const struct nfs4_ace *)nfsv4_ace;
+	return ace->flag & NFS4_ACE_INHERIT_ONLY_ACE;
+}
+
+#define NFSV4_ACE_FLAGS_OPS_FNS(name) \
+static inline bool __ace_##name(const struct nfsv4_acl_info *nfsv4_acl_info, \
+				const void *nfsv4_ace) \
+{ \
+	struct nfsv4_ace_flags_operations *flags_ops = NULL; \
+	BUG_ON(!nfsv4_acl_info); \
+	flags_ops = nfsv4_acl_info->flags_ops; \
+	if (flags_ops && flags_ops->ace_##name) \
+		return flags_ops->ace_##name(nfsv4_ace); \
+	return nfsv4_ace_##name(nfsv4_ace); \
+}
+
+NFSV4_ACE_FLAGS_OPS_FNS(has_unknown_flags)
+NFSV4_ACE_FLAGS_OPS_FNS(has_inheritance_flags)
+NFSV4_ACE_FLAGS_OPS_FNS(inherit_only_flag)
+
+static inline u32 nfsv4_mask_from_posix(unsigned short perm,
+					unsigned int flags)
+{
+	int mask = NFS4_ANYONE_MODE;
+
+	if (flags & NFS4_ACL_OWNER)
+		mask |= NFS4_OWNER_MODE;
+	if (perm & ACL_READ)
+		mask |= NFS4_READ_MODE;
+	if (perm & ACL_WRITE)
+		mask |= NFS4_WRITE_MODE;
+	if ((perm & ACL_WRITE) && (flags & NFS4_ACL_DIR))
+		mask |= NFS4_ACE_DELETE_CHILD;
+	if (perm & ACL_EXECUTE)
+		mask |= NFS4_EXECUTE_MODE;
+	return mask;
+}
+
+static inline u32 nfsv4_deny_mask_from_posix(unsigned short perm,
+						unsigned int flags)
+{
+	u32 mask = 0;
+
+	if (perm & ACL_READ)
+		mask |= NFS4_READ_MODE;
+	if (perm & ACL_WRITE)
+		mask |= NFS4_WRITE_MODE;
+	if ((perm & ACL_WRITE) && (flags & NFS4_ACL_DIR))
+		mask |= NFS4_ACE_DELETE_CHILD;
+	if (perm & ACL_EXECUTE)
+		mask |= NFS4_EXECUTE_MODE;
+	return mask;
+}
+
+/* XXX: modify functions to return NFS errors; they're only ever
+ * used by nfs code, after all.... */
+
+/* We only map from NFSv4 to POSIX ACLs when setting ACLs, when we err on the
+ * side of being more restrictive, so the mode bit mapping below is
+ * pessimistic.  An optimistic version would be needed to handle DENY's,
+ * but we espect to coalesce all ALLOWs and DENYs before mapping to mode
+ * bits. */
+
+static void nfsv4_low_mode_from_nfs4(u32 perm, unsigned short *mode,
+						unsigned int flags)
+{
+	u32 write_mode = NFS4_WRITE_MODE;
+
+	if (flags & NFS4_ACL_DIR)
+		write_mode |= NFS4_ACE_DELETE_CHILD;
+	*mode = 0;
+	if ((perm & NFS4_READ_MODE) == NFS4_READ_MODE)
+		*mode |= ACL_READ;
+	if ((perm & write_mode) == write_mode)
+		*mode |= ACL_WRITE;
+	if ((perm & NFS4_EXECUTE_MODE) == NFS4_EXECUTE_MODE)
+		*mode |= ACL_EXECUTE;
+}
+
+static inline void __low_mode_from_nfs4(
+				const struct nfsv4_acl_info *nfsv4_acl_info,
+				u32 perm,
+				unsigned short *mode,
+				unsigned int flags)
+{
+	struct nfsv4_ace_flags_operations *flags_ops = NULL;
+
+	BUG_ON(!nfsv4_acl_info);
+	flags_ops = nfsv4_acl_info->flags_ops;
+
+	if (flags_ops && flags_ops->low_mode_from_nfs4)
+		return flags_ops->low_mode_from_nfs4(perm, mode, flags);
+
+	return nfsv4_low_mode_from_nfs4(perm, mode, flags);
+}
+
+static void summarize_posix_acl(struct posix_acl *acl,
+				struct posix_acl_summary *pas)
+{
+	struct posix_acl_entry *pa, *pe;
+
+	/*
+	 * Only pas.users and pas.groups need initialization; previous
+	 * posix_acl_valid() calls ensure that the other fields will be
+	 * initialized in the following loop.  But, just to placate gcc:
+	 */
+	memset(pas, 0, sizeof(*pas));
+	pas->mask = 07;
+
+	pe = acl->a_entries + acl->a_count;
+
+	FOREACH_ACL_ENTRY(pa, acl, pe) {
+		switch (pa->e_tag) {
+		case ACL_USER_OBJ:
+			pas->owner = pa->e_perm;
+			break;
+		case ACL_GROUP_OBJ:
+			pas->group = pa->e_perm;
+			break;
+		case ACL_USER:
+			pas->users |= pa->e_perm;
+			break;
+		case ACL_GROUP:
+			pas->groups |= pa->e_perm;
+			break;
+		case ACL_OTHER:
+			pas->other = pa->e_perm;
+			break;
+		case ACL_MASK:
+			pas->mask = pa->e_perm;
+			break;
+		}
+	}
+	/* We'll only care about effective permissions: */
+	pas->users &= pas->mask;
+	pas->group &= pas->mask;
+	pas->groups &= pas->mask;
+}
+
+/* We assume the acl has been verified with posix_acl_valid. */
+int map_posix_acl_to_nfsv4_one(struct user_namespace *user_ns,
+				struct posix_acl *pacl,
+				struct nfsv4_acl_info *nfsv4_acl_info,
+				unsigned int flags)
+{
+	struct posix_acl_entry *pa, *group_owner_entry;
+	void *nfs4_ace = NULL;
+	struct posix_acl_summary pas;
+	unsigned short deny;
+	int eflag = __calculate_eflag(nfsv4_acl_info, flags);
+	int ret = 0;
+
+	BUG_ON(pacl->a_count < 3);
+	summarize_posix_acl(pacl, &pas);
+
+	pa = pacl->a_entries;
+	ret = __prepare_nfsv4_acl_mapping(nfsv4_acl_info, &nfs4_ace);
+	if (unlikely(ret))
+		return ret;
+
+	/* We could deny everything not granted by the owner: */
+	deny = ~pas.owner;
+	/*
+	 * but it is equivalent (and simpler) to deny only what is not
+	 * granted by later entries:
+	 */
+	deny &= pas.users | pas.group | pas.groups | pas.other;
+
+	ret = __map_owner_ace(user_ns, eflag, flags, deny,
+				pa, &pas, nfsv4_acl_info, &nfs4_ace);
+	if (unlikely(ret))
+		return ret;
+	pa++;
+
+	while (pa->e_tag == ACL_USER) {
+		deny = ~(pa->e_perm & pas.mask);
+		deny &= pas.groups | pas.group | pas.other;
+		ret = __map_user_ace(user_ns, eflag, flags, deny,
+					pa, &pas, nfsv4_acl_info, &nfs4_ace);
+		if (unlikely(ret))
+			return ret;
+		pa++;
+	}
+
+	/* In the case of groups, we apply allow ACEs first, then deny ACEs,
+	 * since a user can be in more than one group.  */
+
+	/* allow ACEs */
+
+	group_owner_entry = pa;
+
+	ret = __map_group_owner_permit_ace(user_ns, eflag, flags, deny,
+					pa, &pas, nfsv4_acl_info, &nfs4_ace);
+	if (unlikely(ret))
+		return ret;
+	pa++;
+
+	while (pa->e_tag == ACL_GROUP) {
+		ret = __map_group_permit_ace(user_ns, eflag, flags, deny,
+					pa, &pas, nfsv4_acl_info, &nfs4_ace);
+		if (unlikely(ret))
+			return ret;
+		pa++;
+	}
+
+	/* deny ACEs */
+
+	pa = group_owner_entry;
+
+	deny = ~pas.group & pas.other;
+	ret = __map_group_owner_deny_ace(user_ns, eflag, flags, deny,
+					pa, &pas, nfsv4_acl_info, &nfs4_ace);
+	if (unlikely(ret))
+		return ret;
+	pa++;
+
+	while (pa->e_tag == ACL_GROUP) {
+		deny = ~(pa->e_perm & pas.mask);
+		deny &= pas.other;
+		ret = __map_group_deny_ace(user_ns, eflag, flags, deny,
+					pa, &pas, nfsv4_acl_info, &nfs4_ace);
+		if (unlikely(ret))
+			return ret;
+		pa++;
+	}
+
+	if (pa->e_tag == ACL_MASK)
+		pa++;
+	ret = __map_everyone_permit_ace(eflag, flags, pa,
+					nfsv4_acl_info, &nfs4_ace);
+
+	return ret;
+}
+EXPORT_SYMBOL(map_posix_acl_to_nfsv4_one);
+
+static bool pace_gt(struct posix_acl_entry *pace1,
+			struct posix_acl_entry *pace2)
+{
+	if (pace1->e_tag != pace2->e_tag)
+		return pace1->e_tag > pace2->e_tag;
+	if (pace1->e_tag == ACL_USER)
+		return uid_gt(pace1->e_uid, pace2->e_uid);
+	if (pace1->e_tag == ACL_GROUP)
+		return gid_gt(pace1->e_gid, pace2->e_gid);
+	return false;
+}
+
+static void sort_pacl_range(struct posix_acl *pacl, int start, int end)
+{
+	int sorted = 0, i;
+	struct posix_acl_entry tmp;
+
+	/* We just do a bubble sort; easy to do in place, and we're not
+	 * expecting acl's to be long enough to justify anything more. */
+	while (!sorted) {
+		sorted = 1;
+		for (i = start; i < end; i++) {
+			if (pace_gt(&pacl->a_entries[i],
+				    &pacl->a_entries[i+1])) {
+				sorted = 0;
+				tmp = pacl->a_entries[i];
+				pacl->a_entries[i] = pacl->a_entries[i+1];
+				pacl->a_entries[i+1] = tmp;
+			}
+		}
+	}
+}
+
+static void sort_pacl(struct posix_acl *pacl)
+{
+	/* posix_acl_valid requires that users and groups be in order
+	 * by uid/gid. */
+	int i, j;
+
+	if (pacl->a_count <= 4)
+		return; /* no users or groups */
+	i = 1;
+	while (pacl->a_entries[i].e_tag == ACL_USER)
+		i++;
+	sort_pacl_range(pacl, 1, i-1);
+
+	BUG_ON(pacl->a_entries[i].e_tag != ACL_GROUP_OBJ);
+	j = ++i;
+	while (pacl->a_entries[j].e_tag == ACL_GROUP)
+		j++;
+	sort_pacl_range(pacl, i, j-1);
+	return;
+}
+
+static int init_state(struct posix_acl_state *state, int cnt)
+{
+	int alloc;
+
+	memset(state, 0, sizeof(struct posix_acl_state));
+	state->empty = 1;
+	/*
+	 * In the worst case, each individual acl could be for a distinct
+	 * named user or group, but we don't no which, so we allocate
+	 * enough space for either:
+	 */
+	alloc = sizeof(struct posix_ace_state_array)
+		+ cnt*sizeof(struct posix_user_ace_state);
+	state->users = kzalloc(alloc, GFP_KERNEL);
+	if (!state->users)
+		return -ENOMEM;
+	state->groups = kzalloc(alloc, GFP_KERNEL);
+	if (!state->groups) {
+		kfree(state->users);
+		return -ENOMEM;
+	}
+	return 0;
+}
+
+static void free_state(struct posix_acl_state *state)
+{
+	kfree(state->users);
+	kfree(state->groups);
+}
+
+static inline void add_to_mask(struct posix_acl_state *state,
+				struct posix_ace_state *astate)
+{
+	state->mask.allow |= astate->allow;
+}
+
+/*
+ * Certain bits (SYNCHRONIZE, DELETE, WRITE_OWNER, READ/WRITE_NAMED_ATTRS,
+ * READ_ATTRIBUTES, READ_ACL) are currently unenforceable and don't translate
+ * to traditional read/write/execute permissions.
+ *
+ * It's problematic to reject acls that use certain mode bits, because it
+ * places the burden on users to learn the rules about which bits one
+ * particular server sets, without giving the user a lot of help--we return an
+ * error that could mean any number of different things.  To make matters
+ * worse, the problematic bits might be introduced by some application that's
+ * automatically mapping from some other acl model.
+ *
+ * So wherever possible we accept anything, possibly erring on the side of
+ * denying more permissions than necessary.
+ *
+ * However we do reject *explicit* DENY's of a few bits representing
+ * permissions we could never deny:
+ */
+
+static inline int nfsv4_check_deny(u32 mask, int isowner)
+{
+	if (mask & (NFS4_ACE_READ_ATTRIBUTES | NFS4_ACE_READ_ACL))
+		return -EINVAL;
+	if (!isowner)
+		return 0;
+	if (mask & (NFS4_ACE_WRITE_ATTRIBUTES | NFS4_ACE_WRITE_ACL))
+		return -EINVAL;
+	return 0;
+}
+
+static inline int __check_deny(const struct nfsv4_acl_info *nfsv4_acl_info,
+				u32 mask, int isowner)
+{
+	struct nfsv4_ace_flags_operations *flags_ops = NULL;
+
+	BUG_ON(!nfsv4_acl_info);
+	flags_ops = nfsv4_acl_info->flags_ops;
+
+	if (flags_ops && flags_ops->check_deny)
+		return flags_ops->check_deny(mask, isowner);
+
+	return nfsv4_check_deny(mask, isowner);
+}
+
+static struct posix_acl *posix_state_to_acl(struct user_namespace *user_ns,
+					struct nfsv4_acl_info *nfsv4_acl_info,
+					struct posix_acl_state *state,
+					unsigned int flags)
+{
+	struct posix_acl_entry *pace;
+	struct posix_acl *pacl;
+	int nace;
+	int i, error = 0;
+
+	/*
+	 * ACLs with no ACEs are treated differently in the inheritable
+	 * and effective cases: when there are no inheritable ACEs, we
+	 * set a zero-length default posix acl:
+	 */
+	if (state->empty && (flags & NFS4_ACL_TYPE_DEFAULT)) {
+		pacl = posix_acl_alloc(0, GFP_KERNEL);
+		return pacl ? pacl : ERR_PTR(-ENOMEM);
+	}
+	/*
+	 * When there are no effective ACEs, the following will end
+	 * up setting a 3-element effective posix ACL with all
+	 * permissions zero.
+	 */
+	nace = 4 + state->users->n + state->groups->n;
+	pacl = posix_acl_alloc(nace, GFP_KERNEL);
+	if (!pacl)
+		return ERR_PTR(-ENOMEM);
+
+	pace = pacl->a_entries;
+	pace->e_tag = ACL_USER_OBJ;
+	error = __check_deny(nfsv4_acl_info, state->owner.deny, 1);
+	if (error)
+		goto out_err;
+	__low_mode_from_nfs4(nfsv4_acl_info, state->owner.allow,
+				&pace->e_perm, flags);
+
+	for (i = 0; i < state->users->n; i++) {
+		pace++;
+		pace->e_tag = ACL_USER;
+		error = __check_deny(nfsv4_acl_info,
+				state->users->aces[i].perms.deny, 0);
+		if (error)
+			goto out_err;
+		__low_mode_from_nfs4(nfsv4_acl_info,
+					state->users->aces[i].perms.allow,
+					&pace->e_perm,
+					flags);
+		error = __set_posix_ace_uid(user_ns, nfsv4_acl_info, pace,
+						state->users->aces[i].uid);
+		if (error)
+			goto out_err;
+		add_to_mask(state, &state->users->aces[i].perms);
+	}
+
+	pace++;
+	pace->e_tag = ACL_GROUP_OBJ;
+	error = __check_deny(nfsv4_acl_info, state->group.deny, 0);
+	if (error)
+		goto out_err;
+	__low_mode_from_nfs4(nfsv4_acl_info, state->group.allow,
+				&pace->e_perm, flags);
+	add_to_mask(state, &state->group);
+
+	for (i = 0; i < state->groups->n; i++) {
+		pace++;
+		pace->e_tag = ACL_GROUP;
+		error = __check_deny(nfsv4_acl_info,
+					state->groups->aces[i].perms.deny, 0);
+		if (error)
+			goto out_err;
+		__low_mode_from_nfs4(nfsv4_acl_info,
+					state->groups->aces[i].perms.allow,
+					&pace->e_perm,
+					flags);
+		error = __set_posix_ace_gid(user_ns, nfsv4_acl_info, pace,
+						state->groups->aces[i].gid);
+		if (error)
+			goto out_err;
+		add_to_mask(state, &state->groups->aces[i].perms);
+	}
+
+	pace++;
+	pace->e_tag = ACL_MASK;
+	__low_mode_from_nfs4(nfsv4_acl_info, state->mask.allow,
+				&pace->e_perm, flags);
+
+	pace++;
+	pace->e_tag = ACL_OTHER;
+	error = __check_deny(nfsv4_acl_info, state->other.deny, 0);
+	if (error)
+		goto out_err;
+	__low_mode_from_nfs4(nfsv4_acl_info, state->other.allow,
+				&pace->e_perm, flags);
+
+	return pacl;
+out_err:
+	posix_acl_release(pacl);
+	return ERR_PTR(error);
+}
+
+static inline void allow_bits(struct posix_ace_state *astate, u32 mask)
+{
+	/* Allow all bits in the mask not already denied: */
+	astate->allow |= mask & ~astate->deny;
+}
+
+static void allow_bits_array(struct posix_ace_state_array *a, u32 mask)
+{
+	int i;
+
+	for (i = 0; i < a->n; i++)
+		allow_bits(&a->aces[i].perms, mask);
+}
+
+static inline void deny_bits(struct posix_ace_state *astate, u32 mask)
+{
+	/* Deny all bits in the mask not already allowed: */
+	astate->deny |= mask & ~astate->allow;
+}
+
+static void deny_bits_array(struct posix_ace_state_array *a, u32 mask)
+{
+	int i;
+
+	for (i = 0; i < a->n; i++)
+		deny_bits(&a->aces[i].perms, mask);
+}
+
+static int nfsv4_find_uid(struct posix_acl_state *state,
+					const void *nfsv4_ace)
+{
+	const struct nfs4_ace *ace = (const struct nfs4_ace *)nfsv4_ace;
+	struct posix_ace_state_array *a = state->users;
+	kuid_t uid = ace->who_uid;
+	int i;
+
+	for (i = 0; i < a->n; i++)
+		if (uid_eq(a->aces[i].uid, uid))
+			return i;
+	/* Not found: */
+	a->n++;
+	a->aces[i].uid = uid;
+	a->aces[i].perms.allow = state->everyone.allow;
+	a->aces[i].perms.deny  = state->everyone.deny;
+
+	return i;
+}
+
+static int nfsv4_find_gid(struct posix_acl_state *state,
+					const void *nfsv4_ace)
+{
+	const struct nfs4_ace *ace = (const struct nfs4_ace *)nfsv4_ace;
+	struct posix_ace_state_array *a = state->users;
+	kgid_t gid = ace->who_gid;
+	int i;
+
+	for (i = 0; i < a->n; i++)
+		if (gid_eq(a->aces[i].gid, gid))
+			return i;
+	/* Not found: */
+	a->n++;
+	a->aces[i].gid = gid;
+	a->aces[i].perms.allow = state->everyone.allow;
+	a->aces[i].perms.deny  = state->everyone.deny;
+
+	return i;
+}
+
+#define NFSV4_ACL_FIND_ID_FNS(name) \
+static inline int __find_##name(const struct nfsv4_acl_info *nfsv4_acl_info, \
+				struct posix_acl_state *state, \
+				const void *nfsv4_ace) \
+{ \
+	struct nfsv4_acl_id_operations *id_ops = NULL; \
+	BUG_ON(!nfsv4_acl_info); \
+	id_ops = nfsv4_acl_info->id_ops; \
+	if (id_ops && id_ops->find_##name) \
+		return id_ops->find_##name(state, nfsv4_ace); \
+	return nfsv4_find_##name(state, nfsv4_ace); \
+}
+
+NFSV4_ACL_FIND_ID_FNS(uid)
+NFSV4_ACL_FIND_ID_FNS(gid)
+
+static void process_one_v4_ace(struct nfsv4_acl_info *nfsv4_acl_info,
+				struct posix_acl_state *state,
+				const void *nfsv4_ace)
+{
+	u32 mask = __get_access_mask(nfsv4_acl_info, nfsv4_ace);
+	int i;
+
+	state->empty = 0;
+
+	if (__is_acl_user_obj(nfsv4_acl_info, nfsv4_ace)) {
+		if (__is_allowed_ace_type(nfsv4_acl_info, nfsv4_ace))
+			allow_bits(&state->owner, mask);
+		else
+			deny_bits(&state->owner, mask);
+	} else if (__is_acl_user(nfsv4_acl_info, nfsv4_ace)) {
+		i = __find_uid(nfsv4_acl_info, state, nfsv4_ace);
+		if (__is_allowed_ace_type(nfsv4_acl_info, nfsv4_ace))
+			allow_bits(&state->users->aces[i].perms, mask);
+		else {
+			deny_bits(&state->users->aces[i].perms, mask);
+			mask = state->users->aces[i].perms.deny;
+			deny_bits(&state->owner, mask);
+		}
+	} else if (__is_acl_group_obj(nfsv4_acl_info, nfsv4_ace)) {
+		if (__is_allowed_ace_type(nfsv4_acl_info, nfsv4_ace))
+			allow_bits(&state->group, mask);
+		else {
+			deny_bits(&state->group, mask);
+			mask = state->group.deny;
+			deny_bits(&state->owner, mask);
+			deny_bits(&state->everyone, mask);
+			deny_bits_array(state->users, mask);
+			deny_bits_array(state->groups, mask);
+		}
+	} else if (__is_acl_group(nfsv4_acl_info, nfsv4_ace)) {
+		i = __find_gid(nfsv4_acl_info, state, nfsv4_ace);
+		if (__is_allowed_ace_type(nfsv4_acl_info, nfsv4_ace)) {
+			allow_bits(&state->groups->aces[i].perms, mask);
+		} else {
+			deny_bits(&state->groups->aces[i].perms, mask);
+			mask = state->groups->aces[i].perms.deny;
+			deny_bits(&state->owner, mask);
+			deny_bits(&state->group, mask);
+			deny_bits(&state->everyone, mask);
+			deny_bits_array(state->users, mask);
+			deny_bits_array(state->groups, mask);
+		}
+	} else if (__is_acl_other(nfsv4_acl_info, nfsv4_ace)) {
+		if (__is_allowed_ace_type(nfsv4_acl_info, nfsv4_ace)) {
+			allow_bits(&state->owner, mask);
+			allow_bits(&state->group, mask);
+			allow_bits(&state->other, mask);
+			allow_bits(&state->everyone, mask);
+			allow_bits_array(state->users, mask);
+			allow_bits_array(state->groups, mask);
+		} else {
+			deny_bits(&state->owner, mask);
+			deny_bits(&state->group, mask);
+			deny_bits(&state->other, mask);
+			deny_bits(&state->everyone, mask);
+			deny_bits_array(state->users, mask);
+			deny_bits_array(state->groups, mask);
+		}
+	}
+}
+
+int map_nfsv4_acl_to_posix(struct user_namespace *user_ns,
+			    struct nfsv4_acl_info *nfsv4_acl_info,
+			    struct posix_acl **pacl,
+			    struct posix_acl **dpacl,
+			    unsigned int flags)
+{
+	struct posix_acl_state effective_acl_state, default_acl_state;
+	void *nfsv4_ace;
+	uint32_t index;
+	int ret;
+
+	ret = init_state(&effective_acl_state, __get_naces(nfsv4_acl_info));
+	if (ret)
+		return ret;
+	ret = init_state(&default_acl_state, __get_naces(nfsv4_acl_info));
+	if (ret)
+		goto out_estate;
+
+	ret = -EINVAL;
+	for (index = 0; index < __get_naces(nfsv4_acl_info); ++index) {
+
+		nfsv4_ace = __get_ace(nfsv4_acl_info, index);
+
+		if (unlikely(IS_ERR(nfsv4_ace)))
+			goto out_dstate;
+		if (!__ace_type_valid(nfsv4_acl_info, nfsv4_ace))
+			goto out_dstate;
+		if (__ace_has_unknown_flags(nfsv4_acl_info, nfsv4_ace))
+			goto out_dstate;
+		if (!__ace_has_inheritance_flags(nfsv4_acl_info, nfsv4_ace)) {
+			process_one_v4_ace(nfsv4_acl_info,
+						&effective_acl_state,
+						nfsv4_ace);
+			continue;
+		}
+		if (!(flags & NFS4_ACL_DIR))
+			goto out_dstate;
+		/*
+		 * Note that when only one of FILE_INHERIT or DIRECTORY_INHERIT
+		 * is set, we're effectively turning on the other.  That's OK,
+		 * according to rfc 3530.
+		 */
+		process_one_v4_ace(nfsv4_acl_info,
+					&default_acl_state, nfsv4_ace);
+
+		if (!__ace_inherit_only_flag(nfsv4_acl_info, nfsv4_ace))
+			process_one_v4_ace(nfsv4_acl_info,
+						&effective_acl_state,
+						nfsv4_ace);
+	}
+
+	*pacl = posix_state_to_acl(user_ns,
+					nfsv4_acl_info,
+					&effective_acl_state,
+					flags);
+	if (IS_ERR(*pacl)) {
+		ret = PTR_ERR(*pacl);
+		*pacl = NULL;
+		goto out_dstate;
+	}
+	*dpacl = posix_state_to_acl(user_ns,
+					nfsv4_acl_info,
+					&default_acl_state,
+					flags | NFS4_ACL_TYPE_DEFAULT);
+	if (IS_ERR(*dpacl)) {
+		ret = PTR_ERR(*dpacl);
+		*dpacl = NULL;
+		posix_acl_release(*pacl);
+		*pacl = NULL;
+		goto out_dstate;
+	}
+	sort_pacl(*pacl);
+	sort_pacl(*dpacl);
+	ret = 0;
+out_dstate:
+	free_state(&default_acl_state);
+out_estate:
+	free_state(&effective_acl_state);
+	return ret;
+}
+EXPORT_SYMBOL(map_nfsv4_acl_to_posix);
+
+short ace2type(const struct nfs4_ace *ace)
+{
+	switch (ace->whotype) {
+	case NFS4_ACL_WHO_NAMED:
+		return (ace->flag & NFS4_ACE_IDENTIFIER_GROUP) ?
+					ACL_GROUP : ACL_USER;
+	case NFS4_ACL_WHO_OWNER:
+		return ACL_USER_OBJ;
+	case NFS4_ACL_WHO_GROUP:
+		return ACL_GROUP_OBJ;
+	case NFS4_ACL_WHO_EVERYONE:
+		return ACL_OTHER;
+	}
+	BUG();
+	return -1;
+}
+EXPORT_SYMBOL(ace2type);
diff --git a/fs/nfsd/acl.h b/fs/nfsd/acl.h
index 8b186a4..dce725f 100644
--- a/fs/nfsd/acl.h
+++ b/fs/nfsd/acl.h
@@ -35,7 +35,7 @@
 #ifndef LINUX_NFS4_ACL_H
 #define LINUX_NFS4_ACL_H
 
-#include <linux/posix_acl.h>
+#include <linux/nfs4acl.h>
 
 /* Maximum ACL we'll accept from client; chosen (somewhat arbitrarily) to
  * fit in a page: */
@@ -45,13 +45,4 @@ struct nfs4_acl *nfs4_acl_new(int);
 int nfs4_acl_get_whotype(char *, u32);
 int nfs4_acl_write_who(int who, char *p);
 
-#define NFS4_ACL_TYPE_DEFAULT	0x01
-#define NFS4_ACL_DIR		0x02
-#define NFS4_ACL_OWNER		0x04
-
-struct nfs4_acl *nfs4_acl_posix_to_nfsv4(struct posix_acl *,
-				struct posix_acl *, unsigned int flags);
-int nfs4_acl_nfsv4_to_posix(struct nfs4_acl *, struct posix_acl **,
-				struct posix_acl **, unsigned int flags);
-
 #endif /* LINUX_NFS4_ACL_H */
diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index 8a50b3c..c5e58e5 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -39,102 +39,29 @@
 #include <linux/export.h>
 #include "acl.h"
 
-
-/* mode bit translations: */
-#define NFS4_READ_MODE (NFS4_ACE_READ_DATA)
-#define NFS4_WRITE_MODE (NFS4_ACE_WRITE_DATA | NFS4_ACE_APPEND_DATA)
-#define NFS4_EXECUTE_MODE NFS4_ACE_EXECUTE
-#define NFS4_ANYONE_MODE (NFS4_ACE_READ_ATTRIBUTES | NFS4_ACE_READ_ACL | NFS4_ACE_SYNCHRONIZE)
-#define NFS4_OWNER_MODE (NFS4_ACE_WRITE_ATTRIBUTES | NFS4_ACE_WRITE_ACL)
-
-/* We don't support these bits; insist they be neither allowed nor denied */
-#define NFS4_MASK_UNSUPP (NFS4_ACE_DELETE | NFS4_ACE_WRITE_OWNER \
-		| NFS4_ACE_READ_NAMED_ATTRS | NFS4_ACE_WRITE_NAMED_ATTRS)
-
-/* flags used to simulate posix default ACLs */
-#define NFS4_INHERITANCE_FLAGS (NFS4_ACE_FILE_INHERIT_ACE \
-		| NFS4_ACE_DIRECTORY_INHERIT_ACE)
-
-#define NFS4_SUPPORTED_FLAGS (NFS4_INHERITANCE_FLAGS \
-		| NFS4_ACE_INHERIT_ONLY_ACE \
-		| NFS4_ACE_IDENTIFIER_GROUP)
-
-#define MASK_EQUAL(mask1, mask2) \
-	( ((mask1) & NFS4_ACE_MASK_ALL) == ((mask2) & NFS4_ACE_MASK_ALL) )
-
-static u32
-mask_from_posix(unsigned short perm, unsigned int flags)
+struct nfs4_acl *nfs4_acl_new(int n)
 {
-	int mask = NFS4_ANYONE_MODE;
-
-	if (flags & NFS4_ACL_OWNER)
-		mask |= NFS4_OWNER_MODE;
-	if (perm & ACL_READ)
-		mask |= NFS4_READ_MODE;
-	if (perm & ACL_WRITE)
-		mask |= NFS4_WRITE_MODE;
-	if ((perm & ACL_WRITE) && (flags & NFS4_ACL_DIR))
-		mask |= NFS4_ACE_DELETE_CHILD;
-	if (perm & ACL_EXECUTE)
-		mask |= NFS4_EXECUTE_MODE;
-	return mask;
-}
-
-static u32
-deny_mask_from_posix(unsigned short perm, u32 flags)
-{
-	u32 mask = 0;
+	struct nfs4_acl *acl;
 
-	if (perm & ACL_READ)
-		mask |= NFS4_READ_MODE;
-	if (perm & ACL_WRITE)
-		mask |= NFS4_WRITE_MODE;
-	if ((perm & ACL_WRITE) && (flags & NFS4_ACL_DIR))
-		mask |= NFS4_ACE_DELETE_CHILD;
-	if (perm & ACL_EXECUTE)
-		mask |= NFS4_EXECUTE_MODE;
-	return mask;
+	acl = kmalloc(sizeof(*acl) + n*sizeof(struct nfs4_ace), GFP_KERNEL);
+	if (acl == NULL)
+		return NULL;
+	acl->naces = 0;
+	return acl;
 }
 
-/* XXX: modify functions to return NFS errors; they're only ever
- * used by nfs code, after all.... */
-
-/* We only map from NFSv4 to POSIX ACLs when setting ACLs, when we err on the
- * side of being more restrictive, so the mode bit mapping below is
- * pessimistic.  An optimistic version would be needed to handle DENY's,
- * but we espect to coalesce all ALLOWs and DENYs before mapping to mode
- * bits. */
-
-static void
-low_mode_from_nfs4(u32 perm, unsigned short *mode, unsigned int flags)
+struct nfs4_acl *nfs4_acl_posix_to_nfsv4(struct posix_acl *pacl,
+					    struct posix_acl *dpacl,
+					    unsigned int flags)
 {
-	u32 write_mode = NFS4_WRITE_MODE;
-
-	if (flags & NFS4_ACL_DIR)
-		write_mode |= NFS4_ACE_DELETE_CHILD;
-	*mode = 0;
-	if ((perm & NFS4_READ_MODE) == NFS4_READ_MODE)
-		*mode |= ACL_READ;
-	if ((perm & write_mode) == write_mode)
-		*mode |= ACL_WRITE;
-	if ((perm & NFS4_EXECUTE_MODE) == NFS4_EXECUTE_MODE)
-		*mode |= ACL_EXECUTE;
-}
-
-struct ace_container {
-	struct nfs4_ace  *ace;
-	struct list_head  ace_l;
-};
-
-static short ace2type(struct nfs4_ace *);
-static void _posix_to_nfsv4_one(struct posix_acl *, struct nfs4_acl *,
-				unsigned int);
-
-struct nfs4_acl *
-nfs4_acl_posix_to_nfsv4(struct posix_acl *pacl, struct posix_acl *dpacl,
-			unsigned int flags)
-{
-	struct nfs4_acl *acl;
+	struct nfsv4_acl_info acl_info = {
+		.ace_ops = NULL,
+		.flags_ops = NULL,
+		.id_ops = NULL,
+		.mapping_ops = NULL,
+		.raw_acl = NULL,
+		.private = NULL
+	};
 	int size = 0;
 
 	if (pacl) {
@@ -149,670 +76,43 @@ nfs4_acl_posix_to_nfsv4(struct posix_acl *pacl, struct posix_acl *dpacl,
 	}
 
 	/* Allocate for worst case: one (deny, allow) pair each: */
-	acl = nfs4_acl_new(size);
-	if (acl == NULL)
+	acl_info.raw_acl = nfs4_acl_new(size);
+	if (acl_info.raw_acl == NULL)
 		return ERR_PTR(-ENOMEM);
 
-	if (pacl)
-		_posix_to_nfsv4_one(pacl, acl, flags & ~NFS4_ACL_TYPE_DEFAULT);
-
-	if (dpacl)
-		_posix_to_nfsv4_one(dpacl, acl, flags | NFS4_ACL_TYPE_DEFAULT);
-
-	return acl;
-}
-
-struct posix_acl_summary {
-	unsigned short owner;
-	unsigned short users;
-	unsigned short group;
-	unsigned short groups;
-	unsigned short other;
-	unsigned short mask;
-};
-
-static void
-summarize_posix_acl(struct posix_acl *acl, struct posix_acl_summary *pas)
-{
-	struct posix_acl_entry *pa, *pe;
-
-	/*
-	 * Only pas.users and pas.groups need initialization; previous
-	 * posix_acl_valid() calls ensure that the other fields will be
-	 * initialized in the following loop.  But, just to placate gcc:
-	 */
-	memset(pas, 0, sizeof(*pas));
-	pas->mask = 07;
-
-	pe = acl->a_entries + acl->a_count;
-
-	FOREACH_ACL_ENTRY(pa, acl, pe) {
-		switch (pa->e_tag) {
-			case ACL_USER_OBJ:
-				pas->owner = pa->e_perm;
-				break;
-			case ACL_GROUP_OBJ:
-				pas->group = pa->e_perm;
-				break;
-			case ACL_USER:
-				pas->users |= pa->e_perm;
-				break;
-			case ACL_GROUP:
-				pas->groups |= pa->e_perm;
-				break;
-			case ACL_OTHER:
-				pas->other = pa->e_perm;
-				break;
-			case ACL_MASK:
-				pas->mask = pa->e_perm;
-				break;
-		}
-	}
-	/* We'll only care about effective permissions: */
-	pas->users &= pas->mask;
-	pas->group &= pas->mask;
-	pas->groups &= pas->mask;
-}
-
-/* We assume the acl has been verified with posix_acl_valid. */
-static void
-_posix_to_nfsv4_one(struct posix_acl *pacl, struct nfs4_acl *acl,
-						unsigned int flags)
-{
-	struct posix_acl_entry *pa, *group_owner_entry;
-	struct nfs4_ace *ace;
-	struct posix_acl_summary pas;
-	unsigned short deny;
-	int eflag = ((flags & NFS4_ACL_TYPE_DEFAULT) ?
-		NFS4_INHERITANCE_FLAGS | NFS4_ACE_INHERIT_ONLY_ACE : 0);
-
-	BUG_ON(pacl->a_count < 3);
-	summarize_posix_acl(pacl, &pas);
-
-	pa = pacl->a_entries;
-	ace = acl->aces + acl->naces;
-
-	/* We could deny everything not granted by the owner: */
-	deny = ~pas.owner;
-	/*
-	 * but it is equivalent (and simpler) to deny only what is not
-	 * granted by later entries:
-	 */
-	deny &= pas.users | pas.group | pas.groups | pas.other;
-	if (deny) {
-		ace->type = NFS4_ACE_ACCESS_DENIED_ACE_TYPE;
-		ace->flag = eflag;
-		ace->access_mask = deny_mask_from_posix(deny, flags);
-		ace->whotype = NFS4_ACL_WHO_OWNER;
-		ace++;
-		acl->naces++;
-	}
-
-	ace->type = NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE;
-	ace->flag = eflag;
-	ace->access_mask = mask_from_posix(pa->e_perm, flags | NFS4_ACL_OWNER);
-	ace->whotype = NFS4_ACL_WHO_OWNER;
-	ace++;
-	acl->naces++;
-	pa++;
-
-	while (pa->e_tag == ACL_USER) {
-		deny = ~(pa->e_perm & pas.mask);
-		deny &= pas.groups | pas.group | pas.other;
-		if (deny) {
-			ace->type = NFS4_ACE_ACCESS_DENIED_ACE_TYPE;
-			ace->flag = eflag;
-			ace->access_mask = deny_mask_from_posix(deny, flags);
-			ace->whotype = NFS4_ACL_WHO_NAMED;
-			ace->who_uid = pa->e_uid;
-			ace++;
-			acl->naces++;
-		}
-		ace->type = NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE;
-		ace->flag = eflag;
-		ace->access_mask = mask_from_posix(pa->e_perm & pas.mask,
-						   flags);
-		ace->whotype = NFS4_ACL_WHO_NAMED;
-		ace->who_uid = pa->e_uid;
-		ace++;
-		acl->naces++;
-		pa++;
-	}
-
-	/* In the case of groups, we apply allow ACEs first, then deny ACEs,
-	 * since a user can be in more than one group.  */
-
-	/* allow ACEs */
-
-	group_owner_entry = pa;
-
-	ace->type = NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE;
-	ace->flag = eflag;
-	ace->access_mask = mask_from_posix(pas.group, flags);
-	ace->whotype = NFS4_ACL_WHO_GROUP;
-	ace++;
-	acl->naces++;
-	pa++;
-
-	while (pa->e_tag == ACL_GROUP) {
-		ace->type = NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE;
-		ace->flag = eflag | NFS4_ACE_IDENTIFIER_GROUP;
-		ace->access_mask = mask_from_posix(pa->e_perm & pas.mask,
-						   flags);
-		ace->whotype = NFS4_ACL_WHO_NAMED;
-		ace->who_gid = pa->e_gid;
-		ace++;
-		acl->naces++;
-		pa++;
-	}
-
-	/* deny ACEs */
-
-	pa = group_owner_entry;
-
-	deny = ~pas.group & pas.other;
-	if (deny) {
-		ace->type = NFS4_ACE_ACCESS_DENIED_ACE_TYPE;
-		ace->flag = eflag;
-		ace->access_mask = deny_mask_from_posix(deny, flags);
-		ace->whotype = NFS4_ACL_WHO_GROUP;
-		ace++;
-		acl->naces++;
-	}
-	pa++;
-
-	while (pa->e_tag == ACL_GROUP) {
-		deny = ~(pa->e_perm & pas.mask);
-		deny &= pas.other;
-		if (deny) {
-			ace->type = NFS4_ACE_ACCESS_DENIED_ACE_TYPE;
-			ace->flag = eflag | NFS4_ACE_IDENTIFIER_GROUP;
-			ace->access_mask = deny_mask_from_posix(deny, flags);
-			ace->whotype = NFS4_ACL_WHO_NAMED;
-			ace->who_gid = pa->e_gid;
-			ace++;
-			acl->naces++;
-		}
-		pa++;
-	}
-
-	if (pa->e_tag == ACL_MASK)
-		pa++;
-	ace->type = NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE;
-	ace->flag = eflag;
-	ace->access_mask = mask_from_posix(pa->e_perm, flags);
-	ace->whotype = NFS4_ACL_WHO_EVERYONE;
-	acl->naces++;
-}
-
-static bool
-pace_gt(struct posix_acl_entry *pace1, struct posix_acl_entry *pace2)
-{
-	if (pace1->e_tag != pace2->e_tag)
-		return pace1->e_tag > pace2->e_tag;
-	if (pace1->e_tag == ACL_USER)
-		return uid_gt(pace1->e_uid, pace2->e_uid);
-	if (pace1->e_tag == ACL_GROUP)
-		return gid_gt(pace1->e_gid, pace2->e_gid);
-	return false;
-}
-
-static void
-sort_pacl_range(struct posix_acl *pacl, int start, int end) {
-	int sorted = 0, i;
-	struct posix_acl_entry tmp;
-
-	/* We just do a bubble sort; easy to do in place, and we're not
-	 * expecting acl's to be long enough to justify anything more. */
-	while (!sorted) {
-		sorted = 1;
-		for (i = start; i < end; i++) {
-			if (pace_gt(&pacl->a_entries[i],
-				    &pacl->a_entries[i+1])) {
-				sorted = 0;
-				tmp = pacl->a_entries[i];
-				pacl->a_entries[i] = pacl->a_entries[i+1];
-				pacl->a_entries[i+1] = tmp;
-			}
-		}
-	}
-}
-
-static void
-sort_pacl(struct posix_acl *pacl)
-{
-	/* posix_acl_valid requires that users and groups be in order
-	 * by uid/gid. */
-	int i, j;
-
-	if (pacl->a_count <= 4)
-		return; /* no users or groups */
-	i = 1;
-	while (pacl->a_entries[i].e_tag == ACL_USER)
-		i++;
-	sort_pacl_range(pacl, 1, i-1);
-
-	BUG_ON(pacl->a_entries[i].e_tag != ACL_GROUP_OBJ);
-	j = ++i;
-	while (pacl->a_entries[j].e_tag == ACL_GROUP)
-		j++;
-	sort_pacl_range(pacl, i, j-1);
-	return;
-}
-
-/*
- * While processing the NFSv4 ACE, this maintains bitmasks representing
- * which permission bits have been allowed and which denied to a given
- * entity: */
-struct posix_ace_state {
-	u32 allow;
-	u32 deny;
-};
-
-struct posix_user_ace_state {
-	union {
-		kuid_t uid;
-		kgid_t gid;
-	};
-	struct posix_ace_state perms;
-};
-
-struct posix_ace_state_array {
-	int n;
-	struct posix_user_ace_state aces[];
-};
-
-/*
- * While processing the NFSv4 ACE, this maintains the partial permissions
- * calculated so far: */
-
-struct posix_acl_state {
-	int empty;
-	struct posix_ace_state owner;
-	struct posix_ace_state group;
-	struct posix_ace_state other;
-	struct posix_ace_state everyone;
-	struct posix_ace_state mask; /* Deny unused in this case */
-	struct posix_ace_state_array *users;
-	struct posix_ace_state_array *groups;
-};
-
-static int
-init_state(struct posix_acl_state *state, int cnt)
-{
-	int alloc;
-
-	memset(state, 0, sizeof(struct posix_acl_state));
-	state->empty = 1;
-	/*
-	 * In the worst case, each individual acl could be for a distinct
-	 * named user or group, but we don't no which, so we allocate
-	 * enough space for either:
-	 */
-	alloc = sizeof(struct posix_ace_state_array)
-		+ cnt*sizeof(struct posix_user_ace_state);
-	state->users = kzalloc(alloc, GFP_KERNEL);
-	if (!state->users)
-		return -ENOMEM;
-	state->groups = kzalloc(alloc, GFP_KERNEL);
-	if (!state->groups) {
-		kfree(state->users);
-		return -ENOMEM;
-	}
-	return 0;
-}
-
-static void
-free_state(struct posix_acl_state *state) {
-	kfree(state->users);
-	kfree(state->groups);
-}
-
-static inline void add_to_mask(struct posix_acl_state *state, struct posix_ace_state *astate)
-{
-	state->mask.allow |= astate->allow;
-}
-
-/*
- * Certain bits (SYNCHRONIZE, DELETE, WRITE_OWNER, READ/WRITE_NAMED_ATTRS,
- * READ_ATTRIBUTES, READ_ACL) are currently unenforceable and don't translate
- * to traditional read/write/execute permissions.
- *
- * It's problematic to reject acls that use certain mode bits, because it
- * places the burden on users to learn the rules about which bits one
- * particular server sets, without giving the user a lot of help--we return an
- * error that could mean any number of different things.  To make matters
- * worse, the problematic bits might be introduced by some application that's
- * automatically mapping from some other acl model.
- *
- * So wherever possible we accept anything, possibly erring on the side of
- * denying more permissions than necessary.
- *
- * However we do reject *explicit* DENY's of a few bits representing
- * permissions we could never deny:
- */
-
-static inline int check_deny(u32 mask, int isowner)
-{
-	if (mask & (NFS4_ACE_READ_ATTRIBUTES | NFS4_ACE_READ_ACL))
-		return -EINVAL;
-	if (!isowner)
-		return 0;
-	if (mask & (NFS4_ACE_WRITE_ATTRIBUTES | NFS4_ACE_WRITE_ACL))
-		return -EINVAL;
-	return 0;
-}
-
-static struct posix_acl *
-posix_state_to_acl(struct posix_acl_state *state, unsigned int flags)
-{
-	struct posix_acl_entry *pace;
-	struct posix_acl *pacl;
-	int nace;
-	int i, error = 0;
-
-	/*
-	 * ACLs with no ACEs are treated differently in the inheritable
-	 * and effective cases: when there are no inheritable ACEs, we
-	 * set a zero-length default posix acl:
-	 */
-	if (state->empty && (flags & NFS4_ACL_TYPE_DEFAULT)) {
-		pacl = posix_acl_alloc(0, GFP_KERNEL);
-		return pacl ? pacl : ERR_PTR(-ENOMEM);
-	}
-	/*
-	 * When there are no effective ACEs, the following will end
-	 * up setting a 3-element effective posix ACL with all
-	 * permissions zero.
-	 */
-	nace = 4 + state->users->n + state->groups->n;
-	pacl = posix_acl_alloc(nace, GFP_KERNEL);
-	if (!pacl)
-		return ERR_PTR(-ENOMEM);
-
-	pace = pacl->a_entries;
-	pace->e_tag = ACL_USER_OBJ;
-	error = check_deny(state->owner.deny, 1);
-	if (error)
-		goto out_err;
-	low_mode_from_nfs4(state->owner.allow, &pace->e_perm, flags);
-
-	for (i=0; i < state->users->n; i++) {
-		pace++;
-		pace->e_tag = ACL_USER;
-		error = check_deny(state->users->aces[i].perms.deny, 0);
-		if (error)
-			goto out_err;
-		low_mode_from_nfs4(state->users->aces[i].perms.allow,
-					&pace->e_perm, flags);
-		pace->e_uid = state->users->aces[i].uid;
-		add_to_mask(state, &state->users->aces[i].perms);
+	if (pacl) {
+		map_posix_acl_to_nfsv4_one(&init_user_ns, pacl, &acl_info,
+					flags & ~NFS4_ACL_TYPE_DEFAULT);
 	}
 
-	pace++;
-	pace->e_tag = ACL_GROUP_OBJ;
-	error = check_deny(state->group.deny, 0);
-	if (error)
-		goto out_err;
-	low_mode_from_nfs4(state->group.allow, &pace->e_perm, flags);
-	add_to_mask(state, &state->group);
-
-	for (i=0; i < state->groups->n; i++) {
-		pace++;
-		pace->e_tag = ACL_GROUP;
-		error = check_deny(state->groups->aces[i].perms.deny, 0);
-		if (error)
-			goto out_err;
-		low_mode_from_nfs4(state->groups->aces[i].perms.allow,
-					&pace->e_perm, flags);
-		pace->e_gid = state->groups->aces[i].gid;
-		add_to_mask(state, &state->groups->aces[i].perms);
+	if (dpacl) {
+		map_posix_acl_to_nfsv4_one(&init_user_ns, dpacl, &acl_info,
+					flags | NFS4_ACL_TYPE_DEFAULT);
 	}
 
-	pace++;
-	pace->e_tag = ACL_MASK;
-	low_mode_from_nfs4(state->mask.allow, &pace->e_perm, flags);
-
-	pace++;
-	pace->e_tag = ACL_OTHER;
-	error = check_deny(state->other.deny, 0);
-	if (error)
-		goto out_err;
-	low_mode_from_nfs4(state->other.allow, &pace->e_perm, flags);
-
-	return pacl;
-out_err:
-	posix_acl_release(pacl);
-	return ERR_PTR(error);
-}
-
-static inline void allow_bits(struct posix_ace_state *astate, u32 mask)
-{
-	/* Allow all bits in the mask not already denied: */
-	astate->allow |= mask & ~astate->deny;
-}
-
-static inline void deny_bits(struct posix_ace_state *astate, u32 mask)
-{
-	/* Deny all bits in the mask not already allowed: */
-	astate->deny |= mask & ~astate->allow;
-}
-
-static int find_uid(struct posix_acl_state *state, kuid_t uid)
-{
-	struct posix_ace_state_array *a = state->users;
-	int i;
-
-	for (i = 0; i < a->n; i++)
-		if (uid_eq(a->aces[i].uid, uid))
-			return i;
-	/* Not found: */
-	a->n++;
-	a->aces[i].uid = uid;
-	a->aces[i].perms.allow = state->everyone.allow;
-	a->aces[i].perms.deny  = state->everyone.deny;
-
-	return i;
-}
-
-static int find_gid(struct posix_acl_state *state, kgid_t gid)
-{
-	struct posix_ace_state_array *a = state->groups;
-	int i;
-
-	for (i = 0; i < a->n; i++)
-		if (gid_eq(a->aces[i].gid, gid))
-			return i;
-	/* Not found: */
-	a->n++;
-	a->aces[i].gid = gid;
-	a->aces[i].perms.allow = state->everyone.allow;
-	a->aces[i].perms.deny  = state->everyone.deny;
-
-	return i;
-}
-
-static void deny_bits_array(struct posix_ace_state_array *a, u32 mask)
-{
-	int i;
-
-	for (i=0; i < a->n; i++)
-		deny_bits(&a->aces[i].perms, mask);
-}
-
-static void allow_bits_array(struct posix_ace_state_array *a, u32 mask)
-{
-	int i;
-
-	for (i=0; i < a->n; i++)
-		allow_bits(&a->aces[i].perms, mask);
-}
-
-static void process_one_v4_ace(struct posix_acl_state *state,
-				struct nfs4_ace *ace)
-{
-	u32 mask = ace->access_mask;
-	int i;
-
-	state->empty = 0;
-
-	switch (ace2type(ace)) {
-	case ACL_USER_OBJ:
-		if (ace->type == NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE) {
-			allow_bits(&state->owner, mask);
-		} else {
-			deny_bits(&state->owner, mask);
-		}
-		break;
-	case ACL_USER:
-		i = find_uid(state, ace->who_uid);
-		if (ace->type == NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE) {
-			allow_bits(&state->users->aces[i].perms, mask);
-		} else {
-			deny_bits(&state->users->aces[i].perms, mask);
-			mask = state->users->aces[i].perms.deny;
-			deny_bits(&state->owner, mask);
-		}
-		break;
-	case ACL_GROUP_OBJ:
-		if (ace->type == NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE) {
-			allow_bits(&state->group, mask);
-		} else {
-			deny_bits(&state->group, mask);
-			mask = state->group.deny;
-			deny_bits(&state->owner, mask);
-			deny_bits(&state->everyone, mask);
-			deny_bits_array(state->users, mask);
-			deny_bits_array(state->groups, mask);
-		}
-		break;
-	case ACL_GROUP:
-		i = find_gid(state, ace->who_gid);
-		if (ace->type == NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE) {
-			allow_bits(&state->groups->aces[i].perms, mask);
-		} else {
-			deny_bits(&state->groups->aces[i].perms, mask);
-			mask = state->groups->aces[i].perms.deny;
-			deny_bits(&state->owner, mask);
-			deny_bits(&state->group, mask);
-			deny_bits(&state->everyone, mask);
-			deny_bits_array(state->users, mask);
-			deny_bits_array(state->groups, mask);
-		}
-		break;
-	case ACL_OTHER:
-		if (ace->type == NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE) {
-			allow_bits(&state->owner, mask);
-			allow_bits(&state->group, mask);
-			allow_bits(&state->other, mask);
-			allow_bits(&state->everyone, mask);
-			allow_bits_array(state->users, mask);
-			allow_bits_array(state->groups, mask);
-		} else {
-			deny_bits(&state->owner, mask);
-			deny_bits(&state->group, mask);
-			deny_bits(&state->other, mask);
-			deny_bits(&state->everyone, mask);
-			deny_bits_array(state->users, mask);
-			deny_bits_array(state->groups, mask);
-		}
-	}
+	return (struct nfs4_acl *)acl_info.raw_acl;
 }
 
 int nfs4_acl_nfsv4_to_posix(struct nfs4_acl *acl, struct posix_acl **pacl,
 			    struct posix_acl **dpacl, unsigned int flags)
 {
-	struct posix_acl_state effective_acl_state, default_acl_state;
-	struct nfs4_ace *ace;
-	int ret;
-
-	ret = init_state(&effective_acl_state, acl->naces);
-	if (ret)
-		return ret;
-	ret = init_state(&default_acl_state, acl->naces);
-	if (ret)
-		goto out_estate;
-	ret = -EINVAL;
-	for (ace = acl->aces; ace < acl->aces + acl->naces; ace++) {
-		if (ace->type != NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE &&
-		    ace->type != NFS4_ACE_ACCESS_DENIED_ACE_TYPE)
-			goto out_dstate;
-		if (ace->flag & ~NFS4_SUPPORTED_FLAGS)
-			goto out_dstate;
-		if ((ace->flag & NFS4_INHERITANCE_FLAGS) == 0) {
-			process_one_v4_ace(&effective_acl_state, ace);
-			continue;
-		}
-		if (!(flags & NFS4_ACL_DIR))
-			goto out_dstate;
-		/*
-		 * Note that when only one of FILE_INHERIT or DIRECTORY_INHERIT
-		 * is set, we're effectively turning on the other.  That's OK,
-		 * according to rfc 3530.
-		 */
-		process_one_v4_ace(&default_acl_state, ace);
+	struct nfsv4_acl_info acl_info = {
+		.ace_ops = NULL,
+		.flags_ops = NULL,
+		.id_ops = NULL,
+		.mapping_ops = NULL,
+		.raw_acl = NULL,
+		.private = NULL
+	};
+	acl_info.raw_acl = acl;
 
-		if (!(ace->flag & NFS4_ACE_INHERIT_ONLY_ACE))
-			process_one_v4_ace(&effective_acl_state, ace);
-	}
-	*pacl = posix_state_to_acl(&effective_acl_state, flags);
-	if (IS_ERR(*pacl)) {
-		ret = PTR_ERR(*pacl);
-		*pacl = NULL;
-		goto out_dstate;
-	}
-	*dpacl = posix_state_to_acl(&default_acl_state,
-						flags | NFS4_ACL_TYPE_DEFAULT);
-	if (IS_ERR(*dpacl)) {
-		ret = PTR_ERR(*dpacl);
-		*dpacl = NULL;
-		posix_acl_release(*pacl);
-		*pacl = NULL;
-		goto out_dstate;
-	}
-	sort_pacl(*pacl);
-	sort_pacl(*dpacl);
-	ret = 0;
-out_dstate:
-	free_state(&default_acl_state);
-out_estate:
-	free_state(&effective_acl_state);
-	return ret;
-}
-
-static short
-ace2type(struct nfs4_ace *ace)
-{
-	switch (ace->whotype) {
-		case NFS4_ACL_WHO_NAMED:
-			return (ace->flag & NFS4_ACE_IDENTIFIER_GROUP ?
-					ACL_GROUP : ACL_USER);
-		case NFS4_ACL_WHO_OWNER:
-			return ACL_USER_OBJ;
-		case NFS4_ACL_WHO_GROUP:
-			return ACL_GROUP_OBJ;
-		case NFS4_ACL_WHO_EVERYONE:
-			return ACL_OTHER;
-	}
-	BUG();
-	return -1;
+	return map_nfsv4_acl_to_posix(&init_user_ns, &acl_info,
+					pacl, dpacl, flags);
 }
 
 EXPORT_SYMBOL(nfs4_acl_posix_to_nfsv4);
 EXPORT_SYMBOL(nfs4_acl_nfsv4_to_posix);
 
-struct nfs4_acl *
-nfs4_acl_new(int n)
-{
-	struct nfs4_acl *acl;
-
-	acl = kmalloc(sizeof(*acl) + n*sizeof(struct nfs4_ace), GFP_KERNEL);
-	if (acl == NULL)
-		return NULL;
-	acl->naces = 0;
-	return acl;
-}
-
 static struct {
 	char *string;
 	int   stringlen;
@@ -835,8 +135,7 @@ static struct {
 	},
 };
 
-int
-nfs4_acl_get_whotype(char *p, u32 len)
+int nfs4_acl_get_whotype(char *p, u32 len)
 {
 	int i;
 
@@ -848,8 +147,7 @@ nfs4_acl_get_whotype(char *p, u32 len)
 	return NFS4_ACL_WHO_NAMED;
 }
 
-int
-nfs4_acl_write_who(int who, char *p)
+int nfs4_acl_write_who(int who, char *p)
 {
 	int i;
 
-- 
1.7.9.5



