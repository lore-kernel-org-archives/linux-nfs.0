Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552639;
	b=OUpWa4EcfJOGLnu/sqnvDgAD9HKZkvlUQ0ppK0NFUENIN4WAoQXExTEauEC8qpg4e3mf
	 0QEIqYKuu1PXXoj6j0yLqSvdLxOIaRuJu21ngPkSr8L/7VJX/CMZLn0bqtZnFMdZ91G8J
	 B4da2XrLnjMJV/TZnFQ+1goA2s0msYDxOZdSSnggzdCk/h0vzc3vW8XZYZOlv8Aq+RRzn
	 KvWmO4n0MddtiwAFp3WbgDc/x/ZKBJ6FkVRnIUVYGTVn4n6JVsrcxD6HABlIBDYw+rONt
	 Y1gQOTIr68zUpfNizuW98n9DX3YlqNmYja+wRKYC19Xvrww7YXt3wQ6rgUSrIfOutbA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552639;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=gfFBA8LH4gfsSKNHEPmNQ/vWCOtrs7FdgWk9k3JrBHg=;
	b=Yba0laho60HZzfL9vOFJfOjRp4UV7VKZnh75x3NSp6aAmFo7gz+GvzV0ez2c19Uwoa9a
	 9DSyMZG3LxQGxjEDiYtYcd9KPTRI0Snzu1Rq7YlWXTgjIVA8suxKxN4A8cnq4ECKwmQI5
	 BlsoG+YmZ98PxevXR1ypiq6bEnYSbuZnmk2Xf5FIIZIK7afGvo/y66/5L06o/QVBrcPW1
	 L2NYzboz2Zdkhb6JK06S7g/LEJ+ugahH1ImVS/mHe6co51Y7rRI2eiPw4OBqeSRqYF6S/
	 3j/vC3y4J4Y/1EtzLq4eRryrn4K00QrC6noZiV9X+YOekPPWunjtjeBZjdbjW6F4Y/Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=W4BT9TNR;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0926460A382C;
	Wed, 21 Oct 2026 03:17:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0926460A382C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=W4BT9TNR
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552637; bh=c/MatJ7zCmct39K83og7TVItx3cItrvprM66Ihgbc+M=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=W4BT9TNRFBeCPYk+tKtWArqh4Ur5DtLo0vljyceBtP8rbavEfHigwo1frJ3i62gYx
	 z3krisNdVJ37oqMsaK2uyqmWlj6j5QRmocqzrfCSlVaqAvdn3FKeDZ06WL8JdAekBj
	 E7aIKHC3FMOIOS6+6iOaSGE3W0UvLoa7fVNArUs6w3C4w28+pp0TpyIfGYnkbePujE
	 16fIfgDl5Cn9Nm9qlMDXuTLW1NKDlP+Y5bs4b4R+tLarpLnDRLArLHntkMoIxtIP6z
	 1Inqg2AngQKfLy0kxk0oelvGjx6iRqmwZ+SAdL2RVR8iQHys3D5Y0RxckrhsVDOmsM
	 eQW3xgoajXseg==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 71B0F8A091B;
	Wed, 21 Oct 2026 05:17:16 +0200 (CEST)
Message-ID: <98758113db07083faeb158948b6b3362c2795231.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 34/41] ext4: store ACLs with UUID and GUID entries on
 uid_r filesystems
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
Date: Wed, 21 Oct 2026 05:15:54 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

ACLs whose ACL_USER or ACL_GROUP entries are UUIDs or GUIDs are written
in a new on-disk format, EXT4_ACL_VERSION_R: the short entries stay as
they are, the user and group entries carry an EXT4_ID_R_* kind and 16
bytes of id. Only such ACLs use it, and only uid_r filesystems can have
them (set_posix_acl() refuses them elsewhere); all other ACLs keep
EXT4_ACL_VERSION.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/ext4/acl.c | 109 +++++++++++++++++++++++++++++++++++++++-----------
 fs/ext4/acl.h |  34 +++++++++++++---
 2 files changed, 115 insertions(+), 28 deletions(-)

diff --git a/fs/ext4/acl.c b/fs/ext4/acl.c
index 3bffe862f9..27f8a1b503 100644
--- a/fs/ext4/acl.c
+++ b/fs/ext4/acl.c
@@ -6,6 +6,7 @@
  */
 
 #include <linux/quotaops.h>
+#include <linux/unaligned.h>
 #include "ext4_jbd2.h"
 #include "ext4.h"
 #include "xattr.h"
@@ -14,22 +15,41 @@
 /*
  * Convert from filesystem to in-memory representation.
  */
+/* The id of an ACL_USER or ACL_GROUP entry of EXT4_ACL_VERSION_R */
+static int ext4_acl_id_from_disk(const ext4_acl_entry_r *entry, u32 *type,
+				 u32 *legacy, uuid_t *id)
+{
+	*type = le32_to_cpu(entry->e_type);
+	if (*type > EXT4_ID_R_GUID)
+		return -EINVAL;
+	*legacy = get_unaligned_le32(entry->e_id);
+	memcpy(id->b, entry->e_id, sizeof(id->b));
+	return 0;
+}
+
 static struct posix_acl *
 ext4_acl_from_disk(const void *value, size_t size)
 {
 	const char *end = (char *)value + size;
 	int n, count;
 	struct posix_acl *acl;
+	size_t entry_size = sizeof(ext4_acl_entry);
+	bool r = false;
 
 	if (!value)
 		return NULL;
 	if (size < sizeof(ext4_acl_header))
 		 return ERR_PTR(-EINVAL);
-	if (((ext4_acl_header *)value)->a_version !=
-	    cpu_to_le32(EXT4_ACL_VERSION))
+	if (((ext4_acl_header *)value)->a_version ==
+	    cpu_to_le32(EXT4_ACL_VERSION_R)) {
+		r = true;
+		entry_size = sizeof(ext4_acl_entry_r);
+	} else if (((ext4_acl_header *)value)->a_version !=
+		   cpu_to_le32(EXT4_ACL_VERSION)) {
 		return ERR_PTR(-EINVAL);
+	}
 	value = (char *)value + sizeof(ext4_acl_header);
-	count = ext4_acl_count(size);
+	count = ext4_acl_count_e(size, entry_size);
 	if (count < 0)
 		return ERR_PTR(-EINVAL);
 	if (count == 0)
@@ -55,21 +75,33 @@ ext4_acl_from_disk(const void *value, size_t size)
 			break;
 
 		case ACL_USER:
-			value = (char *)value + sizeof(ext4_acl_entry);
+		case ACL_GROUP: {
+			u32 type = EXT4_ID_R_LEGACY, legacy;
+			uuid_t id;
+
+			value = (char *)value + entry_size;
 			if ((char *)value > end)
 				goto fail;
-			acl->a_entries[n].e_uid =
-				make_kuid(&init_user_ns,
-					  le32_to_cpu(entry->e_id));
-			break;
-		case ACL_GROUP:
-			value = (char *)value + sizeof(ext4_acl_entry);
-			if ((char *)value > end)
+			legacy = le32_to_cpu(entry->e_id);
+			if (r && ext4_acl_id_from_disk((void *)entry, &type,
+						       &legacy, &id))
 				goto fail;
-			acl->a_entries[n].e_gid =
-				make_kgid(&init_user_ns,
-					  le32_to_cpu(entry->e_id));
+			if (acl->a_entries[n].e_tag == ACL_USER)
+				acl->a_entries[n].e_uid =
+					type == EXT4_ID_R_LEGACY ?
+					make_kuid(&init_user_ns, legacy) :
+					type == EXT4_ID_R_UUID ?
+					KUIDT_INIT_UUID(id) :
+					KUIDT_INIT_GUID(*(guid_t *)&id);
+			else
+				acl->a_entries[n].e_gid =
+					type == EXT4_ID_R_LEGACY ?
+					make_kgid(&init_user_ns, legacy) :
+					type == EXT4_ID_R_UUID ?
+					KGIDT_INIT_UUID(id) :
+					KGIDT_INIT_GUID(*(guid_t *)&id);
 			break;
+		}
 
 		default:
 			goto fail;
@@ -87,19 +119,38 @@ ext4_acl_from_disk(const void *value, size_t size)
 /*
  * Convert from in-memory to filesystem representation.
  */
+/* An ACL_USER or ACL_GROUP id into an entry of EXT4_ACL_VERSION_R */
+static void ext4_acl_id_to_disk(ext4_acl_entry_r *entry, u32 type, u32 legacy,
+				const uuid_t *id)
+{
+	entry->e_type = cpu_to_le32(type);
+	memset(entry->e_id, 0, sizeof(entry->e_id));
+	if (type == EXT4_ID_R_LEGACY)
+		put_unaligned_le32(legacy, entry->e_id);
+	else
+		memcpy(entry->e_id, id->b, sizeof(entry->e_id));
+}
+
+/*
+ * ACLs with UUID or GUID entries (only on uid_r filesystems, see
+ * set_posix_acl()) are written as EXT4_ACL_VERSION_R, others as before.
+ */
 static void *
 ext4_acl_to_disk(const struct posix_acl *acl, size_t *size)
 {
 	ext4_acl_header *ext_acl;
 	char *e;
 	size_t n;
+	bool r = posix_acl_has_id_r(acl);
+	size_t entry_size = r ? sizeof(ext4_acl_entry_r) : sizeof(ext4_acl_entry);
 
-	*size = ext4_acl_size(acl->a_count);
+	*size = ext4_acl_size_e(acl->a_count, entry_size);
 	ext_acl = kmalloc(sizeof(ext4_acl_header) + acl->a_count *
-			sizeof(ext4_acl_entry), GFP_NOFS);
+			entry_size, GFP_NOFS);
 	if (!ext_acl)
 		return ERR_PTR(-ENOMEM);
-	ext_acl->a_version = cpu_to_le32(EXT4_ACL_VERSION);
+	ext_acl->a_version = cpu_to_le32(r ? EXT4_ACL_VERSION_R :
+					     EXT4_ACL_VERSION);
 	e = (char *)ext_acl + sizeof(ext4_acl_header);
 	for (n = 0; n < acl->a_count; n++) {
 		const struct posix_acl_entry *acl_e = &acl->a_entries[n];
@@ -108,14 +159,26 @@ ext4_acl_to_disk(const struct posix_acl *acl, size_t *size)
 		entry->e_perm = cpu_to_le16(acl_e->e_perm);
 		switch (acl_e->e_tag) {
 		case ACL_USER:
-			entry->e_id = cpu_to_le32(
-				from_kuid(&init_user_ns, acl_e->e_uid));
-			e += sizeof(ext4_acl_entry);
+			if (r)
+				ext4_acl_id_to_disk((void *)entry,
+						    acl_e->e_uid.type,
+						    from_kuid(&init_user_ns, acl_e->e_uid),
+						    &acl_e->e_uid.uuid);
+			else
+				entry->e_id = cpu_to_le32(
+					from_kuid(&init_user_ns, acl_e->e_uid));
+			e += entry_size;
 			break;
 		case ACL_GROUP:
-			entry->e_id = cpu_to_le32(
-				from_kgid(&init_user_ns, acl_e->e_gid));
-			e += sizeof(ext4_acl_entry);
+			if (r)
+				ext4_acl_id_to_disk((void *)entry,
+						    acl_e->e_gid.type,
+						    from_kgid(&init_user_ns, acl_e->e_gid),
+						    &acl_e->e_gid.uuid);
+			else
+				entry->e_id = cpu_to_le32(
+					from_kgid(&init_user_ns, acl_e->e_gid));
+			e += entry_size;
 			break;
 
 		case ACL_USER_OBJ:
diff --git a/fs/ext4/acl.h b/fs/ext4/acl.h
index 0c5a79c3b5..48bc352ec7 100644
--- a/fs/ext4/acl.h
+++ b/fs/ext4/acl.h
@@ -8,6 +8,8 @@
 #include <linux/posix_acl_xattr.h>
 
 #define EXT4_ACL_VERSION	0x0001
+/* uid_r: ACL_USER and ACL_GROUP entries are ext4_acl_entry_r */
+#define EXT4_ACL_VERSION_R	0x0002
 
 typedef struct {
 	__le16		e_tag;
@@ -20,11 +22,23 @@ typedef struct {
 	__le16		e_perm;
 } ext4_acl_entry_short;
 
+/*
+ * EXT4_ACL_VERSION_R: e_type an EXT4_ID_R_* kind, a classic id in the
+ * first four bytes of e_id (little endian), a UUID or GUID all of it
+ */
+typedef struct {
+	__le16		e_tag;
+	__le16		e_perm;
+	__le32		e_type;
+	__u8		e_id[16];
+} ext4_acl_entry_r;
+
 typedef struct {
 	__le32		a_version;
 } ext4_acl_header;
 
-static inline size_t ext4_acl_size(int count)
+/* @entry: sizeof(ext4_acl_entry) or, for EXT4_ACL_VERSION_R, of _r */
+static inline size_t ext4_acl_size_e(int count, size_t entry)
 {
 	if (count <= 4) {
 		return sizeof(ext4_acl_header) +
@@ -32,11 +46,11 @@ static inline size_t ext4_acl_size(int count)
 	} else {
 		return sizeof(ext4_acl_header) +
 		       4 * sizeof(ext4_acl_entry_short) +
-		       (count - 4) * sizeof(ext4_acl_entry);
+		       (count - 4) * entry;
 	}
 }
 
-static inline int ext4_acl_count(size_t size)
+static inline int ext4_acl_count_e(size_t size, size_t entry)
 {
 	ssize_t s;
 	size -= sizeof(ext4_acl_header);
@@ -46,12 +60,22 @@ static inline int ext4_acl_count(size_t size)
 			return -1;
 		return size / sizeof(ext4_acl_entry_short);
 	} else {
-		if (s % sizeof(ext4_acl_entry))
+		if (s % entry)
 			return -1;
-		return s / sizeof(ext4_acl_entry) + 4;
+		return s / entry + 4;
 	}
 }
 
+static inline size_t ext4_acl_size(int count)
+{
+	return ext4_acl_size_e(count, sizeof(ext4_acl_entry));
+}
+
+static inline int ext4_acl_count(size_t size)
+{
+	return ext4_acl_count_e(size, sizeof(ext4_acl_entry));
+}
+
 #ifdef CONFIG_EXT4_FS_POSIX_ACL
 
 /* acl.c */
-- 
2.56.0

