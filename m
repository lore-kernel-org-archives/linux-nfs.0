Received: from canpmsgout12.his.huawei.com (canpmsgout12.his.huawei.com [113.46.200.227])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 268B34734EE;
	Thu, 24 Sep 2026 10:22:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.227
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790245379; cv=none; b=loDVoCKvn9es3EPvl1pK7dc5uiC/vHOf5cpahAKXveRdq+Z8QwecceZT2H29HDmu9dLWMpIGRmx6cbvbCsapmN7J7sn6Qo82n/SM343euUfxoor8w78LlNE1dFhJbslNwr0U7ps9DPUmgT/qjA9ABD7RUvmrATJYS08q8mcpZjk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790245379; c=relaxed/simple;
	bh=HFIeNbCDQvHOZUpb97fVJuTD5Xfvj0xr/vLW1HLndgU=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=H2yS0XM5R7CVs1MwzTIuzE3X3sbFnalDrwKPg3C1NnCVhCrsga2zvtLhU2eaGypucII5UuY+xqZ+AeDLZ16bZoaRYPQ4B7WdZL70tnVsIxiifCKRNr7pfkY9lYYyVBf0IwzMaeOFHUKto1KSwrqL+md0T3B6NwSsdw7qmLSdtrw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=izv1kzjI; arc=none smtp.client-ip=113.46.200.227
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="izv1kzjI"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=UBErxReQP/m4dnSx4/Ks3qpJsicn/oLlYlbYKKe9S+k=;
	b=izv1kzjIiGJXxTPwJBhi2JyZnREsN1wNLfMFHTPYK+XZt8nzP/VYr6DunF0XLIXF/P5eNOn6m
	G4Tel+7GUzBoANwsfB6l50yA3Eql/d3sAjTeGiX9xhYvWQDTmAaP+MMQOT6nQ38/FOAMIwtwhCE
	Az5bCnDi7rVBPBEl/M2fRCs=
Received: from mail.maildlp.com (unknown [172.19.163.214])
	by canpmsgout12.his.huawei.com (SkyGuard) with ESMTPS id 4hr8jj6BBYznTyW;
	Thu, 24 Sep 2026 18:10:49 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 9C4354057C;
	Thu, 24 Sep 2026 18:22:53 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 24 Sep 2026 18:22:49 +0800
From: Cai Xinchen <caixinchen1@huawei.com>
To: <mic@digikod.net>, <gnoack@google.com>, <paul@paul-moore.com>,
	<jmorris@namei.org>, <serge@hallyn.com>, <corbet@lwn.net>,
	<skhan@linuxfoundation.org>
CC: <rdunlap@infradead.org>, <gregkh@linuxfoundation.org>,
	<rafael@kernel.org>, <dakr@kernel.org>, <dlemoal@kernel.org>, <hch@lst.de>,
	<axboe@kernel.dk>, <viro@zeniv.linux.org.uk>, <brauner@kernel.org>,
	<jack@suse.cz>, <dhowells@redhat.com>, <code@tyhicks.com>,
	<linkinjeon@kernel.org>, <sj1557.seo@samsung.com>, <yuezhang.mo@sony.com>,
	<hirofumi@mail.parknet.co.jp>, <cel@kernel.org>, <jlayton@kernel.org>,
	<neil@brown.name>, <okorniev@redhat.com>, <Dai.Ngo@oracle.com>,
	<tom@talpey.com>, <miklos@szeredi.hu>, <amir73il@gmail.com>,
	<senozhatsky@chromium.org>, <chenxiaosong@chenxiaosong.com>,
	<zohar@linux.ibm.com>, <roberto.sassu@huawei.com>,
	<dmitry.kasatkin@gmail.com>, <eric.snowberg@oracle.com>,
	<stephen.smalley.work@gmail.com>, <omosnacek@gmail.com>,
	<casey@schaufler-ca.com>, <nanx95726@gmail.com>, <djwong@kernel.org>,
	<daniel@iogearbox.net>, <linux-security-module@vger.kernel.org>,
	<linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<driver-core@lists.linux.dev>, <linux-block@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <netfs@lists.linux.dev>,
	<ecryptfs@vger.kernel.org>, <exfat@lists.linux.dev>,
	<linux-nfs@vger.kernel.org>, <linux-unionfs@vger.kernel.org>,
	<linux-cifs@vger.kernel.org>, <linux-integrity@vger.kernel.org>,
	<selinux@vger.kernel.org>, <linux-kselftest@vger.kernel.org>,
	<xiujianfeng@huawei.com>, <caixinchen1@huawei.com>, <lujialin4@huawei.com>
Subject: [PATCH RFC -next 06/12] LSM: pass struct path to the inode xattr hooks
Date: Thu, 24 Sep 2026 18:48:25 +0800
Message-ID: <20260924104831.1081137-7-caixinchen1@huawei.com>
X-Mailer: git-send-email 2.18.0.huawei.25
In-Reply-To: <20260924104831.1081137-1-caixinchen1@huawei.com>
References: <20260924104831.1081137-1-caixinchen1@huawei.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
X-ClientProxiedBy: kwepems200001.china.huawei.com (7.221.188.67) To
 whupemk100010.china.huawei.com (7.152.184.41)

The inode_setxattr, inode_getxattr, inode_listxattr and
inode_removexattr hooks are called from fs/xattr.c, whose helpers
now hold a struct path and used to derive the idmap and dentry from
it just for the hook calls.

Convert the hooks and their commoncap, SELinux, Smack, EVM and IMA
implementations to take a const struct path.  The implementations
derive the idmap and dentry they still need from the path, so this
is a purely mechanical change with no behavior change.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/xattr.c                            |  8 ++---
 include/linux/lsm_hook_defs.h         | 13 ++++---
 include/linux/security.h              | 35 +++++++++---------
 security/commoncap.c                  | 22 +++++-------
 security/integrity/evm/evm_main.c     | 15 ++++----
 security/integrity/ima/ima_appraise.c |  9 ++---
 security/security.c                   | 51 +++++++++++++--------------
 security/selinux/hooks.c              | 23 ++++++------
 security/smack/smack_lsm.c            | 18 +++++-----
 9 files changed, 96 insertions(+), 98 deletions(-)

diff --git a/fs/xattr.c b/fs/xattr.c
index ee4a5f6d7ef3..7f09307d6845 100644
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
index b54fdf7d32e8..3a3512a3ee91 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -148,15 +148,14 @@ LSM_HOOK(void, LSM_RET_VOID, inode_post_setattr, struct mnt_idmap *idmap,
 	 struct dentry *dentry, int ia_valid)
 LSM_HOOK(int, 0, inode_getattr, const struct path *path)
 LSM_HOOK(int, 0, inode_xattr_skipcap, const char *name)
-LSM_HOOK(int, 0, inode_setxattr, struct mnt_idmap *idmap,
-	 struct dentry *dentry, const char *name, const void *value,
-	 size_t size, int flags)
+LSM_HOOK(int, 0, inode_setxattr, const struct path *path,
+	 const char *name, const void *value, size_t size, int flags)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_setxattr, struct dentry *dentry,
 	 const char *name, const void *value, size_t size, int flags)
-LSM_HOOK(int, 0, inode_getxattr, struct dentry *dentry, const char *name)
-LSM_HOOK(int, 0, inode_listxattr, struct dentry *dentry)
-LSM_HOOK(int, 0, inode_removexattr, struct mnt_idmap *idmap,
-	 struct dentry *dentry, const char *name)
+LSM_HOOK(int, 0, inode_getxattr, const struct path *path, const char *name)
+LSM_HOOK(int, 0, inode_listxattr, const struct path *path)
+LSM_HOOK(int, 0, inode_removexattr, const struct path *path,
+	 const char *name)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_removexattr, struct dentry *dentry,
 	 const char *name)
 LSM_HOOK(int, 0, inode_file_setattr, struct dentry *dentry, struct file_kattr *fa)
diff --git a/include/linux/security.h b/include/linux/security.h
index 09c14c83e58f..f5dc67a937bd 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -185,10 +185,9 @@ extern int cap_capset(struct cred *new, const struct cred *old,
 		      const kernel_cap_t *inheritable,
 		      const kernel_cap_t *permitted);
 extern int cap_bprm_creds_from_file(struct linux_binprm *bprm, const struct file *file);
-int cap_inode_setxattr(struct dentry *dentry, const char *name,
+int cap_inode_setxattr(const struct path *path, const char *name,
 		       const void *value, size_t size, int flags);
-int cap_inode_removexattr(struct mnt_idmap *idmap,
-			  struct dentry *dentry, const char *name);
+int cap_inode_removexattr(const struct path *path, const char *name);
 int cap_inode_need_killpriv(struct dentry *dentry);
 int cap_inode_killpriv(struct mnt_idmap *idmap, struct dentry *dentry);
 int cap_inode_getsecurity(struct mnt_idmap *idmap,
@@ -433,9 +432,9 @@ int security_inode_setattr(const struct path *path, struct iattr *attr);
 void security_inode_post_setattr(struct mnt_idmap *idmap, struct dentry *dentry,
 				 int ia_valid);
 int security_inode_getattr(const struct path *path);
-int security_inode_setxattr(struct mnt_idmap *idmap,
-			    struct dentry *dentry, const char *name,
-			    const void *value, size_t size, int flags);
+int security_inode_setxattr(const struct path *path,
+			    const char *name, const void *value,
+			    size_t size, int flags);
 int security_inode_set_acl(struct mnt_idmap *idmap,
 			   struct dentry *dentry, const char *acl_name,
 			   struct posix_acl *kacl);
@@ -450,10 +449,10 @@ void security_inode_post_remove_acl(struct mnt_idmap *idmap,
 				    const char *acl_name);
 void security_inode_post_setxattr(struct dentry *dentry, const char *name,
 				  const void *value, size_t size, int flags);
-int security_inode_getxattr(struct dentry *dentry, const char *name);
-int security_inode_listxattr(struct dentry *dentry);
-int security_inode_removexattr(struct mnt_idmap *idmap,
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
 
-static inline int security_inode_setxattr(struct mnt_idmap *idmap,
-		struct dentry *dentry, const char *name, const void *value,
-		size_t size, int flags)
+static inline int security_inode_setxattr(const struct path *path,
+		const char *name, const void *value, size_t size, int flags)
 {
-	return cap_inode_setxattr(dentry, name, value, size, flags);
+	return cap_inode_setxattr(path, name, value, size, flags);
 }
 
 static inline int security_inode_set_acl(struct mnt_idmap *idmap,
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
 
-static inline int security_inode_removexattr(struct mnt_idmap *idmap,
-					     struct dentry *dentry,
+static inline int security_inode_removexattr(const struct path *path,
 					     const char *name)
 {
-	return cap_inode_removexattr(idmap, dentry, name);
+	return cap_inode_removexattr(path, name);
 }
 
 static inline void security_inode_post_removexattr(struct dentry *dentry,
diff --git a/security/commoncap.c b/security/commoncap.c
index c5d2f263d75b..9a185a6036af 100644
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
-int cap_inode_removexattr(struct mnt_idmap *idmap,
-			  struct dentry *dentry, const char *name)
+int cap_inode_removexattr(const struct path *path, const char *name)
 {
+	struct dentry *dentry = path->dentry;
 	struct user_namespace *user_ns = dentry->d_sb->s_user_ns;
 
 	/* Ignore non-security xattrs */
@@ -1075,7 +1070,8 @@ int cap_inode_removexattr(struct mnt_idmap *idmap,
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
index b0af1bf86ab5..47ad39d64c76 100644
--- a/security/integrity/evm/evm_main.c
+++ b/security/integrity/evm/evm_main.c
@@ -594,8 +594,7 @@ static int evm_protect_xattr(struct mnt_idmap *idmap,
 
 /**
  * evm_inode_setxattr - protect the EVM extended attribute
- * @idmap: idmap of the mount
- * @dentry: pointer to the affected dentry
+ * @path: pointer to the affected object
  * @xattr_name: pointer to the affected extended attribute name
  * @xattr_value: pointer to the new extended attribute value
  * @xattr_value_len: pointer to the new extended attribute value length
@@ -607,11 +606,13 @@ static int evm_protect_xattr(struct mnt_idmap *idmap,
  * userspace from writing HMAC value.  Writing 'security.evm' requires
  * requires CAP_SYS_ADMIN privileges.
  */
-static int evm_inode_setxattr(struct mnt_idmap *idmap, struct dentry *dentry,
+static int evm_inode_setxattr(const struct path *path,
 			      const char *xattr_name, const void *xattr_value,
 			      size_t xattr_value_len, int flags)
 {
 	const struct evm_ima_xattr_data *xattr_data = xattr_value;
+	struct dentry *dentry = path->dentry;
+	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
 
 	/* Policy permits modification of the protected xattrs even though
 	 * there's no HMAC key loaded
@@ -632,16 +633,18 @@ static int evm_inode_setxattr(struct mnt_idmap *idmap, struct dentry *dentry,
 
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
-static int evm_inode_removexattr(struct mnt_idmap *idmap, struct dentry *dentry,
+static int evm_inode_removexattr(const struct path *path,
 				 const char *xattr_name)
 {
+	struct dentry *dentry = path->dentry;
+	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
+
 	/* Policy permits modification of the protected xattrs even though
 	 * there's no HMAC key loaded
 	 */
diff --git a/security/integrity/ima/ima_appraise.c b/security/integrity/ima/ima_appraise.c
index b280488e15fc..58ba674bc172 100644
--- a/security/integrity/ima/ima_appraise.c
+++ b/security/integrity/ima/ima_appraise.c
@@ -759,11 +759,12 @@ static int validate_hash_algo(struct dentry *dentry,
 	return -EACCES;
 }
 
-static int ima_inode_setxattr(struct mnt_idmap *idmap, struct dentry *dentry,
+static int ima_inode_setxattr(const struct path *path,
 			      const char *xattr_name, const void *xattr_value,
 			      size_t xattr_value_len, int flags)
 {
 	const struct evm_ima_xattr_data *xvalue = xattr_value;
+	struct dentry *dentry = path->dentry;
 	int digsig = 0;
 	int result;
 	int err;
@@ -801,16 +802,16 @@ static int ima_inode_set_acl(struct mnt_idmap *idmap, struct dentry *dentry,
 	return 0;
 }
 
-static int ima_inode_removexattr(struct mnt_idmap *idmap, struct dentry *dentry,
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
index ce74b9f1d110..3a8892d8ca5c 100644
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
-int security_inode_setxattr(struct mnt_idmap *idmap,
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
-int security_inode_removexattr(struct mnt_idmap *idmap,
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
index 49785dd62df4..5d98ec73df9f 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3410,10 +3410,12 @@ static int selinux_inode_xattr_skipcap(const char *name)
 	return !strcmp(name, XATTR_NAME_SELINUX);
 }
 
-static int selinux_inode_setxattr(struct mnt_idmap *idmap,
-				  struct dentry *dentry, const char *name,
-				  const void *value, size_t size, int flags)
+static int selinux_inode_setxattr(const struct path *path,
+				  const char *name, const void *value,
+				  size_t size, int flags)
 {
+	struct dentry *dentry = path->dentry;
+	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
 	struct inode *inode = d_backing_inode(dentry);
 	struct inode_security_struct *isec;
 	struct superblock_security_struct *sbsec;
@@ -3555,26 +3557,27 @@ static void selinux_inode_post_setxattr(struct dentry *dentry, const char *name,
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
 
-static int selinux_inode_removexattr(struct mnt_idmap *idmap,
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
index 991b967c4c4e..4adb2fd9cf70 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1351,11 +1351,12 @@ static int smack_inode_xattr_skipcap(const char *name)
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_setxattr(struct mnt_idmap *idmap,
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
-static int smack_inode_removexattr(struct mnt_idmap *idmap,
-				   struct dentry *dentry, const char *name)
+static int smack_inode_removexattr(const struct path *path,
+				   const char *name)
 {
 	struct inode_smack *isp;
 	struct smk_audit_info ad;
+	struct dentry *dentry = path->dentry;
 	int rc = 0;
 
 	if (strcmp(name, XATTR_NAME_SMACK) == 0 ||
-- 
2.18.0.huawei.25

