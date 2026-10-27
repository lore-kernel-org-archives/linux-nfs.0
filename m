Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.224
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101111;
	b=yiR5S0Ty+RB4mOU7SBjt8ayoqX1iiNR+ZLkvbvjz7heLYpq6YSvqd4A/hpH0g84smKXI
	 tngItu1rdTJt285hSeWqniABNKKZNMkeGatZ3AZfeJSAjpS5ULf//z2qwg4xRKCdC2wGh
	 5p971gO2/aDZqTJc/hyetGjhW0QWd0qKyRTYq/VSQRoXinN8k8TaNOLQMTz0URCpW5Ewj
	 mUlleK2LEpDcnFrY0LON7u3EvKzLCbDiEZmZAlEHWZVyL302pa1n4OOANwWxBg53D9CJd
	 oJxLaWl9NkBO3KXIhxn0NKRH6wKsdf4AsFYESLmyq597VhwNxH5KbYHNqVjQfcx0qgA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101111;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:X-Originating-IP:X-ClientProxiedBy;
	bh=/NtnJSOdjz1gLfDSreIhGeIs1D5UxVR0DX+9y7QpD3Q=;
	b=LnmMH1FtxCnVHQDaZYEFoqlQim1lqeI6d9AYb4brwG3NExb/kfqPbIXGmSh+Xsw5HpT1
	 Exc9PBowX71ZuTQRTjda4L/tW3WTv0E/pPAf00//d1LHvVYnlW1EqQ8TAaiSAcuYj71Ps
	 +LqayEF+mfLBIjuGt8FFPpfARqprcE3n05C3NBAFN7VAqv8f3+/TstzFq36oRU3SS55nI
	 SaQyMZ6B+xF+VVHLOo2561BgCfHqYcpMVR2h/FEb86Lu5VAm7GYp28GN+2zWFUY8xkafy
	 XUa/l0NI0PL69Sc/PM9zeY7PATaCB6WQwciDrmCrI+5bvG08y1M/vC+l0gj4jelQLxg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=6V+SBwMG;
	arc=none smtp.remote-ip=113.46.200.224
Received: from canpmsgout09.his.huawei.com (canpmsgout09.his.huawei.com [113.46.200.224])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EFA70606A323;
	Tue, 27 Oct 2026 11:38:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EFA70606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=6V+SBwMG
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=/NtnJSOdjz1gLfDSreIhGeIs1D5UxVR0DX+9y7QpD3Q=;
	b=6V+SBwMGHZH//Ti8XuWJqNrnIBCQdrBl0dszw8l7fUqEEG7UgoTam+Z7dgwvtruDeak5X+5ZR
	n+yoYht/WNBG6FdgIvlP58zRD6jip6+cNlx0mr7wgdwXAwHmGEbrH/aCXfrd/hw8HqAfoJgl5Up
	uL6fS6oTJ4bStAbFUvAIbIc=
Received: from mail.maildlp.com (unknown [172.19.163.15])
	by canpmsgout09.his.huawei.com (SkyGuard) with ESMTPS id 4jDT5S4T9Dz1cyQt;
	Tue, 27 Oct 2026 19:38:20 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id B15C840578;
	Tue, 27 Oct 2026 19:38:26 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Tue, 27 Oct 2026 19:38:21 +0800
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
Subject: [PATCH v3 -next 05/18] LSM: pass struct path and struct file to the inode_setattr hook
Date: Tue, 27 Oct 2026 20:11:38 +0800
Message-ID: <20261027121151.1887650-6-caixinchen1@huawei.com>
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

The inode_setattr hook is called from notify_change(), which now
holds a struct path and a struct file, together with the idmap that
was taken from the mount when the path was checked.  The other
in-kernel caller, the fat and exfat attribute ioctls, already holds
a struct file and can pass its f_path and its file_mnt_idmap()
directly.

Convert the hook and its SELinux, Smack and EVM implementations to
take the struct path and the struct file, next to the idmap: the
dentry is taken from the path, while the idmap remains a separate
argument, as it must be passed down unchanged so that the VFS and
the LSM are guaranteed to see the same idmap; ecryptfs, for example,
applies attribute changes to a lower path with &nop_mnt_idmap,
which deriving the idmap from that path would not reproduce.

Also pass the struct file through which an attribute change is
requested, when there is one, so that LSMs can later authorize
file descriptor-based operations (fchmod(2), fchown(2),
fchmodat2(2), fchownat(2) and utimensat(2) with AT_EMPTY_PATH, and
the fat/exfat attribute ioctls) with the rights available at
open(2) time.  To that end, do_fchmodat(), do_fchownat() and
do_utimes_path() now follow the vfs_fstatat() pattern and dispatch
an empty path with AT_EMPTY_PATH to the file descriptor-based
vfs_fchmod(), vfs_fchown() and vfs_utimes() callers.  The file is
threaded through notify_change(), chmod_common(), chown_common()
and vfs_utimes(), and set to NULL for path-based operations, for
server-side callers that only hold a path, and for internal kernel
changes: the implicit setuid clearing through __remove_privs(), the
size changes in do_truncate(), which are governed by the truncate
hooks, and the nfsd delegation cmtime updates.  No implementation
uses the file yet, so this is a purely mechanical change with no
behavior change.

Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 drivers/base/devtmpfs.c           |  4 +--
 fs/attr.c                         | 14 +++++----
 fs/btrfs/volumes.c                |  2 +-
 fs/ecryptfs/inode.c               |  4 +--
 fs/exfat/file.c                   |  2 +-
 fs/fat/file.c                     |  2 +-
 fs/init.c                         |  6 ++--
 fs/inode.c                        |  2 +-
 fs/internal.h                     |  6 ++--
 fs/nfsd/nfs4state.c               |  4 +--
 fs/nfsd/vfs.c                     |  4 +--
 fs/open.c                         | 50 +++++++++++++++++++++++--------
 fs/overlayfs/overlayfs.h          |  2 +-
 fs/smb/server/smb2pdu.c           |  2 +-
 fs/smb/server/smbacl.c            |  2 +-
 fs/utimes.c                       | 21 +++++++++----
 include/linux/fs.h                |  6 ++--
 include/linux/lsm_hook_defs.h     | 12 ++++++--
 include/linux/security.h          |  8 +++--
 init/initramfs.c                  |  2 +-
 security/integrity/evm/evm_main.c |  9 ++++--
 security/security.c               | 10 ++++---
 security/selinux/hooks.c          |  6 ++--
 security/smack/smack_lsm.c        |  9 ++++--
 24 files changed, 127 insertions(+), 62 deletions(-)

diff --git a/drivers/base/devtmpfs.c b/drivers/base/devtmpfs.c
index 410906a66ee9..00f2e3e7e27e 100644
--- a/drivers/base/devtmpfs.c
+++ b/drivers/base/devtmpfs.c
@@ -291,7 +291,7 @@ static int handle_create(const char *nodename, umode_t mode, kuid_t uid,
 		newattrs.ia_gid = gid;
 		newattrs.ia_valid = ATTR_MODE|ATTR_UID|ATTR_GID;
 		inode_lock(d_inode(dentry));
-		notify_change(&nop_mnt_idmap, &attr_path, &newattrs, NULL);
+		notify_change(&nop_mnt_idmap, &attr_path, &newattrs, NULL, NULL);
 		inode_unlock(d_inode(dentry));
 
 		/* mark as kernel-created inode */
@@ -392,7 +392,7 @@ static int handle_remove(const char *nodename, struct device *dev)
 		newattrs.ia_valid =
 			ATTR_UID|ATTR_GID|ATTR_MODE;
 		inode_lock(d_inode(dentry));
-		notify_change(&nop_mnt_idmap, &attr_path, &newattrs, NULL);
+		notify_change(&nop_mnt_idmap, &attr_path, &newattrs, NULL, NULL);
 		inode_unlock(d_inode(dentry));
 		err = vfs_unlink(&nop_mnt_idmap, d_inode(parent.dentry),
 				 dentry, NULL);
diff --git a/fs/attr.c b/fs/attr.c
index cc06fd676e6b..67fa5ee6b30e 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -400,7 +400,8 @@ EXPORT_SYMBOL(may_setattr);
 static int do_notify_change(const struct path *const path,
 			    const struct mnt_idmap *const idmap,
 			    struct dentry *const dentry, struct iattr *attr,
-			    struct delegated_inode *delegated_inode)
+			    struct delegated_inode *delegated_inode,
+			    struct file *const file)
 {
 	struct inode *inode = dentry->d_inode;
 	umode_t mode = inode->i_mode;
@@ -518,7 +519,7 @@ static int do_notify_change(const struct path *const path,
 	 * filesystem, were already checked on the user-facing path.
 	 */
 	if (path) {
-		error = security_inode_setattr(idmap, dentry, attr);
+		error = security_inode_setattr(idmap, path, attr, file);
 		if (error)
 			return error;
 	}
@@ -570,7 +571,8 @@ static int do_notify_change(const struct path *const path,
 int __notify_change(const struct mnt_idmap *idmap, struct dentry *dentry,
 		    struct iattr *attr, struct delegated_inode *delegated_inode)
 {
-	return do_notify_change(NULL, idmap, dentry, attr, delegated_inode);
+	return do_notify_change(NULL, idmap, dentry, attr, delegated_inode,
+				NULL);
 }
 EXPORT_SYMBOL(__notify_change);
 
@@ -580,6 +582,7 @@ EXPORT_SYMBOL(__notify_change);
  * @path:	object affected
  * @attr:	new attributes
  * @delegated_inode: returns inode, if the inode is delegated
+ * @file:	file through which the attribute change is requested, if any
  *
  * The caller must hold the i_rwsem exclusively on the affected object.
  *
@@ -604,9 +607,10 @@ EXPORT_SYMBOL(__notify_change);
  * Return: 0 on success, or a negative error on failure.
  */
 int notify_change(const struct mnt_idmap *idmap, const struct path *path,
-		  struct iattr *attr, struct delegated_inode *delegated_inode)
+		  struct iattr *attr, struct delegated_inode *delegated_inode,
+		  struct file *file)
 {
 	return do_notify_change(path, idmap, path->dentry, attr,
-				delegated_inode);
+				delegated_inode, file);
 }
 EXPORT_SYMBOL(notify_change);
diff --git a/fs/btrfs/volumes.c b/fs/btrfs/volumes.c
index f1305f68b1f8..2f91b81bbd30 100644
--- a/fs/btrfs/volumes.c
+++ b/fs/btrfs/volumes.c
@@ -2152,7 +2152,7 @@ static void update_dev_time(const char *device_path)
 	}
 
 	if (!err) {
-		vfs_utimes(&path, NULL);
+		vfs_utimes(&path, NULL, NULL);
 		path_put(&path);
 	}
 }
diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index 7db6fa6e5274..a6de40fcce4c 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -822,7 +822,7 @@ static int __ecryptfs_truncate(struct dentry *dentry, const struct iattr *ia)
 set_size:
 	lower_ia.ia_valid |= ATTR_SIZE;
 	inode_lock(d_inode(lower_dentry));
-	rc = notify_change(&nop_mnt_idmap, &lower_path, &lower_ia, NULL);
+	rc = notify_change(&nop_mnt_idmap, &lower_path, &lower_ia, NULL, NULL);
 	inode_unlock(d_inode(lower_dentry));
 out:
 	ecryptfs_put_lower_file(inode);
@@ -932,7 +932,7 @@ static int ecryptfs_setattr(const struct mnt_idmap *idmap,
 
 		inode_lock(d_inode(lower_path.dentry));
 		rc = notify_change(&nop_mnt_idmap, &lower_path, &lower_ia,
-				   NULL);
+				   NULL, NULL);
 		inode_unlock(d_inode(lower_path.dentry));
 	}
 out:
diff --git a/fs/exfat/file.c b/fs/exfat/file.c
index 1386149916bb..27b4917e02cb 100644
--- a/fs/exfat/file.c
+++ b/fs/exfat/file.c
@@ -552,7 +552,7 @@ static int exfat_ioctl_set_attributes(struct file *file, u32 __user *user_attr)
 	 * module, just because it maps to a file mode.
 	 */
 	err = security_inode_setattr(file_mnt_idmap(file),
-				     file->f_path.dentry, &ia);
+			     &file->f_path, &ia, file);
 	if (err)
 		goto out_unlock_inode;
 
diff --git a/fs/fat/file.c b/fs/fat/file.c
index 70583e791bdc..a044270379e4 100644
--- a/fs/fat/file.c
+++ b/fs/fat/file.c
@@ -93,7 +93,7 @@ static int fat_ioctl_set_attributes(struct file *file, u32 __user *user_attr)
 	 * module, just because it maps to a file mode.
 	 */
 	err = security_inode_setattr(file_mnt_idmap(file),
-				     file->f_path.dentry, &ia);
+			     &file->f_path, &ia, file);
 	if (err)
 		goto out_unlock_inode;
 
diff --git a/fs/init.c b/fs/init.c
index 33e312d74f58..b65e47e59ee0 100644
--- a/fs/init.c
+++ b/fs/init.c
@@ -107,7 +107,7 @@ int __init init_chown(const char *filename, uid_t user, gid_t group, int flags)
 		return error;
 	error = mnt_want_write(path.mnt);
 	if (!error) {
-		error = chown_common(&path, user, group);
+		error = chown_common(&path, user, group, NULL);
 		mnt_drop_write(path.mnt);
 	}
 	path_put(&path);
@@ -122,7 +122,7 @@ int __init init_chmod(const char *filename, umode_t mode)
 	error = kern_path(filename, LOOKUP_FOLLOW, &path);
 	if (error)
 		return error;
-	error = chmod_common(&path, mode);
+	error = chmod_common(&path, mode, NULL);
 	path_put(&path);
 	return error;
 }
@@ -201,7 +201,7 @@ int __init init_utimes(char *filename, struct timespec64 *ts)
 	error = kern_path(filename, 0, &path);
 	if (error)
 		return error;
-	error = vfs_utimes(&path, ts);
+	error = vfs_utimes(&path, ts, NULL);
 	path_put(&path);
 	return error;
 }
diff --git a/fs/inode.c b/fs/inode.c
index fe176293fd36..d69973fabd52 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2366,7 +2366,7 @@ static int __remove_privs(const struct mnt_idmap *idmap,
 	 * Note we call this on write, so notify_change will not
 	 * encounter any conflicting delegations:
 	 */
-	return notify_change(idmap, path, &newattrs, NULL);
+	return notify_change(idmap, path, &newattrs, NULL, NULL);
 }
 
 static int file_remove_privs_flags(struct file *file, unsigned int flags)
diff --git a/fs/internal.h b/fs/internal.h
index dcbc54f9803c..e90de99de5ea 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -201,10 +201,12 @@ struct file *file_close_fd_locked(struct files_struct *files, unsigned fd);
 int filp_close_sync(struct file *filp, fl_owner_t id);
 
 int do_ftruncate(struct file *file, loff_t length, unsigned int flags);
-int chmod_common(const struct path *path, umode_t mode);
+int chmod_common(const struct path *path, umode_t mode,
+		  struct file *file);
 int do_fchownat(int dfd, const char __user *filename, uid_t user, gid_t group,
 		int flag);
-int chown_common(const struct path *path, uid_t user, gid_t group);
+int chown_common(const struct path *path, uid_t user, gid_t group,
+		  struct file *file);
 extern int vfs_open(const struct path *, struct file *);
 int vfs_open_consume(struct path *, struct file *);
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3a08c56a27c6..38451d1de587 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -10510,7 +10510,7 @@ static int cb_getattr_update_times(const struct path *path,
 
 	attrs.ia_valid |= ATTR_DELEG;
 	inode_lock(inode);
-	ret = notify_change(&nop_mnt_idmap, path, &attrs, NULL);
+	ret = notify_change(&nop_mnt_idmap, path, &attrs, NULL, NULL);
 	inode_unlock(inode);
 	return ret;
 }
@@ -10791,7 +10791,7 @@ void nfsd_update_cmtime_attr(struct file *f, unsigned int flags)
 	};
 
 	inode_lock(inode);
-	ret = notify_change(&nop_mnt_idmap, &f->f_path, &attr, NULL);
+	ret = notify_change(&nop_mnt_idmap, &f->f_path, &attr, NULL, NULL);
 	inode_unlock(inode);
 	if (ret)
 		pr_notice_ratelimited("nfsd: Unable to update timestamps on "
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 397f417e77b3..2ab92a0e3b6b 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -478,7 +478,7 @@ static int __nfsd_setattr(const struct path *path, struct iattr *iap)
 			return -EFBIG;
 
 		host_err = notify_change(&nop_mnt_idmap, path, &size_attr,
-					  NULL);
+					  NULL, NULL);
 		if (host_err)
 			return host_err;
 		iap->ia_valid &= ~ATTR_SIZE;
@@ -504,7 +504,7 @@ static int __nfsd_setattr(const struct path *path, struct iattr *iap)
 	if (!(iap->ia_valid & ATTR_DELEG))
 		iap->ia_valid |= ATTR_CTIME;
 
-	return notify_change(&nop_mnt_idmap, path, iap, NULL);
+	return notify_change(&nop_mnt_idmap, path, iap, NULL, NULL);
 }
 
 /**
diff --git a/fs/open.c b/fs/open.c
index 294d0ea7488e..882985d4008b 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -65,8 +65,13 @@ int do_truncate(const struct mnt_idmap *idmap, const struct path *path,
 	if (ret)
 		return ret;
 
-	/* Note any delegations or leases have already been broken: */
-	ret = notify_change(idmap, path, &newattrs, NULL);
+	/*
+	 * Note any delegations or leases have already been broken.  Size
+	 * changes are governed by the truncate hooks, which are checked at
+	 * ftruncate(2) time on the opened file, so no struct file is passed
+	 * to the setattr hook.
+	 */
+	ret = notify_change(idmap, path, &newattrs, NULL, NULL);
 	inode_unlock(dentry->d_inode);
 	return ret;
 }
@@ -665,7 +670,7 @@ SYSCALL_DEFINE2(fchroot, int, fd, unsigned int, flags)
 	return error;
 }
 
-int chmod_common(const struct path *path, umode_t mode)
+int chmod_common(const struct path *path, umode_t mode, struct file *file)
 {
 	struct inode *inode = path->dentry->d_inode;
 	struct delegated_inode delegated_inode = { };
@@ -685,7 +690,7 @@ int chmod_common(const struct path *path, umode_t mode)
 	newattrs.ia_mode = (mode & S_IALLUGO) | (inode->i_mode & ~S_IALLUGO);
 	newattrs.ia_valid = ATTR_MODE | ATTR_CTIME;
 	error = notify_change(mnt_idmap(path->mnt), path, &newattrs,
-			      &delegated_inode);
+			      &delegated_inode, file);
 out_unlock:
 	inode_unlock(inode);
 	if (is_delegated(&delegated_inode)) {
@@ -701,7 +706,7 @@ int chmod_common(const struct path *path, umode_t mode)
 int vfs_fchmod(struct file *file, umode_t mode)
 {
 	audit_file(file);
-	return chmod_common(&file->f_path, mode);
+	return chmod_common(&file->f_path, mode, file);
 }
 
 SYSCALL_DEFINE2(fchmod, unsigned int, fd, umode_t, mode)
@@ -724,12 +729,22 @@ static int do_fchmodat(int dfd, const char __user *filename, umode_t mode,
 	if (unlikely(flags & ~(AT_SYMLINK_NOFOLLOW | AT_EMPTY_PATH)))
 		return -EINVAL;
 
+	CLASS(filename_maybe_null, name)(filename, flags);
+
+	if (!name && dfd >= 0) {
+		CLASS(fd, f)(dfd);
+
+		if (fd_empty(f))
+			return -EBADF;
+
+		return vfs_fchmod(fd_file(f), mode);
+	}
+
 	lookup_flags = (flags & AT_SYMLINK_NOFOLLOW) ? 0 : LOOKUP_FOLLOW;
-	CLASS(filename_uflags, name)(filename, flags);
 retry:
 	error = filename_lookup(dfd, name, lookup_flags, &path, NULL);
 	if (!error) {
-		error = chmod_common(&path, mode);
+		error = chmod_common(&path, mode, NULL);
 		path_put(&path);
 		if (retry_estale(error, lookup_flags)) {
 			lookup_flags |= LOOKUP_REVAL;
@@ -786,7 +801,8 @@ static inline bool setattr_vfsgid(struct iattr *attr, kgid_t kgid)
 	return true;
 }
 
-int chown_common(const struct path *path, uid_t user, gid_t group)
+int chown_common(const struct path *path, uid_t user, gid_t group,
+		 struct file *file)
 {
 	const struct mnt_idmap *idmap;
 	struct user_namespace *fs_userns;
@@ -824,7 +840,7 @@ int chown_common(const struct path *path, uid_t user, gid_t group)
 		from_vfsgid(idmap, fs_userns, newattrs.ia_vfsgid));
 	if (!error)
 		error = notify_change(idmap, path, &newattrs,
-				      &delegated_inode);
+				      &delegated_inode, file);
 	inode_unlock(inode);
 	if (is_delegated(&delegated_inode)) {
 		error = break_deleg_wait(&delegated_inode);
@@ -844,14 +860,24 @@ int do_fchownat(int dfd, const char __user *filename, uid_t user, gid_t group,
 	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_EMPTY_PATH)) != 0)
 		return -EINVAL;
 
+	CLASS(filename_maybe_null, name)(filename, flag);
+
+	if (!name && dfd >= 0) {
+		CLASS(fd, f)(dfd);
+
+		if (fd_empty(f))
+			return -EBADF;
+
+		return vfs_fchown(fd_file(f), user, group);
+	}
+
 	lookup_flags = (flag & AT_SYMLINK_NOFOLLOW) ? 0 : LOOKUP_FOLLOW;
-	CLASS(filename_uflags, name)(filename, flag);
 retry:
 	error = filename_lookup(dfd, name, lookup_flags, &path, NULL);
 	if (!error) {
 		error = mnt_want_write(path.mnt);
 		if (!error) {
-			error = chown_common(&path, user, group);
+			error = chown_common(&path, user, group, NULL);
 			mnt_drop_write(path.mnt);
 		}
 		path_put(&path);
@@ -888,7 +914,7 @@ int vfs_fchown(struct file *file, uid_t user, gid_t group)
 	if (error)
 		return error;
 	audit_file(file);
-	error = chown_common(&file->f_path, user, group);
+	error = chown_common(&file->f_path, user, group, file);
 	mnt_drop_write_file(file);
 	return error;
 }
diff --git a/fs/overlayfs/overlayfs.h b/fs/overlayfs/overlayfs.h
index fc5e7accc1f0..a169f27258a0 100644
--- a/fs/overlayfs/overlayfs.h
+++ b/fs/overlayfs/overlayfs.h
@@ -213,7 +213,7 @@ static inline int ovl_do_notify_change(struct ovl_fs *ofs,
 		.dentry = upperdentry,
 	};
 
-	return notify_change(ovl_upper_mnt_idmap(ofs), &path, attr, NULL);
+	return notify_change(ovl_upper_mnt_idmap(ofs), &path, attr, NULL, NULL);
 }
 
 static inline int ovl_do_rmdir(struct ovl_fs *ofs,
diff --git a/fs/smb/server/smb2pdu.c b/fs/smb/server/smb2pdu.c
index 07b0a71a4353..91e201af66c2 100644
--- a/fs/smb/server/smb2pdu.c
+++ b/fs/smb/server/smb2pdu.c
@@ -8778,7 +8778,7 @@ static int set_file_basic_info(struct ksmbd_file *fp,
 			return -EACCES;
 
 		inode_lock(inode);
-		rc = notify_change(idmap, &filp->f_path, &attrs, NULL);
+		rc = notify_change(idmap, &filp->f_path, &attrs, NULL, filp);
 		inode_unlock(inode);
 	}
 	return rc;
diff --git a/fs/smb/server/smbacl.c b/fs/smb/server/smbacl.c
index 94bf83d07452..c0f8f6d8ea98 100644
--- a/fs/smb/server/smbacl.c
+++ b/fs/smb/server/smbacl.c
@@ -1749,7 +1749,7 @@ int set_info_sec(struct ksmbd_conn *conn, struct ksmbd_tree_connect *tcon,
 	}
 
 	inode_lock(inode);
-	rc = notify_change(idmap, path, &newattrs, NULL);
+	rc = notify_change(idmap, path, &newattrs, NULL, NULL);
 	inode_unlock(inode);
 	if (rc)
 		goto out;
diff --git a/fs/utimes.c b/fs/utimes.c
index 5193d504d289..6021c481e742 100644
--- a/fs/utimes.c
+++ b/fs/utimes.c
@@ -18,7 +18,8 @@ static bool nsec_valid(long nsec)
 	return nsec >= 0 && nsec <= 999999999;
 }
 
-int vfs_utimes(const struct path *path, struct timespec64 *times)
+int vfs_utimes(const struct path *path, struct timespec64 *times,
+	       struct file *file)
 {
 	int error;
 	struct iattr newattrs;
@@ -65,7 +66,7 @@ int vfs_utimes(const struct path *path, struct timespec64 *times)
 retry_deleg:
 	inode_lock(inode);
 	error = notify_change(mnt_idmap(path->mnt), path, &newattrs,
-			      &delegated_inode);
+			      &delegated_inode, file);
 	inode_unlock(inode);
 	if (is_delegated(&delegated_inode)) {
 		error = break_deleg_wait(&delegated_inode);
@@ -88,15 +89,25 @@ static int do_utimes_path(int dfd, const char __user *filename,
 	if (flags & ~(AT_SYMLINK_NOFOLLOW | AT_EMPTY_PATH))
 		return -EINVAL;
 
+	CLASS(filename_maybe_null, name)(filename, flags);
+
+	if (!name && dfd >= 0) {
+		CLASS(fd, f)(dfd);
+
+		if (fd_empty(f))
+			return -EBADF;
+
+		return vfs_utimes(&fd_file(f)->f_path, times, fd_file(f));
+	}
+
 	if (!(flags & AT_SYMLINK_NOFOLLOW))
 		lookup_flags |= LOOKUP_FOLLOW;
 
-	CLASS(filename_uflags, name)(filename, flags);
 retry:
 	error = filename_lookup(dfd, name, lookup_flags, &path, NULL);
 	if (error)
 		return error;
-	error = vfs_utimes(&path, times);
+	error = vfs_utimes(&path, times, NULL);
 	path_put(&path);
 	if (retry_estale(error, lookup_flags)) {
 		lookup_flags |= LOOKUP_REVAL;
@@ -113,7 +124,7 @@ static int do_utimes_fd(int fd, struct timespec64 *times, int flags)
 	CLASS(fd, f)(fd);
 	if (fd_empty(f))
 		return -EBADF;
-	return vfs_utimes(&fd_file(f)->f_path, times);
+	return vfs_utimes(&fd_file(f)->f_path, times, fd_file(f));
 }
 
 /*
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 960334128b83..9c344cbad296 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1818,7 +1818,8 @@ int vfs_mkobj(struct dentry *, umode_t,
 
 int vfs_fchown(struct file *file, uid_t user, gid_t group);
 int vfs_fchmod(struct file *file, umode_t mode);
-int vfs_utimes(const struct path *path, struct timespec64 *times);
+int vfs_utimes(const struct path *path, struct timespec64 *times,
+		struct file *file);
 
 #ifdef CONFIG_COMPAT
 extern long compat_ptr_ioctl(struct file *file, unsigned int cmd,
@@ -2717,7 +2718,8 @@ static inline int bmap(struct inode *inode,  sector_t *block)
 int __notify_change(const struct mnt_idmap *, struct dentry *,
 		    struct iattr *, struct delegated_inode *);
 int notify_change(const struct mnt_idmap *, const struct path *,
-		  struct iattr *, struct delegated_inode *);
+		  struct iattr *, struct delegated_inode *,
+		  struct file *);
 int inode_permission(const struct mnt_idmap *, struct inode *, int);
 int generic_permission(const struct mnt_idmap *, struct inode *, int);
 static inline int file_permission(struct file *file, int mask)
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index 539525648b30..ea6e0fbaa3b9 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -141,8 +141,16 @@ LSM_HOOK(int, 0, inode_follow_link, struct dentry *dentry, struct inode *inode,
 	 bool rcu)
 LSM_HOOK(int, 0, inode_permission, const struct mnt_idmap *idmap,
 	 struct inode *inode, int mask)
-LSM_HOOK(int, 0, inode_setattr, const struct mnt_idmap *idmap, struct dentry *dentry,
-	 struct iattr *attr)
+/*
+ * For the hooks that pass a struct path: the VFS only sanctions
+ * passing the path to VFS helpers taking a struct path (e.g.,
+ * notify_change(), the *xattr() helpers); it makes no guarantees
+ * with regard to path->mnt, whose layout and implementation details
+ * are subject to change.  Implementations must not rely on its
+ * properties.
+ */
+LSM_HOOK(int, 0, inode_setattr, const struct mnt_idmap *idmap,
+	 const struct path *path, struct iattr *attr, struct file *file)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_setattr, const struct mnt_idmap *idmap,
 	 struct dentry *dentry, int ia_valid)
 LSM_HOOK(int, 0, inode_getattr, const struct path *path)
diff --git a/include/linux/security.h b/include/linux/security.h
index 225f822470e2..8b660c118dee 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -429,7 +429,8 @@ int security_inode_follow_link(struct dentry *dentry, struct inode *inode,
 int security_inode_permission(const struct mnt_idmap *idmap,
 			      struct inode *inode, int mask);
 int security_inode_setattr(const struct mnt_idmap *idmap,
-			   struct dentry *dentry, struct iattr *attr);
+			   const struct path *path, struct iattr *attr,
+			   struct file *file);
 void security_inode_post_setattr(const struct mnt_idmap *idmap, struct dentry *dentry,
 				 int ia_valid);
 int security_inode_getattr(const struct path *path);
@@ -995,8 +996,9 @@ static inline int security_inode_permission(const struct mnt_idmap *idmap,
 }
 
 static inline int security_inode_setattr(const struct mnt_idmap *idmap,
-					 struct dentry *dentry,
-					 struct iattr *attr)
+					 const struct path *path,
+					 struct iattr *attr,
+					 struct file *file)
 {
 	return 0;
 }
diff --git a/init/initramfs.c b/init/initramfs.c
index ebddde9c8f0d..c8172440276e 100644
--- a/init/initramfs.c
+++ b/init/initramfs.c
@@ -144,7 +144,7 @@ static void __init do_utime(char *filename, time64_t mtime)
 static void __init do_utime_path(const struct path *path, time64_t mtime)
 {
 	struct timespec64 t[2] = { { .tv_sec = mtime }, { .tv_sec = mtime } };
-	vfs_utimes(path, t);
+	vfs_utimes(path, t, NULL);
 }
 
 static __initdata LIST_HEAD(dir_list);
diff --git a/security/integrity/evm/evm_main.c b/security/integrity/evm/evm_main.c
index ac8328812e6e..9526bffe34aa 100644
--- a/security/integrity/evm/evm_main.c
+++ b/security/integrity/evm/evm_main.c
@@ -950,17 +950,20 @@ static int evm_attr_change(const struct mnt_idmap *idmap,
 /**
  * evm_inode_setattr - prevent updating an invalid EVM extended attribute
  * @idmap: idmap of the mount
- * @dentry: pointer to the affected dentry
+ * @path: pointer to the affected object
  * @attr: iattr structure containing the new file attributes
+ * @file: file through which the attribute change is requested, if any
  *
  * Permit update of file attributes when files have a valid EVM signature,
  * except in the case of them having an immutable portable signature.
  */
-static int evm_inode_setattr(const struct mnt_idmap *idmap, struct dentry *dentry,
-			     struct iattr *attr)
+static int evm_inode_setattr(const struct mnt_idmap *idmap,
+			     const struct path *path,
+			     struct iattr *attr, struct file *file)
 {
 	unsigned int ia_valid = attr->ia_valid;
 	enum integrity_status evm_status;
+	struct dentry *dentry = path->dentry;
 
 	/* Policy permits modification of the protected attrs even though
 	 * there's no HMAC key loaded
diff --git a/security/security.c b/security/security.c
index 49cd3393c207..9c1e27f0e5cb 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1867,8 +1867,9 @@ int security_inode_permission(const struct mnt_idmap *idmap,
 /**
  * security_inode_setattr() - Check if setting file attributes is allowed
  * @idmap: idmap of the mount
- * @dentry: file
+ * @path: file (the VFS makes no guarantees with regard to @path->mnt)
  * @attr: new attributes
+ * @file: file through which the attribute change is requested, if any
  *
  * Check permission before setting file attributes.  Note that the kernel call
  * to notify_change is performed from several locations, whenever file
@@ -1878,11 +1879,12 @@ int security_inode_permission(const struct mnt_idmap *idmap,
  * Return: Returns 0 if permission is granted.
  */
 int security_inode_setattr(const struct mnt_idmap *idmap,
-			   struct dentry *dentry, struct iattr *attr)
+			   const struct path *path, struct iattr *attr,
+			   struct file *file)
 {
-	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
+	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_setattr, idmap, dentry, attr);
+	return call_int_hook(inode_setattr, idmap, path, attr, file);
 }
 EXPORT_SYMBOL_GPL(security_inode_setattr);
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 548a14ff0664..3d8636149f59 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3316,10 +3316,12 @@ static int selinux_inode_permission(const struct mnt_idmap *idmap,
 	return rc;
 }
 
-static int selinux_inode_setattr(const struct mnt_idmap *idmap, struct dentry *dentry,
-				 struct iattr *iattr)
+static int selinux_inode_setattr(const struct mnt_idmap *idmap,
+				 const struct path *path,
+				 struct iattr *iattr, struct file *file)
 {
 	const struct cred *cred = current_cred();
+	struct dentry *dentry = path->dentry;
 	struct inode *inode = d_backing_inode(dentry);
 	unsigned int ia_valid = iattr->ia_valid;
 	u32 av = FILE__WRITE;
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index b39bee15b70c..ede1314030af 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1267,15 +1267,18 @@ static int smack_inode_permission(const struct mnt_idmap *idmap, struct inode *i
 /**
  * smack_inode_setattr - Smack check for setting attributes
  * @idmap: idmap of the mount
- * @dentry: the object
+ * @path: the object
  * @iattr: for the force flag
+ * @file: file through which the attribute change is requested, if any
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_setattr(const struct mnt_idmap *idmap, struct dentry *dentry,
-			       struct iattr *iattr)
+static int smack_inode_setattr(const struct mnt_idmap *idmap,
+			       const struct path *path,
+			       struct iattr *iattr, struct file *file)
 {
 	struct smk_audit_info ad;
+	struct dentry *dentry = path->dentry;
 	int rc;
 
 	/*
-- 
2.18.0.huawei.25

