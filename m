Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552589;
	b=R0/B6pHChTxdan1OX9Ktw3LDtBYUyOeh8p5muhoTH2nUxnryCFuUBlJf27snrtDXdhww
	 EHM2bhWHQXG8oT1WHSkGaSRi0UrX6RFmKs5YgiiNt82RbTlDJbN1EaZqU1ayZJOddyGBS
	 nnrenHbX/tT7eNUDqztc4QJszHCU+a/7Z5P71QBMlkEh8M3v5/xv0s4qeCZyEJHtgZ62i
	 GMg3j/9RtjoJOH9KpyIKmZ4rK4hoJ0hnW6c/eqRMegMkTi2ybXHBJvWWL7Qsk2ea1IDxd
	 WBtOA/E1irf+KPuVjrcob0c6XAdlbKzis21f+ZL9zSurX6sIQBBie1aQy7Y6fjT+kMg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552589;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date:X-Spam;
	bh=DN63fcAbZOr4DzpoKQai8EJ/O3JjRyHa8in8Eg0V/nQ=;
	b=2h6yM+r54tAkjckbPb+FexFSHB91sEirPc58gZ9uIPXcLMsYJOZ9TrX4GpGeAaEE3ll4
	 2+MtSYMy/2U/PIXJZmRb/fCSDb1uz45WakTPGoRyzqXjBFSJ5a4aOwOGYj/A247SmV3br
	 EOQ7yri/EZGl8kce1GxArBtjhFO+4Zv0kv9BkLf0rIhbKeVqDHBUc33Dqj/BwwZTSFKAi
	 +WKFM6ZnM3SUBS9zEKAoXhnd/Y61oGAHv++VXW6c+cUGyIJe2fM2EUt5HU9gwyRhM8hN0
	 YD1uUy0IVEIYxoiFg4Am2CwGDcTXPea5aNFd7yk7LZAPC0VXRG2U9MCh4u3934sdsQw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=C+Naquet;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C7F3606D3D0;
	Wed, 21 Oct 2026 03:16:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2C7F3606D3D0
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=C+Naquet
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552586; bh=0apaDegVOVFS5TwK2iAUEkqmdtB5hM5qhyDUWswSDSE=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=C+Naquet2wv50WDK1K3yEmAkRfq9pweBCGw49dajG8OaZ3t/XHVKGbVLaLE0I/Mad
	 X9vhBVpNcQR2D7y1FAZx9bAxy1lSybABMr1AQ5BdKdKsyYou5cOZ41BbyBNjD8RaKp
	 CwCBT0hChqRu9zx1uADZv1BrWIOz+4uzJd2IEzUyXGAO9dNRWbYgkXLE5PbFSFKDTE
	 Wo33WKvsvtGFky606hCV3PVERALNrbiyFL6m7cBg2Q2HCD14kscOzijWjG9Ouz6Abp
	 ZY2xPXxrY3JgEtZuiVH2lYhUcuHHXOhWEbX7Bxxfj9L2pz3YyG6tNBziSgMKr1CKVi
	 KZfvejnwEzGXg==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id B91E28A090D;
	Wed, 21 Oct 2026 05:16:25 +0200 (CEST)
Message-ID: <86c66380f2654c560e747b9075edbddd610975ca.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 19/41] cred: add the *_r variants of the get/set*id()
 system calls
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
Date: Wed, 21 Oct 2026 05:15:39 +0200
X-Spam: Yes
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Add getuid_r(), geteuid_r(), getgid_r(), getegid_r(), setuid_r(),
setgid_r(), setreuid_r(), setregid_r(), setresuid_r(), getresuid_r(),
setresgid_r(), getresgid_r(), setfsuid_r() and setfsgid_r(). They work
like the classic calls but take and return pointers to
__kernel_uid_r_t, so a process can be a UUID or GUID user and group.
The classic calls see such ids as the overflow id, like the 16 bit
calls see ids above 65535.

To share the logic, the classic implementations are split into a part
converting the arguments and a do_*() part working on kuid_t/kgid_t,
in which an invalid id means "unchanged" -- what -1 converts to. A
NULL pointer, UID_R_NONE or a classic -1 mean "unchanged" in the new
calls as well.

UUIDs and GUIDs have no mapping outside the initial user namespace, so
only CAP_SETUID/CAP_SETGID there can switch to one.

setfsuid_r() and setfsgid_r() differ from the classic calls in one
respect: they return -EPERM when the change is not allowed instead of
failing silently, and hand the old id back through a second argument.

The system call numbers are assigned in a later patch.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 include/linux/syscalls.h |  27 +++
 kernel/sys.c             | 472 +++++++++++++++++++++++++++++----------
 kernel/sys_ni.c          |  10 +
 3 files changed, 385 insertions(+), 124 deletions(-)

diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 8413b624ad..09fa1093a9 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -17,6 +17,7 @@ struct iocb;
 struct io_event;
 struct iovec;
 struct __kernel_old_itimerval;
+struct __kernel_uid_r;
 struct kexec_segment;
 struct linux_dirent;
 struct linux_dirent64;
@@ -967,6 +968,32 @@ asmlinkage long sys_statx(int dfd, const char __user *path, unsigned flags,
 asmlinkage long sys_rseq(struct rseq __user *rseq, uint32_t rseq_len,
 			 int flags, uint32_t sig);
 asmlinkage long sys_rseq_slice_yield(void);
+asmlinkage long sys_getuid_r(struct __kernel_uid_r __user *uid);
+asmlinkage long sys_geteuid_r(struct __kernel_uid_r __user *uid);
+asmlinkage long sys_getgid_r(struct __kernel_uid_r __user *gid);
+asmlinkage long sys_getegid_r(struct __kernel_uid_r __user *gid);
+asmlinkage long sys_setuid_r(const struct __kernel_uid_r __user *uid);
+asmlinkage long sys_setgid_r(const struct __kernel_uid_r __user *gid);
+asmlinkage long sys_setreuid_r(const struct __kernel_uid_r __user *ruid,
+			       const struct __kernel_uid_r __user *euid);
+asmlinkage long sys_setregid_r(const struct __kernel_uid_r __user *rgid,
+			       const struct __kernel_uid_r __user *egid);
+asmlinkage long sys_setresuid_r(const struct __kernel_uid_r __user *ruid,
+				const struct __kernel_uid_r __user *euid,
+				const struct __kernel_uid_r __user *suid);
+asmlinkage long sys_getresuid_r(struct __kernel_uid_r __user *ruid,
+				struct __kernel_uid_r __user *euid,
+				struct __kernel_uid_r __user *suid);
+asmlinkage long sys_setresgid_r(const struct __kernel_uid_r __user *rgid,
+				const struct __kernel_uid_r __user *egid,
+				const struct __kernel_uid_r __user *sgid);
+asmlinkage long sys_getresgid_r(struct __kernel_uid_r __user *rgid,
+				struct __kernel_uid_r __user *egid,
+				struct __kernel_uid_r __user *sgid);
+asmlinkage long sys_setfsuid_r(const struct __kernel_uid_r __user *uid,
+			       struct __kernel_uid_r __user *old_uid);
+asmlinkage long sys_setfsgid_r(const struct __kernel_uid_r __user *gid,
+			       struct __kernel_uid_r __user *old_gid);
 asmlinkage long sys_open_tree(int dfd, const char __user *path, unsigned flags);
 asmlinkage long sys_open_tree_attr(int dfd, const char __user *path,
 				   unsigned flags,
diff --git a/kernel/sys.c b/kernel/sys.c
index 35b538ba84..fad5573234 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -410,21 +410,12 @@ SYSCALL_DEFINE2(getpriority, int, which, int, who)
  *      operations (as far as semantic preservation is concerned).
  */
 #ifdef CONFIG_MULTIUSER
-long __sys_setregid(gid_t rgid, gid_t egid)
+/* Invalid ids (INVALID_GID) stand for "unchanged" */
+static long do_setregid(kgid_t krgid, kgid_t kegid)
 {
-	struct user_namespace *ns = current_user_ns();
 	const struct cred *old;
 	struct cred *new;
 	int retval;
-	kgid_t krgid, kegid;
-
-	krgid = make_kgid(ns, rgid);
-	kegid = make_kgid(ns, egid);
-
-	if ((rgid != (gid_t) -1) && !gid_valid(krgid))
-		return -EINVAL;
-	if ((egid != (gid_t) -1) && !gid_valid(kegid))
-		return -EINVAL;
 
 	new = prepare_creds();
 	if (!new)
@@ -432,7 +423,7 @@ long __sys_setregid(gid_t rgid, gid_t egid)
 	old = current_cred();
 
 	retval = -EPERM;
-	if (rgid != (gid_t) -1) {
+	if (gid_valid(krgid)) {
 		if (gid_eq(old->gid, krgid) ||
 		    gid_eq(old->egid, krgid) ||
 		    ns_capable_setid(old->user_ns, CAP_SETGID))
@@ -440,7 +431,7 @@ long __sys_setregid(gid_t rgid, gid_t egid)
 		else
 			goto error;
 	}
-	if (egid != (gid_t) -1) {
+	if (gid_valid(kegid)) {
 		if (gid_eq(old->gid, kegid) ||
 		    gid_eq(old->egid, kegid) ||
 		    gid_eq(old->sgid, kegid) ||
@@ -450,8 +441,8 @@ long __sys_setregid(gid_t rgid, gid_t egid)
 			goto error;
 	}
 
-	if (rgid != (gid_t) -1 ||
-	    (egid != (gid_t) -1 && !gid_eq(kegid, old->gid)))
+	if (gid_valid(krgid) ||
+	    (gid_valid(kegid) && !gid_eq(kegid, old->gid)))
 		new->sgid = new->egid;
 	new->fsgid = new->egid;
 
@@ -466,6 +457,22 @@ long __sys_setregid(gid_t rgid, gid_t egid)
 	return retval;
 }
 
+long __sys_setregid(gid_t rgid, gid_t egid)
+{
+	struct user_namespace *ns = current_user_ns();
+	kgid_t krgid, kegid;
+
+	krgid = make_kgid(ns, rgid);
+	kegid = make_kgid(ns, egid);
+
+	if ((rgid != (gid_t) -1) && !gid_valid(krgid))
+		return -EINVAL;
+	if ((egid != (gid_t) -1) && !gid_valid(kegid))
+		return -EINVAL;
+
+	return do_setregid(krgid, kegid);
+}
+
 SYSCALL_DEFINE2(setregid, gid_t, rgid, gid_t, egid)
 {
 	return __sys_setregid(rgid, egid);
@@ -476,15 +483,12 @@ SYSCALL_DEFINE2(setregid, gid_t, rgid, gid_t, egid)
  *
  * SMP: Same implicit races as above.
  */
-long __sys_setgid(gid_t gid)
+static long do_setgid(kgid_t kgid)
 {
-	struct user_namespace *ns = current_user_ns();
 	const struct cred *old;
 	struct cred *new;
 	int retval;
-	kgid_t kgid;
 
-	kgid = make_kgid(ns, gid);
 	if (!gid_valid(kgid))
 		return -EINVAL;
 
@@ -512,6 +516,11 @@ long __sys_setgid(gid_t gid)
 	return retval;
 }
 
+long __sys_setgid(gid_t gid)
+{
+	return do_setgid(make_kgid(current_user_ns(), gid));
+}
+
 SYSCALL_DEFINE1(setgid, gid_t, gid)
 {
 	return __sys_setgid(gid);
@@ -567,21 +576,12 @@ static void flag_nproc_exceeded(struct cred *new)
  * 100% compatible with BSD.  A program which uses just setuid() will be
  * 100% compatible with POSIX with saved IDs.
  */
-long __sys_setreuid(uid_t ruid, uid_t euid)
+/* Invalid ids (INVALID_UID) stand for "unchanged" */
+static long do_setreuid(kuid_t kruid, kuid_t keuid)
 {
-	struct user_namespace *ns = current_user_ns();
 	const struct cred *old;
 	struct cred *new;
 	int retval;
-	kuid_t kruid, keuid;
-
-	kruid = make_kuid(ns, ruid);
-	keuid = make_kuid(ns, euid);
-
-	if ((ruid != (uid_t) -1) && !uid_valid(kruid))
-		return -EINVAL;
-	if ((euid != (uid_t) -1) && !uid_valid(keuid))
-		return -EINVAL;
 
 	new = prepare_creds();
 	if (!new)
@@ -589,7 +589,7 @@ long __sys_setreuid(uid_t ruid, uid_t euid)
 	old = current_cred();
 
 	retval = -EPERM;
-	if (ruid != (uid_t) -1) {
+	if (uid_valid(kruid)) {
 		new->uid = kruid;
 		if (!uid_eq(old->uid, kruid) &&
 		    !uid_eq(old->euid, kruid) &&
@@ -597,7 +597,7 @@ long __sys_setreuid(uid_t ruid, uid_t euid)
 			goto error;
 	}
 
-	if (euid != (uid_t) -1) {
+	if (uid_valid(keuid)) {
 		new->euid = keuid;
 		if (!uid_eq(old->uid, keuid) &&
 		    !uid_eq(old->euid, keuid) &&
@@ -611,8 +611,8 @@ long __sys_setreuid(uid_t ruid, uid_t euid)
 		if (retval < 0)
 			goto error;
 	}
-	if (ruid != (uid_t) -1 ||
-	    (euid != (uid_t) -1 && !uid_eq(keuid, old->uid)))
+	if (uid_valid(kruid) ||
+	    (uid_valid(keuid) && !uid_eq(keuid, old->uid)))
 		new->suid = new->euid;
 	new->fsuid = new->euid;
 
@@ -632,6 +632,22 @@ long __sys_setreuid(uid_t ruid, uid_t euid)
 	return retval;
 }
 
+long __sys_setreuid(uid_t ruid, uid_t euid)
+{
+	struct user_namespace *ns = current_user_ns();
+	kuid_t kruid, keuid;
+
+	kruid = make_kuid(ns, ruid);
+	keuid = make_kuid(ns, euid);
+
+	if ((ruid != (uid_t) -1) && !uid_valid(kruid))
+		return -EINVAL;
+	if ((euid != (uid_t) -1) && !uid_valid(keuid))
+		return -EINVAL;
+
+	return do_setreuid(kruid, keuid);
+}
+
 SYSCALL_DEFINE2(setreuid, uid_t, ruid, uid_t, euid)
 {
 	return __sys_setreuid(ruid, euid);
@@ -648,15 +664,12 @@ SYSCALL_DEFINE2(setreuid, uid_t, ruid, uid_t, euid)
  * will allow a root program to temporarily drop privileges and be able to
  * regain them by swapping the real and effective uid.
  */
-long __sys_setuid(uid_t uid)
+static long do_setuid(kuid_t kuid)
 {
-	struct user_namespace *ns = current_user_ns();
 	const struct cred *old;
 	struct cred *new;
 	int retval;
-	kuid_t kuid;
 
-	kuid = make_kuid(ns, uid);
 	if (!uid_valid(kuid))
 		return -EINVAL;
 
@@ -695,6 +708,11 @@ long __sys_setuid(uid_t uid)
 	return retval;
 }
 
+long __sys_setuid(uid_t uid)
+{
+	return do_setuid(make_kuid(current_user_ns(), uid));
+}
+
 SYSCALL_DEFINE1(setuid, uid_t, uid)
 {
 	return __sys_setuid(uid);
@@ -705,42 +723,28 @@ SYSCALL_DEFINE1(setuid, uid_t, uid)
  * This function implements a generic ability to update ruid, euid,
  * and suid.  This allows you to implement the 4.4 compatible seteuid().
  */
-long __sys_setresuid(uid_t ruid, uid_t euid, uid_t suid)
+/* Invalid ids (INVALID_UID) stand for "unchanged" */
+static long do_setresuid(kuid_t kruid, kuid_t keuid, kuid_t ksuid)
 {
-	struct user_namespace *ns = current_user_ns();
 	const struct cred *old;
 	struct cred *new;
 	int retval;
-	kuid_t kruid, keuid, ksuid;
 	bool ruid_new, euid_new, suid_new;
 
-	kruid = make_kuid(ns, ruid);
-	keuid = make_kuid(ns, euid);
-	ksuid = make_kuid(ns, suid);
-
-	if ((ruid != (uid_t) -1) && !uid_valid(kruid))
-		return -EINVAL;
-
-	if ((euid != (uid_t) -1) && !uid_valid(keuid))
-		return -EINVAL;
-
-	if ((suid != (uid_t) -1) && !uid_valid(ksuid))
-		return -EINVAL;
-
 	old = current_cred();
 
 	/* check for no-op */
-	if ((ruid == (uid_t) -1 || uid_eq(kruid, old->uid)) &&
-	    (euid == (uid_t) -1 || (uid_eq(keuid, old->euid) &&
-				    uid_eq(keuid, old->fsuid))) &&
-	    (suid == (uid_t) -1 || uid_eq(ksuid, old->suid)))
+	if ((!uid_valid(kruid) || uid_eq(kruid, old->uid)) &&
+	    (!uid_valid(keuid) || (uid_eq(keuid, old->euid) &&
+				   uid_eq(keuid, old->fsuid))) &&
+	    (!uid_valid(ksuid) || uid_eq(ksuid, old->suid)))
 		return 0;
 
-	ruid_new = ruid != (uid_t) -1        && !uid_eq(kruid, old->uid) &&
+	ruid_new = uid_valid(kruid)          && !uid_eq(kruid, old->uid) &&
 		   !uid_eq(kruid, old->euid) && !uid_eq(kruid, old->suid);
-	euid_new = euid != (uid_t) -1        && !uid_eq(keuid, old->uid) &&
+	euid_new = uid_valid(keuid)          && !uid_eq(keuid, old->uid) &&
 		   !uid_eq(keuid, old->euid) && !uid_eq(keuid, old->suid);
-	suid_new = suid != (uid_t) -1        && !uid_eq(ksuid, old->uid) &&
+	suid_new = uid_valid(ksuid)          && !uid_eq(ksuid, old->uid) &&
 		   !uid_eq(ksuid, old->euid) && !uid_eq(ksuid, old->suid);
 	if ((ruid_new || euid_new || suid_new) &&
 	    !ns_capable_setid(old->user_ns, CAP_SETUID))
@@ -750,7 +754,7 @@ long __sys_setresuid(uid_t ruid, uid_t euid, uid_t suid)
 	if (!new)
 		return -ENOMEM;
 
-	if (ruid != (uid_t) -1) {
+	if (uid_valid(kruid)) {
 		new->uid = kruid;
 		if (!uid_eq(kruid, old->uid)) {
 			retval = set_user(new);
@@ -758,9 +762,9 @@ long __sys_setresuid(uid_t ruid, uid_t euid, uid_t suid)
 				goto error;
 		}
 	}
-	if (euid != (uid_t) -1)
+	if (uid_valid(keuid))
 		new->euid = keuid;
-	if (suid != (uid_t) -1)
+	if (uid_valid(ksuid))
 		new->suid = ksuid;
 	new->fsuid = new->euid;
 
@@ -780,6 +784,27 @@ long __sys_setresuid(uid_t ruid, uid_t euid, uid_t suid)
 	return retval;
 }
 
+long __sys_setresuid(uid_t ruid, uid_t euid, uid_t suid)
+{
+	struct user_namespace *ns = current_user_ns();
+	kuid_t kruid, keuid, ksuid;
+
+	kruid = make_kuid(ns, ruid);
+	keuid = make_kuid(ns, euid);
+	ksuid = make_kuid(ns, suid);
+
+	if ((ruid != (uid_t) -1) && !uid_valid(kruid))
+		return -EINVAL;
+
+	if ((euid != (uid_t) -1) && !uid_valid(keuid))
+		return -EINVAL;
+
+	if ((suid != (uid_t) -1) && !uid_valid(ksuid))
+		return -EINVAL;
+
+	return do_setresuid(kruid, keuid, ksuid);
+}
+
 SYSCALL_DEFINE3(setresuid, uid_t, ruid, uid_t, euid, uid_t, suid)
 {
 	return __sys_setresuid(ruid, euid, suid);
@@ -807,40 +832,28 @@ SYSCALL_DEFINE3(getresuid, uid_t __user *, ruidp, uid_t __user *, euidp, uid_t _
 /*
  * Same as above, but for rgid, egid, sgid.
  */
-long __sys_setresgid(gid_t rgid, gid_t egid, gid_t sgid)
+/* Invalid ids (INVALID_GID) stand for "unchanged" */
+static long do_setresgid(kgid_t krgid, kgid_t kegid, kgid_t ksgid)
 {
-	struct user_namespace *ns = current_user_ns();
 	const struct cred *old;
 	struct cred *new;
 	int retval;
-	kgid_t krgid, kegid, ksgid;
 	bool rgid_new, egid_new, sgid_new;
 
-	krgid = make_kgid(ns, rgid);
-	kegid = make_kgid(ns, egid);
-	ksgid = make_kgid(ns, sgid);
-
-	if ((rgid != (gid_t) -1) && !gid_valid(krgid))
-		return -EINVAL;
-	if ((egid != (gid_t) -1) && !gid_valid(kegid))
-		return -EINVAL;
-	if ((sgid != (gid_t) -1) && !gid_valid(ksgid))
-		return -EINVAL;
-
 	old = current_cred();
 
 	/* check for no-op */
-	if ((rgid == (gid_t) -1 || gid_eq(krgid, old->gid)) &&
-	    (egid == (gid_t) -1 || (gid_eq(kegid, old->egid) &&
-				    gid_eq(kegid, old->fsgid))) &&
-	    (sgid == (gid_t) -1 || gid_eq(ksgid, old->sgid)))
+	if ((!gid_valid(krgid) || gid_eq(krgid, old->gid)) &&
+	    (!gid_valid(kegid) || (gid_eq(kegid, old->egid) &&
+				   gid_eq(kegid, old->fsgid))) &&
+	    (!gid_valid(ksgid) || gid_eq(ksgid, old->sgid)))
 		return 0;
 
-	rgid_new = rgid != (gid_t) -1        && !gid_eq(krgid, old->gid) &&
+	rgid_new = gid_valid(krgid)          && !gid_eq(krgid, old->gid) &&
 		   !gid_eq(krgid, old->egid) && !gid_eq(krgid, old->sgid);
-	egid_new = egid != (gid_t) -1        && !gid_eq(kegid, old->gid) &&
+	egid_new = gid_valid(kegid)          && !gid_eq(kegid, old->gid) &&
 		   !gid_eq(kegid, old->egid) && !gid_eq(kegid, old->sgid);
-	sgid_new = sgid != (gid_t) -1        && !gid_eq(ksgid, old->gid) &&
+	sgid_new = gid_valid(ksgid)          && !gid_eq(ksgid, old->gid) &&
 		   !gid_eq(ksgid, old->egid) && !gid_eq(ksgid, old->sgid);
 	if ((rgid_new || egid_new || sgid_new) &&
 	    !ns_capable_setid(old->user_ns, CAP_SETGID))
@@ -850,11 +863,11 @@ long __sys_setresgid(gid_t rgid, gid_t egid, gid_t sgid)
 	if (!new)
 		return -ENOMEM;
 
-	if (rgid != (gid_t) -1)
+	if (gid_valid(krgid))
 		new->gid = krgid;
-	if (egid != (gid_t) -1)
+	if (gid_valid(kegid))
 		new->egid = kegid;
-	if (sgid != (gid_t) -1)
+	if (gid_valid(ksgid))
 		new->sgid = ksgid;
 	new->fsgid = new->egid;
 
@@ -869,6 +882,25 @@ long __sys_setresgid(gid_t rgid, gid_t egid, gid_t sgid)
 	return retval;
 }
 
+long __sys_setresgid(gid_t rgid, gid_t egid, gid_t sgid)
+{
+	struct user_namespace *ns = current_user_ns();
+	kgid_t krgid, kegid, ksgid;
+
+	krgid = make_kgid(ns, rgid);
+	kegid = make_kgid(ns, egid);
+	ksgid = make_kgid(ns, sgid);
+
+	if ((rgid != (gid_t) -1) && !gid_valid(krgid))
+		return -EINVAL;
+	if ((egid != (gid_t) -1) && !gid_valid(kegid))
+		return -EINVAL;
+	if ((sgid != (gid_t) -1) && !gid_valid(ksgid))
+		return -EINVAL;
+
+	return do_setresgid(krgid, kegid, ksgid);
+}
+
 SYSCALL_DEFINE3(setresgid, gid_t, rgid, gid_t, egid, gid_t, sgid)
 {
 	return __sys_setresgid(rgid, egid, sgid);
@@ -901,40 +933,44 @@ SYSCALL_DEFINE3(getresgid, gid_t __user *, rgidp, gid_t __user *, egidp, gid_t _
  * whatever uid it wants to). It normally shadows "euid", except when
  * explicitly set by setfsuid() or for access..
  */
-long __sys_setfsuid(uid_t uid)
+/*
+ * Sets the fsuid to @kuid, unless it is invalid; 0 or -EPERM. The fsuid
+ * before the call goes to @old.
+ */
+static long do_setfsuid(kuid_t kuid, kuid_t *old_fsuid)
 {
 	const struct cred *old;
 	struct cred *new;
-	uid_t old_fsuid;
-	kuid_t kuid;
 
 	old = current_cred();
-	old_fsuid = from_kuid_munged(old->user_ns, old->fsuid);
+	*old_fsuid = old->fsuid;
 
-	kuid = make_kuid(old->user_ns, uid);
-	if (!uid_valid(kuid))
-		return old_fsuid;
+	if (!uid_valid(kuid) || uid_eq(kuid, old->fsuid))
+		return 0;
 
 	new = prepare_creds();
 	if (!new)
-		return old_fsuid;
+		return -ENOMEM;
 
 	if (uid_eq(kuid, old->uid)  || uid_eq(kuid, old->euid)  ||
-	    uid_eq(kuid, old->suid) || uid_eq(kuid, old->fsuid) ||
+	    uid_eq(kuid, old->suid) ||
 	    ns_capable_setid(old->user_ns, CAP_SETUID)) {
-		if (!uid_eq(kuid, old->fsuid)) {
-			new->fsuid = kuid;
-			if (security_task_fix_setuid(new, old, LSM_SETID_FS) == 0)
-				goto change_okay;
-		}
+		new->fsuid = kuid;
+		if (security_task_fix_setuid(new, old, LSM_SETID_FS) == 0)
+			return commit_creds(new);
 	}
 
 	abort_creds(new);
-	return old_fsuid;
+	return -EPERM;
+}
+
+long __sys_setfsuid(uid_t uid)
+{
+	struct user_namespace *ns = current_user_ns();
+	kuid_t old_fsuid;
 
-change_okay:
-	commit_creds(new);
-	return old_fsuid;
+	do_setfsuid(make_kuid(ns, uid), &old_fsuid);
+	return from_kuid_munged(ns, old_fsuid);
 }
 
 SYSCALL_DEFINE1(setfsuid, uid_t, uid)
@@ -945,46 +981,214 @@ SYSCALL_DEFINE1(setfsuid, uid_t, uid)
 /*
  * Samma på svenska..
  */
-long __sys_setfsgid(gid_t gid)
+/*
+ * Sets the fsgid to @kgid, unless it is invalid; 0 or -EPERM. The fsgid
+ * before the call goes to @old.
+ */
+static long do_setfsgid(kgid_t kgid, kgid_t *old_fsgid)
 {
 	const struct cred *old;
 	struct cred *new;
-	gid_t old_fsgid;
-	kgid_t kgid;
 
 	old = current_cred();
-	old_fsgid = from_kgid_munged(old->user_ns, old->fsgid);
+	*old_fsgid = old->fsgid;
 
-	kgid = make_kgid(old->user_ns, gid);
-	if (!gid_valid(kgid))
-		return old_fsgid;
+	if (!gid_valid(kgid) || gid_eq(kgid, old->fsgid))
+		return 0;
 
 	new = prepare_creds();
 	if (!new)
-		return old_fsgid;
+		return -ENOMEM;
 
 	if (gid_eq(kgid, old->gid)  || gid_eq(kgid, old->egid)  ||
-	    gid_eq(kgid, old->sgid) || gid_eq(kgid, old->fsgid) ||
+	    gid_eq(kgid, old->sgid) ||
 	    ns_capable_setid(old->user_ns, CAP_SETGID)) {
-		if (!gid_eq(kgid, old->fsgid)) {
-			new->fsgid = kgid;
-			if (security_task_fix_setgid(new,old,LSM_SETID_FS) == 0)
-				goto change_okay;
-		}
+		new->fsgid = kgid;
+		if (security_task_fix_setgid(new, old, LSM_SETID_FS) == 0)
+			return commit_creds(new);
 	}
 
 	abort_creds(new);
-	return old_fsgid;
+	return -EPERM;
+}
+
+long __sys_setfsgid(gid_t gid)
+{
+	struct user_namespace *ns = current_user_ns();
+	kgid_t old_fsgid;
 
-change_okay:
-	commit_creds(new);
-	return old_fsgid;
+	do_setfsgid(make_kgid(ns, gid), &old_fsgid);
+	return from_kgid_munged(ns, old_fsgid);
 }
 
 SYSCALL_DEFINE1(setfsgid, gid_t, gid)
 {
 	return __sys_setfsgid(gid);
 }
+
+/*
+ * The *_r variants take and return __kernel_uid_r_t, which can also be a
+ * UUID or a GUID. A NULL pointer, UID_R_NONE or a classic -1 leave an id
+ * unchanged, like -1 does for the classic calls.
+ */
+SYSCALL_DEFINE1(setuid_r, const struct __kernel_uid_r __user *, uid)
+{
+	kuid_t kuid;
+	int err;
+
+	err = get_kuid_r(current_user_ns(), uid, &kuid);
+	if (err)
+		return err;
+	return do_setuid(kuid);
+}
+
+SYSCALL_DEFINE1(setgid_r, const struct __kernel_uid_r __user *, gid)
+{
+	kgid_t kgid;
+	int err;
+
+	err = get_kgid_r(current_user_ns(), gid, &kgid);
+	if (err)
+		return err;
+	return do_setgid(kgid);
+}
+
+SYSCALL_DEFINE2(setreuid_r, const struct __kernel_uid_r __user *, ruid,
+		const struct __kernel_uid_r __user *, euid)
+{
+	struct user_namespace *ns = current_user_ns();
+	kuid_t kruid, keuid;
+	int err;
+
+	err = get_kuid_r(ns, ruid, &kruid);
+	if (!err)
+		err = get_kuid_r(ns, euid, &keuid);
+	if (err)
+		return err;
+	return do_setreuid(kruid, keuid);
+}
+
+SYSCALL_DEFINE2(setregid_r, const struct __kernel_uid_r __user *, rgid,
+		const struct __kernel_uid_r __user *, egid)
+{
+	struct user_namespace *ns = current_user_ns();
+	kgid_t krgid, kegid;
+	int err;
+
+	err = get_kgid_r(ns, rgid, &krgid);
+	if (!err)
+		err = get_kgid_r(ns, egid, &kegid);
+	if (err)
+		return err;
+	return do_setregid(krgid, kegid);
+}
+
+SYSCALL_DEFINE3(setresuid_r, const struct __kernel_uid_r __user *, ruid,
+		const struct __kernel_uid_r __user *, euid,
+		const struct __kernel_uid_r __user *, suid)
+{
+	struct user_namespace *ns = current_user_ns();
+	kuid_t kruid, keuid, ksuid;
+	int err;
+
+	err = get_kuid_r(ns, ruid, &kruid);
+	if (!err)
+		err = get_kuid_r(ns, euid, &keuid);
+	if (!err)
+		err = get_kuid_r(ns, suid, &ksuid);
+	if (err)
+		return err;
+	return do_setresuid(kruid, keuid, ksuid);
+}
+
+SYSCALL_DEFINE3(setresgid_r, const struct __kernel_uid_r __user *, rgid,
+		const struct __kernel_uid_r __user *, egid,
+		const struct __kernel_uid_r __user *, sgid)
+{
+	struct user_namespace *ns = current_user_ns();
+	kgid_t krgid, kegid, ksgid;
+	int err;
+
+	err = get_kgid_r(ns, rgid, &krgid);
+	if (!err)
+		err = get_kgid_r(ns, egid, &kegid);
+	if (!err)
+		err = get_kgid_r(ns, sgid, &ksgid);
+	if (err)
+		return err;
+	return do_setresgid(krgid, kegid, ksgid);
+}
+
+/* NULL pointers are skipped */
+SYSCALL_DEFINE3(getresuid_r, struct __kernel_uid_r __user *, ruid,
+		struct __kernel_uid_r __user *, euid,
+		struct __kernel_uid_r __user *, suid)
+{
+	const struct cred *cred = current_cred();
+	int err = 0;
+
+	if (ruid)
+		err = put_kuid_r(cred->user_ns, cred->uid, ruid);
+	if (!err && euid)
+		err = put_kuid_r(cred->user_ns, cred->euid, euid);
+	if (!err && suid)
+		err = put_kuid_r(cred->user_ns, cred->suid, suid);
+	return err;
+}
+
+SYSCALL_DEFINE3(getresgid_r, struct __kernel_uid_r __user *, rgid,
+		struct __kernel_uid_r __user *, egid,
+		struct __kernel_uid_r __user *, sgid)
+{
+	const struct cred *cred = current_cred();
+	int err = 0;
+
+	if (rgid)
+		err = put_kgid_r(cred->user_ns, cred->gid, rgid);
+	if (!err && egid)
+		err = put_kgid_r(cred->user_ns, cred->egid, egid);
+	if (!err && sgid)
+		err = put_kgid_r(cred->user_ns, cred->sgid, sgid);
+	return err;
+}
+
+/*
+ * Unlike setfsuid(), which returns the old fsuid whatever happens,
+ * setfsuid_r() reports failure: 0, or -EPERM if the caller may not use
+ * @uid. The fsuid before the call goes to @old_uid unless it is NULL; a
+ * NULL @uid only queries it.
+ */
+SYSCALL_DEFINE2(setfsuid_r, const struct __kernel_uid_r __user *, uid,
+		struct __kernel_uid_r __user *, old_uid)
+{
+	struct user_namespace *ns = current_user_ns();
+	kuid_t kuid, old_fsuid;
+	int err;
+
+	err = get_kuid_r(ns, uid, &kuid);
+	if (err)
+		return err;
+	err = do_setfsuid(kuid, &old_fsuid);
+	if (!err && old_uid)
+		err = put_kuid_r(ns, old_fsuid, old_uid);
+	return err;
+}
+
+SYSCALL_DEFINE2(setfsgid_r, const struct __kernel_uid_r __user *, gid,
+		struct __kernel_uid_r __user *, old_gid)
+{
+	struct user_namespace *ns = current_user_ns();
+	kgid_t kgid, old_fsgid;
+	int err;
+
+	err = get_kgid_r(ns, gid, &kgid);
+	if (err)
+		return err;
+	err = do_setfsgid(kgid, &old_fsgid);
+	if (!err && old_gid)
+		err = put_kgid_r(ns, old_fsgid, old_gid);
+	return err;
+}
 #endif /* CONFIG_MULTIUSER */
 
 /**
@@ -1048,6 +1252,26 @@ SYSCALL_DEFINE0(getegid)
 	return from_kgid_munged(current_user_ns(), current_egid());
 }
 
+SYSCALL_DEFINE1(getuid_r, struct __kernel_uid_r __user *, uid)
+{
+	return put_kuid_r(current_user_ns(), current_uid(), uid);
+}
+
+SYSCALL_DEFINE1(geteuid_r, struct __kernel_uid_r __user *, uid)
+{
+	return put_kuid_r(current_user_ns(), current_euid(), uid);
+}
+
+SYSCALL_DEFINE1(getgid_r, struct __kernel_uid_r __user *, gid)
+{
+	return put_kgid_r(current_user_ns(), current_gid(), gid);
+}
+
+SYSCALL_DEFINE1(getegid_r, struct __kernel_uid_r __user *, gid)
+{
+	return put_kgid_r(current_user_ns(), current_egid(), gid);
+}
+
 static void do_sys_times(struct tms *tms)
 {
 	u64 tgutime, tgstime, cutime, cstime;
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index c8be0abaa4..01f14d7a4d 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -103,6 +103,16 @@ COND_SYSCALL(setfsuid);
 COND_SYSCALL(setfsgid);
 COND_SYSCALL(setgroups);
 COND_SYSCALL(getgroups);
+COND_SYSCALL(setregid_r);
+COND_SYSCALL(setgid_r);
+COND_SYSCALL(setreuid_r);
+COND_SYSCALL(setuid_r);
+COND_SYSCALL(setresuid_r);
+COND_SYSCALL(getresuid_r);
+COND_SYSCALL(setresgid_r);
+COND_SYSCALL(getresgid_r);
+COND_SYSCALL(setfsuid_r);
+COND_SYSCALL(setfsgid_r);
 COND_SYSCALL(mq_open);
 COND_SYSCALL_COMPAT(mq_open);
 COND_SYSCALL(mq_unlink);
-- 
2.56.0

