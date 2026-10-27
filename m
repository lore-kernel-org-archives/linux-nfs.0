Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.226
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101136;
	b=CZINfOOf6eQvEx5kEEXlxKCf5ZKDHtYrFIOCvyuc0TzfPm8k6r01qbhh/GmEKXBuQ0TZ
	 qRQj7K/TjfwbqO+4qfB8dwYQYLeaQA7yENS+/L8RG0c21cRQNVcfzpJAGwbB5NR5WzV41
	 CPAt3ArdrJugf7MVxrT+AQYbBwghf5aDO6e47uU2PWxMGqDzgl6l6uhHPXAbSh7NS0f94
	 WpBMLq9MpXkSmQAnsUCWMlLlOVprjqyVRRUEeUnhi/aUvbEfHgJVC3mq81i1lCaIujJyU
	 AHKpZTyZTUQLmm88vNKFC6nyjk+fniB3gxlPkcyUS408Moep5pRy0H68ydRprCMOP/Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101136;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:X-Originating-IP:X-ClientProxiedBy;
	bh=hB8v81W/S6bRZOtnZabyBeSd41G8ouXrX6zwWPK3Ga8=;
	b=FXSXGTmqM13+vsEfKG1N0b5C3NY7WFuYP+GsPneSB9HsKDC/Mrq9EUStwiHtmtkI9iwX
	 dvg9YeMU1KIvwyZVcMxywySlUgbQlU1+bhI/KSbcyOHdDisJ8Z0zHv5wGB/C8nU+nP4me
	 HsS5DqWkmhS5rSWRVWouuRWh+DofwOBCxxOf50bRICghdDw9QSLLaTuoSnBw9eKBt9bCR
	 nisDU9io9El6bjDGaAu/sGYLSdKxm7sDV4CsPqNqAggR4kkCqT6+zThOzdU/icc8K1Lml
	 X5PVwIJz6opOkfI3ztVNa+B8+JqtrmFXhm/eelYLJB8TVr3EC535BJ2Nnd4sLXOULgA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b="Z//wGmrN";
	arc=none smtp.remote-ip=113.46.200.226
Received: from canpmsgout11.his.huawei.com (canpmsgout11.his.huawei.com [113.46.200.226])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 360D8606F35E;
	Tue, 27 Oct 2026 11:38:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 360D8606F35E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=Z//wGmrN
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=hB8v81W/S6bRZOtnZabyBeSd41G8ouXrX6zwWPK3Ga8=;
	b=Z//wGmrNq/NawHGak2wnRxxrhdeRUVyuKV0q/hpHfSHaW0xpjD1ODS+CVU5hARmonnrwvoh+z
	04jOTN0geZqrjC1if6usc5tvy70A0GO5Ad/5i16B8fX//WWLDWKQUWrfkNggNBwObYlbUXOA3Dk
	W0tuihfjbSbIjguACIQ5PdE=
Received: from mail.maildlp.com (unknown [172.19.163.214])
	by canpmsgout11.his.huawei.com (SkyGuard) with ESMTPS id 4jDT5w1F8RzKmZP;
	Tue, 27 Oct 2026 19:38:44 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 8EDB24056C;
	Tue, 27 Oct 2026 19:38:52 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Tue, 27 Oct 2026 19:38:47 +0800
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
Subject: [PATCH v3 -next 10/18] LSM: rename inode_setattr to path_setattr
Date: Tue, 27 Oct 2026 20:11:43 +0800
Message-ID: <20261027121151.1887650-11-caixinchen1@huawei.com>
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

The inode_setattr hook receives a struct path, so rename it to
path_setattr to follow the path_* naming convention used for the
other hooks that take a struct path (path_chmod, path_chown, ...).
Rename the security_inode_setattr() inline wrapper to
security_path_setattr() and the SELinux, Smack and EVM
implementations accordingly.

Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/attr.c                         | 4 ++--
 fs/bpf_fs_kfuncs.c                | 2 +-
 fs/exfat/file.c                   | 4 ++--
 fs/fat/file.c                     | 4 ++--
 include/linux/lsm_hook_defs.h     | 2 +-
 include/linux/security.h          | 4 ++--
 kernel/bpf/bpf_lsm.c              | 2 +-
 security/integrity/evm/evm_main.c | 6 +++---
 security/security.c               | 8 ++++----
 security/selinux/hooks.c          | 4 ++--
 security/smack/smack_lsm.c        | 6 +++---
 11 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index 67fa5ee6b30e..62f3dc759f76 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -519,7 +519,7 @@ static int do_notify_change(const struct path *const path,
 	 * filesystem, were already checked on the user-facing path.
 	 */
 	if (path) {
-		error = security_inode_setattr(idmap, path, attr, file);
+		error = security_path_setattr(idmap, path, attr, file);
 		if (error)
 			return error;
 	}
@@ -556,7 +556,7 @@ static int do_notify_change(const struct path *const path,
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
index 27b4917e02cb..c108c1ad22a2 100644
--- a/fs/exfat/file.c
+++ b/fs/exfat/file.c
@@ -551,8 +551,8 @@ static int exfat_ioctl_set_attributes(struct file *file, u32 __user *user_attr)
 	 * out the RO attribute for checking by the security
 	 * module, just because it maps to a file mode.
 	 */
-	err = security_inode_setattr(file_mnt_idmap(file),
-			     &file->f_path, &ia, file);
+	err = security_path_setattr(file_mnt_idmap(file),
+				     &file->f_path, &ia, file);
 	if (err)
 		goto out_unlock_inode;
 
diff --git a/fs/fat/file.c b/fs/fat/file.c
index a044270379e4..dd06c68ebcd4 100644
--- a/fs/fat/file.c
+++ b/fs/fat/file.c
@@ -92,8 +92,8 @@ static int fat_ioctl_set_attributes(struct file *file, u32 __user *user_attr)
 	 * out the RO attribute for checking by the security
 	 * module, just because it maps to a file mode.
 	 */
-	err = security_inode_setattr(file_mnt_idmap(file),
-			     &file->f_path, &ia, file);
+	err = security_path_setattr(file_mnt_idmap(file),
+				     &file->f_path, &ia, file);
 	if (err)
 		goto out_unlock_inode;
 
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index 0f7712f51644..f64a8a0f94a4 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -149,7 +149,7 @@ LSM_HOOK(int, 0, inode_permission, const struct mnt_idmap *idmap,
  * are subject to change.  Implementations must not rely on its
  * properties.
  */
-LSM_HOOK(int, 0, inode_setattr, const struct mnt_idmap *idmap,
+LSM_HOOK(int, 0, path_setattr, const struct mnt_idmap *idmap,
 	 const struct path *path, struct iattr *attr, struct file *file)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_setattr, const struct mnt_idmap *idmap,
 	 struct dentry *dentry, int ia_valid)
diff --git a/include/linux/security.h b/include/linux/security.h
index 1e9382fb16a9..17a46b413ed3 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -430,7 +430,7 @@ int security_inode_follow_link(struct dentry *dentry, struct inode *inode,
 			       bool rcu);
 int security_inode_permission(const struct mnt_idmap *idmap,
 			      struct inode *inode, int mask);
-int security_inode_setattr(const struct mnt_idmap *idmap,
+int security_path_setattr(const struct mnt_idmap *idmap,
 			   const struct path *path, struct iattr *attr,
 			   struct file *file);
 void security_inode_post_setattr(const struct mnt_idmap *idmap, struct dentry *dentry,
@@ -1003,7 +1003,7 @@ static inline int security_inode_permission(const struct mnt_idmap *idmap,
 	return 0;
 }
 
-static inline int security_inode_setattr(const struct mnt_idmap *idmap,
+static inline int security_path_setattr(const struct mnt_idmap *idmap,
 					 const struct path *path,
 					 struct iattr *attr,
 					 struct file *file)
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
index 5c24111a9ba7..962b31a97ec9 100644
--- a/security/integrity/evm/evm_main.c
+++ b/security/integrity/evm/evm_main.c
@@ -962,7 +962,7 @@ static int evm_attr_change(const struct mnt_idmap *idmap,
 }
 
 /**
- * evm_inode_setattr - prevent updating an invalid EVM extended attribute
+ * evm_path_setattr - prevent updating an invalid EVM extended attribute
  * @idmap: idmap of the mount
  * @path: pointer to the affected object
  * @attr: iattr structure containing the new file attributes
@@ -971,7 +971,7 @@ static int evm_attr_change(const struct mnt_idmap *idmap,
  * Permit update of file attributes when files have a valid EVM signature,
  * except in the case of them having an immutable portable signature.
  */
-static int evm_inode_setattr(const struct mnt_idmap *idmap,
+static int evm_path_setattr(const struct mnt_idmap *idmap,
 			     const struct path *path,
 			     struct iattr *attr, struct file *file)
 {
@@ -1212,7 +1212,7 @@ static int __init init_evm(void)
 }
 
 static struct security_hook_list evm_hooks[] __ro_after_init = {
-	LSM_HOOK_INIT(inode_setattr, evm_inode_setattr),
+	LSM_HOOK_INIT(path_setattr, evm_path_setattr),
 	LSM_HOOK_INIT(inode_post_setattr, evm_inode_post_setattr),
 	LSM_HOOK_INIT(inode_copy_up_xattr, evm_inode_copy_up_xattr),
 	LSM_HOOK_INIT(inode_setxattr, evm_inode_setxattr),
diff --git a/security/security.c b/security/security.c
index d91268f88760..01d4a463c6b1 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1865,7 +1865,7 @@ int security_inode_permission(const struct mnt_idmap *idmap,
 }
 
 /**
- * security_inode_setattr() - Check if setting file attributes is allowed
+ * security_path_setattr() - Check if setting file attributes is allowed
  * @idmap: idmap of the mount
  * @path: file (the VFS makes no guarantees with regard to @path->mnt)
  * @attr: new attributes
@@ -1878,15 +1878,15 @@ int security_inode_permission(const struct mnt_idmap *idmap,
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_setattr(const struct mnt_idmap *idmap,
+int security_path_setattr(const struct mnt_idmap *idmap,
 			   const struct path *path, struct iattr *attr,
 			   struct file *file)
 {
 	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_setattr, idmap, path, attr, file);
+	return call_int_hook(path_setattr, idmap, path, attr, file);
 }
-EXPORT_SYMBOL_GPL(security_inode_setattr);
+EXPORT_SYMBOL_GPL(security_path_setattr);
 
 /**
  * security_inode_post_setattr() - Update the inode after a setattr operation
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index e07b45fba392..4751e300bde6 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3316,7 +3316,7 @@ static int selinux_inode_permission(const struct mnt_idmap *idmap,
 	return rc;
 }
 
-static int selinux_inode_setattr(const struct mnt_idmap *idmap,
+static int selinux_path_setattr(const struct mnt_idmap *idmap,
 				 const struct path *path,
 				 struct iattr *iattr, struct file *file)
 {
@@ -7734,7 +7734,7 @@ static struct security_hook_list selinux_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(inode_readlink, selinux_inode_readlink),
 	LSM_HOOK_INIT(inode_follow_link, selinux_inode_follow_link),
 	LSM_HOOK_INIT(inode_permission, selinux_inode_permission),
-	LSM_HOOK_INIT(inode_setattr, selinux_inode_setattr),
+	LSM_HOOK_INIT(path_setattr, selinux_path_setattr),
 	LSM_HOOK_INIT(path_getattr, selinux_path_getattr),
 	LSM_HOOK_INIT(inode_xattr_skipcap, selinux_inode_xattr_skipcap),
 	LSM_HOOK_INIT(inode_setxattr, selinux_inode_setxattr),
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 1aa94331c980..1cbcba3fa62b 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1265,7 +1265,7 @@ static int smack_inode_permission(const struct mnt_idmap *idmap, struct inode *i
 }
 
 /**
- * smack_inode_setattr - Smack check for setting attributes
+ * smack_path_setattr - Smack check for setting attributes
  * @idmap: idmap of the mount
  * @path: the object
  * @iattr: for the force flag
@@ -1273,7 +1273,7 @@ static int smack_inode_permission(const struct mnt_idmap *idmap, struct inode *i
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_setattr(const struct mnt_idmap *idmap,
+static int smack_path_setattr(const struct mnt_idmap *idmap,
 			       const struct path *path,
 			       struct iattr *iattr, struct file *file)
 {
@@ -5198,7 +5198,7 @@ static struct security_hook_list smack_hooks[] __ro_after_init = {
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

