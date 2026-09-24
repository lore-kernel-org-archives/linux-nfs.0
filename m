Received: from canpmsgout01.his.huawei.com (canpmsgout01.his.huawei.com [113.46.200.216])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C8803480DD3;
	Thu, 24 Sep 2026 10:23:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.216
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790245397; cv=none; b=CzDs1upO7rQbc/wTVngj//7BIaZi8QhFCuuGvwQwdb3bmc3yL7LdHx+EMyxQWiFz99bLEO6RHqcQINviBJqPP6Eg2naZl96kF6Dbq8XWWWYXmaCLKGbxBho/I8LmHGrEJszE1L2Oc7ltkgeJwDqxj3FMJAgGBEm6sNpiWc7a5XM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790245397; c=relaxed/simple;
	bh=+J9wF9Lwfej7v+EFr/M72Wad5q0IN8ZD20vz7sYauA8=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=AI9NvB9Xjl6TRngeyP2sba5eSda0INmkXIeUv8Ldym4cYuhC/2nEojGjAO68ZJQeaM/7uyvqfbJSusWdpHRvVWo1lC/0jMWQLZ1S6mfGe4SxR++zwU/JvDKl0jtATxYlDmUZe+tnBglYE+3RBYe/7yHQuPXY6yxHajeecwmHQWU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=OSEgd3wT; arc=none smtp.client-ip=113.46.200.216
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="OSEgd3wT"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=8DKf2xUAPJdFv62WusOE155ZXr5hz4ClWmqJjmuEvrM=;
	b=OSEgd3wTTC9H3Bg/fwH6mgbUPq7QleGKyp7CnGhY5pEPAsAzLMw+cpov82lIQpBgTgdOAExFM
	W27uMrhIIRBmXzModDQeGZ0M8zORvTlCpf4H5oXTbGvlQeuu+fuqhc8/UWePrvpcPkV2JfmLZcX
	loEouL1qBf21RS7PXeeVZ6I=
Received: from mail.maildlp.com (unknown [172.19.163.104])
	by canpmsgout01.his.huawei.com (SkyGuard) with ESMTPS id 4hr8kF3MwKz1T4MQ;
	Thu, 24 Sep 2026 18:11:17 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 68CE34057F;
	Thu, 24 Sep 2026 18:23:10 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 24 Sep 2026 18:23:05 +0800
From: Cai Xinchen <caixinchen1@huawei.com>
To: <mic@digikod.net>, <gnoack@google.com>, <paul@paul-moore.com>,
	<jmorris@namei.org>, <serge@hallyn.com>, <corbet@lwn.net>,
	<skhan@linuxfoundation.org>
CC: <rdunlap@infradead.org>, <gregkh@linuxfoundation.org>,
	<rafael@kernel.org>, <dakr@kernel.org>, <dlemoal@kernel.org>, <hch@lst.de>,
	<axboe@kernel.dk>, <viro@zeniv.linux.org.uk>, <brauner@kernel.org>,
	<jack@suse.cz>, <dhowells@redhat.com>, <code@tyhicks.com>,
	<linkinjeon@kernel.org>, <sj1557.seo@samsung.com>, <yuezhang.mo@sony.com>,
	<hirofumi@mail.parknet.co.jp>, <cel@kernel.org>, <jlayton@kernel.org>,
	<neil@brown.name>, <okorniev@redhat.com>, <Dai.Ngo@oracle.com>,
	<tom@talpey.com>, <miklos@szeredi.hu>, <amir73il@gmail.com>,
	<senozhatsky@chromium.org>, <chenxiaosong@chenxiaosong.com>,
	<zohar@linux.ibm.com>, <roberto.sassu@huawei.com>,
	<dmitry.kasatkin@gmail.com>, <eric.snowberg@oracle.com>,
	<stephen.smalley.work@gmail.com>, <omosnacek@gmail.com>,
	<casey@schaufler-ca.com>, <nanx95726@gmail.com>, <djwong@kernel.org>,
	<daniel@iogearbox.net>, <linux-security-module@vger.kernel.org>,
	<linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<driver-core@lists.linux.dev>, <linux-block@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <netfs@lists.linux.dev>,
	<ecryptfs@vger.kernel.org>, <exfat@lists.linux.dev>,
	<linux-nfs@vger.kernel.org>, <linux-unionfs@vger.kernel.org>,
	<linux-cifs@vger.kernel.org>, <linux-integrity@vger.kernel.org>,
	<selinux@vger.kernel.org>, <linux-kselftest@vger.kernel.org>,
	<xiujianfeng@huawei.com>, <caixinchen1@huawei.com>, <lujialin4@huawei.com>
Subject: [PATCH RFC -next 10/12] selftests/landlock: Add tests for metadata access rights
Date: Thu, 24 Sep 2026 18:48:29 +0800
Message-ID: <20260924104831.1081137-11-caixinchen1@huawei.com>
X-Mailer: git-send-email 2.18.0.huawei.25
In-Reply-To: <20260924104831.1081137-1-caixinchen1@huawei.com>
References: <20260924104831.1081137-1-caixinchen1@huawei.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
X-ClientProxiedBy: kwepems200001.china.huawei.com (7.221.188.67) To
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

Rule enforcement is checked per file and per directory.  chown(2) is
tested with a group change because chown(2) with (-1, -1) is a no-op
that is not visible to the inode_setattr hook.

Update the ACCESS_FILE and ACCESS_LAST definitions to include the new
rights.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 tools/testing/selftests/landlock/fs_test.c | 309 ++++++++++++++++++++-
 1 file changed, 308 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/landlock/fs_test.c b/tools/testing/selftests/landlock/fs_test.c
index fd20a2b3c0a5..a3e764cc56d5 100644
--- a/tools/testing/selftests/landlock/fs_test.c
+++ b/tools/testing/selftests/landlock/fs_test.c
@@ -28,6 +28,7 @@
 #include <sys/stat.h>
 #include <sys/sysmacros.h>
 #include <sys/un.h>
+#include <sys/xattr.h>
 #include <sys/vfs.h>
 #include <unistd.h>
 
@@ -578,11 +579,13 @@ TEST_F_FORK(layout1, inval)
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
@@ -10923,4 +10926,308 @@ TEST_F(trace_layout1, check_rule_fs_empty_grant)
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
+	int file_fd, file2_fd;
+	int ruleset_fd;
+	const char *const file1 = file1_s1d1;
+	const char *const file2 = file2_s1d1;
+	const char *const dir1 = dir_s1d1;
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
+	file2_fd = open(file2, O_WRONLY | O_CLOEXEC);
+	ASSERT_LE(0, file2_fd);
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
+	 * updates are allowed without WRITE_METADATA.
+	 */
+	EXPECT_EQ(1, write(file2_fd, "a", 1));
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
+	ASSERT_EQ(0, close(file_fd));
+	ASSERT_EQ(0, close(file2_fd));
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
 TEST_HARNESS_MAIN
-- 
2.18.0.huawei.25

