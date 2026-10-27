Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.222
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101168;
	b=PpJNO0OLuDA1JWM3n/5FuzA3gh/+zUg/1WhuuiVSx41gDjyCEEdslcM6qJ9dlyK1DZSb
	 FKglGk6wau0wSZlvOT0wyAimAWdw4JFRYxQaHJZL1OUaXQtE8lFJHXbzlXr+L+Bdeq4kV
	 xwfpY8fCY8OWgK4pRvR8ilc3hNxeF+p36zDoYCBWy/W8hcZ3WoROdSXhvFHHmp+bqeVpc
	 5VzfUvAewsnJRT9MQqwj1X59R2NRHYTKbK/0aIR0sjLfkIMhoBVDSwBQaS/lxIFLy5G3x
	 Opqf21pxUrfnHKgn26gi5V+iQw8Lb7XiOWxrIaGcqcTiyBe7J6HdEmSFphVhNWKG12A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101168;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:X-Originating-IP:X-ClientProxiedBy;
	bh=1VtIHJ+tuGs/IAWNrnPIyzriRVCAOpszDHNED4Rp19M=;
	b=mteloP/HD424a5WeOaEI2kUFFSW+o/EC7PedQVyLHhxNnmw2gln52T+y3AQCHgUF41Ug
	 wwg50Q1SNHr8Y16huuLIHmkI0ghcGaaHr1EFEgyVTk27XtxP5/JGObi6jkqdiCcA18a9E
	 GOdQsWXCWuysMTx+44PQya4OaHJinsJruKpxN1xOjt67n9kUPAxnKCBsQspllDd/4ui0B
	 XvCjDETQxzr0k5Sy/8JxJ9PjYJ5pUK7fr9QYGTqDntRu9v336ADKY9AfS7H3JLplImUTY
	 rHk4NPUF9lLrao0rRR2QA1NV1w5uy+lD38jVJJMAakUkESmFsAqEFSaZMyzC17BF61g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=X4+TOg1k;
	arc=none smtp.remote-ip=113.46.200.222
Received: from canpmsgout07.his.huawei.com (canpmsgout07.his.huawei.com [113.46.200.222])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4025F606A7CA;
	Tue, 27 Oct 2026 11:39:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4025F606A7CA
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=X4+TOg1k
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=1VtIHJ+tuGs/IAWNrnPIyzriRVCAOpszDHNED4Rp19M=;
	b=X4+TOg1kXiYvmpqnqEUsOw2/o4gX+xV+1569HON0wT1fQGrmHjHU8A0BNQHIMw+pfg3/7YMsl
	5WLEWqfSJM7q5IXJ3JozYKtj/xsPvkMAqF9ePeDWAlmgXK9wBGLlfjS2e9l6bFNhq+lg9aBOGyM
	Y5xQOhGZaFTMygAyC2tLIIE=
Received: from mail.maildlp.com (unknown [172.19.163.214])
	by canpmsgout07.his.huawei.com (SkyGuard) with ESMTPS id 4jDT6Y548qzLlVS;
	Tue, 27 Oct 2026 19:39:17 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 829A04056C;
	Tue, 27 Oct 2026 19:39:23 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Tue, 27 Oct 2026 19:39:18 +0800
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
Subject: [PATCH v3 -next 16/18] selftests/landlock: Add tests for metadata access rights
Date: Tue, 27 Oct 2026 20:11:49 +0800
Message-ID: <20261027121151.1887650-17-caixinchen1@huawei.com>
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

Add layout1 tests for the LANDLOCK_ACCESS_FS_READ_METADATA and
LANDLOCK_ACCESS_FS_WRITE_METADATA access rights:

- unhandled_metadata: metadata access is allowed when the new rights
  are not handled by the ruleset;
- write_metadata: chmod(2), fchmod(2), chown(2), fchown(2), lchown(2),
  utimensat(2) (both with explicit times and with UTIME_NOW),
  setxattr(2), and removexattr(2) are denied with EACCES without
  WRITE_METADATA, and allowed with it.  Writing to or truncating a
  set-user-ID file clears the set-user-ID bit implicitly, which
  stays allowed without WRITE_METADATA, while an explicit chown(2)
  with (-1, -1) requesting the same clearing is denied without
  WRITE_METADATA and allowed with it;
- read_metadata: stat(2), fstat(2), getxattr(2), and listxattr(2) are
  denied with EACCES without READ_METADATA, and allowed with it.

Add layout1 and layout2_overlay tests for the fileattr interfaces
controlled by the same rights:

- fileattr: ioctl(FS_IOC_GETFLAGS), ioctl(FS_IOC_SETFLAGS),
  file_getattr(2) and file_setattr(2) (both with a path and with
  AT_EMPTY_PATH) are denied with EACCES without the corresponding
  right, and allowed with it;
- fileattr_write_only: with only WRITE_METADATA handled, metadata
  writes (ioctl(FS_IOC_SETFLAGS)) and reads (ioctl(FS_IOC_GETFLAGS))
  are both allowed, as READ_METADATA is not handled; when
  READ_METADATA is handled as well but not granted, metadata reads
  through a file descriptor opened from then on are denied with
  EACCES while writes are still allowed, because the kernel-side
  read of the old flags performed when setting new ones does not go
  through the READ_METADATA check.  Reading metadata through a file
  descriptor opened while READ_METADATA was not handled yet is still
  allowed;
- layout2_overlay.fileattr: the same fileattr checks on files
  accessed through an overlayfs mount created by the (unrestricted)
  test process;
- overlay_mount_denied: a restricted process cannot bypass the
  metadata rights by mounting a new overlayfs with mount(2), even
  with CAP_SYS_ADMIN: landlock denies mount(2) with EPERM for any
  landlocked process.

The file-based metadata checks follow the
LANDLOCK_ACCESS_FS_TRUNCATE mechanic: it is the access rights at the
time of open(2) which decide whether an operation on an already
opened file is permitted.  Adapt the fchown(2) denial case of the
write_metadata test and the second phase of the fileattr_write_only
test to that semantic by (re)opening the file descriptors after the
ruleset is enforced, and add layout1 tests for the open-time
semantic itself:

- metadata_open_time: a file descriptor opened before the ruleset is
  enforced keeps allowing fchmod(2), fchown(2), futimens(2),
  fstat(2), fgetxattr(2), fsetxattr(2), ioctl(FS_IOC_GETFLAGS) and
  file_getattr(2)/file_setattr(2) with AT_EMPTY_PATH, whereas the
  same operations through a file descriptor opened while the
  ruleset is enforced are denied with EACCES, and the same
  operations through paths are denied as well.  Data accesses
  (write(2)) still work through the restricted file descriptor, and
  an O_PATH file descriptor is checked against the current domain,
  like path-based accesses;
- metadata_transfer: a file descriptor opened by a landlocked
  process without the metadata access rights and passed to a
  non-landlocked process through a unix socket still denies metadata
  accesses, while data accesses work: the file descriptor carries
  the rights of the process which opened it, whatever the rights of
  the process using it.

The fallback syscall numbers for file_getattr(2) and file_setattr(2)
used when building against older headers are not universal: alpha
assigns 578 and 579 to them instead of the generic 468 and 469.

Rule enforcement is checked per file and per directory.

Update the ACCESS_FILE and ACCESS_LAST definitions to include the new
rights.

The new rights are appended to _LANDLOCK_ACCESS_FS_NAMES, which
extends the absolute access mask expanded by
landlock_append_fs_rule(); update the expected access_rights suffix in
the trace_fs.add_rule_path_beneath_escaped_path_overflow test
accordingly.

Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 tools/testing/selftests/landlock/base_test.c  |   2 +-
 tools/testing/selftests/landlock/fs_test.c    | 921 +++++++++++++++++-
 .../selftests/landlock/trace_fs_test.c        |   3 +-
 3 files changed, 923 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/landlock/base_test.c b/tools/testing/selftests/landlock/base_test.c
index 89c0d96607de..14078ad203d8 100644
--- a/tools/testing/selftests/landlock/base_test.c
+++ b/tools/testing/selftests/landlock/base_test.c
@@ -76,7 +76,7 @@ TEST(abi_version)
 	const struct landlock_ruleset_attr ruleset_attr = {
 		.handled_access_fs = LANDLOCK_ACCESS_FS_READ_FILE,
 	};
-	ASSERT_EQ(12, landlock_create_ruleset(NULL, 0,
+	ASSERT_EQ(13, landlock_create_ruleset(NULL, 0,
 					      LANDLOCK_CREATE_RULESET_VERSION));
 
 	ASSERT_EQ(-1, landlock_create_ruleset(&ruleset_attr, 0,
diff --git a/tools/testing/selftests/landlock/fs_test.c b/tools/testing/selftests/landlock/fs_test.c
index f725882fa4a7..1e819ba952ac 100644
--- a/tools/testing/selftests/landlock/fs_test.c
+++ b/tools/testing/selftests/landlock/fs_test.c
@@ -12,6 +12,7 @@
 #include <fcntl.h>
 #include <libgen.h>
 #include <linux/fiemap.h>
+#include <linux/fs.h>
 #include <linux/landlock.h>
 #include <linux/magic.h>
 #include <sched.h>
@@ -26,8 +27,10 @@
 #include <sys/sendfile.h>
 #include <sys/socket.h>
 #include <sys/stat.h>
+#include <sys/syscall.h>
 #include <sys/sysmacros.h>
 #include <sys/un.h>
+#include <sys/xattr.h>
 #include <sys/vfs.h>
 #include <unistd.h>
 
@@ -571,11 +574,13 @@ TEST_F_FORK(layout1, inval)
 	LANDLOCK_ACCESS_FS_EXECUTE | \
 	LANDLOCK_ACCESS_FS_WRITE_FILE | \
 	LANDLOCK_ACCESS_FS_READ_FILE | \
+	LANDLOCK_ACCESS_FS_READ_METADATA | \
+	LANDLOCK_ACCESS_FS_WRITE_METADATA | \
 	LANDLOCK_ACCESS_FS_TRUNCATE | \
 	LANDLOCK_ACCESS_FS_IOCTL_DEV | \
 	LANDLOCK_ACCESS_FS_RESOLVE_UNIX)
 
-#define ACCESS_LAST LANDLOCK_ACCESS_FS_RESOLVE_UNIX
+#define ACCESS_LAST LANDLOCK_ACCESS_FS_WRITE_METADATA
 
 #define ACCESS_ALL ( \
 	ACCESS_FILE | \
@@ -10916,4 +10921,918 @@ TEST_F(trace_layout1, check_rule_fs_empty_grant)
 	free(buf);
 }
 
+/* Invokes chmod(2) and returns its errno or 0. */
+static int test_chmod(const char *const path, mode_t mode)
+{
+	if (chmod(path, mode) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes fchmod(2) and returns its errno or 0. */
+static int test_fchmod(int fd, mode_t mode)
+{
+	if (fchmod(fd, mode) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes chown(2) and returns its errno or 0. */
+static int test_chown(const char *const path, uid_t uid, gid_t gid)
+{
+	if (chown(path, uid, gid) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes fchown(2) and returns its errno or 0. */
+static int test_fchown(int fd, uid_t uid, gid_t gid)
+{
+	if (fchown(fd, uid, gid) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes lchown(2) and returns its errno or 0. */
+static int test_lchown(const char *const path, uid_t uid, gid_t gid)
+{
+	if (lchown(path, uid, gid) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes utimensat(2) with explicit times and returns its errno or 0. */
+static int test_utimensat(const char *const path)
+{
+	const struct timespec times[] = {
+		{
+			.tv_sec = 0,
+			.tv_nsec = UTIME_OMIT,
+		},
+		{
+			.tv_sec = 1,
+			.tv_nsec = 0,
+		},
+	};
+
+	if (utimensat(AT_FDCWD, path, times, 0) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes utimensat(2) with UTIME_NOW and returns its errno or 0. */
+static int test_utimensat_now(const char *const path)
+{
+	if (utimensat(AT_FDCWD, path, NULL, 0) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes futimens(2) and returns its errno or 0. */
+static int test_futimensat(int fd)
+{
+	const struct timespec times[] = {
+		{
+			.tv_sec = 0,
+			.tv_nsec = UTIME_OMIT,
+		},
+		{
+			.tv_sec = 1,
+			.tv_nsec = 0,
+		},
+	};
+
+	if (futimens(fd, times) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes setxattr(2) and returns its errno or 0. */
+static int test_setxattr(const char *const path, const char *const name,
+			 const void *const value, const size_t size)
+{
+	if (setxattr(path, name, value, size, 0) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes getxattr(2) and returns its errno or 0. */
+static int test_getxattr(const char *const path, const char *const name,
+			 void *const value, const size_t size)
+{
+	if (getxattr(path, name, value, size) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes listxattr(2) and returns its errno or 0. */
+static int test_listxattr(const char *const path, void *const list,
+			  const size_t size)
+{
+	if (listxattr(path, list, size) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes removexattr(2) and returns its errno or 0. */
+static int test_removexattr(const char *const path, const char *const name)
+{
+	if (removexattr(path, name) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes fsetxattr(2) and returns its errno or 0. */
+static int test_fsetxattr(int fd, const char *const name,
+			  const void *const value, const size_t size)
+{
+	if (fsetxattr(fd, name, value, size, 0) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes fgetxattr(2) and returns its errno or 0. */
+static int test_fgetxattr(int fd, const char *const name, void *const value,
+			  const size_t size)
+{
+	if (fgetxattr(fd, name, value, size) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes stat(2) and returns its errno or 0. */
+static int test_stat(const char *const path, struct stat *statbuf)
+{
+	if (stat(path, statbuf) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes fstat(2) and returns its errno or 0. */
+static int test_fstat(int fd, struct stat *statbuf)
+{
+	if (fstat(fd, statbuf) < 0)
+		return errno;
+	return 0;
+}
+
+TEST_F_FORK(layout1, unhandled_metadata)
+{
+	int file_fd;
+	int ruleset_fd;
+	const char *const file1 = file1_s1d1;
+	const char *const file2 = file2_s1d1;
+	const char *const dir1 = dir_s1d1;
+	struct stat statbuf;
+	const struct rule rules[] = {
+		{
+			.path = file1,
+			.access = LANDLOCK_ACCESS_FS_WRITE_FILE,
+		},
+		{
+			.path = file2,
+			.access = LANDLOCK_ACCESS_FS_READ_FILE |
+				  LANDLOCK_ACCESS_FS_WRITE_FILE,
+		},
+		{
+			.path = dir1,
+			.access = ACCESS_RW,
+		},
+		{},
+	};
+
+	/*
+	 * READ_METADATA and WRITE_METADATA are not handled, so metadata
+	 * access should be allowed.
+	 */
+	ruleset_fd = create_ruleset(_metadata, ACCESS_RW, rules);
+	ASSERT_LE(0, ruleset_fd);
+	file_fd = open(file1, O_WRONLY | O_CLOEXEC);
+	ASSERT_LE(0, file_fd);
+
+	enforce_ruleset(_metadata, ruleset_fd);
+	ASSERT_EQ(0, close(ruleset_fd));
+
+	EXPECT_EQ(0, test_chmod(file1, 0644));
+	EXPECT_EQ(0, test_fchmod(file_fd, 0644));
+	EXPECT_EQ(0, test_chmod(file2, 0400));
+	EXPECT_EQ(0, test_chmod(dir1, 0700));
+
+	EXPECT_EQ(0, test_chown(file1, -1, 0));
+	EXPECT_EQ(0, test_fchown(file_fd, -1, 0));
+	EXPECT_EQ(0, test_lchown(file1, -1, 0));
+
+	EXPECT_EQ(0, test_utimensat(file1));
+	EXPECT_EQ(0, test_utimensat_now(file1));
+
+	EXPECT_EQ(0, test_setxattr(file1, "user.test", "a", 1));
+	EXPECT_EQ(0, test_getxattr(file1, "user.test", NULL, 0));
+	EXPECT_EQ(0, test_listxattr(file1, NULL, 0));
+	EXPECT_EQ(0, test_removexattr(file1, "user.test"));
+
+	EXPECT_EQ(0, test_stat(file1, &statbuf));
+	EXPECT_EQ(0, test_fstat(file_fd, &statbuf));
+	EXPECT_EQ(0, test_stat(dir1, &statbuf));
+
+	ASSERT_EQ(0, close(file_fd));
+}
+
+TEST_F_FORK(layout1, write_metadata)
+{
+	int file_fd, file2_fd, trunc_fd, chown_fd;
+	int ruleset_fd;
+	const char *const file1 = file1_s1d1;
+	const char *const file2 = file2_s1d1;
+	const char *const trunc_file = file1_s1d2;
+	const char *const chown_file = file2_s1d2;
+	const char *const dir1 = dir_s1d1;
+	struct stat statbuf;
+	const struct rule rules[] = {
+		{
+			.path = file1,
+			.access = LANDLOCK_ACCESS_FS_WRITE_FILE |
+				  LANDLOCK_ACCESS_FS_WRITE_METADATA,
+		},
+		{
+			.path = file2,
+			.access = LANDLOCK_ACCESS_FS_READ_FILE |
+				  LANDLOCK_ACCESS_FS_WRITE_FILE,
+		},
+		{
+			.path = chown_file,
+			.access = LANDLOCK_ACCESS_FS_READ_FILE |
+				  LANDLOCK_ACCESS_FS_WRITE_FILE,
+		},
+		{
+			.path = dir1,
+			.access = ACCESS_RW,
+		},
+		{},
+	};
+
+	ruleset_fd = create_ruleset(_metadata, ACCESS_RW |
+				    LANDLOCK_ACCESS_FS_WRITE_METADATA, rules);
+	ASSERT_LE(0, ruleset_fd);
+	file_fd = open(file1, O_WRONLY | O_CLOEXEC);
+	ASSERT_LE(0, file_fd);
+	file2_fd = open(file2, O_RDWR | O_CLOEXEC);
+	ASSERT_LE(0, file2_fd);
+	trunc_fd = open(trunc_file, O_RDWR | O_CLOEXEC);
+	ASSERT_LE(0, trunc_fd);
+	chown_fd = open(chown_file, O_RDWR | O_CLOEXEC);
+	ASSERT_LE(0, chown_fd);
+
+	/*
+	 * Arm the setuid bit for the setuid-clearing tests below:
+	 * writing or truncating a setuid file clears that bit
+	 * implicitly, which must not require WRITE_METADATA, whereas
+	 * an explicit chown(2) with (-1, -1) requests the same
+	 * clearing and must require it.  The clearing happens when
+	 * the caller has no CAP_FSETID, which is the case here
+	 * because tests run without capabilities (see disable_caps()
+	 * in prepare_layout()).
+	 */
+	ASSERT_EQ(0, fchmod(file_fd, 04666));
+	ASSERT_EQ(0, fchmod(file2_fd, 04666));
+	ASSERT_EQ(0, fchmod(trunc_fd, 04666));
+	ASSERT_EQ(0, fchmod(chown_fd, 04666));
+	/* Closes the file descriptor opened before sandboxing. */
+	ASSERT_EQ(0, close(chown_fd));
+
+	enforce_ruleset(_metadata, ruleset_fd);
+	ASSERT_EQ(0, close(ruleset_fd));
+
+	/*
+	 * Reopens the file while the ruleset is enforced: the fchown(2)
+	 * below is denied because the WRITE_METADATA right is missing from
+	 * the rights stashed at open time.
+	 */
+	chown_fd = open(chown_file, O_RDWR | O_CLOEXEC);
+	ASSERT_LE(0, chown_fd);
+
+	/*
+	 * An explicit chown(2) with (-1, -1) on a setuid file is an
+	 * explicit request to clear the setuid bit: it requires
+	 * WRITE_METADATA, which file1 has, and clears the bit.
+	 */
+	EXPECT_EQ(0, test_fchown(file_fd, -1, -1));
+	ASSERT_EQ(0, fstat(file_fd, &statbuf));
+	EXPECT_EQ(0, statbuf.st_mode & S_ISUID);
+
+	/* file1 has WRITE_METADATA: allowed */
+	EXPECT_EQ(0, test_chmod(file1, 0644));
+	EXPECT_EQ(0, test_fchmod(file_fd, 0644));
+	EXPECT_EQ(0, test_chown(file1, -1, 0));
+	EXPECT_EQ(0, test_fchown(file_fd, -1, 0));
+	EXPECT_EQ(0, test_lchown(file1, -1, 0));
+	EXPECT_EQ(0, test_utimensat(file1));
+	EXPECT_EQ(0, test_utimensat_now(file1));
+	EXPECT_EQ(0, test_setxattr(file1, "user.test", "a", 1));
+	EXPECT_EQ(0, test_removexattr(file1, "user.test"));
+
+	/*
+	 * Writing is not an explicit metadata change: implicit timestamp
+	 * updates and the implicit setuid-bit clearing are allowed
+	 * without WRITE_METADATA.
+	 */
+	EXPECT_EQ(1, write(file2_fd, "a", 1));
+	ASSERT_EQ(0, fstat(file2_fd, &statbuf));
+	EXPECT_EQ(0, statbuf.st_mode & S_ISUID);
+
+	/* file2 does not have WRITE_METADATA: denied */
+	EXPECT_EQ(EACCES, test_chmod(file2, 0400));
+	EXPECT_EQ(EACCES, test_chown(file2, -1, 0));
+	EXPECT_EQ(EACCES, test_lchown(file2, -1, 0));
+	EXPECT_EQ(EACCES, test_utimensat(file2));
+	EXPECT_EQ(EACCES, test_utimensat_now(file2));
+	EXPECT_EQ(EACCES, test_setxattr(file2, "user.test", "a", 1));
+	EXPECT_EQ(EACCES, test_removexattr(file2, "user.test"));
+
+	/*
+	 * Without the WRITE_METADATA right (i.e. without the right stashed
+	 * at open time), the same explicit chown(2) with (-1, -1) is
+	 * denied and leaves the setuid bit in place.
+	 */
+	EXPECT_EQ(EACCES, test_fchown(chown_fd, -1, -1));
+	ASSERT_EQ(0, fstat(chown_fd, &statbuf));
+	EXPECT_EQ(S_ISUID, statbuf.st_mode & S_ISUID);
+
+	/* dir1 does not have WRITE_METADATA: denied */
+	EXPECT_EQ(EACCES, test_chmod(dir1, 0700));
+	EXPECT_EQ(EACCES, test_chown(dir1, -1, 0));
+
+	/*
+	 * Truncating a setuid file implicitly clears the setuid bit as
+	 * well: this must not require WRITE_METADATA, which trunc_file
+	 * does not have.
+	 */
+	EXPECT_EQ(0, ftruncate(trunc_fd, 0));
+	ASSERT_EQ(0, fstat(trunc_fd, &statbuf));
+	EXPECT_EQ(0, statbuf.st_mode & S_ISUID);
+
+	ASSERT_EQ(0, close(file_fd));
+	ASSERT_EQ(0, close(file2_fd));
+	ASSERT_EQ(0, close(trunc_fd));
+	ASSERT_EQ(0, close(chown_fd));
+}
+
+TEST_F_FORK(layout1, read_metadata)
+{
+	int file_fd, file2_fd, sandbox_fd;
+	int ruleset_fd;
+	const char *const file1 = file1_s1d1;
+	const char *const file2 = file2_s1d1;
+	const char *const dir1 = dir_s1d1;
+	struct stat statbuf;
+	const struct rule rules[] = {
+		{
+			.path = file1,
+			.access = LANDLOCK_ACCESS_FS_READ_FILE |
+				  LANDLOCK_ACCESS_FS_READ_METADATA,
+		},
+		{
+			.path = file2,
+			.access = LANDLOCK_ACCESS_FS_READ_FILE |
+				  LANDLOCK_ACCESS_FS_WRITE_FILE,
+		},
+		{
+			.path = dir1,
+			.access = ACCESS_RW,
+		},
+		{},
+	};
+
+	ruleset_fd = create_ruleset(_metadata, ACCESS_RW |
+				    LANDLOCK_ACCESS_FS_READ_METADATA, rules);
+	ASSERT_LE(0, ruleset_fd);
+
+	ASSERT_EQ(0, setxattr(file1, "user.test", "a", 1, 0));
+	ASSERT_EQ(0, setxattr(file2, "user.test", "a", 1, 0));
+
+	/*
+	 * A file descriptor opened before the ruleset is enforced carries
+	 * all access rights.
+	 */
+	sandbox_fd = open(file1, O_RDONLY | O_CLOEXEC);
+	ASSERT_LE(0, sandbox_fd);
+
+	enforce_ruleset(_metadata, ruleset_fd);
+	ASSERT_EQ(0, close(ruleset_fd));
+
+	/* file1 has READ_METADATA: allowed */
+	EXPECT_EQ(0, test_stat(file1, &statbuf));
+	file_fd = open(file1, O_RDONLY | O_CLOEXEC);
+	ASSERT_LE(0, file_fd);
+	EXPECT_EQ(0, test_fstat(file_fd, &statbuf));
+	EXPECT_EQ(0, test_getxattr(file1, "user.test", NULL, 0));
+	EXPECT_EQ(0, test_listxattr(file1, NULL, 0));
+
+	/*
+	 * Reading metadata through the file descriptor opened before
+	 * sandboxing is still allowed.
+	 */
+	EXPECT_EQ(0, test_fstat(sandbox_fd, &statbuf));
+	ASSERT_EQ(0, close(sandbox_fd));
+
+	/*
+	 * file2 does not have READ_METADATA: denied, both through the path
+	 * and through a file descriptor opened while the ruleset is
+	 * enforced.
+	 */
+	EXPECT_EQ(EACCES, test_stat(file2, &statbuf));
+	file2_fd = open(file2, O_RDONLY | O_CLOEXEC);
+	ASSERT_LE(0, file2_fd);
+	EXPECT_EQ(EACCES, test_fstat(file2_fd, &statbuf));
+	EXPECT_EQ(EACCES, test_fgetxattr(file2_fd, "user.test", NULL, 0));
+	ASSERT_EQ(0, close(file2_fd));
+	EXPECT_EQ(EACCES, test_getxattr(file2, "user.test", NULL, 0));
+	EXPECT_EQ(EACCES, test_listxattr(file2, NULL, 0));
+	/* dir1 does not have READ_METADATA: denied */
+	EXPECT_EQ(EACCES, test_stat(dir1, &statbuf));
+
+	ASSERT_EQ(0, close(file_fd));
+}
+
+/* Invokes ioctl(FS_IOC_GETFLAGS) and returns its errno or 0. */
+static int test_getflags(int fd, unsigned int *const flags)
+{
+	if (ioctl(fd, FS_IOC_GETFLAGS, flags) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes ioctl(FS_IOC_SETFLAGS) and returns its errno or 0. */
+static int test_setflags(int fd, const unsigned int flags)
+{
+	unsigned int flags_ = flags;
+
+	if (ioctl(fd, FS_IOC_SETFLAGS, &flags_) < 0)
+		return errno;
+	return 0;
+}
+
+#ifndef __NR_file_getattr
+#if defined(__alpha__)
+#define __NR_file_getattr 578
+#else
+#define __NR_file_getattr 468
+#endif
+#endif
+#ifndef __NR_file_setattr
+#if defined(__alpha__)
+#define __NR_file_setattr 579
+#else
+#define __NR_file_setattr 469
+#endif
+#endif
+
+/* Invokes file_getattr(2) and returns its errno or 0. */
+static int test_file_getattr(int dfd, const char *const path,
+			     struct file_attr *const fattr,
+			     const unsigned int at_flags)
+{
+	if (syscall(__NR_file_getattr, dfd, path, fattr, sizeof(*fattr),
+		    at_flags) < 0)
+		return errno;
+	return 0;
+}
+
+/* Invokes file_setattr(2) and returns its errno or 0. */
+static int test_file_setattr(int dfd, const char *const path,
+			     struct file_attr *const fattr,
+			     const unsigned int at_flags)
+{
+	if (syscall(__NR_file_setattr, dfd, path, fattr, sizeof(*fattr),
+		    at_flags) < 0)
+		return errno;
+	return 0;
+}
+
+TEST_F_FORK(layout1, fileattr)
+{
+	const struct rule rules[] = {
+		{
+			.path = file1_s1d1,
+			.access = LANDLOCK_ACCESS_FS_READ_METADATA |
+				  LANDLOCK_ACCESS_FS_WRITE_METADATA,
+		},
+		{},
+	};
+	struct file_attr fattr;
+	unsigned int flags;
+	int fd, fd2, ruleset_fd;
+
+	ruleset_fd = create_ruleset(
+		_metadata,
+		LANDLOCK_ACCESS_FS_READ_METADATA |
+			LANDLOCK_ACCESS_FS_WRITE_METADATA,
+		rules);
+	ASSERT_LE(0, ruleset_fd);
+
+	fd = open(file1_s1d1, O_RDONLY | O_CLOEXEC);
+	ASSERT_LE(0, fd);
+
+	enforce_ruleset(_metadata, ruleset_fd);
+	ASSERT_EQ(0, close(ruleset_fd));
+
+	/* Allowed file: FS_IOC_GETFLAGS */
+	flags = 0;
+	EXPECT_EQ(0, test_getflags(fd, &flags));
+	EXPECT_EQ(0, flags & FS_NODUMP_FL);
+
+	/* Allowed file: FS_IOC_SETFLAGS */
+	EXPECT_EQ(0, test_setflags(fd, FS_NODUMP_FL));
+	flags = 0;
+	EXPECT_EQ(0, test_getflags(fd, &flags));
+	EXPECT_EQ(FS_NODUMP_FL, flags & FS_NODUMP_FL);
+	EXPECT_EQ(0, test_setflags(fd, 0));
+
+	/* Allowed file: file_getattr(2), with a path and with AT_EMPTY_PATH */
+	memset(&fattr, 0, sizeof(fattr));
+	EXPECT_EQ(0, test_file_getattr(AT_FDCWD, file1_s1d1, &fattr, 0));
+	EXPECT_EQ(0, fattr.fa_xflags & FS_XFLAG_NODUMP);
+	memset(&fattr, 0, sizeof(fattr));
+	EXPECT_EQ(0, test_file_getattr(fd, NULL, &fattr, AT_EMPTY_PATH));
+
+	/* Allowed file: file_setattr(2), with a path and with AT_EMPTY_PATH */
+	memset(&fattr, 0, sizeof(fattr));
+	fattr.fa_xflags = FS_XFLAG_NODUMP;
+	EXPECT_EQ(0, test_file_setattr(AT_FDCWD, file1_s1d1, &fattr, 0));
+	memset(&fattr, 0, sizeof(fattr));
+	EXPECT_EQ(0, test_file_getattr(AT_FDCWD, file1_s1d1, &fattr, 0));
+	EXPECT_EQ(FS_XFLAG_NODUMP, fattr.fa_xflags & FS_XFLAG_NODUMP);
+	memset(&fattr, 0, sizeof(fattr));
+	fattr.fa_xflags = 0;
+	EXPECT_EQ(0, test_file_setattr(fd, NULL, &fattr, AT_EMPTY_PATH));
+
+	/* Non-allowed file: FS_IOC_GETFLAGS and FS_IOC_SETFLAGS */
+	fd2 = open(file2_s1d1, O_RDONLY | O_CLOEXEC);
+	ASSERT_LE(0, fd2);
+	EXPECT_EQ(EACCES, test_getflags(fd2, &flags));
+	EXPECT_EQ(EACCES, test_setflags(fd2, FS_NODUMP_FL));
+
+	/* Non-allowed file: file_getattr(2) and file_setattr(2) */
+	memset(&fattr, 0, sizeof(fattr));
+	EXPECT_EQ(EACCES, test_file_getattr(AT_FDCWD, file2_s1d1, &fattr, 0));
+	fattr.fa_xflags = FS_XFLAG_NODUMP;
+	EXPECT_EQ(EACCES, test_file_setattr(AT_FDCWD, file2_s1d1, &fattr, 0));
+
+	ASSERT_EQ(0, close(fd));
+	ASSERT_EQ(0, close(fd2));
+}
+
+TEST_F_FORK(layout1, fileattr_write_only)
+{
+	const struct rule rules[] = {
+		{
+			.path = file1_s1d1,
+			.access = LANDLOCK_ACCESS_FS_WRITE_METADATA,
+		},
+		{},
+	};
+	struct file_attr fattr;
+	unsigned int flags;
+	int fd, fd2, ruleset_fd;
+
+	ruleset_fd = create_ruleset(_metadata,
+				    LANDLOCK_ACCESS_FS_WRITE_METADATA, rules);
+	ASSERT_LE(0, ruleset_fd);
+
+	fd = open(file1_s1d1, O_RDONLY | O_CLOEXEC);
+	ASSERT_LE(0, fd);
+
+	enforce_ruleset(_metadata, ruleset_fd);
+	ASSERT_EQ(0, close(ruleset_fd));
+
+	/*
+	 * WRITE_METADATA alone must be enough to set flags: the kernel-side
+	 * read of the old flags must not require READ_METADATA.
+	 */
+	EXPECT_EQ(0, test_setflags(fd, FS_NODUMP_FL));
+	flags = 0;
+	/* READ_METADATA is not handled: reading is allowed. */
+	EXPECT_EQ(0, test_getflags(fd, &flags));
+	EXPECT_EQ(FS_NODUMP_FL, flags & FS_NODUMP_FL);
+
+	/*
+	 * Handle READ_METADATA as well, without granting it.  Reading is
+	 * now denied for file descriptors opened from now on, but writing
+	 * must still work because the kernel-side read of the old flags
+	 * does not go through the READ_METADATA check.
+	 */
+	ruleset_fd = create_ruleset(
+		_metadata,
+		LANDLOCK_ACCESS_FS_READ_METADATA |
+			LANDLOCK_ACCESS_FS_WRITE_METADATA,
+		rules);
+	ASSERT_LE(0, ruleset_fd);
+	enforce_ruleset(_metadata, ruleset_fd);
+	ASSERT_EQ(0, close(ruleset_fd));
+
+	fd2 = open(file1_s1d1, O_RDONLY | O_CLOEXEC);
+	ASSERT_LE(0, fd2);
+	EXPECT_EQ(EACCES, test_getflags(fd2, &flags));
+	memset(&fattr, 0, sizeof(fattr));
+	EXPECT_EQ(EACCES,
+		  test_file_getattr(fd2, NULL, &fattr, AT_EMPTY_PATH));
+
+	EXPECT_EQ(0, test_setflags(fd2, 0));
+	memset(&fattr, 0, sizeof(fattr));
+	fattr.fa_xflags = FS_XFLAG_NODUMP;
+	EXPECT_EQ(0, test_file_setattr(fd2, NULL, &fattr, AT_EMPTY_PATH));
+	memset(&fattr, 0, sizeof(fattr));
+	fattr.fa_xflags = 0;
+	EXPECT_EQ(0, test_file_setattr(fd2, NULL, &fattr, AT_EMPTY_PATH));
+
+	/*
+	 * Reading through the file descriptor opened before READ_METADATA
+	 * was handled is still allowed: it carries the rights of the time
+	 * it was opened with.
+	 */
+	EXPECT_EQ(0, test_getflags(fd, &flags));
+
+	ASSERT_EQ(0, close(fd));
+	ASSERT_EQ(0, close(fd2));
+}
+
+TEST_F_FORK(layout1, metadata_open_time)
+{
+	int file_fd, opath_fd, ruleset_fd;
+	struct stat statbuf;
+	unsigned int flags;
+	struct file_attr fattr;
+	const char *const file1 = file1_s1d1;
+	const struct rule rules[] = {
+		{
+			.path = file1,
+			.access = LANDLOCK_ACCESS_FS_READ_FILE |
+				  LANDLOCK_ACCESS_FS_WRITE_FILE,
+		},
+		{},
+	};
+
+	ruleset_fd = create_ruleset(_metadata, ACCESS_RW |
+				    LANDLOCK_ACCESS_FS_READ_METADATA |
+				    LANDLOCK_ACCESS_FS_WRITE_METADATA,
+				    rules);
+	ASSERT_LE(0, ruleset_fd);
+
+	/*
+	 * A file descriptor opened before the ruleset is enforced carries
+	 * all access rights: metadata accesses through it remain allowed
+	 * even though the current thread cannot access the file's metadata
+	 * anymore.
+	 */
+	file_fd = open(file1, O_RDWR | O_CLOEXEC);
+	ASSERT_LE(0, file_fd);
+
+	enforce_ruleset(_metadata, ruleset_fd);
+	ASSERT_EQ(0, close(ruleset_fd));
+
+	EXPECT_EQ(0, test_fchmod(file_fd, 0600));
+	EXPECT_EQ(0, test_fchown(file_fd, -1, 0));
+	EXPECT_EQ(0, test_futimensat(file_fd));
+	EXPECT_EQ(0, test_fstat(file_fd, &statbuf));
+	EXPECT_EQ(0, test_getflags(file_fd, &flags));
+	EXPECT_EQ(0, test_fsetxattr(file_fd, "user.test", "a", 1));
+	EXPECT_EQ(0, test_fgetxattr(file_fd, "user.test", NULL, 0));
+	memset(&fattr, 0, sizeof(fattr));
+	EXPECT_EQ(0,
+		  test_file_getattr(file_fd, NULL, &fattr, AT_EMPTY_PATH));
+	memset(&fattr, 0, sizeof(fattr));
+	fattr.fa_xflags = FS_XFLAG_NODUMP;
+	EXPECT_EQ(0,
+		  test_file_setattr(file_fd, NULL, &fattr, AT_EMPTY_PATH));
+	memset(&fattr, 0, sizeof(fattr));
+	fattr.fa_xflags = 0;
+	EXPECT_EQ(0,
+		  test_file_setattr(file_fd, NULL, &fattr, AT_EMPTY_PATH));
+
+	/* Path-based accesses use the rights of the current thread. */
+	EXPECT_EQ(EACCES, test_chmod(file1, 0644));
+	EXPECT_EQ(EACCES, test_chown(file1, -1, 0));
+	EXPECT_EQ(EACCES, test_utimensat(file1));
+	EXPECT_EQ(EACCES, test_stat(file1, &statbuf));
+	EXPECT_EQ(EACCES, test_setxattr(file1, "user.test", "a", 1));
+	EXPECT_EQ(EACCES, test_getxattr(file1, "user.test", NULL, 0));
+
+	ASSERT_EQ(0, close(file_fd));
+
+	/*
+	 * A file descriptor opened while the ruleset is enforced only
+	 * carries the rights granted to the file: metadata accesses
+	 * through it are denied, but data accesses still work.
+	 */
+	file_fd = open(file1, O_RDWR | O_CLOEXEC);
+	ASSERT_LE(0, file_fd);
+
+	EXPECT_EQ(EACCES, test_fchmod(file_fd, 0600));
+	EXPECT_EQ(EACCES, test_fchown(file_fd, -1, 0));
+	EXPECT_EQ(EACCES, test_futimensat(file_fd));
+	EXPECT_EQ(EACCES, test_fstat(file_fd, &statbuf));
+	EXPECT_EQ(EACCES, test_getflags(file_fd, &flags));
+	EXPECT_EQ(EACCES, test_fsetxattr(file_fd, "user.test", "a", 1));
+	EXPECT_EQ(EACCES, test_fgetxattr(file_fd, "user.test", NULL, 0));
+	memset(&fattr, 0, sizeof(fattr));
+	EXPECT_EQ(EACCES,
+		  test_file_getattr(file_fd, NULL, &fattr, AT_EMPTY_PATH));
+	memset(&fattr, 0, sizeof(fattr));
+	fattr.fa_xflags = FS_XFLAG_NODUMP;
+	EXPECT_EQ(EACCES,
+		  test_file_setattr(file_fd, NULL, &fattr, AT_EMPTY_PATH));
+
+	EXPECT_EQ(0, lseek(file_fd, 0, SEEK_SET));
+	EXPECT_EQ(1, write(file_fd, "a", 1));
+
+	/*
+	 * An O_PATH file descriptor does not carry open-time rights: it is
+	 * checked against the current domain, like path-based accesses.
+	 */
+	opath_fd = open(file1, O_PATH | O_CLOEXEC);
+	ASSERT_LE(0, opath_fd);
+	EXPECT_EQ(EACCES, test_fstat(opath_fd, &statbuf));
+
+	ASSERT_EQ(0, close(file_fd));
+	ASSERT_EQ(0, close(opath_fd));
+}
+
+TEST_F_FORK(layout1, metadata_transfer)
+{
+	int child, fd, status;
+	int socket_fds[2];
+	struct stat statbuf;
+	unsigned int flags;
+	const char *const file1 = file1_s1d1;
+	const struct rule rules[] = {
+		{
+			.path = file1,
+			.access = LANDLOCK_ACCESS_FS_READ_FILE |
+				  LANDLOCK_ACCESS_FS_WRITE_FILE,
+		},
+		{},
+	};
+
+	ASSERT_EQ(0, socketpair(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0,
+				socket_fds));
+
+	child = fork();
+	ASSERT_LE(0, child);
+	if (child == 0) {
+		/*
+		 * Enables Landlock in the child process, opens a file
+		 * descriptor without the metadata access rights and sends it
+		 * to the non-landlocked parent process.
+		 */
+		int fd;
+
+		enforce_fs(_metadata, ACCESS_RW |
+					  LANDLOCK_ACCESS_FS_READ_METADATA |
+					  LANDLOCK_ACCESS_FS_WRITE_METADATA,
+			   rules);
+
+		fd = open(file1, O_RDWR | O_CLOEXEC);
+		ASSERT_LE(0, fd);
+		ASSERT_EQ(0, send_fd(socket_fds[0], fd));
+		ASSERT_EQ(0, close(fd));
+		ASSERT_EQ(0, close(socket_fds[0]));
+
+		_exit(_metadata->exit_code);
+		return;
+	}
+
+	/*
+	 * The non-landlocked parent process can use the received file
+	 * descriptor for data accesses, but its metadata accesses are
+	 * still denied with the rights stashed at open time.
+	 */
+	fd = recv_fd(socket_fds[1]);
+	ASSERT_LE(0, fd);
+	EXPECT_EQ(1, write(fd, "a", 1));
+	EXPECT_EQ(EACCES, test_fchmod(fd, 0600));
+	EXPECT_EQ(EACCES, test_fchown(fd, -1, 0));
+	EXPECT_EQ(EACCES, test_futimensat(fd));
+	EXPECT_EQ(EACCES, test_fstat(fd, &statbuf));
+	EXPECT_EQ(EACCES, test_getflags(fd, &flags));
+	ASSERT_EQ(0, close(fd));
+
+	ASSERT_EQ(child, waitpid(child, &status, 0));
+	ASSERT_EQ(1, WIFEXITED(status));
+	ASSERT_EQ(EXIT_SUCCESS, WEXITSTATUS(status));
+
+	ASSERT_EQ(0, close(socket_fds[0]));
+	ASSERT_EQ(0, close(socket_fds[1]));
+}
+
+TEST_F_FORK(layout2_overlay, fileattr)
+{
+	const struct rule rules[] = {
+		{
+			.path = MERGE_DATA,
+			.access = LANDLOCK_ACCESS_FS_READ_METADATA |
+				  LANDLOCK_ACCESS_FS_WRITE_METADATA,
+		},
+		{},
+	};
+	unsigned int flags;
+	int fd, fd2, ruleset_fd;
+
+	if (self->skip_test)
+		SKIP(return, "overlayfs is not supported (test)");
+
+	ruleset_fd = create_ruleset(
+		_metadata,
+		LANDLOCK_ACCESS_FS_READ_METADATA |
+			LANDLOCK_ACCESS_FS_WRITE_METADATA,
+		rules);
+	ASSERT_LE(0, ruleset_fd);
+
+	enforce_ruleset(_metadata, ruleset_fd);
+	ASSERT_EQ(0, close(ruleset_fd));
+
+	/*
+	 * The overlay mount was created before the ruleset was enforced
+	 * (i.e. as an administrator): the internal forwards to the real
+	 * paths must not interfere with the allowed accesses below.
+	 */
+	fd = open(merge_fl1, O_RDONLY | O_CLOEXEC);
+	ASSERT_LE(0, fd);
+
+	flags = 0;
+	EXPECT_EQ(0, test_getflags(fd, &flags));
+	EXPECT_EQ(0, flags & FS_NODUMP_FL);
+	/* Copies the file up and sets the flag on the upper real file. */
+	EXPECT_EQ(0, test_setflags(fd, FS_NODUMP_FL));
+	flags = 0;
+	EXPECT_EQ(0, test_getflags(fd, &flags));
+	EXPECT_EQ(FS_NODUMP_FL, flags & FS_NODUMP_FL);
+	EXPECT_EQ(0, test_setflags(fd, 0));
+
+	ASSERT_EQ(0, close(fd));
+
+	/* Non-allowed path: raw lower tmpfs path, outside of MERGE_DATA. */
+	fd2 = open(lower_fl1, O_RDONLY | O_CLOEXEC);
+	ASSERT_LE(0, fd2);
+	EXPECT_EQ(EACCES, test_getflags(fd2, &flags));
+	EXPECT_EQ(EACCES, test_setflags(fd2, FS_NODUMP_FL));
+	ASSERT_EQ(0, close(fd2));
+
+	/*
+	 * Removes the copied-up file to keep the upper tree in the state
+	 * expected by FIXTURE_TEARDOWN_PARENT().
+	 */
+	EXPECT_EQ(0, remove_path(merge_fl1));
+}
+
+/*
+ * A landlocked process cannot change the mount topology with mount(2),
+ * even with CAP_SYS_ADMIN (see hook_sb_mount()).  An overlay filesystem
+ * can therefore not be mounted this way by a restricted process.
+ */
+TEST_F_FORK(layout1, overlay_mount_denied)
+{
+	const char lower_dir[] = TMP_DIR "/ovl-lower";
+	const char upper_dir[] = TMP_DIR "/ovl-upper";
+	const char work_dir[] = TMP_DIR "/ovl-work";
+	const char merge_dir[] = TMP_DIR "/ovl-merge";
+	char mount_data[256];
+	const struct rule rules[] = {
+		{
+			.path = merge_dir,
+			.access = LANDLOCK_ACCESS_FS_READ_METADATA |
+				  LANDLOCK_ACCESS_FS_WRITE_METADATA,
+		},
+		{},
+	};
+	int ruleset_fd;
+
+	ASSERT_EQ(0, mkdir(lower_dir, 0700));
+	ASSERT_EQ(0, mkdir(upper_dir, 0700));
+	ASSERT_EQ(0, mkdir(work_dir, 0700));
+	ASSERT_EQ(0, mkdir(merge_dir, 0700));
+
+	snprintf(mount_data, sizeof(mount_data),
+		 "lowerdir=%s,upperdir=%s,workdir=%s", lower_dir, upper_dir,
+		 work_dir);
+
+	ruleset_fd = create_ruleset(
+		_metadata,
+		LANDLOCK_ACCESS_FS_READ_METADATA |
+			LANDLOCK_ACCESS_FS_WRITE_METADATA,
+		rules);
+	ASSERT_LE(0, ruleset_fd);
+
+	enforce_ruleset(_metadata, ruleset_fd);
+	ASSERT_EQ(0, close(ruleset_fd));
+
+	set_cap(_metadata, CAP_SYS_ADMIN);
+	EXPECT_EQ(-1, mount("overlay", merge_dir, "overlay", 0, mount_data));
+	EXPECT_EQ(EPERM, errno);
+	clear_cap(_metadata, CAP_SYS_ADMIN);
+
+	EXPECT_EQ(0, rmdir(lower_dir));
+	EXPECT_EQ(0, rmdir(upper_dir));
+	EXPECT_EQ(0, rmdir(work_dir));
+	EXPECT_EQ(0, rmdir(merge_dir));
+}
+
 TEST_HARNESS_MAIN
diff --git a/tools/testing/selftests/landlock/trace_fs_test.c b/tools/testing/selftests/landlock/trace_fs_test.c
index 64014ade3a0e..97506d249c4f 100644
--- a/tools/testing/selftests/landlock/trace_fs_test.c
+++ b/tools/testing/selftests/landlock/trace_fs_test.c
@@ -252,7 +252,8 @@ TEST_F(trace_fs, add_rule_path_beneath)
 TEST_F(trace_fs, add_rule_path_beneath_escaped_path_overflow)
 {
 	static const char access_prefix[] = "execute|write_file|read_file|";
-	static const char access_suffix[] = "|ioctl_dev|resolve_unix";
+	static const char access_suffix[] =
+		"|ioctl_dev|resolve_unix|read_metadata|write_metadata";
 	struct landlock_ruleset_attr ruleset_attr = {
 		.handled_access_fs = LANDLOCK_ACCESS_FS_READ_FILE,
 	};
-- 
2.18.0.huawei.25

