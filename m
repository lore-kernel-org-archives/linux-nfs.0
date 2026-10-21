Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552609;
	b=tuvzwwFaYT9bXoDLq4eXrznsJYIToZ4tnJrH9zqeB/zocppDHxhQtRXKXlo5aV0lgC+w
	 a0QpUeNQmzlqBp+zaVz0smkNAl03rc7I7kR0/LFv1BVSIYh+Z34PoKq/nJbioTvyJusb6
	 bVIvPF08Ssf7KmXskj9E8sJ6QbXYXFNCnYr/IVksuKjRzKuWfN7QTTw9hbKfYen6luhdB
	 EODU0OXnI0UPYAbjaYUWrCNbex2UC3/Ov4XfvELxVBLWwLhZLEQXEYciyev7Zh6cM/fxf
	 uBH0tkLop/zmA+QyGAwSz5Ula8oyiMGtav9d/BpBB5Zp60n+XklIoEDq3B/pej2sb+A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552609;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=XPetBJfDkAzAZ8UTDQicbQRK+iH8jjbopwvCHr+wr6I=;
	b=xlRKqqNnHr5O2yYiHYPDxlX6Xrp63nWY9XDVOY5Ly/pIbS6Gd0vm3t8GDN8qzivoNUEp
	 B7pDyQdjxfIY81Vbx1f28QUtwUcva9WqSryJk2RYW+btwyeX5D6sOd/FUpJ96oEj8tAy2
	 y3Bc9zo4hqIe+seRORQEDx56+tC+EaRd4iUwfNrUoGDPmntyqntd2sUQiSVveAzkUPiSu
	 X0QEsMrjF2NcjuX+qUxUK9FXLkOZrUYPBGsHTBNjDwO6eILxgTsPP2pTChVZ2xkMZYoyk
	 8sxHUX47lvcw+QXHIbaemqTOcX9NyNyvdbGUZYEshnbhYwkOUv3hM4BP82WbDBu1NKw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=MvZnv28O;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5BE5A607095A;
	Wed, 21 Oct 2026 03:16:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5BE5A607095A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=MvZnv28O
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552606; bh=vR17OcW5DP2to57LMQkJCXz9sOVicwks2xNBVa+gK/c=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=MvZnv28OBDboO1Uckg4VHuK/UCnr5rurzSeDn9rh3CM8Oi+8NpNgWNtkIccYx5qyF
	 ndW6QFNpKp4H1P/4JvmDSWzdVIoAEaNqTq0xoPzvfxt/e9z2vys6oMeRq/oKDBtAKX
	 +aN+sOmHrfuEdV51ZZ2r9g7Wr8TdKTAbfDMuwOcjaJRjx2hJlcsYGzARDsqfxqV/ox
	 pXIMjzH5sYuB/rluXQcqmrcXuXG3EFvM9A7sdlk/Mb+bGwKBVX2e/Nd0FT74brAjMl
	 Uv8wqwMlruNGr/0anQBZWwG1U3ZR6i99bXdWRuTg5MYbLZTBKM77f30XEu7RAoTaFi
	 ZGVDd4t4+1GaQ==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id B90608A096E;
	Wed, 21 Oct 2026 05:16:45 +0200 (CEST)
Message-ID: <1151adfbb3aeae57cb26df8723287857f8d0af57.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 25/41] uidgid: parse and print ids in their text form
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
Date: Wed, 21 Oct 2026 05:15:45 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Add helpers for interfaces that pass ids as text:

- make_kuid_str()/make_kgid_str() parse what kuid_str() writes: a
  decimal number, a UUID, or a GUID in braces,
- kuid_str_munged()/kgid_str_munged() write an id as seen from a user
  namespace, the overflow id if it has no mapping there,
- kuid_str_signed()/kgid_str_signed() write a legacy id as a signed
  number, for output that used "%d",
- KUID_STR() and friends wrap them as expressions with a buffer of the
  enclosing block, so that printf-like calls can replace
  "%u", from_kuid(&init_user_ns, uid) by "%s", KUID_STR(uid) and print
  legacy ids exactly as before.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 include/linux/uidgid.h |  19 ++++++
 kernel/uidgid_r.c      | 152 +++++++++++++++++++++++++++++++++++++++--
 2 files changed, 167 insertions(+), 4 deletions(-)

diff --git a/include/linux/uidgid.h b/include/linux/uidgid.h
index ac7786f760..03ece8a4cb 100644
--- a/include/linux/uidgid.h
+++ b/include/linux/uidgid.h
@@ -190,6 +190,25 @@ static inline u32 kgid_hash(kgid_t gid)
 
 char *kuid_str(kuid_t uid, char buf[KID_STR_LEN]);
 char *kgid_str(kgid_t gid, char buf[KID_STR_LEN]);
+char *kuid_str_signed(kuid_t uid, char buf[KID_STR_LEN]);
+char *kgid_str_signed(kgid_t gid, char buf[KID_STR_LEN]);
+
+/*
+ * The text form of an id as an expression, in a buffer that lives until
+ * the end of the enclosing block -- for "%s" in place of "%u" (or "%d",
+ * with the _D variants, which write a legacy id as a signed number) of
+ * from_kuid(&init_user_ns, uid) in printf-like calls.
+ */
+#define KUID_STR(uid)	kuid_str(uid, (char [KID_STR_LEN]) {})
+#define KGID_STR(gid)	kgid_str(gid, (char [KID_STR_LEN]) {})
+#define KUID_STR_D(uid)	kuid_str_signed(uid, (char [KID_STR_LEN]) {})
+#define KGID_STR_D(gid)	kgid_str_signed(gid, (char [KID_STR_LEN]) {})
+char *kuid_str_munged(struct user_namespace *to, kuid_t uid,
+		      char buf[KID_STR_LEN]);
+char *kgid_str_munged(struct user_namespace *to, kgid_t gid,
+		      char buf[KID_STR_LEN]);
+kuid_t make_kuid_str(struct user_namespace *from, const char *str);
+kgid_t make_kgid_str(struct user_namespace *from, const char *str);
 
 #ifdef CONFIG_USER_NS
 
diff --git a/kernel/uidgid_r.c b/kernel/uidgid_r.c
index d71aecddb2..9bba60f413 100644
--- a/kernel/uidgid_r.c
+++ b/kernel/uidgid_r.c
@@ -12,6 +12,7 @@
 #include <linux/uidgid.h>
 #include <linux/uidgid_r.h>
 #include <linux/user_namespace.h>
+#include <linux/uuid.h>
 
 /*
  * Whether @id is well formed: a known type, reserved bytes zero, a UUID of
@@ -278,11 +279,12 @@ int put_kgid_r(struct user_namespace *to, kgid_t kgid,
 }
 EXPORT_SYMBOL(put_kgid_r);
 
-static char *kid_str(u32 type, u32 legacy, const uuid_t *b, char *buf)
+static char *kid_str(u32 type, u32 legacy, const uuid_t *b, char *buf,
+		     bool sgn)
 {
 	switch (type) {
 	case KID_LEGACY:
-		snprintf(buf, KID_STR_LEN, "%u", legacy);
+		snprintf(buf, KID_STR_LEN, sgn ? "%d" : "%u", legacy);
 		break;
 	case KID_UUID:
 		snprintf(buf, KID_STR_LEN, "%pUb", b);
@@ -304,7 +306,7 @@ static char *kid_str(u32 type, u32 legacy, const uuid_t *b, char *buf)
  */
 char *kuid_str(kuid_t uid, char buf[KID_STR_LEN])
 {
-	return kid_str(uid.type, __kuid_val(uid), &uid.uuid, buf);
+	return kid_str(uid.type, __kuid_val(uid), &uid.uuid, buf, false);
 }
 EXPORT_SYMBOL(kuid_str);
 
@@ -318,6 +320,148 @@ EXPORT_SYMBOL(kuid_str);
  */
 char *kgid_str(kgid_t gid, char buf[KID_STR_LEN])
 {
-	return kid_str(gid.type, __kgid_val(gid), &gid.uuid, buf);
+	return kid_str(gid.type, __kgid_val(gid), &gid.uuid, buf, false);
 }
 EXPORT_SYMBOL(kgid_str);
+
+/**
+ * kuid_str_signed - like kuid_str(), but a legacy uid as a signed number
+ * @uid: the kuid
+ * @buf: buffer of KID_STR_LEN bytes
+ *
+ * For callers that used to print from_kuid() with "%d".
+ *
+ * Return: @buf.
+ */
+char *kuid_str_signed(kuid_t uid, char buf[KID_STR_LEN])
+{
+	return kid_str(uid.type, __kuid_val(uid), &uid.uuid, buf, true);
+}
+EXPORT_SYMBOL(kuid_str_signed);
+
+/**
+ * kgid_str_signed - like kgid_str(), but a legacy gid as a signed number
+ * @gid: the kgid
+ * @buf: buffer of KID_STR_LEN bytes
+ *
+ * For callers that used to print from_kgid() with "%d".
+ *
+ * Return: @buf.
+ */
+char *kgid_str_signed(kgid_t gid, char buf[KID_STR_LEN])
+{
+	return kid_str(gid.type, __kgid_val(gid), &gid.uuid, buf, true);
+}
+EXPORT_SYMBOL(kgid_str_signed);
+
+/*
+ * Parses the text forms of kuid_str() -- a decimal number, a UUID, a GUID
+ * in braces -- with an optional trailing newline.
+ */
+static int kid_r_from_str(const char *str, struct __kernel_uid_r *id)
+{
+	char buf[KID_STR_LEN];
+	size_t len = strlen(str);
+
+	if (len && str[len - 1] == '\n')
+		len--;
+	if (!len || len >= sizeof(buf))
+		return -EINVAL;
+	memcpy(buf, str, len);
+	buf[len] = '\0';
+	memset(id, 0, sizeof(*id));
+
+	if (len == UUID_STRING_LEN) {
+		id->type = UID_R_UUID;
+		return uuid_parse(buf, (uuid_t *)id->uuid);
+	}
+	if (len == UUID_STRING_LEN + 2 && buf[0] == '{' && buf[len - 1] == '}') {
+		buf[len - 1] = '\0';
+		id->type = UID_R_GUID;
+		return guid_parse(buf + 1, (guid_t *)id->guid);
+	}
+	id->type = UID_R_LEGACY;
+	return kstrtou32(buf, 10, &id->legacy);
+}
+
+/**
+ * make_kuid_str - map the text form of a uid into a kuid
+ * @from: user namespace the uid is in
+ * @str: a decimal number, a UUID, or a GUID in braces; a trailing newline
+ *       is allowed
+ *
+ * Return: the kuid, INVALID_UID if @str is malformed or has no mapping in
+ * @from.
+ */
+kuid_t make_kuid_str(struct user_namespace *from, const char *str)
+{
+	struct __kernel_uid_r id;
+
+	if (kid_r_from_str(str, &id))
+		return INVALID_UID;
+	return make_kuid_r(from, &id);
+}
+EXPORT_SYMBOL(make_kuid_str);
+
+/**
+ * make_kgid_str - map the text form of a gid into a kgid
+ * @from: user namespace the gid is in
+ * @str: a decimal number, a UUID, or a GUID in braces; a trailing newline
+ *       is allowed
+ *
+ * Return: the kgid, INVALID_GID if @str is malformed or has no mapping in
+ * @from.
+ */
+kgid_t make_kgid_str(struct user_namespace *from, const char *str)
+{
+	struct __kernel_uid_r id;
+
+	if (kid_r_from_str(str, &id))
+		return INVALID_GID;
+	return make_kgid_r(from, &id);
+}
+EXPORT_SYMBOL(make_kgid_str);
+
+/**
+ * kuid_str_munged - text form of a kuid in a user namespace
+ * @to: user namespace the uid is wanted in
+ * @uid: the kuid
+ * @buf: buffer of KID_STR_LEN bytes
+ *
+ * Return: @buf, holding the uid in @to like kuid_str() does, overflowuid if
+ * @uid has no mapping there.
+ */
+char *kuid_str_munged(struct user_namespace *to, kuid_t uid,
+		      char buf[KID_STR_LEN])
+{
+	if (!kuid_has_mapping(to, uid))
+		snprintf(buf, KID_STR_LEN, "%u", overflowuid);
+	else if (uid_is_legacy(uid))
+		snprintf(buf, KID_STR_LEN, "%u", from_kuid(to, uid));
+	else
+		kuid_str(uid, buf);
+	return buf;
+}
+EXPORT_SYMBOL(kuid_str_munged);
+
+/**
+ * kgid_str_munged - text form of a kgid in a user namespace
+ * @to: user namespace the gid is wanted in
+ * @gid: the kgid
+ * @buf: buffer of KID_STR_LEN bytes
+ *
+ * Return: @buf, holding the gid in @to like kgid_str() does, overflowgid if
+ * @gid has no mapping there.
+ */
+char *kgid_str_munged(struct user_namespace *to, kgid_t gid,
+		      char buf[KID_STR_LEN])
+{
+	if (!kgid_has_mapping(to, gid))
+		snprintf(buf, KID_STR_LEN, "%u", overflowgid);
+	else if (gid_is_legacy(gid))
+		snprintf(buf, KID_STR_LEN, "%u", from_kgid(to, gid));
+	else
+		kgid_str(gid, buf);
+	return buf;
+}
+EXPORT_SYMBOL(kgid_str_munged);
-- 
2.56.0

