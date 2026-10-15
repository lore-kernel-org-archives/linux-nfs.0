Received: from canpmsgout05.his.huawei.com (canpmsgout05.his.huawei.com [113.46.200.220])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 651E45372E7;
	Thu, 15 Oct 2026 12:20:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.220
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792066843; cv=none; b=D1i847SAY9lgSfaA6QAd3hFslpcrScHidJjpGHPJ4PTxpGod9/d1yZXA3nrb9p6kXOTML1hqwo6fhadUNgxsM3BYdq/2HnMq0GfWtsxcNc0QHDOu8atWsvvB01eqqx1Mplp2yH5j0GxU5fE9xNEQoXsVRm1Ci6URA9dPT5oyfUk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792066843; c=relaxed/simple;
	bh=2bihL+VmPVzsyi8BeBMCUBE7Vj526f5OwZizyPtbp3c=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=WoW5sqq/CuzRrnpIoEdLqcDYIS4oMD3nkj+zyW7lfpgheXyQkSvjRQTfjN7jAgBEmNXIEXH7s4Oh6x82iSJ0YTBelh7KFQbRQCUPqxIB2JNHXViR9FnoXNK+B8V0LpxeACpmb6wIlAEIkErHrDCCp2qOugB+DSE0iLpTvtPizTk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=mtltaizu; arc=none smtp.client-ip=113.46.200.220
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="mtltaizu"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=0NL7t1IOQI7TCN8tbrASMpELo+7IH0n7ig6Mp4vGcws=;
	b=mtltaizueEGr6F08yK2ggPXNlAS9E1dxFJb6ANeJWD41V3sEUmveJ9r4HTg3aWX92w6vijzvl
	7Mab3c45zSlKkttzm0M5dNANr2It9J/Zmgx5YKcDkOgCdLucBuLRKuztMfNGdsrbIHbBG08Frt4
	692m0rC4mSy18bB5vROP0/8=
Received: from mail.maildlp.com (unknown [172.19.162.140])
	by canpmsgout05.his.huawei.com (SkyGuard) with ESMTPS id 4j56L30Vtgz12LF9;
	Thu, 15 Oct 2026 20:08:43 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 6A5F5202E6;
	Thu, 15 Oct 2026 20:20:36 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 15 Oct 2026 20:20:31 +0800
From: Cai Xinchen <caixinchen1@huawei.com>
To: <mic@digikod.net>, <gnoack@google.com>, <paul@paul-moore.com>,
	<jmorris@namei.org>, <serge@hallyn.com>, <corbet@lwn.net>,
	<skhan@linuxfoundation.org>
CC: <ast@kernel.org>, <daniel@iogearbox.net>, <andrii@kernel.org>,
	<eddyz87@gmail.com>, <memxor@gmail.com>, <martin.lau@linux.dev>,
	<song@kernel.org>, <yonghong.song@linux.dev>, <jolsa@kernel.org>,
	<emil@etsalapatis.com>, <ihor.solodrai@linux.dev>, <rdunlap@infradead.org>,
	<gregkh@linuxfoundation.org>, <rafael@kernel.org>, <dakr@kernel.org>,
	<johan@kernel.org>, <dlemoal@kernel.org>, <hch@lst.de>, <axboe@kernel.dk>,
	<viro@zeniv.linux.org.uk>, <brauner@kernel.org>, <jack@suse.cz>,
	<dhowells@redhat.com>, <code@tyhicks.com>, <linkinjeon@kernel.org>,
	<sj1557.seo@samsung.com>, <yuezhang.mo@sony.com>,
	<hirofumi@mail.parknet.co.jp>, <cel@kernel.org>, <jlayton@kernel.org>,
	<neil@brown.name>, <okorniev@redhat.com>, <Dai.Ngo@oracle.com>,
	<tom@talpey.com>, <hyc.lee@gmail.com>, <miklos@szeredi.hu>,
	<amir73il@gmail.com>, <senozhatsky@chromium.org>,
	<chenxiaosong@chenxiaosong.com>, <kpsingh@kernel.org>, <matt@bobrowski.net>,
	<rostedt@goodmis.org>, <mhiramat@kernel.org>,
	<mathieu.desnoyers@efficios.com>, <john.johansen@canonical.com>,
	<georgia.garcia@canonical.com>, <zohar@linux.ibm.com>,
	<roberto.sassu@huawei.com>, <dmitry.kasatkin@gmail.com>,
	<eric.snowberg@oracle.com>, <stephen.smalley.work@gmail.com>,
	<omosnacek@gmail.com>, <casey@schaufler-ca.com>, <takedakn@nttdata.co.jp>,
	<penguin-kernel@I-love.SAKURA.ne.jp>, <xiujianfeng@huawei.com>,
	<nanx95726@gmail.com>, <djwong@kernel.org>, <lujialin4@huawei.com>,
	<bpf@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<driver-core@lists.linux.dev>, <linux-block@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <netfs@lists.linux.dev>,
	<ecryptfs@vger.kernel.org>, <exfat@lists.linux.dev>,
	<linux-nfs@vger.kernel.org>, <ntfs@lists.linux.dev>,
	<linux-unionfs@vger.kernel.org>, <linux-cifs@vger.kernel.org>,
	<linux-trace-kernel@vger.kernel.org>, <apparmor@lists.ubuntu.com>,
	<linux-integrity@vger.kernel.org>, <selinux@vger.kernel.org>,
	<linux-kselftest@vger.kernel.org>
Subject: [PATCH v2 -next 10/18] LSM: rename inode_getattr to path_getattr
Date: Thu, 15 Oct 2026 20:54:16 +0800
Message-ID: <20261015125425.3246251-11-caixinchen1@huawei.com>
X-Mailer: git-send-email 2.18.0.huawei.25
In-Reply-To: <20261015125425.3246251-1-caixinchen1@huawei.com>
References: <20261015125425.3246251-1-caixinchen1@huawei.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
X-ClientProxiedBy: kwepems500001.china.huawei.com (7.221.188.70) To
 whupemk100010.china.huawei.com (7.152.184.41)

The inode_getattr hook receives a struct path, so rename it to
path_getattr to follow the path_* naming convention used for the
other hooks that take a struct path (path_chmod, path_chown, ...).
Rename the security_inode_getattr() inline wrapper to
security_path_getattr() and the SELinux, Smack, AppArmor, TOMOYO and
Landlock implementations accordingly.

BPF programs attach to LSM hooks and to the security_*() wrappers by
name ("lsm/inode_getattr", "fentry/security_inode_getattr"), so
update the BPF selftests to the new names, along with the d_path BTF
allowlist in kernel/trace/bpf_trace.c.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/stat.c                                                   | 4 ++--
 include/linux/lsm_hook_defs.h                               | 2 +-
 include/linux/security.h                                    | 4 ++--
 kernel/bpf/bpf_lsm.c                                        | 2 +-
 kernel/trace/bpf_trace.c                                    | 2 +-
 security/apparmor/lsm.c                                     | 4 ++--
 security/landlock/fs.c                                      | 4 ++--
 security/security.c                                         | 6 +++---
 security/selinux/hooks.c                                    | 4 ++--
 security/smack/smack_lsm.c                                  | 6 +++---
 security/tomoyo/tomoyo.c                                    | 6 +++---
 tools/testing/selftests/bpf/prog_tests/d_path.c             | 2 +-
 tools/testing/selftests/bpf/progs/test_d_path.c             | 2 +-
 .../selftests/bpf/progs/test_d_path_check_rdonly_mem.c      | 2 +-
 tools/testing/selftests/bpf/progs/test_d_path_check_types.c | 2 +-
 tools/testing/selftests/bpf/progs/verifier_vfs_accept.c     | 2 +-
 16 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/fs/stat.c b/fs/stat.c
index a2e63c6c45b7..06e4a5dcea57 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -172,7 +172,7 @@ EXPORT_SYMBOL_GPL(generic_fill_statx_atomic_writes);
  * @request_mask: STATX_xxx flags indicating what the caller wants
  * @query_flags: Query mode (AT_STATX_SYNC_TYPE)
  *
- * Get attributes without calling security_inode_getattr.
+ * Get attributes without calling security_path_getattr.
  *
  * Currently the only caller other than vfs_getattr is internal to the
  * filehandle lookup code, which uses only the inode number and returns no
@@ -260,7 +260,7 @@ int vfs_getattr(const struct path *path, struct kstat *stat,
 {
 	int retval;
 
-	retval = security_inode_getattr(path);
+	retval = security_path_getattr(path);
 	if (unlikely(retval))
 		return retval;
 	return vfs_getattr_nosec(path, stat, request_mask, query_flags);
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index 25655b3eca71..ea1df85b5fd4 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -146,7 +146,7 @@ LSM_HOOK(int, 0, inode_setattr, const struct path *path,
 	 struct iattr *attr)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_setattr, const struct mnt_idmap *idmap,
 	 struct dentry *dentry, int ia_valid)
-LSM_HOOK(int, 0, inode_getattr, const struct path *path)
+LSM_HOOK(int, 0, path_getattr, const struct path *path)
 LSM_HOOK(int, 0, inode_xattr_skipcap, const char *name)
 LSM_HOOK(int, 0, inode_setxattr, const struct path *path,
 	 const char *name, const void *value, size_t size, int flags)
diff --git a/include/linux/security.h b/include/linux/security.h
index 633c8225524a..630a19a63291 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -431,7 +431,7 @@ int security_inode_permission(const struct mnt_idmap *idmap, struct inode *inode
 int security_inode_setattr(const struct path *path, struct iattr *attr);
 void security_inode_post_setattr(const struct mnt_idmap *idmap, struct dentry *dentry,
 				 int ia_valid);
-int security_inode_getattr(const struct path *path);
+int security_path_getattr(const struct path *path);
 int security_inode_setxattr(const struct path *path,
 			    const char *name, const void *value,
 			    size_t size, int flags);
@@ -1007,7 +1007,7 @@ security_inode_post_setattr(const struct mnt_idmap *idmap, struct dentry *dentry
 			    int ia_valid)
 { }
 
-static inline int security_inode_getattr(const struct path *path)
+static inline int security_path_getattr(const struct path *path)
 {
 	return 0;
 }
diff --git a/kernel/bpf/bpf_lsm.c b/kernel/bpf/bpf_lsm.c
index f58dce888ff4..293f849879e2 100644
--- a/kernel/bpf/bpf_lsm.c
+++ b/kernel/bpf/bpf_lsm.c
@@ -335,7 +335,7 @@ BTF_ID(func, bpf_lsm_file_receive)
 
 BTF_ID(func, bpf_lsm_inode_create)
 BTF_ID(func, bpf_lsm_inode_free_security)
-BTF_ID(func, bpf_lsm_inode_getattr)
+BTF_ID(func, bpf_lsm_path_getattr)
 BTF_ID(func, bpf_lsm_inode_getxattr)
 BTF_ID(func, bpf_lsm_inode_mknod)
 BTF_ID(func, bpf_lsm_inode_need_killpriv)
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 195f78db9bda..6f3664718842 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -961,7 +961,7 @@ BPF_CALL_3(bpf_d_path, const struct path *, path, char *, buf, u32, sz)
 BTF_SET_START(btf_allowlist_d_path)
 #ifdef CONFIG_SECURITY
 BTF_ID(func, security_file_permission)
-BTF_ID(func, security_inode_getattr)
+BTF_ID(func, security_path_getattr)
 BTF_ID(func, security_file_open)
 #endif
 #ifdef CONFIG_SECURITY_PATH
diff --git a/security/apparmor/lsm.c b/security/apparmor/lsm.c
index 9d572cf8486b..a2886f6ece78 100644
--- a/security/apparmor/lsm.c
+++ b/security/apparmor/lsm.c
@@ -456,7 +456,7 @@ static int apparmor_path_chown(const struct path *path, kuid_t uid, kgid_t gid)
 	return common_perm_cond(OP_CHOWN, path, AA_MAY_CHOWN);
 }
 
-static int apparmor_inode_getattr(const struct path *path)
+static int apparmor_path_getattr(const struct path *path)
 {
 	return common_perm_cond(OP_GETATTR, path, AA_MAY_GETATTR);
 }
@@ -1785,7 +1785,7 @@ static struct security_hook_list apparmor_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(path_chmod, apparmor_path_chmod),
 	LSM_HOOK_INIT(path_chown, apparmor_path_chown),
 	LSM_HOOK_INIT(path_truncate, apparmor_path_truncate),
-	LSM_HOOK_INIT(inode_getattr, apparmor_inode_getattr),
+	LSM_HOOK_INIT(path_getattr, apparmor_path_getattr),
 
 	LSM_HOOK_INIT(file_open, apparmor_file_open),
 	LSM_HOOK_INIT(file_receive, apparmor_file_receive),
diff --git a/security/landlock/fs.c b/security/landlock/fs.c
index f56277c67a24..439a6159e24a 100644
--- a/security/landlock/fs.c
+++ b/security/landlock/fs.c
@@ -1678,7 +1678,7 @@ static int hook_path_truncate(const struct path *const path)
 	return current_check_access_path(path, LANDLOCK_ACCESS_FS_TRUNCATE);
 }
 
-static int hook_inode_getattr(const struct path *const path)
+static int hook_path_getattr(const struct path *const path)
 {
 	return current_check_access_path(path,
 					LANDLOCK_ACCESS_FS_READ_METADATA);
@@ -2215,7 +2215,7 @@ static struct security_hook_list landlock_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(path_unlink, hook_path_unlink),
 	LSM_HOOK_INIT(path_rmdir, hook_path_rmdir),
 	LSM_HOOK_INIT(path_truncate, hook_path_truncate),
-	LSM_HOOK_INIT(inode_getattr, hook_inode_getattr),
+	LSM_HOOK_INIT(path_getattr, hook_path_getattr),
 	LSM_HOOK_INIT(inode_file_getattr, hook_inode_file_getattr),
 	LSM_HOOK_INIT(inode_setattr, hook_inode_setattr),
 	LSM_HOOK_INIT(inode_file_setattr, hook_inode_file_setattr),
diff --git a/security/security.c b/security/security.c
index 10b331749889..c7cb96db7299 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1926,18 +1926,18 @@ void security_inode_post_setattr(const struct mnt_idmap *idmap, struct dentry *d
 }
 
 /**
- * security_inode_getattr() - Check if getting file attributes is allowed
+ * security_path_getattr() - Check if getting file attributes is allowed
  * @path: file
  *
  * Check permission before obtaining file attributes.
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_getattr(const struct path *path)
+int security_path_getattr(const struct path *path)
 {
 	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_getattr, path);
+	return call_int_hook(path_getattr, path);
 }
 
 /**
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 0a841777fe12..93e3d9223e34 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3376,7 +3376,7 @@ static int selinux_inode_setattr(const struct path *path,
 	return dentry_has_perm(cred, dentry, av);
 }
 
-static int selinux_inode_getattr(const struct path *path)
+static int selinux_path_getattr(const struct path *path)
 {
 	struct task_security_struct *tsec;
 
@@ -7756,7 +7756,7 @@ static struct security_hook_list selinux_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(inode_follow_link, selinux_inode_follow_link),
 	LSM_HOOK_INIT(inode_permission, selinux_inode_permission),
 	LSM_HOOK_INIT(inode_setattr, selinux_inode_setattr),
-	LSM_HOOK_INIT(inode_getattr, selinux_inode_getattr),
+	LSM_HOOK_INIT(path_getattr, selinux_path_getattr),
 	LSM_HOOK_INIT(inode_xattr_skipcap, selinux_inode_xattr_skipcap),
 	LSM_HOOK_INIT(inode_setxattr, selinux_inode_setxattr),
 	LSM_HOOK_INIT(inode_post_setxattr, selinux_inode_post_setxattr),
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 8cfe5d522246..43b9877d6a00 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1293,12 +1293,12 @@ static int smack_inode_setattr(const struct path *path,
 }
 
 /**
- * smack_inode_getattr - Smack check for getting attributes
+ * smack_path_getattr - Smack check for getting attributes
  * @path: path to extract the info from
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_getattr(const struct path *path)
+static int smack_path_getattr(const struct path *path)
 {
 	struct smk_audit_info ad;
 	struct inode *inode = d_backing_inode(path->dentry);
@@ -5179,7 +5179,7 @@ static struct security_hook_list smack_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(inode_rename, smack_inode_rename),
 	LSM_HOOK_INIT(inode_permission, smack_inode_permission),
 	LSM_HOOK_INIT(inode_setattr, smack_inode_setattr),
-	LSM_HOOK_INIT(inode_getattr, smack_inode_getattr),
+	LSM_HOOK_INIT(path_getattr, smack_path_getattr),
 	LSM_HOOK_INIT(inode_xattr_skipcap, smack_inode_xattr_skipcap),
 	LSM_HOOK_INIT(inode_setxattr, smack_inode_setxattr),
 	LSM_HOOK_INIT(inode_post_setxattr, smack_inode_post_setxattr),
diff --git a/security/tomoyo/tomoyo.c b/security/tomoyo/tomoyo.c
index c66e02ed8ee3..901eefa84ea6 100644
--- a/security/tomoyo/tomoyo.c
+++ b/security/tomoyo/tomoyo.c
@@ -112,13 +112,13 @@ static int tomoyo_bprm_check_security(struct linux_binprm *bprm)
 }
 
 /**
- * tomoyo_inode_getattr - Target for security_inode_getattr().
+ * tomoyo_path_getattr - Target for security_path_getattr().
  *
  * @path: Pointer to "struct path".
  *
  * Returns 0 on success, negative value otherwise.
  */
-static int tomoyo_inode_getattr(const struct path *path)
+static int tomoyo_path_getattr(const struct path *path)
 {
 	return tomoyo_path_perm(TOMOYO_TYPE_GETATTR, path, NULL);
 }
@@ -570,7 +570,7 @@ static struct security_hook_list tomoyo_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(path_mknod, tomoyo_path_mknod),
 	LSM_HOOK_INIT(path_link, tomoyo_path_link),
 	LSM_HOOK_INIT(path_rename, tomoyo_path_rename),
-	LSM_HOOK_INIT(inode_getattr, tomoyo_inode_getattr),
+	LSM_HOOK_INIT(path_getattr, tomoyo_path_getattr),
 	LSM_HOOK_INIT(file_ioctl, tomoyo_file_ioctl),
 	LSM_HOOK_INIT(file_ioctl_compat, tomoyo_file_ioctl),
 	LSM_HOOK_INIT(path_chmod, tomoyo_path_chmod),
diff --git a/tools/testing/selftests/bpf/prog_tests/d_path.c b/tools/testing/selftests/bpf/prog_tests/d_path.c
index 1a2a2f1abf03..9877c098e5c1 100644
--- a/tools/testing/selftests/bpf/prog_tests/d_path.c
+++ b/tools/testing/selftests/bpf/prog_tests/d_path.c
@@ -160,7 +160,7 @@ static void test_d_path_basic(void)
 
 	if (CHECK(!bss->called_stat,
 		  "stat",
-		  "trampoline for security_inode_getattr was not called\n"))
+		  "trampoline for security_path_getattr was not called\n"))
 		goto cleanup;
 
 	if (CHECK(!bss->called_close,
diff --git a/tools/testing/selftests/bpf/progs/test_d_path.c b/tools/testing/selftests/bpf/progs/test_d_path.c
index 561b2f861808..b97c203e3992 100644
--- a/tools/testing/selftests/bpf/progs/test_d_path.c
+++ b/tools/testing/selftests/bpf/progs/test_d_path.c
@@ -19,7 +19,7 @@ int called_stat = 0;
 int called_close = 0;
 int path_match_fallocate = 0;
 
-SEC("fentry/security_inode_getattr")
+SEC("fentry/security_path_getattr")
 int BPF_PROG(prog_stat, struct path *path, struct kstat *stat,
 	     __u32 request_mask, unsigned int query_flags)
 {
diff --git a/tools/testing/selftests/bpf/progs/test_d_path_check_rdonly_mem.c b/tools/testing/selftests/bpf/progs/test_d_path_check_rdonly_mem.c
index 27c27cff6a3a..5e0e3d4828d7 100644
--- a/tools/testing/selftests/bpf/progs/test_d_path_check_rdonly_mem.c
+++ b/tools/testing/selftests/bpf/progs/test_d_path_check_rdonly_mem.c
@@ -7,7 +7,7 @@
 
 extern const int bpf_prog_active __ksym;
 
-SEC("fentry/security_inode_getattr")
+SEC("fentry/security_path_getattr")
 int BPF_PROG(d_path_check_rdonly_mem, struct path *path, struct kstat *stat,
 	     __u32 request_mask, unsigned int query_flags)
 {
diff --git a/tools/testing/selftests/bpf/progs/test_d_path_check_types.c b/tools/testing/selftests/bpf/progs/test_d_path_check_types.c
index 7e02b7361307..fba3d527b4df 100644
--- a/tools/testing/selftests/bpf/progs/test_d_path_check_types.c
+++ b/tools/testing/selftests/bpf/progs/test_d_path_check_types.c
@@ -11,7 +11,7 @@ struct {
 	__uint(max_entries, 1 << 12);
 } ringbuf SEC(".maps");
 
-SEC("fentry/security_inode_getattr")
+SEC("fentry/security_path_getattr")
 int BPF_PROG(d_path_check_rdonly_mem, struct path *path, struct kstat *stat,
 	     __u32 request_mask, unsigned int query_flags)
 {
diff --git a/tools/testing/selftests/bpf/progs/verifier_vfs_accept.c b/tools/testing/selftests/bpf/progs/verifier_vfs_accept.c
index 55398c04290a..55e292a41d30 100644
--- a/tools/testing/selftests/bpf/progs/verifier_vfs_accept.c
+++ b/tools/testing/selftests/bpf/progs/verifier_vfs_accept.c
@@ -54,7 +54,7 @@ int BPF_PROG(get_task_exe_file_and_put_kfunc_from_argument,
 	return 0;
 }
 
-SEC("lsm.s/inode_getattr")
+SEC("lsm.s/path_getattr")
 __success
 int BPF_PROG(path_d_path_from_path_argument, struct path *path)
 {
-- 
2.18.0.huawei.25

