Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.218
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101126;
	b=Al+rTk+MLx1405MpOORVwrMp+W0NWnxmKh0ilxBA8zKxnTDkHP/dthGWL1YoniR1edey
	 81h1uxT/wfTbHQwYy+0mj3gxA76da98CxPaE706FlUvSV5RqxAoAjfXpHD1d2muXM80Hu
	 UWMsGFgBBgeE0Vnn03njUSrue1tL4usqr+a3lzOtzqwlBMHuPYxu+v/SI1CYdOvPbA74d
	 I0bq2iqIOkbVxvpkHbfY5Qpcx6ZCyDWYyfiMvgMDCZiFAAwVaFkwLgz9L3g7pdNzWvO5T
	 atC4b65MwidaC7JIQ9A6dg28y8bdFTbXV73Jsop26DLnKNJKFYhz7PwiXHW6tyXO7EA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101126;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:X-Originating-IP:X-ClientProxiedBy;
	bh=vOAvYe+6tKdmmVqtIg3fjU1b8HtTsVbUhmzbkJ0cd6U=;
	b=MyaZDDlSvwOpjXRVfXD/Nu5viT12xEFtteZ8GY8l8uzWfoO4rHA7wBMhcX1Nf8Aucb+k
	 SySDVy/qmAH/+txzjxcGIlocDbLvW30DyepeaDyidiY+W9hStqAQkGv2ofKMkHPS+q92Y
	 ckgvlNEcezZEe8RAEsbIXQSx7FEdpLfGhSTM5ooj1QVhGhIsQ5Z3gQEbRdRjaRcWt2hDY
	 COrswXyuVsie376DYV6bjy/6ye7sNlxqXgexh0ZqQlDYbSciHBUOk8bqKkXcmpJMvFc6p
	 OD2p76+/PMIip6iGKMEefLIbugY8XoMPzjHYLeQQ65HXqE1pW7gxr+L1dNrZZUWbxUg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=VGd8IznD;
	arc=none smtp.remote-ip=113.46.200.218
Received: from canpmsgout03.his.huawei.com (canpmsgout03.his.huawei.com [113.46.200.218])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6309E606B5F6;
	Tue, 27 Oct 2026 11:38:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6309E606B5F6
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=VGd8IznD
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=vOAvYe+6tKdmmVqtIg3fjU1b8HtTsVbUhmzbkJ0cd6U=;
	b=VGd8IznDfFcPZnXOcm/Rn3AJYOXWNp9z8hw7mZZWG4WSQntioyX9nnAjAqTHIvckoUonyZGkV
	rGcCAzJmISWZSFB1wrKzOeTA+TpQ4mlWabGN9O2bDmwEYdf3Gr2wdEhWpWt+wx764SlcuReAcPx
	89kXyhxnD+0eDlmHFWKQcqw=
Received: from mail.maildlp.com (unknown [172.19.162.144])
	by canpmsgout03.his.huawei.com (SkyGuard) with ESMTPS id 4jDT5g2bZHzpSt7;
	Tue, 27 Oct 2026 19:38:31 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 36EA04056E;
	Tue, 27 Oct 2026 19:38:42 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Tue, 27 Oct 2026 19:38:36 +0800
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
Subject: [PATCH v3 -next 08/18] LSM: pass struct path and struct file to the inode fileattr hooks
Date: Tue, 27 Oct 2026 20:11:41 +0800
Message-ID: <20261027121151.1887650-9-caixinchen1@huawei.com>
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

The inode_file_getattr and inode_file_setattr hooks are called from
vfs_fileattr_get() and vfs_fileattr_set(), whose callers -- the
FS_IOC_GETFLAGS, FS_IOC_SETFLAGS, FS_IOC_FSGETXATTR and
FS_IOC_FSSETXATTR ioctls and the file_getattr(2) and file_setattr(2)
syscalls -- all operate on a struct file or a struct path and had to
derive the dentry from it just for the fileattr helpers and the
hooks.  Switch the helpers and the hooks, along with their SELinux
implementations, to take a const struct path, keeping the idmap as a
separate argument.

Also pass the struct file through which a fileattr operation is
requested, when there is one, so that LSMs can later authorize
file descriptor-based operations (the FS_IOC_GETFLAGS,
FS_IOC_SETFLAGS, FS_IOC_FSGETXATTR and FS_IOC_FSSETXATTR ioctls,
and the file_getattr(2) and file_setattr(2) syscalls with
AT_EMPTY_PATH) with the rights available at open(2) time.  The file
is threaded through vfs_fileattr_get(), vfs_fileattr_set() and
do_vfs_fileattr_set(), and set to NULL for path-based operations
and for callers that only hold a path.  No implementation uses the
file yet, so this part is a purely mechanical change with no
behavior change either.

vfs_fileattr_get() and vfs_fileattr_set() are also called to forward
fileattr operations from stacking filesystems, which are performed
with kernel-side credentials (e.g. overlayfs uses its superblock
creator credentials) and the user-facing operation was already
checked by the hooks, so they must not invoke the security
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

The read of the current file attributes that do_vfs_fileattr_set()
performs to initialize the bits the caller did not set uses the
unchecked helper as well: it is part of a user-facing change, which
is authorized as a whole by the following path_file_setattr check.
A file attribute change therefore no longer requires the file
attribute read permission as a side effect (e.g. FILE__GETATTR for
SELinux); the Landlock patch of this series relies on this for
LANDLOCK_ACCESS_FS_WRITE_METADATA.

ksmbd serves user-facing SMB requests and keeps calling the
hook-checked vfs_fileattr_get() and vfs_fileattr_set(); it passes
the struct file it holds for the SMB opens it serves, and NULL for
its path-only probes.

Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/ecryptfs/inode.c           |   4 +-
 fs/file_attr.c                | 159 ++++++++++++++++++++++++----------
 fs/nfsd/vfs.c                 |   2 +-
 fs/overlayfs/inode.c          |  47 +---------
 fs/smb/server/smb2pdu.c       |   6 +-
 fs/smb/server/vfs.c           |  14 +--
 fs/smb/server/vfs.h           |   2 +-
 include/linux/fileattr.h      |  10 ++-
 include/linux/lsm_hook_defs.h |   6 +-
 include/linux/security.h      |  18 ++--
 security/security.c           |  18 ++--
 security/selinux/hooks.c      |  14 +--
 12 files changed, 169 insertions(+), 131 deletions(-)

diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index fcb5b4de897e..2b8daf21aea8 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -1077,7 +1077,7 @@ static int ecryptfs_removexattr(struct dentry *dentry, struct inode *inode,
 
 static int ecryptfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa)
 {
-	return vfs_fileattr_get(ecryptfs_dentry_to_lower(dentry), fa);
+	return __vfs_fileattr_get(ecryptfs_dentry_to_lower(dentry), fa);
 }
 
 static int ecryptfs_fileattr_set(const struct mnt_idmap *idmap,
@@ -1086,7 +1086,7 @@ static int ecryptfs_fileattr_set(const struct mnt_idmap *idmap,
 	struct dentry *lower_dentry = ecryptfs_dentry_to_lower(dentry);
 	int rc;
 
-	rc = vfs_fileattr_set(&nop_mnt_idmap, lower_dentry, fa);
+	rc = __vfs_fileattr_set(&nop_mnt_idmap, lower_dentry, fa);
 	fsstack_copy_attr_all(d_inode(dentry), d_inode(lower_dentry));
 
 	return rc;
diff --git a/fs/file_attr.c b/fs/file_attr.c
index 833e03810b24..08b4cdbef9ff 100644
--- a/fs/file_attr.c
+++ b/fs/file_attr.c
@@ -75,27 +75,48 @@ void fileattr_fill_flags(struct file_kattr *fa, u32 flags)
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
+ * @file:	file through which the attributes are retrieved, if any
+ *
+ * Call i_op->fileattr_get() callback, if exists.
+ *
+ * Return: 0 on success, or a negative error on failure.
+ */
+int vfs_fileattr_get(const struct path *path, struct file_kattr *fa,
+		     struct file *file)
+{
+	int error;
+
+	error = security_inode_file_getattr(path, fa, file);
 	if (error)
 		return error;
 
-	return inode->i_op->fileattr_get(dentry, fa);
+	return __vfs_fileattr_get(path->dentry, fa);
 }
 EXPORT_SYMBOL(vfs_fileattr_get);
 
@@ -254,24 +275,11 @@ static int fileattr_set_prepare(struct inode *inode,
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
+			       struct file_kattr *const fa,
+			       struct file *const file)
 {
 	struct inode *inode = d_inode(dentry);
 	struct file_kattr old_ma = {};
@@ -284,7 +292,7 @@ int vfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
 		return -EPERM;
 
 	inode_lock(inode);
-	err = vfs_fileattr_get(dentry, &old_ma);
+	err = __vfs_fileattr_get(dentry, &old_ma);
 	if (!err) {
 		/* initialize missing bits from old_ma */
 		if (fa->flags_valid) {
@@ -300,9 +308,17 @@ int vfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
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
+			err = security_inode_file_setattr(path, fa, file);
+			if (err)
+				goto out;
+		}
 		err = inode->i_op->fileattr_set(idmap, dentry, fa);
 		if (err)
 			goto out;
@@ -313,6 +329,50 @@ int vfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
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
+	return do_vfs_fileattr_set(NULL, idmap, dentry, fa, NULL);
+}
+EXPORT_SYMBOL(__vfs_fileattr_set);
+
+/**
+ * vfs_fileattr_set - change miscellaneous file attributes
+ * @idmap:	idmap of the mount
+ * @path:	the object to change
+ * @fa:		fileattr pointer
+ * @file:	file through which the attributes are set, if any
+ *
+ * After verifying permissions, call i_op->fileattr_set() callback, if
+ * exists.
+ *
+ * Return: 0 on success, or a negative error on failure.
+ */
+int vfs_fileattr_set(const struct mnt_idmap *idmap, const struct path *path,
+		     struct file_kattr *fa, struct file *file)
+{
+	return do_vfs_fileattr_set(path, idmap, path->dentry, fa, file);
+}
 EXPORT_SYMBOL(vfs_fileattr_set);
 
 int ioctl_getflags(struct file *file, unsigned int __user *argp)
@@ -320,7 +380,7 @@ int ioctl_getflags(struct file *file, unsigned int __user *argp)
 	struct file_kattr fa = { .flags_valid = true }; /* hint only */
 	int err;
 
-	err = vfs_fileattr_get(file->f_path.dentry, &fa);
+	err = vfs_fileattr_get(&file->f_path, &fa, file);
 	if (!err)
 		err = put_user(fa.flags, argp);
 	return err;
@@ -329,7 +389,6 @@ int ioctl_getflags(struct file *file, unsigned int __user *argp)
 int ioctl_setflags(struct file *file, unsigned int __user *argp)
 {
 	const struct mnt_idmap *idmap = file_mnt_idmap(file);
-	struct dentry *dentry = file->f_path.dentry;
 	struct file_kattr fa = {};
 	unsigned int flags;
 	int err;
@@ -339,7 +398,7 @@ int ioctl_setflags(struct file *file, unsigned int __user *argp)
 		err = mnt_want_write_file(file);
 		if (!err) {
 			fileattr_fill_flags(&fa, flags);
-			err = vfs_fileattr_set(idmap, dentry, &fa);
+			err = vfs_fileattr_set(idmap, &file->f_path, &fa, file);
 			mnt_drop_write_file(file);
 		}
 	}
@@ -351,7 +410,7 @@ int ioctl_fsgetxattr(struct file *file, void __user *argp)
 	struct file_kattr fa = { .fsx_valid = true }; /* hint only */
 	int err;
 
-	err = vfs_fileattr_get(file->f_path.dentry, &fa);
+	err = vfs_fileattr_get(&file->f_path, &fa, file);
 	if (!err)
 		err = copy_fsxattr_to_user(&fa, argp);
 
@@ -361,7 +420,6 @@ int ioctl_fsgetxattr(struct file *file, void __user *argp)
 int ioctl_fssetxattr(struct file *file, void __user *argp)
 {
 	const struct mnt_idmap *idmap = file_mnt_idmap(file);
-	struct dentry *dentry = file->f_path.dentry;
 	struct file_kattr fa = {};
 	int err;
 
@@ -369,7 +427,7 @@ int ioctl_fssetxattr(struct file *file, void __user *argp)
 	if (!err) {
 		err = mnt_want_write_file(file);
 		if (!err) {
-			err = vfs_fileattr_set(idmap, dentry, &fa);
+			err = vfs_fileattr_set(idmap, &file->f_path, &fa, file);
 			mnt_drop_write_file(file);
 		}
 	}
@@ -407,16 +465,16 @@ SYSCALL_DEFINE5(file_getattr, int, dfd, const char __user *, filename,
 		if (fd_empty(f))
 			return -EBADF;
 
-		filepath = fd_file(f)->f_path;
-		path_get(&filepath);
+		error = vfs_fileattr_get(&fd_file(f)->f_path, &fa,
+					 fd_file(f));
 	} else {
 		error = filename_lookup(dfd, name, lookup_flags, &filepath,
 					NULL);
 		if (error)
 			return error;
-	}
 
-	error = vfs_fileattr_get(filepath.dentry, &fa);
+		error = vfs_fileattr_get(&filepath, &fa, NULL);
+	}
 	if (error == -ENOIOCTLCMD || error == -ENOTTY)
 		error = -EOPNOTSUPP;
 	if (error)
@@ -469,23 +527,28 @@ SYSCALL_DEFINE5(file_setattr, int, dfd, const char __user *, filename,
 		if (fd_empty(f))
 			return -EBADF;
 
-		filepath = fd_file(f)->f_path;
-		path_get(&filepath);
+		error = mnt_want_write_file(fd_file(f));
+		if (!error) {
+			error = vfs_fileattr_set(file_mnt_idmap(fd_file(f)),
+						 &fd_file(f)->f_path, &fa,
+						 fd_file(f));
+			mnt_drop_write_file(fd_file(f));
+		}
 	} else {
 		error = filename_lookup(dfd, name, lookup_flags, &filepath,
 					NULL);
 		if (error)
 			return error;
-	}
 
-	error = mnt_want_write(filepath.mnt);
-	if (!error) {
-		error = vfs_fileattr_set(mnt_idmap(filepath.mnt),
-					 filepath.dentry, &fa);
-		if (error == -ENOIOCTLCMD || error == -ENOTTY)
-			error = -EOPNOTSUPP;
-		mnt_drop_write(filepath.mnt);
+		error = mnt_want_write(filepath.mnt);
+		if (!error) {
+			error = vfs_fileattr_set(mnt_idmap(filepath.mnt),
+						 &filepath, &fa, NULL);
+			mnt_drop_write(filepath.mnt);
+		}
 	}
+	if (error == -ENOIOCTLCMD || error == -ENOTTY)
+		error = -EOPNOTSUPP;
 
 	return error;
 }
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 7050ec0992a1..870756842882 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -2984,7 +2984,7 @@ nfsd_get_case_info(struct dentry *dentry, bool *case_insensitive,
 	}
 	saved = override_creds(probe);
 
-	err = vfs_fileattr_get(cd, &fa);
+	err = __vfs_fileattr_get(cd, &fa);
 
 	put_cred(revert_creds(saved));
 out:
diff --git a/fs/overlayfs/inode.c b/fs/overlayfs/inode.c
index eb408284df08..4f1d3077735b 100644
--- a/fs/overlayfs/inode.c
+++ b/fs/overlayfs/inode.c
@@ -608,47 +608,10 @@ static int ovl_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
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
@@ -718,11 +681,7 @@ int ovl_real_fileattr_get(const struct path *realpath, struct file_kattr *fa)
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
index 91e201af66c2..26782bdb5fa4 100644
--- a/fs/smb/server/smb2pdu.c
+++ b/fs/smb/server/smb2pdu.c
@@ -3660,7 +3660,7 @@ static bool smb2_parent_compressed(struct ksmbd_tree_connect *tcon,
 	bool compressed = false;
 	int rc;
 
-	rc = vfs_fileattr_get(parent, &fa);
+	rc = vfs_fileattr_get(&parent_path, &fa, NULL);
 	if (!rc && fa.flags & FS_COMPR_FL) {
 		compressed = true;
 		goto out;
@@ -5283,7 +5283,7 @@ int smb2_open(struct ksmbd_work *work)
 		smb2_new_xattrs(tcon, &path, fp);
 	}
 
-	ksmbd_vfs_update_compressed_fattr(path.dentry, &fp->f_ci->m_fattr);
+	ksmbd_vfs_update_compressed_fattr(&path, &fp->f_ci->m_fattr);
 
 	if (created) {
 		if (fp->coption & FILE_NO_COMPRESSION_LE) {
@@ -7956,7 +7956,7 @@ static int smb2_get_info_filesystem(struct ksmbd_work *work,
 			FILE_SUPPORTS_SPARSE_FILES |
 			FILE_SUPPORTS_BLOCK_REFCOUNTING;
 
-		err = vfs_fileattr_get(path.dentry, &fa);
+		err = vfs_fileattr_get(&path, &fa, NULL);
 		/*
 		 * -EINVAL, -EOPNOTSUPP: ntfs-3g and other FUSE
 		 * filesystems that lack FS_IOC_FSGETXATTR support.
diff --git a/fs/smb/server/vfs.c b/fs/smb/server/vfs.c
index 54b5f17995c3..d30f89884c06 100644
--- a/fs/smb/server/vfs.c
+++ b/fs/smb/server/vfs.c
@@ -2350,12 +2350,12 @@ int ksmbd_vfs_inherit_posix_acl(const struct mnt_idmap *idmap,
 	return 0;
 }
 
-void ksmbd_vfs_update_compressed_fattr(struct dentry *dentry, __le32 *fattr)
+void ksmbd_vfs_update_compressed_fattr(struct path *path, __le32 *fattr)
 {
 	int rc;
 	struct file_kattr fa = { .flags_valid = true };
 
-	rc = vfs_fileattr_get(dentry, &fa);
+	rc = vfs_fileattr_get(path, &fa, NULL);
 	if (rc)
 		return;
 
@@ -2368,7 +2368,7 @@ int ksmbd_vfs_get_compression(struct ksmbd_file *fp, u16 *fmt)
 	struct file_kattr fa = { .flags_valid = true };
 	int rc;
 
-	rc = vfs_fileattr_get(fp->filp->f_path.dentry, &fa);
+	rc = vfs_fileattr_get(&fp->filp->f_path, &fa, fp->filp);
 	if (rc == -ENOIOCTLCMD || rc == -ENOTTY || rc == -EINVAL ||
 	    rc == -EOPNOTSUPP) {
 		if (fp->f_ci->m_fattr & FILE_ATTRIBUTE_COMPRESSED_LE)
@@ -2395,9 +2395,8 @@ static int __ksmbd_vfs_set_compression(struct ksmbd_work *work,
 				       bool check_access)
 {
 	const struct cred *saved_cred = NULL;
-	struct file_kattr fa;
-	struct dentry *dentry = fp->filp->f_path.dentry;
 	const struct mnt_idmap *idmap = file_mnt_idmap(fp->filp);
+	struct file_kattr fa;
 	u32 flags;
 	__le32 old_fattr;
 	int rc;
@@ -2415,7 +2414,7 @@ static int __ksmbd_vfs_set_compression(struct ksmbd_work *work,
 	}
 
 	saved_cred = override_creds(fp->filp->f_cred);
-	rc = vfs_fileattr_get(dentry, &fa);
+	rc = vfs_fileattr_get(&fp->filp->f_path, &fa, fp->filp);
 	if (rc == -ENOIOCTLCMD || rc == -ENOTTY || rc == -EINVAL ||
 	    rc == -EOPNOTSUPP)
 		goto update_fattr;
@@ -2436,7 +2435,8 @@ static int __ksmbd_vfs_set_compression(struct ksmbd_work *work,
 		if (rc)
 			goto out;
 
-		rc = vfs_fileattr_set(idmap, dentry, &fa);
+		rc = vfs_fileattr_set(idmap, &fp->filp->f_path, &fa,
+				      fp->filp);
 		mnt_drop_write_file(fp->filp);
 		if (rc == -ENOIOCTLCMD || rc == -ENOTTY || rc == -EINVAL ||
 		    rc == -EOPNOTSUPP)
diff --git a/fs/smb/server/vfs.h b/fs/smb/server/vfs.h
index c1ea94cf153f..8231412182a8 100644
--- a/fs/smb/server/vfs.h
+++ b/fs/smb/server/vfs.h
@@ -182,7 +182,7 @@ int ksmbd_vfs_set_init_posix_acl(const struct mnt_idmap *idmap,
 int ksmbd_vfs_inherit_posix_acl(const struct mnt_idmap *idmap,
 				const struct path *path,
 				struct inode *parent_inode);
-void ksmbd_vfs_update_compressed_fattr(struct dentry *dentry, __le32 *fattr);
+void ksmbd_vfs_update_compressed_fattr(struct path *path, __le32 *fattr);
 int ksmbd_vfs_get_compression(struct ksmbd_file *fp, u16 *fmt);
 int ksmbd_vfs_set_compression(struct ksmbd_work *work, struct ksmbd_file *fp, u16 fmt);
 int ksmbd_vfs_set_compression_create(struct ksmbd_work *work,
diff --git a/include/linux/fileattr.h b/include/linux/fileattr.h
index 09e32b84e02a..66ffd2478d1b 100644
--- a/include/linux/fileattr.h
+++ b/include/linux/fileattr.h
@@ -73,9 +73,13 @@ static inline bool fileattr_has_fsx(const struct file_kattr *fa)
 		 fa->fsx_projid != 0 ||	fa->fsx_cowextsize != 0);
 }
 
-int vfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa);
-int vfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
-		     struct file_kattr *fa);
+int __vfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa);
+int __vfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
+		       struct file_kattr *fa);
+int vfs_fileattr_get(const struct path *path, struct file_kattr *fa,
+		     struct file *file);
+int vfs_fileattr_set(const struct mnt_idmap *idmap, const struct path *path,
+		     struct file_kattr *fa, struct file *file);
 int ioctl_getflags(struct file *file, unsigned int __user *argp);
 int ioctl_setflags(struct file *file, unsigned int __user *argp);
 int ioctl_fsgetxattr(struct file *file, void __user *argp);
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index 8b191df5b169..96ae1b548e8d 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -168,8 +168,10 @@ LSM_HOOK(int, 0, inode_removexattr, const struct mnt_idmap *idmap,
 	 const struct path *path, const char *name, struct file *file)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_removexattr, struct dentry *dentry,
 	 const char *name)
-LSM_HOOK(int, 0, inode_file_setattr, struct dentry *dentry, struct file_kattr *fa)
-LSM_HOOK(int, 0, inode_file_getattr, struct dentry *dentry, struct file_kattr *fa)
+LSM_HOOK(int, 0, inode_file_setattr, const struct path *path,
+	 struct file_kattr *fa, struct file *file)
+LSM_HOOK(int, 0, inode_file_getattr, const struct path *path,
+	 struct file_kattr *fa, struct file *file)
 LSM_HOOK(int, 0, inode_set_acl, const struct mnt_idmap *idmap,
 	 const struct path *path, const char *acl_name,
 	 struct posix_acl *kacl, struct file *file)
diff --git a/include/linux/security.h b/include/linux/security.h
index 27291542a7e2..67dc03d7cee2 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -464,10 +464,10 @@ int security_inode_removexattr(const struct mnt_idmap *idmap,
 			       const struct path *path, const char *name,
 			       struct file *file);
 void security_inode_post_removexattr(struct dentry *dentry, const char *name);
-int security_inode_file_setattr(struct dentry *dentry,
-			      struct file_kattr *fa);
-int security_inode_file_getattr(struct dentry *dentry,
-			      struct file_kattr *fa);
+int security_inode_file_setattr(const struct path *path,
+				struct file_kattr *fa, struct file *file);
+int security_inode_file_getattr(const struct path *path,
+				struct file_kattr *fa, struct file *file);
 int security_inode_need_killpriv(struct dentry *dentry);
 int security_inode_killpriv(const struct mnt_idmap *idmap, struct dentry *dentry);
 int security_inode_getsecurity(const struct mnt_idmap *idmap,
@@ -1092,14 +1092,16 @@ static inline void security_inode_post_removexattr(struct dentry *dentry,
 						   const char *name)
 { }
 
-static inline int security_inode_file_setattr(struct dentry *dentry,
-					      struct file_kattr *fa)
+static inline int security_inode_file_setattr(const struct path *path,
+					      struct file_kattr *fa,
+					      struct file *file)
 {
 	return 0;
 }
 
-static inline int security_inode_file_getattr(struct dentry *dentry,
-					      struct file_kattr *fa)
+static inline int security_inode_file_getattr(const struct path *path,
+					      struct file_kattr *fa,
+					      struct file *file)
 {
 	return 0;
 }
diff --git a/security/security.c b/security/security.c
index af1777f2aa5e..661b18f08f1b 100644
--- a/security/security.c
+++ b/security/security.c
@@ -2179,32 +2179,38 @@ void security_inode_post_removexattr(struct dentry *dentry, const char *name)
 
 /**
  * security_inode_file_setattr() - check if setting fsxattr is allowed
- * @dentry: file to set filesystem extended attributes on
+ * @path: file to set filesystem extended attributes on (the VFS makes no
+ *        guarantees with regard to @path->mnt)
  * @fa: extended attributes to set on the inode
+ * @file: file through which the file attributes are set, if any
  *
  * Called when file_setattr() syscall or FS_IOC_FSSETXATTR ioctl() is called on
  * inode
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_file_setattr(struct dentry *dentry, struct file_kattr *fa)
+int security_inode_file_setattr(const struct path *path,
+				struct file_kattr *fa, struct file *file)
 {
-	return call_int_hook(inode_file_setattr, dentry, fa);
+	return call_int_hook(inode_file_setattr, path, fa, file);
 }
 
 /**
  * security_inode_file_getattr() - check if retrieving fsxattr is allowed
- * @dentry: file to retrieve filesystem extended attributes from
+ * @path: file to retrieve filesystem extended attributes from (the VFS makes no
+ *        guarantees with regard to @path->mnt)
  * @fa: extended attributes to get
+ * @file: file through which the file attributes are retrieved, if any
  *
  * Called when file_getattr() syscall or FS_IOC_FSGETXATTR ioctl() is called on
  * inode
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_file_getattr(struct dentry *dentry, struct file_kattr *fa)
+int security_inode_file_getattr(const struct path *path,
+				struct file_kattr *fa, struct file *file)
 {
-	return call_int_hook(inode_file_getattr, dentry, fa);
+	return call_int_hook(inode_file_getattr, path, fa, file);
 }
 
 /**
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 2b5efe041bc1..16c8e852f841 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3570,16 +3570,18 @@ static int selinux_inode_removexattr(const struct mnt_idmap *idmap,
 	return -EACCES;
 }
 
-static int selinux_inode_file_setattr(struct dentry *dentry,
-				      struct file_kattr *fa)
+static int selinux_inode_file_setattr(const struct path *path,
+				      struct file_kattr *fa,
+				      struct file *file)
 {
-	return dentry_has_perm(current_cred(), dentry, FILE__SETATTR);
+	return dentry_has_perm(current_cred(), path->dentry, FILE__SETATTR);
 }
 
-static int selinux_inode_file_getattr(struct dentry *dentry,
-				      struct file_kattr *fa)
+static int selinux_inode_file_getattr(const struct path *path,
+				      struct file_kattr *fa,
+				      struct file *file)
 {
-	return dentry_has_perm(current_cred(), dentry, FILE__GETATTR);
+	return dentry_has_perm(current_cred(), path->dentry, FILE__GETATTR);
 }
 
 static int selinux_path_notify(const struct path *path, u64 mask,
-- 
2.18.0.huawei.25

