Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.218
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101146;
	b=NHZ9VNrR3/zhkgaiF7SaALieAGTPKs+sYiaw6fJBpH8RxqkIcKWKQW53AVoZQi6mSol4
	 Ydaip/GEEgkqu6Ei+DRZk8eDJ+KOXbGxp9xbBbTDX6HKxUGuf0zhTqE84y/UaeRI+XOGL
	 5jUaw2NP4HWjVrlO4gOOxnIIyvu8ZezkqUQsDxckO22rq+FBa3ufnghXUwoYqhxj6j+Uv
	 0Q+2jqrSs2dfaC3uCHYNUYoP7esXARj0NCZRnHQjX72PAwzu3mMzwhbiqXm53DwjBKAvJ
	 YiAAjoSArzy1gayNrtjyo1tvONN3vmtTaDU4XFwgUltqH3C+mzG2oGitxSvptXqLuVA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101146;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:X-Originating-IP:X-ClientProxiedBy;
	bh=YJLumQG4zZfTPvuSJgxE/h6tSrN687TQmidzif2KOyU=;
	b=Ex1E6dPUNY99eDl9YVSuwE35lJqgOLUNo0sMVQzqLEi4Ro1/hnEIGWTzkQreUUJCSfXd
	 QG3ErWldF0kgQzkO5b46V/FawoFwPvT7JDp4dZqQXAj6XukNIY/GhqH5UPtV0sFD0OkxD
	 v6qqz8rF1MqkH5UTrJ23mqLOibVRZEkK8k3YifdmZ9qSHwsyoumScrEez/4noD/MuaWha
	 qWDjvaKyUtT5B8imeRZdcttrgVRUG3dHN4NCS7EgEYhf4VNRX78lvWCVqZH04Gz//rnUZ
	 Vzne2Sa393gLDTEh1aqu5QPc+eutQCIQ+8sNEGWreiKsijpDqbf8bAecGj4Z7ajYHMw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=f4BADt5A;
	arc=none smtp.remote-ip=113.46.200.218
Received: from canpmsgout03.his.huawei.com (canpmsgout03.his.huawei.com [113.46.200.218])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F034E606A338;
	Tue, 27 Oct 2026 11:39:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org F034E606A338
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=f4BADt5A
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=YJLumQG4zZfTPvuSJgxE/h6tSrN687TQmidzif2KOyU=;
	b=f4BADt5ATbNEjliZle7M5BZ0Tu4lnABZbBxaRIwfeiPiXyKKt25EkCHWnBzmE3P7hMoJApx+G
	kiv80GQRJ0OgM4ke2WBtp/WHo0L4SpwBlm6IMGjHjllHdXzKwgAVJb0VJTrsgC7YdQfnpuk+i43
	mjib9GSjJLrmTKHySL8cQ+M=
Received: from mail.maildlp.com (unknown [172.19.163.104])
	by canpmsgout03.his.huawei.com (SkyGuard) with ESMTPS id 4jDT636JRKzpStY;
	Tue, 27 Oct 2026 19:38:51 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id C57DC4058F;
	Tue, 27 Oct 2026 19:39:02 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Tue, 27 Oct 2026 19:38:57 +0800
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
Subject: [PATCH v3 -next 12/18] LSM: rename the inode posix acl hooks to path_*_acl hooks
Date: Tue, 27 Oct 2026 20:11:45 +0800
Message-ID: <20261027121151.1887650-13-caixinchen1@huawei.com>
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

The inode_set_acl, inode_get_acl and inode_remove_acl hooks receive a
struct path, so rename them to path_set_acl, path_get_acl and
path_remove_acl to follow the path_* naming convention used for the
other hooks that take a struct path (path_chmod, path_chown, ...).
Rename the security_inode_*_acl() inline wrappers to
security_path_*_acl() and the SELinux, Smack, EVM and IMA
implementations accordingly.  The inode_post_set_acl and
inode_post_remove_acl notification hooks still take a dentry and keep
their names.

Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/posix_acl.c                        |  6 ++--
 include/linux/lsm_hook_defs.h         |  6 ++--
 include/linux/security.h              | 44 +++++++++++++--------------
 security/integrity/evm/evm_main.c     | 26 ++++++++--------
 security/integrity/ima/ima_appraise.c | 20 ++++++------
 security/security.c                   | 32 +++++++++----------
 security/selinux/hooks.c              | 26 ++++++++--------
 security/smack/smack_lsm.c            | 32 +++++++++----------
 8 files changed, 96 insertions(+), 96 deletions(-)

diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 487e17e91e2b..5feeb651fa85 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -1130,7 +1130,7 @@ int vfs_set_acl(const struct mnt_idmap *idmap, const struct path *path,
 	if (error)
 		goto out_inode_unlock;
 
-	error = security_inode_set_acl(idmap, path, acl_name, kacl, file);
+	error = security_path_set_acl(idmap, path, acl_name, kacl, file);
 	if (error)
 		goto out_inode_unlock;
 
@@ -1189,7 +1189,7 @@ struct posix_acl *vfs_get_acl(const struct mnt_idmap *idmap,
 	 * The VFS has no restrictions on reading POSIX ACLs so calling
 	 * something like xattr_permission() isn't needed. Only LSMs get a say.
 	 */
-	error = security_inode_get_acl(idmap, path, acl_name, file);
+	error = security_path_get_acl(idmap, path, acl_name, file);
 	if (error)
 		return ERR_PTR(error);
 
@@ -1243,7 +1243,7 @@ int vfs_remove_acl(const struct mnt_idmap *idmap, const struct path *path,
 	if (error)
 		goto out_inode_unlock;
 
-	error = security_inode_remove_acl(idmap, path, acl_name, file);
+	error = security_path_remove_acl(idmap, path, acl_name, file);
 	if (error)
 		goto out_inode_unlock;
 
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index 4f3d19bf4644..7602a3074375 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -173,15 +173,15 @@ LSM_HOOK(int, 0, inode_file_setattr, const struct path *path,
 	 struct file_kattr *fa, struct file *file)
 LSM_HOOK(int, 0, inode_file_getattr, const struct path *path,
 	 struct file_kattr *fa, struct file *file)
-LSM_HOOK(int, 0, inode_set_acl, const struct mnt_idmap *idmap,
+LSM_HOOK(int, 0, path_set_acl, const struct mnt_idmap *idmap,
 	 const struct path *path, const char *acl_name,
 	 struct posix_acl *kacl, struct file *file)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_set_acl, struct dentry *dentry,
 	 const char *acl_name, struct posix_acl *kacl)
-LSM_HOOK(int, 0, inode_get_acl, const struct mnt_idmap *idmap,
+LSM_HOOK(int, 0, path_get_acl, const struct mnt_idmap *idmap,
 	 const struct path *path, const char *acl_name,
 	 struct file *file)
-LSM_HOOK(int, 0, inode_remove_acl, const struct mnt_idmap *idmap,
+LSM_HOOK(int, 0, path_remove_acl, const struct mnt_idmap *idmap,
 	 const struct path *path, const char *acl_name,
 	 struct file *file)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_remove_acl, const struct mnt_idmap *idmap,
diff --git a/include/linux/security.h b/include/linux/security.h
index afbc12c6e614..305b92c0494c 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -440,17 +440,17 @@ int security_path_setxattr(const struct mnt_idmap *idmap,
 			   const struct path *path, const char *name,
 			   const void *value, size_t size, int flags,
 			   struct file *file);
-int security_inode_set_acl(const struct mnt_idmap *idmap,
-			   const struct path *path, const char *acl_name,
-			   struct posix_acl *kacl, struct file *file);
+int security_path_set_acl(const struct mnt_idmap *idmap,
+			  const struct path *path, const char *acl_name,
+			  struct posix_acl *kacl, struct file *file);
 void security_inode_post_set_acl(struct dentry *dentry, const char *acl_name,
 				 struct posix_acl *kacl);
-int security_inode_get_acl(const struct mnt_idmap *idmap,
-			   const struct path *path, const char *acl_name,
-			   struct file *file);
-int security_inode_remove_acl(const struct mnt_idmap *idmap,
-			      const struct path *path, const char *acl_name,
-			      struct file *file);
+int security_path_get_acl(const struct mnt_idmap *idmap,
+			  const struct path *path, const char *acl_name,
+			  struct file *file);
+int security_path_remove_acl(const struct mnt_idmap *idmap,
+			     const struct path *path, const char *acl_name,
+			     struct file *file);
 void security_inode_post_remove_acl(const struct mnt_idmap *idmap,
 				    struct dentry *dentry,
 				    const char *acl_name);
@@ -1030,11 +1030,11 @@ static inline int security_path_setxattr(const struct mnt_idmap *idmap,
 	return cap_inode_setxattr(path, name, value, size, flags, file);
 }
 
-static inline int security_inode_set_acl(const struct mnt_idmap *idmap,
-					 const struct path *path,
-					 const char *acl_name,
-					 struct posix_acl *kacl,
-					 struct file *file)
+static inline int security_path_set_acl(const struct mnt_idmap *idmap,
+				       const struct path *path,
+				       const char *acl_name,
+				       struct posix_acl *kacl,
+				       struct file *file)
 {
 	return 0;
 }
@@ -1044,18 +1044,18 @@ static inline void security_inode_post_set_acl(struct dentry *dentry,
 					       struct posix_acl *kacl)
 { }
 
-static inline int security_inode_get_acl(const struct mnt_idmap *idmap,
-					 const struct path *path,
-					 const char *acl_name,
-					 struct file *file)
+static inline int security_path_get_acl(const struct mnt_idmap *idmap,
+				       const struct path *path,
+				       const char *acl_name,
+				       struct file *file)
 {
 	return 0;
 }
 
-static inline int security_inode_remove_acl(const struct mnt_idmap *idmap,
-					    const struct path *path,
-					    const char *acl_name,
-					    struct file *file)
+static inline int security_path_remove_acl(const struct mnt_idmap *idmap,
+					  const struct path *path,
+					  const char *acl_name,
+					  struct file *file)
 {
 	return 0;
 }
diff --git a/security/integrity/evm/evm_main.c b/security/integrity/evm/evm_main.c
index 025606fe5fe8..a0702eeba02b 100644
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
@@ -689,7 +689,7 @@ static inline int evm_inode_set_acl_change(const struct mnt_idmap *idmap,
 #endif
 
 /**
- * evm_inode_set_acl - protect the EVM extended attribute from posix acls
+ * evm_path_set_acl - protect the EVM extended attribute from posix acls
  * @idmap: idmap of the mount
  * @path: pointer to the affected object
  * @acl_name: name of the posix acl
@@ -702,10 +702,10 @@ static inline int evm_inode_set_acl_change(const struct mnt_idmap *idmap,
  *
  * Return: zero on success, -EPERM on failure.
  */
-static int evm_inode_set_acl(const struct mnt_idmap *idmap,
-			     const struct path *path,
-			     const char *acl_name, struct posix_acl *kacl,
-			     struct file *file)
+static int evm_path_set_acl(const struct mnt_idmap *idmap,
+			    const struct path *path,
+			    const char *acl_name, struct posix_acl *kacl,
+			    struct file *file)
 {
 	enum integrity_status evm_status;
 	struct dentry *dentry = path->dentry;
@@ -746,7 +746,7 @@ static int evm_inode_set_acl(const struct mnt_idmap *idmap,
 }
 
 /**
- * evm_inode_remove_acl - Protect the EVM extended attribute from posix acls
+ * evm_path_remove_acl - Protect the EVM extended attribute from posix acls
  * @idmap: idmap of the mount
  * @path: pointer to the affected object
  * @acl_name: name of the posix acl
@@ -758,11 +758,11 @@ static int evm_inode_set_acl(const struct mnt_idmap *idmap,
  *
  * Return: zero on success, -EPERM on failure.
  */
-static int evm_inode_remove_acl(const struct mnt_idmap *idmap,
-				const struct path *path,
-				const char *acl_name, struct file *file)
+static int evm_path_remove_acl(const struct mnt_idmap *idmap,
+			       const struct path *path,
+			       const char *acl_name, struct file *file)
 {
-	return evm_inode_set_acl(idmap, path, acl_name, NULL, file);
+	return evm_path_set_acl(idmap, path, acl_name, NULL, file);
 }
 
 static void evm_reset_status(struct inode *inode)
@@ -1217,9 +1217,9 @@ static struct security_hook_list evm_hooks[] __ro_after_init = {
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
index c701dce1e837..8b12f73afa62 100644
--- a/security/integrity/ima/ima_appraise.c
+++ b/security/integrity/ima/ima_appraise.c
@@ -795,10 +795,10 @@ static int ima_path_setxattr(const struct mnt_idmap *idmap,
 	return result;
 }
 
-static int ima_inode_set_acl(const struct mnt_idmap *idmap,
-			     const struct path *path,
-			     const char *acl_name, struct posix_acl *kacl,
-			     struct file *file)
+static int ima_path_set_acl(const struct mnt_idmap *idmap,
+			   const struct path *path,
+			   const char *acl_name, struct posix_acl *kacl,
+			   struct file *file)
 {
 	if (evm_revalidate_status(acl_name))
 		ima_reset_appraise_flags(d_backing_inode(path->dentry), -1);
@@ -823,19 +823,19 @@ static int ima_path_removexattr(const struct mnt_idmap *idmap,
 	return result;
 }
 
-static int ima_inode_remove_acl(const struct mnt_idmap *idmap,
-				 const struct path *path,
-				 const char *acl_name, struct file *file)
+static int ima_path_remove_acl(const struct mnt_idmap *idmap,
+				const struct path *path,
+				const char *acl_name, struct file *file)
 {
-	return ima_inode_set_acl(idmap, path, acl_name, NULL, file);
+	return ima_path_set_acl(idmap, path, acl_name, NULL, file);
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
diff --git a/security/security.c b/security/security.c
index bca46f5444bd..13778c83fd3a 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1969,7 +1969,7 @@ int security_path_setxattr(const struct mnt_idmap *idmap,
 }
 
 /**
- * security_inode_set_acl() - Check if setting posix acls is allowed
+ * security_path_set_acl() - Check if setting posix acls is allowed
  * @idmap: idmap of the mount
  * @path: file (the VFS makes no guarantees with regard to @path->mnt)
  * @acl_name: acl name
@@ -1981,14 +1981,14 @@ int security_path_setxattr(const struct mnt_idmap *idmap,
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_set_acl(const struct mnt_idmap *idmap,
-			   const struct path *path, const char *acl_name,
-			   struct posix_acl *kacl, struct file *file)
+int security_path_set_acl(const struct mnt_idmap *idmap,
+			  const struct path *path, const char *acl_name,
+			  struct posix_acl *kacl, struct file *file)
 {
 	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_set_acl, idmap, path, acl_name, kacl,
-			       file);
+	return call_int_hook(path_set_acl, idmap, path, acl_name, kacl,
+			     file);
 }
 
 /**
@@ -2009,7 +2009,7 @@ void security_inode_post_set_acl(struct dentry *dentry, const char *acl_name,
 }
 
 /**
- * security_inode_get_acl() - Check if reading posix acls is allowed
+ * security_path_get_acl() - Check if reading posix acls is allowed
  * @idmap: idmap of the mount
  * @path: file (the VFS makes no guarantees with regard to @path->mnt)
  * @acl_name: acl name
@@ -2020,17 +2020,17 @@ void security_inode_post_set_acl(struct dentry *dentry, const char *acl_name,
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_get_acl(const struct mnt_idmap *idmap,
-			   const struct path *path, const char *acl_name,
-			   struct file *file)
+int security_path_get_acl(const struct mnt_idmap *idmap,
+			  const struct path *path, const char *acl_name,
+			  struct file *file)
 {
 	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_get_acl, idmap, path, acl_name, file);
+	return call_int_hook(path_get_acl, idmap, path, acl_name, file);
 }
 
 /**
- * security_inode_remove_acl() - Check if removing a posix acl is allowed
+ * security_path_remove_acl() - Check if removing a posix acl is allowed
  * @idmap: idmap of the mount
  * @path: file (the VFS makes no guarantees with regard to @path->mnt)
  * @acl_name: acl name
@@ -2041,13 +2041,13 @@ int security_inode_get_acl(const struct mnt_idmap *idmap,
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_remove_acl(const struct mnt_idmap *idmap,
-			      const struct path *path, const char *acl_name,
-			      struct file *file)
+int security_path_remove_acl(const struct mnt_idmap *idmap,
+			     const struct path *path, const char *acl_name,
+			     struct file *file)
 {
 	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_remove_acl, idmap, path, acl_name, file);
+	return call_int_hook(path_remove_acl, idmap, path, acl_name, file);
 }
 
 /**
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 62053a9f7d9e..e0aaaee537d1 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3477,24 +3477,24 @@ static int selinux_path_setxattr(const struct mnt_idmap *idmap,
 			    &ad);
 }
 
-static int selinux_inode_set_acl(const struct mnt_idmap *idmap,
-				 const struct path *path,
-				 const char *acl_name, struct posix_acl *kacl,
-				 struct file *file)
+static int selinux_path_set_acl(const struct mnt_idmap *idmap,
+				const struct path *path,
+				const char *acl_name, struct posix_acl *kacl,
+				struct file *file)
 {
 	return dentry_has_perm(current_cred(), path->dentry, FILE__SETATTR);
 }
 
-static int selinux_inode_get_acl(const struct mnt_idmap *idmap,
-				 const struct path *path,
-				 const char *acl_name, struct file *file)
+static int selinux_path_get_acl(const struct mnt_idmap *idmap,
+				const struct path *path,
+				const char *acl_name, struct file *file)
 {
 	return dentry_has_perm(current_cred(), path->dentry, FILE__GETATTR);
 }
 
-static int selinux_inode_remove_acl(const struct mnt_idmap *idmap,
-				    const struct path *path,
-				    const char *acl_name, struct file *file)
+static int selinux_path_remove_acl(const struct mnt_idmap *idmap,
+				   const struct path *path,
+				   const char *acl_name, struct file *file)
 {
 	return dentry_has_perm(current_cred(), path->dentry, FILE__SETATTR);
 }
@@ -7745,9 +7745,9 @@ static struct security_hook_list selinux_hooks[] __ro_after_init = {
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
index eed06cf7af99..95a048bcf3a6 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1551,7 +1551,7 @@ static int smack_path_removexattr(const struct mnt_idmap *idmap,
 }
 
 /**
- * smack_inode_set_acl - Smack check for setting posix acls
+ * smack_path_set_acl - Smack check for setting posix acls
  * @idmap: idmap of the mnt this request came from
  * @path: the object
  * @acl_name: name of the posix acl
@@ -1560,10 +1560,10 @@ static int smack_path_removexattr(const struct mnt_idmap *idmap,
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_set_acl(const struct mnt_idmap *idmap,
-			       const struct path *path,
-			       const char *acl_name, struct posix_acl *kacl,
-			       struct file *file)
+static int smack_path_set_acl(const struct mnt_idmap *idmap,
+			      const struct path *path,
+			      const char *acl_name, struct posix_acl *kacl,
+			      struct file *file)
 {
 	struct smk_audit_info ad;
 	int rc;
@@ -1577,7 +1577,7 @@ static int smack_inode_set_acl(const struct mnt_idmap *idmap,
 }
 
 /**
- * smack_inode_get_acl - Smack check for getting posix acls
+ * smack_path_get_acl - Smack check for getting posix acls
  * @idmap: idmap of the mnt this request came from
  * @path: the object
  * @acl_name: name of the posix acl
@@ -1585,9 +1585,9 @@ static int smack_inode_set_acl(const struct mnt_idmap *idmap,
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_get_acl(const struct mnt_idmap *idmap,
-			       const struct path *path,
-			       const char *acl_name, struct file *file)
+static int smack_path_get_acl(const struct mnt_idmap *idmap,
+			      const struct path *path,
+			      const char *acl_name, struct file *file)
 {
 	struct smk_audit_info ad;
 	int rc;
@@ -1601,7 +1601,7 @@ static int smack_inode_get_acl(const struct mnt_idmap *idmap,
 }
 
 /**
- * smack_inode_remove_acl - Smack check for getting posix acls
+ * smack_path_remove_acl - Smack check for removing posix acls
  * @idmap: idmap of the mnt this request came from
  * @path: the object
  * @acl_name: name of the posix acl
@@ -1609,9 +1609,9 @@ static int smack_inode_get_acl(const struct mnt_idmap *idmap,
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_remove_acl(const struct mnt_idmap *idmap,
-				  const struct path *path,
-				  const char *acl_name, struct file *file)
+static int smack_path_remove_acl(const struct mnt_idmap *idmap,
+				 const struct path *path,
+				 const char *acl_name, struct file *file)
 {
 	struct smk_audit_info ad;
 	int rc;
@@ -5205,9 +5205,9 @@ static struct security_hook_list smack_hooks[] __ro_after_init = {
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

