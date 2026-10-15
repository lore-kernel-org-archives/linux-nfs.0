Received: from canpmsgout03.his.huawei.com (canpmsgout03.his.huawei.com [113.46.200.218])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86FA1541E41;
	Thu, 15 Oct 2026 12:21:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.218
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792066871; cv=none; b=m0YwHZwfinaaxluYOHsS6+rMGPn6eT6Yw7SEfSy7yk0hneHdwbFWHY4UeMPrFt+zCZVpQEmjiVooq31Y29A/xnE56wSgrViwvD5pXcVIZ1iUtZZpXcgKo2jp13TOW+bL/RvkEyrGGO25bgfHZxeekVV4lGj9sqHL8se33vQsCzg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792066871; c=relaxed/simple;
	bh=yKGPJIH9kXlhzy9XFpLV8938vCTDYSsNy6QSgFB07hI=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=huDDF/OOmPXLOMeKTitjrF4aapCt+UtpJFUg+aTBOCBT+2A8fEkiaHwmv+R1ejn28L+krzhSFslX+7ewWx4KellclH2H8/yStKWcApmbO3dTXRcbXzdxVr/Icq8hvmU+SKDAw5JdW7Ope8gzYGEkNzYb5hK9Jh5Dw59ZmxVA5ek=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=ra3Qs1Sz; arc=none smtp.client-ip=113.46.200.218
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="ra3Qs1Sz"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=j5PdBVuok29EkzINq6XDaEzTV5XlEvko+h/vo1oVtR0=;
	b=ra3Qs1SzY76fEOsyvf9CW+8DNiOw8EsI0D1B5wqT7tLnICt0G4jlN1hiiuu3LEJdtTiBt1Dg2
	jpOpd/p+m63dkgw4UjEYsDj3ZMoXBtWurQ3nbiStEIxksmlgPhHnikf/79KyQOxmEMoyUi+BPFC
	b0nsR+vEv/kKNXcQIr0L6PQ=
Received: from mail.maildlp.com (unknown [172.19.162.197])
	by canpmsgout03.his.huawei.com (SkyGuard) with ESMTPS id 4j56Km5zyjzpT0h;
	Thu, 15 Oct 2026 20:08:28 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 0E4A940579;
	Thu, 15 Oct 2026 20:21:06 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 15 Oct 2026 20:21:00 +0800
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
Subject: [PATCH v2 -next 16/18] selftests/landlock: Add tests for metadata access rights
Date: Thu, 15 Oct 2026 20:54:22 +0800
Message-ID: <20261015125425.3246251-17-caixinchen1@huawei.com>
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

Add layout1 tests for the LANDLOCK_ACCESS_FS_READ_METADATA and
LANDLOCK_ACCESS_FS_WRITE_METADATA access rights:

- unhandled_metadata: metadata access is allowed when the new rights
  are not handled by the ruleset;
- write_metadata: chmod(2), fchmod(2), chown(2), fchown(2), lchown(2),
  utimensat(2) (both with explicit times and with UTIME_NOW),
  setxattr(2), and removexattr(2) are denied with EACCES without
  WRITE_METADATA, and allowed with it.  Writing to a file (which
  triggers implicit timestamp updates) stays allowed without
  WRITE_METADATA;
- read_metadata: stat(2), fstat(2), getxattr(2), and listxattr(2) are
  denied with EACCES without READ_METADATA, and allowed with it.

Add layout1 and layout2_overlay tests for the fileattr interfaces
controlled by the same rights:

- fileattr: ioctl(FS_IOC_GETFLAGS), ioctl(FS_IOC_SETFLAGS),
  file_getattr(2) and file_setattr(2) (both with a path and with
  AT_EMPTY_PATH) are denied with EACCES without the corresponding
  right, and allowed with it;
- fileattr_write_only: with only WRITE_METADATA handled, metadata
  writes (ioctl(FS_IOC_SETFLAGS)) are allowed while metadata reads
  (ioctl(FS_IOC_GETFLAGS)) are still denied;
- layout2_overlay.fileattr: the same fileattr checks on files
  accessed through an overlayfs mount created by the (unrestricted)
  test process;
- overlay_mount_denied: a restricted process cannot bypass the
  metadata rights by mounting a new overlayfs with mount(2), even
  with CAP_SYS_ADMIN: landlock denies mount(2) with EPERM for any
  landlocked process.

Rule enforcement is checked per file and per directory.  chown(2) is
tested with a group change because chown(2) with (-1, -1) is a no-op
that is not visible to the inode_setattr hook.

Update the ACCESS_FILE and ACCESS_LAST definitions to include the new
rights.

The new rights are appended to _LANDLOCK_ACCESS_FS_NAMES, which
extends the absolute access mask expanded by
landlock_append_fs_rule(); update the expected access_rights suffix in
the trace_fs.add_rule_path_beneath_escaped_path_overflow test
accordingly.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 tools/testing/selftests/landlock/base_test.c  |   2 +-
 tools/testing/selftests/landlock/fs_test.c    | 606 +++++++++++++++++-
 .../selftests/landlock/trace_fs_test.c        |   3 +-
 3 files changed, 608 insertions(+), 3 deletions(-)

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
index f725882fa4a7..ce865955c579 100644
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
@@ -10916,4 +10921,603 @@ TEST_F(trace_layout1, check_rule_fs_empty_grant)
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
+	int file_fd, file2_fd, trunc_fd;
+	int ruleset_fd;
+	const char *const file1 = file1_s1d1;
+	const char *const file2 = file2_s1d1;
+	const char *const trunc_file = file1_s1d2;
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
+
+	/*
+	 * Arm the setuid bit for the implicit clearing tests below:
+	 * writing or truncating a setuid file clears that bit when the
+	 * caller has no CAP_FSETID, which is the case here because
+	 * tests run without capabilities (see disable_caps() in
+	 * prepare_layout()).
+	 */
+	ASSERT_EQ(0, fchmod(file2_fd, 04666));
+	ASSERT_EQ(0, fchmod(trunc_fd, 04666));
+
+	enforce_ruleset(_metadata, ruleset_fd);
+	ASSERT_EQ(0, close(ruleset_fd));
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
+}
+
+TEST_F_FORK(layout1, read_metadata)
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
+	file_fd = open(file1, O_RDONLY | O_CLOEXEC);
+	ASSERT_LE(0, file_fd);
+
+	enforce_ruleset(_metadata, ruleset_fd);
+	ASSERT_EQ(0, close(ruleset_fd));
+
+	/* file1 has READ_METADATA: allowed */
+	EXPECT_EQ(0, test_stat(file1, &statbuf));
+	EXPECT_EQ(0, test_fstat(file_fd, &statbuf));
+	EXPECT_EQ(0, test_getxattr(file1, "user.test", NULL, 0));
+	EXPECT_EQ(0, test_listxattr(file1, NULL, 0));
+
+	/* file2 does not have READ_METADATA: denied */
+	EXPECT_EQ(EACCES, test_stat(file2, &statbuf));
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
+#define __NR_file_getattr 468
+#endif
+#ifndef __NR_file_setattr
+#define __NR_file_setattr 469
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
+	unsigned int flags;
+	int fd, ruleset_fd;
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
+	EXPECT_EQ(0, test_setflags(fd, 0));
+
+	ASSERT_EQ(0, close(fd));
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

