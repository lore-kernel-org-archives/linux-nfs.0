Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552570;
	b=V136J1YJZ+Ed/ebBH9NhrdkBEK7ghlBQEqpZ2r5FL1fUFrfGloUDRmwzKpoip2XjQHjN
	 Qa4ddDY0lVkH7CTPB79JrMr7gL9q/rgs4aY8rr+Kokju/DHr6shu8xqee4NE/qgp/H8PS
	 O2qnuEhYXube9HN3DB+zgp674lUFQv7B56bMR4bIe1hZK6bq288MFDu0g+OQWaLAxWx/U
	 AMuYoBW6sWPnGgsFPYFj2aQ9nkinv2dGUI/e+vFAyv7mdeeRfmZywVGoTK94rvur1Sy40
	 71oNzpOkJszEGZKYueV5IyDSuBI2gSeSwy20fJj1Xqf2uKmhIkZWs7pQP8Ar1DfePuA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552570;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=qdX/if/Vks4LtHia0l+fUvYqJOpb6zoMHl+LWjeHHoU=;
	b=1e5I8+6nP7xZ8KRc/y4FZHqxBBmcP6bl3hdtAPM26TsvssscJOfDPrUm6q0Cqp8QmiJd
	 azfmFQZfIPxLkVbPg2y43lev0AT5GAwGkC/vj9epCsROuRyQUKBV/Uc6Rr1oqTsUWAYHV
	 zcQJ+BUGhQGXwywaPpxCFqAXsplB/gAf56GJRMJHKP5AmJ6s7Q+8G43cU6NR8UWEUDZbN
	 HTmdIVrj3HjrIDOoFj5u2pWB0KO4zIDSSG4YR6aDK9acbH2IOVi4tf/KvS/jcBtEt6wMS
	 ZVKwKy5PbbxXeGamQWJzyCOKIPynEKeK3jIWJIla6l8czdHH7RDEc4tBy3qxn24ovVA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=IE3zmQFM;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8748F606A337;
	Wed, 21 Oct 2026 03:16:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8748F606A337
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=IE3zmQFM
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552562; bh=y6zy55wnqQPEYhv9B99usCt+PFRA22CLnDaPf4ccMxU=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=IE3zmQFMMKAavC/e4BOe+uE+Gt9ga+95eM4Hx3E4t+4E1U9UsnGEswLeYkd+foUxw
	 lsK80KaJc+Tb7ljhTDSvZT3hudkr+7Ff1IyK9GUwpSNiw2cwqRSjooG4tb0740ExhR
	 fog+ikSME3zgm/TwqzYTQQL1bLGIgCPSYYFr0tLZdMQqQsBVtPdN3/oZ8xRlcsLTeq
	 W8UrjomwsinTXdtG73C4FZBffZ3szS+KPrxRX9t6GHewiHXIGuc+QYKiXvIFlKirK8
	 O+vn8/O/1CeaDg7a4IikJD6yHNLS6TimfkPpe4/asJuByWUHqL7RssB+uoRIWEK+E8
	 H+357dO7W8+GQ==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id EAE048A0927;
	Wed, 21 Oct 2026 05:16:01 +0200 (CEST)
Message-ID: <54affe23a0160331a14a3e993ea30b0d5af7df1a.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 12/41] keys: name per-user keyrings of UUID and GUID
 users by the whole uid
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
Date: Wed, 21 Oct 2026 05:15:32 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

The user keyring, the user session keyring and the persistent keyring
are found by name: "_uid.<uid>", "_uid_ses.<uid>" and
"_persistent.<uid>", the uid in the caller's user namespace. A UUID or
GUID uid has none and comes out as -1, so all such users would find
and share the same keyrings -- each other's keys.

Name their keyrings after the text form of the uid (kuid_str()), which
is unique; classic uids keep their names. Hand request-key the text
form as well instead of -1.

Also add KEYCTL_CHOWN_R, KEYCTL_CHOWN with __kernel_uid_r_t ids, so keys
can be given to UUID and GUID users and groups.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 include/uapi/linux/keyctl.h  |  1 +
 security/keys/compat.c       |  3 ++
 security/keys/internal.h     |  3 ++
 security/keys/keyctl.c       | 61 ++++++++++++++++++++++++++----------
 security/keys/persistent.c   | 11 +++++--
 security/keys/process_keys.c | 36 +++++++++++++++------
 security/keys/request_key.c  | 12 +++++--
 7 files changed, 97 insertions(+), 30 deletions(-)

diff --git a/include/uapi/linux/keyctl.h b/include/uapi/linux/keyctl.h
index 4c8884eea8..73ee0cb7b7 100644
--- a/include/uapi/linux/keyctl.h
+++ b/include/uapi/linux/keyctl.h
@@ -70,6 +70,7 @@
 #define KEYCTL_MOVE			30	/* Move keys between keyrings */
 #define KEYCTL_CAPABILITIES		31	/* Find capabilities of keyrings subsystem */
 #define KEYCTL_WATCH_KEY		32	/* Watch a key or ring of keys for changes */
+#define KEYCTL_CHOWN_R			33	/* set ownership of a key, __kernel_uid_r_t ids */
 
 /* keyctl structures */
 struct keyctl_dh_params {
diff --git a/security/keys/compat.c b/security/keys/compat.c
index 1545efdca5..c7acf7db59 100644
--- a/security/keys/compat.c
+++ b/security/keys/compat.c
@@ -52,6 +52,9 @@ COMPAT_SYSCALL_DEFINE5(keyctl, u32, option,
 	case KEYCTL_CHOWN:
 		return keyctl_chown_key(arg2, arg3, arg4);
 
+	case KEYCTL_CHOWN_R:
+		return keyctl_chown_key_r(arg2, compat_ptr(arg3), compat_ptr(arg4));
+
 	case KEYCTL_SETPERM:
 		return keyctl_setperm_key(arg2, arg3);
 
diff --git a/security/keys/internal.h b/security/keys/internal.h
index b7b622bc36..63874fa531 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -249,6 +249,9 @@ extern long keyctl_keyring_search(key_serial_t, const char __user *,
 				  const char __user *, key_serial_t);
 extern long keyctl_read_key(key_serial_t, char __user *, size_t);
 extern long keyctl_chown_key(key_serial_t, uid_t, gid_t);
+extern long keyctl_chown_key_r(key_serial_t id,
+			       const struct __kernel_uid_r __user *user,
+			       const struct __kernel_uid_r __user *group);
 extern long keyctl_setperm_key(key_serial_t, key_perm_t);
 extern long keyctl_instantiate_key(key_serial_t, const void __user *,
 				   size_t, key_serial_t);
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index d14ace88e5..984c9c54a5 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -946,26 +946,17 @@ long keyctl_read_key(key_serial_t keyid, char __user *buffer, size_t buflen)
  *
  * If successful, 0 will be returned.
  */
-long keyctl_chown_key(key_serial_t id, uid_t user, gid_t group)
+static long keyctl_chown_kid(key_serial_t id, kuid_t uid, kgid_t gid)
 {
 	struct key_user *newowner, *zapowner = NULL;
 	struct key *key;
 	key_ref_t key_ref;
 	long ret;
-	kuid_t uid;
-	kgid_t gid;
 	unsigned long flags;
 
-	uid = make_kuid(current_user_ns(), user);
-	gid = make_kgid(current_user_ns(), group);
-	ret = -EINVAL;
-	if ((user != (uid_t) -1) && !uid_valid(uid))
-		goto error;
-	if ((group != (gid_t) -1) && !gid_valid(gid))
-		goto error;
-
+	/* invalid ids leave the owner or group unchanged */
 	ret = 0;
-	if (user == (uid_t) -1 && group == (gid_t) -1)
+	if (!uid_valid(uid) && !gid_valid(gid))
 		goto error;
 
 	key_ref = lookup_user_key(id, KEY_LOOKUP_CREATE | KEY_LOOKUP_PARTIAL,
@@ -985,12 +976,12 @@ long keyctl_chown_key(key_serial_t id, uid_t user, gid_t group)
 		bool is_privileged_op = false;
 
 		/* only the sysadmin can chown a key to some other UID */
-		if (user != (uid_t) -1 && !uid_eq(key->uid, uid))
+		if (uid_valid(uid) && !uid_eq(key->uid, uid))
 			is_privileged_op = true;
 
 		/* only the sysadmin can set the key's GID to a group other
 		 * than one of those that the current process subscribes to */
-		if (group != (gid_t) -1 && !gid_eq(gid, key->gid) && !in_group_p(gid))
+		if (gid_valid(gid) && !gid_eq(gid, key->gid) && !in_group_p(gid))
 			is_privileged_op = true;
 
 		if (is_privileged_op && !capable(CAP_SYS_ADMIN))
@@ -998,7 +989,7 @@ long keyctl_chown_key(key_serial_t id, uid_t user, gid_t group)
 	}
 
 	/* change the UID */
-	if (user != (uid_t) -1 && !uid_eq(uid, key->uid)) {
+	if (uid_valid(uid) && !uid_eq(uid, key->uid)) {
 		ret = -ENOMEM;
 		newowner = key_user_lookup(uid);
 		if (!newowner)
@@ -1042,7 +1033,7 @@ long keyctl_chown_key(key_serial_t id, uid_t user, gid_t group)
 	}
 
 	/* change the GID */
-	if (group != (gid_t) -1)
+	if (gid_valid(gid))
 		key->gid = gid;
 
 	notify_key(key, NOTIFY_KEY_SETATTR, 0);
@@ -1063,6 +1054,39 @@ long keyctl_chown_key(key_serial_t id, uid_t user, gid_t group)
 	goto error_put;
 }
 
+long keyctl_chown_key(key_serial_t id, uid_t user, gid_t group)
+{
+	kuid_t uid = make_kuid(current_user_ns(), user);
+	kgid_t gid = make_kgid(current_user_ns(), group);
+
+	if ((user != (uid_t) -1) && !uid_valid(uid))
+		return -EINVAL;
+	if ((group != (gid_t) -1) && !gid_valid(gid))
+		return -EINVAL;
+	return keyctl_chown_kid(id, uid, gid);
+}
+
+/*
+ * KEYCTL_CHOWN with __kernel_uid_r_t ids, which can be UUIDs and GUIDs. A
+ * NULL pointer, UID_R_NONE or a classic -1 leave the owner or group
+ * unchanged.
+ */
+long keyctl_chown_key_r(key_serial_t id,
+			const struct __kernel_uid_r __user *user,
+			const struct __kernel_uid_r __user *group)
+{
+	kuid_t uid;
+	kgid_t gid;
+	long ret;
+
+	ret = get_kuid_r(current_user_ns(), user, &uid);
+	if (!ret)
+		ret = get_kgid_r(current_user_ns(), group, &gid);
+	if (ret)
+		return ret;
+	return keyctl_chown_kid(id, uid, gid);
+}
+
 /*
  * Change the permission mask on a key.
  *
@@ -1934,6 +1958,11 @@ SYSCALL_DEFINE5(keyctl, int, option, unsigned long, arg2, unsigned long, arg3,
 					(uid_t) arg3,
 					(gid_t) arg4);
 
+	case KEYCTL_CHOWN_R:
+		return keyctl_chown_key_r((key_serial_t) arg2,
+					  (const struct __kernel_uid_r __user *) arg3,
+					  (const struct __kernel_uid_r __user *) arg4);
+
 	case KEYCTL_SETPERM:
 		return keyctl_setperm_key((key_serial_t) arg2,
 					  (key_perm_t) arg3);
diff --git a/security/keys/persistent.c b/security/keys/persistent.c
index bdab995393..2c4b32cd2f 100644
--- a/security/keys/persistent.c
+++ b/security/keys/persistent.c
@@ -83,7 +83,8 @@ static long key_get_persistent(struct user_namespace *ns, kuid_t uid,
 	struct keyring_index_key index_key;
 	struct key *persistent;
 	key_ref_t reg_ref, persistent_ref;
-	char buf[32];
+	char buf[sizeof("_persistent.") + KID_STR_LEN];
+	char idbuf[KID_STR_LEN];
 	long ret;
 	bool created = false;
 
@@ -91,7 +92,13 @@ static long key_get_persistent(struct user_namespace *ns, kuid_t uid,
 	memset(&index_key, 0, sizeof(index_key));
 	index_key.type = &key_type_keyring;
 	index_key.description = buf;
-	index_key.desc_len = sprintf(buf, "_persistent.%u", from_kuid(ns, uid));
+	/* a UUID or GUID has no uid in @ns: name it by its text form */
+	if (uid_is_legacy(uid))
+		index_key.desc_len = sprintf(buf, "_persistent.%u",
+					     from_kuid(ns, uid));
+	else
+		index_key.desc_len = sprintf(buf, "_persistent.%s",
+					     kuid_str(uid, idbuf));
 	key_set_index_key(&index_key);
 
 	if (ns->persistent_keyring_register) {
diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index a63c46bb2d..6f275899f3 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -67,6 +67,25 @@ static struct key *get_user_register(struct user_namespace *user_ns)
 	return reg_keyring;
 }
 
+/*
+ * The name of a user's keyring or user session keyring: @prefix and the uid
+ * in @user_ns, or for a UUID or GUID uid its text form. Those have no uid
+ * in any namespace, and as -1 all of them would share the keyrings.
+ */
+#define USER_KEYRING_NAME_SIZE	(sizeof("_uid_ses.") + KID_STR_LEN)
+
+static int user_keyring_name(char *buf, const char *prefix,
+			     struct user_namespace *user_ns, kuid_t kuid)
+{
+	char idbuf[KID_STR_LEN];
+
+	if (!uid_is_legacy(kuid))
+		return snprintf(buf, USER_KEYRING_NAME_SIZE, "%s%s", prefix,
+				kuid_str(kuid, idbuf));
+	return snprintf(buf, USER_KEYRING_NAME_SIZE, "%s%u", prefix,
+			from_kuid(user_ns, kuid));
+}
+
 /*
  * Look up the user and user session keyrings for the current process's UID,
  * creating them if they don't exist.
@@ -79,13 +98,12 @@ int look_up_user_keyrings(struct key **_user_keyring,
 	struct key *reg_keyring, *uid_keyring, *session_keyring;
 	key_perm_t user_keyring_perm;
 	key_ref_t uid_keyring_r, session_keyring_r;
-	uid_t uid = from_kuid(user_ns, cred->user->uid);
-	char buf[20];
+	char buf[USER_KEYRING_NAME_SIZE];
 	int ret;
 
 	user_keyring_perm = (KEY_POS_ALL & ~KEY_POS_SETATTR) | KEY_USR_ALL;
 
-	kenter("%u", uid);
+	kenter("%u", from_kuid(user_ns, cred->user->uid));
 
 	reg_keyring = get_user_register(user_ns);
 	if (IS_ERR(reg_keyring))
@@ -98,7 +116,7 @@ int look_up_user_keyrings(struct key **_user_keyring,
 	 * already as it may have been pinned by a session, but the user_struct
 	 * pointing to it may have been destroyed by setuid.
 	 */
-	snprintf(buf, sizeof(buf), "_uid.%u", uid);
+	user_keyring_name(buf, "_uid.", user_ns, cred->user->uid);
 	uid_keyring_r = keyring_search(make_key_ref(reg_keyring, true),
 				       &key_type_keyring, buf, false);
 	kdebug("_uid %p", uid_keyring_r);
@@ -120,7 +138,7 @@ int look_up_user_keyrings(struct key **_user_keyring,
 	}
 
 	/* Get a default session keyring (which might also exist already) */
-	snprintf(buf, sizeof(buf), "_uid_ses.%u", uid);
+	user_keyring_name(buf, "_uid_ses.", user_ns, cred->user->uid);
 	session_keyring_r = keyring_search(make_key_ref(reg_keyring, true),
 					   &key_type_keyring, buf, false);
 	kdebug("_uid_ses %p", session_keyring_r);
@@ -186,7 +204,7 @@ struct key *get_user_session_keyring_rcu(const struct cred *cred)
 {
 	struct key *reg_keyring = READ_ONCE(cred->user_ns->user_keyring_register);
 	key_ref_t session_keyring_r;
-	char buf[20];
+	char buf[USER_KEYRING_NAME_SIZE];
 
 	struct keyring_search_context ctx = {
 		.index_key.type		= &key_type_keyring,
@@ -201,9 +219,9 @@ struct key *get_user_session_keyring_rcu(const struct cred *cred)
 	if (!reg_keyring)
 		return NULL;
 
-	ctx.index_key.desc_len = snprintf(buf, sizeof(buf), "_uid_ses.%u",
-					  from_kuid(cred->user_ns,
-						    cred->user->uid));
+	ctx.index_key.desc_len = user_keyring_name(buf, "_uid_ses.",
+						   cred->user_ns,
+						   cred->user->uid);
 
 	session_keyring_r = keyring_search_rcu(make_key_ref(reg_keyring, true),
 					       &ctx);
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index fa2bb9f2f5..48067bb73a 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -122,7 +122,7 @@ static int call_sbin_request_key(struct key *authkey, void *aux)
 	const struct cred *cred = current_cred();
 	key_serial_t prkey, sskey;
 	struct key *key = rka->target_key, *keyring, *session, *user_session;
-	char *argv[9], *envp[3], uid_str[12], gid_str[12];
+	char *argv[9], *envp[3], uid_str[KID_STR_LEN], gid_str[KID_STR_LEN];
 	char key_str[12], keyring_str[3][12];
 	char desc[20];
 	int ret, i;
@@ -152,8 +152,14 @@ static int call_sbin_request_key(struct key *authkey, void *aux)
 		goto error_link;
 
 	/* record the UID and GID */
-	sprintf(uid_str, "%d", from_kuid(&init_user_ns, cred->fsuid));
-	sprintf(gid_str, "%d", from_kgid(&init_user_ns, cred->fsgid));
+	if (uid_is_legacy(cred->fsuid))
+		sprintf(uid_str, "%d", from_kuid(&init_user_ns, cred->fsuid));
+	else
+		kuid_str(cred->fsuid, uid_str);
+	if (gid_is_legacy(cred->fsgid))
+		sprintf(gid_str, "%d", from_kgid(&init_user_ns, cred->fsgid));
+	else
+		kgid_str(cred->fsgid, gid_str);
 
 	/* we say which key is under construction */
 	sprintf(key_str, "%d", key->serial);
-- 
2.56.0

