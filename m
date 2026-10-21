Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552555;
	b=XGHYRjrAmZ/t1mrXg26BP767xESsqzZZdmNb6254GTbVc0gdjv7KIh25bkhfp2DGGpp5
	 V/LK4H1yYQ1qGWWFpG2q9FIAIsosEt5honFpsXNems4s/wgCZSnGuE+5cEfNVNBs1Vpoq
	 XVVSoTYxUmjAwXL8VtQdGSzKCQat+6DXu7ABNol6eSYWeFXdQayaQynuZcFH31cDkUDh7
	 GTtarPFZTEJLwjPcdYgmeZxGIernYcDL5EEhMcKFxTDfiRIDYuniIzcL1agOkWuO5n79N
	 ZzP8dujKExn26tdZ3mYYcU/OgfhH5EXsqpqFddUBipW6bDfy8OI+Po+w3hWPWZkwLrw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552555;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=XdjniX01hhdh0CoWmtkhU5+EFc77cvpM/wbgBeTS3xM=;
	b=NzoUEPTa+o6lKlQBe/apja+cAtacmHi0WFC/lc12Zmj/dH8oAX8QVRvt3WcpUcxWTdHx
	 yjKS2RQEHc+ez5/CbecbSeximDOXhZoUUiU3tehUcQqb2Ciw5399LxvLJdunsQcVC/a7t
	 2KzyagHabkTNmIgxfUbLAjMnQ6tHzzY7g/0jWPA+X1yMOquGUe219eeG1/VkLlaNP3kwU
	 BabC53ZW3Wc1SRfyrgwblFNKyUZh0wBhIwCK93tyUTN1wqdgOkM6Qh525l3qqWCv1qnI+
	 83tQPY10/4SmwtAyUcBC3NENRhPNEUvkyLY5ojdbcFlsTum+ZSwy/qJ4NjDgQswpe/w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=gpaNkHxP;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1933760A381A;
	Wed, 21 Oct 2026 03:15:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1933760A381A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=gpaNkHxP
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552552; bh=sU7lqbdzjCOL/a0r7Zk22MFnMengoV7Rk5+Kfjz4bUs=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=gpaNkHxPJp8lUyxm2y/AoCDV+B8UpX22fGj+TR6Ua/lLS8HXytjGMFECMMWaBs/g3
	 fFt/6QRM0y3nNZRs3xNcRkI44NugjUCNiYjDW24MF7Cxpmr3wtuvdaFs6CMTc3pT3U
	 gtEY+3BaSFJIE2dU8sGO0CW4GT5XLR2mjjFWwzmD6EvSfznoRzAguj1QjP4lLDkres
	 nupnFzXos52eFvuIt9mHIcXTd5naD+/bEg1OTgDhTldsAs92yp2aAJ6RMQxp9mJ/3g
	 FIlit8cGnc7W/zB4cHjcnxoVyeb7RBY17eL6V4u9eDjg6kAXsmHuA412mc7vTMz2xN
	 jvKQTwG8/v6hQ==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id AF2E58A090D;
	Wed, 21 Oct 2026 05:15:51 +0200 (CEST)
Message-ID: <740f7687fd823a127ff6c312240eadbd8b3ec209.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 09/41] uidgid: let kuid_t and kgid_t hold a UUID or a
 GUID
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
Date: Wed, 21 Oct 2026 05:15:29 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Make kuid_t and kgid_t (and vfsuid_t and vfsgid_t, which share their
layout) tagged unions: a classic 32 bit id, an RFC 9562 UUID, or a
Microsoft GUID. KID_LEGACY is 0, so zeroed memory still holds the root
ids, and KUIDT_INIT()/KGIDT_INIT() keep building classic ids, so the
bulk of the kernel needs no change. The member is renamed from val to
legacy so the compiler finds code that peeks at it directly.

Semantics of the new ids:

- They are not in any uid_map or gid_map: they exist in the initial
  user namespace only. kuid_has_mapping() is false for them in every
  other namespace, so no capability in a child namespace gives
  privilege over them, and from_kuid() and friends give -1 (the
  overflow id when munged), exactly as for any other id without a
  mapping. Anything that can only store or report a 32 bit id thereby
  already treats them safely.

- Idmapped mounts map classic ids; UUIDs and GUIDs pass through them
  unchanged, as long as the filesystem itself is in the initial user
  namespace.

- Ids are ordered by kind first and value second, so sorted group
  lists, bsearch() and range checks between classic ids keep working:
  a UUID never falls into a range of classic ids.

- __kuid_val() and __kgid_val() stay the classic value of a classic id
  and are -1 for the others; hash tables keyed by ids (user_struct,
  ucounts) use the new kuid_hash() instead, and the IMA policy
  comparators the new ordering.

The structs grow from 4 to 20 bytes: struct cred by 128 bytes, struct
inode by 32 bytes.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/mnt_idmapping.c                  |  14 ++++
 include/linux/mnt_idmapping.h       |  74 ++++++++++++++-----
 include/linux/uidgid.h              | 109 ++++++++++++++++++++++------
 include/linux/uidgid_types.h        |  32 +++++++-
 kernel/groups.c                     |  15 ++--
 kernel/ucount.c                     |   2 +-
 kernel/user.c                       |   2 +-
 kernel/user_namespace.c             |  10 ++-
 mm/oom_kill.c                       |   2 +-
 security/integrity/ima/ima_policy.c |   8 +-
 10 files changed, 209 insertions(+), 59 deletions(-)

diff --git a/fs/mnt_idmapping.c b/fs/mnt_idmapping.c
index cb61fbdb52..c36e74a371 100644
--- a/fs/mnt_idmapping.c
+++ b/fs/mnt_idmapping.c
@@ -87,6 +87,10 @@ vfsuid_t make_vfsuid(struct mnt_idmap *idmap,
 		return VFSUIDT_INIT(kuid);
 	if (idmap == &invalid_mnt_idmap)
 		return INVALID_VFSUID;
+	/* idmappings map classic ids only; UUIDs and GUIDs pass unchanged */
+	if (!uid_is_legacy(kuid))
+		return kuid_has_mapping(fs_userns, kuid) ?
+		       VFSUIDT_INIT(kuid) : INVALID_VFSUID;
 	if (initial_idmapping(fs_userns))
 		uid = __kuid_val(kuid);
 	else
@@ -126,6 +130,10 @@ vfsgid_t make_vfsgid(struct mnt_idmap *idmap,
 		return VFSGIDT_INIT(kgid);
 	if (idmap == &invalid_mnt_idmap)
 		return INVALID_VFSGID;
+	/* idmappings map classic ids only; UUIDs and GUIDs pass unchanged */
+	if (!gid_is_legacy(kgid))
+		return kgid_has_mapping(fs_userns, kgid) ?
+		       VFSGIDT_INIT(kgid) : INVALID_VFSGID;
 	if (initial_idmapping(fs_userns))
 		gid = __kgid_val(kgid);
 	else
@@ -156,6 +164,9 @@ kuid_t from_vfsuid(struct mnt_idmap *idmap,
 		return AS_KUIDT(vfsuid);
 	if (idmap == &invalid_mnt_idmap)
 		return INVALID_UID;
+	if (!vfsuid_is_legacy(vfsuid))
+		return kuid_has_mapping(fs_userns, AS_KUIDT(vfsuid)) ?
+		       AS_KUIDT(vfsuid) : INVALID_UID;
 	uid = map_id_up(&idmap->uid_map, __vfsuid_val(vfsuid));
 	if (uid == (uid_t)-1)
 		return INVALID_UID;
@@ -185,6 +196,9 @@ kgid_t from_vfsgid(struct mnt_idmap *idmap,
 		return AS_KGIDT(vfsgid);
 	if (idmap == &invalid_mnt_idmap)
 		return INVALID_GID;
+	if (!vfsgid_is_legacy(vfsgid))
+		return kgid_has_mapping(fs_userns, AS_KGIDT(vfsgid)) ?
+		       AS_KGIDT(vfsgid) : INVALID_GID;
 	gid = map_id_up(&idmap->gid_map, __vfsgid_val(vfsgid));
 	if (gid == (gid_t)-1)
 		return INVALID_GID;
diff --git a/include/linux/mnt_idmapping.h b/include/linux/mnt_idmapping.h
index e71a6070a8..40f0f994ad 100644
--- a/include/linux/mnt_idmapping.h
+++ b/include/linux/mnt_idmapping.h
@@ -12,33 +12,55 @@ extern struct mnt_idmap nop_mnt_idmap;
 extern struct mnt_idmap invalid_mnt_idmap;
 extern struct user_namespace init_user_ns;
 
+/* Like kuid_t and kgid_t: a classic id, a UUID or a GUID */
 typedef struct {
-	uid_t val;
+	u32 type;
+	union {
+		uid_t legacy;
+		uuid_t uuid;
+		guid_t guid;
+	};
 } vfsuid_t;
 
 typedef struct {
-	gid_t val;
+	u32 type;
+	union {
+		gid_t legacy;
+		uuid_t uuid;
+		guid_t guid;
+	};
 } vfsgid_t;
 
 static_assert(sizeof(vfsuid_t) == sizeof(kuid_t));
 static_assert(sizeof(vfsgid_t) == sizeof(kgid_t));
-static_assert(offsetof(vfsuid_t, val) == offsetof(kuid_t, val));
-static_assert(offsetof(vfsgid_t, val) == offsetof(kgid_t, val));
+static_assert(offsetof(vfsuid_t, uuid) == offsetof(kuid_t, uuid));
+static_assert(offsetof(vfsgid_t, uuid) == offsetof(kgid_t, uuid));
 
 static inline bool is_valid_mnt_idmap(const struct mnt_idmap *idmap)
 {
 	return idmap != &nop_mnt_idmap && idmap != &invalid_mnt_idmap;
 }
 
+static inline bool vfsuid_is_legacy(vfsuid_t uid)
+{
+	return uid.type == KID_LEGACY;
+}
+
+static inline bool vfsgid_is_legacy(vfsgid_t gid)
+{
+	return gid.type == KID_LEGACY;
+}
+
+/* The classic value of a legacy id, -1 for a UUID or GUID */
 #ifdef CONFIG_MULTIUSER
 static inline uid_t __vfsuid_val(vfsuid_t uid)
 {
-	return uid.val;
+	return vfsuid_is_legacy(uid) ? uid.legacy : (uid_t)-1;
 }
 
 static inline gid_t __vfsgid_val(vfsgid_t gid)
 {
-	return gid.val;
+	return vfsgid_is_legacy(gid) ? gid.legacy : (gid_t)-1;
 }
 #else
 static inline uid_t __vfsuid_val(vfsuid_t uid)
@@ -54,22 +76,34 @@ static inline gid_t __vfsgid_val(vfsgid_t gid)
 
 static inline bool vfsuid_valid(vfsuid_t uid)
 {
-	return __vfsuid_val(uid) != (uid_t)-1;
+	return !vfsuid_is_legacy(uid) || __vfsuid_val(uid) != (uid_t)-1;
 }
 
 static inline bool vfsgid_valid(vfsgid_t gid)
 {
-	return __vfsgid_val(gid) != (gid_t)-1;
+	return !vfsgid_is_legacy(gid) || __vfsgid_val(gid) != (gid_t)-1;
+}
+
+static inline int vfsuid_cmp(vfsuid_t left, vfsuid_t right)
+{
+	return __kid_cmp(left.type, left.legacy, left.uuid.b,
+			 right.type, right.legacy, right.uuid.b);
+}
+
+static inline int vfsgid_cmp(vfsgid_t left, vfsgid_t right)
+{
+	return __kid_cmp(left.type, left.legacy, left.uuid.b,
+			 right.type, right.legacy, right.uuid.b);
 }
 
 static inline bool vfsuid_eq(vfsuid_t left, vfsuid_t right)
 {
-	return vfsuid_valid(left) && __vfsuid_val(left) == __vfsuid_val(right);
+	return vfsuid_valid(left) && vfsuid_cmp(left, right) == 0;
 }
 
 static inline bool vfsgid_eq(vfsgid_t left, vfsgid_t right)
 {
-	return vfsgid_valid(left) && __vfsgid_val(left) == __vfsgid_val(right);
+	return vfsgid_valid(left) && vfsgid_cmp(left, right) == 0;
 }
 
 /**
@@ -84,7 +118,9 @@ static inline bool vfsgid_eq(vfsgid_t left, vfsgid_t right)
  */
 static inline bool vfsuid_eq_kuid(vfsuid_t vfsuid, kuid_t kuid)
 {
-	return vfsuid_valid(vfsuid) && __vfsuid_val(vfsuid) == __kuid_val(kuid);
+	return vfsuid_valid(vfsuid) &&
+	       __kid_cmp(vfsuid.type, vfsuid.legacy, vfsuid.uuid.b,
+			 kuid.type, kuid.legacy, kuid.uuid.b) == 0;
 }
 
 /**
@@ -99,15 +135,17 @@ static inline bool vfsuid_eq_kuid(vfsuid_t vfsuid, kuid_t kuid)
  */
 static inline bool vfsgid_eq_kgid(vfsgid_t vfsgid, kgid_t kgid)
 {
-	return vfsgid_valid(vfsgid) && __vfsgid_val(vfsgid) == __kgid_val(kgid);
+	return vfsgid_valid(vfsgid) &&
+	       __kid_cmp(vfsgid.type, vfsgid.legacy, vfsgid.uuid.b,
+			 kgid.type, kgid.legacy, kgid.uuid.b) == 0;
 }
 
 /*
  * vfs{g,u}ids are created from k{g,u}ids.
  * We don't allow them to be created from regular {u,g}id.
  */
-#define VFSUIDT_INIT(val) (vfsuid_t){ __kuid_val(val) }
-#define VFSGIDT_INIT(val) (vfsgid_t){ __kgid_val(val) }
+#define VFSUIDT_INIT(val) (vfsuid_t){ .type = (val).type, .uuid = (val).uuid }
+#define VFSGIDT_INIT(val) (vfsgid_t){ .type = (val).type, .uuid = (val).uuid }
 
 #define INVALID_VFSUID VFSUIDT_INIT(INVALID_UID)
 #define INVALID_VFSGID VFSGIDT_INIT(INVALID_GID)
@@ -116,8 +154,8 @@ static inline bool vfsgid_eq_kgid(vfsgid_t vfsgid, kgid_t kgid)
  * Allow a vfs{g,u}id to be used as a k{g,u}id where we want to compare
  * whether the mapped value is identical to value of a k{g,u}id.
  */
-#define AS_KUIDT(val) (kuid_t){ __vfsuid_val(val) }
-#define AS_KGIDT(val) (kgid_t){ __vfsgid_val(val) }
+#define AS_KUIDT(val) (kuid_t){ .type = (val).type, .uuid = (val).uuid }
+#define AS_KGIDT(val) (kgid_t){ .type = (val).type, .uuid = (val).uuid }
 
 int vfsgid_in_group_p(vfsgid_t vfsgid);
 
@@ -158,7 +196,7 @@ static inline bool vfsuid_has_fsmapping(struct mnt_idmap *idmap,
 static inline bool vfsuid_has_mapping(struct user_namespace *userns,
 				      vfsuid_t vfsuid)
 {
-	return from_kuid(userns, AS_KUIDT(vfsuid)) != (uid_t)-1;
+	return kuid_has_mapping(userns, AS_KUIDT(vfsuid));
 }
 
 /**
@@ -196,7 +234,7 @@ static inline bool vfsgid_has_fsmapping(struct mnt_idmap *idmap,
 static inline bool vfsgid_has_mapping(struct user_namespace *userns,
 				      vfsgid_t vfsgid)
 {
-	return from_kgid(userns, AS_KGIDT(vfsgid)) != (gid_t)-1;
+	return kgid_has_mapping(userns, AS_KGIDT(vfsgid));
 }
 
 /**
diff --git a/include/linux/uidgid.h b/include/linux/uidgid.h
index 182c682458..e1adb50d5d 100644
--- a/include/linux/uidgid.h
+++ b/include/linux/uidgid.h
@@ -19,32 +19,37 @@ struct user_namespace;
 extern struct user_namespace init_user_ns;
 struct uid_gid_map;
 
-#define KUIDT_INIT(value) (kuid_t){ value }
-#define KGIDT_INIT(value) (kgid_t){ value }
+#define KUIDT_INIT(value) (kuid_t){ .type = KID_LEGACY, .legacy = (value) }
+#define KGIDT_INIT(value) (kgid_t){ .type = KID_LEGACY, .legacy = (value) }
+
+#define KUIDT_INIT_UUID(value) (kuid_t){ .type = KID_UUID, .uuid = (value) }
+#define KGIDT_INIT_UUID(value) (kgid_t){ .type = KID_UUID, .uuid = (value) }
+#define KUIDT_INIT_GUID(value) (kuid_t){ .type = KID_GUID, .guid = (value) }
+#define KGIDT_INIT_GUID(value) (kgid_t){ .type = KID_GUID, .guid = (value) }
 
-/*
- * Whether an id is a classic 32 bit id. All of them are for now; code that
- * needs one (to store it in 32 bits, for example) checks with these.
- */
 static inline bool uid_is_legacy(kuid_t uid)
 {
-	return true;
+	return uid.type == KID_LEGACY;
 }
 
 static inline bool gid_is_legacy(kgid_t gid)
 {
-	return true;
+	return gid.type == KID_LEGACY;
 }
 
+/*
+ * __kuid_val() and __kgid_val() are the classic value of a legacy id;
+ * a UUID or GUID has none and gives -1, which is never a valid id.
+ */
 #ifdef CONFIG_MULTIUSER
 static inline uid_t __kuid_val(kuid_t uid)
 {
-	return uid.val;
+	return uid_is_legacy(uid) ? uid.legacy : (uid_t)-1;
 }
 
 static inline gid_t __kgid_val(kgid_t gid)
 {
-	return gid.val;
+	return gid_is_legacy(gid) ? gid.legacy : (gid_t)-1;
 }
 #else
 static inline uid_t __kuid_val(kuid_t uid)
@@ -64,64 +69,115 @@ static inline gid_t __kgid_val(kgid_t gid)
 #define INVALID_UID KUIDT_INIT(-1)
 #define INVALID_GID KGIDT_INIT(-1)
 
+/*
+ * Ids are ordered by kind first (legacy ids before UUIDs before GUIDs),
+ * then by value: numerically for legacy ids, bytewise for the others.
+ * That keeps sorted id arrays and range checks between legacy ids
+ * working: a UUID is never inside a range of legacy ids.
+ */
+static inline int __kid_cmp(u32 ltype, u32 llegacy, const u8 *lb,
+			    u32 rtype, u32 rlegacy, const u8 *rb)
+{
+	if (!IS_ENABLED(CONFIG_MULTIUSER))
+		return 0;
+	if (ltype != rtype)
+		return ltype < rtype ? -1 : 1;
+	if (ltype == KID_LEGACY)
+		return llegacy == rlegacy ? 0 : llegacy < rlegacy ? -1 : 1;
+	return __builtin_memcmp(lb, rb, UUID_SIZE);
+}
+
+static inline int uid_cmp(kuid_t left, kuid_t right)
+{
+	return __kid_cmp(left.type, left.legacy, left.uuid.b,
+			 right.type, right.legacy, right.uuid.b);
+}
+
+static inline int gid_cmp(kgid_t left, kgid_t right)
+{
+	return __kid_cmp(left.type, left.legacy, left.uuid.b,
+			 right.type, right.legacy, right.uuid.b);
+}
+
 static inline bool uid_eq(kuid_t left, kuid_t right)
 {
-	return __kuid_val(left) == __kuid_val(right);
+	return uid_cmp(left, right) == 0;
 }
 
 static inline bool gid_eq(kgid_t left, kgid_t right)
 {
-	return __kgid_val(left) == __kgid_val(right);
+	return gid_cmp(left, right) == 0;
 }
 
 static inline bool uid_gt(kuid_t left, kuid_t right)
 {
-	return __kuid_val(left) > __kuid_val(right);
+	return uid_cmp(left, right) > 0;
 }
 
 static inline bool gid_gt(kgid_t left, kgid_t right)
 {
-	return __kgid_val(left) > __kgid_val(right);
+	return gid_cmp(left, right) > 0;
 }
 
 static inline bool uid_gte(kuid_t left, kuid_t right)
 {
-	return __kuid_val(left) >= __kuid_val(right);
+	return uid_cmp(left, right) >= 0;
 }
 
 static inline bool gid_gte(kgid_t left, kgid_t right)
 {
-	return __kgid_val(left) >= __kgid_val(right);
+	return gid_cmp(left, right) >= 0;
 }
 
 static inline bool uid_lt(kuid_t left, kuid_t right)
 {
-	return __kuid_val(left) < __kuid_val(right);
+	return uid_cmp(left, right) < 0;
 }
 
 static inline bool gid_lt(kgid_t left, kgid_t right)
 {
-	return __kgid_val(left) < __kgid_val(right);
+	return gid_cmp(left, right) < 0;
 }
 
 static inline bool uid_lte(kuid_t left, kuid_t right)
 {
-	return __kuid_val(left) <= __kuid_val(right);
+	return uid_cmp(left, right) <= 0;
 }
 
 static inline bool gid_lte(kgid_t left, kgid_t right)
 {
-	return __kgid_val(left) <= __kgid_val(right);
+	return gid_cmp(left, right) <= 0;
 }
 
 static inline bool uid_valid(kuid_t uid)
 {
-	return __kuid_val(uid) != (uid_t) -1;
+	return !uid_is_legacy(uid) || __kuid_val(uid) != (uid_t) -1;
 }
 
 static inline bool gid_valid(kgid_t gid)
 {
-	return __kgid_val(gid) != (gid_t) -1;
+	return !gid_is_legacy(gid) || __kgid_val(gid) != (gid_t) -1;
+}
+
+/* A hash of an id, for hash tables keyed by kuid_t or kgid_t */
+static inline u32 __kid_hash(u32 type, u32 legacy, const u8 *b)
+{
+	u32 w[4];
+
+	if (type == KID_LEGACY)
+		return legacy;
+	__builtin_memcpy(w, b, sizeof(w));
+	return w[0] ^ w[1] ^ w[2] ^ w[3] ^ type;
+}
+
+static inline u32 kuid_hash(kuid_t uid)
+{
+	return __kid_hash(uid.type, __kuid_val(uid), uid.uuid.b);
+}
+
+static inline u32 kgid_hash(kgid_t gid)
+{
+	return __kid_hash(gid.type, __kgid_val(gid), gid.uuid.b);
 }
 
 #ifdef CONFIG_USER_NS
@@ -134,13 +190,22 @@ extern gid_t from_kgid(struct user_namespace *to, kgid_t gid);
 extern uid_t from_kuid_munged(struct user_namespace *to, kuid_t uid);
 extern gid_t from_kgid_munged(struct user_namespace *to, kgid_t gid);
 
+/*
+ * UUIDs and GUIDs aren't in any namespace's uid_map or gid_map: they
+ * exist in the initial user namespace only, and nobody has privilege
+ * over them through a capability in another one.
+ */
 static inline bool kuid_has_mapping(struct user_namespace *ns, kuid_t uid)
 {
+	if (!uid_is_legacy(uid))
+		return ns == &init_user_ns;
 	return from_kuid(ns, uid) != (uid_t) -1;
 }
 
 static inline bool kgid_has_mapping(struct user_namespace *ns, kgid_t gid)
 {
+	if (!gid_is_legacy(gid))
+		return ns == &init_user_ns;
 	return from_kgid(ns, gid) != (gid_t) -1;
 }
 
diff --git a/include/linux/uidgid_types.h b/include/linux/uidgid_types.h
index b35ac4955a..0f595d075b 100644
--- a/include/linux/uidgid_types.h
+++ b/include/linux/uidgid_types.h
@@ -3,13 +3,41 @@
 #define _LINUX_UIDGID_TYPES_H
 
 #include <linux/types.h>
+#include <linux/uuid_types.h>
 
+/*
+ * Kinds of kuid_t and kgid_t. KID_LEGACY is 0, so zeroed memory still
+ * holds GLOBAL_ROOT_UID and GLOBAL_ROOT_GID as it did when the ids were
+ * plain numbers. Userspace has its own numbering (UID_R_* in
+ * <uapi/linux/uidgid_r.h>), in which zero is "no id".
+ */
+enum kid_type {
+	KID_LEGACY = 0,		/* classic 32 bit id in .legacy */
+	KID_UUID,		/* RFC 9562 UUID in .uuid */
+	KID_GUID,		/* Microsoft GUID in .guid */
+};
+
+/*
+ * Only the member .type selects is meaningful; the bytes of .uuid past
+ * .legacy are undefined for a KID_LEGACY id. Copy the whole struct and
+ * use the helpers of <linux/uidgid.h> to look at it.
+ */
 typedef struct {
-	uid_t val;
+	u32 type;
+	union {
+		uid_t legacy;
+		uuid_t uuid;
+		guid_t guid;
+	};
 } kuid_t;
 
 typedef struct {
-	gid_t val;
+	u32 type;
+	union {
+		gid_t legacy;
+		uuid_t uuid;
+		guid_t guid;
+	};
 } kgid_t;
 
 #endif /* _LINUX_UIDGID_TYPES_H */
diff --git a/kernel/groups.c b/kernel/groups.c
index b5e3be6a6b..3aa0651d7a 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -73,18 +73,15 @@ static int groups_from_user(struct group_info *group_info,
 	return 0;
 }
 
-static int gid_cmp(const void *_a, const void *_b)
+static int groups_cmp(const void *_a, const void *_b)
 {
-	kgid_t a = *(kgid_t *)_a;
-	kgid_t b = *(kgid_t *)_b;
-
-	return gid_gt(a, b) - gid_lt(a, b);
+	return gid_cmp(*(kgid_t *)_a, *(kgid_t *)_b);
 }
 
 void groups_sort(struct group_info *group_info)
 {
 	sort(group_info->gid, group_info->ngroups, sizeof(*group_info->gid),
-	     gid_cmp, NULL);
+	     groups_cmp, NULL);
 }
 EXPORT_SYMBOL(groups_sort);
 
@@ -100,9 +97,11 @@ int groups_search(const struct group_info *group_info, kgid_t grp)
 	right = group_info->ngroups;
 	while (left < right) {
 		unsigned int mid = (left+right)/2;
-		if (gid_gt(grp, group_info->gid[mid]))
+		int cmp = gid_cmp(grp, group_info->gid[mid]);
+
+		if (cmp > 0)
 			left = mid + 1;
-		else if (gid_lt(grp, group_info->gid[mid]))
+		else if (cmp < 0)
 			right = mid;
 		else
 			return 1;
diff --git a/kernel/ucount.c b/kernel/ucount.c
index ec8b1445e2..d34bc9ea9d 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -23,7 +23,7 @@ static struct hlist_nulls_head ucounts_hashtable[UCOUNTS_HASHTABLE_ENTRIES] = {
 static DEFINE_SPINLOCK(ucounts_lock);
 
 #define ucounts_hashfn(ns, uid)						\
-	hash_long((unsigned long)__kuid_val(uid) + (unsigned long)(ns), \
+	hash_long((unsigned long)kuid_hash(uid) + (unsigned long)(ns), \
 		  UCOUNTS_HASHTABLE_BITS)
 #define ucounts_hashentry(ns, uid)	\
 	(ucounts_hashtable + ucounts_hashfn(ns, uid))
diff --git a/kernel/user.c b/kernel/user.c
index 21bafdc113..e41806bb70 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -88,7 +88,7 @@ EXPORT_SYMBOL_GPL(init_user_ns);
 #define UIDHASH_SZ	(1 << UIDHASH_BITS)
 #define UIDHASH_MASK		(UIDHASH_SZ - 1)
 #define __uidhashfn(uid)	(((uid >> UIDHASH_BITS) + uid) & UIDHASH_MASK)
-#define uidhashentry(uid)	(uidhash_table + __uidhashfn((__kuid_val(uid))))
+#define uidhashentry(uid)	(uidhash_table + __uidhashfn(kuid_hash(uid)))
 
 static struct kmem_cache *uid_cachep;
 static struct hlist_head uidhash_table[UIDHASH_SZ];
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 0bed462e9b..88fc8ba586 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -436,10 +436,13 @@ EXPORT_SYMBOL(make_kuid);
  *
  *	There is always a mapping into the initial user_namespace.
  *
- *	If @kuid has no mapping in @targ (uid_t)-1 is returned.
+ *	If @kuid has no mapping in @targ (uid_t)-1 is returned. A UUID or
+ *	GUID has no classic uid in any user namespace.
  */
 uid_t from_kuid(struct user_namespace *targ, kuid_t kuid)
 {
+	if (!uid_is_legacy(kuid))
+		return (uid_t) -1;
 	/* Map the uid from a global kernel uid */
 	return map_id_up(&targ->uid_map, __kuid_val(kuid));
 }
@@ -504,10 +507,13 @@ EXPORT_SYMBOL(make_kgid);
  *
  *	There is always a mapping into the initial user_namespace.
  *
- *	If @kgid has no mapping in @targ (gid_t)-1 is returned.
+ *	If @kgid has no mapping in @targ (gid_t)-1 is returned. A UUID or
+ *	GUID has no classic gid in any user namespace.
  */
 gid_t from_kgid(struct user_namespace *targ, kgid_t kgid)
 {
+	if (!gid_is_legacy(kgid))
+		return (gid_t) -1;
 	/* Map the gid from a global kernel gid */
 	return map_id_up(&targ->gid_map, __kgid_val(kgid));
 }
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5f372f6e26..2ce3072931 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -771,7 +771,7 @@ static void mark_oom_victim(struct task_struct *tsk)
 	thaw_process(tsk);
 	atomic_inc(&oom_victims);
 	cred = get_task_cred(tsk);
-	trace_mark_victim(tsk, cred->uid.val);
+	trace_mark_victim(tsk, __kuid_val(cred->uid));
 	put_cred(cred);
 }
 
diff --git a/security/integrity/ima/ima_policy.c b/security/integrity/ima/ima_policy.c
index 68d9a5e6c2..839b88ea20 100644
--- a/security/integrity/ima/ima_policy.c
+++ b/security/integrity/ima/ima_policy.c
@@ -81,22 +81,22 @@ struct ima_rule_opt_list {
  */
 static inline bool vfsuid_gt_kuid(vfsuid_t vfsuid, kuid_t kuid)
 {
-	return __vfsuid_val(vfsuid) > __kuid_val(kuid);
+	return vfsuid_cmp(vfsuid, VFSUIDT_INIT(kuid)) > 0;
 }
 
 static inline bool vfsgid_gt_kgid(vfsgid_t vfsgid, kgid_t kgid)
 {
-	return __vfsgid_val(vfsgid) > __kgid_val(kgid);
+	return vfsgid_cmp(vfsgid, VFSGIDT_INIT(kgid)) > 0;
 }
 
 static inline bool vfsuid_lt_kuid(vfsuid_t vfsuid, kuid_t kuid)
 {
-	return __vfsuid_val(vfsuid) < __kuid_val(kuid);
+	return vfsuid_cmp(vfsuid, VFSUIDT_INIT(kuid)) < 0;
 }
 
 static inline bool vfsgid_lt_kgid(vfsgid_t vfsgid, kgid_t kgid)
 {
-	return __vfsgid_val(vfsgid) < __kgid_val(kgid);
+	return vfsgid_cmp(vfsgid, VFSGIDT_INIT(kgid)) < 0;
 }
 
 struct ima_rule_entry {
-- 
2.56.0

