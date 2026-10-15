Received: from canpmsgout03.his.huawei.com (canpmsgout03.his.huawei.com [113.46.200.218])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CB1225226AC;
	Thu, 15 Oct 2026 12:20:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.218
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792066856; cv=none; b=dASig2S93NDRFNWkcSkB3lo0NCfWFY3uPW66mUZnXGfhWknQ6ZKfp6Y8ek2DbPvyEsIGKzlKenpr/n2c00d2WQSv8plWbtYb7eOiNmgQU6TurK6wggcfTRL0Pqd+PnD00D7mj+LgfesqZye3nMsqn9Px4TgfvJQf7jjvIo+KhxE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792066856; c=relaxed/simple;
	bh=ZmnCl1JdZpg5Gni2PLPJ6dd3sCv4RI+1yEWdivoiXRI=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=SMFoWMZEOYdjb0UaPucm5y6h24mIBYd75af/6FIQQT66mRfjvs/A25YnoMWMvH7WdaeM9Ncue9qALncULdAR8KkPHfwngQjcQp2CeDhZNWU2Y1x+hi7LNJaPlZKGhKyrG2q4IRTAiRPvxf8xwL9PwkXTyLs0ZbPpA6k2XW5J5v0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=0att79FW; arc=none smtp.client-ip=113.46.200.218
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="0att79FW"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=zywXHsx69HeAuCIzXf/xi/eqFmbL5V4UnYEf6YJMcYQ=;
	b=0att79FWtjO/MVeqpBOLigbCzGcXyKZTznhEMFX9BP60CFiMwKwbllTgctC4U3maG5ml9QzqA
	hmPoES3izh28aL0vrdvO+kJCFT1Y0H1Mv7pJ69cqpJ6qOSr1fROD3ogczAVWBqYBB7F0lq2IKnG
	VBLSonCz1AtVfyUIlM1kxJI=
Received: from mail.maildlp.com (unknown [172.19.163.0])
	by canpmsgout03.his.huawei.com (SkyGuard) with ESMTPS id 4j56KP1CbtzpStW;
	Thu, 15 Oct 2026 20:08:09 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 50FBD40537;
	Thu, 15 Oct 2026 20:20:46 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 15 Oct 2026 20:20:41 +0800
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
Subject: [PATCH v2 -next 12/18] LSM: rename the inode xattr hooks to path_xattr hooks
Date: Thu, 15 Oct 2026 20:54:18 +0800
Message-ID: <20261015125425.3246251-13-caixinchen1@huawei.com>
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

The inode_setxattr, inode_getxattr, inode_listxattr and
inode_removexattr hooks receive a struct path, so rename them to
path_setxattr, path_getxattr, path_listxattr and path_removexattr to
follow the path_* naming convention used for the other hooks that
take a struct path (path_chmod, path_chown, ...).  Rename the
security_inode_*xattr() inline wrappers to security_path_*xattr()
and the SELinux, Smack, EVM, IMA and Landlock implementations
accordingly.  The inode_post_setxattr and inode_post_removexattr
notification hooks still take a dentry and keep their names.

BPF programs attach to LSM hooks by name ("lsm/inode_getxattr",
"lsm.s/inode_setxattr", ...), so update the BPF selftests to the new
names.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 Documentation/bpf/fs_kfuncs.rst               |  2 +-
 fs/bpf_fs_kfuncs.c                            |  4 ++--
 fs/overlayfs/inode.c                          |  2 +-
 fs/xattr.c                                    |  8 +++----
 include/linux/lsm_hook_defs.h                 |  8 +++----
 include/linux/security.h                      | 16 ++++++-------
 kernel/bpf/bpf_lsm.c                          |  6 ++---
 security/integrity/evm/evm_main.c             | 16 ++++++-------
 security/integrity/ima/ima_appraise.c         |  8 +++----
 security/landlock/fs.c                        | 16 ++++++-------
 security/security.c                           | 24 +++++++++----------
 security/selinux/hooks.c                      | 18 +++++++-------
 security/smack/smack_lsm.c                    | 18 +++++++-------
 .../selftests/bpf/prog_tests/fs_kfuncs.c      | 10 ++++----
 .../selftests/bpf/progs/test_get_xattr.c      |  4 ++--
 .../bpf/progs/test_set_remove_xattr.c         |  8 +++----
 .../bpf/progs/verifier_lsm_init_xattr.c       |  2 +-
 .../selftests/bpf/progs/verifier_vfs_reject.c |  2 +-
 18 files changed, 86 insertions(+), 86 deletions(-)

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
index f06e994e2e33..9e89aeabeaa8 100644
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
index f469a9464081..5e960f450488 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -307,7 +307,7 @@ __vfs_setxattr_locked(const struct path *path, const char *name,
 	if (error)
 		return error;
 
-	error = security_inode_setxattr(path, name, value, size,
+	error = security_path_setxattr(path, name, value, size,
 					flags);
 	if (error)
 		goto out;
@@ -463,7 +463,7 @@ vfs_getxattr(const struct path *path, const char *name, void *value,
 	if (error)
 		return error;
 
-	error = security_inode_getxattr(path, name);
+	error = security_path_getxattr(path, name);
 	if (error)
 		return error;
 
@@ -514,7 +514,7 @@ vfs_listxattr(const struct path *path, char *list, size_t size)
 	struct inode *inode = d_inode(dentry);
 	ssize_t error;
 
-	error = security_inode_listxattr(path);
+	error = security_path_listxattr(path);
 	if (error)
 		return error;
 
@@ -574,7 +574,7 @@ __vfs_removexattr_locked(const struct path *path, const char *name,
 	if (error)
 		return error;
 
-	error = security_inode_removexattr(path, name);
+	error = security_path_removexattr(path, name);
 	if (error)
 		goto out;
 
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index b0dd9f4a6a38..83b04d64a906 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -148,13 +148,13 @@ LSM_HOOK(void, LSM_RET_VOID, inode_post_setattr, const struct mnt_idmap *idmap,
 	 struct dentry *dentry, int ia_valid)
 LSM_HOOK(int, 0, path_getattr, const struct path *path)
 LSM_HOOK(int, 0, inode_xattr_skipcap, const char *name)
-LSM_HOOK(int, 0, inode_setxattr, const struct path *path,
+LSM_HOOK(int, 0, path_setxattr, const struct path *path,
 	 const char *name, const void *value, size_t size, int flags)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_setxattr, struct dentry *dentry,
 	 const char *name, const void *value, size_t size, int flags)
-LSM_HOOK(int, 0, inode_getxattr, const struct path *path, const char *name)
-LSM_HOOK(int, 0, inode_listxattr, const struct path *path)
-LSM_HOOK(int, 0, inode_removexattr, const struct path *path,
+LSM_HOOK(int, 0, path_getxattr, const struct path *path, const char *name)
+LSM_HOOK(int, 0, path_listxattr, const struct path *path)
+LSM_HOOK(int, 0, path_removexattr, const struct path *path,
 	 const char *name)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_removexattr, struct dentry *dentry,
 	 const char *name)
diff --git a/include/linux/security.h b/include/linux/security.h
index 340eb2d0c1a2..15a8bd6c16e5 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -432,7 +432,7 @@ int security_path_setattr(const struct path *path, struct iattr *attr);
 void security_inode_post_setattr(const struct mnt_idmap *idmap, struct dentry *dentry,
 				 int ia_valid);
 int security_path_getattr(const struct path *path);
-int security_inode_setxattr(const struct path *path,
+int security_path_setxattr(const struct path *path,
 			    const char *name, const void *value,
 			    size_t size, int flags);
 int security_inode_set_acl(const struct path *path,
@@ -446,9 +446,9 @@ void security_inode_post_remove_acl(const struct mnt_idmap *idmap,
 				    const char *acl_name);
 void security_inode_post_setxattr(struct dentry *dentry, const char *name,
 				  const void *value, size_t size, int flags);
-int security_inode_getxattr(const struct path *path, const char *name);
-int security_inode_listxattr(const struct path *path);
-int security_inode_removexattr(const struct path *path,
+int security_path_getxattr(const struct path *path, const char *name);
+int security_path_listxattr(const struct path *path);
+int security_path_removexattr(const struct path *path,
 			       const char *name);
 void security_inode_post_removexattr(struct dentry *dentry, const char *name);
 int security_inode_file_setattr(const struct path *path,
@@ -1012,7 +1012,7 @@ static inline int security_path_getattr(const struct path *path)
 	return 0;
 }
 
-static inline int security_inode_setxattr(const struct path *path,
+static inline int security_path_setxattr(const struct path *path,
 		const char *name, const void *value, size_t size, int flags)
 {
 	return cap_inode_setxattr(path, name, value, size, flags);
@@ -1051,18 +1051,18 @@ static inline void security_inode_post_setxattr(struct dentry *dentry,
 		const char *name, const void *value, size_t size, int flags)
 { }
 
-static inline int security_inode_getxattr(const struct path *path,
+static inline int security_path_getxattr(const struct path *path,
 			const char *name)
 {
 	return 0;
 }
 
-static inline int security_inode_listxattr(const struct path *path)
+static inline int security_path_listxattr(const struct path *path)
 {
 	return 0;
 }
 
-static inline int security_inode_removexattr(const struct path *path,
+static inline int security_path_removexattr(const struct path *path,
 					     const char *name)
 {
 	return cap_inode_removexattr(path, name);
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
index a44776e5f1a7..5d8fd1ee6a3b 100644
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
  * @path: pointer to the affected object
  * @xattr_name: pointer to the affected extended attribute name
  * @xattr_value: pointer to the new extended attribute value
@@ -606,7 +606,7 @@ static int evm_protect_xattr(const struct mnt_idmap *idmap,
  * userspace from writing HMAC value.  Writing 'security.evm' requires
  * requires CAP_SYS_ADMIN privileges.
  */
-static int evm_inode_setxattr(const struct path *path,
+static int evm_path_setxattr(const struct path *path,
 			      const char *xattr_name, const void *xattr_value,
 			      size_t xattr_value_len, int flags)
 {
@@ -632,14 +632,14 @@ static int evm_inode_setxattr(const struct path *path,
 }
 
 /**
- * evm_inode_removexattr - protect the EVM extended attribute
+ * evm_path_removexattr - protect the EVM extended attribute
  * @path: pointer to the affected object
  * @xattr_name: pointer to the affected extended attribute name
  *
  * Removing 'security.evm' requires CAP_SYS_ADMIN privileges and that
  * the current value is valid.
  */
-static int evm_inode_removexattr(const struct path *path,
+static int evm_path_removexattr(const struct path *path,
 				 const char *xattr_name)
 {
 	struct dentry *dentry = path->dentry;
@@ -1202,13 +1202,13 @@ static struct security_hook_list evm_hooks[] __ro_after_init = {
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
index 27b261a19900..3a6cb541ab32 100644
--- a/security/integrity/ima/ima_appraise.c
+++ b/security/integrity/ima/ima_appraise.c
@@ -759,7 +759,7 @@ static int validate_hash_algo(struct dentry *dentry,
 	return -EACCES;
 }
 
-static int ima_inode_setxattr(const struct path *path,
+static int ima_path_setxattr(const struct path *path,
 			      const char *xattr_name, const void *xattr_value,
 			      size_t xattr_value_len, int flags)
 {
@@ -802,7 +802,7 @@ static int ima_inode_set_acl(const struct path *path,
 	return 0;
 }
 
-static int ima_inode_removexattr(const struct path *path,
+static int ima_path_removexattr(const struct path *path,
 				 const char *xattr_name)
 {
 	int result, digsig = -1;
@@ -826,9 +826,9 @@ static int ima_inode_remove_acl(const struct path *path,
 
 static struct security_hook_list ima_appraise_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(inode_post_setattr, ima_inode_post_setattr),
-	LSM_HOOK_INIT(inode_setxattr, ima_inode_setxattr),
+	LSM_HOOK_INIT(path_setxattr, ima_path_setxattr),
 	LSM_HOOK_INIT(inode_set_acl, ima_inode_set_acl),
-	LSM_HOOK_INIT(inode_removexattr, ima_inode_removexattr),
+	LSM_HOOK_INIT(path_removexattr, ima_path_removexattr),
 	LSM_HOOK_INIT(inode_remove_acl, ima_inode_remove_acl),
 };
 
diff --git a/security/landlock/fs.c b/security/landlock/fs.c
index 0ec923c9cbd9..33bca2d878c8 100644
--- a/security/landlock/fs.c
+++ b/security/landlock/fs.c
@@ -1740,7 +1740,7 @@ static int hook_inode_file_setattr(const struct path *const path,
 					LANDLOCK_ACCESS_FS_WRITE_METADATA);
 }
 
-static int hook_inode_setxattr(const struct path *const path,
+static int hook_path_setxattr(const struct path *const path,
 			       const char *const name,
 			       const void *const value, const size_t size,
 			       const int flags)
@@ -1749,20 +1749,20 @@ static int hook_inode_setxattr(const struct path *const path,
 					LANDLOCK_ACCESS_FS_WRITE_METADATA);
 }
 
-static int hook_inode_getxattr(const struct path *const path,
+static int hook_path_getxattr(const struct path *const path,
 			       const char *const name)
 {
 	return current_check_access_path(path,
 					LANDLOCK_ACCESS_FS_READ_METADATA);
 }
 
-static int hook_inode_listxattr(const struct path *const path)
+static int hook_path_listxattr(const struct path *const path)
 {
 	return current_check_access_path(path,
 					LANDLOCK_ACCESS_FS_READ_METADATA);
 }
 
-static int hook_inode_removexattr(const struct path *const path,
+static int hook_path_removexattr(const struct path *const path,
 				  const char *const name)
 {
 	return current_check_access_path(path,
@@ -2219,10 +2219,10 @@ static struct security_hook_list landlock_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(inode_file_getattr, hook_inode_file_getattr),
 	LSM_HOOK_INIT(path_setattr, hook_path_setattr),
 	LSM_HOOK_INIT(inode_file_setattr, hook_inode_file_setattr),
-	LSM_HOOK_INIT(inode_setxattr, hook_inode_setxattr),
-	LSM_HOOK_INIT(inode_getxattr, hook_inode_getxattr),
-	LSM_HOOK_INIT(inode_listxattr, hook_inode_listxattr),
-	LSM_HOOK_INIT(inode_removexattr, hook_inode_removexattr),
+	LSM_HOOK_INIT(path_setxattr, hook_path_setxattr),
+	LSM_HOOK_INIT(path_getxattr, hook_path_getxattr),
+	LSM_HOOK_INIT(path_listxattr, hook_path_listxattr),
+	LSM_HOOK_INIT(path_removexattr, hook_path_removexattr),
 	LSM_HOOK_INIT(inode_set_acl, hook_inode_set_acl),
 	LSM_HOOK_INIT(inode_get_acl, hook_inode_get_acl),
 	LSM_HOOK_INIT(inode_remove_acl, hook_inode_remove_acl),
diff --git a/security/security.c b/security/security.c
index f008f127b6f2..98930f0b3b60 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1941,7 +1941,7 @@ int security_path_getattr(const struct path *path)
 }
 
 /**
- * security_inode_setxattr() - Check if setting file xattrs is allowed
+ * security_path_setxattr() - Check if setting file xattrs is allowed
  * @path: file
  * @name: xattr name
  * @value: xattr value
@@ -1965,7 +1965,7 @@ int security_path_getattr(const struct path *path)
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_setxattr(const struct path *path,
+int security_path_setxattr(const struct path *path,
 			    const char *name, const void *value,
 			    size_t size, int flags)
 {
@@ -1981,7 +1981,7 @@ int security_inode_setxattr(const struct path *path,
 			return rc;
 	}
 
-	return call_int_hook(inode_setxattr, path, name, value, size,
+	return call_int_hook(path_setxattr, path, name, value, size,
 			     flags);
 }
 
@@ -2091,7 +2091,7 @@ void security_inode_post_setxattr(struct dentry *dentry, const char *name,
 }
 
 /**
- * security_inode_getxattr() - Check if xattr access is allowed
+ * security_path_getxattr() - Check if xattr access is allowed
  * @path: file
  * @name: xattr name
  *
@@ -2100,15 +2100,15 @@ void security_inode_post_setxattr(struct dentry *dentry, const char *name,
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_getxattr(const struct path *path, const char *name)
+int security_path_getxattr(const struct path *path, const char *name)
 {
 	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_getxattr, path, name);
+	return call_int_hook(path_getxattr, path, name);
 }
 
 /**
- * security_inode_listxattr() - Check if listing xattrs is allowed
+ * security_path_listxattr() - Check if listing xattrs is allowed
  * @path: file
  *
  * Check permission before obtaining the list of extended attribute names for
@@ -2116,15 +2116,15 @@ int security_inode_getxattr(const struct path *path, const char *name)
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_listxattr(const struct path *path)
+int security_path_listxattr(const struct path *path)
 {
 	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_listxattr, path);
+	return call_int_hook(path_listxattr, path);
 }
 
 /**
- * security_inode_removexattr() - Check if removing an xattr is allowed
+ * security_path_removexattr() - Check if removing an xattr is allowed
  * @path: file
  * @name: xattr name
  *
@@ -2145,7 +2145,7 @@ int security_inode_listxattr(const struct path *path)
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_removexattr(const struct path *path, const char *name)
+int security_path_removexattr(const struct path *path, const char *name)
 {
 	int rc;
 
@@ -2159,7 +2159,7 @@ int security_inode_removexattr(const struct path *path, const char *name)
 			return rc;
 	}
 
-	return call_int_hook(inode_removexattr, path, name);
+	return call_int_hook(path_removexattr, path, name);
 }
 
 /**
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 44c7fe660bdb..9b2e0f38bf2c 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3417,7 +3417,7 @@ static int selinux_inode_xattr_skipcap(const char *name)
 	return !strcmp(name, XATTR_NAME_SELINUX);
 }
 
-static int selinux_inode_setxattr(const struct path *path,
+static int selinux_path_setxattr(const struct path *path,
 				  const char *name, const void *value,
 				  size_t size, int flags)
 {
@@ -3563,21 +3563,21 @@ static void selinux_inode_post_setxattr(struct dentry *dentry, const char *name,
 	spin_unlock(&isec->lock);
 }
 
-static int selinux_inode_getxattr(const struct path *path, const char *name)
+static int selinux_path_getxattr(const struct path *path, const char *name)
 {
 	const struct cred *cred = current_cred();
 
 	return dentry_has_perm(cred, path->dentry, FILE__GETATTR);
 }
 
-static int selinux_inode_listxattr(const struct path *path)
+static int selinux_path_listxattr(const struct path *path)
 {
 	const struct cred *cred = current_cred();
 
 	return dentry_has_perm(cred, path->dentry, FILE__GETATTR);
 }
 
-static int selinux_inode_removexattr(const struct path *path,
+static int selinux_path_removexattr(const struct path *path,
 				     const char *name)
 {
 	/* if not a selinux xattr, only check the ordinary setattr perm */
@@ -3656,7 +3656,7 @@ static int selinux_path_notify(const struct path *path, u64 mask,
 /*
  * Copy the inode security context value to the user.
  *
- * Permission check is handled by selinux_inode_getxattr hook.
+ * Permission check is handled by selinux_path_getxattr hook.
  */
 static int selinux_inode_getsecurity(const struct mnt_idmap *idmap,
 				     struct inode *inode, const char *name,
@@ -7758,11 +7758,11 @@ static struct security_hook_list selinux_hooks[] __ro_after_init = {
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
index 2cf786ee3752..95799afbb5c9 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1339,7 +1339,7 @@ static int smack_inode_xattr_skipcap(const char *name)
 }
 
 /**
- * smack_inode_setxattr - Smack check for setting xattrs
+ * smack_path_setxattr - Smack check for setting xattrs
  * @idmap: idmap of the mount
  * @dentry: the object
  * @name: name of the attribute
@@ -1351,7 +1351,7 @@ static int smack_inode_xattr_skipcap(const char *name)
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_setxattr(const struct path *path,
+static int smack_path_setxattr(const struct path *path,
 				const char *name, const void *value,
 				size_t size, int flags)
 {
@@ -1457,13 +1457,13 @@ static void smack_inode_post_setxattr(struct dentry *dentry, const char *name,
 }
 
 /**
- * smack_inode_getxattr - Smack check on getxattr
+ * smack_path_getxattr - Smack check on getxattr
  * @dentry: the object
  * @name: unused
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_getxattr(const struct path *path, const char *name)
+static int smack_path_getxattr(const struct path *path, const char *name)
 {
 	struct smk_audit_info ad;
 	struct dentry *dentry = path->dentry;
@@ -1478,7 +1478,7 @@ static int smack_inode_getxattr(const struct path *path, const char *name)
 }
 
 /**
- * smack_inode_removexattr - Smack check on removexattr
+ * smack_path_removexattr - Smack check on removexattr
  * @path: the object
  * @name: name of the attribute
  *
@@ -1486,7 +1486,7 @@ static int smack_inode_getxattr(const struct path *path, const char *name)
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_removexattr(const struct path *path,
+static int smack_path_removexattr(const struct path *path,
 				   const char *name)
 {
 	struct inode_smack *isp;
@@ -5181,10 +5181,10 @@ static struct security_hook_list smack_hooks[] __ro_after_init = {
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
index 5c49c3ab2e69..eea89016f96f 100644
--- a/tools/testing/selftests/bpf/progs/test_get_xattr.c
+++ b/tools/testing/selftests/bpf/progs/test_get_xattr.c
@@ -55,8 +55,8 @@ int BPF_PROG(test_file_open, struct file *f)
 	return 0;
 }
 
-SEC("lsm.s/inode_getxattr")
-int BPF_PROG(test_inode_getxattr, const struct path *path, char *name)
+SEC("lsm.s/path_getxattr")
+int BPF_PROG(test_path_getxattr, const struct path *path, char *name)
 {
 	struct bpf_dynptr value_ptr;
 	__u32 pid;
diff --git a/tools/testing/selftests/bpf/progs/test_set_remove_xattr.c b/tools/testing/selftests/bpf/progs/test_set_remove_xattr.c
index 006c97eee80e..f7438081d630 100644
--- a/tools/testing/selftests/bpf/progs/test_set_remove_xattr.c
+++ b/tools/testing/selftests/bpf/progs/test_set_remove_xattr.c
@@ -32,8 +32,8 @@ static inline bool name_match_foo(const char *name)
 }
 
 /* Test bpf_set_dentry_xattr and bpf_remove_dentry_xattr */
-SEC("lsm.s/inode_getxattr")
-int BPF_PROG(test_inode_getxattr, const struct path *path, char *name)
+SEC("lsm.s/path_getxattr")
+int BPF_PROG(test_path_getxattr, const struct path *path, char *name)
 {
 	struct bpf_dynptr value_ptr;
 	__u32 pid;
@@ -86,8 +86,8 @@ bool locked_remove_security_selinux_fail;
  * not-_locked version in the BPF program. The verifier will fix them up
  * properly.
  */
-SEC("lsm.s/inode_setxattr")
-int BPF_PROG(test_inode_setxattr, const struct path *path,
+SEC("lsm.s/path_setxattr")
+int BPF_PROG(test_path_setxattr, const struct path *path,
 	     const char *name, const void *value, size_t size, int flags)
 {
 	struct bpf_dynptr value_ptr;
diff --git a/tools/testing/selftests/bpf/progs/verifier_lsm_init_xattr.c b/tools/testing/selftests/bpf/progs/verifier_lsm_init_xattr.c
index ef170366dc04..a9b09e559d7e 100644
--- a/tools/testing/selftests/bpf/progs/verifier_lsm_init_xattr.c
+++ b/tools/testing/selftests/bpf/progs/verifier_lsm_init_xattr.c
@@ -232,7 +232,7 @@ int BPF_PROG(reject_lsm_cgroup, struct inode *inode, struct inode *dir,
 	return 0;
 }
 
-SEC("lsm/inode_setxattr")
+SEC("lsm/path_setxattr")
 __failure __msg("calling kernel function bpf_inode_init_xattr is not allowed")
 int BPF_PROG(reject_wrong_hook, const struct path *path,
 	     const char *name, const void *value, size_t size, int flags)
diff --git a/tools/testing/selftests/bpf/progs/verifier_vfs_reject.c b/tools/testing/selftests/bpf/progs/verifier_vfs_reject.c
index b5f456d57669..1337effeb46b 100644
--- a/tools/testing/selftests/bpf/progs/verifier_vfs_reject.c
+++ b/tools/testing/selftests/bpf/progs/verifier_vfs_reject.c
@@ -27,7 +27,7 @@ int BPF_PROG(get_task_exe_file_kfunc_null)
 	return 0;
 }
 
-SEC("lsm.s/inode_getxattr")
+SEC("lsm.s/path_getxattr")
 __failure __msg("R1 type=fp expected=ptr_, trusted_ptr_, rcu_ptr_")
 int BPF_PROG(get_task_exe_file_kfunc_fp)
 {
-- 
2.18.0.huawei.25

