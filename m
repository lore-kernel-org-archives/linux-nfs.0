Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.221
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101146;
	b=FNpmNQBrZJ7cCv14qeYYoqe7ptgTle2soB9adMhvWJed606easmWnIU64TQE857iKF2i
	 Jnxg9oNwa7m/QO89U0EnlD1QRbFczNSIkKI6oUuX3PX056r2STdnfKgOXJlLUtfJeNijz
	 XrXEQ12FH/b+c2NpDqfm84vV0jkdHipchGw/reCsdOu/4NDGYUCK1PjcK+I1SOV9rSZI+
	 0/5uVRR2SoMlFL/E6TvBFVH/KmfnMr9DfgWP4YTmSIbiX+j75S2MfMT0N6JmYMNPnO3NM
	 Nc4Mquo4y6d8xK1BhSwjGg1kPcminEwu+TLRJ/6ecwGO1Dt4zcSjwUJfuOzStHvL6WA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101146;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:X-Originating-IP:X-ClientProxiedBy;
	bh=ic92MzCf6KpquytFcG/PqE+rOS0TT+6sRbhPjPBtwW4=;
	b=U+EcxCoQNQ26pIZZGn3JAXWPk4QAC606XX2ncl1oC9yfmMqRpE2IsFSRgiIBEeD/yVbk
	 4UoQHk9tf/mvcz0RNEZCBKY/T8tGsvSikGm2fkivYayQ4bC+Ag1OecXYjmjWt6uw6u4AB
	 DSCc2E0HWFeVMmX1Ze3oGkSxZACjudTdqR7zztpM8DJ9mGfrIJorkqXkMxdxc/EdTogzc
	 H0MAZR/yVvfoW67Uc952kRreB4NgeNSBuwEJHjqp5FZDPxA0fCoI5zQPTvgCxf0lIVndQ
	 GowUZEHpJ/TDvPGL7TolM7+LN9H+RGjXaOZ2/TzDj2EfGWUXRu0vGIa1qNUULrHRw1g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=uFhmVte5;
	arc=none smtp.remote-ip=113.46.200.221
Received: from canpmsgout06.his.huawei.com (canpmsgout06.his.huawei.com [113.46.200.221])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5DFDC606A321;
	Tue, 27 Oct 2026 11:39:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5DFDC606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=uFhmVte5
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=ic92MzCf6KpquytFcG/PqE+rOS0TT+6sRbhPjPBtwW4=;
	b=uFhmVte5DiIDuz5G9TzMws4H8nIYxUXDaHnqqTirh/REx+XVZI3sQBjoqRfbhvA00Nmj7aaPt
	swfsWu/1kp5DDdR0sbCC0tFw0ljaMUCkUFAttkXuMZKQggl3UmOSB4Z60PnbLs/dzQX1yXTGmTm
	NzRIDjVk+vrdZfV3GYQRzO8=
Received: from mail.maildlp.com (unknown [172.19.162.144])
	by canpmsgout06.his.huawei.com (SkyGuard) with ESMTPS id 4jDT615BQRzRhtQ;
	Tue, 27 Oct 2026 19:38:49 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id A10344056D;
	Tue, 27 Oct 2026 19:38:57 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Tue, 27 Oct 2026 19:38:52 +0800
From: Cai Xinchen <caixinchen1@huawei.com>
To: <mic@digikod.net>, <gnoack@google.com>, <paul@paul-moore.com>,
	<jmorris@namei.org>, <serge@hallyn.com>, <corbet@lwn.net>,
	<skhan@linuxfoundation.org>, <utilityemal77@gmail.com>,
	<caixinchen1@huawei.com>
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
	<chenxiaosong@chenxiaosong.com>, <dsterba@suse.com>, <mason@kernel.org>,
	<kpsingh@kernel.org>, <matt@bobrowski.net>, <rostedt@goodmis.org>,
	<mhiramat@kernel.org>, <mathieu.desnoyers@efficios.com>,
	<john.johansen@canonical.com>, <georgia.garcia@canonical.com>,
	<zohar@linux.ibm.com>, <roberto.sassu@huawei.com>,
	<dmitry.kasatkin@gmail.com>, <eric.snowberg@oracle.com>,
	<stephen.smalley.work@gmail.com>, <omosnacek@gmail.com>,
	<casey@schaufler-ca.com>, <takedakn@nttdata.co.jp>,
	<penguin-kernel@I-love.SAKURA.ne.jp>, <xiujianfeng@huawei.com>,
	<nanx95726@gmail.com>, <djwong@kernel.org>, <lujialin4@huawei.com>,
	<bpf@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<driver-core@lists.linux.dev>, <linux-block@vger.kernel.org>,
	<linux-btrfs@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	<netfs@lists.linux.dev>, <ecryptfs@vger.kernel.org>, <exfat@lists.linux.dev>,
	<linux-nfs@vger.kernel.org>, <ntfs@lists.linux.dev>,
	<linux-unionfs@vger.kernel.org>, <linux-cifs@vger.kernel.org>,
	<linux-trace-kernel@vger.kernel.org>, <apparmor@lists.ubuntu.com>,
	<linux-integrity@vger.kernel.org>, <selinux@vger.kernel.org>,
	<linux-kselftest@vger.kernel.org>
Subject: [PATCH v3 -next 11/18] LSM: rename the inode xattr hooks to path_xattr hooks
Date: Tue, 27 Oct 2026 20:11:44 +0800
Message-ID: <20261027121151.1887650-12-caixinchen1@huawei.com>
X-Mailer: git-send-email 2.18.0.huawei.25
In-Reply-To: <20261027121151.1887650-1-caixinchen1@huawei.com>
References: <20261027121151.1887650-1-caixinchen1@huawei.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain
X-ClientProxiedBy: kwepems500002.china.huawei.com (7.221.188.17) To
 whupemk100010.china.huawei.com (7.152.184.41)

The inode_setxattr, inode_getxattr, inode_listxattr and
inode_removexattr hooks receive a struct path, so rename them to
path_setxattr, path_getxattr, path_listxattr and path_removexattr to
follow the path_* naming convention used for the other hooks that
take a struct path (path_chmod, path_chown, ...).  Rename the
security_inode_*xattr() inline wrappers to security_path_*xattr()
and the SELinux, Smack, EVM and IMA implementations
accordingly.  The inode_post_setxattr and inode_post_removexattr
notification hooks still take a dentry and keep their names.

BPF programs attach to LSM hooks by name ("lsm/inode_getxattr",
"lsm.s/inode_setxattr", ...), so update the BPF selftests to the new
names.

Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 Documentation/bpf/fs_kfuncs.rst               |  2 +-
 fs/bpf_fs_kfuncs.c                            |  4 +-
 fs/overlayfs/inode.c                          |  2 +-
 fs/xattr.c                                    | 10 ++---
 include/linux/lsm_hook_defs.h                 |  8 ++--
 include/linux/security.h                      | 32 ++++++++--------
 kernel/bpf/bpf_lsm.c                          |  6 +--
 security/integrity/evm/evm_main.c             | 28 +++++++-------
 security/integrity/ima/ima_appraise.c         | 20 +++++-----
 security/security.c                           | 37 ++++++++++---------
 security/selinux/hooks.c                      | 27 +++++++-------
 security/smack/smack_lsm.c                    | 26 ++++++-------
 .../selftests/bpf/prog_tests/fs_kfuncs.c      | 10 ++---
 .../selftests/bpf/progs/test_get_xattr.c      |  4 +-
 .../bpf/progs/test_set_remove_xattr.c         |  8 ++--
 .../bpf/progs/verifier_lsm_init_xattr.c       |  2 +-
 .../selftests/bpf/progs/verifier_vfs_reject.c |  2 +-
 17 files changed, 115 insertions(+), 113 deletions(-)

diff --git a/Documentation/bpf/fs_kfuncs.rst b/Documentation/bpf/fs_kfuncs.rst
index 8762c3233a3d..9586dbbbf177 100644
--- a/Documentation/bpf/fs_kfuncs.rst
+++ b/Documentation/bpf/fs_kfuncs.rst
@@ -18,4 +18,4 @@ To avoid recursions, these kfuncs follow the following rules:
 1. These kfuncs are only permitted from BPF LSM function.
 2. These kfuncs should not call into other LSM hooks, i.e. security_*(). For
    example, ``bpf_get_file_xattr()`` does not use ``vfs_getxattr()``, because
-   the latter calls LSM hook ``security_inode_getxattr``.
+   the latter calls LSM hook ``security_path_getxattr``.
diff --git a/fs/bpf_fs_kfuncs.c b/fs/bpf_fs_kfuncs.c
index 6500d8419bc1..ab25344e6205 100644
--- a/fs/bpf_fs_kfuncs.c
+++ b/fs/bpf_fs_kfuncs.c
@@ -566,10 +566,10 @@ BTF_SET_START(d_inode_locked_hooks)
 BTF_ID(func, bpf_lsm_inode_post_removexattr)
 BTF_ID(func, bpf_lsm_inode_post_setattr)
 BTF_ID(func, bpf_lsm_inode_post_setxattr)
-BTF_ID(func, bpf_lsm_inode_removexattr)
+BTF_ID(func, bpf_lsm_path_removexattr)
 BTF_ID(func, bpf_lsm_inode_rmdir)
 BTF_ID(func, bpf_lsm_path_setattr)
-BTF_ID(func, bpf_lsm_inode_setxattr)
+BTF_ID(func, bpf_lsm_path_setxattr)
 BTF_ID(func, bpf_lsm_inode_unlink)
 BTF_SET_END(d_inode_locked_hooks)
 
diff --git a/fs/overlayfs/inode.c b/fs/overlayfs/inode.c
index 4f1d3077735b..9e6fab3a42d3 100644
--- a/fs/overlayfs/inode.c
+++ b/fs/overlayfs/inode.c
@@ -392,7 +392,7 @@ static void ovl_idmap_posix_acl(const struct inode *realinode,
  * > and following it on overlayfs.
  * >
  * > Applying the same logic to acl: we do need to call the
- * > security_inode_getxattr() on the underlying fs, even if just want to
+ * > security_path_getxattr() on the underlying fs, even if just want to
  * > check permissions on overlay. This is currently not done, which is an
  * > inconsistency.
  * >
diff --git a/fs/xattr.c b/fs/xattr.c
index 7ef3d28e5979..c97fb768ac61 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -309,8 +309,8 @@ __vfs_setxattr_locked(const struct mnt_idmap *idmap, const struct path *path,
 	if (error)
 		return error;
 
-	error = security_inode_setxattr(idmap, path, name, value, size,
-					flags, file);
+	error = security_path_setxattr(idmap, path, name, value, size,
+				       flags, file);
 	if (error)
 		goto out;
 
@@ -464,7 +464,7 @@ vfs_getxattr(const struct mnt_idmap *idmap, const struct path *path,
 	if (error)
 		return error;
 
-	error = security_inode_getxattr(path, name, file);
+	error = security_path_getxattr(path, name, file);
 	if (error)
 		return error;
 
@@ -517,7 +517,7 @@ vfs_listxattr(const struct path *path, char *list, size_t size,
 	struct inode *inode = d_inode(dentry);
 	ssize_t error;
 
-	error = security_inode_listxattr(path, file);
+	error = security_path_listxattr(path, file);
 	if (error)
 		return error;
 
@@ -580,7 +580,7 @@ __vfs_removexattr_locked(const struct mnt_idmap *idmap,
 	if (error)
 		return error;
 
-	error = security_inode_removexattr(idmap, path, name, file);
+	error = security_path_removexattr(idmap, path, name, file);
 	if (error)
 		goto out;
 
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index f64a8a0f94a4..4f3d19bf4644 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -156,16 +156,16 @@ LSM_HOOK(void, LSM_RET_VOID, inode_post_setattr, const struct mnt_idmap *idmap,
 LSM_HOOK(int, 0, path_getattr, const struct path *path,
 	 struct file *file)
 LSM_HOOK(int, 0, inode_xattr_skipcap, const char *name)
-LSM_HOOK(int, 0, inode_setxattr, const struct mnt_idmap *idmap,
+LSM_HOOK(int, 0, path_setxattr, const struct mnt_idmap *idmap,
 	 const struct path *path, const char *name, const void *value,
 	 size_t size, int flags, struct file *file)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_setxattr, struct dentry *dentry,
 	 const char *name, const void *value, size_t size, int flags)
-LSM_HOOK(int, 0, inode_getxattr, const struct path *path, const char *name,
+LSM_HOOK(int, 0, path_getxattr, const struct path *path, const char *name,
 	 struct file *file)
-LSM_HOOK(int, 0, inode_listxattr, const struct path *path,
+LSM_HOOK(int, 0, path_listxattr, const struct path *path,
 	 struct file *file)
-LSM_HOOK(int, 0, inode_removexattr, const struct mnt_idmap *idmap,
+LSM_HOOK(int, 0, path_removexattr, const struct mnt_idmap *idmap,
 	 const struct path *path, const char *name, struct file *file)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_removexattr, struct dentry *dentry,
 	 const char *name)
diff --git a/include/linux/security.h b/include/linux/security.h
index 17a46b413ed3..afbc12c6e614 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -436,10 +436,10 @@ int security_path_setattr(const struct mnt_idmap *idmap,
 void security_inode_post_setattr(const struct mnt_idmap *idmap, struct dentry *dentry,
 				 int ia_valid);
 int security_path_getattr(const struct path *path, struct file *file);
-int security_inode_setxattr(const struct mnt_idmap *idmap,
-			    const struct path *path, const char *name,
-			    const void *value, size_t size, int flags,
-			    struct file *file);
+int security_path_setxattr(const struct mnt_idmap *idmap,
+			   const struct path *path, const char *name,
+			   const void *value, size_t size, int flags,
+			   struct file *file);
 int security_inode_set_acl(const struct mnt_idmap *idmap,
 			   const struct path *path, const char *acl_name,
 			   struct posix_acl *kacl, struct file *file);
@@ -456,13 +456,13 @@ void security_inode_post_remove_acl(const struct mnt_idmap *idmap,
 				    const char *acl_name);
 void security_inode_post_setxattr(struct dentry *dentry, const char *name,
 				  const void *value, size_t size, int flags);
-int security_inode_getxattr(const struct path *path,
-			    const char *name, struct file *file);
-int security_inode_listxattr(const struct path *path,
+int security_path_getxattr(const struct path *path,
+			   const char *name, struct file *file);
+int security_path_listxattr(const struct path *path,
+			    struct file *file);
+int security_path_removexattr(const struct mnt_idmap *idmap,
+			      const struct path *path, const char *name,
 			      struct file *file);
-int security_inode_removexattr(const struct mnt_idmap *idmap,
-			       const struct path *path, const char *name,
-			       struct file *file);
 void security_inode_post_removexattr(struct dentry *dentry, const char *name);
 int security_inode_file_setattr(const struct path *path,
 				struct file_kattr *fa, struct file *file);
@@ -1022,7 +1022,7 @@ static inline int security_path_getattr(const struct path *path,
 	return 0;
 }
 
-static inline int security_inode_setxattr(const struct mnt_idmap *idmap,
+static inline int security_path_setxattr(const struct mnt_idmap *idmap,
 		const struct path *path, const char *name,
 		const void *value, size_t size, int flags,
 		struct file *file)
@@ -1069,19 +1069,19 @@ static inline void security_inode_post_setxattr(struct dentry *dentry,
 		const char *name, const void *value, size_t size, int flags)
 { }
 
-static inline int security_inode_getxattr(const struct path *path,
-			const char *name, struct file *file)
+static inline int security_path_getxattr(const struct path *path,
+					 const char *name, struct file *file)
 {
 	return 0;
 }
 
-static inline int security_inode_listxattr(const struct path *path,
-					   struct file *file)
+static inline int security_path_listxattr(const struct path *path,
+					  struct file *file)
 {
 	return 0;
 }
 
-static inline int security_inode_removexattr(const struct mnt_idmap *idmap,
+static inline int security_path_removexattr(const struct mnt_idmap *idmap,
 					     const struct path *path,
 					     const char *name,
 					     struct file *file)
diff --git a/kernel/bpf/bpf_lsm.c b/kernel/bpf/bpf_lsm.c
index 32f84356933e..9d7771417812 100644
--- a/kernel/bpf/bpf_lsm.c
+++ b/kernel/bpf/bpf_lsm.c
@@ -336,17 +336,17 @@ BTF_ID(func, bpf_lsm_file_receive)
 BTF_ID(func, bpf_lsm_inode_create)
 BTF_ID(func, bpf_lsm_inode_free_security)
 BTF_ID(func, bpf_lsm_path_getattr)
-BTF_ID(func, bpf_lsm_inode_getxattr)
+BTF_ID(func, bpf_lsm_path_getxattr)
 BTF_ID(func, bpf_lsm_inode_mknod)
 BTF_ID(func, bpf_lsm_inode_need_killpriv)
 BTF_ID(func, bpf_lsm_inode_post_setxattr)
 BTF_ID(func, bpf_lsm_inode_post_removexattr)
 BTF_ID(func, bpf_lsm_inode_readlink)
-BTF_ID(func, bpf_lsm_inode_removexattr)
+BTF_ID(func, bpf_lsm_path_removexattr)
 BTF_ID(func, bpf_lsm_inode_rename)
 BTF_ID(func, bpf_lsm_inode_rmdir)
 BTF_ID(func, bpf_lsm_path_setattr)
-BTF_ID(func, bpf_lsm_inode_setxattr)
+BTF_ID(func, bpf_lsm_path_setxattr)
 BTF_ID(func, bpf_lsm_inode_symlink)
 BTF_ID(func, bpf_lsm_inode_unlink)
 BTF_ID(func, bpf_lsm_kernel_module_request)
diff --git a/security/integrity/evm/evm_main.c b/security/integrity/evm/evm_main.c
index 962b31a97ec9..025606fe5fe8 100644
--- a/security/integrity/evm/evm_main.c
+++ b/security/integrity/evm/evm_main.c
@@ -7,8 +7,8 @@
  * Kylene Hall <kjhall@us.ibm.com>
  *
  * File: evm_main.c
- *	implements evm_inode_setxattr, evm_inode_post_setxattr,
- *	evm_inode_removexattr, evm_verifyxattr, and evm_inode_set_acl.
+ *	implements evm_path_setxattr, evm_inode_post_setxattr,
+ *	evm_path_removexattr, evm_verifyxattr, and evm_inode_set_acl.
  */
 
 #define pr_fmt(fmt) "EVM: "fmt
@@ -593,7 +593,7 @@ static int evm_protect_xattr(const struct mnt_idmap *idmap,
 }
 
 /**
- * evm_inode_setxattr - protect the EVM extended attribute
+ * evm_path_setxattr - protect the EVM extended attribute
  * @idmap: idmap of the mount
  * @path: pointer to the affected object
  * @xattr_name: pointer to the affected extended attribute name
@@ -608,11 +608,11 @@ static int evm_protect_xattr(const struct mnt_idmap *idmap,
  * userspace from writing HMAC value.  Writing 'security.evm' requires
  * requires CAP_SYS_ADMIN privileges.
  */
-static int evm_inode_setxattr(const struct mnt_idmap *idmap,
-			      const struct path *path,
-			      const char *xattr_name, const void *xattr_value,
-			      size_t xattr_value_len, int flags,
-			      struct file *file)
+static int evm_path_setxattr(const struct mnt_idmap *idmap,
+			     const struct path *path,
+			     const char *xattr_name, const void *xattr_value,
+			     size_t xattr_value_len, int flags,
+			     struct file *file)
 {
 	const struct evm_ima_xattr_data *xattr_data = xattr_value;
 	struct dentry *dentry = path->dentry;
@@ -635,7 +635,7 @@ static int evm_inode_setxattr(const struct mnt_idmap *idmap,
 }
 
 /**
- * evm_inode_removexattr - protect the EVM extended attribute
+ * evm_path_removexattr - protect the EVM extended attribute
  * @idmap: idmap of the mount
  * @path: pointer to the affected object
  * @xattr_name: pointer to the affected extended attribute name
@@ -644,9 +644,9 @@ static int evm_inode_setxattr(const struct mnt_idmap *idmap,
  * Removing 'security.evm' requires CAP_SYS_ADMIN privileges and that
  * the current value is valid.
  */
-static int evm_inode_removexattr(const struct mnt_idmap *idmap,
-				 const struct path *path,
-				 const char *xattr_name, struct file *file)
+static int evm_path_removexattr(const struct mnt_idmap *idmap,
+				const struct path *path,
+				const char *xattr_name, struct file *file)
 {
 	struct dentry *dentry = path->dentry;
 
@@ -1215,13 +1215,13 @@ static struct security_hook_list evm_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(path_setattr, evm_path_setattr),
 	LSM_HOOK_INIT(inode_post_setattr, evm_inode_post_setattr),
 	LSM_HOOK_INIT(inode_copy_up_xattr, evm_inode_copy_up_xattr),
-	LSM_HOOK_INIT(inode_setxattr, evm_inode_setxattr),
+	LSM_HOOK_INIT(path_setxattr, evm_path_setxattr),
 	LSM_HOOK_INIT(inode_post_setxattr, evm_inode_post_setxattr),
 	LSM_HOOK_INIT(inode_set_acl, evm_inode_set_acl),
 	LSM_HOOK_INIT(inode_post_set_acl, evm_inode_post_set_acl),
 	LSM_HOOK_INIT(inode_remove_acl, evm_inode_remove_acl),
 	LSM_HOOK_INIT(inode_post_remove_acl, evm_inode_post_remove_acl),
-	LSM_HOOK_INIT(inode_removexattr, evm_inode_removexattr),
+	LSM_HOOK_INIT(path_removexattr, evm_path_removexattr),
 	LSM_HOOK_INIT(inode_post_removexattr, evm_inode_post_removexattr),
 	LSM_HOOK_INIT(inode_init_security, evm_inode_init_security),
 	LSM_HOOK_INIT(inode_alloc_security, evm_inode_alloc_security),
diff --git a/security/integrity/ima/ima_appraise.c b/security/integrity/ima/ima_appraise.c
index a231f1f419f7..c701dce1e837 100644
--- a/security/integrity/ima/ima_appraise.c
+++ b/security/integrity/ima/ima_appraise.c
@@ -759,11 +759,11 @@ static int validate_hash_algo(struct dentry *dentry,
 	return -EACCES;
 }
 
-static int ima_inode_setxattr(const struct mnt_idmap *idmap,
-			      const struct path *path,
-			      const char *xattr_name, const void *xattr_value,
-			      size_t xattr_value_len, int flags,
-			      struct file *file)
+static int ima_path_setxattr(const struct mnt_idmap *idmap,
+			   const struct path *path,
+			   const char *xattr_name, const void *xattr_value,
+			   size_t xattr_value_len, int flags,
+			   struct file *file)
 {
 	const struct evm_ima_xattr_data *xvalue = xattr_value;
 	struct dentry *dentry = path->dentry;
@@ -806,9 +806,9 @@ static int ima_inode_set_acl(const struct mnt_idmap *idmap,
 	return 0;
 }
 
-static int ima_inode_removexattr(const struct mnt_idmap *idmap,
-				 const struct path *path,
-				 const char *xattr_name, struct file *file)
+static int ima_path_removexattr(const struct mnt_idmap *idmap,
+				const struct path *path,
+				const char *xattr_name, struct file *file)
 {
 	int result, digsig = -1;
 
@@ -832,9 +832,9 @@ static int ima_inode_remove_acl(const struct mnt_idmap *idmap,
 
 static struct security_hook_list ima_appraise_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(inode_post_setattr, ima_inode_post_setattr),
-	LSM_HOOK_INIT(inode_setxattr, ima_inode_setxattr),
+	LSM_HOOK_INIT(path_setxattr, ima_path_setxattr),
 	LSM_HOOK_INIT(inode_set_acl, ima_inode_set_acl),
-	LSM_HOOK_INIT(inode_removexattr, ima_inode_removexattr),
+	LSM_HOOK_INIT(path_removexattr, ima_path_removexattr),
 	LSM_HOOK_INIT(inode_remove_acl, ima_inode_remove_acl),
 };
 
diff --git a/security/security.c b/security/security.c
index 01d4a463c6b1..bca46f5444bd 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1921,7 +1921,7 @@ int security_path_getattr(const struct path *path, struct file *file)
 }
 
 /**
- * security_inode_setxattr() - Check if setting file xattrs is allowed
+ * security_path_setxattr() - Check if setting file xattrs is allowed
  * @idmap: idmap of the mount
  * @path: file (the VFS makes no guarantees with regard to @path->mnt)
  * @name: xattr name
@@ -1947,10 +1947,10 @@ int security_path_getattr(const struct path *path, struct file *file)
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_setxattr(const struct mnt_idmap *idmap,
-			    const struct path *path, const char *name,
-			    const void *value, size_t size, int flags,
-			    struct file *file)
+int security_path_setxattr(const struct mnt_idmap *idmap,
+			   const struct path *path, const char *name,
+			   const void *value, size_t size, int flags,
+			   struct file *file)
 {
 	int rc;
 
@@ -1964,7 +1964,7 @@ int security_inode_setxattr(const struct mnt_idmap *idmap,
 			return rc;
 	}
 
-	return call_int_hook(inode_setxattr, idmap, path, name, value,
+	return call_int_hook(path_setxattr, idmap, path, name, value,
 			     size, flags, file);
 }
 
@@ -2086,7 +2086,7 @@ void security_inode_post_setxattr(struct dentry *dentry, const char *name,
 }
 
 /**
- * security_inode_getxattr() - Check if xattr access is allowed
+ * security_path_getxattr() - Check if xattr access is allowed
  * @path: file (the VFS makes no guarantees with regard to @path->mnt)
  * @name: xattr name
  * @file: file through which the xattr access is requested, if any
@@ -2096,16 +2096,16 @@ void security_inode_post_setxattr(struct dentry *dentry, const char *name,
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_getxattr(const struct path *path,
-			    const char *name, struct file *file)
+int security_path_getxattr(const struct path *path,
+			   const char *name, struct file *file)
 {
 	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_getxattr, path, name, file);
+	return call_int_hook(path_getxattr, path, name, file);
 }
 
 /**
- * security_inode_listxattr() - Check if listing xattrs is allowed
+ * security_path_listxattr() - Check if listing xattrs is allowed
  * @path: file (the VFS makes no guarantees with regard to @path->mnt)
  * @file: file through which the xattr names are listed, if any
  *
@@ -2114,15 +2114,16 @@ int security_inode_getxattr(const struct path *path,
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_listxattr(const struct path *path, struct file *file)
+int security_path_listxattr(const struct path *path,
+			    struct file *file)
 {
 	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_listxattr, path, file);
+	return call_int_hook(path_listxattr, path, file);
 }
 
 /**
- * security_inode_removexattr() - Check if removing an xattr is allowed
+ * security_path_removexattr() - Check if removing an xattr is allowed
  * @idmap: idmap of the mount
  * @path: file (the VFS makes no guarantees with regard to @path->mnt)
  * @name: xattr name
@@ -2145,9 +2146,9 @@ int security_inode_listxattr(const struct path *path, struct file *file)
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_removexattr(const struct mnt_idmap *idmap,
-			       const struct path *path, const char *name,
-			       struct file *file)
+int security_path_removexattr(const struct mnt_idmap *idmap,
+			      const struct path *path, const char *name,
+			      struct file *file)
 {
 	int rc;
 
@@ -2161,7 +2162,7 @@ int security_inode_removexattr(const struct mnt_idmap *idmap,
 			return rc;
 	}
 
-	return call_int_hook(inode_removexattr, idmap, path, name, file);
+	return call_int_hook(path_removexattr, idmap, path, name, file);
 }
 
 /**
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 4751e300bde6..62053a9f7d9e 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3389,8 +3389,8 @@ static int selinux_inode_xattr_skipcap(const char *name)
 	return !strcmp(name, XATTR_NAME_SELINUX);
 }
 
-static int selinux_inode_setxattr(const struct mnt_idmap *idmap,
-				  const struct path *path,
+static int selinux_path_setxattr(const struct mnt_idmap *idmap,
+				 const struct path *path,
 				  const char *name, const void *value,
 				  size_t size, int flags, struct file *file)
 {
@@ -3539,24 +3539,25 @@ static void selinux_inode_post_setxattr(struct dentry *dentry, const char *name,
 	spin_unlock(&isec->lock);
 }
 
-static int selinux_inode_getxattr(const struct path *path,
-				  const char *name, struct file *file)
+static int selinux_path_getxattr(const struct path *path, const char *name,
+				 struct file *file)
 {
 	const struct cred *cred = current_cred();
 
 	return dentry_has_perm(cred, path->dentry, FILE__GETATTR);
 }
 
-static int selinux_inode_listxattr(const struct path *path, struct file *file)
+static int selinux_path_listxattr(const struct path *path,
+				  struct file *file)
 {
 	const struct cred *cred = current_cred();
 
 	return dentry_has_perm(cred, path->dentry, FILE__GETATTR);
 }
 
-static int selinux_inode_removexattr(const struct mnt_idmap *idmap,
-				     const struct path *path,
-				     const char *name, struct file *file)
+static int selinux_path_removexattr(const struct mnt_idmap *idmap,
+				    const struct path *path,
+				    const char *name, struct file *file)
 {
 	/* if not a selinux xattr, only check the ordinary setattr perm */
 	if (strcmp(name, XATTR_NAME_SELINUX))
@@ -3636,7 +3637,7 @@ static int selinux_path_notify(const struct path *path, u64 mask,
 /*
  * Copy the inode security context value to the user.
  *
- * Permission check is handled by selinux_inode_getxattr hook.
+ * Permission check is handled by selinux_path_getxattr hook.
  */
 static int selinux_inode_getsecurity(const struct mnt_idmap *idmap,
 				     struct inode *inode, const char *name,
@@ -7737,11 +7738,11 @@ static struct security_hook_list selinux_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(path_setattr, selinux_path_setattr),
 	LSM_HOOK_INIT(path_getattr, selinux_path_getattr),
 	LSM_HOOK_INIT(inode_xattr_skipcap, selinux_inode_xattr_skipcap),
-	LSM_HOOK_INIT(inode_setxattr, selinux_inode_setxattr),
+	LSM_HOOK_INIT(path_setxattr, selinux_path_setxattr),
 	LSM_HOOK_INIT(inode_post_setxattr, selinux_inode_post_setxattr),
-	LSM_HOOK_INIT(inode_getxattr, selinux_inode_getxattr),
-	LSM_HOOK_INIT(inode_listxattr, selinux_inode_listxattr),
-	LSM_HOOK_INIT(inode_removexattr, selinux_inode_removexattr),
+	LSM_HOOK_INIT(path_getxattr, selinux_path_getxattr),
+	LSM_HOOK_INIT(path_listxattr, selinux_path_listxattr),
+	LSM_HOOK_INIT(path_removexattr, selinux_path_removexattr),
 	LSM_HOOK_INIT(inode_file_getattr, selinux_inode_file_getattr),
 	LSM_HOOK_INIT(inode_file_setattr, selinux_inode_file_setattr),
 	LSM_HOOK_INIT(inode_set_acl, selinux_inode_set_acl),
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 1cbcba3fa62b..eed06cf7af99 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1343,7 +1343,7 @@ static int smack_inode_xattr_skipcap(const char *name)
 }
 
 /**
- * smack_inode_setxattr - Smack check for setting xattrs
+ * smack_path_setxattr - Smack check for setting xattrs
  * @idmap: idmap of the mount
  * @path: the object
  * @name: name of the attribute
@@ -1356,8 +1356,8 @@ static int smack_inode_xattr_skipcap(const char *name)
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_setxattr(const struct mnt_idmap *idmap,
-				const struct path *path,
+static int smack_path_setxattr(const struct mnt_idmap *idmap,
+			       const struct path *path,
 				const char *name, const void *value,
 				size_t size, int flags, struct file *file)
 {
@@ -1463,15 +1463,15 @@ static void smack_inode_post_setxattr(struct dentry *dentry, const char *name,
 }
 
 /**
- * smack_inode_getxattr - Smack check on getxattr
+ * smack_path_getxattr - Smack check on getxattr
  * @path: the object
  * @name: unused
  * @file: file through which the xattr access is requested, if any
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_getxattr(const struct path *path,
-			const char *name, struct file *file)
+static int smack_path_getxattr(const struct path *path, const char *name,
+			       struct file *file)
 {
 	struct smk_audit_info ad;
 	struct dentry *dentry = path->dentry;
@@ -1486,7 +1486,7 @@ static int smack_inode_getxattr(const struct path *path,
 }
 
 /**
- * smack_inode_removexattr - Smack check on removexattr
+ * smack_path_removexattr - Smack check on removexattr
  * @idmap: idmap of the mount
  * @path: the object
  * @name: name of the attribute
@@ -1496,9 +1496,9 @@ static int smack_inode_getxattr(const struct path *path,
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_removexattr(const struct mnt_idmap *idmap,
-				   const struct path *path,
-				   const char *name, struct file *file)
+static int smack_path_removexattr(const struct mnt_idmap *idmap,
+				  const struct path *path,
+				  const char *name, struct file *file)
 {
 	struct inode_smack *isp;
 	struct smk_audit_info ad;
@@ -5201,10 +5201,10 @@ static struct security_hook_list smack_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(path_setattr, smack_path_setattr),
 	LSM_HOOK_INIT(path_getattr, smack_path_getattr),
 	LSM_HOOK_INIT(inode_xattr_skipcap, smack_inode_xattr_skipcap),
-	LSM_HOOK_INIT(inode_setxattr, smack_inode_setxattr),
+	LSM_HOOK_INIT(path_setxattr, smack_path_setxattr),
 	LSM_HOOK_INIT(inode_post_setxattr, smack_inode_post_setxattr),
-	LSM_HOOK_INIT(inode_getxattr, smack_inode_getxattr),
-	LSM_HOOK_INIT(inode_removexattr, smack_inode_removexattr),
+	LSM_HOOK_INIT(path_getxattr, smack_path_getxattr),
+	LSM_HOOK_INIT(path_removexattr, smack_path_removexattr),
 	LSM_HOOK_INIT(inode_set_acl, smack_inode_set_acl),
 	LSM_HOOK_INIT(inode_get_acl, smack_inode_get_acl),
 	LSM_HOOK_INIT(inode_remove_acl, smack_inode_remove_acl),
diff --git a/tools/testing/selftests/bpf/prog_tests/fs_kfuncs.c b/tools/testing/selftests/bpf/prog_tests/fs_kfuncs.c
index 43a26ec69a8e..5145b1f03cac 100644
--- a/tools/testing/selftests/bpf/prog_tests/fs_kfuncs.c
+++ b/tools/testing/selftests/bpf/prog_tests/fs_kfuncs.c
@@ -53,7 +53,7 @@ static void test_get_xattr(const char *name, const char *value, bool allow_acces
 	if (!ASSERT_GE(fd, 0, "open_file"))
 		goto out;
 
-	/* Trigger security_inode_getxattr */
+	/* Trigger security_path_getxattr */
 	err = getxattr(testfile, name, v, sizeof(v));
 
 	if (allow_access) {
@@ -148,13 +148,13 @@ static void test_set_remove_xattr(void)
 
 	/* First, test not _locked version of the kfuncs with getxattr. */
 
-	/* Read security.bpf.foo and trigger test_inode_getxattr. This
+	/* Read security.bpf.foo and trigger test_path_getxattr. This
 	 * bpf program will set security.bpf.bar to "world".
 	 */
 	read_and_validate_foo(skel);
 	validate_bar_match(skel);
 
-	/* Read security.bpf.foo and trigger test_inode_getxattr again.
+	/* Read security.bpf.foo and trigger test_path_getxattr again.
 	 * This will remove xattr security.bpf.bar.
 	 */
 	read_and_validate_foo(skel);
@@ -167,13 +167,13 @@ static void test_set_remove_xattr(void)
 
 	/* Second, test _locked version of the kfuncs, with setxattr */
 
-	/* Set security.bpf.foo and trigger test_inode_setxattr. This
+	/* Set security.bpf.foo and trigger test_path_setxattr. This
 	 * bpf program will set security.bpf.bar to "world".
 	 */
 	set_foo(skel);
 	validate_bar_match(skel);
 
-	/* Set security.bpf.foo and trigger test_inode_setxattr again.
+	/* Set security.bpf.foo and trigger test_path_setxattr again.
 	 * This will remove xattr security.bpf.bar.
 	 */
 	set_foo(skel);
diff --git a/tools/testing/selftests/bpf/progs/test_get_xattr.c b/tools/testing/selftests/bpf/progs/test_get_xattr.c
index 97361ff10e9f..c6bde355b58f 100644
--- a/tools/testing/selftests/bpf/progs/test_get_xattr.c
+++ b/tools/testing/selftests/bpf/progs/test_get_xattr.c
@@ -55,8 +55,8 @@ int BPF_PROG(test_file_open, struct file *f)
 	return 0;
 }
 
-SEC("lsm.s/inode_getxattr")
-int BPF_PROG(test_inode_getxattr, const struct path *path, char *name,
+SEC("lsm.s/path_getxattr")
+int BPF_PROG(test_path_getxattr, const struct path *path, char *name,
 	     struct file *file)
 {
 	struct bpf_dynptr value_ptr;
diff --git a/tools/testing/selftests/bpf/progs/test_set_remove_xattr.c b/tools/testing/selftests/bpf/progs/test_set_remove_xattr.c
index 06656ac9a777..d096b00cf3bf 100644
--- a/tools/testing/selftests/bpf/progs/test_set_remove_xattr.c
+++ b/tools/testing/selftests/bpf/progs/test_set_remove_xattr.c
@@ -32,8 +32,8 @@ static inline bool name_match_foo(const char *name)
 }
 
 /* Test bpf_set_dentry_xattr and bpf_remove_dentry_xattr */
-SEC("lsm.s/inode_getxattr")
-int BPF_PROG(test_inode_getxattr, const struct path *path, char *name,
+SEC("lsm.s/path_getxattr")
+int BPF_PROG(test_path_getxattr, const struct path *path, char *name,
 	     struct file *file)
 {
 	struct bpf_dynptr value_ptr;
@@ -87,8 +87,8 @@ bool locked_remove_security_selinux_fail;
  * not-_locked version in the BPF program. The verifier will fix them up
  * properly.
  */
-SEC("lsm.s/inode_setxattr")
-int BPF_PROG(test_inode_setxattr, const struct mnt_idmap *idmap,
+SEC("lsm.s/path_setxattr")
+int BPF_PROG(test_path_setxattr, const struct mnt_idmap *idmap,
 	     const struct path *path,
 	     const char *name, const void *value, size_t size, int flags,
 	     struct file *file)
diff --git a/tools/testing/selftests/bpf/progs/verifier_lsm_init_xattr.c b/tools/testing/selftests/bpf/progs/verifier_lsm_init_xattr.c
index 9b7a15c1862f..bc728fdd0b0f 100644
--- a/tools/testing/selftests/bpf/progs/verifier_lsm_init_xattr.c
+++ b/tools/testing/selftests/bpf/progs/verifier_lsm_init_xattr.c
@@ -232,7 +232,7 @@ int BPF_PROG(reject_lsm_cgroup, struct inode *inode, struct inode *dir,
 	return 0;
 }
 
-SEC("lsm/inode_setxattr")
+SEC("lsm/path_setxattr")
 __failure __msg("calling kernel function bpf_inode_init_xattr is not allowed")
 int BPF_PROG(reject_wrong_hook, const struct mnt_idmap *idmap,
 	     const struct path *path,
diff --git a/tools/testing/selftests/bpf/progs/verifier_vfs_reject.c b/tools/testing/selftests/bpf/progs/verifier_vfs_reject.c
index ed2bd2faebf3..f41750c3fc70 100644
--- a/tools/testing/selftests/bpf/progs/verifier_vfs_reject.c
+++ b/tools/testing/selftests/bpf/progs/verifier_vfs_reject.c
@@ -46,7 +46,7 @@ int BPF_PROG(get_task_exe_file_kfunc_null)
 	return 0;
 }
 
-SEC("lsm.s/inode_getxattr")
+SEC("lsm.s/path_getxattr")
 __failure __msg("R1 type=fp expected=ptr_, trusted_ptr_, rcu_ptr_")
 int BPF_PROG(get_task_exe_file_kfunc_fp)
 {
-- 
2.18.0.huawei.25

