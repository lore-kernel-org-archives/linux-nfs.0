Received: from canpmsgout10.his.huawei.com (canpmsgout10.his.huawei.com [113.46.200.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 229645349A3;
	Thu, 15 Oct 2026 12:20:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.225
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792066842; cv=none; b=W0ydN0ldHaGrl5E0ixciV80Usr6mHWPkyKZLJQx0iDTmydUpW2s5C4p0ep3Pvwtn4TLtKTLUrShNK0eH25PZ+bIA6xDce/E2TwPHxBlCuryRjO0rrIeSndEGCZrPrlEh6VGGAlKQ0TpDambVUYlOAz7Ot3zoXKG8kFWyQmZscgc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792066842; c=relaxed/simple;
	bh=V5//zhxOtTu2tnYAVZ9J6ri0GFeFUwZCtW4VGhrlabc=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=QmJ1CGdm0uAnSqt1dba5H9/8FBfHX0GdsDWzH6+QZA3y7qgX91qKR7S4+7hUEiJ8nBclGVm+50+PJ7TwRg9OquqCVLzdI9NoV1SfiyRXFUwJHu3pxrz6LzcKWYVhYKkYiOChipofjQhMY8PbMwjWWiKTPSys/Qi/0yaDbfd2d6k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=bOGCORKq; arc=none smtp.client-ip=113.46.200.225
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="bOGCORKq"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=x3/KOHgkqzGBrZ0s7GqkOqGvtb2LAxUbFzxklnh/i2s=;
	b=bOGCORKqKTUe4LUEiThFmmEAS+PxnWtExdf8xO5/T1CN/GObQps61B/Od1f8tWcMKnyaXAkvW
	mM9LLks11liQ/YytHX85CJSDgyjKAx4lnjybm6vZzrnEv3ZltRHa6vgbcHywTYYJRlwPimcwlJq
	U3RSwak7i8RPDv3b7f6UjJw=
Received: from mail.maildlp.com (unknown [172.19.163.200])
	by canpmsgout10.his.huawei.com (SkyGuard) with ESMTPS id 4j56KS2mpjz1K96s;
	Thu, 15 Oct 2026 20:08:12 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 848E940563;
	Thu, 15 Oct 2026 20:20:31 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 15 Oct 2026 20:20:26 +0800
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
Subject: [PATCH v2 -next 09/18] landlock: Add READ_METADATA and WRITE_METADATA access rights
Date: Thu, 15 Oct 2026 20:54:15 +0800
Message-ID: <20261015125425.3246251-10-caixinchen1@huawei.com>
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

Add two new filesystem access rights to control file metadata access:

- LANDLOCK_ACCESS_FS_READ_METADATA: Read file or directory metadata
  (e.g. inode attributes, extended attributes and POSIX ACLs) through
  stat(2), fstat(2), lstat(2), newfstatat(2), getxattr(2) and
  friends, listxattr(2) and friends, and the POSIX ACL read
  operations.
- LANDLOCK_ACCESS_FS_WRITE_METADATA: Change file or directory
  metadata through chmod(2) and friends, chown(2) and friends,
  utimensat(2) and friends, setxattr(2) and friends, removexattr(2)
  and friends, and the POSIX ACL set and remove operations.

This follows the coarse-grained grouping approach discussed in the
mailing list [1], where file metadata operations are grouped by
security relevance rather than by individual syscall.

Implement the two rights by hooking the inode_getattr,
inode_file_getattr, inode_setattr, inode_file_setattr,
inode_setxattr, inode_getxattr, inode_listxattr, inode_removexattr,
inode_set_acl, inode_get_acl and inode_remove_acl LSM hooks, which
now receive a struct path thanks to the preceding VFS and LSM
refactoring.  The following system calls are now controlled:

- stat(2), fstat(2), lstat(2), newfstatat(2), getxattr(2) and
  friends, listxattr(2) and friends, POSIX ACL reads, and the
  chattr(1)/xfs_io style reads: ioctl(FS_IOC_GETFLAGS),
  ioctl(FS_IOC_FSGETXATTR) and file_getattr(2) via inode_getattr,
  inode_getxattr, inode_listxattr, inode_get_acl and
  inode_file_getattr (READ_METADATA)
- chmod(2), fchmod(2), fchmodat(2), fchmodat2(2), chown(2), fchown(2),
  lchown(2), fchownat(2), chgrp(2), utimensat(2), futimens(2),
  utime(2), setxattr(2) and friends, removexattr(2) and friends,
  POSIX ACL set and remove, and the chattr(1)/xfs_io style writes:
  ioctl(FS_IOC_SETFLAGS), ioctl(FS_IOC_FSSETXATTR) and
  file_setattr(2) via inode_setattr, inode_file_setattr,
  inode_setxattr, inode_removexattr, inode_set_acl and
  inode_remove_acl (WRITE_METADATA)

Both new rights are added to ACCESS_FILE as they apply to both files
and directories.

hook_inode_setattr only restricts explicit metadata changes, i.e. it
checks WRITE_METADATA only when the ia_valid mask contains
ATTR_MODE, ATTR_UID, ATTR_GID, ATTR_TIMES_SET or ATTR_TOUCH.
Metadata changes that the kernel performs implicitly, such as
timestamp updates on write(2) or size changes on truncate(2), are
therefore not restricted, and neither are chmod(2)/chown(2) calls
that do not change any attribute (e.g. chown(2) with -1/-1, which is
a no-op that never reaches the hook), matching the behavior of the
SELinux inode_setattr hook.

Stacking filesystems forward fileattr operations to underlying inodes
without calling the LSM hooks again (see the preceding patch), so a
fileattr operation on an overlayfs file is checked once on the
user-facing merged path and is not spuriously denied because of the
kernel-side creator credentials used for the forward.

Kernel-internal accesses performed with override_creds() (e.g.
overlayfs and cachefiles) are not affected because Landlock domains
are attached to credentials, and kernel threads without a Landlock
domain (e.g. nfsd and ksmbd) are not restricted either.

Remove stat(2), chmod(2), chown(2), setxattr(2) and utime(2) from the
list of file-related actions that cannot be restricted yet, and add
the names of the new rights to _LANDLOCK_ACCESS_FS_NAMES in
include/linux/landlock.h, which is shared by audit records and trace
events, so that denied accesses can be reported with a human-readable
name and the static assertion on fs_access_strings in
security/landlock/audit.c stays valid.

Increment the Landlock ABI version from 12 to 13, and update the ABI
version check in tools/testing/selftests/landlock/base_test.c
accordingly.

[1]
https://lore.kernel.org/all/abc960a1-e66e-792e-6869-cfd201c29dbe@digikod.net/

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 include/linux/landlock.h      |   4 +-
 include/uapi/linux/landlock.h |  25 ++++++-
 security/landlock/fs.c        | 126 ++++++++++++++++++++++++++++++++++
 security/landlock/limits.h    |   2 +-
 security/landlock/syscalls.c  |   2 +-
 5 files changed, 153 insertions(+), 6 deletions(-)

diff --git a/include/linux/landlock.h b/include/linux/landlock.h
index 0ee4880988ba..ee1234fbc9f0 100644
--- a/include/linux/landlock.h
+++ b/include/linux/landlock.h
@@ -41,7 +41,9 @@
 	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_REFER, "refer"), \
 	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_TRUNCATE, "truncate"), \
 	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_IOCTL_DEV, "ioctl_dev"), \
-	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_RESOLVE_UNIX, "resolve_unix")
+	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_RESOLVE_UNIX, "resolve_unix"), \
+	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_READ_METADATA, "read_metadata"), \
+	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_WRITE_METADATA, "write_metadata")
 
 #define _LANDLOCK_ACCESS_NET_NAMES \
 	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_NET_BIND_TCP, "bind_tcp"), \
diff --git a/include/uapi/linux/landlock.h b/include/uapi/linux/landlock.h
index 24510e5d8479..36dfb499e48e 100644
--- a/include/uapi/linux/landlock.h
+++ b/include/uapi/linux/landlock.h
@@ -429,6 +429,25 @@ struct landlock_capability_attr {
  *
  *   The rationale for this design is described in
  *   :ref:`Documentation/security/landlock.rst <scoped-flags-interaction>`.
+ * - %LANDLOCK_ACCESS_FS_READ_METADATA: Read file or directory metadata (e.g.
+ *   inode attributes, extended attributes, and POSIX ACLs) through
+ *   :manpage:`stat(2)`, :manpage:`fstat(2)`, :manpage:`lstat(2)`,
+ *   :manpage:`newfstatat(2)`, :manpage:`getxattr(2)`, and
+ *   :manpage:`listxattr(2)`.
+ *
+ *   This access right is available since the thirteenth version of the
+ *   Landlock ABI.
+ * - %LANDLOCK_ACCESS_FS_WRITE_METADATA: Change file or directory metadata
+ *   (e.g. inode attributes, extended attributes, and POSIX ACLs) through
+ *   :manpage:`chmod(2)`, :manpage:`chown(2)`, :manpage:`utimensat(2)`,
+ *   :manpage:`setxattr(2)`, and :manpage:`removexattr(2)`, as well as related
+ *   system calls.  Implicit metadata changes performed by the kernel (e.g.
+ *   timestamp updates with :manpage:`write(2)`, or set-user-ID and
+ *   set-group-ID bit clearing with :manpage:`write(2)` or
+ *   :manpage:`truncate(2)`) are not restricted by this access right.
+ *
+ *   This access right is available since the thirteenth version of the
+ *   Landlock ABI.
  *
  * Whether an opened file can be truncated with :manpage:`ftruncate(2)` or used
  * with `ioctl(2)` is determined during :manpage:`open(2)`, in the same way as
@@ -493,9 +512,7 @@ struct landlock_capability_attr {
  *
  *   It is currently not possible to restrict some file-related actions
  *   accessible through these syscall families: :manpage:`chdir(2)`,
- *   :manpage:`stat(2)`, :manpage:`flock(2)`, :manpage:`chmod(2)`,
- *   :manpage:`chown(2)`, :manpage:`setxattr(2)`, :manpage:`utime(2)`,
- *   :manpage:`fcntl(2)`, :manpage:`access(2)`.
+ *   :manpage:`flock(2)`, :manpage:`fcntl(2)`, :manpage:`access(2)`.
  *   Future Landlock evolutions will enable to restrict them.
  */
 /* clang-format off */
@@ -516,6 +533,8 @@ struct landlock_capability_attr {
 #define LANDLOCK_ACCESS_FS_TRUNCATE			(1ULL << 14)
 #define LANDLOCK_ACCESS_FS_IOCTL_DEV			(1ULL << 15)
 #define LANDLOCK_ACCESS_FS_RESOLVE_UNIX			(1ULL << 16)
+#define LANDLOCK_ACCESS_FS_READ_METADATA		(1ULL << 17)
+#define LANDLOCK_ACCESS_FS_WRITE_METADATA		(1ULL << 18)
 /* clang-format on */
 
 /**
diff --git a/security/landlock/fs.c b/security/landlock/fs.c
index a8fa8f77e775..f56277c67a24 100644
--- a/security/landlock/fs.c
+++ b/security/landlock/fs.c
@@ -318,6 +318,8 @@ static struct landlock_object *get_inode_object(struct inode *const inode)
 	LANDLOCK_ACCESS_FS_EXECUTE | \
 	LANDLOCK_ACCESS_FS_WRITE_FILE | \
 	LANDLOCK_ACCESS_FS_READ_FILE | \
+	LANDLOCK_ACCESS_FS_READ_METADATA | \
+	LANDLOCK_ACCESS_FS_WRITE_METADATA | \
 	LANDLOCK_ACCESS_FS_TRUNCATE | \
 	LANDLOCK_ACCESS_FS_IOCTL_DEV | \
 	LANDLOCK_ACCESS_FS_RESOLVE_UNIX)
@@ -1676,6 +1678,119 @@ static int hook_path_truncate(const struct path *const path)
 	return current_check_access_path(path, LANDLOCK_ACCESS_FS_TRUNCATE);
 }
 
+static int hook_inode_getattr(const struct path *const path)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_READ_METADATA);
+}
+
+static int hook_inode_file_getattr(const struct path *const path,
+				   struct file_kattr *const fa)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_READ_METADATA);
+}
+
+static int hook_inode_setattr(const struct path *const path,
+			      struct iattr *const attr)
+{
+	unsigned int ia_valid = attr->ia_valid;
+
+	/*
+	 * Only explicit metadata changes are checked: implicit
+	 * timestamp updates never go through notify_change(), and size
+	 * changes (ATTR_SIZE) are governed by the truncate hooks
+	 * instead.  See the "File metadata" section in the user space
+	 * documentation for the full semantics.
+	 *
+	 * Clearing the setuid and setgid bits on write(2) or
+	 * truncate(2) is also an implicit change: callers request it
+	 * with ATTR_KILL_S[UG]ID, and do_notify_change() then adds a
+	 * synthesized ATTR_MODE (with these bits removed) before
+	 * calling this hook.  As do_notify_change() makes it a bug for
+	 * callers to pass ATTR_MODE together with a kill flag, an
+	 * ATTR_MODE seen along with ATTR_KILL_S[UG]ID is always
+	 * kernel-synthesized and must not be checked.  An explicit
+	 * chmod(2) never sets a kill flag, and an explicit chown(2) on
+	 * a privileged file is still checked thanks to ATTR_UID and
+	 * ATTR_GID.
+	 */
+	if (ia_valid & (ATTR_KILL_SUID | ATTR_KILL_SGID))
+		ia_valid &= ~ATTR_MODE;
+
+	if (!(ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID |
+			  ATTR_TIMES_SET | ATTR_TOUCH)))
+		return 0;
+
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
+static int hook_inode_file_setattr(const struct path *const path,
+				   struct file_kattr *const fa)
+{
+	/*
+	 * The chattr(2) style flags (e.g. FS_IMMUTABLE_FL) and fsxattr
+	 * fields are metadata: writing them requires WRITE_METADATA.  The
+	 * user-facing path is checked here; stacking filesystems skip this
+	 * hook on their internal forwards because they were already
+	 * checked on the user-facing path.
+	 */
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
+static int hook_inode_setxattr(const struct path *const path,
+			       const char *const name,
+			       const void *const value, const size_t size,
+			       const int flags)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
+static int hook_inode_getxattr(const struct path *const path,
+			       const char *const name)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_READ_METADATA);
+}
+
+static int hook_inode_listxattr(const struct path *const path)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_READ_METADATA);
+}
+
+static int hook_inode_removexattr(const struct path *const path,
+				  const char *const name)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
+static int hook_inode_set_acl(const struct path *const path,
+			      const char *const acl_name,
+			      struct posix_acl *const kacl)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
+static int hook_inode_get_acl(const struct path *const path,
+			      const char *const acl_name)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_READ_METADATA);
+}
+
+static int hook_inode_remove_acl(const struct path *const path,
+				 const char *const acl_name)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
 /**
  * unmask_scoped_access - Remove access right bits in @masks in all layers
  *                        where @client and @server have the same domain
@@ -2100,6 +2215,17 @@ static struct security_hook_list landlock_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(path_unlink, hook_path_unlink),
 	LSM_HOOK_INIT(path_rmdir, hook_path_rmdir),
 	LSM_HOOK_INIT(path_truncate, hook_path_truncate),
+	LSM_HOOK_INIT(inode_getattr, hook_inode_getattr),
+	LSM_HOOK_INIT(inode_file_getattr, hook_inode_file_getattr),
+	LSM_HOOK_INIT(inode_setattr, hook_inode_setattr),
+	LSM_HOOK_INIT(inode_file_setattr, hook_inode_file_setattr),
+	LSM_HOOK_INIT(inode_setxattr, hook_inode_setxattr),
+	LSM_HOOK_INIT(inode_getxattr, hook_inode_getxattr),
+	LSM_HOOK_INIT(inode_listxattr, hook_inode_listxattr),
+	LSM_HOOK_INIT(inode_removexattr, hook_inode_removexattr),
+	LSM_HOOK_INIT(inode_set_acl, hook_inode_set_acl),
+	LSM_HOOK_INIT(inode_get_acl, hook_inode_get_acl),
+	LSM_HOOK_INIT(inode_remove_acl, hook_inode_remove_acl),
 	LSM_HOOK_INIT(unix_find, hook_unix_find),
 
 	LSM_HOOK_INIT(file_alloc_security, hook_file_alloc_security),
diff --git a/security/landlock/limits.h b/security/landlock/limits.h
index ddd300e10689..ed606ee3102f 100644
--- a/security/landlock/limits.h
+++ b/security/landlock/limits.h
@@ -21,7 +21,7 @@
 #define LANDLOCK_MAX_NUM_LAYERS		16
 #define LANDLOCK_MAX_NUM_RULES		U32_MAX
 
-#define LANDLOCK_LAST_ACCESS_FS		LANDLOCK_ACCESS_FS_RESOLVE_UNIX
+#define LANDLOCK_LAST_ACCESS_FS		LANDLOCK_ACCESS_FS_WRITE_METADATA
 #define LANDLOCK_MASK_ACCESS_FS		((LANDLOCK_LAST_ACCESS_FS << 1) - 1)
 #define LANDLOCK_NUM_ACCESS_FS		__const_hweight64(LANDLOCK_MASK_ACCESS_FS)
 
diff --git a/security/landlock/syscalls.c b/security/landlock/syscalls.c
index fb5af318b69b..11d3a2abcec1 100644
--- a/security/landlock/syscalls.c
+++ b/security/landlock/syscalls.c
@@ -191,7 +191,7 @@ static const struct file_operations ruleset_fops = {
  * If the change involves a fix that requires userspace awareness, also update
  * the errata documentation in Documentation/userspace-api/landlock.rst .
  */
-const int landlock_abi_version = 12;
+const int landlock_abi_version = 13;
 
 /**
  * sys_landlock_create_ruleset - Create a new ruleset
-- 
2.18.0.huawei.25

