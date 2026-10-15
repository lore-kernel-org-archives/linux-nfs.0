Received: from canpmsgout04.his.huawei.com (canpmsgout04.his.huawei.com [113.46.200.219])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F3D73521881;
	Thu, 15 Oct 2026 12:20:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.219
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792066832; cv=none; b=pMVv3yW1BzzZmgP+p7MhWSVNsDGichrGWj+s8iQ9WHr3PeP3Ph0MvIwzcA6znHm4OrWkI9biUHlrG2NGecQ8xZONe6SPd1zYQc4N1CeQo9kzdx29hZ6+rpL0XOnuXCc+HfZvtkzXZMp0GilrrRU7Y8CN9F6dy1p4G6JbSChif3A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792066832; c=relaxed/simple;
	bh=8I3xNHAloRIAY7xCqht4/QMBB42cU6CBpMXELLxFR84=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=CJ+AEsP886Bb0wmdTtIC5rVnYz6wz4a8ROBleRbcrRyfKqxJmzgDHgwlKS7JUaGm0yy1eCJs0NcQjBUVHqnkVZqXoxm/1AZ7X8AsxPkejNx4ylR4+RkFE0AHsABTEOVV+tHxeyrQ+8V2/WoZYRVfIkhmhzTkBblwdmodKAstDs0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=AVPuOh0g; arc=none smtp.client-ip=113.46.200.219
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="AVPuOh0g"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=RgVFRgwYhyDNHQAM2usvlL4FprtvqGy/kfDYRb0w+zQ=;
	b=AVPuOh0gTGdt7BnaPlgUiyQRN8uh/px5fzD2ZuHV2lkROn/iKH9mB0NyxULxrmd301qSGNMfE
	HJCTJAkP0DWpEJSozRXou1I8uVFt4CPnW51ismb06GKvq5Mts1zTi+kUiO7f0immOpK6fHcDlzf
	Jlk7buQYltm+GMganfLaems=
Received: from mail.maildlp.com (unknown [172.19.163.0])
	by canpmsgout04.his.huawei.com (SkyGuard) with ESMTPS id 4j56KF1tCDz1prN4;
	Thu, 15 Oct 2026 20:08:01 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 93B9A40537;
	Thu, 15 Oct 2026 20:20:21 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 15 Oct 2026 20:20:16 +0800
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
Subject: [PATCH v2 -next 07/18] LSM: pass struct path to the inode posix acl hooks
Date: Thu, 15 Oct 2026 20:54:13 +0800
Message-ID: <20261015125425.3246251-8-caixinchen1@huawei.com>
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

The inode_set_acl, inode_get_acl and inode_remove_acl hooks are
called from fs/posix_acl.c, whose helpers now hold a struct path and
used to derive the idmap and dentry from it just for the hook calls.

Convert the hooks and their SELinux, Smack, EVM and IMA
implementations to take a const struct path.  The implementations
derive the idmap and dentry they still need from the path, so this
is a purely mechanical change with no behavior change.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/posix_acl.c                        |  6 ++---
 include/linux/lsm_hook_defs.h         | 12 ++++-----
 include/linux/security.h              | 20 +++++----------
 security/integrity/evm/evm_main.c     | 14 +++++-----
 security/integrity/ima/ima_appraise.c |  8 +++---
 security/security.c                   | 32 ++++++++++-------------
 security/selinux/hooks.c              | 19 +++++++-------
 security/smack/smack_lsm.c            | 37 ++++++++++++---------------
 8 files changed, 66 insertions(+), 82 deletions(-)

diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 32b62c1fa519..75a90921a241 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -1128,7 +1128,7 @@ int vfs_set_acl(const struct path *path, const char *acl_name,
 	if (error)
 		goto out_inode_unlock;
 
-	error = security_inode_set_acl(idmap, dentry, acl_name, kacl);
+	error = security_inode_set_acl(path, acl_name, kacl);
 	if (error)
 		goto out_inode_unlock;
 
@@ -1184,7 +1184,7 @@ struct posix_acl *vfs_get_acl(const struct path *path, const char *acl_name)
 	 * The VFS has no restrictions on reading POSIX ACLs so calling
 	 * something like xattr_permission() isn't needed. Only LSMs get a say.
 	 */
-	error = security_inode_get_acl(idmap, dentry, acl_name);
+	error = security_inode_get_acl(path, acl_name);
 	if (error)
 		return ERR_PTR(error);
 
@@ -1236,7 +1236,7 @@ int vfs_remove_acl(const struct path *path, const char *acl_name)
 	if (error)
 		goto out_inode_unlock;
 
-	error = security_inode_remove_acl(idmap, dentry, acl_name);
+	error = security_inode_remove_acl(path, acl_name);
 	if (error)
 		goto out_inode_unlock;
 
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index 49483c51667b..cef041b19703 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -160,14 +160,14 @@ LSM_HOOK(void, LSM_RET_VOID, inode_post_removexattr, struct dentry *dentry,
 	 const char *name)
 LSM_HOOK(int, 0, inode_file_setattr, struct dentry *dentry, struct file_kattr *fa)
 LSM_HOOK(int, 0, inode_file_getattr, struct dentry *dentry, struct file_kattr *fa)
-LSM_HOOK(int, 0, inode_set_acl, const struct mnt_idmap *idmap,
-	 struct dentry *dentry, const char *acl_name, struct posix_acl *kacl)
+LSM_HOOK(int, 0, inode_set_acl, const struct path *path,
+	 const char *acl_name, struct posix_acl *kacl)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_set_acl, struct dentry *dentry,
 	 const char *acl_name, struct posix_acl *kacl)
-LSM_HOOK(int, 0, inode_get_acl, const struct mnt_idmap *idmap,
-	 struct dentry *dentry, const char *acl_name)
-LSM_HOOK(int, 0, inode_remove_acl, const struct mnt_idmap *idmap,
-	 struct dentry *dentry, const char *acl_name)
+LSM_HOOK(int, 0, inode_get_acl, const struct path *path,
+	 const char *acl_name)
+LSM_HOOK(int, 0, inode_remove_acl, const struct path *path,
+	 const char *acl_name)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_remove_acl, const struct mnt_idmap *idmap,
 	 struct dentry *dentry, const char *acl_name)
 LSM_HOOK(int, 0, inode_need_killpriv, struct dentry *dentry)
diff --git a/include/linux/security.h b/include/linux/security.h
index 741f914128e2..31e29a0d08c4 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -435,15 +435,12 @@ int security_inode_getattr(const struct path *path);
 int security_inode_setxattr(const struct path *path,
 			    const char *name, const void *value,
 			    size_t size, int flags);
-int security_inode_set_acl(const struct mnt_idmap *idmap,
-			   struct dentry *dentry, const char *acl_name,
-			   struct posix_acl *kacl);
+int security_inode_set_acl(const struct path *path,
+			   const char *acl_name, struct posix_acl *kacl);
 void security_inode_post_set_acl(struct dentry *dentry, const char *acl_name,
 				 struct posix_acl *kacl);
-int security_inode_get_acl(const struct mnt_idmap *idmap,
-			   struct dentry *dentry, const char *acl_name);
-int security_inode_remove_acl(const struct mnt_idmap *idmap,
-			      struct dentry *dentry, const char *acl_name);
+int security_inode_get_acl(const struct path *path, const char *acl_name);
+int security_inode_remove_acl(const struct path *path, const char *acl_name);
 void security_inode_post_remove_acl(const struct mnt_idmap *idmap,
 				    struct dentry *dentry,
 				    const char *acl_name);
@@ -1021,8 +1018,7 @@ static inline int security_inode_setxattr(const struct path *path,
 	return cap_inode_setxattr(path, name, value, size, flags);
 }
 
-static inline int security_inode_set_acl(const struct mnt_idmap *idmap,
-					 struct dentry *dentry,
+static inline int security_inode_set_acl(const struct path *path,
 					 const char *acl_name,
 					 struct posix_acl *kacl)
 {
@@ -1034,15 +1030,13 @@ static inline void security_inode_post_set_acl(struct dentry *dentry,
 					       struct posix_acl *kacl)
 { }
 
-static inline int security_inode_get_acl(const struct mnt_idmap *idmap,
-					 struct dentry *dentry,
+static inline int security_inode_get_acl(const struct path *path,
 					 const char *acl_name)
 {
 	return 0;
 }
 
-static inline int security_inode_remove_acl(const struct mnt_idmap *idmap,
-					    struct dentry *dentry,
+static inline int security_inode_remove_acl(const struct path *path,
 					    const char *acl_name)
 {
 	return 0;
diff --git a/security/integrity/evm/evm_main.c b/security/integrity/evm/evm_main.c
index bd1cec1aa074..0d8d82536151 100644
--- a/security/integrity/evm/evm_main.c
+++ b/security/integrity/evm/evm_main.c
@@ -685,8 +685,7 @@ static inline int evm_inode_set_acl_change(const struct mnt_idmap *idmap,
 
 /**
  * evm_inode_set_acl - protect the EVM extended attribute from posix acls
- * @idmap: idmap of the idmapped mount
- * @dentry: pointer to the affected dentry
+ * @path: pointer to the affected object
  * @acl_name: name of the posix acl
  * @kacl: pointer to the posix acls
  *
@@ -696,10 +695,12 @@ static inline int evm_inode_set_acl_change(const struct mnt_idmap *idmap,
  *
  * Return: zero on success, -EPERM on failure.
  */
-static int evm_inode_set_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
+static int evm_inode_set_acl(const struct path *path,
 			     const char *acl_name, struct posix_acl *kacl)
 {
 	enum integrity_status evm_status;
+	struct dentry *dentry = path->dentry;
+	const struct mnt_idmap *idmap = mnt_idmap(path->mnt);
 
 	/* Policy permits modification of the protected xattrs even though
 	 * there's no HMAC key loaded
@@ -738,8 +739,7 @@ static int evm_inode_set_acl(const struct mnt_idmap *idmap, struct dentry *dentr
 
 /**
  * evm_inode_remove_acl - Protect the EVM extended attribute from posix acls
- * @idmap: idmap of the mount
- * @dentry: pointer to the affected dentry
+ * @path: pointer to the affected object
  * @acl_name: name of the posix acl
  *
  * Prevent removing posix acls causing the EVM HMAC to be re-calculated
@@ -748,10 +748,10 @@ static int evm_inode_set_acl(const struct mnt_idmap *idmap, struct dentry *dentr
  *
  * Return: zero on success, -EPERM on failure.
  */
-static int evm_inode_remove_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
+static int evm_inode_remove_acl(const struct path *path,
 				const char *acl_name)
 {
-	return evm_inode_set_acl(idmap, dentry, acl_name, NULL);
+	return evm_inode_set_acl(path, acl_name, NULL);
 }
 
 static void evm_reset_status(struct inode *inode)
diff --git a/security/integrity/ima/ima_appraise.c b/security/integrity/ima/ima_appraise.c
index 2479bd78a17f..27b261a19900 100644
--- a/security/integrity/ima/ima_appraise.c
+++ b/security/integrity/ima/ima_appraise.c
@@ -793,11 +793,11 @@ static int ima_inode_setxattr(const struct path *path,
 	return result;
 }
 
-static int ima_inode_set_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
+static int ima_inode_set_acl(const struct path *path,
 			     const char *acl_name, struct posix_acl *kacl)
 {
 	if (evm_revalidate_status(acl_name))
-		ima_reset_appraise_flags(d_backing_inode(dentry), -1);
+		ima_reset_appraise_flags(d_backing_inode(path->dentry), -1);
 
 	return 0;
 }
@@ -818,10 +818,10 @@ static int ima_inode_removexattr(const struct path *path,
 	return result;
 }
 
-static int ima_inode_remove_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
+static int ima_inode_remove_acl(const struct path *path,
 				const char *acl_name)
 {
-	return ima_inode_set_acl(idmap, dentry, acl_name, NULL);
+	return ima_inode_set_acl(path, acl_name, NULL);
 }
 
 static struct security_hook_list ima_appraise_hooks[] __ro_after_init = {
diff --git a/security/security.c b/security/security.c
index 229242a1b2b1..9fae4f16f886 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1987,8 +1987,7 @@ int security_inode_setxattr(const struct path *path,
 
 /**
  * security_inode_set_acl() - Check if setting posix acls is allowed
- * @idmap: idmap of the mount
- * @dentry: file
+ * @path: file
  * @acl_name: acl name
  * @kacl: acl struct
  *
@@ -1997,13 +1996,12 @@ int security_inode_setxattr(const struct path *path,
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_set_acl(const struct mnt_idmap *idmap,
-			   struct dentry *dentry, const char *acl_name,
-			   struct posix_acl *kacl)
+int security_inode_set_acl(const struct path *path,
+			   const char *acl_name, struct posix_acl *kacl)
 {
-	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
+	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_set_acl, idmap, dentry, acl_name, kacl);
+	return call_int_hook(inode_set_acl, path, acl_name, kacl);
 }
 
 /**
@@ -2025,8 +2023,7 @@ void security_inode_post_set_acl(struct dentry *dentry, const char *acl_name,
 
 /**
  * security_inode_get_acl() - Check if reading posix acls is allowed
- * @idmap: idmap of the mount
- * @dentry: file
+ * @path: file
  * @acl_name: acl name
  *
  * Check permission before getting osix acls, the posix acls are identified by
@@ -2034,18 +2031,16 @@ void security_inode_post_set_acl(struct dentry *dentry, const char *acl_name,
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_get_acl(const struct mnt_idmap *idmap,
-			   struct dentry *dentry, const char *acl_name)
+int security_inode_get_acl(const struct path *path, const char *acl_name)
 {
-	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
+	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_get_acl, idmap, dentry, acl_name);
+	return call_int_hook(inode_get_acl, path, acl_name);
 }
 
 /**
  * security_inode_remove_acl() - Check if removing a posix acl is allowed
- * @idmap: idmap of the mount
- * @dentry: file
+ * @path: file
  * @acl_name: acl name
  *
  * Check permission before removing posix acls, the posix acls are identified
@@ -2053,12 +2048,11 @@ int security_inode_get_acl(const struct mnt_idmap *idmap,
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_remove_acl(const struct mnt_idmap *idmap,
-			      struct dentry *dentry, const char *acl_name)
+int security_inode_remove_acl(const struct path *path, const char *acl_name)
 {
-	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
+	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_remove_acl, idmap, dentry, acl_name);
+	return call_int_hook(inode_remove_acl, path, acl_name);
 }
 
 /**
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 250401461684..523b7c273d3c 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3505,23 +3505,22 @@ static int selinux_inode_setxattr(const struct path *path,
 			    &ad);
 }
 
-static int selinux_inode_set_acl(const struct mnt_idmap *idmap,
-				 struct dentry *dentry, const char *acl_name,
-				 struct posix_acl *kacl)
+static int selinux_inode_set_acl(const struct path *path,
+				 const char *acl_name, struct posix_acl *kacl)
 {
-	return dentry_has_perm(current_cred(), dentry, FILE__SETATTR);
+	return dentry_has_perm(current_cred(), path->dentry, FILE__SETATTR);
 }
 
-static int selinux_inode_get_acl(const struct mnt_idmap *idmap,
-				 struct dentry *dentry, const char *acl_name)
+static int selinux_inode_get_acl(const struct path *path,
+				 const char *acl_name)
 {
-	return dentry_has_perm(current_cred(), dentry, FILE__GETATTR);
+	return dentry_has_perm(current_cred(), path->dentry, FILE__GETATTR);
 }
 
-static int selinux_inode_remove_acl(const struct mnt_idmap *idmap,
-				    struct dentry *dentry, const char *acl_name)
+static int selinux_inode_remove_acl(const struct path *path,
+				    const char *acl_name)
 {
-	return dentry_has_perm(current_cred(), dentry, FILE__SETATTR);
+	return dentry_has_perm(current_cred(), path->dentry, FILE__SETATTR);
 }
 
 static void selinux_inode_post_setxattr(struct dentry *dentry, const char *name,
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index fe11b06475bd..8cfe5d522246 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1548,62 +1548,59 @@ static int smack_inode_removexattr(const struct path *path,
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_set_acl(const struct mnt_idmap *idmap,
-			       struct dentry *dentry, const char *acl_name,
-			       struct posix_acl *kacl)
+static int smack_inode_set_acl(const struct path *path,
+			       const char *acl_name, struct posix_acl *kacl)
 {
 	struct smk_audit_info ad;
 	int rc;
 
 	smk_ad_init(&ad, __func__, LSM_AUDIT_DATA_DENTRY);
-	smk_ad_setfield_u_fs_path_dentry(&ad, dentry);
+	smk_ad_setfield_u_fs_path_dentry(&ad, path->dentry);
 
-	rc = smk_curacc(smk_of_inode(d_backing_inode(dentry)), MAY_WRITE, &ad);
-	rc = smk_bu_inode(d_backing_inode(dentry), MAY_WRITE, rc);
+	rc = smk_curacc(smk_of_inode(d_backing_inode(path->dentry)), MAY_WRITE, &ad);
+	rc = smk_bu_inode(d_backing_inode(path->dentry), MAY_WRITE, rc);
 	return rc;
 }
 
 /**
  * smack_inode_get_acl - Smack check for getting posix acls
- * @idmap: idmap of the mnt this request came from
- * @dentry: the object
+ * @path: the object
  * @acl_name: name of the posix acl
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_get_acl(const struct mnt_idmap *idmap,
-			       struct dentry *dentry, const char *acl_name)
+static int smack_inode_get_acl(const struct path *path,
+			       const char *acl_name)
 {
 	struct smk_audit_info ad;
 	int rc;
 
 	smk_ad_init(&ad, __func__, LSM_AUDIT_DATA_DENTRY);
-	smk_ad_setfield_u_fs_path_dentry(&ad, dentry);
+	smk_ad_setfield_u_fs_path_dentry(&ad, path->dentry);
 
-	rc = smk_curacc(smk_of_inode(d_backing_inode(dentry)), MAY_READ, &ad);
-	rc = smk_bu_inode(d_backing_inode(dentry), MAY_READ, rc);
+	rc = smk_curacc(smk_of_inode(d_backing_inode(path->dentry)), MAY_READ, &ad);
+	rc = smk_bu_inode(d_backing_inode(path->dentry), MAY_READ, rc);
 	return rc;
 }
 
 /**
  * smack_inode_remove_acl - Smack check for getting posix acls
- * @idmap: idmap of the mnt this request came from
- * @dentry: the object
+ * @path: the object
  * @acl_name: name of the posix acl
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_remove_acl(const struct mnt_idmap *idmap,
-				  struct dentry *dentry, const char *acl_name)
+static int smack_inode_remove_acl(const struct path *path,
+				  const char *acl_name)
 {
 	struct smk_audit_info ad;
 	int rc;
 
 	smk_ad_init(&ad, __func__, LSM_AUDIT_DATA_DENTRY);
-	smk_ad_setfield_u_fs_path_dentry(&ad, dentry);
+	smk_ad_setfield_u_fs_path_dentry(&ad, path->dentry);
 
-	rc = smk_curacc(smk_of_inode(d_backing_inode(dentry)), MAY_WRITE, &ad);
-	rc = smk_bu_inode(d_backing_inode(dentry), MAY_WRITE, rc);
+	rc = smk_curacc(smk_of_inode(d_backing_inode(path->dentry)), MAY_WRITE, &ad);
+	rc = smk_bu_inode(d_backing_inode(path->dentry), MAY_WRITE, rc);
 	return rc;
 }
 
-- 
2.18.0.huawei.25

