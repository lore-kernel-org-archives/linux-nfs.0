Received: from canpmsgout09.his.huawei.com (canpmsgout09.his.huawei.com [113.46.200.224])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F70453E2F8;
	Thu, 15 Oct 2026 12:20:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.224
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792066862; cv=none; b=Jg0XIlizSOvgIHfbR5rqdQUfApciFN80jDSanXHSgw6sHu+ezA2A5Ws0286mMVxw3dGygLRkYY/KEsYraR5qLoNvkLqDDpEHDyQFtX/FF2IGirGSC0ZmgvORQU+bPUBlVYzDlkhrU8IvjlIH+31AeyiQC6ydvHeqotC1U8JvF/8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792066862; c=relaxed/simple;
	bh=9wQkR/130TK/S/Oz8syc2fqad2B+WSqnb9rmmZxoPwE=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=i3UmXtdf2DBwrBReLf4yeMgXUi9cJe9EauVvDJMqoxKwsccbRmPupMU/lDDq01VgSb9y2zUHe/qLSmdDiaoGsv1xDUxs0D9g7DbmF5w29JI5Zl6StE1TO2bqfsr/pmzPob/kUMmCqSxNdp6eqMxeiMlcknqtlC2O7yHkIILHpcw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=g5X5/Cp8; arc=none smtp.client-ip=113.46.200.224
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="g5X5/Cp8"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=+CnApGI7O4NBiZYKpfwDewigga/iTUer7Ao9pZQuYtI=;
	b=g5X5/Cp8MpYdQpji4JErKj24rd1n6KM79/Cmke88Ynynwr0KBo3POD2ZWL75usC+FDzQ8VOPe
	cDcwIq87diax+pcQ28pDhhmyQ/uPN7sWPFVgGF2pUkURC20p33NoMiLfRwaW2Iwypyzb270eg2B
	8E+ce320PZINW6P5krQFWgI=
Received: from mail.maildlp.com (unknown [172.19.162.92])
	by canpmsgout09.his.huawei.com (SkyGuard) with ESMTPS id 4j56M81CZPz1cyPY;
	Thu, 15 Oct 2026 20:09:40 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 2D15740565;
	Thu, 15 Oct 2026 20:20:56 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 15 Oct 2026 20:20:50 +0800
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
Subject: [PATCH v2 -next 14/18] LSM: rename the inode fileattr hooks to path_file_* hooks
Date: Thu, 15 Oct 2026 20:54:20 +0800
Message-ID: <20261015125425.3246251-15-caixinchen1@huawei.com>
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

The inode_file_getattr and inode_file_setattr hooks receive a struct
path, so rename them to path_file_getattr and path_file_setattr to
follow the path_* naming convention used for the other hooks that
take a struct path (path_chmod, path_chown, ...).  Rename the
security_inode_file_getattr() and security_inode_file_setattr()
inline wrappers and the SELinux and Landlock implementations
accordingly.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/file_attr.c                |  4 ++--
 include/linux/lsm_hook_defs.h |  4 ++--
 include/linux/security.h      |  8 ++++----
 security/landlock/fs.c        |  8 ++++----
 security/security.c           | 12 ++++++------
 security/selinux/hooks.c      |  8 ++++----
 6 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/fs/file_attr.c b/fs/file_attr.c
index 1e555aebd815..ea56843450f7 100644
--- a/fs/file_attr.c
+++ b/fs/file_attr.c
@@ -110,7 +110,7 @@ int vfs_fileattr_get(const struct path *path, struct file_kattr *fa)
 {
 	int error;
 
-	error = security_inode_file_getattr(path, fa);
+	error = security_path_file_getattr(path, fa);
 	if (error)
 		return error;
 
@@ -312,7 +312,7 @@ static int do_vfs_fileattr_set(const struct path *const path,
 		 * user-facing path.
 		 */
 		if (path) {
-			err = security_inode_file_setattr(path, fa);
+			err = security_path_file_setattr(path, fa);
 			if (err)
 				goto out;
 		}
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index 867a43e5c771..da490923cdcd 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -158,9 +158,9 @@ LSM_HOOK(int, 0, path_removexattr, const struct path *path,
 	 const char *name)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_removexattr, struct dentry *dentry,
 	 const char *name)
-LSM_HOOK(int, 0, inode_file_setattr, const struct path *path,
+LSM_HOOK(int, 0, path_file_setattr, const struct path *path,
 	 struct file_kattr *fa)
-LSM_HOOK(int, 0, inode_file_getattr, const struct path *path,
+LSM_HOOK(int, 0, path_file_getattr, const struct path *path,
 	 struct file_kattr *fa)
 LSM_HOOK(int, 0, path_set_acl, const struct path *path,
 	 const char *acl_name, struct posix_acl *kacl)
diff --git a/include/linux/security.h b/include/linux/security.h
index d695f963fae0..4f1c26c75093 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -451,9 +451,9 @@ int security_path_listxattr(const struct path *path);
 int security_path_removexattr(const struct path *path,
 			       const char *name);
 void security_inode_post_removexattr(struct dentry *dentry, const char *name);
-int security_inode_file_setattr(const struct path *path,
+int security_path_file_setattr(const struct path *path,
 			      struct file_kattr *fa);
-int security_inode_file_getattr(const struct path *path,
+int security_path_file_getattr(const struct path *path,
 			      struct file_kattr *fa);
 int security_inode_need_killpriv(struct dentry *dentry);
 int security_inode_killpriv(const struct mnt_idmap *idmap, struct dentry *dentry);
@@ -1072,13 +1072,13 @@ static inline void security_inode_post_removexattr(struct dentry *dentry,
 						   const char *name)
 { }
 
-static inline int security_inode_file_setattr(const struct path *path,
+static inline int security_path_file_setattr(const struct path *path,
 					      struct file_kattr *fa)
 {
 	return 0;
 }
 
-static inline int security_inode_file_getattr(const struct path *path,
+static inline int security_path_file_getattr(const struct path *path,
 					      struct file_kattr *fa)
 {
 	return 0;
diff --git a/security/landlock/fs.c b/security/landlock/fs.c
index 380a80247b6d..1bca7558ea9f 100644
--- a/security/landlock/fs.c
+++ b/security/landlock/fs.c
@@ -1684,7 +1684,7 @@ static int hook_path_getattr(const struct path *const path)
 					LANDLOCK_ACCESS_FS_READ_METADATA);
 }
 
-static int hook_inode_file_getattr(const struct path *const path,
+static int hook_path_file_getattr(const struct path *const path,
 				   struct file_kattr *const fa)
 {
 	return current_check_access_path(path,
@@ -1726,7 +1726,7 @@ static int hook_path_setattr(const struct path *const path,
 					LANDLOCK_ACCESS_FS_WRITE_METADATA);
 }
 
-static int hook_inode_file_setattr(const struct path *const path,
+static int hook_path_file_setattr(const struct path *const path,
 				   struct file_kattr *const fa)
 {
 	/*
@@ -2216,9 +2216,9 @@ static struct security_hook_list landlock_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(path_rmdir, hook_path_rmdir),
 	LSM_HOOK_INIT(path_truncate, hook_path_truncate),
 	LSM_HOOK_INIT(path_getattr, hook_path_getattr),
-	LSM_HOOK_INIT(inode_file_getattr, hook_inode_file_getattr),
+	LSM_HOOK_INIT(path_file_getattr, hook_path_file_getattr),
 	LSM_HOOK_INIT(path_setattr, hook_path_setattr),
-	LSM_HOOK_INIT(inode_file_setattr, hook_inode_file_setattr),
+	LSM_HOOK_INIT(path_file_setattr, hook_path_file_setattr),
 	LSM_HOOK_INIT(path_setxattr, hook_path_setxattr),
 	LSM_HOOK_INIT(path_getxattr, hook_path_getxattr),
 	LSM_HOOK_INIT(path_listxattr, hook_path_listxattr),
diff --git a/security/security.c b/security/security.c
index 0a8ffc97d679..f04a7bb311ea 100644
--- a/security/security.c
+++ b/security/security.c
@@ -2177,7 +2177,7 @@ void security_inode_post_removexattr(struct dentry *dentry, const char *name)
 }
 
 /**
- * security_inode_file_setattr() - check if setting fsxattr is allowed
+ * security_path_file_setattr() - check if setting fsxattr is allowed
  * @path: file to set filesystem extended attributes on
  * @fa: extended attributes to set on the inode
  *
@@ -2186,13 +2186,13 @@ void security_inode_post_removexattr(struct dentry *dentry, const char *name)
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_file_setattr(const struct path *path, struct file_kattr *fa)
+int security_path_file_setattr(const struct path *path, struct file_kattr *fa)
 {
-	return call_int_hook(inode_file_setattr, path, fa);
+	return call_int_hook(path_file_setattr, path, fa);
 }
 
 /**
- * security_inode_file_getattr() - check if retrieving fsxattr is allowed
+ * security_path_file_getattr() - check if retrieving fsxattr is allowed
  * @path: file to retrieve filesystem extended attributes from
  * @fa: extended attributes to get
  *
@@ -2201,9 +2201,9 @@ int security_inode_file_setattr(const struct path *path, struct file_kattr *fa)
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_file_getattr(const struct path *path, struct file_kattr *fa)
+int security_path_file_getattr(const struct path *path, struct file_kattr *fa)
 {
-	return call_int_hook(inode_file_getattr, path, fa);
+	return call_int_hook(path_file_getattr, path, fa);
 }
 
 /**
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index e1d3dc4f063f..ee0d6c12de37 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3593,13 +3593,13 @@ static int selinux_path_removexattr(const struct path *path,
 	return -EACCES;
 }
 
-static int selinux_inode_file_setattr(const struct path *path,
+static int selinux_path_file_setattr(const struct path *path,
 				      struct file_kattr *fa)
 {
 	return dentry_has_perm(current_cred(), path->dentry, FILE__SETATTR);
 }
 
-static int selinux_inode_file_getattr(const struct path *path,
+static int selinux_path_file_getattr(const struct path *path,
 				      struct file_kattr *fa)
 {
 	return dentry_has_perm(current_cred(), path->dentry, FILE__GETATTR);
@@ -7763,8 +7763,8 @@ static struct security_hook_list selinux_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(path_getxattr, selinux_path_getxattr),
 	LSM_HOOK_INIT(path_listxattr, selinux_path_listxattr),
 	LSM_HOOK_INIT(path_removexattr, selinux_path_removexattr),
-	LSM_HOOK_INIT(inode_file_getattr, selinux_inode_file_getattr),
-	LSM_HOOK_INIT(inode_file_setattr, selinux_inode_file_setattr),
+	LSM_HOOK_INIT(path_file_getattr, selinux_path_file_getattr),
+	LSM_HOOK_INIT(path_file_setattr, selinux_path_file_setattr),
 	LSM_HOOK_INIT(path_set_acl, selinux_path_set_acl),
 	LSM_HOOK_INIT(path_get_acl, selinux_path_get_acl),
 	LSM_HOOK_INIT(path_remove_acl, selinux_path_remove_acl),
-- 
2.18.0.huawei.25

