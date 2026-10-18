Received: from mout.gmx.net (mout.gmx.net [212.227.15.15])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3B73D3A6EEE;
	Sun, 18 Oct 2026 18:02:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.15
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792346531; cv=none; b=iGfyIWCww4AJiiM4WQ58jjA19O5J6a9QuOdfomD3PitjHGs9kerEEemw2zlCI21twAhAdBdHowOeZDHnwALWdeZtHDHr1YeLIFIln82cNhxalE79+SIz7TdYuADefGXRuzprCZzvP3fyle3E/oKtj4yECcwJ47kTmPGawlInD50=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792346531; c=relaxed/simple;
	bh=Url8WSKE/8cCSvXNrJHa5adqy3ZxrAbridEY110zWvM=;
	h=Message-ID:In-Reply-To:References:From:Subject:To:Cc:Date; b=GFiNSHF35TPOChXu9A1sh2xmJXH2j9qOe2HQx933IwkbWtzaHl+4RSA39sOIP8jG7TGWIb4oM2s7zNAmJaqMfjBlRTvAPlYPtPk2okeJ9YNa11UIW8gRckZwvvXti0IZecjEt4MAYRpXoudL2XyudjiZ8ifd0CFYHl/sMglpVlI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net; spf=pass smtp.mailfrom=gmx.net; dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b=CKp9U6E1; arc=none smtp.client-ip=212.227.15.15
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b="CKp9U6E1"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.net;
	s=s31663417; t=1792346515; x=1792951315; i=jan.koester@gmx.net;
	bh=FIpTr3tDULitgJCL//dYgf0mJfsKUxkZ82+q+NIFHLE=;
	h=X-UI-Sender-Class:Message-ID:In-Reply-To:References:From:Subject:
	 To:Cc:Date:Content-Transfer-Encoding:cc:content-transfer-encoding:
	 content-type:date:from:message-id:mime-version:reply-to:subject:
	 to;
	b=CKp9U6E1n6OplOEZj0xtFtykHBPfX0w4FYDNhMkxZGxk0VN4NR8vpV+WihZ5rBeD
	 FnFLcMMjxzVw5vcjFy/x2ODmB9yve7nnDazalbngtr2mrGn6kSTdoMUNbi9LVcgW0
	 2OFwoM+vDTohl+lrYZzlWdbFTx+3Pbu3pDpeTyTwT8ZtccG9m/Fp2f3jcN9N9iHUX
	 LVqVN4ZNKSiSYneJPRv1S3XvrCNaxWZD24yINQvunRLtK5Qbo45xvikvksuk4igsJ
	 rlPfQ4qoUZ3OX40AlWUgGYNKRXCWpSOsrlHq5dNxsy8vXBYG+BimeOHXWTGPwn8LG
	 IcrqJ4D63GPYY96j1g==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from client.hidden.invalid by mail.gmx.net (mrgmx004
 [212.227.17.190]) with ESMTPSA (Nemesis) id 1MXXyP-1x6nNs1IoZ-00QLFZ; Sun, 18
 Oct 2026 20:01:55 +0200
Message-ID: <9c17a1f7f82b953e6f4d9e17f4ca19d5220d7f2b.1792346472.git.jan.koester@gmx.net>
In-Reply-To: <cover.1792346472.git.jan.koester@gmx.net>
References: <cover.1792346472.git.jan.koester@gmx.net>
From: Jan Koester <jan.koester@gmx.net>
Subject: [RFC PATCH 09/41] uidgid: let kuid_t and kgid_t hold a UUID or a GUID
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
Date: Sun, 18 Oct 2026 20:01:30 +0200
X-Provags-ID: V03:K1:/4sSUWL+koqw2bRzc35+bhsJRSXo/2mGvB1Y20PzBZ24la2vQbU
 XVRbAtYlbgdFIL3i2p81XlExD3RggtGFsL7O5lKdpVrsN8l39aoFgXbLXwZFh2O8NWdSWkR
 mK9GX93L02VdOZQ5OpyEBbEm0ICsESn3RWNmYgXNdSj6e3fzHtyaIQ126mKwycu9QZJZjKf
 c5ev8vTuLAtu7y9qqfRjQ==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:S2Sem/MT4Mc=;lMxeWGBSijDp+oUC3NNi2Z1RpIb
 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
 7fFk7yZPce0=
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

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

Signed-off-by: Jan Koester <jan.koester@gmx.net>
=2D--
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
=2D-- a/fs/mnt_idmapping.c
+++ b/fs/mnt_idmapping.c
@@ -87,6 +87,10 @@ vfsuid_t make_vfsuid(struct mnt_idmap *idmap,
 		return VFSUIDT_INIT(kuid);
 	if (idmap =3D=3D &invalid_mnt_idmap)
 		return INVALID_VFSUID;
+	/* idmappings map classic ids only; UUIDs and GUIDs pass unchanged */
+	if (!uid_is_legacy(kuid))
+		return kuid_has_mapping(fs_userns, kuid) ?
+		       VFSUIDT_INIT(kuid) : INVALID_VFSUID;
 	if (initial_idmapping(fs_userns))
 		uid =3D __kuid_val(kuid);
 	else
@@ -126,6 +130,10 @@ vfsgid_t make_vfsgid(struct mnt_idmap *idmap,
 		return VFSGIDT_INIT(kgid);
 	if (idmap =3D=3D &invalid_mnt_idmap)
 		return INVALID_VFSGID;
+	/* idmappings map classic ids only; UUIDs and GUIDs pass unchanged */
+	if (!gid_is_legacy(kgid))
+		return kgid_has_mapping(fs_userns, kgid) ?
+		       VFSGIDT_INIT(kgid) : INVALID_VFSGID;
 	if (initial_idmapping(fs_userns))
 		gid =3D __kgid_val(kgid);
 	else
@@ -156,6 +164,9 @@ kuid_t from_vfsuid(struct mnt_idmap *idmap,
 		return AS_KUIDT(vfsuid);
 	if (idmap =3D=3D &invalid_mnt_idmap)
 		return INVALID_UID;
+	if (!vfsuid_is_legacy(vfsuid))
+		return kuid_has_mapping(fs_userns, AS_KUIDT(vfsuid)) ?
+		       AS_KUIDT(vfsuid) : INVALID_UID;
 	uid =3D map_id_up(&idmap->uid_map, __vfsuid_val(vfsuid));
 	if (uid =3D=3D (uid_t)-1)
 		return INVALID_UID;
@@ -185,6 +196,9 @@ kgid_t from_vfsgid(struct mnt_idmap *idmap,
 		return AS_KGIDT(vfsgid);
 	if (idmap =3D=3D &invalid_mnt_idmap)
 		return INVALID_GID;
+	if (!vfsgid_is_legacy(vfsgid))
+		return kgid_has_mapping(fs_userns, AS_KGIDT(vfsgid)) ?
+		       AS_KGIDT(vfsgid) : INVALID_GID;
 	gid =3D map_id_up(&idmap->gid_map, __vfsgid_val(vfsgid));
 	if (gid =3D=3D (gid_t)-1)
 		return INVALID_GID;
diff --git a/include/linux/mnt_idmapping.h b/include/linux/mnt_idmapping.h
index e71a6070a8..40f0f994ad 100644
=2D-- a/include/linux/mnt_idmapping.h
+++ b/include/linux/mnt_idmapping.h
@@ -12,33 +12,55 @@ extern struct mnt_idmap nop_mnt_idmap;
 extern struct mnt_idmap invalid_mnt_idmap;
 extern struct user_namespace init_user_ns;
=20
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
=20
 typedef struct {
-	gid_t val;
+	u32 type;
+	union {
+		gid_t legacy;
+		uuid_t uuid;
+		guid_t guid;
+	};
 } vfsgid_t;
=20
 static_assert(sizeof(vfsuid_t) =3D=3D sizeof(kuid_t));
 static_assert(sizeof(vfsgid_t) =3D=3D sizeof(kgid_t));
-static_assert(offsetof(vfsuid_t, val) =3D=3D offsetof(kuid_t, val));
-static_assert(offsetof(vfsgid_t, val) =3D=3D offsetof(kgid_t, val));
+static_assert(offsetof(vfsuid_t, uuid) =3D=3D offsetof(kuid_t, uuid));
+static_assert(offsetof(vfsgid_t, uuid) =3D=3D offsetof(kgid_t, uuid));
=20
 static inline bool is_valid_mnt_idmap(const struct mnt_idmap *idmap)
 {
 	return idmap !=3D &nop_mnt_idmap && idmap !=3D &invalid_mnt_idmap;
 }
=20
+static inline bool vfsuid_is_legacy(vfsuid_t uid)
+{
+	return uid.type =3D=3D KID_LEGACY;
+}
+
+static inline bool vfsgid_is_legacy(vfsgid_t gid)
+{
+	return gid.type =3D=3D KID_LEGACY;
+}
+
+/* The classic value of a legacy id, -1 for a UUID or GUID */
 #ifdef CONFIG_MULTIUSER
 static inline uid_t __vfsuid_val(vfsuid_t uid)
 {
-	return uid.val;
+	return vfsuid_is_legacy(uid) ? uid.legacy : (uid_t)-1;
 }
=20
 static inline gid_t __vfsgid_val(vfsgid_t gid)
 {
-	return gid.val;
+	return vfsgid_is_legacy(gid) ? gid.legacy : (gid_t)-1;
 }
 #else
 static inline uid_t __vfsuid_val(vfsuid_t uid)
@@ -54,22 +76,34 @@ static inline gid_t __vfsgid_val(vfsgid_t gid)
=20
 static inline bool vfsuid_valid(vfsuid_t uid)
 {
-	return __vfsuid_val(uid) !=3D (uid_t)-1;
+	return !vfsuid_is_legacy(uid) || __vfsuid_val(uid) !=3D (uid_t)-1;
 }
=20
 static inline bool vfsgid_valid(vfsgid_t gid)
 {
-	return __vfsgid_val(gid) !=3D (gid_t)-1;
+	return !vfsgid_is_legacy(gid) || __vfsgid_val(gid) !=3D (gid_t)-1;
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
=20
 static inline bool vfsuid_eq(vfsuid_t left, vfsuid_t right)
 {
-	return vfsuid_valid(left) && __vfsuid_val(left) =3D=3D __vfsuid_val(righ=
t);
+	return vfsuid_valid(left) && vfsuid_cmp(left, right) =3D=3D 0;
 }
=20
 static inline bool vfsgid_eq(vfsgid_t left, vfsgid_t right)
 {
-	return vfsgid_valid(left) && __vfsgid_val(left) =3D=3D __vfsgid_val(righ=
t);
+	return vfsgid_valid(left) && vfsgid_cmp(left, right) =3D=3D 0;
 }
=20
 /**
@@ -84,7 +118,9 @@ static inline bool vfsgid_eq(vfsgid_t left, vfsgid_t ri=
ght)
  */
 static inline bool vfsuid_eq_kuid(vfsuid_t vfsuid, kuid_t kuid)
 {
-	return vfsuid_valid(vfsuid) && __vfsuid_val(vfsuid) =3D=3D __kuid_val(ku=
id);
+	return vfsuid_valid(vfsuid) &&
+	       __kid_cmp(vfsuid.type, vfsuid.legacy, vfsuid.uuid.b,
+			 kuid.type, kuid.legacy, kuid.uuid.b) =3D=3D 0;
 }
=20
 /**
@@ -99,15 +135,17 @@ static inline bool vfsuid_eq_kuid(vfsuid_t vfsuid, ku=
id_t kuid)
  */
 static inline bool vfsgid_eq_kgid(vfsgid_t vfsgid, kgid_t kgid)
 {
-	return vfsgid_valid(vfsgid) && __vfsgid_val(vfsgid) =3D=3D __kgid_val(kg=
id);
+	return vfsgid_valid(vfsgid) &&
+	       __kid_cmp(vfsgid.type, vfsgid.legacy, vfsgid.uuid.b,
+			 kgid.type, kgid.legacy, kgid.uuid.b) =3D=3D 0;
 }
=20
 /*
  * vfs{g,u}ids are created from k{g,u}ids.
  * We don't allow them to be created from regular {u,g}id.
  */
-#define VFSUIDT_INIT(val) (vfsuid_t){ __kuid_val(val) }
-#define VFSGIDT_INIT(val) (vfsgid_t){ __kgid_val(val) }
+#define VFSUIDT_INIT(val) (vfsuid_t){ .type =3D (val).type, .uuid =3D (va=
l).uuid }
+#define VFSGIDT_INIT(val) (vfsgid_t){ .type =3D (val).type, .uuid =3D (va=
l).uuid }
=20
 #define INVALID_VFSUID VFSUIDT_INIT(INVALID_UID)
 #define INVALID_VFSGID VFSGIDT_INIT(INVALID_GID)
@@ -116,8 +154,8 @@ static inline bool vfsgid_eq_kgid(vfsgid_t vfsgid, kgi=
d_t kgid)
  * Allow a vfs{g,u}id to be used as a k{g,u}id where we want to compare
  * whether the mapped value is identical to value of a k{g,u}id.
  */
-#define AS_KUIDT(val) (kuid_t){ __vfsuid_val(val) }
-#define AS_KGIDT(val) (kgid_t){ __vfsgid_val(val) }
+#define AS_KUIDT(val) (kuid_t){ .type =3D (val).type, .uuid =3D (val).uui=
d }
+#define AS_KGIDT(val) (kgid_t){ .type =3D (val).type, .uuid =3D (val).uui=
d }
=20
 int vfsgid_in_group_p(vfsgid_t vfsgid);
=20
@@ -158,7 +196,7 @@ static inline bool vfsuid_has_fsmapping(struct mnt_idm=
ap *idmap,
 static inline bool vfsuid_has_mapping(struct user_namespace *userns,
 				      vfsuid_t vfsuid)
 {
-	return from_kuid(userns, AS_KUIDT(vfsuid)) !=3D (uid_t)-1;
+	return kuid_has_mapping(userns, AS_KUIDT(vfsuid));
 }
=20
 /**
@@ -196,7 +234,7 @@ static inline bool vfsgid_has_fsmapping(struct mnt_idm=
ap *idmap,
 static inline bool vfsgid_has_mapping(struct user_namespace *userns,
 				      vfsgid_t vfsgid)
 {
-	return from_kgid(userns, AS_KGIDT(vfsgid)) !=3D (gid_t)-1;
+	return kgid_has_mapping(userns, AS_KGIDT(vfsgid));
 }
=20
 /**
diff --git a/include/linux/uidgid.h b/include/linux/uidgid.h
index 182c682458..e1adb50d5d 100644
=2D-- a/include/linux/uidgid.h
+++ b/include/linux/uidgid.h
@@ -19,32 +19,37 @@ struct user_namespace;
 extern struct user_namespace init_user_ns;
 struct uid_gid_map;
=20
-#define KUIDT_INIT(value) (kuid_t){ value }
-#define KGIDT_INIT(value) (kgid_t){ value }
+#define KUIDT_INIT(value) (kuid_t){ .type =3D KID_LEGACY, .legacy =3D (va=
lue) }
+#define KGIDT_INIT(value) (kgid_t){ .type =3D KID_LEGACY, .legacy =3D (va=
lue) }
+
+#define KUIDT_INIT_UUID(value) (kuid_t){ .type =3D KID_UUID, .uuid =3D (v=
alue) }
+#define KGIDT_INIT_UUID(value) (kgid_t){ .type =3D KID_UUID, .uuid =3D (v=
alue) }
+#define KUIDT_INIT_GUID(value) (kuid_t){ .type =3D KID_GUID, .guid =3D (v=
alue) }
+#define KGIDT_INIT_GUID(value) (kgid_t){ .type =3D KID_GUID, .guid =3D (v=
alue) }
=20
-/*
- * Whether an id is a classic 32 bit id. All of them are for now; code th=
at
- * needs one (to store it in 32 bits, for example) checks with these.
- */
 static inline bool uid_is_legacy(kuid_t uid)
 {
-	return true;
+	return uid.type =3D=3D KID_LEGACY;
 }
=20
 static inline bool gid_is_legacy(kgid_t gid)
 {
-	return true;
+	return gid.type =3D=3D KID_LEGACY;
 }
=20
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
=20
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
=20
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
+	if (ltype !=3D rtype)
+		return ltype < rtype ? -1 : 1;
+	if (ltype =3D=3D KID_LEGACY)
+		return llegacy =3D=3D rlegacy ? 0 : llegacy < rlegacy ? -1 : 1;
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
-	return __kuid_val(left) =3D=3D __kuid_val(right);
+	return uid_cmp(left, right) =3D=3D 0;
 }
=20
 static inline bool gid_eq(kgid_t left, kgid_t right)
 {
-	return __kgid_val(left) =3D=3D __kgid_val(right);
+	return gid_cmp(left, right) =3D=3D 0;
 }
=20
 static inline bool uid_gt(kuid_t left, kuid_t right)
 {
-	return __kuid_val(left) > __kuid_val(right);
+	return uid_cmp(left, right) > 0;
 }
=20
 static inline bool gid_gt(kgid_t left, kgid_t right)
 {
-	return __kgid_val(left) > __kgid_val(right);
+	return gid_cmp(left, right) > 0;
 }
=20
 static inline bool uid_gte(kuid_t left, kuid_t right)
 {
-	return __kuid_val(left) >=3D __kuid_val(right);
+	return uid_cmp(left, right) >=3D 0;
 }
=20
 static inline bool gid_gte(kgid_t left, kgid_t right)
 {
-	return __kgid_val(left) >=3D __kgid_val(right);
+	return gid_cmp(left, right) >=3D 0;
 }
=20
 static inline bool uid_lt(kuid_t left, kuid_t right)
 {
-	return __kuid_val(left) < __kuid_val(right);
+	return uid_cmp(left, right) < 0;
 }
=20
 static inline bool gid_lt(kgid_t left, kgid_t right)
 {
-	return __kgid_val(left) < __kgid_val(right);
+	return gid_cmp(left, right) < 0;
 }
=20
 static inline bool uid_lte(kuid_t left, kuid_t right)
 {
-	return __kuid_val(left) <=3D __kuid_val(right);
+	return uid_cmp(left, right) <=3D 0;
 }
=20
 static inline bool gid_lte(kgid_t left, kgid_t right)
 {
-	return __kgid_val(left) <=3D __kgid_val(right);
+	return gid_cmp(left, right) <=3D 0;
 }
=20
 static inline bool uid_valid(kuid_t uid)
 {
-	return __kuid_val(uid) !=3D (uid_t) -1;
+	return !uid_is_legacy(uid) || __kuid_val(uid) !=3D (uid_t) -1;
 }
=20
 static inline bool gid_valid(kgid_t gid)
 {
-	return __kgid_val(gid) !=3D (gid_t) -1;
+	return !gid_is_legacy(gid) || __kgid_val(gid) !=3D (gid_t) -1;
+}
+
+/* A hash of an id, for hash tables keyed by kuid_t or kgid_t */
+static inline u32 __kid_hash(u32 type, u32 legacy, const u8 *b)
+{
+	u32 w[4];
+
+	if (type =3D=3D KID_LEGACY)
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
=20
 #ifdef CONFIG_USER_NS
@@ -134,13 +190,22 @@ extern gid_t from_kgid(struct user_namespace *to, kg=
id_t gid);
 extern uid_t from_kuid_munged(struct user_namespace *to, kuid_t uid);
 extern gid_t from_kgid_munged(struct user_namespace *to, kgid_t gid);
=20
+/*
+ * UUIDs and GUIDs aren't in any namespace's uid_map or gid_map: they
+ * exist in the initial user namespace only, and nobody has privilege
+ * over them through a capability in another one.
+ */
 static inline bool kuid_has_mapping(struct user_namespace *ns, kuid_t uid=
)
 {
+	if (!uid_is_legacy(uid))
+		return ns =3D=3D &init_user_ns;
 	return from_kuid(ns, uid) !=3D (uid_t) -1;
 }
=20
 static inline bool kgid_has_mapping(struct user_namespace *ns, kgid_t gid=
)
 {
+	if (!gid_is_legacy(gid))
+		return ns =3D=3D &init_user_ns;
 	return from_kgid(ns, gid) !=3D (gid_t) -1;
 }
=20
diff --git a/include/linux/uidgid_types.h b/include/linux/uidgid_types.h
index b35ac4955a..0f595d075b 100644
=2D-- a/include/linux/uidgid_types.h
+++ b/include/linux/uidgid_types.h
@@ -3,13 +3,41 @@
 #define _LINUX_UIDGID_TYPES_H
=20
 #include <linux/types.h>
+#include <linux/uuid_types.h>
=20
+/*
+ * Kinds of kuid_t and kgid_t. KID_LEGACY is 0, so zeroed memory still
+ * holds GLOBAL_ROOT_UID and GLOBAL_ROOT_GID as it did when the ids were
+ * plain numbers. Userspace has its own numbering (UID_R_* in
+ * <uapi/linux/uidgid_r.h>), in which zero is "no id".
+ */
+enum kid_type {
+	KID_LEGACY =3D 0,		/* classic 32 bit id in .legacy */
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
=20
 typedef struct {
-	gid_t val;
+	u32 type;
+	union {
+		gid_t legacy;
+		uuid_t uuid;
+		guid_t guid;
+	};
 } kgid_t;
=20
 #endif /* _LINUX_UIDGID_TYPES_H */
diff --git a/kernel/groups.c b/kernel/groups.c
index b5e3be6a6b..3aa0651d7a 100644
=2D-- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -73,18 +73,15 @@ static int groups_from_user(struct group_info *group_i=
nfo,
 	return 0;
 }
=20
-static int gid_cmp(const void *_a, const void *_b)
+static int groups_cmp(const void *_a, const void *_b)
 {
-	kgid_t a =3D *(kgid_t *)_a;
-	kgid_t b =3D *(kgid_t *)_b;
-
-	return gid_gt(a, b) - gid_lt(a, b);
+	return gid_cmp(*(kgid_t *)_a, *(kgid_t *)_b);
 }
=20
 void groups_sort(struct group_info *group_info)
 {
 	sort(group_info->gid, group_info->ngroups, sizeof(*group_info->gid),
-	     gid_cmp, NULL);
+	     groups_cmp, NULL);
 }
 EXPORT_SYMBOL(groups_sort);
=20
@@ -100,9 +97,11 @@ int groups_search(const struct group_info *group_info,=
 kgid_t grp)
 	right =3D group_info->ngroups;
 	while (left < right) {
 		unsigned int mid =3D (left+right)/2;
-		if (gid_gt(grp, group_info->gid[mid]))
+		int cmp =3D gid_cmp(grp, group_info->gid[mid]);
+
+		if (cmp > 0)
 			left =3D mid + 1;
-		else if (gid_lt(grp, group_info->gid[mid]))
+		else if (cmp < 0)
 			right =3D mid;
 		else
 			return 1;
diff --git a/kernel/ucount.c b/kernel/ucount.c
index ec8b1445e2..d34bc9ea9d 100644
=2D-- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -23,7 +23,7 @@ static struct hlist_nulls_head ucounts_hashtable[UCOUNTS=
_HASHTABLE_ENTRIES] =3D {
 static DEFINE_SPINLOCK(ucounts_lock);
=20
 #define ucounts_hashfn(ns, uid)						\
-	hash_long((unsigned long)__kuid_val(uid) + (unsigned long)(ns), \
+	hash_long((unsigned long)kuid_hash(uid) + (unsigned long)(ns), \
 		  UCOUNTS_HASHTABLE_BITS)
 #define ucounts_hashentry(ns, uid)	\
 	(ucounts_hashtable + ucounts_hashfn(ns, uid))
diff --git a/kernel/user.c b/kernel/user.c
index 21bafdc113..e41806bb70 100644
=2D-- a/kernel/user.c
+++ b/kernel/user.c
@@ -88,7 +88,7 @@ EXPORT_SYMBOL_GPL(init_user_ns);
 #define UIDHASH_SZ	(1 << UIDHASH_BITS)
 #define UIDHASH_MASK		(UIDHASH_SZ - 1)
 #define __uidhashfn(uid)	(((uid >> UIDHASH_BITS) + uid) & UIDHASH_MASK)
-#define uidhashentry(uid)	(uidhash_table + __uidhashfn((__kuid_val(uid)))=
)
+#define uidhashentry(uid)	(uidhash_table + __uidhashfn(kuid_hash(uid)))
=20
 static struct kmem_cache *uid_cachep;
 static struct hlist_head uidhash_table[UIDHASH_SZ];
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 0bed462e9b..88fc8ba586 100644
=2D-- a/kernel/user_namespace.c
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
=2D-- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -771,7 +771,7 @@ static void mark_oom_victim(struct task_struct *tsk)
 	thaw_process(tsk);
 	atomic_inc(&oom_victims);
 	cred =3D get_task_cred(tsk);
-	trace_mark_victim(tsk, cred->uid.val);
+	trace_mark_victim(tsk, __kuid_val(cred->uid));
 	put_cred(cred);
 }
=20
diff --git a/security/integrity/ima/ima_policy.c b/security/integrity/ima/=
ima_policy.c
index 68d9a5e6c2..839b88ea20 100644
=2D-- a/security/integrity/ima/ima_policy.c
+++ b/security/integrity/ima/ima_policy.c
@@ -81,22 +81,22 @@ struct ima_rule_opt_list {
  */
 static inline bool vfsuid_gt_kuid(vfsuid_t vfsuid, kuid_t kuid)
 {
-	return __vfsuid_val(vfsuid) > __kuid_val(kuid);
+	return vfsuid_cmp(vfsuid, VFSUIDT_INIT(kuid)) > 0;
 }
=20
 static inline bool vfsgid_gt_kgid(vfsgid_t vfsgid, kgid_t kgid)
 {
-	return __vfsgid_val(vfsgid) > __kgid_val(kgid);
+	return vfsgid_cmp(vfsgid, VFSGIDT_INIT(kgid)) > 0;
 }
=20
 static inline bool vfsuid_lt_kuid(vfsuid_t vfsuid, kuid_t kuid)
 {
-	return __vfsuid_val(vfsuid) < __kuid_val(kuid);
+	return vfsuid_cmp(vfsuid, VFSUIDT_INIT(kuid)) < 0;
 }
=20
 static inline bool vfsgid_lt_kgid(vfsgid_t vfsgid, kgid_t kgid)
 {
-	return __vfsgid_val(vfsgid) < __kgid_val(kgid);
+	return vfsgid_cmp(vfsgid, VFSGIDT_INIT(kgid)) < 0;
 }
=20
 struct ima_rule_entry {
=2D-=20
2.56.0

