Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.223
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101162;
	b=UNJH/b8GF1Ib+8kl5EoMWmHsixfFoz+x77/n6mvWEH/gUIQW3XkGBzli6fd/iFtgVX79
	 aoYhb8MLIst0StjrYEx3Y+bmh99AHYCwoVOI6foszYQ06WHDQRMWSMS9Zpw770TaHXZiN
	 DDdD1mkz3JUvwGphNUL2idtavkbU3bUt7mlqkl6xKtRuHUTnkKRkg8MutmEN28DSrQ1FG
	 WaWmALWOFh/9slkUUO26wj3l+Wv/EwQIM0biAEqkfQK/PMmo9hUWObOFDcoI3vL1R0soI
	 DNC20nvM7pOICCAfiirukk7TmIWPyqt2l9gESZnKYpcD9UaGSpvKAtu8lwuswEkmdSw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101162;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:X-Originating-IP:X-ClientProxiedBy;
	bh=i8v2NhoJ9ynMPpbzLlLQrAS4ueIrDfKhJGXA39YJhw8=;
	b=kY0/SnXqdPjaxVlJfEsKQZyLjXVBu5msjAj5+5n7w64hP404Ci2w58596oqCtL1CslhQ
	 ZyJYISjPvl310Ey/bMMBQWLeLPeoGkD/MXAGTjTblo9SpbY/02Vw/DECESG/wWplYPdjp
	 o0k0PYQT+QwozS7TRhPn/ldQjD7nI90IrFhJfkKKebQKllYlY++Yd3YnOa2AHRa5xpjRV
	 Th66BEQvn3Yc2tugVAvhqd3QcNIP2URySFjY7h1tRNbCETHh424Jz4y2d8yrySDwjD80k
	 ioXUHpBzk22m5yH0YPED2HuQpbUPOlx9xYuYAan/w6Rg19oWAjdbJ+P4zy0n/uh40Tw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=fw6xy346;
	arc=none smtp.remote-ip=113.46.200.223
Received: from canpmsgout08.his.huawei.com (canpmsgout08.his.huawei.com [113.46.200.223])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 43767606A7D2;
	Tue, 27 Oct 2026 11:39:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 43767606A7D2
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=fw6xy346
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=i8v2NhoJ9ynMPpbzLlLQrAS4ueIrDfKhJGXA39YJhw8=;
	b=fw6xy346xV+DYzzfACpCaXdKx2P86yDZNytRj67Jclvnru9+9sgM5X9W4Y8eQfmrPDXzgfmct
	/hpEgLDYbVfsG4NSY/NW/Wxa1s8+uA683g4PkJoMsJApxjLKbyN2SdcqF6PvGWYL7GCzxzjMCHx
	2l1ewEQ1gkQQCd1I40bX97w=
Received: from mail.maildlp.com (unknown [172.19.163.127])
	by canpmsgout08.his.huawei.com (SkyGuard) with ESMTPS id 4jDT6S48FxzmV7W;
	Tue, 27 Oct 2026 19:39:12 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 50E9140561;
	Tue, 27 Oct 2026 19:39:18 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Tue, 27 Oct 2026 19:39:12 +0800
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
Subject: [PATCH v3 -next 15/18] landlock: Add READ_METADATA and WRITE_METADATA access rights
Date: Tue, 27 Oct 2026 20:11:48 +0800
Message-ID: <20261027121151.1887650-16-caixinchen1@huawei.com>
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

Implement the two rights by hooking the path_getattr,
path_file_getattr, path_setattr, path_file_setattr, path_setxattr,
path_getxattr, path_listxattr, path_removexattr, path_set_acl,
path_get_acl and path_remove_acl LSM hooks, which now receive a
struct path thanks to the preceding VFS and LSM refactoring.  All of
them receive the struct file through which the operation is
requested, when there is one.  The following system
calls are now controlled:

- stat(2), fstat(2), lstat(2), newfstatat(2), getxattr(2) and
  friends, listxattr(2) and friends, POSIX ACL reads, and the
  chattr(1)/xfs_io style reads: ioctl(FS_IOC_GETFLAGS),
  ioctl(FS_IOC_FSGETXATTR) and file_getattr(2) via path_getattr,
  path_getxattr, path_listxattr, path_get_acl and path_file_getattr
  (READ_METADATA)
- chmod(2), fchmod(2), fchmodat(2), fchmodat2(2), chown(2), fchown(2),
  lchown(2), fchownat(2), chgrp(2), utimensat(2) and friends,
  utime(2), setxattr(2) and friends, removexattr(2) and friends,
  POSIX ACL set and remove, and the chattr(1)/xfs_io style writes:
  ioctl(FS_IOC_SETFLAGS), ioctl(FS_IOC_FSSETXATTR) and
  file_setattr(2) via path_setattr, path_file_setattr, path_setxattr,
  path_removexattr, path_set_acl and path_remove_acl
  (WRITE_METADATA)

For operations on already opened files (e.g. fchmod(2), fchown(2),
utimensat(2) with an empty path, fgetxattr(2), fstat(2), or the
FS_IOC_* ioctls), it is the access rights at the time of open(2)
which decide whether the operation is permitted, not the rights of
the current thread, as for LANDLOCK_ACCESS_FS_TRUNCATE.  To that
end, READ_METADATA and WRITE_METADATA are included in
_LANDLOCK_ACCESS_FS_OPTIONAL, deny_masks_t is widened from u8 to u16
to keep tracking one nibble per optional access right for the audit
logs, and both rights are recorded in the allowed_access of opened
files in hook_file_open().  The metadata hooks consume this record
when they are called with a file, and fall back to the current
domain's rights for path-based operations.  The hook_file_truncate()
check is factored out into the shared check_access_file() helper for
that purpose.

As for truncate, file descriptors therefore carry the rights of the
process which opened them: a file descriptor opened before sandboxing
keeps working, whereas a file descriptor opened with a restricted set
of rights keeps denying metadata accesses even when passed to another
process.  This also closes the metadata leak through file descriptors
opened without READ_METADATA, e.g. via fstat(2) or the
FS_IOC_GETFLAGS ioctl.  O_PATH file descriptors are an exception:
they are not opened through the open permission checks (cf.
do_dentry_open()), so they do not carry access rights stashed at open
time; metadata accesses through them are checked against the current
domain, like path-based accesses.

hook_path_setattr only restricts explicit metadata changes, i.e. it
checks WRITE_METADATA only when the ia_valid mask contains
ATTR_MODE, ATTR_UID, ATTR_GID, ATTR_TIMES_SET or ATTR_TOUCH.
Metadata changes that the kernel performs implicitly, such as
timestamp updates on write(2) or size changes on truncate(2), are
therefore not restricted.  The setuid/setgid bit clearing that the
kernel performs after write(2) or truncate(2) comes through
notify_change() with ATTR_FORCE set, and the ATTR_MODE that
do_notify_change() synthesizes from ATTR_KILL_S[UG]ID is therefore
ignored; an explicit chown(2), including chown(2) with (-1, -1) on
a privileged file, does not set ATTR_FORCE and is still checked,
matching the behavior of the SELinux path_setattr hook.  A chown(2)
that changes nothing (e.g. with (-1, -1) on a file without privilege
bits) sets no checkable attribute and is not restricted either.

Stacking filesystems forward fileattr operations to underlying inodes
without calling the LSM hooks again (cf. the patch passing struct path
and struct file to the inode fileattr hooks), so a fileattr operation
on an overlayfs file is checked once on the user-facing merged path
and is not spuriously denied because of the kernel-side creator
credentials used for the forward.

Kernel-internal accesses performed with override_creds() (e.g.
overlayfs and cachefiles) are not affected because Landlock domains
are attached to credentials, and kernel threads without a Landlock
domain (e.g. nfsd and ksmbd) are not restricted either.

Both new rights are added to ACCESS_FILE as they apply to both files
and directories.  Add the names of the new rights to
_LANDLOCK_ACCESS_FS_NAMES in include/linux/landlock.h, which is
shared by audit records and trace events, so that denied accesses can
be reported with a human-readable name and the static assertion on
fs_access_strings in security/landlock/audit.c stays valid.

Remove stat(2), chmod(2), chown(2), setxattr(2) and utime(2) from the
list of file-related actions that cannot be restricted yet, and
increment the Landlock ABI version from 12 to 13.

[1]
https://lore.kernel.org/all/abc960a1-e66e-792e-6869-cfd201c29dbe@digikod.net/

Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 include/linux/landlock.h      |   4 +-
 include/uapi/linux/landlock.h |  25 +++-
 security/landlock/access.h    |  13 +-
 security/landlock/fs.c        | 232 ++++++++++++++++++++++++++++++----
 security/landlock/limits.h    |   2 +-
 security/landlock/syscalls.c  |   2 +-
 6 files changed, 241 insertions(+), 37 deletions(-)

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
diff --git a/security/landlock/access.h b/security/landlock/access.h
index f9eaa2f53686..a719760cdeff 100644
--- a/security/landlock/access.h
+++ b/security/landlock/access.h
@@ -31,7 +31,9 @@
 /* clang-format off */
 #define _LANDLOCK_ACCESS_FS_OPTIONAL ( \
 	LANDLOCK_ACCESS_FS_TRUNCATE | \
-	LANDLOCK_ACCESS_FS_IOCTL_DEV)
+	LANDLOCK_ACCESS_FS_IOCTL_DEV | \
+	LANDLOCK_ACCESS_FS_READ_METADATA | \
+	LANDLOCK_ACCESS_FS_WRITE_METADATA)
 /* clang-format on */
 
 typedef u32 access_mask_t;
@@ -156,11 +158,12 @@ struct layer_masks {
  * required by update_request().
  *
  * Each nibble represents the layer index of the newest layer which denied a
- * certain access right.  For file system access rights, the upper four bits are
- * the index of the layer which denies LANDLOCK_ACCESS_FS_IOCTL_DEV and the
- * lower nibble represents LANDLOCK_ACCESS_FS_TRUNCATE.
+ * certain access right.  For file system access rights, the nibbles from the
+ * least to the most significant one represent the layers which deny
+ * LANDLOCK_ACCESS_FS_TRUNCATE, LANDLOCK_ACCESS_FS_IOCTL_DEV,
+ * LANDLOCK_ACCESS_FS_READ_METADATA and LANDLOCK_ACCESS_FS_WRITE_METADATA.
  */
-typedef u8 deny_masks_t;
+typedef u16 deny_masks_t;
 
 /*
  * Makes sure all optional access rights can be tied to a layer index (cf.
diff --git a/security/landlock/fs.c b/security/landlock/fs.c
index 2ab67bcad198..73c6353ecbf8 100644
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
@@ -1676,6 +1678,192 @@ static int hook_path_truncate(const struct path *const path)
 	return current_check_access_path(path, LANDLOCK_ACCESS_FS_TRUNCATE);
 }
 
+static int check_access_file(const struct file *const file,
+			     const access_mask_t access)
+{
+	/*
+	 * O_PATH file descriptors do not go through the open permission
+	 * checks (cf. do_dentry_open()) and therefore do not carry the
+	 * access rights stashed at open time: they are checked against the
+	 * current domain, like path-based accesses.
+	 */
+	if (unlikely(file->f_mode & FMODE_PATH))
+		return current_check_access_path(&file->f_path, access);
+
+	/*
+	 * Allows accesses if the requested access right was available at the
+	 * time of opening the file, to get a consistent access check as for
+	 * read, write and execute operations.
+	 *
+	 * Note: For checks done based on the file's Landlock allowed access,
+	 * we enforce them independently of whether the current thread is in
+	 * a Landlock domain, so that open files passed between independent
+	 * processes retain their behaviour.
+	 */
+	if (landlock_file(file)->allowed_access & access)
+		return 0;
+
+	landlock_log_denial(landlock_cred(file->f_cred), &(struct landlock_request) {
+		.type = LANDLOCK_REQUEST_FS_ACCESS,
+		.audit = {
+			.type = LSM_AUDIT_DATA_FILE,
+			.u.file = file,
+		},
+		.all_existing_optional_access = _LANDLOCK_ACCESS_FS_OPTIONAL,
+		.access = access,
+#ifdef CONFIG_SECURITY_LANDLOCK_LOG
+		.deny_masks = landlock_file(file)->deny_masks,
+		.quiet_optional_accesses = landlock_file(file)->quiet_optional_accesses,
+#endif /* CONFIG_SECURITY_LANDLOCK_LOG */
+	});
+	return -EACCES;
+}
+
+static int check_access_path_or_file(const struct path *const path,
+				     const struct file *const file,
+				     const access_mask_t access)
+{
+	if (file)
+		return check_access_file(file, access);
+
+	return current_check_access_path(path, access);
+}
+
+static int hook_path_getattr(const struct path *const path,
+			     struct file *const file)
+{
+	return check_access_path_or_file(path, file,
+					 LANDLOCK_ACCESS_FS_READ_METADATA);
+}
+
+static int hook_path_file_getattr(const struct path *const path,
+				  struct file_kattr *const fa,
+				  struct file *const file)
+{
+	return check_access_path_or_file(path, file,
+					 LANDLOCK_ACCESS_FS_READ_METADATA);
+}
+
+static int hook_path_setattr(const struct mnt_idmap *const idmap,
+			     const struct path *const path,
+			     struct iattr *const attr,
+			     struct file *const file)
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
+	 * The setuid/setgid bit clearing that the kernel performs
+	 * after write(2) or truncate(2) is an implicit change as
+	 * well: it comes through __remove_privs() and do_truncate()
+	 * with ATTR_FORCE set, and do_notify_change() then adds a
+	 * synthesized ATTR_MODE (with these bits removed) before
+	 * calling this hook.  As do_notify_change() makes it a bug for
+	 * callers to pass ATTR_MODE together with a kill flag, an
+	 * ATTR_MODE seen along with ATTR_FORCE is always
+	 * kernel-synthesized and must not be checked.  An explicit
+	 * chown(2) does not set ATTR_FORCE, so the same clearing
+	 * requested through chown(2), including chown(2) with
+	 * (-1, -1) on a privileged file, is still checked through the
+	 * synthesized ATTR_MODE, matching the SELinux behavior.  A
+	 * chown(2) that changes nothing (e.g. with (-1, -1) on a file
+	 * without privilege bits) sets neither a changed attribute
+	 * nor a synthesized ATTR_MODE, and is not checked.
+	 */
+	if (ia_valid & ATTR_FORCE)
+		ia_valid &= ~(ATTR_KILL_SUID | ATTR_KILL_SGID | ATTR_MODE);
+
+	if (!(ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID |
+			  ATTR_TIMES_SET | ATTR_TOUCH)))
+		return 0;
+
+	return check_access_path_or_file(path, file,
+					 LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
+static int hook_path_file_setattr(const struct path *const path,
+				  struct file_kattr *const fa,
+				  struct file *const file)
+{
+	/*
+	 * The chattr(2) style flags (e.g. FS_IMMUTABLE_FL) and fsxattr
+	 * fields are metadata: writing them requires WRITE_METADATA.  The
+	 * user-facing path is checked here; stacking filesystems skip this
+	 * hook on their internal forwards because they were already
+	 * checked on the user-facing path.
+	 */
+	return check_access_path_or_file(path, file,
+					 LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
+static int hook_path_setxattr(const struct mnt_idmap *const idmap,
+			       const struct path *const path,
+			       const char *const name,
+			       const void *const value, const size_t size,
+			       const int flags,
+			       struct file *const file)
+{
+	return check_access_path_or_file(path, file,
+					 LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
+static int hook_path_getxattr(const struct path *const path,
+			      const char *const name,
+			      struct file *const file)
+{
+	return check_access_path_or_file(path, file,
+					 LANDLOCK_ACCESS_FS_READ_METADATA);
+}
+
+static int hook_path_listxattr(const struct path *const path,
+			       struct file *const file)
+{
+	return check_access_path_or_file(path, file,
+					 LANDLOCK_ACCESS_FS_READ_METADATA);
+}
+
+static int hook_path_removexattr(const struct mnt_idmap *const idmap,
+				  const struct path *const path,
+				  const char *const name,
+				  struct file *const file)
+{
+	return check_access_path_or_file(path, file,
+					 LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
+static int hook_path_set_acl(const struct mnt_idmap *const idmap,
+			      const struct path *const path,
+			      const char *const acl_name,
+			      struct posix_acl *const kacl,
+			      struct file *const file)
+{
+	return check_access_path_or_file(path, file,
+					 LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
+static int hook_path_get_acl(const struct mnt_idmap *const idmap,
+			      const struct path *const path,
+			      const char *const acl_name,
+			      struct file *const file)
+{
+	return check_access_path_or_file(path, file,
+					 LANDLOCK_ACCESS_FS_READ_METADATA);
+}
+
+static int hook_path_remove_acl(const struct mnt_idmap *const idmap,
+				const struct path *const path,
+				const char *const acl_name,
+				struct file *const file)
+{
+	return check_access_path_or_file(path, file,
+					 LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
 /**
  * unmask_scoped_access - Remove access right bits in @masks in all layers
  *                        where @client and @server have the same domain
@@ -1876,7 +2064,9 @@ static int hook_file_open(struct file *const file)
 	 * We look up more access than what we immediately need for open(), so
 	 * that we can later authorize operations on opened files.
 	 */
-	optional_access = LANDLOCK_ACCESS_FS_TRUNCATE;
+	optional_access = LANDLOCK_ACCESS_FS_TRUNCATE |
+			  LANDLOCK_ACCESS_FS_READ_METADATA |
+			  LANDLOCK_ACCESS_FS_WRITE_METADATA;
 	if (is_device(file))
 		optional_access |= LANDLOCK_ACCESS_FS_IOCTL_DEV;
 
@@ -1928,32 +2118,11 @@ static int hook_file_open(struct file *const file)
 static int hook_file_truncate(struct file *const file)
 {
 	/*
-	 * Allows truncation if the truncate right was available at the time of
-	 * opening the file, to get a consistent access check as for read, write
-	 * and execute operations.
-	 *
-	 * Note: For checks done based on the file's Landlock allowed access, we
-	 * enforce them independently of whether the current thread is in a
-	 * Landlock domain, so that open files passed between independent
-	 * processes retain their behaviour.
+	 * Allows truncation if the truncate right was available at the time
+	 * of opening the file, to get a consistent access check as for read,
+	 * write and execute operations.
 	 */
-	if (landlock_file(file)->allowed_access & LANDLOCK_ACCESS_FS_TRUNCATE)
-		return 0;
-
-	landlock_log_denial(landlock_cred(file->f_cred), &(struct landlock_request) {
-		.type = LANDLOCK_REQUEST_FS_ACCESS,
-		.audit = {
-			.type = LSM_AUDIT_DATA_FILE,
-			.u.file = file,
-		},
-		.all_existing_optional_access = _LANDLOCK_ACCESS_FS_OPTIONAL,
-		.access = LANDLOCK_ACCESS_FS_TRUNCATE,
-#ifdef CONFIG_SECURITY_LANDLOCK_LOG
-		.deny_masks = landlock_file(file)->deny_masks,
-		.quiet_optional_accesses = landlock_file(file)->quiet_optional_accesses,
-#endif /* CONFIG_SECURITY_LANDLOCK_LOG */
-	});
-	return -EACCES;
+	return check_access_file(file, LANDLOCK_ACCESS_FS_TRUNCATE);
 }
 
 static int hook_file_ioctl_common(const struct file *const file,
@@ -2100,6 +2269,17 @@ static struct security_hook_list landlock_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(path_unlink, hook_path_unlink),
 	LSM_HOOK_INIT(path_rmdir, hook_path_rmdir),
 	LSM_HOOK_INIT(path_truncate, hook_path_truncate),
+	LSM_HOOK_INIT(path_getattr, hook_path_getattr),
+	LSM_HOOK_INIT(path_file_getattr, hook_path_file_getattr),
+	LSM_HOOK_INIT(path_setattr, hook_path_setattr),
+	LSM_HOOK_INIT(path_file_setattr, hook_path_file_setattr),
+	LSM_HOOK_INIT(path_setxattr, hook_path_setxattr),
+	LSM_HOOK_INIT(path_getxattr, hook_path_getxattr),
+	LSM_HOOK_INIT(path_listxattr, hook_path_listxattr),
+	LSM_HOOK_INIT(path_removexattr, hook_path_removexattr),
+	LSM_HOOK_INIT(path_set_acl, hook_path_set_acl),
+	LSM_HOOK_INIT(path_get_acl, hook_path_get_acl),
+	LSM_HOOK_INIT(path_remove_acl, hook_path_remove_acl),
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

