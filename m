Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552636;
	b=5AL1FcCdcXVete/8UGTaCwzuVnKZEl499mX5eU3vU2kkalyi/fVYo2y1XcpgmKPsKJ1U
	 dHLP7oL/lbd1jtyDFHZY5KlfnmjdDrJ9RDV/hVLjDKseM8cHuLXdCi7xLDrajdO6Q+UQo
	 Cyi0sddZoSFbirGLuAadFxPrLenbuW2cSaLbk0WzvGYZwNlz/edjzHczwgOndbXxvu9w1
	 LJj5LGveq5AhfmW57ykMdfVHu/35m/DVX2J3FL/RXJ8KLxqjIOSHZzVWk91U0UlRKCQCD
	 p2NFMoZeD+mSfPBmplFmetHsT2Jc6+Cf50rQzi8Cc1Ds7KzRye8gMpKKz6STU7YOldg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552636;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=PYtCM8AZCT6uaJfSrx0BOZ+0uHQZVP/Z/KdzZbvlZJ0=;
	b=aTEW6LXwuVuxk/5ELvlqs5IHdKpwphNQ+T85mDtZYMmizvTAme5x9LTMtlyvzL2LLVJX
	 /MGJx1M4ani0U3nQvpZ1ORdCV+bQuAHDsY6Zkh4W0mhxMTcbS/pgZOO2zhzLpBmgvTle9
	 7NConjwvBL58xClLUdSEEWyOavvBaBc/VjCzkMbiLybt4xgELOzakH1Zxu7Vp6xDpZgUk
	 u2nThS1gT9RuVMktE5TLaAq7nDJwcIsRSZNQQZuJAUtD63zqhdLS9+Cqdhv+cl7MV0iXM
	 EUkQbC1IcSpgRh3LMR4e9Hzypqa2tf5ufNNrFkN8VTLWuyYIpid+atwa+fOMoQtuEwA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=aFbSe6vz;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B58160779CD;
	Wed, 21 Oct 2026 03:17:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8B58160779CD
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=aFbSe6vz
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552633; bh=YMnWTj9au5/Tn2L6+FyQDCou1t3SlsDfGkZwpfIj2wQ=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=aFbSe6vzYnxQOasfNGnMc2AmHeAZd3awQACfsGIMhiWm7a1jy9iung+k6mmkjFihq
	 ezNd4/Ui7rvTHMmta86DrGE8P6szY3N5L4fkDoDUhsZ/eYBqCVqUYIGHkpzB+9ZocS
	 c4Ymndv2T7OnAih6Ot/XyhNVCkNdjEllYepyKl4lbnCl0U6/F9euiOVI3icLH4oP1v
	 anVB/8Gq388jBYOiTKjaRD2IapP6bra4n8DZYK/IvvSKZAT33N4ZfNObDWx6bZfVNC
	 +KRpXtyIeADEHZ3b9OlmFjwXnDY8PY3ON1IUx9QsoX8hRd+INdCEEJMPUYUFZvZx1R
	 wxOW0gXCilXsg==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 391D48A08F4;
	Wed, 21 Oct 2026 05:17:13 +0200 (CEST)
Message-ID: <d8a3b0587e8123c56058d097fbd2d5fa00cf7bd6.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 33/41] posix_acl: support UUID and GUID entries
To: Christian Brauner <brauner@kernel.org>,
    Alexander Viro <viro@zeniv.linux.org.uk>,
    "Serge E. Hallyn" <serge@hallyn.com>
Cc: Jan Kara <jack@suse.cz>,
    "Theodore Y. Ts'o" <tytso@mit.edu>,
    Paul Moore <paul@paul-moore.com>,
    Arnd Bergmann <arnd@arndb.de>,
    linux-fsdevel@vger.kernel.org,
    linux-api@vger.kernel.org,
    linux-security-module@vger.kernel.org,
    linux-arch@vger.kernel.org,
    linux-ext4@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    linux-cifs@vger.kernel.org,
    netdev@vger.kernel.org,
    audit@vger.kernel.org,
    keyrings@vger.kernel.org,
    linux-kernel@vger.kernel.org
Date: Wed, 21 Oct 2026 05:15:53 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

The ACL xattrs carry 32 bit ids, so ACL_USER and ACL_GROUP entries for
UUID and GUID users and groups could neither be set nor shown.

Add version 3 of the xattr format, whose entries hold an id kind and
16 bytes of id. setxattr() takes version 2 and 3; getxattr() returns
version 3 only if the ACL has such an entry the caller can see, so
existing tools keep getting version 2 for everything else.

set_posix_acl() refuses UUID and GUID entries with -EOVERFLOW on
filesystems without SB_I_UID_R, whose ACL formats can't store them.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/posix_acl.c                       | 123 ++++++++++++++++++++++++++-
 include/linux/posix_acl_xattr.h      |  31 +++++++
 include/uapi/linux/posix_acl_xattr.h |  19 +++++
 3 files changed, 171 insertions(+), 2 deletions(-)

diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 18b302f941..bcb0663fe2 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -19,6 +19,8 @@
 #include <linux/cred.h>
 #include <linux/posix_acl.h>
 #include <linux/posix_acl_xattr.h>
+#include <linux/uidgid_r.h>
+#include <linux/unaligned.h>
 #include <linux/xattr.h>
 #include <linux/export.h>
 #include <linux/user_namespace.h>
@@ -741,16 +743,62 @@ static int posix_acl_fix_xattr_common(const void *value, size_t size)
 		return -EINVAL;
 	if (size < sizeof(struct posix_acl_xattr_header))
 		return -EINVAL;
-	if (header->a_version != cpu_to_le32(POSIX_ACL_XATTR_VERSION))
+	if (header->a_version == cpu_to_le32(POSIX_ACL_XATTR_VERSION_R))
+		count = posix_acl_xattr_count_r(size);
+	else if (header->a_version == cpu_to_le32(POSIX_ACL_XATTR_VERSION))
+		count = posix_acl_xattr_count(size);
+	else
 		return -EOPNOTSUPP;
 
-	count = posix_acl_xattr_count(size);
 	if (count < 0)
 		return -EINVAL;
 
 	return count;
 }
 
+/* The entries of a version 3 ACL xattr into @acl; -EINVAL if malformed */
+static int posix_acl_from_xattr_r(struct user_namespace *userns,
+				  const struct posix_acl_xattr_entry_r *entry,
+				  struct posix_acl *acl)
+{
+	struct __kernel_uid_r id;
+
+	for (int n = 0; n < acl->a_count; n++, entry++) {
+		struct posix_acl_entry *acl_e = &acl->a_entries[n];
+
+		acl_e->e_tag  = le16_to_cpu(entry->e_tag);
+		acl_e->e_perm = le16_to_cpu(entry->e_perm);
+
+		memset(&id, 0, sizeof(id));
+		id.type = le32_to_cpu(entry->e_type);
+		if (id.type == UID_R_LEGACY)
+			id.legacy = get_unaligned_le32(entry->e_id);
+		else
+			memcpy(id.uuid, entry->e_id, sizeof(id.uuid));
+
+		switch (acl_e->e_tag) {
+		case ACL_USER_OBJ:
+		case ACL_GROUP_OBJ:
+		case ACL_MASK:
+		case ACL_OTHER:
+			break;
+		case ACL_USER:
+			acl_e->e_uid = make_kuid_r(userns, &id);
+			if (!uid_valid(acl_e->e_uid))
+				return -EINVAL;
+			break;
+		case ACL_GROUP:
+			acl_e->e_gid = make_kgid_r(userns, &id);
+			if (!gid_valid(acl_e->e_gid))
+				return -EINVAL;
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
 /**
  * posix_acl_from_xattr - convert POSIX ACLs from backing store to VFS format
  * @userns: the filesystem's idmapping
@@ -795,6 +843,13 @@ struct posix_acl *posix_acl_from_xattr(struct user_namespace *userns,
 		return ERR_PTR(-ENOMEM);
 	acl_e = acl->a_entries;
 
+	if (header->a_version == cpu_to_le32(POSIX_ACL_XATTR_VERSION_R)) {
+		if (posix_acl_from_xattr_r(userns, (const void *)(header + 1),
+					   acl))
+			goto fail;
+		return acl;
+	}
+
 	for (end = entry + count; entry != end; acl_e++, entry++) {
 		acl_e->e_tag  = le16_to_cpu(entry->e_tag);
 		acl_e->e_perm = le16_to_cpu(entry->e_perm);
@@ -874,6 +929,61 @@ posix_acl_to_xattr(struct user_namespace *user_ns, const struct posix_acl *acl,
 }
 EXPORT_SYMBOL (posix_acl_to_xattr);
 
+/* Like vfs_posix_acl_to_xattr(), in version 3 */
+static ssize_t vfs_posix_acl_to_xattr_r(struct mnt_idmap *idmap,
+					struct inode *inode,
+					const struct posix_acl *acl,
+					void *buffer, size_t size)
+{
+	struct posix_acl_xattr_header *ext_acl = buffer;
+	struct posix_acl_xattr_entry_r *ext_entry;
+	struct user_namespace *fs_userns = i_user_ns(inode);
+	struct user_namespace *caller_userns = current_user_ns();
+	struct __kernel_uid_r id;
+	ssize_t real_size;
+	bool mapped;
+
+	real_size = posix_acl_xattr_size_r(acl->a_count);
+	if (!buffer)
+		return real_size;
+	if (real_size > size)
+		return -ERANGE;
+
+	ext_entry = (void *)(ext_acl + 1);
+	ext_acl->a_version = cpu_to_le32(POSIX_ACL_XATTR_VERSION_R);
+
+	for (int n = 0; n < acl->a_count; n++, ext_entry++) {
+		const struct posix_acl_entry *acl_e = &acl->a_entries[n];
+
+		ext_entry->e_tag  = cpu_to_le16(acl_e->e_tag);
+		ext_entry->e_perm = cpu_to_le16(acl_e->e_perm);
+		memset(&id, 0, sizeof(id));
+		mapped = true;
+		switch (acl_e->e_tag) {
+		case ACL_USER:
+			mapped = from_kuid_r(caller_userns, vfsuid_into_kuid(
+				make_vfsuid(idmap, fs_userns, acl_e->e_uid)), &id);
+			break;
+		case ACL_GROUP:
+			mapped = from_kgid_r(caller_userns, vfsgid_into_kgid(
+				make_vfsgid(idmap, fs_userns, acl_e->e_gid)), &id);
+			break;
+		}
+		/* no mapping: the classic -1, as in version 2 */
+		if (!mapped) {
+			id.type = UID_R_LEGACY;
+			id.legacy = ACL_UNDEFINED_ID;
+		}
+		ext_entry->e_type = cpu_to_le32(id.type);
+		memset(ext_entry->e_id, 0, sizeof(ext_entry->e_id));
+		if (id.type == UID_R_LEGACY)
+			put_unaligned_le32(id.legacy, ext_entry->e_id);
+		else if (id.type != UID_R_NONE)
+			memcpy(ext_entry->e_id, id.uuid, sizeof(ext_entry->e_id));
+	}
+	return real_size;
+}
+
 /**
  * vfs_posix_acl_to_xattr - convert from kernel to userspace representation
  * @idmap: idmap of the mount
@@ -902,6 +1012,11 @@ static ssize_t vfs_posix_acl_to_xattr(struct mnt_idmap *idmap,
 	vfsuid_t vfsuid;
 	vfsgid_t vfsgid;
 
+	/* UUIDs and GUIDs the caller can see need version 3 */
+	if (posix_acl_has_id_r(acl) && current_user_ns() == &init_user_ns)
+		return vfs_posix_acl_to_xattr_r(idmap, inode, acl, buffer,
+						size);
+
 	real_size = posix_acl_xattr_size(acl->a_count);
 	if (!buffer)
 		return real_size;
@@ -956,6 +1071,10 @@ set_posix_acl(struct mnt_idmap *idmap, struct dentry *dentry,
 		int ret = posix_acl_valid(inode->i_sb->s_user_ns, acl);
 		if (ret)
 			return ret;
+		/* UUID and GUID entries only where the filesystem stores them */
+		if (posix_acl_has_id_r(acl) &&
+		    !(inode->i_sb->s_iflags & SB_I_UID_R))
+			return -EOVERFLOW;
 	}
 	return inode->i_op->set_acl(idmap, dentry, acl, type);
 }
diff --git a/include/linux/posix_acl_xattr.h b/include/linux/posix_acl_xattr.h
index 9e1892525e..307d543bce 100644
--- a/include/linux/posix_acl_xattr.h
+++ b/include/linux/posix_acl_xattr.h
@@ -32,6 +32,37 @@ posix_acl_xattr_count(size_t size)
 	return size / sizeof(struct posix_acl_xattr_entry);
 }
 
+static inline size_t
+posix_acl_xattr_size_r(int count)
+{
+	return (sizeof(struct posix_acl_xattr_header) +
+		(count * sizeof(struct posix_acl_xattr_entry_r)));
+}
+
+static inline int
+posix_acl_xattr_count_r(size_t size)
+{
+	if (size < sizeof(struct posix_acl_xattr_header))
+		return -1;
+	size -= sizeof(struct posix_acl_xattr_header);
+	if (size % sizeof(struct posix_acl_xattr_entry_r))
+		return -1;
+	return size / sizeof(struct posix_acl_xattr_entry_r);
+}
+
+/* Whether an ACL_USER or ACL_GROUP entry of @acl is a UUID or GUID */
+static inline bool posix_acl_has_id_r(const struct posix_acl *acl)
+{
+	for (int n = 0; n < acl->a_count; n++) {
+		const struct posix_acl_entry *e = &acl->a_entries[n];
+
+		if ((e->e_tag == ACL_USER && !uid_is_legacy(e->e_uid)) ||
+		    (e->e_tag == ACL_GROUP && !gid_is_legacy(e->e_gid)))
+			return true;
+	}
+	return false;
+}
+
 #ifdef CONFIG_FS_POSIX_ACL
 struct posix_acl *posix_acl_from_xattr(struct user_namespace *user_ns,
 				       const void *value, size_t size);
diff --git a/include/uapi/linux/posix_acl_xattr.h b/include/uapi/linux/posix_acl_xattr.h
index 506380f0b9..a44a515079 100644
--- a/include/uapi/linux/posix_acl_xattr.h
+++ b/include/uapi/linux/posix_acl_xattr.h
@@ -36,4 +36,23 @@ struct posix_acl_xattr_header {
 	__le32			a_version;
 };
 
+/*
+ * Version 3: the ids of ACL_USER and ACL_GROUP entries can also be UUIDs
+ * and GUIDs. e_type is a UID_R_* kind (<linux/uidgid_r.h>); a classic id
+ * is in the first four bytes of e_id, little endian, a UUID or GUID takes
+ * all of it in the byte order of __kernel_uid_r_t. Other entries have
+ * e_type UID_R_NONE.
+ *
+ * getxattr() returns version 2 unless an entry has a UUID or GUID;
+ * setxattr() takes both.
+ */
+#define POSIX_ACL_XATTR_VERSION_R	0x0003
+
+struct posix_acl_xattr_entry_r {
+	__le16			e_tag;
+	__le16			e_perm;
+	__le32			e_type;
+	__u8			e_id[16];
+};
+
 #endif	/* __UAPI_POSIX_ACL_XATTR_H */
-- 
2.56.0

