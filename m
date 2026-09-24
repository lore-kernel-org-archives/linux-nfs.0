Received: from canpmsgout10.his.huawei.com (canpmsgout10.his.huawei.com [113.46.200.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 97A7447276D;
	Thu, 24 Sep 2026 10:22:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.225
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790245374; cv=none; b=PWY3HjsCLQy/j0HpuAaiBag9255gCWurhrSF3sAClj8gXo66D+j71KxT2HLigVJcKkzXBYehWpAJh8/Zu8KGxRfWncBfsrOYmLSRnXT/IwaeS2FeFLyAOKE21WWUEzhch5hRagnDf8OwClSl+iKCYyFh9pHWoVd2QI3yyumYSc0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790245374; c=relaxed/simple;
	bh=yIWk2z7Kn6KDAbnNXADHaqW8/grBunxlSozSsJw0ERQ=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=eu1XlPez9fQV+KgxytW1fuxAY24uTaowDE6sodkqgZ8wZ0Ou+xc6SRjetgiyv6P1ESPX885Atv5OxCq+LjWc4sFLCS35/Yoq9gUFOSfZO52RNkXC0cXvQDpx0NEhAnBd7XYxcS4+TLRagUt/BI0YoHcdNw8Z2cyD+h0TxF1lQ5w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=CJb1ZQJ7; arc=none smtp.client-ip=113.46.200.225
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="CJb1ZQJ7"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=uGzOy/v4wYJC3Hqw93vd9Z+a0m25IVeEcUNy9USeD5Q=;
	b=CJb1ZQJ78rVItwYnP0OSDKYg2fUFIEaxqOho+5xaDHvSaWnDatSjLwQeRiPggUx2YBwlafp34
	w1p7rxUxrdhqzAkFSpCHWKYk3ILyVFBQgjOXQrAMbSZYc/XK/mHVV4Y5gJKL5OX4vmAmzqQIS0m
	AICaIIYZxhKNs6sMLXgRXVU=
Received: from mail.maildlp.com (unknown [172.19.163.214])
	by canpmsgout10.his.huawei.com (SkyGuard) with ESMTPS id 4hr8jb1tRXz1K9D2;
	Thu, 24 Sep 2026 18:10:43 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 68D0A4057C;
	Thu, 24 Sep 2026 18:22:49 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 24 Sep 2026 18:22:44 +0800
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
Subject: [PATCH RFC -next 05/12] LSM: pass struct path to the inode_setattr hook
Date: Thu, 24 Sep 2026 18:48:24 +0800
Message-ID: <20260924104831.1081137-6-caixinchen1@huawei.com>
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

The inode_setattr hook is called from notify_change(), which now
holds a struct path and used to derive the idmap and dentry from it
just for the hook.  The other in-kernel caller, the fat and exfat
attribute ioctls, already holds a struct file and can pass its
f_path directly.

Convert the hook and its SELinux, Smack and EVM implementations to
take a const struct path.  The implementations derive the idmap and
dentry they still need from the path, so this is a purely mechanical
change with no behavior change.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/attr.c                         |  2 +-
 fs/exfat/file.c                   |  3 +--
 fs/fat/file.c                     |  3 +--
 include/linux/lsm_hook_defs.h     |  2 +-
 include/linux/security.h          |  6 ++----
 security/integrity/evm/evm_main.c |  7 ++++---
 security/security.c               | 10 ++++------
 security/selinux/hooks.c          |  3 ++-
 security/smack/smack_lsm.c        |  3 ++-
 9 files changed, 18 insertions(+), 21 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index ea91e4471faa..f0eb4be496fc 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -537,7 +537,7 @@ int notify_change(const struct path *path, struct iattr *attr,
 	    !vfsgid_valid(i_gid_into_vfsgid(idmap, inode)))
 		return -EOVERFLOW;
 
-	error = security_inode_setattr(idmap, dentry, attr);
+	error = security_inode_setattr(path, attr);
 	if (error)
 		return error;
 
diff --git a/fs/exfat/file.c b/fs/exfat/file.c
index a2a9ee1a2004..db62a8c85d64 100644
--- a/fs/exfat/file.c
+++ b/fs/exfat/file.c
@@ -493,8 +493,7 @@ static int exfat_ioctl_set_attributes(struct file *file, u32 __user *user_attr)
 	 * out the RO attribute for checking by the security
 	 * module, just because it maps to a file mode.
 	 */
-	err = security_inode_setattr(file_mnt_idmap(file),
-				     file->f_path.dentry, &ia);
+	err = security_inode_setattr(&file->f_path, &ia);
 	if (err)
 		goto out_unlock_inode;
 
diff --git a/fs/fat/file.c b/fs/fat/file.c
index 6c475c53334c..c0ec05825517 100644
--- a/fs/fat/file.c
+++ b/fs/fat/file.c
@@ -92,8 +92,7 @@ static int fat_ioctl_set_attributes(struct file *file, u32 __user *user_attr)
 	 * out the RO attribute for checking by the security
 	 * module, just because it maps to a file mode.
 	 */
-	err = security_inode_setattr(file_mnt_idmap(file),
-				     file->f_path.dentry, &ia);
+	err = security_inode_setattr(&file->f_path, &ia);
 	if (err)
 		goto out_unlock_inode;
 
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index b22f7928523e..b54fdf7d32e8 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -142,7 +142,7 @@ LSM_HOOK(int, 0, inode_follow_link, struct dentry *dentry, struct inode *inode,
 	 bool rcu)
 LSM_HOOK(int, 0, inode_permission, struct mnt_idmap *idmap,
 	 struct inode *inode, int mask)
-LSM_HOOK(int, 0, inode_setattr, struct mnt_idmap *idmap, struct dentry *dentry,
+LSM_HOOK(int, 0, inode_setattr, const struct path *path,
 	 struct iattr *attr)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_setattr, struct mnt_idmap *idmap,
 	 struct dentry *dentry, int ia_valid)
diff --git a/include/linux/security.h b/include/linux/security.h
index 6ac9fb634017..09c14c83e58f 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -429,8 +429,7 @@ int security_inode_follow_link(struct dentry *dentry, struct inode *inode,
 			       bool rcu);
 int security_inode_permission(struct mnt_idmap *idmap, struct inode *inode,
 			      int mask);
-int security_inode_setattr(struct mnt_idmap *idmap,
-			   struct dentry *dentry, struct iattr *attr);
+int security_inode_setattr(const struct path *path, struct iattr *attr);
 void security_inode_post_setattr(struct mnt_idmap *idmap, struct dentry *dentry,
 				 int ia_valid);
 int security_inode_getattr(const struct path *path);
@@ -1001,8 +1000,7 @@ static inline int security_inode_permission(struct mnt_idmap *idmap,
 	return 0;
 }
 
-static inline int security_inode_setattr(struct mnt_idmap *idmap,
-					 struct dentry *dentry,
+static inline int security_inode_setattr(const struct path *path,
 					 struct iattr *attr)
 {
 	return 0;
diff --git a/security/integrity/evm/evm_main.c b/security/integrity/evm/evm_main.c
index b59e3f121b8a..b0af1bf86ab5 100644
--- a/security/integrity/evm/evm_main.c
+++ b/security/integrity/evm/evm_main.c
@@ -949,18 +949,19 @@ static int evm_attr_change(struct mnt_idmap *idmap,
 
 /**
  * evm_inode_setattr - prevent updating an invalid EVM extended attribute
- * @idmap: idmap of the mount
- * @dentry: pointer to the affected dentry
+ * @path: pointer to the affected object
  * @attr: iattr structure containing the new file attributes
  *
  * Permit update of file attributes when files have a valid EVM signature,
  * except in the case of them having an immutable portable signature.
  */
-static int evm_inode_setattr(struct mnt_idmap *idmap, struct dentry *dentry,
+static int evm_inode_setattr(const struct path *path,
 			     struct iattr *attr)
 {
 	unsigned int ia_valid = attr->ia_valid;
 	enum integrity_status evm_status;
+	struct dentry *dentry = path->dentry;
+	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
 
 	/* Policy permits modification of the protected attrs even though
 	 * there's no HMAC key loaded
diff --git a/security/security.c b/security/security.c
index de3ed5c18802..ce74b9f1d110 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1891,8 +1891,7 @@ int security_inode_permission(struct mnt_idmap *idmap, struct inode *inode,
 
 /**
  * security_inode_setattr() - Check if setting file attributes is allowed
- * @idmap: idmap of the mount
- * @dentry: file
+ * @path: file
  * @attr: new attributes
  *
  * Check permission before setting file attributes.  Note that the kernel call
@@ -1902,12 +1901,11 @@ int security_inode_permission(struct mnt_idmap *idmap, struct inode *inode,
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_setattr(struct mnt_idmap *idmap,
-			   struct dentry *dentry, struct iattr *attr)
+int security_inode_setattr(const struct path *path, struct iattr *attr)
 {
-	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
+	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_setattr, idmap, dentry, attr);
+	return call_int_hook(inode_setattr, path, attr);
 }
 EXPORT_SYMBOL_GPL(security_inode_setattr);
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 1d06b08f3c41..49785dd62df4 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3339,10 +3339,11 @@ static int selinux_inode_permission(struct mnt_idmap *idmap,
 	return rc;
 }
 
-static int selinux_inode_setattr(struct mnt_idmap *idmap, struct dentry *dentry,
+static int selinux_inode_setattr(const struct path *path,
 				 struct iattr *iattr)
 {
 	const struct cred *cred = current_cred();
+	struct dentry *dentry = path->dentry;
 	struct inode *inode = d_backing_inode(dentry);
 	unsigned int ia_valid = iattr->ia_valid;
 	u32 av = FILE__WRITE;
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index e517809c230d..991b967c4c4e 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1272,10 +1272,11 @@ static int smack_inode_permission(struct mnt_idmap *idmap, struct inode *inode,
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_setattr(struct mnt_idmap *idmap, struct dentry *dentry,
+static int smack_inode_setattr(const struct path *path,
 			       struct iattr *iattr)
 {
 	struct smk_audit_info ad;
+	struct dentry *dentry = path->dentry;
 	int rc;
 
 	/*
-- 
2.18.0.huawei.25

