Received: from canpmsgout09.his.huawei.com (canpmsgout09.his.huawei.com [113.46.200.224])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F7F3531B0F;
	Thu, 15 Oct 2026 12:20:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.224
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792066831; cv=none; b=Fxj7hdblopUcWPK3po00ZRsogG9A3anK78vQKcnnYptFeNxSYoAnsObANiCESgirJMwJU2pwfN/0leXOlFNB+cpJ585A0v9NySXivRTWI5OLW1Ii+zJeCFqt165Uy0fZ9m7l9HUO5Jsx5X+g1TcHNI11Gc9YF6sCl2/q31co2SA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792066831; c=relaxed/simple;
	bh=WBQzhXipYrPV4Sxo6lUfSLkmhktNyRfbQ545P1f+ECw=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=VSPK/F5X6/NUo9Qhlz+8dYQnjZWxlmJ4145XXPap0tcs6t0tFTAAx0tCeGToo9kSuGuabb3hi3obc+VjW09abW01mqsH0AaCdyzo9K43h8TJhCOmGuHd7dGvdoT/EGcVFbmHCvqNKFnLNBcS77HU+/2pVWWimcMZnCHX6BA8bjY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=jRfk/z3+; arc=none smtp.client-ip=113.46.200.224
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="jRfk/z3+"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=cplB8eMKyqCZxN5ioumGA07ut3s+Ooe8o5kzvzfS00Y=;
	b=jRfk/z3+DqTQZk2y6rzyhs7pv7YiUllBxN2tT4+fq1Nqhw1QfiJY7BcX9JZI9QA2ZDZ7tUL/n
	5WmxXAge6l4e3q9wORr7HRInA4eypqpwM6wtm7YuITbxRhwCdaqxxfS2qYxWanLgGuPv5u1WZcW
	f+kw2TR593vzqqP1QLMHTb4=
Received: from mail.maildlp.com (unknown [172.19.163.15])
	by canpmsgout09.his.huawei.com (SkyGuard) with ESMTPS id 4j56LN5Qz6z1cywv;
	Thu, 15 Oct 2026 20:09:00 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id B285240586;
	Thu, 15 Oct 2026 20:20:16 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 15 Oct 2026 20:20:11 +0800
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
Subject: [PATCH v2 -next 06/18] LSM: pass struct path to the inode xattr hooks
Date: Thu, 15 Oct 2026 20:54:12 +0800
Message-ID: <20261015125425.3246251-7-caixinchen1@huawei.com>
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
inode_removexattr hooks are called from fs/xattr.c, whose helpers
now hold a struct path and used to derive the idmap and dentry from
it just for the hook calls.

Convert the hooks and their commoncap, SELinux, Smack, EVM and IMA
implementations to take a const struct path.  The implementations
derive the idmap and dentry they still need from the path, so this
is a purely mechanical change with no behavior change.

Also update the BPF selftest programs that attach to the changed
hooks (test_get_xattr.c, test_set_remove_xattr.c and
verifier_lsm_init_xattr.c) to the new signatures, passing
path->dentry to the dentry xattr kfuncs.  The bpf_lsm_* attach
stubs themselves are generated from lsm_hook_defs.h and need no
changes.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/xattr.c                                    |  8 +--
 include/linux/lsm_hook_defs.h                 | 13 +++--
 include/linux/security.h                      | 35 ++++++-------
 security/commoncap.c                          | 22 ++++----
 security/integrity/evm/evm_main.c             | 15 +++---
 security/integrity/ima/ima_appraise.c         |  9 ++--
 security/security.c                           | 51 +++++++++----------
 security/selinux/hooks.c                      | 23 +++++----
 security/smack/smack_lsm.c                    | 18 ++++---
 .../selftests/bpf/progs/test_get_xattr.c      |  4 +-
 .../bpf/progs/test_set_remove_xattr.c         | 27 +++++-----
 .../bpf/progs/verifier_lsm_init_xattr.c       |  2 +-
 12 files changed, 112 insertions(+), 115 deletions(-)

diff --git a/fs/xattr.c b/fs/xattr.c
index 189ad8d57a2d..f469a9464081 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -307,7 +307,7 @@ __vfs_setxattr_locked(const struct path *path, const char *name,
 	if (error)
 		return error;
 
-	error = security_inode_setxattr(idmap, dentry, name, value, size,
+	error = security_inode_setxattr(path, name, value, size,
 					flags);
 	if (error)
 		goto out;
@@ -463,7 +463,7 @@ vfs_getxattr(const struct path *path, const char *name, void *value,
 	if (error)
 		return error;
 
-	error = security_inode_getxattr(dentry, name);
+	error = security_inode_getxattr(path, name);
 	if (error)
 		return error;
 
@@ -514,7 +514,7 @@ vfs_listxattr(const struct path *path, char *list, size_t size)
 	struct inode *inode = d_inode(dentry);
 	ssize_t error;
 
-	error = security_inode_listxattr(dentry);
+	error = security_inode_listxattr(path);
 	if (error)
 		return error;
 
@@ -574,7 +574,7 @@ __vfs_removexattr_locked(const struct path *path, const char *name,
 	if (error)
 		return error;
 
-	error = security_inode_removexattr(idmap, dentry, name);
+	error = security_inode_removexattr(path, name);
 	if (error)
 		goto out;
 
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index ff3dbe443007..49483c51667b 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -148,15 +148,14 @@ LSM_HOOK(void, LSM_RET_VOID, inode_post_setattr, const struct mnt_idmap *idmap,
 	 struct dentry *dentry, int ia_valid)
 LSM_HOOK(int, 0, inode_getattr, const struct path *path)
 LSM_HOOK(int, 0, inode_xattr_skipcap, const char *name)
-LSM_HOOK(int, 0, inode_setxattr, const struct mnt_idmap *idmap,
-	 struct dentry *dentry, const char *name, const void *value,
-	 size_t size, int flags)
+LSM_HOOK(int, 0, inode_setxattr, const struct path *path,
+	 const char *name, const void *value, size_t size, int flags)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_setxattr, struct dentry *dentry,
 	 const char *name, const void *value, size_t size, int flags)
-LSM_HOOK(int, 0, inode_getxattr, struct dentry *dentry, const char *name)
-LSM_HOOK(int, 0, inode_listxattr, struct dentry *dentry)
-LSM_HOOK(int, 0, inode_removexattr, const struct mnt_idmap *idmap,
-	 struct dentry *dentry, const char *name)
+LSM_HOOK(int, 0, inode_getxattr, const struct path *path, const char *name)
+LSM_HOOK(int, 0, inode_listxattr, const struct path *path)
+LSM_HOOK(int, 0, inode_removexattr, const struct path *path,
+	 const char *name)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_removexattr, struct dentry *dentry,
 	 const char *name)
 LSM_HOOK(int, 0, inode_file_setattr, struct dentry *dentry, struct file_kattr *fa)
diff --git a/include/linux/security.h b/include/linux/security.h
index e821adaeaf01..741f914128e2 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -185,10 +185,9 @@ extern int cap_capset(struct cred *new, const struct cred *old,
 		      const kernel_cap_t *inheritable,
 		      const kernel_cap_t *permitted);
 extern int cap_bprm_creds_from_file(struct linux_binprm *bprm, const struct file *file);
-int cap_inode_setxattr(struct dentry *dentry, const char *name,
+int cap_inode_setxattr(const struct path *path, const char *name,
 		       const void *value, size_t size, int flags);
-int cap_inode_removexattr(const struct mnt_idmap *idmap,
-			  struct dentry *dentry, const char *name);
+int cap_inode_removexattr(const struct path *path, const char *name);
 int cap_inode_need_killpriv(struct dentry *dentry);
 int cap_inode_killpriv(const struct mnt_idmap *idmap, struct dentry *dentry);
 int cap_inode_getsecurity(const struct mnt_idmap *idmap,
@@ -433,9 +432,9 @@ int security_inode_setattr(const struct path *path, struct iattr *attr);
 void security_inode_post_setattr(const struct mnt_idmap *idmap, struct dentry *dentry,
 				 int ia_valid);
 int security_inode_getattr(const struct path *path);
-int security_inode_setxattr(const struct mnt_idmap *idmap,
-			    struct dentry *dentry, const char *name,
-			    const void *value, size_t size, int flags);
+int security_inode_setxattr(const struct path *path,
+			    const char *name, const void *value,
+			    size_t size, int flags);
 int security_inode_set_acl(const struct mnt_idmap *idmap,
 			   struct dentry *dentry, const char *acl_name,
 			   struct posix_acl *kacl);
@@ -450,10 +449,10 @@ void security_inode_post_remove_acl(const struct mnt_idmap *idmap,
 				    const char *acl_name);
 void security_inode_post_setxattr(struct dentry *dentry, const char *name,
 				  const void *value, size_t size, int flags);
-int security_inode_getxattr(struct dentry *dentry, const char *name);
-int security_inode_listxattr(struct dentry *dentry);
-int security_inode_removexattr(const struct mnt_idmap *idmap,
-			       struct dentry *dentry, const char *name);
+int security_inode_getxattr(const struct path *path, const char *name);
+int security_inode_listxattr(const struct path *path);
+int security_inode_removexattr(const struct path *path,
+			       const char *name);
 void security_inode_post_removexattr(struct dentry *dentry, const char *name);
 int security_inode_file_setattr(struct dentry *dentry,
 			      struct file_kattr *fa);
@@ -1016,11 +1015,10 @@ static inline int security_inode_getattr(const struct path *path)
 	return 0;
 }
 
-static inline int security_inode_setxattr(const struct mnt_idmap *idmap,
-		struct dentry *dentry, const char *name, const void *value,
-		size_t size, int flags)
+static inline int security_inode_setxattr(const struct path *path,
+		const char *name, const void *value, size_t size, int flags)
 {
-	return cap_inode_setxattr(dentry, name, value, size, flags);
+	return cap_inode_setxattr(path, name, value, size, flags);
 }
 
 static inline int security_inode_set_acl(const struct mnt_idmap *idmap,
@@ -1059,22 +1057,21 @@ static inline void security_inode_post_setxattr(struct dentry *dentry,
 		const char *name, const void *value, size_t size, int flags)
 { }
 
-static inline int security_inode_getxattr(struct dentry *dentry,
+static inline int security_inode_getxattr(const struct path *path,
 			const char *name)
 {
 	return 0;
 }
 
-static inline int security_inode_listxattr(struct dentry *dentry)
+static inline int security_inode_listxattr(const struct path *path)
 {
 	return 0;
 }
 
-static inline int security_inode_removexattr(const struct mnt_idmap *idmap,
-					     struct dentry *dentry,
+static inline int security_inode_removexattr(const struct path *path,
 					     const char *name)
 {
-	return cap_inode_removexattr(idmap, dentry, name);
+	return cap_inode_removexattr(path, name);
 }
 
 static inline void security_inode_post_removexattr(struct dentry *dentry,
diff --git a/security/commoncap.c b/security/commoncap.c
index 565c893c6d4b..971994e9553e 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -14,6 +14,7 @@
 #include <linux/netlink.h>
 #include <linux/ptrace.h>
 #include <linux/xattr.h>
+#include <linux/path.h>
 #include <linux/mount.h>
 #include <linux/sched.h>
 #include <linux/prctl.h>
@@ -1007,7 +1008,7 @@ int cap_bprm_creds_from_file(struct linux_binprm *bprm, const struct file *file)
 
 /**
  * cap_inode_setxattr - Determine whether an xattr may be altered
- * @dentry: The inode/dentry being altered
+ * @path: The inode/path being altered
  * @name: The name of the xattr to be changed
  * @value: The value that the xattr will be changed to
  * @size: The size of value
@@ -1019,9 +1020,10 @@ int cap_bprm_creds_from_file(struct linux_binprm *bprm, const struct file *file)
  * This is used to make sure security xattrs don't get updated or set by those
  * who aren't privileged to do so.
  */
-int cap_inode_setxattr(struct dentry *dentry, const char *name,
+int cap_inode_setxattr(const struct path *path, const char *name,
 		       const void *value, size_t size, int flags)
 {
+	struct dentry *dentry = path->dentry;
 	struct user_namespace *user_ns = dentry->d_sb->s_user_ns;
 
 	/* Ignore non-security xattrs */
@@ -1044,25 +1046,18 @@ int cap_inode_setxattr(struct dentry *dentry, const char *name,
 /**
  * cap_inode_removexattr - Determine whether an xattr may be removed
  *
- * @idmap:	idmap of the mount the inode was found from
- * @dentry:	The inode/dentry being altered
+ * @path:	The inode/path being altered
  * @name:	The name of the xattr to be changed
  *
  * Determine whether an xattr may be removed from an inode, returning 0 if
  * permission is granted, -ve if denied.
  *
- * If the inode has been found through an idmapped mount the idmap of
- * the vfsmount must be passed through @idmap. This function will then
- * take care to map the inode according to @idmap before checking
- * permissions. On non-idmapped mounts or if permission checking is to be
- * performed on the raw inode simply pass @nop_mnt_idmap.
- *
  * This is used to make sure security xattrs don't get removed by those who
  * aren't privileged to remove them.
  */
-int cap_inode_removexattr(const struct mnt_idmap *idmap,
-			  struct dentry *dentry, const char *name)
+int cap_inode_removexattr(const struct path *path, const char *name)
 {
+	struct dentry *dentry = path->dentry;
 	struct user_namespace *user_ns = dentry->d_sb->s_user_ns;
 
 	/* Ignore non-security xattrs */
@@ -1075,7 +1070,8 @@ int cap_inode_removexattr(const struct mnt_idmap *idmap,
 		struct inode *inode = d_backing_inode(dentry);
 		if (!inode)
 			return -EINVAL;
-		if (!capable_wrt_inode_uidgid(idmap, inode, CAP_SETFCAP))
+		if (!capable_wrt_inode_uidgid(mnt_idmap(path->mnt), inode,
+					      CAP_SETFCAP))
 			return -EPERM;
 		return 0;
 	}
diff --git a/security/integrity/evm/evm_main.c b/security/integrity/evm/evm_main.c
index 61460e3caedc..bd1cec1aa074 100644
--- a/security/integrity/evm/evm_main.c
+++ b/security/integrity/evm/evm_main.c
@@ -594,8 +594,7 @@ static int evm_protect_xattr(const struct mnt_idmap *idmap,
 
 /**
  * evm_inode_setxattr - protect the EVM extended attribute
- * @idmap: idmap of the mount
- * @dentry: pointer to the affected dentry
+ * @path: pointer to the affected object
  * @xattr_name: pointer to the affected extended attribute name
  * @xattr_value: pointer to the new extended attribute value
  * @xattr_value_len: pointer to the new extended attribute value length
@@ -607,11 +606,13 @@ static int evm_protect_xattr(const struct mnt_idmap *idmap,
  * userspace from writing HMAC value.  Writing 'security.evm' requires
  * requires CAP_SYS_ADMIN privileges.
  */
-static int evm_inode_setxattr(const struct mnt_idmap *idmap, struct dentry *dentry,
+static int evm_inode_setxattr(const struct path *path,
 			      const char *xattr_name, const void *xattr_value,
 			      size_t xattr_value_len, int flags)
 {
 	const struct evm_ima_xattr_data *xattr_data = xattr_value;
+	struct dentry *dentry = path->dentry;
+	const struct mnt_idmap *idmap = mnt_idmap(path->mnt);
 
 	/* Policy permits modification of the protected xattrs even though
 	 * there's no HMAC key loaded
@@ -632,16 +633,18 @@ static int evm_inode_setxattr(const struct mnt_idmap *idmap, struct dentry *dent
 
 /**
  * evm_inode_removexattr - protect the EVM extended attribute
- * @idmap: idmap of the mount
- * @dentry: pointer to the affected dentry
+ * @path: pointer to the affected object
  * @xattr_name: pointer to the affected extended attribute name
  *
  * Removing 'security.evm' requires CAP_SYS_ADMIN privileges and that
  * the current value is valid.
  */
-static int evm_inode_removexattr(const struct mnt_idmap *idmap, struct dentry *dentry,
+static int evm_inode_removexattr(const struct path *path,
 				 const char *xattr_name)
 {
+	struct dentry *dentry = path->dentry;
+	const struct mnt_idmap *idmap = mnt_idmap(path->mnt);
+
 	/* Policy permits modification of the protected xattrs even though
 	 * there's no HMAC key loaded
 	 */
diff --git a/security/integrity/ima/ima_appraise.c b/security/integrity/ima/ima_appraise.c
index 134174d2e3f0..2479bd78a17f 100644
--- a/security/integrity/ima/ima_appraise.c
+++ b/security/integrity/ima/ima_appraise.c
@@ -759,11 +759,12 @@ static int validate_hash_algo(struct dentry *dentry,
 	return -EACCES;
 }
 
-static int ima_inode_setxattr(const struct mnt_idmap *idmap, struct dentry *dentry,
+static int ima_inode_setxattr(const struct path *path,
 			      const char *xattr_name, const void *xattr_value,
 			      size_t xattr_value_len, int flags)
 {
 	const struct evm_ima_xattr_data *xvalue = xattr_value;
+	struct dentry *dentry = path->dentry;
 	int digsig = 0;
 	int result;
 	int err;
@@ -801,16 +802,16 @@ static int ima_inode_set_acl(const struct mnt_idmap *idmap, struct dentry *dentr
 	return 0;
 }
 
-static int ima_inode_removexattr(const struct mnt_idmap *idmap, struct dentry *dentry,
+static int ima_inode_removexattr(const struct path *path,
 				 const char *xattr_name)
 {
 	int result, digsig = -1;
 
-	result = ima_protect_xattr(dentry, xattr_name, NULL, 0);
+	result = ima_protect_xattr(path->dentry, xattr_name, NULL, 0);
 	if (result == 1 || evm_revalidate_status(xattr_name)) {
 		if (!strcmp(xattr_name, XATTR_NAME_IMA))
 			digsig = 0;
-		ima_reset_appraise_flags(d_backing_inode(dentry), digsig);
+		ima_reset_appraise_flags(d_backing_inode(path->dentry), digsig);
 		if (result == 1)
 			result = 0;
 	}
diff --git a/security/security.c b/security/security.c
index 5f2cd3e89d65..229242a1b2b1 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1942,15 +1942,14 @@ int security_inode_getattr(const struct path *path)
 
 /**
  * security_inode_setxattr() - Check if setting file xattrs is allowed
- * @idmap: idmap of the mount
- * @dentry: file
+ * @path: file
  * @name: xattr name
  * @value: xattr value
  * @size: size of xattr value
  * @flags: flags
  *
  * This hook performs the desired permission checks before setting the extended
- * attributes (xattrs) on @dentry.  It is important to note that we have some
+ * attributes (xattrs) on @path.  It is important to note that we have some
  * additional logic before the main LSM implementation calls to detect if we
  * need to perform an additional capability check at the LSM layer.
  *
@@ -1966,23 +1965,23 @@ int security_inode_getattr(const struct path *path)
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_setxattr(const struct mnt_idmap *idmap,
-			    struct dentry *dentry, const char *name,
-			    const void *value, size_t size, int flags)
+int security_inode_setxattr(const struct path *path,
+			    const char *name, const void *value,
+			    size_t size, int flags)
 {
 	int rc;
 
-	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
+	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
 
 	/* enforce the capability checks at the lsm layer, if needed */
 	if (!call_int_hook(inode_xattr_skipcap, name)) {
-		rc = cap_inode_setxattr(dentry, name, value, size, flags);
+		rc = cap_inode_setxattr(path, name, value, size, flags);
 		if (rc)
 			return rc;
 	}
 
-	return call_int_hook(inode_setxattr, idmap, dentry, name, value, size,
+	return call_int_hook(inode_setxattr, path, name, value, size,
 			     flags);
 }
 
@@ -2099,45 +2098,44 @@ void security_inode_post_setxattr(struct dentry *dentry, const char *name,
 
 /**
  * security_inode_getxattr() - Check if xattr access is allowed
- * @dentry: file
+ * @path: file
  * @name: xattr name
  *
  * Check permission before obtaining the extended attributes identified by
- * @name for @dentry.
+ * @name for @path.
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_getxattr(struct dentry *dentry, const char *name)
+int security_inode_getxattr(const struct path *path, const char *name)
 {
-	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
+	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_getxattr, dentry, name);
+	return call_int_hook(inode_getxattr, path, name);
 }
 
 /**
  * security_inode_listxattr() - Check if listing xattrs is allowed
- * @dentry: file
+ * @path: file
  *
  * Check permission before obtaining the list of extended attribute names for
- * @dentry.
+ * @path.
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_listxattr(struct dentry *dentry)
+int security_inode_listxattr(const struct path *path)
 {
-	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
+	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_listxattr, dentry);
+	return call_int_hook(inode_listxattr, path);
 }
 
 /**
  * security_inode_removexattr() - Check if removing an xattr is allowed
- * @idmap: idmap of the mount
- * @dentry: file
+ * @path: file
  * @name: xattr name
  *
  * This hook performs the desired permission checks before setting the extended
- * attributes (xattrs) on @dentry.  It is important to note that we have some
+ * attributes (xattrs) on @path.  It is important to note that we have some
  * additional logic before the main LSM implementation calls to detect if we
  * need to perform an additional capability check at the LSM layer.
  *
@@ -2153,22 +2151,21 @@ int security_inode_listxattr(struct dentry *dentry)
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_removexattr(const struct mnt_idmap *idmap,
-			       struct dentry *dentry, const char *name)
+int security_inode_removexattr(const struct path *path, const char *name)
 {
 	int rc;
 
-	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
+	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
 
 	/* enforce the capability checks at the lsm layer, if needed */
 	if (!call_int_hook(inode_xattr_skipcap, name)) {
-		rc = cap_inode_removexattr(idmap, dentry, name);
+		rc = cap_inode_removexattr(path, name);
 		if (rc)
 			return rc;
 	}
 
-	return call_int_hook(inode_removexattr, idmap, dentry, name);
+	return call_int_hook(inode_removexattr, path, name);
 }
 
 /**
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index cc43e08e68c5..250401461684 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3417,10 +3417,12 @@ static int selinux_inode_xattr_skipcap(const char *name)
 	return !strcmp(name, XATTR_NAME_SELINUX);
 }
 
-static int selinux_inode_setxattr(const struct mnt_idmap *idmap,
-				  struct dentry *dentry, const char *name,
-				  const void *value, size_t size, int flags)
+static int selinux_inode_setxattr(const struct path *path,
+				  const char *name, const void *value,
+				  size_t size, int flags)
 {
+	struct dentry *dentry = path->dentry;
+	const struct mnt_idmap *idmap = mnt_idmap(path->mnt);
 	struct inode *inode = d_backing_inode(dentry);
 	struct inode_security_struct *isec;
 	struct superblock_security_struct *sbsec;
@@ -3562,26 +3564,27 @@ static void selinux_inode_post_setxattr(struct dentry *dentry, const char *name,
 	spin_unlock(&isec->lock);
 }
 
-static int selinux_inode_getxattr(struct dentry *dentry, const char *name)
+static int selinux_inode_getxattr(const struct path *path, const char *name)
 {
 	const struct cred *cred = current_cred();
 
-	return dentry_has_perm(cred, dentry, FILE__GETATTR);
+	return dentry_has_perm(cred, path->dentry, FILE__GETATTR);
 }
 
-static int selinux_inode_listxattr(struct dentry *dentry)
+static int selinux_inode_listxattr(const struct path *path)
 {
 	const struct cred *cred = current_cred();
 
-	return dentry_has_perm(cred, dentry, FILE__GETATTR);
+	return dentry_has_perm(cred, path->dentry, FILE__GETATTR);
 }
 
-static int selinux_inode_removexattr(const struct mnt_idmap *idmap,
-				     struct dentry *dentry, const char *name)
+static int selinux_inode_removexattr(const struct path *path,
+				     const char *name)
 {
 	/* if not a selinux xattr, only check the ordinary setattr perm */
 	if (strcmp(name, XATTR_NAME_SELINUX))
-		return dentry_has_perm(current_cred(), dentry, FILE__SETATTR);
+		return dentry_has_perm(current_cred(), path->dentry,
+				       FILE__SETATTR);
 
 	if (!selinux_initialized())
 		return 0;
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index fdc74ca0e870..fe11b06475bd 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1351,11 +1351,12 @@ static int smack_inode_xattr_skipcap(const char *name)
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_setxattr(const struct mnt_idmap *idmap,
-				struct dentry *dentry, const char *name,
-				const void *value, size_t size, int flags)
+static int smack_inode_setxattr(const struct path *path,
+				const char *name, const void *value,
+				size_t size, int flags)
 {
 	struct smk_audit_info ad;
+	struct dentry *dentry = path->dentry;
 	struct smack_known *skp;
 	int check_priv = 0;
 	int check_import = 0;
@@ -1462,9 +1463,10 @@ static void smack_inode_post_setxattr(struct dentry *dentry, const char *name,
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_getxattr(struct dentry *dentry, const char *name)
+static int smack_inode_getxattr(const struct path *path, const char *name)
 {
 	struct smk_audit_info ad;
+	struct dentry *dentry = path->dentry;
 	int rc;
 
 	smk_ad_init(&ad, __func__, LSM_AUDIT_DATA_DENTRY);
@@ -1477,19 +1479,19 @@ static int smack_inode_getxattr(struct dentry *dentry, const char *name)
 
 /**
  * smack_inode_removexattr - Smack check on removexattr
- * @idmap: idmap of the mount
- * @dentry: the object
+ * @path: the object
  * @name: name of the attribute
  *
  * Removing the Smack attribute requires CAP_MAC_ADMIN
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_removexattr(const struct mnt_idmap *idmap,
-				   struct dentry *dentry, const char *name)
+static int smack_inode_removexattr(const struct path *path,
+				   const char *name)
 {
 	struct inode_smack *isp;
 	struct smk_audit_info ad;
+	struct dentry *dentry = path->dentry;
 	int rc = 0;
 
 	if (strcmp(name, XATTR_NAME_SMACK) == 0 ||
diff --git a/tools/testing/selftests/bpf/progs/test_get_xattr.c b/tools/testing/selftests/bpf/progs/test_get_xattr.c
index 54305f4c9f2d..5c49c3ab2e69 100644
--- a/tools/testing/selftests/bpf/progs/test_get_xattr.c
+++ b/tools/testing/selftests/bpf/progs/test_get_xattr.c
@@ -56,7 +56,7 @@ int BPF_PROG(test_file_open, struct file *f)
 }
 
 SEC("lsm.s/inode_getxattr")
-int BPF_PROG(test_inode_getxattr, struct dentry *dentry, char *name)
+int BPF_PROG(test_inode_getxattr, const struct path *path, char *name)
 {
 	struct bpf_dynptr value_ptr;
 	__u32 pid;
@@ -69,7 +69,7 @@ int BPF_PROG(test_inode_getxattr, struct dentry *dentry, char *name)
 	bpf_dynptr_from_mem(value2, sizeof(value2), 0, &value_ptr);
 
 	for (i = 0; i < ARRAY_SIZE(xattr_names); i++) {
-		ret = bpf_get_dentry_xattr(dentry, xattr_names[i], &value_ptr);
+		ret = bpf_get_dentry_xattr(path->dentry, xattr_names[i], &value_ptr);
 		if (ret == sizeof(expected_value))
 			break;
 	}
diff --git a/tools/testing/selftests/bpf/progs/test_set_remove_xattr.c b/tools/testing/selftests/bpf/progs/test_set_remove_xattr.c
index 6a612cf168d3..006c97eee80e 100644
--- a/tools/testing/selftests/bpf/progs/test_set_remove_xattr.c
+++ b/tools/testing/selftests/bpf/progs/test_set_remove_xattr.c
@@ -33,7 +33,7 @@ static inline bool name_match_foo(const char *name)
 
 /* Test bpf_set_dentry_xattr and bpf_remove_dentry_xattr */
 SEC("lsm.s/inode_getxattr")
-int BPF_PROG(test_inode_getxattr, struct dentry *dentry, char *name)
+int BPF_PROG(test_inode_getxattr, const struct path *path, char *name)
 {
 	struct bpf_dynptr value_ptr;
 	__u32 pid;
@@ -50,25 +50,25 @@ int BPF_PROG(test_inode_getxattr, struct dentry *dentry, char *name)
 	bpf_dynptr_from_mem(read_value, sizeof(read_value), 0, &value_ptr);
 
 	/* read security.bpf.bar */
-	ret = bpf_get_dentry_xattr(dentry, xattr_bar, &value_ptr);
+	ret = bpf_get_dentry_xattr(path->dentry, xattr_bar, &value_ptr);
 
 	if (ret < 0) {
 		/* If security.bpf.bar doesn't exist, set it */
 		bpf_dynptr_from_mem(value_bar, sizeof(value_bar), 0, &value_ptr);
 
-		ret = bpf_set_dentry_xattr(dentry, xattr_bar, &value_ptr, 0);
+		ret = bpf_set_dentry_xattr(path->dentry, xattr_bar, &value_ptr, 0);
 		if (!ret)
 			set_security_bpf_bar_success = true;
-		ret = bpf_set_dentry_xattr(dentry, xattr_selinux, &value_ptr, 0);
+		ret = bpf_set_dentry_xattr(path->dentry, xattr_selinux, &value_ptr, 0);
 		if (ret)
 			set_security_selinux_fail = true;
 	} else {
 		/* If security.bpf.bar exists, remove it */
-		ret = bpf_remove_dentry_xattr(dentry, xattr_bar);
+		ret = bpf_remove_dentry_xattr(path->dentry, xattr_bar);
 		if (!ret)
 			remove_security_bpf_bar_success = true;
 
-		ret = bpf_remove_dentry_xattr(dentry, xattr_selinux);
+		ret = bpf_remove_dentry_xattr(path->dentry, xattr_selinux);
 		if (ret)
 			remove_security_selinux_fail = true;
 	}
@@ -87,9 +87,8 @@ bool locked_remove_security_selinux_fail;
  * properly.
  */
 SEC("lsm.s/inode_setxattr")
-int BPF_PROG(test_inode_setxattr, struct mnt_idmap *idmap,
-	     struct dentry *dentry, const char *name,
-	     const void *value, size_t size, int flags)
+int BPF_PROG(test_inode_setxattr, const struct path *path,
+	     const char *name, const void *value, size_t size, int flags)
 {
 	struct bpf_dynptr value_ptr;
 	__u32 pid;
@@ -106,25 +105,25 @@ int BPF_PROG(test_inode_setxattr, struct mnt_idmap *idmap,
 	bpf_dynptr_from_mem(read_value, sizeof(read_value), 0, &value_ptr);
 
 	/* read security.bpf.bar */
-	ret = bpf_get_dentry_xattr(dentry, xattr_bar, &value_ptr);
+	ret = bpf_get_dentry_xattr(path->dentry, xattr_bar, &value_ptr);
 
 	if (ret < 0) {
 		/* If security.bpf.bar doesn't exist, set it */
 		bpf_dynptr_from_mem(value_bar, sizeof(value_bar), 0, &value_ptr);
 
-		ret = bpf_set_dentry_xattr(dentry, xattr_bar, &value_ptr, 0);
+		ret = bpf_set_dentry_xattr(path->dentry, xattr_bar, &value_ptr, 0);
 		if (!ret)
 			locked_set_security_bpf_bar_success = true;
-		ret = bpf_set_dentry_xattr(dentry, xattr_selinux, &value_ptr, 0);
+		ret = bpf_set_dentry_xattr(path->dentry, xattr_selinux, &value_ptr, 0);
 		if (ret)
 			locked_set_security_selinux_fail = true;
 	} else {
 		/* If security.bpf.bar exists, remove it */
-		ret = bpf_remove_dentry_xattr(dentry, xattr_bar);
+		ret = bpf_remove_dentry_xattr(path->dentry, xattr_bar);
 		if (!ret)
 			locked_remove_security_bpf_bar_success = true;
 
-		ret = bpf_remove_dentry_xattr(dentry, xattr_selinux);
+		ret = bpf_remove_dentry_xattr(path->dentry, xattr_selinux);
 		if (ret)
 			locked_remove_security_selinux_fail = true;
 	}
diff --git a/tools/testing/selftests/bpf/progs/verifier_lsm_init_xattr.c b/tools/testing/selftests/bpf/progs/verifier_lsm_init_xattr.c
index b706bf17b556..ef170366dc04 100644
--- a/tools/testing/selftests/bpf/progs/verifier_lsm_init_xattr.c
+++ b/tools/testing/selftests/bpf/progs/verifier_lsm_init_xattr.c
@@ -234,7 +234,7 @@ int BPF_PROG(reject_lsm_cgroup, struct inode *inode, struct inode *dir,
 
 SEC("lsm/inode_setxattr")
 __failure __msg("calling kernel function bpf_inode_init_xattr is not allowed")
-int BPF_PROG(reject_wrong_hook, struct mnt_idmap *idmap, struct dentry *dentry,
+int BPF_PROG(reject_wrong_hook, const struct path *path,
 	     const char *name, const void *value, size_t size, int flags)
 {
 	struct bpf_dynptr val;
-- 
2.18.0.huawei.25

