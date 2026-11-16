Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827418;
	b=jwGxuw4d2JQZkdNSv+r1A0Kkm2hWBMR3t0W22WZTOO8zDSwln3Spmuzge42d6pF+V2wW
	 A5gylt2thvaODO0W1RU/MpUof0KFUWowX+vyXPYebyFoPLXk5WNk7M843SD3xbZAPL/aa
	 ip0oVGhS/KCw5cMuj/aqvgKmE7NAmCmfVtyIv0yaxlaRZtO2VwUojlApJd6ATWJ1JgMsQ
	 oXyeOqFiDfOlsBGN4CM40bMTUJ3guADG+Y9CacMN39YemaUQctb4bhATr2//8IV89HfFv
	 xhuv07pmyxorkcgHIbMbL6UFOTWw6UE+7ZcENhMm+srMEexw8hWVmGHv+n5tql3UjTQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827418;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=AMxV5fDFlTE8OAKC1riUjdbxNUfnGfJUWLINJ0DSOYU=;
	b=LuhvsNwkT7j/OLAvriU+z7L8yLw2HTVU7pkCVBWBbk9dGQNv2xCaSM1mQoK3fPg4jzkx
	 05M/+uQBZTY+PHQJ2KZd0BAPMm7tqj61exfkh2zgiRr1xFCeHBphXyAmpsdAZQq2xle0r
	 c9qeCMvjR5euHnzC0eCR/HkVlZ5v7QJC3WgOgr7mQRadOioUrtimziEd7Xcc9XWsQhXtk
	 e28DWHch/InJmvaffkIImV1fF0+g5+4HYmSgJYuO0t3CKzGhqIyWQVArsp1fKXDrQFpaQ
	 kM7EmuTGdOZPGfIqMX5dAzZqIf7XHjiLWJ4hQmD639DjKsfgLLB6ClGFJPL0WvtlCRA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QNisDWf7;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2BE656081186;
	Mon, 16 Nov 2026 11:10:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QNisDWf7
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4E6C51F000C6;
	Mon, 16 Nov 2026 11:10:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827417;
	bh=AMxV5fDFlTE8OAKC1riUjdbxNUfnGfJUWLINJ0DSOYU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=QNisDWf7U3h663SyoRV0uxWbOVyLtGNDCxOalmGb2Oy1P+x3yPzMj9NJ8VjnhaIgT
	 qFDnHLurOuTPsUtv0TnbCEh8CcE8J2YoDDqRxBvPi3b+0t34sV2ZdQ8WcBJFQAzW01
	 dZV/hUpqsrYSFkjkxKEMYRXKXDlMGRSVBAFcDSt0ZpAWonzunAmi6+H0IT7dCmHDOv
	 Q2tBNYIqTL3Wj8Lpy3eAb86aT5io7YVR2DHh83QvVZ1oViOXs+zhpN9+3TBnhkmBpP
	 P5uSY+0IieOD78GEeEis0B8qJFz0aqRqI7v0WUd9WPnDMgp4QpBzej9YDHKTMsq6SM
	 NnKmRaKURUOpw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:05:07 +0100
Subject: [PATCH RFC v3 34/44] selftests/ovl: test data-only layers on
 pseudo filesystems
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
Message-Id: <20261116-work-loop-pseudo-v3-34-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
In-Reply-To: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=5266; i=brauner@kernel.org;
 h=from:subject:message-id; bh=RU/dYDB+jdMMzNMeo0U5oo6JSftdyfWqQOmLqwIlGOg=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9etzGd2ObhO1hy2rNxbOC9s22uNMhOfPpjadPOhLub
 jlkHKla0VHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRCYKMDFM/BeYEvN8w4/c0
 41kSN3JS3x/VP/Wr6sTU13ffvhGcvfchI8P17p+CIg2c/FPY556OFjotvWWz6DTee+d3yU1wCJc
 /mcsEAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Add tests that overlayfs refuses data-only layers on pseudo filesystems:

- sysfs and procfs via the "::" separator in "lowerdir="
- sysfs and procfs via "datadir+" by path
- sysfs and procfs via "datadir+" by file descriptor
- tmpfs as data-only layer
- sysfs as regular lower layer

The last two must keep mounting.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 .../selftests/filesystems/overlayfs/.gitignore     |   1 +
 .../selftests/filesystems/overlayfs/Makefile       |   1 +
 .../filesystems/overlayfs/pseudo_datadir.c         | 131 +++++++++++++++++++++
 3 files changed, 133 insertions(+)

diff --git a/tools/testing/selftests/filesystems/overlayfs/.gitignore b/tools/testing/selftests/filesystems/overlayfs/.gitignore
index b343cc430051d..e1410fee2269d 100644
--- a/tools/testing/selftests/filesystems/overlayfs/.gitignore
+++ b/tools/testing/selftests/filesystems/overlayfs/.gitignore
@@ -3,3 +3,4 @@ dev_in_maps
 set_layers_via_fds
 idmapped_mounts
 automount_in_layer
+pseudo_datadir
diff --git a/tools/testing/selftests/filesystems/overlayfs/Makefile b/tools/testing/selftests/filesystems/overlayfs/Makefile
index 382a59bda5e70..ace75f5627e0f 100644
--- a/tools/testing/selftests/filesystems/overlayfs/Makefile
+++ b/tools/testing/selftests/filesystems/overlayfs/Makefile
@@ -10,6 +10,7 @@ TEST_GEN_PROGS := dev_in_maps
 TEST_GEN_PROGS += set_layers_via_fds
 TEST_GEN_PROGS += idmapped_mounts
 TEST_GEN_PROGS += automount_in_layer
+TEST_GEN_PROGS += pseudo_datadir
 
 include ../../lib.mk
 
diff --git a/tools/testing/selftests/filesystems/overlayfs/pseudo_datadir.c b/tools/testing/selftests/filesystems/overlayfs/pseudo_datadir.c
new file mode 100644
index 0000000000000..3b59fd3e9f5c2
--- /dev/null
+++ b/tools/testing/selftests/filesystems/overlayfs/pseudo_datadir.c
@@ -0,0 +1,131 @@
+// SPDX-License-Identifier: GPL-2.0
+#define _GNU_SOURCE
+
+#include <errno.h>
+#include <fcntl.h>
+#include <sched.h>
+#include <stdbool.h>
+#include <stdio.h>
+#include <sys/mount.h>
+#include <sys/stat.h>
+#include <unistd.h>
+
+#include "kselftest_harness.h"
+#include "../wrappers.h"
+
+static int setup_tmp(void)
+{
+	if (unshare(CLONE_NEWNS))
+		return -errno;
+	if (sys_mount(NULL, "/", NULL, MS_REC | MS_PRIVATE, NULL))
+		return -errno;
+	if (sys_mount("tmpfs", "/tmp", "tmpfs", 0, NULL))
+		return -errno;
+	if (mkdir("/tmp/lower", 0755) || mkdir("/tmp/data", 0755) ||
+	    mkdir("/tmp/merged", 0755))
+		return -errno;
+	return 0;
+}
+
+/* Mount an overlayfs with the legacy "lowerdir=" option. */
+static int mount_lowerdir(const char *lowerdir)
+{
+	char opts[256];
+
+	snprintf(opts, sizeof(opts), "lowerdir=%s", lowerdir);
+	if (sys_mount("overlay", "/tmp/merged", "overlay", MS_RDONLY, opts))
+		return -errno;
+	if (umount2("/tmp/merged", 0))
+		return -errno;
+	return 0;
+}
+
+static int set_layer(int fd_context, const char *key, const char *path,
+		     bool by_fd)
+{
+	int fd, ret = 0;
+
+	if (!by_fd) {
+		if (sys_fsconfig(fd_context, FSCONFIG_SET_STRING, key, path, 0))
+			return -errno;
+		return 0;
+	}
+
+	fd = open(path, O_DIRECTORY | O_CLOEXEC);
+	if (fd < 0)
+		return -errno;
+	if (sys_fsconfig(fd_context, FSCONFIG_SET_FD, key, NULL, fd))
+		ret = -errno;
+	close(fd);
+	return ret;
+}
+
+/* Create an overlayfs with "lowerdir+" and "datadir+" through fsconfig. */
+static int fsmount_layers(const char *lower, const char *data, bool by_fd)
+{
+	int fd_context, fd_mnt, ret;
+
+	fd_context = sys_fsopen("overlay", FSOPEN_CLOEXEC);
+	if (fd_context < 0)
+		return -errno;
+
+	ret = set_layer(fd_context, "lowerdir+", lower, by_fd);
+	if (ret)
+		goto out;
+	ret = set_layer(fd_context, "datadir+", data, by_fd);
+	if (ret)
+		goto out;
+
+	if (sys_fsconfig(fd_context, FSCONFIG_CMD_CREATE, NULL, NULL, 0)) {
+		ret = -errno;
+		goto out;
+	}
+
+	fd_mnt = sys_fsmount(fd_context, FSMOUNT_CLOEXEC, 0);
+	if (fd_mnt < 0)
+		ret = -errno;
+	else
+		close(fd_mnt);
+out:
+	close(fd_context);
+	return ret;
+}
+
+TEST(datadir_sysfs)
+{
+	ASSERT_EQ(setup_tmp(), 0);
+
+	EXPECT_EQ(mount_lowerdir("/tmp/lower::/sys/kernel"), -EINVAL);
+	EXPECT_EQ(fsmount_layers("/tmp/lower", "/sys/kernel", false), -EINVAL);
+	EXPECT_EQ(fsmount_layers("/tmp/lower", "/sys/kernel", true), -EINVAL);
+}
+
+TEST(datadir_procfs)
+{
+	ASSERT_EQ(setup_tmp(), 0);
+
+	EXPECT_EQ(mount_lowerdir("/tmp/lower::/proc"), -EINVAL);
+	EXPECT_EQ(fsmount_layers("/tmp/lower", "/proc", false), -EINVAL);
+	EXPECT_EQ(fsmount_layers("/tmp/lower", "/proc", true), -EINVAL);
+}
+
+TEST(datadir_tmpfs)
+{
+	ASSERT_EQ(setup_tmp(), 0);
+
+	EXPECT_EQ(mount_lowerdir("/tmp/lower::/tmp/data"), 0);
+	EXPECT_EQ(fsmount_layers("/tmp/lower", "/tmp/data", false), 0);
+	EXPECT_EQ(fsmount_layers("/tmp/lower", "/tmp/data", true), 0);
+}
+
+TEST(lowerdir_sysfs)
+{
+	ASSERT_EQ(setup_tmp(), 0);
+
+	EXPECT_EQ(mount_lowerdir("/sys/kernel:/tmp/lower"), 0);
+	EXPECT_EQ(mount_lowerdir("/sys/kernel::/tmp/data"), 0);
+	EXPECT_EQ(fsmount_layers("/sys/kernel", "/tmp/data", false), 0);
+	EXPECT_EQ(fsmount_layers("/sys/kernel", "/tmp/data", true), 0);
+}
+
+TEST_HARNESS_MAIN

-- 
2.53.0

