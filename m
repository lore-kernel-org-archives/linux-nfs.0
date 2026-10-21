Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552558;
	b=XDqidlAGBUKmhuHeKtoeXg7ogOmVmHZVnhhRmkPYbks3TPfgKJBxvlxeAYmfDcjWys7t
	 O+I+ZoZerAFMammHEoMHptzOhEUt5vIpxzZr2O3p+OywT+7rpKeZevN4hvQWVOspqKnzP
	 sgpZkeFiyxUWqyaolDpPXqpfrgzUraaMY1wxecfKV2Ch6O69n1bHiR69OFc41LRazlcEW
	 dU2jLWqAV39TxTRIWneAGjtqt/+2LEvpzFh9+eOX0QCqM23CfB9jX3qfvy/5vhICkY8WE
	 TNL10qrPKuPvizG7gD0VSjZ6VJtT+NCvV+TPPg0+feNQWX5XES0uZGgnkltdPn6iF6A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552558;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=+q6+EegZcpse/x9oPfvspHk2SnKoh5IxT9s6j/JTxbE=;
	b=AHvl9lU59DR7rlO8NOwru/Dju7EuX7jgCXhqWJcIRSEHaXfHUgqLgs/MBQFFIRAWBmQl
	 kET5Xffnx/FE+0FeZnH00+Cs2NVhgRCx1QM3NcThDC+k3m1hAR+Gn+WmqPu7ETzST9cfy
	 tJDAkX/1RBD5vl682cVJ59TlVdNndHghSU+KU25FzMNHiiXQn94dlMHsUM9CBLgP+lJSs
	 bqXvGr0n4qnJ9r8mh3tQDNcEvD7iHLldXfTjQJeb31rtBRQ+wCxanKIQLuJ6EGsJvuusy
	 m4ob5ZC6PELZrQmsXlUvNfn0B8JG/d760XImxCqDfW2XNvUq0kTikN8nmvuLqQE1dJQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=WLm6Xnsm;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E17A760A262E;
	Wed, 21 Oct 2026 03:15:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E17A760A262E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=WLm6Xnsm
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552555; bh=csY9X+C3GBbeXTgADFasB+JIpeOQ0IJngYqXFeoywj4=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=WLm6Xnsme2O0zDf969fQJgTSLAcjcfnNzch5q4ou3l8q/bTjN7Jsn3kWYUhrrJFbC
	 toaUbYiRQvErtj7KxcWq/DEIUfP7dlTqeQ7ZYchHrdTb3lzcmdJLZpYEttnkaJxKgD
	 Uge6PuaMsirww+i74AJReawC8WWQFWAoltpon5rWGUK+cb+CzlDAwGW+j2lQlxV+ys
	 1PQLkx/gOIxyMu1T8Y0HuagxtP6ATBAQ7uIcMXqh32UJm5rSsH5W5BO4P54TKQjIex
	 5QubnWzjgiSu24CMQeUvQYT+o9jEtliPpCPxBPhl2H1fCKMYvR/HCSBBpWTW4BddFj
	 EiF4wtpDCszLw==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id DB3FF8A0912;
	Wed, 21 Oct 2026 05:15:54 +0200 (CEST)
Message-ID: <42176587b0491de4d74cc6c8dde7e035ffd44661.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 10/41] uidgid: convert between kernel ids and the ids
 of the *_r system calls
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
Date: Wed, 21 Oct 2026 05:15:30 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Add the conversions between kuid_t/kgid_t and __kernel_uid_r_t the new
system calls need: make_kuid_r(), from_kuid_r() and the never failing
from_kuid_r_munged() (and the gid variants), and get_kuid_r() and
put_kuid_r() to copy them from and to userspace.

get_kuid_r() returns INVALID_UID for "no id" -- a NULL pointer,
UID_R_NONE, or a classic -1 -- which the set*id_r() and chown_r() calls
take as "unchanged", like the classic calls take -1. It rejects
malformed ids: unknown types, nonzero reserved bytes, UUIDs other than
RFC 9562 version 4, the nil GUID, and UUIDs or GUIDs given from outside
the initial user namespace.

Also add kuid_str() and kgid_str(), the text form of an id for logs and
procfs: a classic id in decimal, a UUID as usual, a GUID in braces.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 include/linux/uidgid.h |  35 +++++
 kernel/Makefile        |   1 +
 kernel/uidgid_r.c      | 323 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 359 insertions(+)
 create mode 100644 kernel/uidgid_r.c

diff --git a/include/linux/uidgid.h b/include/linux/uidgid.h
index e1adb50d5d..ac7786f760 100644
--- a/include/linux/uidgid.h
+++ b/include/linux/uidgid.h
@@ -180,6 +180,17 @@ static inline u32 kgid_hash(kgid_t gid)
 	return __kid_hash(gid.type, __kgid_val(gid), gid.uuid.b);
 }
 
+/*
+ * The text form of an id, for logs and procfs: a legacy id as a decimal
+ * number, a UUID as "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" and a GUID in
+ * braces, "{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}". KID_STR_LEN includes
+ * the terminating NUL.
+ */
+#define KID_STR_LEN 39
+
+char *kuid_str(kuid_t uid, char buf[KID_STR_LEN]);
+char *kgid_str(kgid_t gid, char buf[KID_STR_LEN]);
+
 #ifdef CONFIG_USER_NS
 
 extern kuid_t make_kuid(struct user_namespace *from, uid_t uid);
@@ -277,4 +288,28 @@ static inline u32 map_id_up(struct uid_gid_map *map, u32 id)
 }
 #endif /* CONFIG_USER_NS */
 
+/*
+ * Conversion between kuid_t/kgid_t and the ids of the *_r system calls
+ * (<uapi/linux/uidgid_r.h>), in kernel/uidgid_r.c.
+ */
+struct __kernel_uid_r;
+
+kuid_t make_kuid_r(struct user_namespace *from, const struct __kernel_uid_r *id);
+kgid_t make_kgid_r(struct user_namespace *from, const struct __kernel_uid_r *id);
+bool from_kuid_r(struct user_namespace *to, kuid_t uid, struct __kernel_uid_r *id);
+bool from_kgid_r(struct user_namespace *to, kgid_t gid, struct __kernel_uid_r *id);
+void from_kuid_r_munged(struct user_namespace *to, kuid_t uid,
+			struct __kernel_uid_r *id);
+void from_kgid_r_munged(struct user_namespace *to, kgid_t gid,
+			struct __kernel_uid_r *id);
+
+int get_kuid_r(struct user_namespace *from,
+	       const struct __kernel_uid_r __user *uid, kuid_t *kuid);
+int get_kgid_r(struct user_namespace *from,
+	       const struct __kernel_uid_r __user *gid, kgid_t *kgid);
+int put_kuid_r(struct user_namespace *to, kuid_t kuid,
+	       struct __kernel_uid_r __user *uid);
+int put_kgid_r(struct user_namespace *to, kgid_t kgid,
+	       struct __kernel_uid_r __user *gid);
+
 #endif /* _LINUX_UIDGID_H */
diff --git a/kernel/Makefile b/kernel/Makefile
index 1e1a316735..813ddbf115 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -89,6 +89,7 @@ obj-$(CONFIG_BACKTRACE_SELF_TEST) += backtracetest.o
 obj-$(CONFIG_COMPAT) += compat.o
 obj-$(CONFIG_CGROUPS) += cgroup/
 obj-$(CONFIG_UTS_NS) += utsname.o
+obj-y += uidgid_r.o
 obj-$(CONFIG_USER_NS) += user_namespace.o
 obj-$(CONFIG_PID_NS) += pid_namespace.o
 obj-$(CONFIG_IKCONFIG) += configs.o
diff --git a/kernel/uidgid_r.c b/kernel/uidgid_r.c
new file mode 100644
index 0000000000..d71aecddb2
--- /dev/null
+++ b/kernel/uidgid_r.c
@@ -0,0 +1,323 @@
+// SPDX-License-Identifier: GPL-2.0-only
+/*
+ * Conversion between kuid_t/kgid_t and the ids of the *_r system calls
+ * (<uapi/linux/uidgid_r.h>).
+ */
+
+#include <linux/export.h>
+#include <linux/highuid.h>
+#include <linux/sprintf.h>
+#include <linux/string.h>
+#include <linux/uaccess.h>
+#include <linux/uidgid.h>
+#include <linux/uidgid_r.h>
+#include <linux/user_namespace.h>
+
+/*
+ * Whether @id is well formed: a known type, reserved bytes zero, a UUID of
+ * version 4 with the RFC 9562 variant, a GUID other than the nil GUID.
+ */
+static bool kid_r_valid(const struct __kernel_uid_r *id)
+{
+	switch (id->type) {
+	case UID_R_LEGACY:
+		return !memchr_inv(id->uuid + sizeof(id->legacy), 0,
+				   UID_R_SIZE - sizeof(id->legacy));
+	case UID_R_UUID:
+		return (id->uuid[6] >> 4) == 4 && (id->uuid[8] & 0xc0) == 0x80;
+	case UID_R_GUID:
+		return memchr_inv(id->guid, 0, UID_R_SIZE);
+	}
+	return false;
+}
+
+/*
+ * The kind and 128 bit value of @id for a kuid_t or kgid_t; false if it is
+ * no UUID or GUID or has no mapping in @ns.
+ */
+static bool kid_r_to_128(struct user_namespace *ns,
+			 const struct __kernel_uid_r *id, u32 *type, uuid_t *b)
+{
+	if (!kid_r_valid(id) || ns != &init_user_ns)
+		return false;
+	if (id->type == UID_R_UUID)
+		*type = KID_UUID;
+	else if (id->type == UID_R_GUID)
+		*type = KID_GUID;
+	else
+		return false;
+	memcpy(b->b, id->uuid, UID_R_SIZE);
+	return true;
+}
+
+static bool kid_128_to_r(struct user_namespace *ns, u32 type, const uuid_t *b,
+			 struct __kernel_uid_r *id)
+{
+	if (ns != &init_user_ns)
+		return false;
+	id->type = type == KID_UUID ? UID_R_UUID : UID_R_GUID;
+	memcpy(id->uuid, b->b, UID_R_SIZE);
+	return true;
+}
+
+/**
+ * make_kuid_r - map a *_r system call uid into a kuid
+ * @from: user namespace the uid is in
+ * @id: the uid
+ *
+ * Return: the kuid, INVALID_UID if @id is malformed, UID_R_NONE or has no
+ * mapping in @from.
+ */
+kuid_t make_kuid_r(struct user_namespace *from, const struct __kernel_uid_r *id)
+{
+	kuid_t uid = INVALID_UID;
+
+	if (id->type == UID_R_LEGACY && kid_r_valid(id))
+		return make_kuid(from, id->legacy);
+	if (!kid_r_to_128(from, id, &uid.type, &uid.uuid))
+		return INVALID_UID;
+	return uid;
+}
+EXPORT_SYMBOL(make_kuid_r);
+
+/**
+ * make_kgid_r - map a *_r system call gid into a kgid
+ * @from: user namespace the gid is in
+ * @id: the gid
+ *
+ * Return: the kgid, INVALID_GID if @id is malformed, UID_R_NONE or has no
+ * mapping in @from.
+ */
+kgid_t make_kgid_r(struct user_namespace *from, const struct __kernel_uid_r *id)
+{
+	kgid_t gid = INVALID_GID;
+
+	if (id->type == UID_R_LEGACY && kid_r_valid(id))
+		return make_kgid(from, id->legacy);
+	if (!kid_r_to_128(from, id, &gid.type, &gid.uuid))
+		return INVALID_GID;
+	return gid;
+}
+EXPORT_SYMBOL(make_kgid_r);
+
+/**
+ * from_kuid_r - map a kuid into a *_r system call uid
+ * @to: user namespace the uid is wanted in
+ * @uid: the kuid
+ * @id: the uid, all zero (UID_R_NONE) if there is no mapping
+ *
+ * Return: whether @uid has a mapping in @to.
+ */
+bool from_kuid_r(struct user_namespace *to, kuid_t uid, struct __kernel_uid_r *id)
+{
+	memset(id, 0, sizeof(*id));
+	if (uid_is_legacy(uid)) {
+		uid_t v = from_kuid(to, uid);
+
+		if (v == (uid_t)-1)
+			return false;
+		id->type = UID_R_LEGACY;
+		id->legacy = v;
+		return true;
+	}
+	return kid_128_to_r(to, uid.type, &uid.uuid, id);
+}
+EXPORT_SYMBOL(from_kuid_r);
+
+/**
+ * from_kgid_r - map a kgid into a *_r system call gid
+ * @to: user namespace the gid is wanted in
+ * @gid: the kgid
+ * @id: the gid, all zero (UID_R_NONE) if there is no mapping
+ *
+ * Return: whether @gid has a mapping in @to.
+ */
+bool from_kgid_r(struct user_namespace *to, kgid_t gid, struct __kernel_uid_r *id)
+{
+	memset(id, 0, sizeof(*id));
+	if (gid_is_legacy(gid)) {
+		gid_t v = from_kgid(to, gid);
+
+		if (v == (gid_t)-1)
+			return false;
+		id->type = UID_R_LEGACY;
+		id->legacy = v;
+		return true;
+	}
+	return kid_128_to_r(to, gid.type, &gid.uuid, id);
+}
+EXPORT_SYMBOL(from_kgid_r);
+
+/**
+ * from_kuid_r_munged - map a kuid into a *_r system call uid, never failing
+ * @to: user namespace the uid is wanted in
+ * @uid: the kuid
+ * @id: the uid, overflowuid if @uid has no mapping in @to
+ */
+void from_kuid_r_munged(struct user_namespace *to, kuid_t uid,
+			struct __kernel_uid_r *id)
+{
+	if (!from_kuid_r(to, uid, id)) {
+		id->type = UID_R_LEGACY;
+		id->legacy = overflowuid;
+	}
+}
+EXPORT_SYMBOL(from_kuid_r_munged);
+
+/**
+ * from_kgid_r_munged - map a kgid into a *_r system call gid, never failing
+ * @to: user namespace the gid is wanted in
+ * @gid: the kgid
+ * @id: the gid, overflowgid if @gid has no mapping in @to
+ */
+void from_kgid_r_munged(struct user_namespace *to, kgid_t gid,
+			struct __kernel_uid_r *id)
+{
+	if (!from_kgid_r(to, gid, id)) {
+		id->type = UID_R_LEGACY;
+		id->legacy = overflowgid;
+	}
+}
+EXPORT_SYMBOL(from_kgid_r_munged);
+
+/*
+ * "No id" from userspace: no pointer, UID_R_NONE, or the classic -1. The
+ * set*id_r() and chown_r() calls take it as "leave unchanged".
+ */
+static bool kid_r_is_none(const struct __kernel_uid_r *id)
+{
+	return id->type == UID_R_NONE ||
+	       (id->type == UID_R_LEGACY && id->legacy == (u32)-1);
+}
+
+/**
+ * get_kuid_r - read a uid of a *_r system call from userspace
+ * @from: user namespace the uid is in
+ * @uid: the uid, or NULL
+ * @kuid: the kuid, INVALID_UID for "no id" (NULL, UID_R_NONE or -1)
+ *
+ * Return: 0, -EFAULT, or -EINVAL if the uid is malformed or has no mapping
+ * in @from.
+ */
+int get_kuid_r(struct user_namespace *from,
+	       const struct __kernel_uid_r __user *uid, kuid_t *kuid)
+{
+	struct __kernel_uid_r id;
+
+	*kuid = INVALID_UID;
+	if (!uid)
+		return 0;
+	if (copy_from_user(&id, uid, sizeof(id)))
+		return -EFAULT;
+	if (kid_r_is_none(&id))
+		return 0;
+	*kuid = make_kuid_r(from, &id);
+	return uid_valid(*kuid) ? 0 : -EINVAL;
+}
+EXPORT_SYMBOL(get_kuid_r);
+
+/**
+ * get_kgid_r - read a gid of a *_r system call from userspace
+ * @from: user namespace the gid is in
+ * @gid: the gid, or NULL
+ * @kgid: the kgid, INVALID_GID for "no id" (NULL, UID_R_NONE or -1)
+ *
+ * Return: 0, -EFAULT, or -EINVAL if the gid is malformed or has no mapping
+ * in @from.
+ */
+int get_kgid_r(struct user_namespace *from,
+	       const struct __kernel_uid_r __user *gid, kgid_t *kgid)
+{
+	struct __kernel_uid_r id;
+
+	*kgid = INVALID_GID;
+	if (!gid)
+		return 0;
+	if (copy_from_user(&id, gid, sizeof(id)))
+		return -EFAULT;
+	if (kid_r_is_none(&id))
+		return 0;
+	*kgid = make_kgid_r(from, &id);
+	return gid_valid(*kgid) ? 0 : -EINVAL;
+}
+EXPORT_SYMBOL(get_kgid_r);
+
+/**
+ * put_kuid_r - write a kuid to userspace as a *_r system call uid
+ * @to: user namespace the uid is wanted in
+ * @kuid: the kuid
+ * @uid: where to put it, overflowuid if @kuid has no mapping in @to
+ *
+ * Return: 0 or -EFAULT.
+ */
+int put_kuid_r(struct user_namespace *to, kuid_t kuid,
+	       struct __kernel_uid_r __user *uid)
+{
+	struct __kernel_uid_r id;
+
+	from_kuid_r_munged(to, kuid, &id);
+	return copy_to_user(uid, &id, sizeof(id)) ? -EFAULT : 0;
+}
+EXPORT_SYMBOL(put_kuid_r);
+
+/**
+ * put_kgid_r - write a kgid to userspace as a *_r system call gid
+ * @to: user namespace the gid is wanted in
+ * @kgid: the kgid
+ * @gid: where to put it, overflowgid if @kgid has no mapping in @to
+ *
+ * Return: 0 or -EFAULT.
+ */
+int put_kgid_r(struct user_namespace *to, kgid_t kgid,
+	       struct __kernel_uid_r __user *gid)
+{
+	struct __kernel_uid_r id;
+
+	from_kgid_r_munged(to, kgid, &id);
+	return copy_to_user(gid, &id, sizeof(id)) ? -EFAULT : 0;
+}
+EXPORT_SYMBOL(put_kgid_r);
+
+static char *kid_str(u32 type, u32 legacy, const uuid_t *b, char *buf)
+{
+	switch (type) {
+	case KID_LEGACY:
+		snprintf(buf, KID_STR_LEN, "%u", legacy);
+		break;
+	case KID_UUID:
+		snprintf(buf, KID_STR_LEN, "%pUb", b);
+		break;
+	default:
+		snprintf(buf, KID_STR_LEN, "{%pUl}", b);
+		break;
+	}
+	return buf;
+}
+
+/**
+ * kuid_str - text form of a kuid, for logs and procfs
+ * @uid: the kuid
+ * @buf: buffer of KID_STR_LEN bytes
+ *
+ * Return: @buf, holding @uid in the initial user namespace: a decimal
+ * number, a UUID, or a GUID in braces.
+ */
+char *kuid_str(kuid_t uid, char buf[KID_STR_LEN])
+{
+	return kid_str(uid.type, __kuid_val(uid), &uid.uuid, buf);
+}
+EXPORT_SYMBOL(kuid_str);
+
+/**
+ * kgid_str - text form of a kgid, for logs and procfs
+ * @gid: the kgid
+ * @buf: buffer of KID_STR_LEN bytes
+ *
+ * Return: @buf, holding @gid in the initial user namespace: a decimal
+ * number, a UUID, or a GUID in braces.
+ */
+char *kgid_str(kgid_t gid, char buf[KID_STR_LEN])
+{
+	return kid_str(gid.type, __kgid_val(gid), &gid.uuid, buf);
+}
+EXPORT_SYMBOL(kgid_str);
-- 
2.56.0

