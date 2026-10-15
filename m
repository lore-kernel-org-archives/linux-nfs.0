Received: from canpmsgout09.his.huawei.com (canpmsgout09.his.huawei.com [113.46.200.224])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 05C675226BF;
	Thu, 15 Oct 2026 12:20:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.224
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792066848; cv=none; b=nfl34p9kSUJ31JbrSOS73MzWhWHDJKM5f49eYM99h2DdsumhtIikrO1BnxZ6dHyFG3NBICggTL8r/fJeYK/cStAfbFwZtgUH/qB2zso11tX73IKgk8bGyFK3W2B1WpPP0WL6u1jbmCn5hBeI17D4BnhTP86cZ7IxFtTAAtzI2Jc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792066848; c=relaxed/simple;
	bh=2bxLdI6VOiJt0xn3o9lGFQxHplhhvPNt15X+fhAvhzA=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=dhKq5W2ezZwvX7wBPxYZx7+9edG0R1EoSLZSGeaJ/m1IH0xzhKbEY6pA8lXZyuNlB49LNfC39OdfaLMOW7PQ/TrF1ZDR6gNLCNwSFUWlTw7zDX23lpIkenu58zXGLoawr8i28sLIO2H9cYu1XdTsoQwqaowGbrMkbfGwjac7O/Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=r7+PUcnv; arc=none smtp.client-ip=113.46.200.224
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="r7+PUcnv"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=qngDhSmNmuWNxbBpTxfWuO1dG6ZIIlZ/T8uTgHJAqlQ=;
	b=r7+PUcnvMytPCWNm1UDtHlTaKqL9YLAHolVVUhBH601rygyggvPn4GgryzBAJ6bbosYOlUDcv
	htBMTKlLLolFe98b8q33ala4Mi55H5jhaRJqMZNdlYoMXtOzns4CYqdfCmKYtgpMbzKBehO9rqR
	EG5yEegC00+1OxpqCJdW4tA=
Received: from mail.maildlp.com (unknown [172.19.163.127])
	by canpmsgout09.his.huawei.com (SkyGuard) with ESMTPS id 4j56Ls2TnJz1cyPY;
	Thu, 15 Oct 2026 20:09:25 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 58B1F40572;
	Thu, 15 Oct 2026 20:20:41 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 15 Oct 2026 20:20:36 +0800
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
Subject: [PATCH v2 -next 11/18] LSM: rename inode_setattr to path_setattr
Date: Thu, 15 Oct 2026 20:54:17 +0800
Message-ID: <20261015125425.3246251-12-caixinchen1@huawei.com>
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

The inode_setattr hook receives a struct path, so rename it to
path_setattr to follow the path_* naming convention used for the
other hooks that take a struct path (path_chmod, path_chown, ...).
Rename the security_inode_setattr() inline wrapper to
security_path_setattr() and the SELinux, Smack, EVM and Landlock
implementations accordingly.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/attr.c                         | 4 ++--
 fs/bpf_fs_kfuncs.c                | 2 +-
 fs/exfat/file.c                   | 2 +-
 fs/fat/file.c                     | 2 +-
 include/linux/lsm_hook_defs.h     | 2 +-
 include/linux/security.h          | 4 ++--
 kernel/bpf/bpf_lsm.c              | 2 +-
 security/integrity/evm/evm_main.c | 6 +++---
 security/landlock/fs.c            | 4 ++--
 security/security.c               | 8 ++++----
 security/selinux/hooks.c          | 4 ++--
 security/smack/smack_lsm.c        | 6 +++---
 12 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index 3a05e50d9c51..c8bf69e60971 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -518,7 +518,7 @@ static int do_notify_change(const struct path *const path,
 	 * filesystem, were already checked on the user-facing path.
 	 */
 	if (path) {
-		error = security_inode_setattr(path, attr);
+		error = security_path_setattr(path, attr);
 		if (error)
 			return error;
 	}
@@ -555,7 +555,7 @@ static int do_notify_change(const struct path *const path,
  * @attr:	new attributes
  * @delegated_inode: returns inode, if the inode is delegated
  *
- * Like notify_change(), but no security_inode_setattr() hook is called:
+ * Like notify_change(), but no security_path_setattr() hook is called:
  * this is the variant to use for internal forwards, where the LSM
  * checks were already performed on the user-facing path.
  *
diff --git a/fs/bpf_fs_kfuncs.c b/fs/bpf_fs_kfuncs.c
index 35ccd98a4de6..6500d8419bc1 100644
--- a/fs/bpf_fs_kfuncs.c
+++ b/fs/bpf_fs_kfuncs.c
@@ -568,7 +568,7 @@ BTF_ID(func, bpf_lsm_inode_post_setattr)
 BTF_ID(func, bpf_lsm_inode_post_setxattr)
 BTF_ID(func, bpf_lsm_inode_removexattr)
 BTF_ID(func, bpf_lsm_inode_rmdir)
-BTF_ID(func, bpf_lsm_inode_setattr)
+BTF_ID(func, bpf_lsm_path_setattr)
 BTF_ID(func, bpf_lsm_inode_setxattr)
 BTF_ID(func, bpf_lsm_inode_unlink)
 BTF_SET_END(d_inode_locked_hooks)
diff --git a/fs/exfat/file.c b/fs/exfat/file.c
index 0d431c0b595b..51ed20e27429 100644
--- a/fs/exfat/file.c
+++ b/fs/exfat/file.c
@@ -551,7 +551,7 @@ static int exfat_ioctl_set_attributes(struct file *file, u32 __user *user_attr)
 	 * out the RO attribute for checking by the security
 	 * module, just because it maps to a file mode.
 	 */
-	err = security_inode_setattr(&file->f_path, &ia);
+	err = security_path_setattr(&file->f_path, &ia);
 	if (err)
 		goto out_unlock_inode;
 
diff --git a/fs/fat/file.c b/fs/fat/file.c
index 4f8dbca28667..5178561906dd 100644
--- a/fs/fat/file.c
+++ b/fs/fat/file.c
@@ -92,7 +92,7 @@ static int fat_ioctl_set_attributes(struct file *file, u32 __user *user_attr)
 	 * out the RO attribute for checking by the security
 	 * module, just because it maps to a file mode.
 	 */
-	err = security_inode_setattr(&file->f_path, &ia);
+	err = security_path_setattr(&file->f_path, &ia);
 	if (err)
 		goto out_unlock_inode;
 
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index ea1df85b5fd4..b0dd9f4a6a38 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -142,7 +142,7 @@ LSM_HOOK(int, 0, inode_follow_link, struct dentry *dentry, struct inode *inode,
 	 bool rcu)
 LSM_HOOK(int, 0, inode_permission, const struct mnt_idmap *idmap,
 	 struct inode *inode, int mask)
-LSM_HOOK(int, 0, inode_setattr, const struct path *path,
+LSM_HOOK(int, 0, path_setattr, const struct path *path,
 	 struct iattr *attr)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_setattr, const struct mnt_idmap *idmap,
 	 struct dentry *dentry, int ia_valid)
diff --git a/include/linux/security.h b/include/linux/security.h
index 630a19a63291..340eb2d0c1a2 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -428,7 +428,7 @@ int security_inode_follow_link(struct dentry *dentry, struct inode *inode,
 			       bool rcu);
 int security_inode_permission(const struct mnt_idmap *idmap, struct inode *inode,
 			      int mask);
-int security_inode_setattr(const struct path *path, struct iattr *attr);
+int security_path_setattr(const struct path *path, struct iattr *attr);
 void security_inode_post_setattr(const struct mnt_idmap *idmap, struct dentry *dentry,
 				 int ia_valid);
 int security_path_getattr(const struct path *path);
@@ -996,7 +996,7 @@ static inline int security_inode_permission(const struct mnt_idmap *idmap,
 	return 0;
 }
 
-static inline int security_inode_setattr(const struct path *path,
+static inline int security_path_setattr(const struct path *path,
 					 struct iattr *attr)
 {
 	return 0;
diff --git a/kernel/bpf/bpf_lsm.c b/kernel/bpf/bpf_lsm.c
index 293f849879e2..32f84356933e 100644
--- a/kernel/bpf/bpf_lsm.c
+++ b/kernel/bpf/bpf_lsm.c
@@ -345,7 +345,7 @@ BTF_ID(func, bpf_lsm_inode_readlink)
 BTF_ID(func, bpf_lsm_inode_removexattr)
 BTF_ID(func, bpf_lsm_inode_rename)
 BTF_ID(func, bpf_lsm_inode_rmdir)
-BTF_ID(func, bpf_lsm_inode_setattr)
+BTF_ID(func, bpf_lsm_path_setattr)
 BTF_ID(func, bpf_lsm_inode_setxattr)
 BTF_ID(func, bpf_lsm_inode_symlink)
 BTF_ID(func, bpf_lsm_inode_unlink)
diff --git a/security/integrity/evm/evm_main.c b/security/integrity/evm/evm_main.c
index 0d8d82536151..a44776e5f1a7 100644
--- a/security/integrity/evm/evm_main.c
+++ b/security/integrity/evm/evm_main.c
@@ -951,14 +951,14 @@ static int evm_attr_change(const struct mnt_idmap *idmap,
 }
 
 /**
- * evm_inode_setattr - prevent updating an invalid EVM extended attribute
+ * evm_path_setattr - prevent updating an invalid EVM extended attribute
  * @path: pointer to the affected object
  * @attr: iattr structure containing the new file attributes
  *
  * Permit update of file attributes when files have a valid EVM signature,
  * except in the case of them having an immutable portable signature.
  */
-static int evm_inode_setattr(const struct path *path,
+static int evm_path_setattr(const struct path *path,
 			     struct iattr *attr)
 {
 	unsigned int ia_valid = attr->ia_valid;
@@ -1199,7 +1199,7 @@ static int __init init_evm(void)
 }
 
 static struct security_hook_list evm_hooks[] __ro_after_init = {
-	LSM_HOOK_INIT(inode_setattr, evm_inode_setattr),
+	LSM_HOOK_INIT(path_setattr, evm_path_setattr),
 	LSM_HOOK_INIT(inode_post_setattr, evm_inode_post_setattr),
 	LSM_HOOK_INIT(inode_copy_up_xattr, evm_inode_copy_up_xattr),
 	LSM_HOOK_INIT(inode_setxattr, evm_inode_setxattr),
diff --git a/security/landlock/fs.c b/security/landlock/fs.c
index 439a6159e24a..0ec923c9cbd9 100644
--- a/security/landlock/fs.c
+++ b/security/landlock/fs.c
@@ -1691,7 +1691,7 @@ static int hook_inode_file_getattr(const struct path *const path,
 					LANDLOCK_ACCESS_FS_READ_METADATA);
 }
 
-static int hook_inode_setattr(const struct path *const path,
+static int hook_path_setattr(const struct path *const path,
 			      struct iattr *const attr)
 {
 	unsigned int ia_valid = attr->ia_valid;
@@ -2217,7 +2217,7 @@ static struct security_hook_list landlock_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(path_truncate, hook_path_truncate),
 	LSM_HOOK_INIT(path_getattr, hook_path_getattr),
 	LSM_HOOK_INIT(inode_file_getattr, hook_inode_file_getattr),
-	LSM_HOOK_INIT(inode_setattr, hook_inode_setattr),
+	LSM_HOOK_INIT(path_setattr, hook_path_setattr),
 	LSM_HOOK_INIT(inode_file_setattr, hook_inode_file_setattr),
 	LSM_HOOK_INIT(inode_setxattr, hook_inode_setxattr),
 	LSM_HOOK_INIT(inode_getxattr, hook_inode_getxattr),
diff --git a/security/security.c b/security/security.c
index c7cb96db7299..f008f127b6f2 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1890,7 +1890,7 @@ int security_inode_permission(const struct mnt_idmap *idmap, struct inode *inode
 }
 
 /**
- * security_inode_setattr() - Check if setting file attributes is allowed
+ * security_path_setattr() - Check if setting file attributes is allowed
  * @path: file
  * @attr: new attributes
  *
@@ -1901,13 +1901,13 @@ int security_inode_permission(const struct mnt_idmap *idmap, struct inode *inode
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_setattr(const struct path *path, struct iattr *attr)
+int security_path_setattr(const struct path *path, struct iattr *attr)
 {
 	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_setattr, path, attr);
+	return call_int_hook(path_setattr, path, attr);
 }
-EXPORT_SYMBOL_GPL(security_inode_setattr);
+EXPORT_SYMBOL_GPL(security_path_setattr);
 
 /**
  * security_inode_post_setattr() - Update the inode after a setattr operation
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 93e3d9223e34..44c7fe660bdb 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3346,7 +3346,7 @@ static int selinux_inode_permission(const struct mnt_idmap *idmap,
 	return rc;
 }
 
-static int selinux_inode_setattr(const struct path *path,
+static int selinux_path_setattr(const struct path *path,
 				 struct iattr *iattr)
 {
 	const struct cred *cred = current_cred();
@@ -7755,7 +7755,7 @@ static struct security_hook_list selinux_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(inode_readlink, selinux_inode_readlink),
 	LSM_HOOK_INIT(inode_follow_link, selinux_inode_follow_link),
 	LSM_HOOK_INIT(inode_permission, selinux_inode_permission),
-	LSM_HOOK_INIT(inode_setattr, selinux_inode_setattr),
+	LSM_HOOK_INIT(path_setattr, selinux_path_setattr),
 	LSM_HOOK_INIT(path_getattr, selinux_path_getattr),
 	LSM_HOOK_INIT(inode_xattr_skipcap, selinux_inode_xattr_skipcap),
 	LSM_HOOK_INIT(inode_setxattr, selinux_inode_setxattr),
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 43b9877d6a00..2cf786ee3752 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1265,14 +1265,14 @@ static int smack_inode_permission(const struct mnt_idmap *idmap, struct inode *i
 }
 
 /**
- * smack_inode_setattr - Smack check for setting attributes
+ * smack_path_setattr - Smack check for setting attributes
  * @idmap: idmap of the mount
  * @dentry: the object
  * @iattr: for the force flag
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_setattr(const struct path *path,
+static int smack_path_setattr(const struct path *path,
 			       struct iattr *iattr)
 {
 	struct smk_audit_info ad;
@@ -5178,7 +5178,7 @@ static struct security_hook_list smack_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(inode_rmdir, smack_inode_rmdir),
 	LSM_HOOK_INIT(inode_rename, smack_inode_rename),
 	LSM_HOOK_INIT(inode_permission, smack_inode_permission),
-	LSM_HOOK_INIT(inode_setattr, smack_inode_setattr),
+	LSM_HOOK_INIT(path_setattr, smack_path_setattr),
 	LSM_HOOK_INIT(path_getattr, smack_path_getattr),
 	LSM_HOOK_INIT(inode_xattr_skipcap, smack_inode_xattr_skipcap),
 	LSM_HOOK_INIT(inode_setxattr, smack_inode_setxattr),
-- 
2.18.0.huawei.25

