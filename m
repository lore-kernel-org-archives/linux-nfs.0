Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.225
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101153;
	b=WYrn2xVL3vp5Yleo6wREGsyhJ4hVgxKEqqZkvhXJEx2HixFSBC/JaI8+7OZLZsVlO0P1
	 iBGJb5EpUgHDwU4pKvGaA6kmgVmBpJvpMNyBxs506fQ4V0aJxMUDdSXf3L2iw9wnX07UN
	 2HUwbtzv0bYbWTr3a/BlDOi1TxUT0xbmYfSJJyykWEBZczPQJuQJkrrM44QL5vWhaqzUG
	 4CXjcAkUi0729T/73ivPu5G13Q6QNwm82DFlSG191cQcQkfu/NO6tDK0aiBH3De4Eg//M
	 +LNM3QC0uN5vwzIR2TbQypIKStVu7BmIxSqve7F3Pf1Z6iVMmTyX3OGjAcw39li94pQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101153;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:X-Originating-IP:X-ClientProxiedBy;
	bh=eSoejBy4BiH08FSMPiqiQwZp6ozqcsl7f9UKEi2EenQ=;
	b=jHjV+C64HuailbzUisMpG3orEPY+Q6AOBkQ3rkdp/7n8FWrYoV4a0k+Q8/vIlGnCa1kP
	 xnAYKgM95hSO6RqGnWQXOwWFJm6zJt9ecg6z44d/OQUIbv86NoTg1aJyaJmSCUozXwT6k
	 Gn9N7WGwkX5Fn4sQNdzHa87+wweCKR00BmCbHDpK91VnSbV8Wz5CQ9H9O1xTS5Wg8KVNV
	 GvKUYZMGDegmkXBhBJFOtfN1AUazes+H+hdDUkIVbnkLhPZwptfo4jg516UZurSevK+Y1
	 rzb79EpSEkr81SteyyraaIVJW4h7raARF2saVh5CeV5ZwC1kmNA9htNfmsD+WoMqrBQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=IYh5nymZ;
	arc=none smtp.remote-ip=113.46.200.225
Received: from canpmsgout10.his.huawei.com (canpmsgout10.his.huawei.com [113.46.200.225])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3DFF26072E4E;
	Tue, 27 Oct 2026 11:39:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3DFF26072E4E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=IYh5nymZ
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=eSoejBy4BiH08FSMPiqiQwZp6ozqcsl7f9UKEi2EenQ=;
	b=IYh5nymZoyJZsxq530x+d7JtOvWC7CZVnW65/y6dNVStjCZU93b2+ZzLdYzxMrsxIJ7GBMbiM
	olU2KeJ9+tVHMer2BN2nlR56XishTWGTfbhNEi7ObodayqrzhGbpUQNAj0giT7B4ynjMp6rahMd
	3SBKUCy3WxU/vXcPVaJH28I=
Received: from mail.maildlp.com (unknown [172.19.163.127])
	by canpmsgout10.his.huawei.com (SkyGuard) with ESMTPS id 4jDT6D0yKtz1K9B9;
	Tue, 27 Oct 2026 19:39:00 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id DFA9B40572;
	Tue, 27 Oct 2026 19:39:07 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Tue, 27 Oct 2026 19:39:02 +0800
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
Subject: [PATCH v3 -next 13/18] LSM: rename the inode fileattr hooks to path_file_* hooks
Date: Tue, 27 Oct 2026 20:11:46 +0800
Message-ID: <20261027121151.1887650-14-caixinchen1@huawei.com>
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

The inode_file_getattr and inode_file_setattr hooks receive a struct
path, so rename them to path_file_getattr and path_file_setattr to
follow the path_* naming convention used for the other hooks that
take a struct path (path_chmod, path_chown, ...).  Rename the
security_inode_file_getattr() and security_inode_file_setattr()
inline wrappers and the SELinux implementations
accordingly.

Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/file_attr.c                |  4 ++--
 include/linux/lsm_hook_defs.h |  4 ++--
 include/linux/security.h      | 20 ++++++++++----------
 security/security.c           | 16 ++++++++--------
 security/selinux/hooks.c      | 16 ++++++++--------
 5 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/fs/file_attr.c b/fs/file_attr.c
index 08b4cdbef9ff..093cb05ae3c4 100644
--- a/fs/file_attr.c
+++ b/fs/file_attr.c
@@ -112,7 +112,7 @@ int vfs_fileattr_get(const struct path *path, struct file_kattr *fa,
 {
 	int error;
 
-	error = security_inode_file_getattr(path, fa, file);
+	error = security_path_file_getattr(path, fa, file);
 	if (error)
 		return error;
 
@@ -315,7 +315,7 @@ static int do_vfs_fileattr_set(const struct path *const path,
 		 * user-facing path.
 		 */
 		if (path) {
-			err = security_inode_file_setattr(path, fa, file);
+			err = security_path_file_setattr(path, fa, file);
 			if (err)
 				goto out;
 		}
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index 7602a3074375..683c4d7a8024 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -169,9 +169,9 @@ LSM_HOOK(int, 0, path_removexattr, const struct mnt_idmap *idmap,
 	 const struct path *path, const char *name, struct file *file)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_removexattr, struct dentry *dentry,
 	 const char *name)
-LSM_HOOK(int, 0, inode_file_setattr, const struct path *path,
+LSM_HOOK(int, 0, path_file_setattr, const struct path *path,
 	 struct file_kattr *fa, struct file *file)
-LSM_HOOK(int, 0, inode_file_getattr, const struct path *path,
+LSM_HOOK(int, 0, path_file_getattr, const struct path *path,
 	 struct file_kattr *fa, struct file *file)
 LSM_HOOK(int, 0, path_set_acl, const struct mnt_idmap *idmap,
 	 const struct path *path, const char *acl_name,
diff --git a/include/linux/security.h b/include/linux/security.h
index 305b92c0494c..edba134db8f6 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -464,10 +464,10 @@ int security_path_removexattr(const struct mnt_idmap *idmap,
 			      const struct path *path, const char *name,
 			      struct file *file);
 void security_inode_post_removexattr(struct dentry *dentry, const char *name);
-int security_inode_file_setattr(const struct path *path,
-				struct file_kattr *fa, struct file *file);
-int security_inode_file_getattr(const struct path *path,
-				struct file_kattr *fa, struct file *file);
+int security_path_file_setattr(const struct path *path,
+			       struct file_kattr *fa, struct file *file);
+int security_path_file_getattr(const struct path *path,
+			       struct file_kattr *fa, struct file *file);
 int security_inode_need_killpriv(struct dentry *dentry);
 int security_inode_killpriv(const struct mnt_idmap *idmap, struct dentry *dentry);
 int security_inode_getsecurity(const struct mnt_idmap *idmap,
@@ -1093,16 +1093,16 @@ static inline void security_inode_post_removexattr(struct dentry *dentry,
 						   const char *name)
 { }
 
-static inline int security_inode_file_setattr(const struct path *path,
-					      struct file_kattr *fa,
-					      struct file *file)
+static inline int security_path_file_setattr(const struct path *path,
+					     struct file_kattr *fa,
+					     struct file *file)
 {
 	return 0;
 }
 
-static inline int security_inode_file_getattr(const struct path *path,
-					      struct file_kattr *fa,
-					      struct file *file)
+static inline int security_path_file_getattr(const struct path *path,
+					     struct file_kattr *fa,
+					     struct file *file)
 {
 	return 0;
 }
diff --git a/security/security.c b/security/security.c
index 13778c83fd3a..919763c61994 100644
--- a/security/security.c
+++ b/security/security.c
@@ -2180,7 +2180,7 @@ void security_inode_post_removexattr(struct dentry *dentry, const char *name)
 }
 
 /**
- * security_inode_file_setattr() - check if setting fsxattr is allowed
+ * security_path_file_setattr() - check if setting fsxattr is allowed
  * @path: file to set filesystem extended attributes on (the VFS makes no
  *        guarantees with regard to @path->mnt)
  * @fa: extended attributes to set on the inode
@@ -2191,14 +2191,14 @@ void security_inode_post_removexattr(struct dentry *dentry, const char *name)
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_file_setattr(const struct path *path,
-				struct file_kattr *fa, struct file *file)
+int security_path_file_setattr(const struct path *path,
+			       struct file_kattr *fa, struct file *file)
 {
-	return call_int_hook(inode_file_setattr, path, fa, file);
+	return call_int_hook(path_file_setattr, path, fa, file);
 }
 
 /**
- * security_inode_file_getattr() - check if retrieving fsxattr is allowed
+ * security_path_file_getattr() - check if retrieving fsxattr is allowed
  * @path: file to retrieve filesystem extended attributes from (the VFS makes no
  *        guarantees with regard to @path->mnt)
  * @fa: extended attributes to get
@@ -2209,10 +2209,10 @@ int security_inode_file_setattr(const struct path *path,
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_file_getattr(const struct path *path,
-				struct file_kattr *fa, struct file *file)
+int security_path_file_getattr(const struct path *path,
+			       struct file_kattr *fa, struct file *file)
 {
-	return call_int_hook(inode_file_getattr, path, fa, file);
+	return call_int_hook(path_file_getattr, path, fa, file);
 }
 
 /**
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index e0aaaee537d1..8bafa530806e 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3572,16 +3572,16 @@ static int selinux_path_removexattr(const struct mnt_idmap *idmap,
 	return -EACCES;
 }
 
-static int selinux_inode_file_setattr(const struct path *path,
-				      struct file_kattr *fa,
-				      struct file *file)
+static int selinux_path_file_setattr(const struct path *path,
+				     struct file_kattr *fa,
+				     struct file *file)
 {
 	return dentry_has_perm(current_cred(), path->dentry, FILE__SETATTR);
 }
 
-static int selinux_inode_file_getattr(const struct path *path,
-				      struct file_kattr *fa,
-				      struct file *file)
+static int selinux_path_file_getattr(const struct path *path,
+				     struct file_kattr *fa,
+				     struct file *file)
 {
 	return dentry_has_perm(current_cred(), path->dentry, FILE__GETATTR);
 }
@@ -7743,8 +7743,8 @@ static struct security_hook_list selinux_hooks[] __ro_after_init = {
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

