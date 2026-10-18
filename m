Received: from mout.gmx.net (mout.gmx.net [212.227.15.15])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A25184B923E;
	Sun, 18 Oct 2026 18:02:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.15
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792346525; cv=none; b=Kjjq3K3oiBgaeVj8EhAYZ9/7bmn/GishgzIgFLcZRHMamwKxqz00uchwNJHVSws6eSzurzIvN4s2ob4Zm7WraDZmSH3uKOibsoCZcBDSgNohoTuYwvHXuju12wX7cmYdtlfk6p28bcMyfYqbx5yyvtM6ReDxWoiD36wBbCa5bH0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792346525; c=relaxed/simple;
	bh=3Dh4RPm9tTKtgYwHC4GijHG9+/giqmsTRNubrZsy/z8=;
	h=Message-ID:In-Reply-To:References:From:Subject:To:Cc:Date; b=m5ghtA92rxOtFPNSLL7y8dKPcMK4x1PRlczEBj/RarVdgJUphAyU+FIZ06xhxIK/pvQSJGILTPGbKdBM6hsAs/13afUeX1uGsY7a6CREmfnGMHEft3yGJpBOo37hu2+KAewS1eDwGUNkcYQcFTyjtWBhN1imPs8m7MzAQ9WCYaA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net; spf=pass smtp.mailfrom=gmx.net; dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b=pK77kM7h; arc=none smtp.client-ip=212.227.15.15
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b="pK77kM7h"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.net;
	s=s31663417; t=1792346518; x=1792951318; i=jan.koester@gmx.net;
	bh=X6z2fD+y/ezdaAOL6H9za9dEVinxB/dv9BkJ4TeB8Ac=;
	h=X-UI-Sender-Class:Message-ID:In-Reply-To:References:From:Subject:
	 To:Cc:Date:Content-Transfer-Encoding:cc:content-transfer-encoding:
	 content-type:date:from:message-id:mime-version:reply-to:subject:
	 to;
	b=pK77kM7hrQmV9SBoXrtEPRQwc23gIkYrbpHNi9S+JFSzSTHcK+OomiFk+H2omZ2F
	 cKz5mgPb2dOYQNwRQqIERUffmZKP5flrf8RbEwR2i0iU/7l/YgE6W43F54AeXlXrM
	 +k9uzWrQVU+w/BGQ0/V9+sqlCR70bkUX11XAtmPQ3qX9JJ6IK499ccupwicE9FxGj
	 m2gCgA2ZWJPMkcjzt3WET1luvsdEjQv8ux58LUIaui/vlMoH0x1zDtFfXpyEeIIqk
	 W8QeMwsIBple1rwq6RpciBwkiAo8l797Mp/tRnjRxrKYCb0YnvurTW8WiJXYzAsWd
	 Otjvhnu1McZ/z/ogqg==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from client.hidden.invalid by mail.gmx.net (mrgmx004
 [212.227.17.190]) with ESMTPSA (Nemesis) id 1MFbRs-1xObLk28wY-008OrI; Sun, 18
 Oct 2026 20:01:58 +0200
Message-ID: <dc9b7d0508439f51e97a8320a1675b57e9612f52.1792346472.git.jan.koester@gmx.net>
In-Reply-To: <cover.1792346472.git.jan.koester@gmx.net>
References: <cover.1792346472.git.jan.koester@gmx.net>
From: Jan Koester <jan.koester@gmx.net>
Subject: [RFC PATCH 10/41] uidgid: convert between kernel ids and the ids of
 the *_r system calls
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
Date: Sun, 18 Oct 2026 20:01:31 +0200
X-Provags-ID: V03:K1:+Fx6vjP9fsIzXUBc1OzjxPv92rg8oPmAq4tAoi88atEIe7r1aME
 rcxDwS5Fl2KhEJYBAIGhqovvhT1NWkSCQM9IjYcxqzdfbUbNt+9oPNlRPizr2hded2WRHEz
 4HOCuvdjY7gBUoaAhUEXXjydV9QK2PjjRML4sU1sGuOCy4K3D5uFEbLONZYsI300XviWAL8
 94ZK+mq9Si/sszuxxskMg==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:Eza86R7u46Q=;N8pNCSHT8nmb61WqDV/SZeaLewT
 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
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

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

Signed-off-by: Jan Koester <jan.koester@gmx.net>
=2D--
 include/linux/uidgid.h |  35 +++++
 kernel/Makefile        |   1 +
 kernel/uidgid_r.c      | 323 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 359 insertions(+)
 create mode 100644 kernel/uidgid_r.c

diff --git a/include/linux/uidgid.h b/include/linux/uidgid.h
index e1adb50d5d..ac7786f760 100644
=2D-- a/include/linux/uidgid.h
+++ b/include/linux/uidgid.h
@@ -180,6 +180,17 @@ static inline u32 kgid_hash(kgid_t gid)
 	return __kid_hash(gid.type, __kgid_val(gid), gid.uuid.b);
 }
=20
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
=20
 extern kuid_t make_kuid(struct user_namespace *from, uid_t uid);
@@ -277,4 +288,28 @@ static inline u32 map_id_up(struct uid_gid_map *map, =
u32 id)
 }
 #endif /* CONFIG_USER_NS */
=20
+/*
+ * Conversion between kuid_t/kgid_t and the ids of the *_r system calls
+ * (<uapi/linux/uidgid_r.h>), in kernel/uidgid_r.c.
+ */
+struct __kernel_uid_r;
+
+kuid_t make_kuid_r(struct user_namespace *from, const struct __kernel_uid=
_r *id);
+kgid_t make_kgid_r(struct user_namespace *from, const struct __kernel_uid=
_r *id);
+bool from_kuid_r(struct user_namespace *to, kuid_t uid, struct __kernel_u=
id_r *id);
+bool from_kgid_r(struct user_namespace *to, kgid_t gid, struct __kernel_u=
id_r *id);
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
=2D-- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -89,6 +89,7 @@ obj-$(CONFIG_BACKTRACE_SELF_TEST) +=3D backtracetest.o
 obj-$(CONFIG_COMPAT) +=3D compat.o
 obj-$(CONFIG_CGROUPS) +=3D cgroup/
 obj-$(CONFIG_UTS_NS) +=3D utsname.o
+obj-y +=3D uidgid_r.o
 obj-$(CONFIG_USER_NS) +=3D user_namespace.o
 obj-$(CONFIG_PID_NS) +=3D pid_namespace.o
 obj-$(CONFIG_IKCONFIG) +=3D configs.o
diff --git a/kernel/uidgid_r.c b/kernel/uidgid_r.c
new file mode 100644
index 0000000000..d71aecddb2
=2D-- /dev/null
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
+ * Whether @id is well formed: a known type, reserved bytes zero, a UUID =
of
+ * version 4 with the RFC 9562 variant, a GUID other than the nil GUID.
+ */
+static bool kid_r_valid(const struct __kernel_uid_r *id)
+{
+	switch (id->type) {
+	case UID_R_LEGACY:
+		return !memchr_inv(id->uuid + sizeof(id->legacy), 0,
+				   UID_R_SIZE - sizeof(id->legacy));
+	case UID_R_UUID:
+		return (id->uuid[6] >> 4) =3D=3D 4 && (id->uuid[8] & 0xc0) =3D=3D 0x80;
+	case UID_R_GUID:
+		return memchr_inv(id->guid, 0, UID_R_SIZE);
+	}
+	return false;
+}
+
+/*
+ * The kind and 128 bit value of @id for a kuid_t or kgid_t; false if it =
is
+ * no UUID or GUID or has no mapping in @ns.
+ */
+static bool kid_r_to_128(struct user_namespace *ns,
+			 const struct __kernel_uid_r *id, u32 *type, uuid_t *b)
+{
+	if (!kid_r_valid(id) || ns !=3D &init_user_ns)
+		return false;
+	if (id->type =3D=3D UID_R_UUID)
+		*type =3D KID_UUID;
+	else if (id->type =3D=3D UID_R_GUID)
+		*type =3D KID_GUID;
+	else
+		return false;
+	memcpy(b->b, id->uuid, UID_R_SIZE);
+	return true;
+}
+
+static bool kid_128_to_r(struct user_namespace *ns, u32 type, const uuid_=
t *b,
+			 struct __kernel_uid_r *id)
+{
+	if (ns !=3D &init_user_ns)
+		return false;
+	id->type =3D type =3D=3D KID_UUID ? UID_R_UUID : UID_R_GUID;
+	memcpy(id->uuid, b->b, UID_R_SIZE);
+	return true;
+}
+
+/**
+ * make_kuid_r - map a *_r system call uid into a kuid
+ * @from: user namespace the uid is in
+ * @id: the uid
+ *
+ * Return: the kuid, INVALID_UID if @id is malformed, UID_R_NONE or has n=
o
+ * mapping in @from.
+ */
+kuid_t make_kuid_r(struct user_namespace *from, const struct __kernel_uid=
_r *id)
+{
+	kuid_t uid =3D INVALID_UID;
+
+	if (id->type =3D=3D UID_R_LEGACY && kid_r_valid(id))
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
+ * Return: the kgid, INVALID_GID if @id is malformed, UID_R_NONE or has n=
o
+ * mapping in @from.
+ */
+kgid_t make_kgid_r(struct user_namespace *from, const struct __kernel_uid=
_r *id)
+{
+	kgid_t gid =3D INVALID_GID;
+
+	if (id->type =3D=3D UID_R_LEGACY && kid_r_valid(id))
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
+bool from_kuid_r(struct user_namespace *to, kuid_t uid, struct __kernel_u=
id_r *id)
+{
+	memset(id, 0, sizeof(*id));
+	if (uid_is_legacy(uid)) {
+		uid_t v =3D from_kuid(to, uid);
+
+		if (v =3D=3D (uid_t)-1)
+			return false;
+		id->type =3D UID_R_LEGACY;
+		id->legacy =3D v;
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
+bool from_kgid_r(struct user_namespace *to, kgid_t gid, struct __kernel_u=
id_r *id)
+{
+	memset(id, 0, sizeof(*id));
+	if (gid_is_legacy(gid)) {
+		gid_t v =3D from_kgid(to, gid);
+
+		if (v =3D=3D (gid_t)-1)
+			return false;
+		id->type =3D UID_R_LEGACY;
+		id->legacy =3D v;
+		return true;
+	}
+	return kid_128_to_r(to, gid.type, &gid.uuid, id);
+}
+EXPORT_SYMBOL(from_kgid_r);
+
+/**
+ * from_kuid_r_munged - map a kuid into a *_r system call uid, never fail=
ing
+ * @to: user namespace the uid is wanted in
+ * @uid: the kuid
+ * @id: the uid, overflowuid if @uid has no mapping in @to
+ */
+void from_kuid_r_munged(struct user_namespace *to, kuid_t uid,
+			struct __kernel_uid_r *id)
+{
+	if (!from_kuid_r(to, uid, id)) {
+		id->type =3D UID_R_LEGACY;
+		id->legacy =3D overflowuid;
+	}
+}
+EXPORT_SYMBOL(from_kuid_r_munged);
+
+/**
+ * from_kgid_r_munged - map a kgid into a *_r system call gid, never fail=
ing
+ * @to: user namespace the gid is wanted in
+ * @gid: the kgid
+ * @id: the gid, overflowgid if @gid has no mapping in @to
+ */
+void from_kgid_r_munged(struct user_namespace *to, kgid_t gid,
+			struct __kernel_uid_r *id)
+{
+	if (!from_kgid_r(to, gid, id)) {
+		id->type =3D UID_R_LEGACY;
+		id->legacy =3D overflowgid;
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
+	return id->type =3D=3D UID_R_NONE ||
+	       (id->type =3D=3D UID_R_LEGACY && id->legacy =3D=3D (u32)-1);
+}
+
+/**
+ * get_kuid_r - read a uid of a *_r system call from userspace
+ * @from: user namespace the uid is in
+ * @uid: the uid, or NULL
+ * @kuid: the kuid, INVALID_UID for "no id" (NULL, UID_R_NONE or -1)
+ *
+ * Return: 0, -EFAULT, or -EINVAL if the uid is malformed or has no mappi=
ng
+ * in @from.
+ */
+int get_kuid_r(struct user_namespace *from,
+	       const struct __kernel_uid_r __user *uid, kuid_t *kuid)
+{
+	struct __kernel_uid_r id;
+
+	*kuid =3D INVALID_UID;
+	if (!uid)
+		return 0;
+	if (copy_from_user(&id, uid, sizeof(id)))
+		return -EFAULT;
+	if (kid_r_is_none(&id))
+		return 0;
+	*kuid =3D make_kuid_r(from, &id);
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
+ * Return: 0, -EFAULT, or -EINVAL if the gid is malformed or has no mappi=
ng
+ * in @from.
+ */
+int get_kgid_r(struct user_namespace *from,
+	       const struct __kernel_uid_r __user *gid, kgid_t *kgid)
+{
+	struct __kernel_uid_r id;
+
+	*kgid =3D INVALID_GID;
+	if (!gid)
+		return 0;
+	if (copy_from_user(&id, gid, sizeof(id)))
+		return -EFAULT;
+	if (kid_r_is_none(&id))
+		return 0;
+	*kgid =3D make_kgid_r(from, &id);
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
=2D-=20
2.56.0

