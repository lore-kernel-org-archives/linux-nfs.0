Received: from canpmsgout07.his.huawei.com (canpmsgout07.his.huawei.com [113.46.200.222])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF5A05221D3;
	Thu, 15 Oct 2026 12:20:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.222
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792066834; cv=none; b=EFsEpUm7IdVRstj7iHD3WwthqooKdsool0rvoKLj80umQCbTL6dOs4QTXd2EOrEajRA9/MLvgssUV0a4yeW4z4jkRnsgJbvHNQlAta75d19viNCwKyx+Alu6FkixiJj3Ex9dOCRcg75McBmt3zhUJU87n+RLs6dLpnTz1LoP8yM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792066834; c=relaxed/simple;
	bh=kjqNC0NoCN8J9pUDnV1yH1/r7qK0ENIZ+T1Q90j6kSM=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=oUwJXG4mPBtJg+blOdgLtV5P56908mOrU/7q3JN5EIrwM6ZwSEljOi7MEVLTgf5Eg2rFS9mdtQ8oC5lEzWQDM3iDzxWV7zQCYK0onKAbVsc1OCMpUx2bml5Leewk75bvLkAamr6yL5+JQWh71oMR1VcPLROm06ilDiiLBoXv0Nc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=L2WFcAYN; arc=none smtp.client-ip=113.46.200.222
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="L2WFcAYN"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=AgXu9I+kUFMc9cv3Df+DDYg/Cn3mjyaZoNllG7zxdfw=;
	b=L2WFcAYN7RbeWCoDH+2IV6GHjFiitOr5E1OJEnINeDsOzaBxnKf53sRk2jyQ5o6O67TUWo4N3
	aDAVYC8Gv6ODXEV4D1TDShv/PakiiB6usm2kJBLoWPVsnaVsuHXkswPJt0ovrNMAcNv5eqy6W/D
	ib/EXg0B88/esWC63RIIksc=
Received: from mail.maildlp.com (unknown [172.19.163.200])
	by canpmsgout07.his.huawei.com (SkyGuard) with ESMTPS id 4j56KM3vvJzLlSh;
	Thu, 15 Oct 2026 20:08:07 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 8C4BD40563;
	Thu, 15 Oct 2026 20:20:26 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 15 Oct 2026 20:20:21 +0800
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
Subject: [PATCH v2 -next 08/18] LSM: pass struct path to the inode fileattr hooks
Date: Thu, 15 Oct 2026 20:54:14 +0800
Message-ID: <20261015125425.3246251-9-caixinchen1@huawei.com>
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

The inode_file_getattr and inode_file_setattr hooks are called from
vfs_fileattr_get() and vfs_fileattr_set(), whose callers -- the
FS_IOC_GETFLAGS, FS_IOC_SETFLAGS, FS_IOC_FSGETXATTR and
FS_IOC_FSSETXATTR ioctls and the file_getattr(2) and file_setattr(2)
syscalls -- all operate on a struct file or a struct path and had to
derive the dentry and the idmap from it just for the fileattr helpers
and the hooks.  Switch the helpers and the hooks, along with their
SELinux implementations, to take a const struct path.

vfs_fileattr_get() and vfs_fileattr_set() are also called to forward
fileattr operations to underlying inodes.  Such internal forwards are
performed with kernel-side credentials (e.g. overlayfs uses its
superblock creator credentials) and the user-facing operation was
already checked by the hooks, so they must not invoke the security
hooks a second time.  Add __vfs_fileattr_get() and __vfs_fileattr_set()
counterparts without the security checks, following the
__vfs_setxattr_noperm() precedent, and use them for the internal
forwards of:

- ecryptfs, which forwards fileattr operations to lower inodes;
- overlayfs, which forwards them to the real (upper or lower) inodes.
  This also removes the ovl_security_fileattr() hack that opened the
  real file just to call security_file_ioctl() on it: the security
  hooks now run on the user-facing path instead;
- nfsd, which probes casefolding and compression state with
  overridden credentials; this is an internal lookup, not a
  user-facing fileattr operation.

ksmbd serves user-facing SMB requests and keeps calling the
hook-checked vfs_fileattr_get() and vfs_fileattr_set(), passing the
struct path it already holds directly.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/ecryptfs/inode.c           |   4 +-
 fs/file_attr.c                | 128 +++++++++++++++++++++++-----------
 fs/nfsd/vfs.c                 |   2 +-
 fs/overlayfs/inode.c          |  47 +------------
 fs/smb/server/smb2pdu.c       |   6 +-
 fs/smb/server/vfs.c           |  12 ++--
 fs/smb/server/vfs.h           |   2 +-
 include/linux/fileattr.h      |   8 ++-
 include/linux/lsm_hook_defs.h |   6 +-
 include/linux/security.h      |   8 +--
 security/security.c           |  12 ++--
 security/selinux/hooks.c      |   8 +--
 12 files changed, 127 insertions(+), 116 deletions(-)

diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index b08eac01d32f..e894ce435b5b 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -1075,7 +1075,7 @@ static int ecryptfs_removexattr(struct dentry *dentry, struct inode *inode,
 
 static int ecryptfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa)
 {
-	return vfs_fileattr_get(ecryptfs_dentry_to_lower(dentry), fa);
+	return __vfs_fileattr_get(ecryptfs_dentry_to_lower(dentry), fa);
 }
 
 static int ecryptfs_fileattr_set(const struct mnt_idmap *idmap,
@@ -1084,7 +1084,7 @@ static int ecryptfs_fileattr_set(const struct mnt_idmap *idmap,
 	struct dentry *lower_dentry = ecryptfs_dentry_to_lower(dentry);
 	int rc;
 
-	rc = vfs_fileattr_set(&nop_mnt_idmap, lower_dentry, fa);
+	rc = __vfs_fileattr_set(&nop_mnt_idmap, lower_dentry, fa);
 	fsstack_copy_attr_all(d_inode(dentry), d_inode(lower_dentry));
 
 	return rc;
diff --git a/fs/file_attr.c b/fs/file_attr.c
index 833e03810b24..1e555aebd815 100644
--- a/fs/file_attr.c
+++ b/fs/file_attr.c
@@ -75,27 +75,46 @@ void fileattr_fill_flags(struct file_kattr *fa, u32 flags)
 EXPORT_SYMBOL(fileattr_fill_flags);
 
 /**
- * vfs_fileattr_get - retrieve miscellaneous file attributes
+ * __vfs_fileattr_get - retrieve miscellaneous file attributes
  * @dentry:	the object to retrieve from
  * @fa:		fileattr pointer
  *
- * Call i_op->fileattr_get() callback, if exists.
+ * Call i_op->fileattr_get() callback, if exists.  Unlike
+ * vfs_fileattr_get(), no security hook is called: this is the variant to
+ * use for internal forwards, where the LSM checks were already performed
+ * on the user-facing path (e.g. by a stacking filesystem).
  *
  * Return: 0 on success, or a negative error on failure.
  */
-int vfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa)
+int __vfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa)
 {
 	struct inode *inode = d_inode(dentry);
-	int error;
 
 	if (!inode->i_op->fileattr_get)
 		return -ENOIOCTLCMD;
 
-	error = security_inode_file_getattr(dentry, fa);
+	return inode->i_op->fileattr_get(dentry, fa);
+}
+EXPORT_SYMBOL(__vfs_fileattr_get);
+
+/**
+ * vfs_fileattr_get - retrieve miscellaneous file attributes
+ * @path:	the object to retrieve from
+ * @fa:		fileattr pointer
+ *
+ * Call i_op->fileattr_get() callback, if exists.
+ *
+ * Return: 0 on success, or a negative error on failure.
+ */
+int vfs_fileattr_get(const struct path *path, struct file_kattr *fa)
+{
+	int error;
+
+	error = security_inode_file_getattr(path, fa);
 	if (error)
 		return error;
 
-	return inode->i_op->fileattr_get(dentry, fa);
+	return __vfs_fileattr_get(path->dentry, fa);
 }
 EXPORT_SYMBOL(vfs_fileattr_get);
 
@@ -254,24 +273,10 @@ static int fileattr_set_prepare(struct inode *inode,
 	return 0;
 }
 
-/**
- * vfs_fileattr_set - change miscellaneous file attributes
- * @idmap:	idmap of the mount
- * @dentry:	the object to change
- * @fa:		fileattr pointer
- *
- * After verifying permissions, call i_op->fileattr_set() callback, if
- * exists.
- *
- * Verifying attributes involves retrieving current attributes with
- * i_op->fileattr_get(), this also allows initializing attributes that have
- * not been set by the caller to current values.  Inode lock is held
- * thoughout to prevent racing with another instance.
- *
- * Return: 0 on success, or a negative error on failure.
- */
-int vfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
-		     struct file_kattr *fa)
+static int do_vfs_fileattr_set(const struct path *const path,
+			       const struct mnt_idmap *const idmap,
+			       struct dentry *const dentry,
+			       struct file_kattr *const fa)
 {
 	struct inode *inode = d_inode(dentry);
 	struct file_kattr old_ma = {};
@@ -284,7 +289,7 @@ int vfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
 		return -EPERM;
 
 	inode_lock(inode);
-	err = vfs_fileattr_get(dentry, &old_ma);
+	err = __vfs_fileattr_get(dentry, &old_ma);
 	if (!err) {
 		/* initialize missing bits from old_ma */
 		if (fa->flags_valid) {
@@ -300,9 +305,17 @@ int vfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
 		err = fileattr_set_prepare(inode, &old_ma, fa);
 		if (err)
 			goto out;
-		err = security_inode_file_setattr(dentry, fa);
-		if (err)
-			goto out;
+		/*
+		 * The LSM checks are only performed for user-facing calls
+		 * (i.e. when @path is set): internal forwards, e.g. from a
+		 * stacking filesystem, were already checked on the
+		 * user-facing path.
+		 */
+		if (path) {
+			err = security_inode_file_setattr(path, fa);
+			if (err)
+				goto out;
+		}
 		err = inode->i_op->fileattr_set(idmap, dentry, fa);
 		if (err)
 			goto out;
@@ -313,6 +326,48 @@ int vfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
 	inode_unlock(inode);
 	return err;
 }
+
+/**
+ * __vfs_fileattr_set - change miscellaneous file attributes
+ * @idmap:	idmap of the mount
+ * @dentry:	the object to change
+ * @fa:		fileattr pointer
+ *
+ * After verifying permissions, call i_op->fileattr_set() callback, if
+ * exists.  Unlike vfs_fileattr_set(), no security hook is called: this is
+ * the variant to use for internal forwards, where the LSM checks were
+ * already performed on the user-facing path (e.g. by a stacking
+ * filesystem).
+ *
+ * Verifying attributes involves retrieving current attributes with
+ * i_op->fileattr_get(), this also allows initializing attributes that have
+ * not been set by the caller to current values.  Inode lock is held
+ * thoughout to prevent racing with another instance.
+ *
+ * Return: 0 on success, or a negative error on failure.
+ */
+int __vfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
+		       struct file_kattr *fa)
+{
+	return do_vfs_fileattr_set(NULL, idmap, dentry, fa);
+}
+EXPORT_SYMBOL(__vfs_fileattr_set);
+
+/**
+ * vfs_fileattr_set - change miscellaneous file attributes
+ * @path:	the object to change
+ * @fa:		fileattr pointer
+ *
+ * After verifying permissions, call i_op->fileattr_set() callback, if
+ * exists.
+ *
+ * Return: 0 on success, or a negative error on failure.
+ */
+int vfs_fileattr_set(const struct path *path, struct file_kattr *fa)
+{
+	return do_vfs_fileattr_set(path, mnt_idmap(path->mnt), path->dentry,
+				   fa);
+}
 EXPORT_SYMBOL(vfs_fileattr_set);
 
 int ioctl_getflags(struct file *file, unsigned int __user *argp)
@@ -320,7 +375,7 @@ int ioctl_getflags(struct file *file, unsigned int __user *argp)
 	struct file_kattr fa = { .flags_valid = true }; /* hint only */
 	int err;
 
-	err = vfs_fileattr_get(file->f_path.dentry, &fa);
+	err = vfs_fileattr_get(&file->f_path, &fa);
 	if (!err)
 		err = put_user(fa.flags, argp);
 	return err;
@@ -328,8 +383,6 @@ int ioctl_getflags(struct file *file, unsigned int __user *argp)
 
 int ioctl_setflags(struct file *file, unsigned int __user *argp)
 {
-	const struct mnt_idmap *idmap = file_mnt_idmap(file);
-	struct dentry *dentry = file->f_path.dentry;
 	struct file_kattr fa = {};
 	unsigned int flags;
 	int err;
@@ -339,7 +392,7 @@ int ioctl_setflags(struct file *file, unsigned int __user *argp)
 		err = mnt_want_write_file(file);
 		if (!err) {
 			fileattr_fill_flags(&fa, flags);
-			err = vfs_fileattr_set(idmap, dentry, &fa);
+			err = vfs_fileattr_set(&file->f_path, &fa);
 			mnt_drop_write_file(file);
 		}
 	}
@@ -351,7 +404,7 @@ int ioctl_fsgetxattr(struct file *file, void __user *argp)
 	struct file_kattr fa = { .fsx_valid = true }; /* hint only */
 	int err;
 
-	err = vfs_fileattr_get(file->f_path.dentry, &fa);
+	err = vfs_fileattr_get(&file->f_path, &fa);
 	if (!err)
 		err = copy_fsxattr_to_user(&fa, argp);
 
@@ -360,8 +413,6 @@ int ioctl_fsgetxattr(struct file *file, void __user *argp)
 
 int ioctl_fssetxattr(struct file *file, void __user *argp)
 {
-	const struct mnt_idmap *idmap = file_mnt_idmap(file);
-	struct dentry *dentry = file->f_path.dentry;
 	struct file_kattr fa = {};
 	int err;
 
@@ -369,7 +420,7 @@ int ioctl_fssetxattr(struct file *file, void __user *argp)
 	if (!err) {
 		err = mnt_want_write_file(file);
 		if (!err) {
-			err = vfs_fileattr_set(idmap, dentry, &fa);
+			err = vfs_fileattr_set(&file->f_path, &fa);
 			mnt_drop_write_file(file);
 		}
 	}
@@ -416,7 +467,7 @@ SYSCALL_DEFINE5(file_getattr, int, dfd, const char __user *, filename,
 			return error;
 	}
 
-	error = vfs_fileattr_get(filepath.dentry, &fa);
+	error = vfs_fileattr_get(&filepath, &fa);
 	if (error == -ENOIOCTLCMD || error == -ENOTTY)
 		error = -EOPNOTSUPP;
 	if (error)
@@ -480,8 +531,7 @@ SYSCALL_DEFINE5(file_setattr, int, dfd, const char __user *, filename,
 
 	error = mnt_want_write(filepath.mnt);
 	if (!error) {
-		error = vfs_fileattr_set(mnt_idmap(filepath.mnt),
-					 filepath.dentry, &fa);
+		error = vfs_fileattr_set(&filepath, &fa);
 		if (error == -ENOIOCTLCMD || error == -ENOTTY)
 			error = -EOPNOTSUPP;
 		mnt_drop_write(filepath.mnt);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 3ee2322990d8..5ae540bf0b9a 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -2980,7 +2980,7 @@ nfsd_get_case_info(struct dentry *dentry, bool *case_insensitive,
 	}
 	saved = override_creds(probe);
 
-	err = vfs_fileattr_get(cd, &fa);
+	err = __vfs_fileattr_get(cd, &fa);
 
 	put_cred(revert_creds(saved));
 out:
diff --git a/fs/overlayfs/inode.c b/fs/overlayfs/inode.c
index 7f8aef41c1ce..f06e994e2e33 100644
--- a/fs/overlayfs/inode.c
+++ b/fs/overlayfs/inode.c
@@ -607,47 +607,10 @@ static int ovl_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
 		return realinode->i_op->fiemap(realinode, fieinfo, start, len);
 }
 
-/*
- * Work around the fact that security_file_ioctl() takes a file argument.
- * Introducing security_inode_fileattr_get/set() hooks would solve this issue
- * properly.
- */
-static int ovl_security_fileattr(const struct path *realpath, struct file_kattr *fa,
-				 bool set)
-{
-	struct file *file;
-	unsigned int cmd;
-	int err;
-	unsigned int flags;
-
-	flags = O_RDONLY;
-	if (force_o_largefile())
-		flags |= O_LARGEFILE;
-
-	file = dentry_open(realpath, flags, current_cred());
-	if (IS_ERR(file))
-		return PTR_ERR(file);
-
-	if (set)
-		cmd = fa->fsx_valid ? FS_IOC_FSSETXATTR : FS_IOC_SETFLAGS;
-	else
-		cmd = fa->fsx_valid ? FS_IOC_FSGETXATTR : FS_IOC_GETFLAGS;
-
-	err = security_file_ioctl(file, cmd, 0);
-	fput(file);
-
-	return err;
-}
-
 int ovl_real_fileattr_set(const struct path *realpath, struct file_kattr *fa)
 {
-	int err;
-
-	err = ovl_security_fileattr(realpath, fa, true);
-	if (err)
-		return err;
-
-	return vfs_fileattr_set(mnt_idmap(realpath->mnt), realpath->dentry, fa);
+	return __vfs_fileattr_set(mnt_idmap(realpath->mnt), realpath->dentry,
+				  fa);
 }
 
 int ovl_fileattr_set(const struct mnt_idmap *idmap,
@@ -717,11 +680,7 @@ int ovl_real_fileattr_get(const struct path *realpath, struct file_kattr *fa)
 {
 	int err;
 
-	err = ovl_security_fileattr(realpath, fa, false);
-	if (err)
-		return err;
-
-	err = vfs_fileattr_get(realpath->dentry, fa);
+	err = __vfs_fileattr_get(realpath->dentry, fa);
 	if (err == -ENOIOCTLCMD)
 		err = -ENOTTY;
 	return err;
diff --git a/fs/smb/server/smb2pdu.c b/fs/smb/server/smb2pdu.c
index 946be3c0e24b..6c8a6f8f27ee 100644
--- a/fs/smb/server/smb2pdu.c
+++ b/fs/smb/server/smb2pdu.c
@@ -3551,7 +3551,7 @@ static bool smb2_parent_compressed(struct ksmbd_tree_connect *tcon,
 	bool compressed = false;
 	int rc;
 
-	rc = vfs_fileattr_get(parent, &fa);
+	rc = vfs_fileattr_get(&parent_path, &fa);
 	if (!rc && fa.flags & FS_COMPR_FL) {
 		compressed = true;
 		goto out;
@@ -5176,7 +5176,7 @@ int smb2_open(struct ksmbd_work *work)
 		smb2_new_xattrs(tcon, &path, fp);
 	}
 
-	ksmbd_vfs_update_compressed_fattr(path.dentry, &fp->f_ci->m_fattr);
+	ksmbd_vfs_update_compressed_fattr(&path, &fp->f_ci->m_fattr);
 
 	if (created) {
 		if (fp->coption & FILE_NO_COMPRESSION_LE) {
@@ -7743,7 +7743,7 @@ static int smb2_get_info_filesystem(struct ksmbd_work *work,
 			FILE_SUPPORTS_SPARSE_FILES |
 			FILE_SUPPORTS_BLOCK_REFCOUNTING;
 
-		err = vfs_fileattr_get(path.dentry, &fa);
+		err = vfs_fileattr_get(&path, &fa);
 		/*
 		 * -EINVAL, -EOPNOTSUPP: ntfs-3g and other FUSE
 		 * filesystems that lack FS_IOC_FSGETXATTR support.
diff --git a/fs/smb/server/vfs.c b/fs/smb/server/vfs.c
index 1d74d4dd22a7..c27a04dcfe38 100644
--- a/fs/smb/server/vfs.c
+++ b/fs/smb/server/vfs.c
@@ -2328,12 +2328,12 @@ int ksmbd_vfs_inherit_posix_acl(const struct mnt_idmap *idmap,
 	return 0;
 }
 
-void ksmbd_vfs_update_compressed_fattr(struct dentry *dentry, __le32 *fattr)
+void ksmbd_vfs_update_compressed_fattr(struct path *path, __le32 *fattr)
 {
 	int rc;
 	struct file_kattr fa = { .flags_valid = true };
 
-	rc = vfs_fileattr_get(dentry, &fa);
+	rc = vfs_fileattr_get(path, &fa);
 	if (rc)
 		return;
 
@@ -2346,7 +2346,7 @@ int ksmbd_vfs_get_compression(struct ksmbd_file *fp, u16 *fmt)
 	struct file_kattr fa = { .flags_valid = true };
 	int rc;
 
-	rc = vfs_fileattr_get(fp->filp->f_path.dentry, &fa);
+	rc = vfs_fileattr_get(&fp->filp->f_path, &fa);
 	if (rc == -ENOIOCTLCMD || rc == -ENOTTY || rc == -EINVAL ||
 	    rc == -EOPNOTSUPP) {
 		if (fp->f_ci->m_fattr & FILE_ATTRIBUTE_COMPRESSED_LE)
@@ -2374,8 +2374,6 @@ static int __ksmbd_vfs_set_compression(struct ksmbd_work *work,
 {
 	const struct cred *saved_cred = NULL;
 	struct file_kattr fa;
-	struct dentry *dentry = fp->filp->f_path.dentry;
-	const struct mnt_idmap *idmap = file_mnt_idmap(fp->filp);
 	u32 flags;
 	__le32 old_fattr;
 	int rc;
@@ -2393,7 +2391,7 @@ static int __ksmbd_vfs_set_compression(struct ksmbd_work *work,
 	}
 
 	saved_cred = override_creds(fp->filp->f_cred);
-	rc = vfs_fileattr_get(dentry, &fa);
+	rc = vfs_fileattr_get(&fp->filp->f_path, &fa);
 	if (rc == -ENOIOCTLCMD || rc == -ENOTTY || rc == -EINVAL ||
 	    rc == -EOPNOTSUPP)
 		goto update_fattr;
@@ -2414,7 +2412,7 @@ static int __ksmbd_vfs_set_compression(struct ksmbd_work *work,
 		if (rc)
 			goto out;
 
-		rc = vfs_fileattr_set(idmap, dentry, &fa);
+		rc = vfs_fileattr_set(&fp->filp->f_path, &fa);
 		mnt_drop_write_file(fp->filp);
 		if (rc == -ENOIOCTLCMD || rc == -ENOTTY || rc == -EINVAL ||
 		    rc == -EOPNOTSUPP)
diff --git a/fs/smb/server/vfs.h b/fs/smb/server/vfs.h
index c6cb174fcdf4..404cf98fe607 100644
--- a/fs/smb/server/vfs.h
+++ b/fs/smb/server/vfs.h
@@ -173,7 +173,7 @@ int ksmbd_vfs_set_init_posix_acl(const struct mnt_idmap *idmap,
 int ksmbd_vfs_inherit_posix_acl(const struct mnt_idmap *idmap,
 				const struct path *path,
 				struct inode *parent_inode);
-void ksmbd_vfs_update_compressed_fattr(struct dentry *dentry, __le32 *fattr);
+void ksmbd_vfs_update_compressed_fattr(struct path *path, __le32 *fattr);
 int ksmbd_vfs_get_compression(struct ksmbd_file *fp, u16 *fmt);
 int ksmbd_vfs_set_compression(struct ksmbd_work *work, struct ksmbd_file *fp, u16 fmt);
 int ksmbd_vfs_set_compression_create(struct ksmbd_work *work,
diff --git a/include/linux/fileattr.h b/include/linux/fileattr.h
index 09e32b84e02a..a572cb850014 100644
--- a/include/linux/fileattr.h
+++ b/include/linux/fileattr.h
@@ -73,9 +73,11 @@ static inline bool fileattr_has_fsx(const struct file_kattr *fa)
 		 fa->fsx_projid != 0 ||	fa->fsx_cowextsize != 0);
 }
 
-int vfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa);
-int vfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
-		     struct file_kattr *fa);
+int __vfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa);
+int __vfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
+		       struct file_kattr *fa);
+int vfs_fileattr_get(const struct path *path, struct file_kattr *fa);
+int vfs_fileattr_set(const struct path *path, struct file_kattr *fa);
 int ioctl_getflags(struct file *file, unsigned int __user *argp);
 int ioctl_setflags(struct file *file, unsigned int __user *argp);
 int ioctl_fsgetxattr(struct file *file, void __user *argp);
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index cef041b19703..25655b3eca71 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -158,8 +158,10 @@ LSM_HOOK(int, 0, inode_removexattr, const struct path *path,
 	 const char *name)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_removexattr, struct dentry *dentry,
 	 const char *name)
-LSM_HOOK(int, 0, inode_file_setattr, struct dentry *dentry, struct file_kattr *fa)
-LSM_HOOK(int, 0, inode_file_getattr, struct dentry *dentry, struct file_kattr *fa)
+LSM_HOOK(int, 0, inode_file_setattr, const struct path *path,
+	 struct file_kattr *fa)
+LSM_HOOK(int, 0, inode_file_getattr, const struct path *path,
+	 struct file_kattr *fa)
 LSM_HOOK(int, 0, inode_set_acl, const struct path *path,
 	 const char *acl_name, struct posix_acl *kacl)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_set_acl, struct dentry *dentry,
diff --git a/include/linux/security.h b/include/linux/security.h
index 31e29a0d08c4..633c8225524a 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -451,9 +451,9 @@ int security_inode_listxattr(const struct path *path);
 int security_inode_removexattr(const struct path *path,
 			       const char *name);
 void security_inode_post_removexattr(struct dentry *dentry, const char *name);
-int security_inode_file_setattr(struct dentry *dentry,
+int security_inode_file_setattr(const struct path *path,
 			      struct file_kattr *fa);
-int security_inode_file_getattr(struct dentry *dentry,
+int security_inode_file_getattr(const struct path *path,
 			      struct file_kattr *fa);
 int security_inode_need_killpriv(struct dentry *dentry);
 int security_inode_killpriv(const struct mnt_idmap *idmap, struct dentry *dentry);
@@ -1072,13 +1072,13 @@ static inline void security_inode_post_removexattr(struct dentry *dentry,
 						   const char *name)
 { }
 
-static inline int security_inode_file_setattr(struct dentry *dentry,
+static inline int security_inode_file_setattr(const struct path *path,
 					      struct file_kattr *fa)
 {
 	return 0;
 }
 
-static inline int security_inode_file_getattr(struct dentry *dentry,
+static inline int security_inode_file_getattr(const struct path *path,
 					      struct file_kattr *fa)
 {
 	return 0;
diff --git a/security/security.c b/security/security.c
index 9fae4f16f886..10b331749889 100644
--- a/security/security.c
+++ b/security/security.c
@@ -2178,7 +2178,7 @@ void security_inode_post_removexattr(struct dentry *dentry, const char *name)
 
 /**
  * security_inode_file_setattr() - check if setting fsxattr is allowed
- * @dentry: file to set filesystem extended attributes on
+ * @path: file to set filesystem extended attributes on
  * @fa: extended attributes to set on the inode
  *
  * Called when file_setattr() syscall or FS_IOC_FSSETXATTR ioctl() is called on
@@ -2186,14 +2186,14 @@ void security_inode_post_removexattr(struct dentry *dentry, const char *name)
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_file_setattr(struct dentry *dentry, struct file_kattr *fa)
+int security_inode_file_setattr(const struct path *path, struct file_kattr *fa)
 {
-	return call_int_hook(inode_file_setattr, dentry, fa);
+	return call_int_hook(inode_file_setattr, path, fa);
 }
 
 /**
  * security_inode_file_getattr() - check if retrieving fsxattr is allowed
- * @dentry: file to retrieve filesystem extended attributes from
+ * @path: file to retrieve filesystem extended attributes from
  * @fa: extended attributes to get
  *
  * Called when file_getattr() syscall or FS_IOC_FSGETXATTR ioctl() is called on
@@ -2201,9 +2201,9 @@ int security_inode_file_setattr(struct dentry *dentry, struct file_kattr *fa)
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_file_getattr(struct dentry *dentry, struct file_kattr *fa)
+int security_inode_file_getattr(const struct path *path, struct file_kattr *fa)
 {
-	return call_int_hook(inode_file_getattr, dentry, fa);
+	return call_int_hook(inode_file_getattr, path, fa);
 }
 
 /**
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 523b7c273d3c..0a841777fe12 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3593,16 +3593,16 @@ static int selinux_inode_removexattr(const struct path *path,
 	return -EACCES;
 }
 
-static int selinux_inode_file_setattr(struct dentry *dentry,
+static int selinux_inode_file_setattr(const struct path *path,
 				      struct file_kattr *fa)
 {
-	return dentry_has_perm(current_cred(), dentry, FILE__SETATTR);
+	return dentry_has_perm(current_cred(), path->dentry, FILE__SETATTR);
 }
 
-static int selinux_inode_file_getattr(struct dentry *dentry,
+static int selinux_inode_file_getattr(const struct path *path,
 				      struct file_kattr *fa)
 {
-	return dentry_has_perm(current_cred(), dentry, FILE__GETATTR);
+	return dentry_has_perm(current_cred(), path->dentry, FILE__GETATTR);
 }
 
 static int selinux_path_notify(const struct path *path, u64 mask,
-- 
2.18.0.huawei.25

