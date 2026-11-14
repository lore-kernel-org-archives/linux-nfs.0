Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.216.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794665613;
	b=AQiV4vTrvImxJIqFmmLrv269684BvrsMGXKpZP04Q5jeVumMW8hs1t/XOUXPC6rverPa
	 KlR+0Mk7MqF0DLEMYzRnaMdQgj50ZlyPEVNwDo+7XVFNGoWutEEBG3nRKYGp+98E4MbkL
	 xI1VyKGwC2D9rcXn/IvQVLKs/7jbhvivxLmsZXnl9HMKV4U3b4/lnCHHRAX998OELptyg
	 2kn/lYmpC2U4acGv0D54JLpbgFvNJ2h5SIW31ksHPvw69005U9aw1VkHRLEkYWXiikuiL
	 2xXw3HPVSxnk3Y1ThVLYOF96OQ13/fjTAGz6PZ3+mTo/2nhOchGq0J0w7mCjUK5IM0A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794665613;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=uxgyh6i/oWZUfGjNhOfAz/zPxc/xSTYW7KM0UR47m2k=;
	b=MSn5mkT34FgtXoK8SROlcbG96WFVBzoFY8IP3oqk4qP/+8niDDeS3i5pVNu6Em0zYrKU
	 IyIsgCezizkNhD7JaysDkMBE96gjXZ/Ck8Y0G+KFYCFUmmunn1LWykAc0RRYPpsRVA118
	 IbtmWMTGrCjOZQZ+u8rbWm0dQhNQFNB/Rw0ZgxBCPq+vUyGh8yCeyJoWzDGKJG55PmpyE
	 ZvqPosCP7lGxFA3fCcgEvNxTuuwHQItiXsqDMaBmBkgs8ePirqRZEQOBcPbgG+ihuXR7m
	 TmhvP6bbMcdmszwD2LC3dueVrPxZEdHEVenW5MlTUxbm27YrA+ugwGQ2f4y8PiZqL3w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=yMeAkMAr;
	arc=none smtp.remote-ip=209.85.216.47
Received: from mail-pj1-f47.google.com (mail-pj1-f47.google.com [209.85.216.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2FA02606A32E
	for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 14:13:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2FA02606A32E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=yMeAkMAr
Received: by mail-pj1-f47.google.com with SMTP id 98e67ed59e1d1-3b155f50c24so3126381a91.3
        for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 06:13:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794665612; x=1795270412; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=uxgyh6i/oWZUfGjNhOfAz/zPxc/xSTYW7KM0UR47m2k=;
        b=yMeAkMArubHR4DSJuBnOkE7Qh6AkLnwz04oh3s89COwiQzFY5xBgPxpEQN9ipD1koo
         iw0DQ1LHb2HMpmR9YPsWCdO8fGNfiG9aNQfs2evwHEXyeRq+a32i+qS6jcxGP8/GKNsL
         zxTjYXZitfPyNvlbH1OBbM04m5Zs9zla1eyrTrnUbxN3GMIMCVXcvnKLU3pZie9s9Soo
         djZfcFN1qye4NirJiSb83s489KRzsa+3xTeXS4qwXU5yXIdmI6CzuF3tqzHci4hEwP/O
         13S5mQYBdZhbNwojuKI68msROTMmHiBjoliq7WMt/y4JGZaP50xkGiMks8sp6JoAU823
         J96g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794665612; x=1795270412;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=uxgyh6i/oWZUfGjNhOfAz/zPxc/xSTYW7KM0UR47m2k=;
        b=lDUTJE27/EU1KxVAsSAXYwf+kRxFwrRHcYfa+8Wh5ktfl/LB/jSifiPFRjjlxs3/QH
         cXc7vodP2ICmRwFAZh4lrdbvsema5iMRDjFYPYnW29QQztlRGeZ2165rF2f84qMZUMGN
         PtFcncwyERKpZQ4tufKW41eZNwlDR6JFKSI7i/ptmy0zSAoY/siGkr78TLs4G76KoIjg
         Wxjd7iNZq2/bYu5G8+TsfE7IRAYUsS+JndcdPGx/FtcgedI7rdBqeF+9NTMqrG1SfX86
         qysUgXIViCEQeEjdu4pFKCby1JbPb6iVS3EDVPWKr0xPGyPtV/T2Fda/NuUGPsihI6/r
         h2Vw==
X-Forwarded-Encrypted: i=1; AL+hErFIkrYZZaY2I1o87VzKtQ3dFFqmNyCNtpu/eevz2jN3qulG9fFZ9cZOICSba0l5OCxJRFQ9Pwn97+I=@vger.kernel.org
X-Gm-Message-State: APuU4Z+uwLtMFW2ECkoOw6DS2Fz3tfTzymu4NrSFwZWNMD/FPZ16AgzO
	rOAsLJjXmurVScZj/uuJxO3DrsjbpDl2LswjumeWPoFK15noIN9bGDCs
X-Gm-Gg: AYBFou0QekXU0yCsIjMtkMsGS2r8i58EJkXiFhKu2I/lCT+ISd+F/hr8RTEm2u1EIoD
	r++qpGSTWgG9HlNF+WX+YiPafCv7oiIpgitpXBmR9k6n4WRngu6z4PpFk9pO6cRwMj0QeNCKTzK
	PFmP88WnY/Y9DiHLcxW4SxX5tNHOz2LIkzHjyqayipN2ITLDvXbbPbslqaEg82Cm4jgugd4yXOv
	lgtOa8Wc0FKvL2/Sz09LqmNSpcjPVElGdHYPneUpv/Y/QRoJjESX9HpnitJeo2t77hlLYdKndQ0
	Ao5wwHdbcK8RXzB3DLgaOXwVgER9AqwLZzjDcC5Fw/3tR51e5P8hzvrjqKqMAuSwYOxfV6/EH8V
	gE0rB7zmHSb9uB+07wNGUOBIiJgreSkts4ww4wtSoVwkqqfS7KN/nVz3Xolz9RVjw6DTNZTHtRD
	L8l5I5wWQZE+XOj9aegzgHnSjIQOOiSrsfSZG1e9dbNxyyujR+IsiywPltwEU9mTe6lxox9NZa9
	2doPIYEpFu9hU8QAueeYb3d4ZhFNMKOo8j/BFhknxceTX4vq2U9LrNkjR7K/lKdYAw0jAaawOLO
	RoLBUL7We6Rtg9FFjwFs29zFDMDAfL+zrz51UHq55DL52qJnpo/oO7XbamS8y5UyvXI/aujHywl
	a
X-Received: by 2002:a17:90b:4c49:b0:3ab:4f1:4f7e with SMTP id 98e67ed59e1d1-3b1b0b8ef0fmr5424088a91.28.1794665612491;
        Sat, 14 Nov 2026 06:13:32 -0800 (PST)
Received: from LDYT9Q2G2M ([2a09:bac1:7680:450::1c:35f])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3b197d0f6e0sm14221601a91.9.2026.11.14.06.13.26
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Sat, 14 Nov 2026 06:13:30 -0800 (PST)
From: Zhiqi Zhang <zhiqizhangg@gmail.com>
To: Christian Brauner <brauner@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Jan Kara <jack@suse.cz>,
	=?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
	=?UTF-8?q?G=C3=BCnther=20Noack?= <gnoack@google.com>,
	Paul Moore <paul@paul-moore.com>,
	James Morris <jmorris@namei.org>,
	"Serge E . Hallyn" <serge@hallyn.com>,
	David Sterba <dsterba@suse.com>,
	linux-fsdevel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] ns: skip namespace_init LSM hook for internal namespaces
Date: Sat, 14 Nov 2026 22:13:23 +0800
Message-ID: <20261114141323.19029-1-zhiqizhangg@gmail.com>
X-Mailer: git-send-email 2.54.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

mount_subtree() allocates a temporary mount namespace while resolving a
path inside a detached mount.  btrfs mounts use this path on every mount
(btrfs_get_tree() -> btrfs_get_tree_subvol() -> mount_subvol() ->
mount_subtree()), as does NFS for referrals.  The namespace is private to
mount_subtree(): it is never installed in an nsproxy, is not reachable
from user space, and is freed before mount_subtree() returns.

__ns_common_init() calls security_namespace_init() for every namespace,
which runs the LSM namespace_init hook.  Landlock implements
LANDLOCK_PERMISSION_NAMESPACE_USE through that hook, so a task in a
domain that handles the permission, allows every namespace type except
CLONE_NEWNS, and is otherwise allowed to mount gets -EPERM from a btrfs
mount.  mount(2) is not covered by the permission and the task never
acquires a namespace.

Skip LSM initialization for kernel-internal namespaces.
__ns_common_init() gains an lsm parameter, and a new
ns_common_init_inum_internal() passes false.  It is used by
mount_subtree() only; user-visible namespace allocations (clone,
unshare, setns, open_tree, fsmount) keep calling the hook.

Reproduced on 7.4-rc2 with a loop-mounted btrfs image and a Landlock
domain that handles NAMESPACE_USE and allows every CLONE_NEW* type except
CLONE_NEWNS:

  mount("/dev/loop0", "/mnt", "btrfs", 0, NULL);   -> -EPERM

The mount succeeds when CLONE_NEWNS is also allowed, and succeeds under
the first domain with this fix.  With the first domain,
unshare(CLONE_NEWNS) and open_tree(OPEN_TREE_CLONE) remain denied.

Fixes: f675d2e95569 ("lsm: add LSM blob and hooks for namespaces")
Signed-off-by: Zhiqi Zhang <zhiqizhangg@gmail.com>
---

AI assistance:

- DeepSeek (deepseek-flash) generated the code change.
- I wrote the tests and reviewed the code.
- I wrote the documentation and the changelog, and used DeepSeek to
  polish the wording.

 fs/namespace.c            | 24 ++++++++++++++++--------
 include/linux/ns_common.h | 20 +++++++++++++++++---
 kernel/nscommon.c         | 18 ++++++++++++------
 security/security.c       |  7 ++++++-
 4 files changed, 51 insertions(+), 18 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index aecd05ac0..622f5094b 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2353,7 +2353,7 @@ void drop_collected_paths(const struct path *paths, const struct path *prealloc)
 		kfree(paths);
 }
 
-static struct mnt_namespace *alloc_mnt_ns(struct user_namespace *, bool);
+static struct mnt_namespace *alloc_mnt_ns(struct user_namespace *, bool, bool);
 
 /* Consumes the caller's reference to @mnt. */
 void dissolve_on_fput(struct vfsmount *mnt)
@@ -3149,7 +3149,7 @@ static struct mnt_namespace *get_detached_copy(const struct path *path, unsigned
 	struct user_namespace *user_ns = mnt_ns->user_ns;
 	struct mount *mnt, *p;
 
-	ns = alloc_mnt_ns(user_ns, true);
+	ns = alloc_mnt_ns(user_ns, true, true);
 	if (IS_ERR(ns))
 		return ns;
 
@@ -3230,7 +3230,7 @@ static struct mnt_namespace *create_new_namespace(struct path *path,
 	if (foreign)
 		copy_flags |= CL_SLAVE | CL_COPY_UNBINDABLE;
 
-	new_ns = alloc_mnt_ns(user_ns, false);
+	new_ns = alloc_mnt_ns(user_ns, false, true);
 	if (IS_ERR(new_ns))
 		return ERR_CAST(new_ns);
 
@@ -4369,7 +4369,7 @@ static void free_mnt_ns(struct mnt_namespace *ns)
 	mnt_ns_tree_remove(ns);
 }
 
-static struct mnt_namespace *alloc_mnt_ns(struct user_namespace *user_ns, bool anon)
+static struct mnt_namespace *alloc_mnt_ns(struct user_namespace *user_ns, bool anon, bool lsm)
 {
 	struct mnt_namespace *new_ns;
 	struct ucounts *ucounts;
@@ -4385,7 +4385,9 @@ static struct mnt_namespace *alloc_mnt_ns(struct user_namespace *user_ns, bool a
 		return ERR_PTR(-ENOMEM);
 	}
 
-	if (anon)
+	if (!lsm)
+		ret = ns_common_init_inum_internal(new_ns, MNT_NS_ANON_INO);
+	else if (anon)
 		ret = ns_common_init_inum(new_ns, MNT_NS_ANON_INO);
 	else
 		ret = ns_common_init(new_ns);
@@ -4422,7 +4424,7 @@ struct mnt_namespace *copy_mnt_ns(u64 flags, struct mnt_namespace *ns,
 
 	old = ns->root;
 
-	new_ns = alloc_mnt_ns(user_ns, false);
+	new_ns = alloc_mnt_ns(user_ns, false, true);
 	if (IS_ERR(new_ns))
 		return new_ns;
 
@@ -4509,7 +4511,13 @@ struct dentry *mount_subtree(struct vfsmount *m, const char *name)
 	struct path path;
 	int err;
 
-	ns = alloc_mnt_ns(&init_user_ns, true);
+	/*
+	 * Private to mount_subtree() and never exposed to user space: skip
+	 * the LSM namespace_init hook, which authorizes a task acquiring
+	 * access to a namespace.  btrfs mounts and NFS referrals use this
+	 * path.
+	 */
+	ns = alloc_mnt_ns(&init_user_ns, true, false);
 	if (IS_ERR(ns)) {
 		mntput(m);
 		return ERR_CAST(ns);
@@ -4699,7 +4707,7 @@ SYSCALL_DEFINE3(fsmount, int, fs_fd, unsigned int, flags,
 		return FD_ADD((flags & FSMOUNT_CLOEXEC) ? O_CLOEXEC : 0,
 			      open_new_namespace(&new_path, MOUNT_COPY_NEW));
 
-	ns = alloc_mnt_ns(current->nsproxy->mnt_ns->user_ns, true);
+	ns = alloc_mnt_ns(current->nsproxy->mnt_ns->user_ns, true, true);
 	if (IS_ERR(ns))
 		return PTR_ERR(ns);
 	mnt = real_mount(new_path.mnt);
diff --git a/include/linux/ns_common.h b/include/linux/ns_common.h
index e8b2bf0da..a21fc1a9b 100644
--- a/include/linux/ns_common.h
+++ b/include/linux/ns_common.h
@@ -10,7 +10,7 @@
 
 bool is_current_namespace(struct ns_common *ns);
 int __ns_common_init(struct ns_common *ns, u32 ns_type, const struct proc_ns_operations *ops,
-		     int inum, u64 ns_id);
+		     int inum, u64 ns_id, bool lsm);
 void __ns_common_free(struct ns_common *ns);
 struct ns_common *__must_check ns_owner(struct ns_common *ns);
 
@@ -47,13 +47,27 @@ static __always_inline bool is_ns_init_id(const struct ns_common *ns)
 			 ns_common_type(__ns),				\
 			 to_ns_operations(__ns),			\
 			 (((__ns) == ns_init_ns(__ns)) ? ns_init_inum(__ns) : 0), \
-			 (((__ns) == ns_init_ns(__ns)) ? ns_init_id(__ns) : 0))
+			 (((__ns) == ns_init_ns(__ns)) ? ns_init_id(__ns) : 0), \
+			 true)
 
 #define ns_common_init_inum(__ns, __inum)        \
 	__ns_common_init(to_ns_common(__ns),     \
 			 ns_common_type(__ns),   \
 			 to_ns_operations(__ns), \
-			 __inum, 0)
+			 __inum, 0, true)
+
+/*
+ * Like ns_common_init_inum(), but for namespaces that stay kernel-internal and
+ * are never exposed to user space (e.g. mount_subtree()'s temporary mount
+ * namespace).  The LSM namespace_init hook authorizes a task acquiring access
+ * to a namespace; these allocations are not such acquisitions and skip LSM
+ * initialization.
+ */
+#define ns_common_init_inum_internal(__ns, __inum) \
+	__ns_common_init(to_ns_common(__ns),          \
+			 ns_common_type(__ns),        \
+			 to_ns_operations(__ns),      \
+			 __inum, 0, false)
 
 #define ns_common_free(__ns) __ns_common_free(to_ns_common((__ns)))
 
diff --git a/kernel/nscommon.c b/kernel/nscommon.c
index 4438c6b66..78e1b6d32 100644
--- a/kernel/nscommon.c
+++ b/kernel/nscommon.c
@@ -55,7 +55,7 @@ static void ns_debug(struct ns_common *ns, const struct proc_ns_operations *ops)
 #endif
 
 int __ns_common_init(struct ns_common *ns, u32 ns_type, const struct proc_ns_operations *ops,
-		     int inum, u64 ns_id)
+		     int inum, u64 ns_id, bool lsm)
 {
 	int ret = 0;
 
@@ -85,11 +85,17 @@ int __ns_common_init(struct ns_common *ns, u32 ns_type, const struct proc_ns_ope
 	/* Allocate the id before the LSM hook so it can track the namespace by it. */
 	__ns_tree_gen_id(ns, ns_id);
 
-	ret = security_namespace_init(ns);
-	if (ret) {
-		if (!inum)
-			proc_free_inum(ns->inum);
-		return ret;
+	/*
+	 * Kernel-internal namespaces (lsm == false) are never exposed to
+	 * user space and are not reported to the namespace_init LSM hook.
+	 */
+	if (lsm) {
+		ret = security_namespace_init(ns);
+		if (ret) {
+			if (!inum)
+				proc_free_inum(ns->inum);
+			return ret;
+		}
 	}
 
 	/*
diff --git a/security/security.c b/security/security.c
index 4727b8347..454ceebcc 100644
--- a/security/security.c
+++ b/security/security.c
@@ -3387,6 +3387,10 @@ int security_create_user_ns(const struct cred *cred)
  * is available via ns->ns_type, and the owning user namespace (if any)
  * via ns->ops->owner(ns).
  *
+ * Kernel-internal namespaces that are never exposed to user space (e.g. the
+ * temporary mount namespace of mount_subtree()) skip this function: they have
+ * no LSM security blob and are not reported to the namespace_init hook.
+ *
  * Return: Returns 0 if successful, otherwise < 0 error code.
  */
 int security_namespace_init(struct ns_common *ns)
@@ -3409,7 +3413,8 @@ int security_namespace_init(struct ns_common *ns)
  * @ns: the namespace being freed
  *
  * Release security data attached to the namespace. Called before the
- * namespace structure is freed.
+ * namespace structure is freed.  Kernel-internal namespaces skipped by
+ * security_namespace_init() have no blob, so this is a no-op for them.
  */
 void security_namespace_free(struct ns_common *ns)
 {
-- 
2.54.0 (Apple Git-157)

