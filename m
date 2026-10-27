Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.227
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101131;
	b=sSqhQhJKvZn3ocs5lCHpMInd5ugRKgHi9Q1xfUGxgJvbdb+cEGKU1VxSROeJTSs6Jk5p
	 qHwbDRIEq/b5H+FgtTuI9zADtSnmCuUevLqI2OZKa6E/+1MCLdUm2qevAhWyXneUptSVl
	 GAsUw4luZJLKtzouVItyxh65OTVgITQbV5MsfR0F7HEoOc9/yR0Cxv3Dh2sNMwcGTxtqP
	 jIElY7z+W9yVY0LouOWGti5q5CUZB177EgfpUZUVCdKFU08FlZqChcvH9qCo/5Z4KjyZk
	 8EOMb9P60Uo030pnqf+aRpMoPfi/AKPxnOhAo00XTPS/4KIcz4jaWGqySgF2J42m5YA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101131;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:X-Originating-IP:X-ClientProxiedBy;
	bh=+d9rHZYLZThvX6aVpE8e7khbDvKIwM9B4lKTVwHphg8=;
	b=37To3t/BBbzzsIA3j2mh2D4RBN1c2rlYAn1kOjXGcOOZE3R/3RAHRA60p1Z6CujMvI4D
	 bOd8t5Q1sv4AJdXc8IyP5Ei0CORmw9ORRaDF5fMX0jFLtLODxoY3bFmSP17GJVIKRRP7S
	 w0eSLdIRE+hxbBmYp5CEf96M2tT519TV8DkkPqToIwYIvgDkut1NkA96+Daq8psc+/vYS
	 sIDM3ePXEe4jiMSbiKaZlCQnpWAZvcrsV7i2Csk6F28uBPffXq/n+i4dVWqxnXuJpnoeq
	 HWPGiGiqBrgamy8uA/S7e8HA6ZTJnSZ40OfKbcPcuDbD+1h8bMO1MkG7JPNONORT0gQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=L5CEqhCJ;
	arc=none smtp.remote-ip=113.46.200.227
Received: from canpmsgout12.his.huawei.com (canpmsgout12.his.huawei.com [113.46.200.227])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9EAA8606DB2E;
	Tue, 27 Oct 2026 11:38:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9EAA8606DB2E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=L5CEqhCJ
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=+d9rHZYLZThvX6aVpE8e7khbDvKIwM9B4lKTVwHphg8=;
	b=L5CEqhCJuWll76bMvHB5ngW7DTlRjQVvjoYCEVXWfyQXHTubp6vR3oGOpzjjV4FYFLb3LsGss
	RgSGim43goFPPtnoEGkp1M7fawxvxKFlyOrb5zB3D1XrNk4ipVR/cd5NJZByWBuIDsYDwA6KClA
	xzT0bTyG7WN8r29zlYBNVm4=
Received: from mail.maildlp.com (unknown [172.19.163.214])
	by canpmsgout12.his.huawei.com (SkyGuard) with ESMTPS id 4jDT644W5BznTWH;
	Tue, 27 Oct 2026 19:38:52 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 5B7B34056C;
	Tue, 27 Oct 2026 19:38:47 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Tue, 27 Oct 2026 19:38:41 +0800
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
Subject: [PATCH v3 -next 09/18] LSM: rename inode_getattr to path_getattr and pass struct file
Date: Tue, 27 Oct 2026 20:11:42 +0800
Message-ID: <20261027121151.1887650-10-caixinchen1@huawei.com>
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

The inode_getattr hook receives a struct path, so rename it to
path_getattr to follow the path_* naming convention used for the
other hooks that take a struct path (path_chmod, path_chown, ...).
Rename the security_inode_getattr() inline wrapper to
security_path_getattr() and the SELinux, Smack, AppArmor and TOMOYO
implementations accordingly.

Also pass the struct file through which the attributes are
requested, when there is one, so that LSMs can later authorize
file descriptor-based operations (fstat(2), statx(2) with an empty
path, and fstatat(2) with AT_EMPTY_PATH) with the rights available
at open(2) time.  vfs_getattr() has many callers and keeps its
signature; it calls the hook with NULL.  The file descriptor-based
vfs_fstat() and vfs_statx_fd() call security_path_getattr()
explicitly with the file they hold and then the unchecked
vfs_getattr_nosec(); vfs_statx_path() takes the file and calls the
hook explicitly, with NULL from the filename-based vfs_statx().  No
implementation uses the file yet, so this part is a purely
mechanical change with no behavior change either.

BPF programs attach to LSM hooks and to the security_*() wrappers by
name ("lsm/inode_getattr", "fentry/security_inode_getattr"), so
update the BPF selftests to the new names, along with the d_path BTF
allowlist in kernel/trace/bpf_trace.c.  Convert the CHECK() in
test_d_path_basic() that this touches to ASSERT_TRUE() to follow the
current selftests style.

Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/stat.c                                     | 48 ++++++++++++-------
 include/linux/lsm_hook_defs.h                 |  3 +-
 include/linux/security.h                      |  5 +-
 kernel/bpf/bpf_lsm.c                          |  2 +-
 kernel/trace/bpf_trace.c                      |  2 +-
 security/apparmor/lsm.c                       |  5 +-
 security/security.c                           |  9 ++--
 security/selinux/hooks.c                      |  5 +-
 security/smack/smack_lsm.c                    |  8 ++--
 security/tomoyo/tomoyo.c                      |  7 +--
 .../testing/selftests/bpf/prog_tests/d_path.c |  4 +-
 .../testing/selftests/bpf/progs/test_d_path.c |  2 +-
 .../bpf/progs/test_d_path_check_rdonly_mem.c  |  2 +-
 .../bpf/progs/test_d_path_check_types.c       |  2 +-
 .../selftests/bpf/progs/verifier_vfs_accept.c |  2 +-
 15 files changed, 64 insertions(+), 42 deletions(-)

diff --git a/fs/stat.c b/fs/stat.c
index a2e63c6c45b7..f2bb0e2d1ef1 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -172,11 +172,12 @@ EXPORT_SYMBOL_GPL(generic_fill_statx_atomic_writes);
  * @request_mask: STATX_xxx flags indicating what the caller wants
  * @query_flags: Query mode (AT_STATX_SYNC_TYPE)
  *
- * Get attributes without calling security_inode_getattr.
+ * Get attributes without calling security_path_getattr.
  *
- * Currently the only caller other than vfs_getattr is internal to the
- * filehandle lookup code, which uses only the inode number and returns no
- * attributes to any user.  Any other code probably wants vfs_getattr.
+ * Callers must call security_path_getattr() beforehand, unless they only
+ * use the attributes internally: the filehandle lookup code, for
+ * instance, uses only the inode number and returns no attributes to any
+ * user.  Code that merely holds a path probably wants vfs_getattr().
  */
 int vfs_getattr_nosec(const struct path *path, struct kstat *stat,
 		      u32 request_mask, unsigned int query_flags)
@@ -260,7 +261,7 @@ int vfs_getattr(const struct path *path, struct kstat *stat,
 {
 	int retval;
 
-	retval = security_inode_getattr(path);
+	retval = security_path_getattr(path, NULL);
 	if (unlikely(retval))
 		return retval;
 	return vfs_getattr_nosec(path, stat, request_mask, query_flags);
@@ -272,17 +273,26 @@ EXPORT_SYMBOL(vfs_getattr);
  * @fd: The file descriptor referring to the file of interest
  * @stat: The result structure to fill in.
  *
- * This function is a wrapper around vfs_getattr().  The main difference is
- * that it uses a file descriptor to determine the file location.
+ * This function is a wrapper around vfs_getattr_nosec().  The main
+ * difference is that it uses a file descriptor to determine the file
+ * location, and passes that file to security_path_getattr(), so that
+ * LSMs can later authorize the operation with the rights available at
+ * open(2) time.
  *
  * 0 will be returned on success, and a -ve error code if unsuccessful.
  */
 int vfs_fstat(int fd, struct kstat *stat)
 {
+	int error;
 	CLASS(fd_raw, f)(fd);
+
 	if (fd_empty(f))
 		return -EBADF;
-	return vfs_getattr(&fd_file(f)->f_path, stat, STATX_BASIC_STATS, 0);
+	error = security_path_getattr(&fd_file(f)->f_path, fd_file(f));
+	if (error)
+		return error;
+	return vfs_getattr_nosec(&fd_file(f)->f_path, stat,
+				  STATX_BASIC_STATS, 0);
 }
 
 static int statx_lookup_flags(int flags)
@@ -298,9 +308,14 @@ static int statx_lookup_flags(int flags)
 }
 
 static int vfs_statx_path(const struct path *path, int flags, struct kstat *stat,
-			  u32 request_mask)
+			  u32 request_mask, struct file *file)
 {
-	int error = vfs_getattr(path, stat, request_mask, flags);
+	int error = security_path_getattr(path, file);
+
+	if (error)
+		return error;
+
+	error = vfs_getattr_nosec(path, stat, request_mask, flags);
 	if (error)
 		return error;
 
@@ -324,7 +339,8 @@ static int vfs_statx_fd(int fd, int flags, struct kstat *stat,
 	CLASS(fd_raw, f)(fd);
 	if (fd_empty(f))
 		return -EBADF;
-	return vfs_statx_path(&fd_file(f)->f_path, flags, stat, request_mask);
+	return vfs_statx_path(&fd_file(f)->f_path, flags, stat, request_mask,
+			      fd_file(f));
 }
 
 /**
@@ -335,10 +351,10 @@ static int vfs_statx_fd(int fd, int flags, struct kstat *stat,
  * @stat: The result structure to fill in.
  * @request_mask: STATX_xxx flags indicating what the caller wants
  *
- * This function is a wrapper around vfs_getattr().  The main difference is
- * that it uses a filename and base directory to determine the file location.
- * Additionally, the use of AT_SYMLINK_NOFOLLOW in flags will prevent a symlink
- * at the given name from being referenced.
+ * This function is a wrapper around vfs_statx_path().  The main difference
+ * with vfs_getattr() is that it uses a filename and base directory to
+ * determine the file location.  Additionally, the use of AT_SYMLINK_NOFOLLOW
+ * in flags will prevent a symlink at the given name from being referenced.
  *
  * 0 will be returned on success, and a -ve error code if unsuccessful.
  */
@@ -357,7 +373,7 @@ static int vfs_statx(int dfd, struct filename *filename, int flags,
 	error = filename_lookup(dfd, filename, lookup_flags, &path, NULL);
 	if (error)
 		return error;
-	error = vfs_statx_path(&path, flags, stat, request_mask);
+	error = vfs_statx_path(&path, flags, stat, request_mask, NULL);
 	path_put(&path);
 	if (retry_estale(error, lookup_flags)) {
 		lookup_flags |= LOOKUP_REVAL;
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index 96ae1b548e8d..0f7712f51644 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -153,7 +153,8 @@ LSM_HOOK(int, 0, inode_setattr, const struct mnt_idmap *idmap,
 	 const struct path *path, struct iattr *attr, struct file *file)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_setattr, const struct mnt_idmap *idmap,
 	 struct dentry *dentry, int ia_valid)
-LSM_HOOK(int, 0, inode_getattr, const struct path *path)
+LSM_HOOK(int, 0, path_getattr, const struct path *path,
+	 struct file *file)
 LSM_HOOK(int, 0, inode_xattr_skipcap, const char *name)
 LSM_HOOK(int, 0, inode_setxattr, const struct mnt_idmap *idmap,
 	 const struct path *path, const char *name, const void *value,
diff --git a/include/linux/security.h b/include/linux/security.h
index 67dc03d7cee2..1e9382fb16a9 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -435,7 +435,7 @@ int security_inode_setattr(const struct mnt_idmap *idmap,
 			   struct file *file);
 void security_inode_post_setattr(const struct mnt_idmap *idmap, struct dentry *dentry,
 				 int ia_valid);
-int security_inode_getattr(const struct path *path);
+int security_path_getattr(const struct path *path, struct file *file);
 int security_inode_setxattr(const struct mnt_idmap *idmap,
 			    const struct path *path, const char *name,
 			    const void *value, size_t size, int flags,
@@ -1016,7 +1016,8 @@ security_inode_post_setattr(const struct mnt_idmap *idmap, struct dentry *dentry
 			    int ia_valid)
 { }
 
-static inline int security_inode_getattr(const struct path *path)
+static inline int security_path_getattr(const struct path *path,
+					struct file *file)
 {
 	return 0;
 }
diff --git a/kernel/bpf/bpf_lsm.c b/kernel/bpf/bpf_lsm.c
index f58dce888ff4..293f849879e2 100644
--- a/kernel/bpf/bpf_lsm.c
+++ b/kernel/bpf/bpf_lsm.c
@@ -335,7 +335,7 @@ BTF_ID(func, bpf_lsm_file_receive)
 
 BTF_ID(func, bpf_lsm_inode_create)
 BTF_ID(func, bpf_lsm_inode_free_security)
-BTF_ID(func, bpf_lsm_inode_getattr)
+BTF_ID(func, bpf_lsm_path_getattr)
 BTF_ID(func, bpf_lsm_inode_getxattr)
 BTF_ID(func, bpf_lsm_inode_mknod)
 BTF_ID(func, bpf_lsm_inode_need_killpriv)
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 14adfb85fdb2..26ff684102f8 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -961,7 +961,7 @@ BPF_CALL_3(bpf_d_path, const struct path *, path, char *, buf, u32, sz)
 BTF_SET_START(btf_allowlist_d_path)
 #ifdef CONFIG_SECURITY
 BTF_ID(func, security_file_permission)
-BTF_ID(func, security_inode_getattr)
+BTF_ID(func, security_path_getattr)
 BTF_ID(func, security_file_open)
 #endif
 #ifdef CONFIG_SECURITY_PATH
diff --git a/security/apparmor/lsm.c b/security/apparmor/lsm.c
index c73681d820a0..11d802b246b4 100644
--- a/security/apparmor/lsm.c
+++ b/security/apparmor/lsm.c
@@ -456,7 +456,8 @@ static int apparmor_path_chown(const struct path *path, kuid_t uid, kgid_t gid)
 	return common_perm_cond(OP_CHOWN, path, AA_MAY_CHOWN);
 }
 
-static int apparmor_inode_getattr(const struct path *path)
+static int apparmor_path_getattr(const struct path *path,
+				 struct file *file)
 {
 	return common_perm_cond(OP_GETATTR, path, AA_MAY_GETATTR);
 }
@@ -1785,7 +1786,7 @@ static struct security_hook_list apparmor_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(path_chmod, apparmor_path_chmod),
 	LSM_HOOK_INIT(path_chown, apparmor_path_chown),
 	LSM_HOOK_INIT(path_truncate, apparmor_path_truncate),
-	LSM_HOOK_INIT(inode_getattr, apparmor_inode_getattr),
+	LSM_HOOK_INIT(path_getattr, apparmor_path_getattr),
 
 	LSM_HOOK_INIT(file_open, apparmor_file_open),
 	LSM_HOOK_INIT(file_receive, apparmor_file_receive),
diff --git a/security/security.c b/security/security.c
index 661b18f08f1b..d91268f88760 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1905,18 +1905,19 @@ void security_inode_post_setattr(const struct mnt_idmap *idmap, struct dentry *d
 }
 
 /**
- * security_inode_getattr() - Check if getting file attributes is allowed
- * @path: file
+ * security_path_getattr() - Check if getting file attributes is allowed
+ * @path: file (the VFS makes no guarantees with regard to @path->mnt)
+ * @file: file through which the attributes are retrieved, if any
  *
  * Check permission before obtaining file attributes.
  *
  * Return: Returns 0 if permission is granted.
  */
-int security_inode_getattr(const struct path *path)
+int security_path_getattr(const struct path *path, struct file *file)
 {
 	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_getattr, path);
+	return call_int_hook(path_getattr, path, file);
 }
 
 /**
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 16c8e852f841..e07b45fba392 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3347,7 +3347,8 @@ static int selinux_inode_setattr(const struct mnt_idmap *idmap,
 	return dentry_has_perm(cred, dentry, av);
 }
 
-static int selinux_inode_getattr(const struct path *path)
+static int selinux_path_getattr(const struct path *path,
+				struct file *file)
 {
 	struct task_security_struct *tsec;
 
@@ -7734,7 +7735,7 @@ static struct security_hook_list selinux_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(inode_follow_link, selinux_inode_follow_link),
 	LSM_HOOK_INIT(inode_permission, selinux_inode_permission),
 	LSM_HOOK_INIT(inode_setattr, selinux_inode_setattr),
-	LSM_HOOK_INIT(inode_getattr, selinux_inode_getattr),
+	LSM_HOOK_INIT(path_getattr, selinux_path_getattr),
 	LSM_HOOK_INIT(inode_xattr_skipcap, selinux_inode_xattr_skipcap),
 	LSM_HOOK_INIT(inode_setxattr, selinux_inode_setxattr),
 	LSM_HOOK_INIT(inode_post_setxattr, selinux_inode_post_setxattr),
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index e3445a4f6a45..1aa94331c980 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1295,12 +1295,14 @@ static int smack_inode_setattr(const struct mnt_idmap *idmap,
 }
 
 /**
- * smack_inode_getattr - Smack check for getting attributes
+ * smack_path_getattr - Smack check for getting attributes
  * @path: path to extract the info from
+ * @file: file through which the attributes are retrieved, if any
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
-static int smack_inode_getattr(const struct path *path)
+static int smack_path_getattr(const struct path *path,
+			      struct file *file)
 {
 	struct smk_audit_info ad;
 	struct inode *inode = d_backing_inode(path->dentry);
@@ -5197,7 +5199,7 @@ static struct security_hook_list smack_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(inode_rename, smack_inode_rename),
 	LSM_HOOK_INIT(inode_permission, smack_inode_permission),
 	LSM_HOOK_INIT(inode_setattr, smack_inode_setattr),
-	LSM_HOOK_INIT(inode_getattr, smack_inode_getattr),
+	LSM_HOOK_INIT(path_getattr, smack_path_getattr),
 	LSM_HOOK_INIT(inode_xattr_skipcap, smack_inode_xattr_skipcap),
 	LSM_HOOK_INIT(inode_setxattr, smack_inode_setxattr),
 	LSM_HOOK_INIT(inode_post_setxattr, smack_inode_post_setxattr),
diff --git a/security/tomoyo/tomoyo.c b/security/tomoyo/tomoyo.c
index c66e02ed8ee3..c67455e060f7 100644
--- a/security/tomoyo/tomoyo.c
+++ b/security/tomoyo/tomoyo.c
@@ -112,13 +112,14 @@ static int tomoyo_bprm_check_security(struct linux_binprm *bprm)
 }
 
 /**
- * tomoyo_inode_getattr - Target for security_inode_getattr().
+ * tomoyo_path_getattr - Target for security_path_getattr().
  *
  * @path: Pointer to "struct path".
  *
  * Returns 0 on success, negative value otherwise.
  */
-static int tomoyo_inode_getattr(const struct path *path)
+static int tomoyo_path_getattr(const struct path *path,
+			       struct file *file)
 {
 	return tomoyo_path_perm(TOMOYO_TYPE_GETATTR, path, NULL);
 }
@@ -570,7 +571,7 @@ static struct security_hook_list tomoyo_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(path_mknod, tomoyo_path_mknod),
 	LSM_HOOK_INIT(path_link, tomoyo_path_link),
 	LSM_HOOK_INIT(path_rename, tomoyo_path_rename),
-	LSM_HOOK_INIT(inode_getattr, tomoyo_inode_getattr),
+	LSM_HOOK_INIT(path_getattr, tomoyo_path_getattr),
 	LSM_HOOK_INIT(file_ioctl, tomoyo_file_ioctl),
 	LSM_HOOK_INIT(file_ioctl_compat, tomoyo_file_ioctl),
 	LSM_HOOK_INIT(path_chmod, tomoyo_path_chmod),
diff --git a/tools/testing/selftests/bpf/prog_tests/d_path.c b/tools/testing/selftests/bpf/prog_tests/d_path.c
index 1a2a2f1abf03..01a03d65b1cf 100644
--- a/tools/testing/selftests/bpf/prog_tests/d_path.c
+++ b/tools/testing/selftests/bpf/prog_tests/d_path.c
@@ -158,9 +158,7 @@ static void test_d_path_basic(void)
 	if (err < 0)
 		goto cleanup;
 
-	if (CHECK(!bss->called_stat,
-		  "stat",
-		  "trampoline for security_inode_getattr was not called\n"))
+	if (!ASSERT_TRUE(bss->called_stat, "stat"))
 		goto cleanup;
 
 	if (CHECK(!bss->called_close,
diff --git a/tools/testing/selftests/bpf/progs/test_d_path.c b/tools/testing/selftests/bpf/progs/test_d_path.c
index 561b2f861808..b97c203e3992 100644
--- a/tools/testing/selftests/bpf/progs/test_d_path.c
+++ b/tools/testing/selftests/bpf/progs/test_d_path.c
@@ -19,7 +19,7 @@ int called_stat = 0;
 int called_close = 0;
 int path_match_fallocate = 0;
 
-SEC("fentry/security_inode_getattr")
+SEC("fentry/security_path_getattr")
 int BPF_PROG(prog_stat, struct path *path, struct kstat *stat,
 	     __u32 request_mask, unsigned int query_flags)
 {
diff --git a/tools/testing/selftests/bpf/progs/test_d_path_check_rdonly_mem.c b/tools/testing/selftests/bpf/progs/test_d_path_check_rdonly_mem.c
index 27c27cff6a3a..5e0e3d4828d7 100644
--- a/tools/testing/selftests/bpf/progs/test_d_path_check_rdonly_mem.c
+++ b/tools/testing/selftests/bpf/progs/test_d_path_check_rdonly_mem.c
@@ -7,7 +7,7 @@
 
 extern const int bpf_prog_active __ksym;
 
-SEC("fentry/security_inode_getattr")
+SEC("fentry/security_path_getattr")
 int BPF_PROG(d_path_check_rdonly_mem, struct path *path, struct kstat *stat,
 	     __u32 request_mask, unsigned int query_flags)
 {
diff --git a/tools/testing/selftests/bpf/progs/test_d_path_check_types.c b/tools/testing/selftests/bpf/progs/test_d_path_check_types.c
index 7e02b7361307..fba3d527b4df 100644
--- a/tools/testing/selftests/bpf/progs/test_d_path_check_types.c
+++ b/tools/testing/selftests/bpf/progs/test_d_path_check_types.c
@@ -11,7 +11,7 @@ struct {
 	__uint(max_entries, 1 << 12);
 } ringbuf SEC(".maps");
 
-SEC("fentry/security_inode_getattr")
+SEC("fentry/security_path_getattr")
 int BPF_PROG(d_path_check_rdonly_mem, struct path *path, struct kstat *stat,
 	     __u32 request_mask, unsigned int query_flags)
 {
diff --git a/tools/testing/selftests/bpf/progs/verifier_vfs_accept.c b/tools/testing/selftests/bpf/progs/verifier_vfs_accept.c
index 25f37a3dd7cf..81142d217655 100644
--- a/tools/testing/selftests/bpf/progs/verifier_vfs_accept.c
+++ b/tools/testing/selftests/bpf/progs/verifier_vfs_accept.c
@@ -71,7 +71,7 @@ int BPF_PROG(get_task_exe_file_and_put_kfunc_from_argument,
 	return 0;
 }
 
-SEC("lsm.s/inode_getattr")
+SEC("lsm.s/path_getattr")
 __success
 int BPF_PROG(path_d_path_from_path_argument, struct path *path)
 {
-- 
2.18.0.huawei.25

