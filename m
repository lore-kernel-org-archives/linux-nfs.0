Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552657;
	b=lTJthD8oiow+O5AFk78LsXnwJYagZfbJJmezcaKd8e/pa9VQZ8+uSn9MgcZHlo3BncPk
	 GO2eUF0yyQtBYP3CnX5uX+KmooNfDnRZk87zl4YI0eFXO8h+wu28EIH9D2bHPlf6ObxiI
	 BrolY5BUOhuLBpSMChYxR4fPskbeOP/Z7l9AT1qSlI8OgvIwWuNCYYp1PhKObD8vRlfuf
	 mqbnyt2QM8N46FC603uaIHyPeqdC2K++amLYrneQwkak6GYA9hc7pEzd1Gxss7VDTJftP
	 olafX6zWH22+cwT041Nd2HvYQwkaDzcjilLEZ+3ayXjklE0boNlZ8DHdgeUgzv8pjOQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552657;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=0oHcFGX5KxF/su2FIh5JI/fE9XKBP6YEnFlXttJ24D4=;
	b=o4pIUd+UVp0jWQdX0a1Z2+EngvCIocKL0l8tukpSWG22bnsxCYimt3ttXCYu4M4nJZtG
	 4i9+oy8SQOQAsntC/KjU/1vbGzsj31OZaVRwH1ZU0Za//4PTdBqKBSxRAesuymbEVwExt
	 gRhWZYtWyF2eIZ9d8AiJOAkcx1qPqz2xI0jxhX6IG6dETZukBPFKaFcjQROEFSvv7D5P1
	 KxSLm7SYzM66ZlEY0btmcaJ0h9bh5lxrS/qCA2uAtsvbzIbk9leb881wJSVsx5j67vKeJ
	 iUAfeWcBfnxvJVxR4NvtGD3UrPzkoyfcAOySnFNZa3EMQF32Inf/tbWhrRD5rJWPnJA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=MCCc3E42;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 300D5607B108;
	Wed, 21 Oct 2026 03:17:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 300D5607B108
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=MCCc3E42
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552654; bh=5FBWIR0hdbsAGfOVhieZxfLAOMETm3oaNAEGbNiEVKM=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=MCCc3E42yoPklxNzLbRznCnzlcJhsyjpzzbrKLseSGApzRpcESAvUKvmzT+7ol5DP
	 ZeOoKros8Is8s/pcWQ270h7IzM8JZmPpNFmB8G9oO8GCstb661S3KfkFFPbRIGNoI/
	 6om3Pnbhx82f+Hi6dCCV5kH6gstfPmx0AlXGXNUv9BSfJD30xhclWBdDo9oyHCXKjl
	 KmrzCIRgtGo9XIL+4Mag+eP3zy+9fjBR7aoemwaO2tcqSam37ocHleXCVPhQggQ4ut
	 J/b9hYKSURHRYp3h0AFB9HLrhO8mWt3/HrTiJ9LV3JgzGT6ZLIOgpWNmdnI//YinvE
	 7iK4B9thNaYvQ==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 5F0778A092D;
	Wed, 21 Oct 2026 05:17:33 +0200 (CEST)
Message-ID: <73dfe9aab6c5dd8152fa494d53f470f3bea53127.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 39/41] ksmbd: log in UUID and GUID users and map them
 to SIDs
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
Date: Wed, 21 Oct 2026 05:15:59 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

A user whose ids are UUIDs or GUIDs could not use ksmbd: the login
response carries 32 bit ids, sessions ran as make_kuid(uid), and SIDs
were built from from_kuid_munged(), so such users and their files all
became the overflow id.

Take the ids from the login response extension: flags, formerly
reserved and zero, has KSMBD_LOGIN_EXT_ID_R when uid_r and gid_r (also
formerly reserved) hold the user's ids as __kernel_uid_r_t, and
KSMBD_LOGIN_EXT_GROUPS_R when the payload holds __kernel_gid_r_t
supplementary groups instead of gid_t. struct ksmbd_user keeps kuid,
kgid and kgid_t groups, which the session's credentials and durable
handle owners use.

UUID and GUID users and groups have no RID; they are represented as
S-1-22-<kind>-w0-w1-w2-w3 (kind 3/4: UUID user/group, 5/6: GUID
user/group; w0..w3 the 16 bytes as big endian words), next to the
existing S-1-22-1-<uid> and S-1-22-2-<gid>, in security descriptors,
inherited ACEs, POSIX ACL entries and owner changes from clients.

The SMB3 POSIX extension's fixed 16 and 28 byte SID buffers can't hold
such a SID; they keep showing the overflow id.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/smb/server/ksmbd_netlink.h    |  15 ++-
 fs/smb/server/mgmt/user_config.c |  35 +++++-
 fs/smb/server/mgmt/user_config.h |   4 +-
 fs/smb/server/smb2pdu.c          |  10 +-
 fs/smb/server/smb_common.c       |  18 ++--
 fs/smb/server/smbacl.c           | 178 ++++++++++++++++++++++++-------
 fs/smb/server/smbacl.h           |  19 +++-
 fs/smb/server/transport_ipc.c    |   4 +-
 fs/smb/server/vfs_cache.c        |   9 +-
 fs/smb/server/vfs_cache.h        |   4 +-
 10 files changed, 229 insertions(+), 67 deletions(-)

diff --git a/fs/smb/server/ksmbd_netlink.h b/fs/smb/server/ksmbd_netlink.h
index 2673522c76..0d92d3fd4f 100644
--- a/fs/smb/server/ksmbd_netlink.h
+++ b/fs/smb/server/ksmbd_netlink.h
@@ -9,6 +9,7 @@
 #define _LINUX_KSMBD_SERVER_H
 
 #include <linux/types.h>
+#include <linux/uidgid_r.h>
 
 /*
  * This is a userspace ABI to communicate data between ksmbd and user IPC
@@ -153,14 +154,26 @@ struct ksmbd_login_response {
 
 /*
  * IPC user login response extension.
+ *
+ * With KSMBD_LOGIN_EXT_ID_R, uid_r and gid_r are the user's ids and may be
+ * UUIDs or GUIDs (see Documentation/userspace-api/uid_r.rst); the response's
+ * uid and gid are then ignored. With KSMBD_LOGIN_EXT_GROUPS_R the payload
+ * holds ngroups __kernel_gid_r_t instead of ngroups gid_t. A user space
+ * that knows neither leaves flags (formerly reserved) zero.
  */
 struct ksmbd_login_response_ext {
 	__u32	handle;
 	__s32	ngroups;			/* supplementary group count */
-	__s8	reserved[128];			/* Reserved room */
+	__u32	flags;				/* KSMBD_LOGIN_EXT_* */
+	__kernel_uid_r_t uid_r;			/* with KSMBD_LOGIN_EXT_ID_R */
+	__kernel_gid_r_t gid_r;
+	__s8	reserved[84];			/* Reserved room */
 	__s8	____payload[];
 };
 
+#define KSMBD_LOGIN_EXT_ID_R		0x1
+#define KSMBD_LOGIN_EXT_GROUPS_R	0x2
+
 /*
  * IPC request to fetch net share config.
  */
diff --git a/fs/smb/server/mgmt/user_config.c b/fs/smb/server/mgmt/user_config.c
index 5efc3d7455..cb175a4c78 100644
--- a/fs/smb/server/mgmt/user_config.c
+++ b/fs/smb/server/mgmt/user_config.c
@@ -56,6 +56,8 @@ struct ksmbd_user *ksmbd_alloc_user(struct ksmbd_login_response *resp,
 	user->flags = resp->status;
 	user->gid = resp->gid;
 	user->uid = resp->uid;
+	user->kuid = make_kuid(&init_user_ns, resp->uid);
+	user->kgid = make_kgid(&init_user_ns, resp->gid);
 	user->passkey_sz = resp->hash_sz;
 	user->passkey = kmalloc(resp->hash_sz, KSMBD_DEFAULT_GFP);
 	if (user->passkey)
@@ -68,12 +70,38 @@ struct ksmbd_user *ksmbd_alloc_user(struct ksmbd_login_response *resp,
 		goto err_free;
 
 	if (resp_ext) {
-		user->sgid = kmemdup(resp_ext->____payload,
-				     resp_ext->ngroups * sizeof(gid_t),
+		int i;
+
+		if (resp_ext->flags & KSMBD_LOGIN_EXT_ID_R) {
+			/* the user's ids may be UUIDs or GUIDs */
+			user->kuid = make_kuid_r(&init_user_ns, &resp_ext->uid_r);
+			user->kgid = make_kgid_r(&init_user_ns, &resp_ext->gid_r);
+			if (!uid_valid(user->kuid) || !gid_valid(user->kgid))
+				goto err_free;
+			user->uid = from_kuid_munged(&init_user_ns, user->kuid);
+			user->gid = from_kgid_munged(&init_user_ns, user->kgid);
+		}
+
+		user->sgid = kcalloc(resp_ext->ngroups, sizeof(kgid_t),
 				     KSMBD_DEFAULT_GFP);
-		if (!user->sgid)
+		if (!user->sgid && resp_ext->ngroups)
 			goto err_free;
 
+		for (i = 0; i < resp_ext->ngroups; i++) {
+			if (resp_ext->flags & KSMBD_LOGIN_EXT_GROUPS_R) {
+				const __kernel_gid_r_t *g = (const __kernel_gid_r_t *)
+					resp_ext->____payload + i;
+
+				user->sgid[i] = make_kgid_r(&init_user_ns, g);
+			} else {
+				const gid_t *g = (const gid_t *)resp_ext->____payload + i;
+
+				user->sgid[i] = make_kgid(&init_user_ns, *g);
+			}
+			if (!gid_valid(user->sgid[i]))
+				goto err_free;
+		}
+
 		user->ngroups = resp_ext->ngroups;
 		ksmbd_debug(SMB, "supplementary groups : %d\n", user->ngroups);
 	}
@@ -81,6 +109,7 @@ struct ksmbd_user *ksmbd_alloc_user(struct ksmbd_login_response *resp,
 	return user;
 
 err_free:
+	kfree(user->sgid);
 	kfree(user->name);
 	kfree_sensitive(user->passkey);
 	kfree(user);
diff --git a/fs/smb/server/mgmt/user_config.h b/fs/smb/server/mgmt/user_config.h
index cc460b4ff7..e55470e008 100644
--- a/fs/smb/server/mgmt/user_config.h
+++ b/fs/smb/server/mgmt/user_config.h
@@ -13,13 +13,15 @@ struct ksmbd_user {
 
 	unsigned int		uid;
 	unsigned int		gid;
+	kuid_t			kuid;	/* the user: uid, or a UUID or GUID */
+	kgid_t			kgid;
 
 	char			*name;
 
 	size_t			passkey_sz;
 	char			*passkey;
 	int			ngroups;
-	gid_t			*sgid;
+	kgid_t			*sgid;
 };
 
 static inline bool user_guest(struct ksmbd_user *user)
diff --git a/fs/smb/server/smb2pdu.c b/fs/smb/server/smb2pdu.c
index 6b8809f67b..ba29f9436e 100644
--- a/fs/smb/server/smb2pdu.c
+++ b/fs/smb/server/smb2pdu.c
@@ -4577,14 +4577,14 @@ int smb2_open(struct ksmbd_work *work)
 	if (file_present && !(req->CreateOptions & FILE_DELETE_ON_CLOSE_LE)) {
 		rc = smb_check_perm_dacl(conn, &path, &daccess,
 					 req->DesiredAccess,
-					 sess->user->uid, false);
+					 sess->user->kuid, false);
 		if (rc)
 			goto err_out;
 
 		if (maximal_access_ctxt) {
 			maximal_access = FILE_MAXIMAL_ACCESS_LE;
 			rc = smb_check_perm_dacl(conn, &path, &maximal_access,
-						 0, sess->user->uid, false);
+						 0, sess->user->kuid, false);
 			if (rc)
 				goto err_out;
 
@@ -4776,8 +4776,8 @@ int smb2_open(struct ksmbd_work *work)
 		if (rc == -ENOENT) {
 			if (test_share_config_flag(work->tcon->share_conf,
 						   KSMBD_SHARE_FLAG_ACL_XATTR)) {
-				rc = smb_inherit_dacl(conn, &path, sess->user->uid,
-						      sess->user->gid);
+				rc = smb_inherit_dacl(conn, &path, sess->user->kuid,
+						      sess->user->kgid);
 			}
 			if (rc) {
 				if (posix_acl_rc)
@@ -5837,7 +5837,7 @@ static int process_query_dir_entries(struct smb2_query_dir_private *priv)
 			path.dentry = dent;
 			rc = smb_check_perm_dacl(priv->work->conn, &path,
 						 &daccess, daccess,
-						 priv->work->sess->user->uid,
+						 priv->work->sess->user->kuid,
 						 true);
 			if (rc) {
 				dput(dent);
diff --git a/fs/smb/server/smb_common.c b/fs/smb/server/smb_common.c
index 4c2da65510..ace3421e57 100644
--- a/fs/smb/server/smb_common.c
+++ b/fs/smb/server/smb_common.c
@@ -797,23 +797,23 @@ int __ksmbd_override_fsids(struct ksmbd_work *work,
 	struct ksmbd_user *user = sess->user;
 	struct cred *cred;
 	struct group_info *gi;
-	unsigned int uid;
-	unsigned int gid;
+	kuid_t uid;
+	kgid_t gid;
 	int i;
 
-	uid = user_uid(user);
-	gid = user_gid(user);
+	uid = user->kuid;
+	gid = user->kgid;
 	if (share->force_uid != KSMBD_SHARE_INVALID_UID)
-		uid = share->force_uid;
+		uid = make_kuid(&init_user_ns, share->force_uid);
 	if (share->force_gid != KSMBD_SHARE_INVALID_GID)
-		gid = share->force_gid;
+		gid = make_kgid(&init_user_ns, share->force_gid);
 
 	cred = prepare_kernel_cred(&init_task);
 	if (!cred)
 		return -ENOMEM;
 
-	cred->fsuid = make_kuid(&init_user_ns, uid);
-	cred->fsgid = make_kgid(&init_user_ns, gid);
+	cred->fsuid = uid;
+	cred->fsgid = gid;
 
 	gi = groups_alloc(user->ngroups);
 	if (!gi) {
@@ -822,7 +822,7 @@ int __ksmbd_override_fsids(struct ksmbd_work *work,
 	}
 
 	for (i = 0; i < user->ngroups; i++)
-		gi->gid[i] = make_kgid(&init_user_ns, user->sgid[i]);
+		gi->gid[i] = user->sgid[i];
 
 	if (user->ngroups)
 		groups_sort(gi);
diff --git a/fs/smb/server/smbacl.c b/fs/smb/server/smbacl.c
index 1fad6ccf3a..126264cc07 100644
--- a/fs/smb/server/smbacl.c
+++ b/fs/smb/server/smbacl.c
@@ -7,6 +7,7 @@
  */
 
 #include <linux/fs.h>
+#include <linux/unaligned.h>
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/mnt_idmapping.h>
@@ -257,6 +258,67 @@ void id_to_sid(unsigned int cid, uint sidtype, struct smb_sid *ssid)
 	ssid->num_subauth++;
 }
 
+/*
+ * UUID and GUID users and groups (Documentation/userspace-api/uid_r.rst)
+ * have no RID: they are S-1-22-<kind>-w0-w1-w2-w3, the 16 bytes of the id
+ * as four big endian words, next to S-1-22-1-<uid> and S-1-22-2-<gid>.
+ */
+#define SID_UNIX_UUID_USER	3
+#define SID_UNIX_UUID_GROUP	4
+#define SID_UNIX_GUID_USER	5
+#define SID_UNIX_GUID_GROUP	6
+
+static void id_r_to_sid(u32 kind, const u8 *id, struct smb_sid *ssid)
+{
+	int i;
+
+	smb_copy_sid(ssid, &sid_unix_users);
+	ssid->sub_auth[0] = cpu_to_le32(kind);
+	for (i = 0; i < 4; i++)
+		ssid->sub_auth[1 + i] = cpu_to_le32(get_unaligned_be32(id + 4 * i));
+	ssid->num_subauth = 5;
+}
+
+/* the kind (SID_UNIX_*) and 16 bytes of a UUID or GUID SID, or 0 */
+static u32 sid_to_id_r(const struct smb_sid *psid, u8 *id)
+{
+	u32 kind;
+	int i;
+
+	if (psid->num_subauth != 5 || psid->revision != sid_unix_users.revision ||
+	    memcmp(psid->authority, sid_unix_users.authority, NUM_AUTHS))
+		return 0;
+	kind = le32_to_cpu(psid->sub_auth[0]);
+	if (kind < SID_UNIX_UUID_USER || kind > SID_UNIX_GUID_GROUP)
+		return 0;
+	for (i = 0; i < 4; i++)
+		put_unaligned_be32(le32_to_cpu(psid->sub_auth[1 + i]), id + 4 * i);
+	return kind;
+}
+
+/* id_to_sid() for any kuid: a classic one gets the usual SIDs */
+void ksmbd_uid_to_sid(kuid_t uid, uint sidtype, struct smb_sid *ssid)
+{
+	if (uid_is_legacy(uid) || sidtype == SIDCREATOR_OWNER ||
+	    sidtype == SIDCREATOR_GROUP)
+		id_to_sid(from_kuid_munged(&init_user_ns, uid), sidtype, ssid);
+	else if (uid.type == KID_UUID)
+		id_r_to_sid(SID_UNIX_UUID_USER, uid.uuid.b, ssid);
+	else
+		id_r_to_sid(SID_UNIX_GUID_USER, uid.guid.b, ssid);
+}
+
+void ksmbd_gid_to_sid(kgid_t gid, uint sidtype, struct smb_sid *ssid)
+{
+	if (gid_is_legacy(gid) || sidtype == SIDCREATOR_OWNER ||
+	    sidtype == SIDCREATOR_GROUP)
+		id_to_sid(from_kgid_munged(&init_user_ns, gid), sidtype, ssid);
+	else if (gid.type == KID_UUID)
+		id_r_to_sid(SID_UNIX_UUID_GROUP, gid.uuid.b, ssid);
+	else
+		id_r_to_sid(SID_UNIX_GUID_GROUP, gid.guid.b, ssid);
+}
+
 static int sid_to_id(struct mnt_idmap *idmap,
 		     struct smb_sid *psid, uint sidtype,
 		     struct smb_fattr *fattr)
@@ -279,6 +341,42 @@ static int sid_to_id(struct mnt_idmap *idmap,
 		return -EIO;
 	}
 
+	{
+		u8 id[16];
+		u32 kind = sid_to_id_r(psid, id);
+
+		if (kind && sidtype == SIDOWNER &&
+		    (kind == SID_UNIX_UUID_USER || kind == SID_UNIX_GUID_USER)) {
+			kuid_t uid;
+
+			if (kind == SID_UNIX_UUID_USER)
+				uid = KUIDT_INIT_UUID(*(uuid_t *)id);
+			else
+				uid = KUIDT_INIT_GUID(*(guid_t *)id);
+			uid = from_vfsuid(idmap, &init_user_ns, VFSUIDT_INIT(uid));
+			if (!uid_valid(uid))
+				return -EINVAL;
+			fattr->cf_uid = uid;
+			return 0;
+		}
+		if (kind && sidtype != SIDOWNER &&
+		    (kind == SID_UNIX_UUID_GROUP || kind == SID_UNIX_GUID_GROUP)) {
+			kgid_t gid;
+
+			if (kind == SID_UNIX_UUID_GROUP)
+				gid = KGIDT_INIT_UUID(*(uuid_t *)id);
+			else
+				gid = KGIDT_INIT_GUID(*(guid_t *)id);
+			gid = from_vfsgid(idmap, &init_user_ns, VFSGIDT_INIT(gid));
+			if (!gid_valid(gid))
+				return -EINVAL;
+			fattr->cf_gid = gid;
+			return 0;
+		}
+		if (kind)
+			return -EINVAL;
+	}
+
 	if (sidtype == SIDOWNER) {
 		kuid_t uid;
 		uid_t id;
@@ -643,18 +741,18 @@ static void set_posix_acl_entries_dacl(struct mnt_idmap *idmap,
 			break;
 
 		if (pace->e_tag == ACL_USER) {
-			uid_t uid;
+			kuid_t uid;
 			unsigned int sid_type = SIDOWNER;
 
-			uid = posix_acl_uid_translate(idmap, pace);
-			if (!uid)
+			uid = posix_acl_kuid_translate(idmap, pace);
+			if (uid_eq(uid, GLOBAL_ROOT_UID))
 				sid_type = SIDUNIX_USER;
-			id_to_sid(uid, sid_type, sid);
+			ksmbd_uid_to_sid(uid, sid_type, sid);
 		} else if (pace->e_tag == ACL_GROUP) {
-			gid_t gid;
+			kgid_t gid;
 
-			gid = posix_acl_gid_translate(idmap, pace);
-			id_to_sid(gid, SIDUNIX_GROUP, sid);
+			gid = posix_acl_kgid_translate(idmap, pace);
+			ksmbd_gid_to_sid(gid, SIDUNIX_GROUP, sid);
 		} else if (pace->e_tag == ACL_OTHER && !had_nt_aces) {
 			smb_copy_sid(sid, &sid_everyone);
 		} else {
@@ -816,7 +914,7 @@ static void set_mode_dacl(struct mnt_idmap *idmap,
 	u16 num_aces = 0;
 	u16 size = 0, ace_size = 0;
 	uid_t uid;
-	const struct smb_sid *sid;
+	struct smb_sid owner_sid, group_sid;
 
 	pace = pndace = (struct smb_ace *)((char *)pndacl + sizeof(struct smb_acl));
 
@@ -826,25 +924,20 @@ static void set_mode_dacl(struct mnt_idmap *idmap,
 		goto out;
 	}
 
-	/* owner RID */
+	/* owner: RID, or a UUID or GUID SID */
 	uid = from_kuid(&init_user_ns, fattr->cf_uid);
-	if (uid)
-		sid = &server_conf.domain_sid;
-	else
-		sid = &sid_unix_users;
-	ace_size = fill_ace_for_sid(pace, sid, ACCESS_ALLOWED, 0,
+	ksmbd_uid_to_sid(fattr->cf_uid, uid ? SIDOWNER : SIDUNIX_USER, &owner_sid);
+	ace_size = fill_ace_for_sid(pace, &owner_sid, ACCESS_ALLOWED, 0,
 				    fattr->cf_mode, 0700);
-	pace->sid.sub_auth[pace->sid.num_subauth++] = cpu_to_le32(uid);
-	pace->size = cpu_to_le16(ace_size + 4);
+	pace->size = cpu_to_le16(ace_size);
 	size += le16_to_cpu(pace->size);
 	pace = (struct smb_ace *)((char *)pndace + size);
 
-	/* Group RID */
-	ace_size = fill_ace_for_sid(pace, &sid_unix_groups,
+	/* Group: RID, or a UUID or GUID SID */
+	ksmbd_gid_to_sid(fattr->cf_gid, SIDUNIX_GROUP, &group_sid);
+	ace_size = fill_ace_for_sid(pace, &group_sid,
 				    ACCESS_ALLOWED, 0, fattr->cf_mode, 0070);
-	pace->sid.sub_auth[pace->sid.num_subauth++] =
-		cpu_to_le32(from_kgid(&init_user_ns, fattr->cf_gid));
-	pace->size = cpu_to_le16(ace_size + 4);
+	pace->size = cpu_to_le16(ace_size);
 	size += le16_to_cpu(pace->size);
 	pace = (struct smb_ace *)((char *)pndace + size);
 	num_aces = 3;
@@ -1041,7 +1134,6 @@ int build_sec_desc(struct mnt_idmap *idmap,
 	struct smb_sid *nowner_sid_ptr, *ngroup_sid_ptr;
 	struct smb_acl *dacl_ptr = NULL; /* no need for SACL ptr */
 	uid_t uid;
-	gid_t gid;
 	unsigned int sid_type = SIDOWNER;
 
 	nowner_sid_ptr = kmalloc_obj(struct smb_sid, KSMBD_DEFAULT_GFP);
@@ -1051,7 +1143,7 @@ int build_sec_desc(struct mnt_idmap *idmap,
 	uid = from_kuid(&init_user_ns, fattr->cf_uid);
 	if (!uid)
 		sid_type = SIDUNIX_USER;
-	id_to_sid(uid, sid_type, nowner_sid_ptr);
+	ksmbd_uid_to_sid(fattr->cf_uid, sid_type, nowner_sid_ptr);
 
 	ngroup_sid_ptr = kmalloc_obj(struct smb_sid, KSMBD_DEFAULT_GFP);
 	if (!ngroup_sid_ptr) {
@@ -1059,8 +1151,7 @@ int build_sec_desc(struct mnt_idmap *idmap,
 		return -ENOMEM;
 	}
 
-	gid = from_kgid(&init_user_ns, fattr->cf_gid);
-	id_to_sid(gid, SIDUNIX_GROUP, ngroup_sid_ptr);
+	ksmbd_gid_to_sid(fattr->cf_gid, SIDUNIX_GROUP, ngroup_sid_ptr);
 
 	offset = sizeof(struct smb_ntsd);
 	pntsd->sacloffset = 0;
@@ -1188,7 +1279,7 @@ static int smb_validate_ntsd_sid(struct smb_ntsd *pntsd, size_t pntsd_size,
 
 int smb_inherit_dacl(struct ksmbd_conn *conn,
 		     const struct path *path,
-		     unsigned int uid, unsigned int gid)
+		     kuid_t uid, kgid_t gid)
 {
 	const struct smb_sid *psid, *creator = NULL;
 	struct smb_ace *parent_aces, *aces;
@@ -1295,11 +1386,11 @@ int smb_inherit_dacl(struct ksmbd_conn *conn,
 
 		if (!compare_sids(&creator_owner, &parent_aces->sid)) {
 			creator = &creator_owner;
-			id_to_sid(uid, SIDOWNER, &owner_sid);
+			ksmbd_uid_to_sid(uid, SIDOWNER, &owner_sid);
 			psid = &owner_sid;
 		} else if (!compare_sids(&creator_group, &parent_aces->sid)) {
 			creator = &creator_group;
-			id_to_sid(gid, SIDUNIX_GROUP, &group_sid);
+			ksmbd_gid_to_sid(gid, SIDUNIX_GROUP, &group_sid);
 			psid = &group_sid;
 		} else {
 			creator = NULL;
@@ -1448,7 +1539,7 @@ bool smb_inherit_flags(int flags, bool is_dir)
 }
 
 int smb_check_perm_dacl(struct ksmbd_conn *conn, const struct path *path,
-			__le32 *pdaccess, __le32 raw_daccess, int uid,
+			__le32 *pdaccess, __le32 raw_daccess, kuid_t uid,
 			bool strict)
 {
 	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
@@ -1499,11 +1590,11 @@ int smb_check_perm_dacl(struct ksmbd_conn *conn, const struct path *path,
 		goto err_out;
 	}
 
-	if (!uid)
+	if (uid_eq(uid, GLOBAL_ROOT_UID))
 		sid_type = SIDUNIX_USER;
-	id_to_sid(uid, sid_type, &sid);
+	ksmbd_uid_to_sid(uid, sid_type, &sid);
 	vfsuid = i_uid_into_vfsuid(idmap, d_inode(path->dentry));
-	is_owner = uid == from_kuid(&init_user_ns, vfsuid_into_kuid(vfsuid));
+	is_owner = uid_eq(uid, vfsuid_into_kuid(vfsuid));
 
 	if (*pdaccess & FILE_MAXIMAL_ACCESS_LE) {
 		ace = (struct smb_ace *)((char *)pdacl + sizeof(struct smb_acl));
@@ -1596,18 +1687,27 @@ int smb_check_perm_dacl(struct ksmbd_conn *conn, const struct path *path,
 	if (IS_ENABLED(CONFIG_FS_POSIX_ACL)) {
 		posix_acls = get_inode_acl(d_inode(path->dentry), ACL_TYPE_ACCESS);
 		if (!IS_ERR_OR_NULL(posix_acls) && !found && !others_ace) {
-			unsigned int id = -1;
+			kuid_t pa_uid;
+			bool match;
 
 			pa_entry = posix_acls->a_entries;
 			for (i = 0; i < posix_acls->a_count; i++, pa_entry++) {
-				if (pa_entry->e_tag == ACL_USER)
-					id = posix_acl_uid_translate(idmap, pa_entry);
-				else if (pa_entry->e_tag == ACL_GROUP)
-					id = posix_acl_gid_translate(idmap, pa_entry);
-				else
+				/*
+				 * A group entry matches a gid equal to the uid,
+				 * as it always has.
+				 */
+				if (pa_entry->e_tag == ACL_USER) {
+					pa_uid = posix_acl_kuid_translate(idmap, pa_entry);
+					match = uid_eq(pa_uid, uid);
+				} else if (pa_entry->e_tag == ACL_GROUP) {
+					match = uid_is_legacy(uid) &&
+						posix_acl_gid_translate(idmap, pa_entry) ==
+						from_kuid(&init_user_ns, uid);
+				} else {
 					continue;
+				}
 
-				if (id == uid) {
+				if (match) {
 					mode_to_access_flags(pa_entry->e_perm,
 							     0777,
 							     &access_bits);
diff --git a/fs/smb/server/smbacl.h b/fs/smb/server/smbacl.h
index 01810c16cc..b6a01f0d45 100644
--- a/fs/smb/server/smbacl.h
+++ b/fs/smb/server/smbacl.h
@@ -93,18 +93,33 @@ void posix_state_to_acl(struct posix_acl_state *state,
 int compare_sids(const struct smb_sid *ctsid, const struct smb_sid *cwsid);
 bool smb_inherit_flags(int flags, bool is_dir);
 int smb_inherit_dacl(struct ksmbd_conn *conn, const struct path *path,
-		     unsigned int uid, unsigned int gid);
+		     kuid_t uid, kgid_t gid);
 int smb_check_perm_dacl(struct ksmbd_conn *conn, const struct path *path,
-			__le32 *pdaccess, __le32 raw_daccess, int uid,
+			__le32 *pdaccess, __le32 raw_daccess, kuid_t uid,
 			bool strict);
 int set_info_sec(struct ksmbd_conn *conn, struct ksmbd_tree_connect *tcon,
 		 const struct path *path, struct smb_ntsd *pntsd, int ntsd_len,
 		 bool type_check, bool get_write);
 void id_to_sid(unsigned int cid, uint sidtype, struct smb_sid *ssid);
+void ksmbd_uid_to_sid(kuid_t uid, uint sidtype, struct smb_sid *ssid);
+void ksmbd_gid_to_sid(kgid_t gid, uint sidtype, struct smb_sid *ssid);
 void ksmbd_init_domain(u32 *sub_auth);
 size_t smb_acl_sec_desc_scratch_len(struct smb_fattr *fattr,
 		struct smb_ntsd *ppntsd, int ppntsd_size, int addition_info);
 
+/* the owner of an ACL entry as a kuid (also a UUID or GUID) */
+static inline kuid_t posix_acl_kuid_translate(struct mnt_idmap *idmap,
+					      struct posix_acl_entry *pace)
+{
+	return vfsuid_into_kuid(make_vfsuid(idmap, &init_user_ns, pace->e_uid));
+}
+
+static inline kgid_t posix_acl_kgid_translate(struct mnt_idmap *idmap,
+					      struct posix_acl_entry *pace)
+{
+	return vfsgid_into_kgid(make_vfsgid(idmap, &init_user_ns, pace->e_gid));
+}
+
 static inline uid_t posix_acl_uid_translate(struct mnt_idmap *idmap,
 					    struct posix_acl_entry *pace)
 {
diff --git a/fs/smb/server/transport_ipc.c b/fs/smb/server/transport_ipc.c
index e550aa41ad..71270c780d 100644
--- a/fs/smb/server/transport_ipc.c
+++ b/fs/smb/server/transport_ipc.c
@@ -564,7 +564,9 @@ static int ipc_validate_msg(struct ipc_msg_table_entry *entry)
 				return -EINVAL;
 			}
 			msg_sz = sizeof(struct ksmbd_login_response_ext) +
-					resp->ngroups * sizeof(gid_t);
+					resp->ngroups *
+					(resp->flags & KSMBD_LOGIN_EXT_GROUPS_R ?
+					 sizeof(__kernel_gid_r_t) : sizeof(gid_t));
 		}
 	}
 	}
diff --git a/fs/smb/server/vfs_cache.c b/fs/smb/server/vfs_cache.c
index fd2c595f04..89686cfc67 100644
--- a/fs/smb/server/vfs_cache.c
+++ b/fs/smb/server/vfs_cache.c
@@ -1715,8 +1715,8 @@ int ksmbd_vfs_set_durable_owner(struct ksmbd_file *fp,
 
 	spin_lock(&fp->f_lock);
 	old_name = fp->owner.name;
-	fp->owner.uid = user->uid;
-	fp->owner.gid = user->gid;
+	fp->owner.uid = user->kuid;
+	fp->owner.gid = user->kgid;
 	fp->owner.name = name;
 	spin_unlock(&fp->f_lock);
 	kfree(old_name);
@@ -1747,7 +1747,7 @@ bool ksmbd_vfs_compare_durable_owner(struct ksmbd_file *fp,
 		goto out;
 
 	/* Check if the UID and GID match first (fast path) */
-	if (fp->owner.uid != user->uid || fp->owner.gid != user->gid)
+	if (!uid_eq(fp->owner.uid, user->kuid) || !gid_eq(fp->owner.gid, user->kgid))
 		goto out;
 
 	/* Validate the account name to ensure the same SecurityContext */
@@ -1953,7 +1953,8 @@ int ksmbd_reopen_durable_fd(struct ksmbd_work *work, struct ksmbd_file *fp)
 	up_write(&ci->m_lock);
 
 	spin_lock(&fp->f_lock);
-	fp->owner.uid = fp->owner.gid = 0;
+	fp->owner.uid = GLOBAL_ROOT_UID;
+	fp->owner.gid = GLOBAL_ROOT_GID;
 	kfree(fp->owner.name);
 	fp->owner.name = NULL;
 	spin_unlock(&fp->f_lock);
diff --git a/fs/smb/server/vfs_cache.h b/fs/smb/server/vfs_cache.h
index 1884f6deb9..396e11f88c 100644
--- a/fs/smb/server/vfs_cache.h
+++ b/fs/smb/server/vfs_cache.h
@@ -77,8 +77,8 @@ enum {
 
 /* Owner information for durable handle reconnect */
 struct durable_owner {
-	unsigned int uid;
-	unsigned int gid;
+	kuid_t		uid;
+	kgid_t		gid;
 	char *name;
 };
 
-- 
2.56.0

