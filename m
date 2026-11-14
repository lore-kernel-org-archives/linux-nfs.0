Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661828;
	b=D2pmV172MsNgux19+8tEgNhk27HGcMhbO9uEJGulIYEwqKAX0BAzevFV2EVkstmtk6js
	 pF2PO8CvENkw44L1PiHhxUCpHF0idMxAOJW4aO7JWm6aOwY1HmbrYKLZZf932BBWzM/sI
	 lWvRgaSPYHKI6AnBcKn//yd4i3x3ZfqQieMOAasC+dACyCYOuFZhBTX30OhToDGy9A5o5
	 xjg/TbUUzlnuxNShEr6sAAWb8T+GKukFwF9xddZp/QPVT0mDXDapczBOtDXs3q3C9hAYa
	 HxC4YUJWo/R15dG6mgbp/ESDq0aFgAZS8ZkFQ+3W2uKyuziPxkZ9o1vGRNJYRTEBM7w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661828;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=bZzPVCDR9p9yXfSnH8rVXpL5YD0HLVrk9YJZvkQ2Ids=;
	b=EBnqwQEg+8Huxg2uLPzY05i7oa9AaZWJsMEuKOKsBINtRWlkS2c3Q00hKUNeDouKNtou
	 ObXc6hSptYhozzRnzKAm/XO22tU2vEjJzSbYyBToqcKQayJ9iW9+45F+Ex5JUKv6mKmOF
	 BV6majqgEw+FoCUAbgVBEQk17C7/uUc6X5jq8aceyS6+Zxg4jl7lpcIT2qXuJIHU6EcC2
	 fJskUE3uP7aqND8xFLwY9sN7Amfppz6wNXn26AFAvj87PNuwSNsBOHwQc5hjoJ2Y05bTD
	 Tmbtb+6UpcMhbLptpcXIFMFhANnITH0hnn8JjaD1A+k7RYYJhOat+I8iYdleEyazmwQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nuDa1vbB;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D07F606F265;
	Sat, 14 Nov 2026 13:10:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nuDa1vbB
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 88A491F000CB;
	Sat, 14 Nov 2026 13:10:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661827;
	bh=bZzPVCDR9p9yXfSnH8rVXpL5YD0HLVrk9YJZvkQ2Ids=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=nuDa1vbBqzQf+qHxjxYPt/VGgYBRDVfq2mYUyhOQxQM1JW9VQXmgorz5WQ9BiZZa0
	 NAieRdfSykihiTRnjS24aMufxFEv6Z0jfFn3W2QfNKWWnSmxY0Xt/IZMnqPHK4T4UG
	 u1+tcNjpfukKnzrLWegECKatFSpLrKOJUDYuXxoB9Jefuuj1LdofHVO2ZA2bpGwuUh
	 EXrkfDLZHhrOLKQrKk1BociqeOcWI7yG42mxCTqjv4xDnP2fig7mcWQzKnI2JA+iCC
	 /mN7VyJPNMsU0lSeUTf0NLlZf3FNWIOGHBGaDjEI3RRwnB7s3vWd/kazpnqRSvX0n7
	 M7oGs6uLQ9Ncg==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:23 +0100
Subject: [PATCH RFC v2 42/42] selftests/filesystems: add backing file tests
 for pseudo files
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261114-work-loop-pseudo-v2-42-98639a2286fb@kernel.org>
References: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
In-Reply-To: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, 
 Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, 
 target-devel@vger.kernel.org, driver-core@lists.linux.dev, 
 linux-mm@kvack.org, bpf@vger.kernel.org, 
 linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
 apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, fuse-devel@lists.linux.dev, 
 linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, 
 ocfs2-devel@lists.linux.dev, linux-s390@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org, 
 Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, 
 linux-kselftest@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=18601; i=brauner@kernel.org;
 h=from:subject:message-id; bh=3WWvVZ2yqqPmZE6xtEwdV3hj04ARSZC29hiCgaem9R4=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iJmmn9279PvOSx9uLJoz4bh+3f91k71erslg2LZAO
 V/P/2Hv5o5SFgYxLgZZMUUWh3aTcLnlPBWbjTI1YOawMoEMYeDiFICJLNvJ8Id3que2ZS4H57Mu
 XbfyydulIUo6OYsNIs5I77wmWy15k3sGI8PPa1N2lTCsFY9QqmOb0KbA0yNml8a/MuiGrs7x+7/
 sKzgA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Add tests that files on pseudo filesystems can't be used as storage:

- a procfs file attached read-only to a loop device
- sysfs files attached read-only and read-write to a loop device
- a sysfs file behind a lower-only overlayfs attached to a loop device
- a symlink and a magic link to a sysfs file attached to a loop device
- a procfs file as the backing file of an nvme target namespace
- a procfs file as the backing file and as the protection file of a
  fileio device of the scsi target
- a procfs file as a zloop zone file
- a sysfs file as the backing file of a usb mass storage gadget LUN
- a sysfs file as the source of a file-backed erofs mount

Add tests that FIFOs and character devices can't be used as storage by
loop, the nvme target, the fileio backend and zloop either.

And make sure that a memfd and another loop device still work as loop
backing files, that a regular file and a block device still work for
the nvme target and the fileio backend and that loop refuses a backing
file that isn't open for reading.

The nvme target test uses buffered_io as asked for in [1]. Most pseudo
files can't be opened with O_DIRECT and the test would pass without
ever reaching the check.

[1]: https://lore.kernel.org/r/71f76e5e-ce24-4a71-863a-169ad262c510@gmail.com

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 tools/testing/selftests/filesystems/.gitignore     |   1 +
 tools/testing/selftests/filesystems/Makefile       |   2 +-
 tools/testing/selftests/filesystems/config         |  14 +
 .../selftests/filesystems/pseudo_backing_test.c    | 570 +++++++++++++++++++++
 4 files changed, 586 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/filesystems/.gitignore b/tools/testing/selftests/filesystems/.gitignore
index cf79000e4092a..8df38eabb1252 100644
--- a/tools/testing/selftests/filesystems/.gitignore
+++ b/tools/testing/selftests/filesystems/.gitignore
@@ -7,3 +7,4 @@ kernfs_test
 idmapped_tmpfile
 ustat_test
 rw_hint_test
+pseudo_backing_test
diff --git a/tools/testing/selftests/filesystems/Makefile b/tools/testing/selftests/filesystems/Makefile
index fbd5c27505ef5..0ebb9005bcd28 100644
--- a/tools/testing/selftests/filesystems/Makefile
+++ b/tools/testing/selftests/filesystems/Makefile
@@ -2,7 +2,7 @@
 
 CFLAGS += $(KHDR_INCLUDES)
 TEST_GEN_PROGS := devpts_pts anon_inode_test kernfs_test fclog ustat_test rw_hint_test
-TEST_GEN_PROGS += idmapped_tmpfile
+TEST_GEN_PROGS += idmapped_tmpfile pseudo_backing_test
 TEST_GEN_PROGS_EXTENDED := dnotify_test
 
 include ../lib.mk
diff --git a/tools/testing/selftests/filesystems/config b/tools/testing/selftests/filesystems/config
index 9f45bc493a30a..9375164f46d70 100644
--- a/tools/testing/selftests/filesystems/config
+++ b/tools/testing/selftests/filesystems/config
@@ -6,3 +6,17 @@ CONFIG_NET=y
 CONFIG_NET_NS=y
 CONFIG_INET=y
 CONFIG_SYSFS=y
+CONFIG_BLK_DEV_LOOP=y
+CONFIG_OVERLAY_FS=y
+CONFIG_TMPFS=y
+CONFIG_CONFIGFS_FS=y
+CONFIG_USB_GADGET=y
+CONFIG_USB_CONFIGFS=y
+CONFIG_USB_CONFIGFS_MASS_STORAGE=y
+CONFIG_EROFS_FS=y
+CONFIG_EROFS_FS_BACKED_BY_FILE=y
+CONFIG_NVME_TARGET=y
+CONFIG_TARGET_CORE=y
+CONFIG_TCM_FILEIO=y
+CONFIG_BLK_DEV_ZONED=y
+CONFIG_BLK_DEV_ZONED_LOOP=y
diff --git a/tools/testing/selftests/filesystems/pseudo_backing_test.c b/tools/testing/selftests/filesystems/pseudo_backing_test.c
new file mode 100644
index 0000000000000..04315655e0587
--- /dev/null
+++ b/tools/testing/selftests/filesystems/pseudo_backing_test.c
@@ -0,0 +1,570 @@
+// SPDX-License-Identifier: GPL-2.0
+#define _GNU_SOURCE
+
+#include <errno.h>
+#include <fcntl.h>
+#include <limits.h>
+#include <sched.h>
+#include <stdbool.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <linux/loop.h>
+#include <linux/magic.h>
+#include <sys/ioctl.h>
+#include <sys/mman.h>
+#include <sys/mount.h>
+#include <sys/stat.h>
+#include <sys/vfs.h>
+
+#include "kselftest_harness.h"
+#include "wrappers.h"
+
+/*
+ * Put @fd behind a free loop device. The device is set up with
+ * LO_FLAGS_AUTOCLEAR and goes away again when it is closed here.
+ */
+static int loop_attach(int fd, bool rw, char *dev, size_t len)
+{
+	struct loop_config cfg = {};
+	int ctl, nr, lfd, ret = 0;
+
+	ctl = open("/dev/loop-control", O_RDWR | O_CLOEXEC);
+	if (ctl < 0)
+		return -errno;
+	nr = ioctl(ctl, LOOP_CTL_GET_FREE);
+	if (nr < 0)
+		ret = -errno;
+	close(ctl);
+	if (ret)
+		return ret;
+
+	snprintf(dev, len, "/dev/loop%d", nr);
+	lfd = open(dev, (rw ? O_RDWR : O_RDONLY) | O_CLOEXEC);
+	if (lfd < 0)
+		return -errno;
+
+	cfg.fd = fd;
+	cfg.info.lo_flags = LO_FLAGS_AUTOCLEAR;
+	if (!rw)
+		cfg.info.lo_flags |= LO_FLAGS_READ_ONLY;
+	if (ioctl(lfd, LOOP_CONFIGURE, &cfg)) {
+		ret = -errno;
+		close(lfd);
+	} else {
+		ret = lfd;
+	}
+	return ret;
+}
+
+static int attach_path(const char *path, bool rw)
+{
+	char dev[PATH_MAX];
+	int fd, ret;
+
+	fd = open(path, (rw ? O_RDWR : O_RDONLY) | O_CLOEXEC);
+	if (fd < 0)
+		return -errno;
+	ret = loop_attach(fd, rw, dev, sizeof(dev));
+	close(fd);
+	if (ret >= 0) {
+		close(ret);
+		ret = 0;
+	}
+	return ret;
+}
+
+static bool can_use_loop(void)
+{
+	return geteuid() == 0 && access("/dev/loop-control", R_OK | W_OK) == 0;
+}
+
+/* A pseudo file that can be opened for reading and writing. */
+#define PSEUDO_FILE "/proc/sys/kernel/hostname"
+
+static int write_string(const char *path, const char *buf)
+{
+	int fd, ret = 0;
+
+	fd = open(path, O_WRONLY | O_CLOEXEC);
+	if (fd < 0)
+		return -errno;
+	if (write(fd, buf, strlen(buf)) < 0)
+		ret = -errno;
+	close(fd);
+	return ret;
+}
+
+static int create_file(const char *path)
+{
+	int fd, ret = 0;
+
+	fd = open(path, O_RDWR | O_CREAT | O_CLOEXEC, 0600);
+	if (fd < 0)
+		return -errno;
+	if (ftruncate(fd, 1 << 20))
+		ret = -errno;
+	close(fd);
+	return ret;
+}
+
+/* Loop device on top of a memfd. It goes away when the fd is closed. */
+static int create_loop_device(char *dev, size_t len)
+{
+	int fd, lfd;
+
+	fd = memfd_create("pseudo_backing_test", MFD_CLOEXEC);
+	if (fd < 0)
+		return -errno;
+	if (ftruncate(fd, 1 << 20)) {
+		lfd = -errno;
+		close(fd);
+		return lfd;
+	}
+	lfd = loop_attach(fd, true, dev, len);
+	close(fd);
+	return lfd;
+}
+
+/* Private tmpfs on /tmp for files, links and FIFOs. */
+static int setup_tmp(void)
+{
+	if (unshare(CLONE_NEWNS))
+		return -errno;
+	if (mount(NULL, "/", NULL, MS_REC | MS_PRIVATE, NULL))
+		return -errno;
+	if (mount("tmpfs", "/tmp", "tmpfs", 0, NULL))
+		return -errno;
+	return 0;
+}
+
+TEST(memfd_backing_file)
+{
+	char dev[PATH_MAX];
+	int fd, lfd;
+
+	if (!can_use_loop())
+		SKIP(return, "loop devices unavailable");
+
+	fd = memfd_create("pseudo_backing_test", MFD_CLOEXEC);
+	ASSERT_GE(fd, 0);
+	ASSERT_EQ(ftruncate(fd, 1 << 20), 0);
+
+	lfd = loop_attach(fd, true, dev, sizeof(dev));
+	ASSERT_GE(lfd, 0);
+	EXPECT_EQ(close(lfd), 0);
+	EXPECT_EQ(close(fd), 0);
+}
+
+TEST(loop_device_backing_file)
+{
+	char dev[PATH_MAX], dev2[PATH_MAX];
+	int fd, lfd, bfd, lfd2;
+
+	if (!can_use_loop())
+		SKIP(return, "loop devices unavailable");
+
+	fd = memfd_create("pseudo_backing_test", MFD_CLOEXEC);
+	ASSERT_GE(fd, 0);
+	ASSERT_EQ(ftruncate(fd, 1 << 20), 0);
+	lfd = loop_attach(fd, true, dev, sizeof(dev));
+	ASSERT_GE(lfd, 0);
+
+	/* A block device stays fine as a backing file. */
+	bfd = open(dev, O_RDWR | O_CLOEXEC);
+	ASSERT_GE(bfd, 0);
+	lfd2 = loop_attach(bfd, true, dev2, sizeof(dev2));
+	ASSERT_GE(lfd2, 0);
+
+	EXPECT_EQ(close(lfd2), 0);
+	EXPECT_EQ(close(bfd), 0);
+	EXPECT_EQ(close(lfd), 0);
+	EXPECT_EQ(close(fd), 0);
+}
+
+TEST(write_only_backing_file)
+{
+	char dev[PATH_MAX], path[PATH_MAX];
+	int fd, wfd, lfd;
+
+	if (!can_use_loop())
+		SKIP(return, "loop devices unavailable");
+
+	fd = memfd_create("pseudo_backing_test", MFD_CLOEXEC);
+	ASSERT_GE(fd, 0);
+	ASSERT_EQ(ftruncate(fd, 1 << 20), 0);
+
+	/* Loop reads from its backing file so it must be open for reading. */
+	snprintf(path, sizeof(path), "/proc/self/fd/%d", fd);
+	wfd = open(path, O_WRONLY | O_CLOEXEC);
+	ASSERT_GE(wfd, 0);
+
+	lfd = loop_attach(wfd, true, dev, sizeof(dev));
+	if (lfd >= 0)
+		close(lfd);
+	EXPECT_EQ(lfd, -EBADF);
+	EXPECT_EQ(close(wfd), 0);
+	EXPECT_EQ(close(fd), 0);
+}
+
+TEST(procfs_backing_file)
+{
+	if (!can_use_loop())
+		SKIP(return, "loop devices unavailable");
+
+	ASSERT_EQ(attach_path("/proc/cpuinfo", false), -EINVAL);
+}
+
+TEST(sysfs_backing_file)
+{
+	if (!can_use_loop())
+		SKIP(return, "loop devices unavailable");
+
+	ASSERT_EQ(attach_path("/sys/kernel/warn_count", false), -EINVAL);
+
+	if (access("/sys/kernel/reboot/mode", F_OK))
+		SKIP(return, "no /sys/kernel/reboot/mode");
+	ASSERT_EQ(attach_path("/sys/kernel/reboot/mode", true), -EINVAL);
+}
+
+TEST(overlayfs_on_sysfs_backing_file)
+{
+	if (!can_use_loop())
+		SKIP(return, "loop devices unavailable");
+
+	ASSERT_EQ(unshare(CLONE_NEWNS), 0);
+	ASSERT_EQ(mount(NULL, "/", NULL, MS_REC | MS_PRIVATE, NULL), 0);
+	ASSERT_EQ(mount("tmpfs", "/tmp", "tmpfs", 0, NULL), 0);
+	ASSERT_EQ(mkdir("/tmp/empty", 0755), 0);
+	ASSERT_EQ(mkdir("/tmp/merged", 0755), 0);
+
+	/* A lower-only overlayfs serves reads from sysfs. */
+	if (mount("overlay", "/tmp/merged", "overlay", MS_RDONLY,
+		  "lowerdir=/sys/kernel:/tmp/empty"))
+		SKIP(return, "no overlayfs on top of sysfs: %s", strerror(errno));
+
+	ASSERT_EQ(attach_path("/tmp/merged/warn_count", false), -EINVAL);
+}
+
+TEST(link_to_sysfs_backing_file)
+{
+	char path[PATH_MAX];
+	int fd;
+
+	if (!can_use_loop())
+		SKIP(return, "loop devices unavailable");
+
+	ASSERT_EQ(setup_tmp(), 0);
+
+	/* Links are followed before the file is checked. */
+	ASSERT_EQ(symlink("/sys/kernel/warn_count", "/tmp/link"), 0);
+	EXPECT_EQ(attach_path("/tmp/link", false), -EINVAL);
+
+	fd = open("/sys/kernel/warn_count", O_RDONLY | O_CLOEXEC);
+	ASSERT_GE(fd, 0);
+	snprintf(path, sizeof(path), "/proc/self/fd/%d", fd);
+	EXPECT_EQ(attach_path(path, false), -EINVAL);
+	EXPECT_EQ(close(fd), 0);
+}
+
+TEST(special_file_backing_file)
+{
+	if (!can_use_loop())
+		SKIP(return, "loop devices unavailable");
+
+	ASSERT_EQ(setup_tmp(), 0);
+	ASSERT_EQ(mkfifo("/tmp/fifo", 0600), 0);
+
+	/* Only regular files and block devices are storage. */
+	EXPECT_EQ(attach_path("/tmp/fifo", true), -EINVAL);
+	EXPECT_EQ(attach_path("/dev/null", true), -EINVAL);
+}
+
+#define CONFIGFS_DIR "/sys/kernel/config"
+#define GADGET_DIR CONFIGFS_DIR "/usb_gadget/pseudo_backing_test"
+#define MASS_STORAGE_DIR GADGET_DIR "/functions/mass_storage.0"
+
+TEST(usb_mass_storage_backing_file)
+{
+	const char *path = "/sys/kernel/warn_count";
+	struct statfs sfs;
+	ssize_t ret;
+	int fd, err;
+
+	if (geteuid())
+		SKIP(return, "needs root");
+
+	/* Mounting configfs on top of itself fails with EBUSY. */
+	if (statfs(CONFIGFS_DIR, &sfs) || sfs.f_type != CONFIGFS_MAGIC) {
+		ASSERT_EQ(unshare(CLONE_NEWNS), 0);
+		ASSERT_EQ(mount(NULL, "/", NULL, MS_REC | MS_PRIVATE, NULL), 0);
+		if (mount("configfs", CONFIGFS_DIR, "configfs", 0, NULL))
+			SKIP(return, "no configfs: %s", strerror(errno));
+	}
+
+	if (mkdir(GADGET_DIR, 0755))
+		SKIP(return, "no usb gadget configfs: %s", strerror(errno));
+	if (mkdir(MASS_STORAGE_DIR, 0755)) {
+		err = errno;
+		rmdir(GADGET_DIR);
+		SKIP(return, "no usb mass storage function: %s", strerror(err));
+	}
+
+	/* Writing the path opens the LUN's backing file right away. */
+	fd = open(MASS_STORAGE_DIR "/lun.0/file", O_WRONLY | O_CLOEXEC);
+	EXPECT_GE(fd, 0);
+	if (fd >= 0) {
+		ret = write(fd, path, strlen(path));
+		err = errno;
+		EXPECT_EQ(ret, -1);
+		EXPECT_EQ(err, EINVAL);
+		EXPECT_EQ(close(fd), 0);
+	}
+
+	EXPECT_EQ(rmdir(MASS_STORAGE_DIR), 0);
+	EXPECT_EQ(rmdir(GADGET_DIR), 0);
+}
+
+/* Mounting configfs on top of itself fails with EBUSY. */
+static int setup_configfs(void)
+{
+	struct statfs sfs;
+
+	if (!statfs(CONFIGFS_DIR, &sfs) && sfs.f_type == CONFIGFS_MAGIC)
+		return 0;
+	if (mount("configfs", CONFIGFS_DIR, "configfs", 0, NULL))
+		return -errno;
+	return 0;
+}
+
+#define NVMET_SUBSYS_DIR CONFIGFS_DIR "/nvmet/subsystems/pseudo_backing_test"
+#define NVMET_NS_DIR NVMET_SUBSYS_DIR "/namespaces/1"
+
+static int nvmet_enable(const char *path)
+{
+	int ret;
+
+	ret = write_string(NVMET_NS_DIR "/device_path", path);
+	if (ret)
+		return ret;
+	ret = write_string(NVMET_NS_DIR "/enable", "1");
+	if (!ret)
+		ret = write_string(NVMET_NS_DIR "/enable", "0");
+	return ret;
+}
+
+TEST(nvmet_backing_file)
+{
+	char dev[PATH_MAX];
+	int lfd;
+
+	if (!can_use_loop())
+		SKIP(return, "loop devices unavailable");
+
+	ASSERT_EQ(setup_tmp(), 0);
+	if (setup_configfs())
+		SKIP(return, "no configfs");
+	if (mkdir(NVMET_SUBSYS_DIR, 0755))
+		SKIP(return, "no nvme target: %s", strerror(errno));
+	EXPECT_EQ(mkdir(NVMET_NS_DIR, 0755), 0);
+
+	/* With direct I/O most pseudo files already fail to open. */
+	EXPECT_EQ(write_string(NVMET_NS_DIR "/buffered_io", "1"), 0);
+
+	EXPECT_EQ(create_file("/tmp/file"), 0);
+	EXPECT_EQ(mkfifo("/tmp/fifo", 0600), 0);
+
+	lfd = create_loop_device(dev, sizeof(dev));
+	EXPECT_GE(lfd, 0);
+
+	/* With buffered_io the file backend handles block devices as well. */
+	EXPECT_EQ(nvmet_enable("/tmp/file"), 0);
+	if (lfd >= 0)
+		EXPECT_EQ(nvmet_enable(dev), 0);
+	EXPECT_EQ(nvmet_enable(PSEUDO_FILE), -EINVAL);
+	EXPECT_EQ(nvmet_enable("/tmp/fifo"), -EINVAL);
+	EXPECT_EQ(nvmet_enable("/dev/null"), -EINVAL);
+
+	if (lfd >= 0)
+		EXPECT_EQ(close(lfd), 0);
+	EXPECT_EQ(rmdir(NVMET_NS_DIR), 0);
+	EXPECT_EQ(rmdir(NVMET_SUBSYS_DIR), 0);
+}
+
+#define FILEIO_HBA_DIR CONFIGFS_DIR "/target/core/fileio_4711"
+#define FILEIO_DEV_DIR FILEIO_HBA_DIR "/pseudo_backing_test"
+#define FILEIO_PROT_TYPE FILEIO_DEV_DIR "/attrib/pi_prot_type"
+
+static int fileio_create(const char *path)
+{
+	char buf[PATH_MAX];
+	int ret;
+
+	if (mkdir(FILEIO_DEV_DIR, 0755))
+		return -errno;
+	snprintf(buf, sizeof(buf), "fd_dev_name=%s,fd_dev_size=1048576", path);
+	ret = write_string(FILEIO_DEV_DIR "/control", buf);
+	if (!ret)
+		ret = write_string(FILEIO_DEV_DIR "/enable", "1");
+	if (ret)
+		rmdir(FILEIO_DEV_DIR);
+	return ret;
+}
+
+static int fileio_enable(const char *path)
+{
+	int ret;
+
+	ret = fileio_create(path);
+	if (!ret)
+		rmdir(FILEIO_DEV_DIR);
+	return ret;
+}
+
+TEST(fileio_backing_file)
+{
+	char dev[PATH_MAX];
+	int lfd;
+
+	if (!can_use_loop())
+		SKIP(return, "loop devices unavailable");
+
+	ASSERT_EQ(setup_tmp(), 0);
+	if (setup_configfs())
+		SKIP(return, "no configfs");
+	if (mkdir(FILEIO_HBA_DIR, 0755))
+		SKIP(return, "no fileio backend: %s", strerror(errno));
+
+	EXPECT_EQ(create_file("/tmp/file"), 0);
+	EXPECT_EQ(mkfifo("/tmp/fifo", 0600), 0);
+
+	lfd = create_loop_device(dev, sizeof(dev));
+	EXPECT_GE(lfd, 0);
+
+	EXPECT_EQ(fileio_enable("/tmp/file"), 0);
+	if (lfd >= 0)
+		EXPECT_EQ(fileio_enable(dev), 0);
+	EXPECT_EQ(fileio_enable(PSEUDO_FILE), -EINVAL);
+	EXPECT_EQ(fileio_enable("/tmp/fifo"), -EINVAL);
+	EXPECT_EQ(fileio_enable("/dev/null"), -EINVAL);
+
+	if (lfd >= 0)
+		EXPECT_EQ(close(lfd), 0);
+	EXPECT_EQ(rmdir(FILEIO_HBA_DIR), 0);
+}
+
+TEST(fileio_protection_file)
+{
+	int ret;
+
+	if (geteuid())
+		SKIP(return, "needs root");
+
+	ASSERT_EQ(setup_tmp(), 0);
+	if (setup_configfs())
+		SKIP(return, "no configfs");
+	if (mkdir(FILEIO_HBA_DIR, 0755))
+		SKIP(return, "no fileio backend: %s", strerror(errno));
+
+	EXPECT_EQ(create_file("/tmp/file"), 0);
+	ret = fileio_create("/tmp/file");
+	EXPECT_EQ(ret, 0);
+	if (!ret) {
+		/* Turning on DIF opens the protection file. */
+		EXPECT_EQ(symlink(PSEUDO_FILE, "/tmp/file.protection"), 0);
+		EXPECT_EQ(write_string(FILEIO_PROT_TYPE, "1"), -EINVAL);
+		EXPECT_EQ(unlink("/tmp/file.protection"), 0);
+
+		EXPECT_EQ(mkfifo("/tmp/file.protection", 0600), 0);
+		EXPECT_EQ(write_string(FILEIO_PROT_TYPE, "1"), -EINVAL);
+		EXPECT_EQ(unlink("/tmp/file.protection"), 0);
+
+		EXPECT_EQ(write_string(FILEIO_PROT_TYPE, "1"), 0);
+		EXPECT_EQ(write_string(FILEIO_PROT_TYPE, "0"), 0);
+		EXPECT_EQ(rmdir(FILEIO_DEV_DIR), 0);
+	}
+
+	EXPECT_EQ(rmdir(FILEIO_HBA_DIR), 0);
+}
+
+#define ZLOOP_CTL "/dev/zloop-control"
+
+/* One conventional and two sequential zones in /tmp/@id. */
+static int zloop_add(int id)
+{
+	char buf[128];
+	int ret;
+
+	snprintf(buf, sizeof(buf),
+		 "add id=%d,base_dir=/tmp,capacity_mb=12,zone_size_mb=4,conv_zones=1,buffered_io",
+		 id);
+	ret = write_string(ZLOOP_CTL, buf);
+	if (!ret) {
+		snprintf(buf, sizeof(buf), "remove id=%d", id);
+		ret = write_string(ZLOOP_CTL, buf);
+	}
+	return ret;
+}
+
+TEST(zloop_zone_file)
+{
+	if (geteuid())
+		SKIP(return, "needs root");
+	if (access(ZLOOP_CTL, W_OK))
+		SKIP(return, "no zloop");
+
+	ASSERT_EQ(setup_tmp(), 0);
+
+	ASSERT_EQ(mkdir("/tmp/4711", 0755), 0);
+	EXPECT_EQ(zloop_add(4711), 0);
+
+	/* Zone files that already exist are used as they are. */
+	ASSERT_EQ(mkdir("/tmp/4712", 0755), 0);
+	ASSERT_EQ(symlink(PSEUDO_FILE, "/tmp/4712/seq-000001"), 0);
+	EXPECT_EQ(zloop_add(4712), -EINVAL);
+
+	ASSERT_EQ(mkdir("/tmp/4713", 0755), 0);
+	ASSERT_EQ(mkfifo("/tmp/4713/seq-000001", 0600), 0);
+	EXPECT_EQ(zloop_add(4713), -EINVAL);
+}
+
+TEST(erofs_backing_file)
+{
+	bool refused = false;
+	char buf[256];
+	int fsfd, ret, err;
+	ssize_t n;
+
+	if (geteuid())
+		SKIP(return, "needs root");
+
+	fsfd = sys_fsopen("erofs", FSOPEN_CLOEXEC);
+	if (fsfd < 0)
+		SKIP(return, "no erofs: %s", strerror(errno));
+
+	ASSERT_EQ(sys_fsconfig(fsfd, FSCONFIG_SET_STRING, "source",
+			       "/sys/kernel/warn_count", 0), 0);
+	ret = sys_fsconfig(fsfd, FSCONFIG_CMD_CREATE, NULL, NULL, 0);
+	err = errno;
+	if (ret && err == ENOTBLK) {
+		close(fsfd);
+		SKIP(return, "no file-backed erofs mounts");
+	}
+	ASSERT_EQ(ret, -1);
+	ASSERT_EQ(err, EINVAL);
+
+	/*
+	 * Something that isn't an erofs image fails with EINVAL as well so
+	 * check that the source itself was refused.
+	 */
+	while ((n = read(fsfd, buf, sizeof(buf) - 1)) > 0) {
+		buf[n] = '\0';
+		if (strstr(buf, "backing file"))
+			refused = true;
+	}
+	EXPECT_TRUE(refused);
+	EXPECT_EQ(close(fsfd), 0);
+}
+
+TEST_HARNESS_MAIN

-- 
2.53.0

