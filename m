Received: from canpmsgout05.his.huawei.com (canpmsgout05.his.huawei.com [113.46.200.220])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99641523784;
	Thu, 15 Oct 2026 12:20:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.220
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792066857; cv=none; b=n7DfkYxvWrJ1hsCemxyDlL2LifTLE36M0nlFgeYAQhhgQg+jiASPfpKa1sNYxjC29COUdL7WE2/NZdpBlCgZFRzyjAZYYqu7NSBEP4QSMm7Fo9oNn0Z0vAqkRImW++kK0zKUkz/ZFpbRewWPf1QDsshzBAD1z+w0BsII2NoNFMg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792066857; c=relaxed/simple;
	bh=af37wkMei0Bu1fhYfrtChdMqJYhZOTKfy1T94gSjs8o=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=VZofUHLfFsU/ISmqHhVJsEfGQkZIbwyJwQZo0CHIuyTgqBU5rh6UICxqYtuV8mFQAgYvXccmwphf07x3hpHmM5/RK81GXT728ayQYZLfv9gk8lQFnXs021YXnGouYJoo1cAtRAPXddQpPSIIo6fi3nIX48QiSlE+HPIcFksbGZg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=D+9aXS85; arc=none smtp.client-ip=113.46.200.220
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="D+9aXS85"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=ZSVxlqxV8bzxc6PWCD4KHer7y4vN/SNVh+u4qFbwW3Q=;
	b=D+9aXS85vp9eh2dFNYEp+WtZpTF0lwSqhoYDXgCPIBHET64CQ0jOcDw+mvXAEfONtkYl+Sxze
	GLdC5DT32WLKGWv5Tlf426XBfj4Ruu7SdWxFI00GemZJX2WiLYF1pchOvOqUToAL11UgJW5GEMP
	tp3RzhjfeHyBAYlNX5X3ZxE=
Received: from mail.maildlp.com (unknown [172.19.162.197])
	by canpmsgout05.his.huawei.com (SkyGuard) with ESMTPS id 4j56LK6h4zz12LHk;
	Thu, 15 Oct 2026 20:08:57 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 47BAC40579;
	Thu, 15 Oct 2026 20:20:51 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 15 Oct 2026 20:20:46 +0800
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
Subject: [PATCH v2 -next 13/18] LSM: rename the inode posix acl hooks to path_*_acl hooks
Date: Thu, 15 Oct 2026 20:54:19 +0800
Message-ID: <20261015125425.3246251-14-caixinchen1@huawei.com>
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

The inode_set_acl, inode_get_acl and inode_remove_acl hooks receive a
struct path, so rename them to path_set_acl, path_get_acl and
path_remove_acl to follow the path_* naming convention used for the
other hooks that take a struct path (path_chmod, path_chown, ...).
Rename the security_inode_*_acl() inline wrappers to
security_path_*_acl() and the SELinux, Smack, EVM, IMA and Landlock
implementations accordingly.  The inode_post_set_acl and
inode_post_remove_acl notification hooks still take a dentry and keep
their names.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/posix_acl.c                        |  6 +++---
 include/linux/lsm_hook_defs.h         |  6 +++---
 include/linux/security.h              | 12 ++++++------
 security/integrity/evm/evm_main.c     | 16 ++++++++--------
 security/integrity/ima/ima_appraise.c | 10 +++++-----
 security/landlock/fs.c                | 12 ++++++------
 security/security.c                   | 18 +++++++++---------
 security/selinux/hooks.c              | 12 ++++++------
 security/smack/smack_lsm.c            | 18 +++++++++---------
 9 files changed, 55 insertions(+), 55 deletions(-)

diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 75a90921a241..d4715c383e04 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -1128,7 +1128,7 @@ int vfs_set_acl(const struct path *path, const char *acl_name,
 	if (error)
 		goto out_inode_unlock;
 
-	error = security_inode_set_acl(path, acl_name, kacl);
+	error = security_path_set_acl(path, acl_name, kacl);
 	if (error)
 		goto out_inode_unlock;
 
@@ -1184,7 +1184,7 @@ struct posix_acl *vfs_get_acl(const struct path *path, const char *acl_name)
 	 * The VFS has no restrictions on reading POSIX ACLs so calling
 	 * something like xattr_permission() isn't needed. Only LSMs get a say.
 	 */
-	error = security_inode_get_acl(path, acl_name);
+	error = security_path_get_acl(path, acl_name);
 	if (error)
 		return ERR_PTR(error);
 
@@ -1236,7 +1236,7 @@ int vfs_remove_acl(const struct path *path, const char *acl_name)
 	if (error)
 		goto out_inode_unlock;
 
-	error = security_inode_remove_acl(path, acl_name);
+	error = security_path_remove_acl(path, acl_name);
 	if (error)
 		goto out_inode_unlock;
 
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index 83b04d64a906..867a43e5c771 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -162,13 +162,13 @@ LSM_HOOK(int, 0, inode_file_setattr, const struct path *path,
 	 struct file_kattr *fa)
 LSM_HOOK(int, 0, inode_file_getattr, const struct path *path,
 	 struct file_kattr *fa)
-LSM_HOOK(int, 0, inode_set_acl, const struct path *path,
+LSM_HOOK(int, 0, path_set_acl, const struct path *path,
 	 const char *acl_name, struct posix_acl *kacl)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_set_acl, struct dentry *dentry,
 	 const char *acl_name, struct posix_acl *kacl)
-LSM_HOOK(int, 0, inode_get_acl, const struct path *path,
+LSM_HOOK(int, 0, path_get_acl, const struct path *path,
 	 const char *acl_name)
-LSM_HOOK(int, 0, inode_remove_acl, const struct path *path,
+LSM_HOOK(int, 0, path_remove_acl, const struct path *path,
 	 const char *acl_name)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_remove_acl, const struct mnt_idmap *idmap,
 	 struct dentry *dentry, const char *acl_name)
diff --git a/include/linux/security.h b/include/linux/security.h
index 15a8bd6c16e5..d695f963fae0 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -435,12 +435,12 @@ int security_path_getattr(const struct path *path);
 int security_path_setxattr(const struct path *path,
 			    const char *name, const void *value,
 			    size_t size, int flags);
-int security_inode_set_acl(const struct path *path,
+int security_path_set_acl(const struct path *path,
 			   const char *acl_name, struct posix_acl *kacl);
 void security_inode_post_set_acl(struct dentry *dentry, const char *acl_name,
 				 struct posix_acl *kacl);
-int security_inode_get_acl(const struct path *path, const char *acl_name);
-int security_inode_remove_acl(const struct path *path, const char *acl_name);
+int security_path_get_acl(const struct path *path, const char *acl_name);
+int security_path_remove_acl(const struct path *path, const char *acl_name);
 void security_inode_post_remove_acl(const struct mnt_idmap *idmap,
 				    struct dentry *dentry,
 				    const char *acl_name);
@@ -1018,7 +1018,7 @@ static inline int security_path_setxattr(const struct path *path,
 	return cap_inode_setxattr(path, name, value, size, flags);
 }
 
-static inline int security_inode_set_acl(const struct path *path,
+static inline int security_path_set_acl(const struct path *path,
 					 const char *acl_name,
 					 struct posix_acl *kacl)
 {
@@ -1030,13 +1030,13 @@ static inline void security_inode_post_set_acl(struct dentry *dentry,
 					       struct posix_acl *kacl)
 { }
 
-static inline int security_inode_get_acl(const struct path *path,
+static inline int security_path_get_acl(const struct path *path,
 					 const char *acl_name)
 {
 	return 0;
 }
 
-static inline int security_inode_remove_acl(const struct path *path,
+static inline int security_path_remove_acl(const struct path *path,
 					    const char *acl_name)
 {
 	return 0;
diff --git a/security/integrity/evm/evm_main.c b/security/integrity/evm/evm_main.c
index 5d8fd1ee6a3b..5c2ce1d00fb8 100644
--- a/security/integrity/evm/evm_main.c
+++ b/security/integrity/evm/evm_main.c
@@ -8,7 +8,7 @@
  *
  * File: evm_main.c
  *	implements evm_path_setxattr, evm_inode_post_setxattr,
- *	evm_path_removexattr, evm_verifyxattr, and evm_inode_set_acl.
+ *	evm_path_removexattr, evm_verifyxattr, and evm_path_set_acl.
  */
 
 #define pr_fmt(fmt) "EVM: "fmt
@@ -684,7 +684,7 @@ static inline int evm_inode_set_acl_change(const struct mnt_idmap *idmap,
 #endif
 
 /**
- * evm_inode_set_acl - protect the EVM extended attribute from posix acls
+ * evm_path_set_acl - protect the EVM extended attribute from posix acls
  * @path: pointer to the affected object
  * @acl_name: name of the posix acl
  * @kacl: pointer to the posix acls
@@ -695,7 +695,7 @@ static inline int evm_inode_set_acl_change(const struct mnt_idmap *idmap,
  *
  * Return: zero on success, -EPERM on failure.
  */
-static int evm_inode_set_acl(const struct path *path,
+static int evm_path_set_acl(const struct path *path,
 			     const char *acl_name, struct posix_acl *kacl)
 {
 	enum integrity_status evm_status;
@@ -738,7 +738,7 @@ static int evm_inode_set_acl(const struct path *path,
 }
 
 /**
- * evm_inode_remove_acl - Protect the EVM extended attribute from posix acls
+ * evm_path_remove_acl - Protect the EVM extended attribute from posix acls
  * @path: pointer to the affected object
  * @acl_name: name of the posix acl
  *
@@ -748,10 +748,10 @@ static int evm_inode_set_acl(const struct path *path,
  *
  * Return: zero on success, -EPERM on failure.
  */
-static int evm_inode_remove_acl(const struct path *path,
+static int evm_path_remove_acl(const struct path *path,
 				const char *acl_name)
 {
-	return evm_inode_set_acl(path, acl_name, NULL);
+	return evm_path_set_acl(path, acl_name, NULL);
 }
 
 static void evm_reset_status(struct inode *inode)
@@ -1204,9 +1204,9 @@ static struct security_hook_list evm_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(inode_copy_up_xattr, evm_inode_copy_up_xattr),
 	LSM_HOOK_INIT(path_setxattr, evm_path_setxattr),
 	LSM_HOOK_INIT(inode_post_setxattr, evm_inode_post_setxattr),
-	LSM_HOOK_INIT(inode_set_acl, evm_inode_set_acl),
+	LSM_HOOK_INIT(path_set_acl, evm_path_set_acl),
 	LSM_HOOK_INIT(inode_post_set_acl, evm_inode_post_set_acl),
-	LSM_HOOK_INIT(inode_remove_acl, evm_inode_remove_acl),
+	LSM_HOOK_INIT(path_remove_acl, evm_path_remove_acl),
 	LSM_HOOK_INIT(inode_post_remove_acl, evm_inode_post_remove_acl),
 	LSM_HOOK_INIT(path_removexattr, evm_path_removexattr),
 	LSM_HOOK_INIT(inode_post_removexattr, evm_inode_post_removexattr),
diff --git a/security/integrity/ima/ima_appraise.c b/security/integrity/ima/ima_appraise.c
index 3a6cb541ab32..f5068f881a24 100644
--- a/security/integrity/ima/ima_appraise.c
+++ b/security/integrity/ima/ima_appraise.c
@@ -793,7 +793,7 @@ static int ima_path_setxattr(const struct path *path,
 	return result;
 }
 
-static int ima_inode_set_acl(const struct path *path,
+static int ima_path_set_acl(const struct path *path,
 			     const char *acl_name, struct posix_acl *kacl)
 {
 	if (evm_revalidate_status(acl_name))
@@ -818,18 +818,18 @@ static int ima_path_removexattr(const struct path *path,
 	return result;
 }
 
-static int ima_inode_remove_acl(const struct path *path,
+static int ima_path_remove_acl(const struct path *path,
 				const char *acl_name)
 {
-	return ima_inode_set_acl(path, acl_name, NULL);
+	return ima_path_set_acl(path, acl_name, NULL);
 }
 
 static struct security_hook_list ima_appraise_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(inode_post_setattr, ima_inode_post_setattr),
 	LSM_HOOK_INIT(path_setxattr, ima_path_setxattr),
-	LSM_HOOK_INIT(inode_set_acl, ima_inode_set_acl),
+	LSM_HOOK_INIT(path_set_acl, ima_path_set_acl),
 	LSM_HOOK_INIT(path_removexattr, ima_path_removexattr),
-	LSM_HOOK_INIT(inode_remove_acl, ima_inode_remove_acl),
+	LSM_HOOK_INIT(path_remove_acl, ima_path_remove_acl),
 };
 
 void __init init_ima_appraise_lsm(const struct lsm_id *lsmid)
diff --git a/security/landlock/fs.c b/security/landlock/fs.c
index 33bca2d878c8..380a80247b6d 100644
--- a/security/landlock/fs.c
+++ b/security/landlock/fs.c
@@ -1769,7 +1769,7 @@ static int hook_path_removexattr(const struct path *const path,
 					LANDLOCK_ACCESS_FS_WRITE_METADATA);
 }
 
-static int hook_inode_set_acl(const struct path *const path,
+static int hook_path_set_acl(const struct path *const path,
 			      const char *const acl_name,
 			      struct posix_acl *const kacl)
 {
@@ -1777,14 +1777,14 @@ static int hook_inode_set_acl(const struct path *const path,
 					LANDLOCK_ACCESS_FS_WRITE_METADATA);
 }
 
-static int hook_inode_get_acl(const struct path *const path,
+static int hook_path_get_acl(const struct path *const path,
 			      const char *const acl_name)
 {
 	return current_check_access_path(path,
 					LANDLOCK_ACCESS_FS_READ_METADATA);
 }
 
-static int hook_inode_remove_acl(const struct path *const path,
+static int hook_path_remove_acl(const struct path *const path,
 				 const char *const acl_name)
 {
 	return current_check_access_path(path,
@@ -2223,9 +2223,9 @@ static struct security_hook_list landlock_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(path_getxattr, hook_path_getxattr),
 	LSM_HOOK_INIT(path_listxattr, hook_path_listxattr),
 	LSM_HOOK_INIT(path_removexattr, hook_path_removexattr),
-	LSM_HOOK_INIT(inode_set_acl, hook_inode_set_acl),
-	LSM_HOOK_INIT(inode_get_acl, hook_inode_get_acl),
-	LSM_HOOK_INIT(inode_remove_acl, hook_inode_remove_acl),
+	LSM_HOOK_INIT(path_set_acl, hook_path_set_acl),
+	LSM_HOOK_INIT(path_get_acl, hook_path_get_acl),
+	LSM_HOOK_INIT(path_remove_acl, hook_path_remove_acl),
 	LSM_HOOK_INIT(unix_find, hook_unix_find),
 
 	LSM_HOOK_INIT(file_alloc_security, hook_file_alloc_security),
diff --git a/security/security.c b/security/security.c
index 98930f0b3b60..0a8ffc97d679 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1986,7 +1986,7 @@ int security_path_setxattr(const struct path *path,
 }
 
 /**
- * security_inode_set_acl() - Check if setting posix acls is allowed
+ * security_path_set_acl() - Check if setting posix acls is allowed
  * @path: file
  * @acl_name: acl name
  * @kacl: acl struct
@@ -1996,12 +1996,12 @@ int security_path_setxattr(const struct path *path,
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_set_acl(const struct path *path,
+int security_path_set_acl(const struct path *path,
 			   const char *acl_name, struct posix_acl *kacl)
 {
 	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_set_acl, path, acl_name, kacl);
+	return call_int_hook(path_set_acl, path, acl_name, kacl);
 }
 
 /**
@@ -2022,7 +2022,7 @@ void security_inode_post_set_acl(struct dentry *dentry, const char *acl_name,
 }
 
 /**
- * security_inode_get_acl() - Check if reading posix acls is allowed
+ * security_path_get_acl() - Check if reading posix acls is allowed
  * @path: file
  * @acl_name: acl name
  *
@@ -2031,15 +2031,15 @@ void security_inode_post_set_acl(struct dentry *dentry, const char *acl_name,
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_get_acl(const struct path *path, const char *acl_name)
+int security_path_get_acl(const struct path *path, const char *acl_name)
 {
 	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_get_acl, path, acl_name);
+	return call_int_hook(path_get_acl, path, acl_name);
 }
 
 /**
- * security_inode_remove_acl() - Check if removing a posix acl is allowed
+ * security_path_remove_acl() - Check if removing a posix acl is allowed
  * @path: file
  * @acl_name: acl name
  *
@@ -2048,11 +2048,11 @@ int security_inode_get_acl(const struct path *path, const char *acl_name)
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_remove_acl(const struct path *path, const char *acl_name)
+int security_path_remove_acl(const struct path *path, const char *acl_name)
 {
 	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_remove_acl, path, acl_name);
+	return call_int_hook(path_remove_acl, path, acl_name);
 }
 
 /**
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 9b2e0f38bf2c..e1d3dc4f063f 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3505,19 +3505,19 @@ static int selinux_path_setxattr(const struct path *path,
 			    &ad);
 }
 
-static int selinux_inode_set_acl(const struct path *path,
+static int selinux_path_set_acl(const struct path *path,
 				 const char *acl_name, struct posix_acl *kacl)
 {
 	return dentry_has_perm(current_cred(), path->dentry, FILE__SETATTR);
 }
 
-static int selinux_inode_get_acl(const struct path *path,
+static int selinux_path_get_acl(const struct path *path,
 				 const char *acl_name)
 {
 	return dentry_has_perm(current_cred(), path->dentry, FILE__GETATTR);
 }
 
-static int selinux_inode_remove_acl(const struct path *path,
+static int selinux_path_remove_acl(const struct path *path,
 				    const char *acl_name)
 {
 	return dentry_has_perm(current_cred(), path->dentry, FILE__SETATTR);
@@ -7765,9 +7765,9 @@ static struct security_hook_list selinux_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(path_removexattr, selinux_path_removexattr),
 	LSM_HOOK_INIT(inode_file_getattr, selinux_inode_file_getattr),
 	LSM_HOOK_INIT(inode_file_setattr, selinux_inode_file_setattr),
-	LSM_HOOK_INIT(inode_set_acl, selinux_inode_set_acl),
-	LSM_HOOK_INIT(inode_get_acl, selinux_inode_get_acl),
-	LSM_HOOK_INIT(inode_remove_acl, selinux_inode_remove_acl),
+	LSM_HOOK_INIT(path_set_acl, selinux_path_set_acl),
+	LSM_HOOK_INIT(path_get_acl, selinux_path_get_acl),
+	LSM_HOOK_INIT(path_remove_acl, selinux_path_remove_acl),
 	LSM_HOOK_INIT(inode_getsecurity, selinux_inode_getsecurity),
 	LSM_HOOK_INIT(inode_setsecurity, selinux_inode_setsecurity),
 	LSM_HOOK_INIT(inode_listsecurity, selinux_inode_listsecurity),
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 95799afbb5c9..1a1e9f11939e 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1540,7 +1540,7 @@ static int smack_path_removexattr(const struct path *path,
 }
 
 /**
- * smack_inode_set_acl - Smack check for setting posix acls
+ * smack_path_set_acl - Smack check for setting posix acls
  * @idmap: idmap of the mnt this request came from
  * @dentry: the object
  * @acl_name: name of the posix acl
@@ -1548,7 +1548,7 @@ static int smack_path_removexattr(const struct path *path,
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_set_acl(const struct path *path,
+static int smack_path_set_acl(const struct path *path,
 			       const char *acl_name, struct posix_acl *kacl)
 {
 	struct smk_audit_info ad;
@@ -1563,13 +1563,13 @@ static int smack_inode_set_acl(const struct path *path,
 }
 
 /**
- * smack_inode_get_acl - Smack check for getting posix acls
+ * smack_path_get_acl - Smack check for getting posix acls
  * @path: the object
  * @acl_name: name of the posix acl
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_get_acl(const struct path *path,
+static int smack_path_get_acl(const struct path *path,
 			       const char *acl_name)
 {
 	struct smk_audit_info ad;
@@ -1584,13 +1584,13 @@ static int smack_inode_get_acl(const struct path *path,
 }
 
 /**
- * smack_inode_remove_acl - Smack check for getting posix acls
+ * smack_path_remove_acl - Smack check for getting posix acls
  * @path: the object
  * @acl_name: name of the posix acl
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_remove_acl(const struct path *path,
+static int smack_path_remove_acl(const struct path *path,
 				  const char *acl_name)
 {
 	struct smk_audit_info ad;
@@ -5185,9 +5185,9 @@ static struct security_hook_list smack_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(inode_post_setxattr, smack_inode_post_setxattr),
 	LSM_HOOK_INIT(path_getxattr, smack_path_getxattr),
 	LSM_HOOK_INIT(path_removexattr, smack_path_removexattr),
-	LSM_HOOK_INIT(inode_set_acl, smack_inode_set_acl),
-	LSM_HOOK_INIT(inode_get_acl, smack_inode_get_acl),
-	LSM_HOOK_INIT(inode_remove_acl, smack_inode_remove_acl),
+	LSM_HOOK_INIT(path_set_acl, smack_path_set_acl),
+	LSM_HOOK_INIT(path_get_acl, smack_path_get_acl),
+	LSM_HOOK_INIT(path_remove_acl, smack_path_remove_acl),
 	LSM_HOOK_INIT(inode_getsecurity, smack_inode_getsecurity),
 	LSM_HOOK_INIT(inode_setsecurity, smack_inode_setsecurity),
 	LSM_HOOK_INIT(inode_listsecurity, smack_inode_listsecurity),
-- 
2.18.0.huawei.25

