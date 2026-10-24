Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792838339;
	b=Ckgilsuxxg8z5n7i2VM4DosjfLG5etjCYfml2o1n36PYwvTPvNFgIq4b/xxhwSRVWzh3
	 ERxqJPysMxa8I6UbcPFU3gUtqW2Tn5ru+zqJu2UJLA3hPmiN6jlQItD1xDxR+NLVtneCR
	 /51IzqXggihwyGNXbYQv2+Cep2iC0D8Skgo6+YBp8tigmoqb0L+Dm3Ac+DW4bDwalBsaN
	 gquj7skGI5LujIItGCJ5yDLzHdIhmlDvaf9XAuCUfeMpLkZL3IqCuJUmrmu5JAiX1ZFuq
	 hysBiW9VgTNRGdzR6oxs5ZhSgeI+xgIFOsoOIxsApMFFqsnAiTymf4JC1gpWauUqjjA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792838339;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=aKsV5UoY36/Ov6bUxmA2+A8FEK5UCURxr90KKYuXoE4=;
	b=lmsjBKZ7S9qkvQyAyugyC4K+qjT3HlG3b8AQ+cV6slzy1vyK786yzBTcbiapqZ/s1iA8
	 u8bDSHBOdP+YU2s+fWzQ0pOAhVwaaF+2g8bHbNw52q9MOnN7zqaCZkxwcSPDQN1XlXn9E
	 OMBaxKH4OvRUW7GQfoInulClHWhwyeUPIzQ8tQYYUq6WTmTKJAVLU9RfACxOaXcHd5wG2
	 jeEtijeGYql5r6zIJLKzhpdDU2KE7nDF+cD8T88cRFKn3DeWIs04XfodPwaHJVg8PP2bd
	 1Swef8DNESCl5W2KIm3dweiClQCcvJMsmvWe3QGAHrwmu0xxMwwp2H92Ro56m5rXGtQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hRw1b7eb;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DCA1F606A321;
	Sat, 24 Oct 2026 10:38:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hRw1b7eb
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EA4AD1F01825;
	Sat, 24 Oct 2026 10:38:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792838338;
	bh=aKsV5UoY36/Ov6bUxmA2+A8FEK5UCURxr90KKYuXoE4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hRw1b7eb48fPA8C51wMXs1/N1OO76hZTW5G7uGebxIKlpdR6V2WoSIuMKAeUg/Q2L
	 da4w/4o/mXjvNudKnp/QYW7e4CPnj6BCs7vF2gh05TD6vrTiuuF1/UfB9Cih+OcVIS
	 H24qGhT/WmYay+x+WQ0zaHhpWXjK8c99UhXaV/dsNbCRePSBzHEVlSoIMWhEh9iU0L
	 NkhoXf2DsoNbfGg9/3DwbiFzJDcOGYTw3gplNHuGrq5mh6+rPVf/cfFpfy7LVs1Rnf
	 YH3ShZj+guJZlDBJvB2mXpjcUAVVhu5KpCdfu1so3u7StPmasHzPU4Mluz0A7NYoKj
	 p1c/6D1FQ9n0Q==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 24 Oct 2026 12:38:33 +0200
Subject: [PATCH 7/7] selftests/proc: test which entries can't be
 mountpoints
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
Message-Id: <20261024-work-procfs-fixes-v1-7-46b03c3a8fac@kernel.org>
References: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
In-Reply-To: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, 
 Aleksa Sarai <cyphar@cyphar.com>, Chris Mason <mason@kernel.org>, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=5560; i=brauner@kernel.org;
 h=from:subject:message-id; bh=cRXTA+r+4IRbQumKHnKzi0P+onITLsuXyi/JuGCYSGk=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWTd6Vr/+mCUtFNNWfqsywtXVT7b3HrQyNwukf3JriN+3
 77c7j7A0FHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjAR2+mMDHu2SxuEck9M+qwz
 +3bGDR+HmuR1BUwP/y5W9ZvhXjbbtJWR4UalsZbqDpEV+9+cv3d+Ztz6Nxov+zXWSAeunb2cS2i
 NBAcA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Check that nothing can be mounted on:

- /proc/self, /proc/thread-self, /proc/mounts and /proc/net themselves
- the entries below /proc/<pid>/net
- the entries below /proc/<pid>/fd and /proc/<pid>/fdinfo

Mounting through /proc/mounts still works and lands on the entry of the
caller.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 tools/testing/selftests/proc/.gitignore         |   1 +
 tools/testing/selftests/proc/Makefile           |   1 +
 tools/testing/selftests/proc/proc-unmountable.c | 150 ++++++++++++++++++++++++
 3 files changed, 152 insertions(+)

diff --git a/tools/testing/selftests/proc/.gitignore b/tools/testing/selftests/proc/.gitignore
index 9c9735570abf..1dd43799ec45 100644
--- a/tools/testing/selftests/proc/.gitignore
+++ b/tools/testing/selftests/proc/.gitignore
@@ -20,6 +20,7 @@
 /proc-uptime-001
 /proc-uptime-002
 /proc-pidns
+/proc-unmountable
 /read
 /self
 /setns-dcache
diff --git a/tools/testing/selftests/proc/Makefile b/tools/testing/selftests/proc/Makefile
index a7de2bb6d8be..49afe08daebe 100644
--- a/tools/testing/selftests/proc/Makefile
+++ b/tools/testing/selftests/proc/Makefile
@@ -30,5 +30,6 @@ TEST_GEN_PROGS += thread-self
 TEST_GEN_PROGS += proc-multiple-procfs
 TEST_GEN_PROGS += proc-fsconfig-hidepid
 TEST_GEN_PROGS += proc-pidns
+TEST_GEN_PROGS += proc-unmountable
 
 include ../lib.mk
diff --git a/tools/testing/selftests/proc/proc-unmountable.c b/tools/testing/selftests/proc/proc-unmountable.c
new file mode 100644
index 000000000000..a1282927cfff
--- /dev/null
+++ b/tools/testing/selftests/proc/proc-unmountable.c
@@ -0,0 +1,150 @@
+// SPDX-License-Identifier: GPL-2.0
+/* The entries in /proc that can't be mountpoints. */
+
+#ifndef _GNU_SOURCE
+#define _GNU_SOURCE
+#endif
+#include <errno.h>
+#include <fcntl.h>
+#include <limits.h>
+#include <sched.h>
+#include <stdio.h>
+#include <sys/mount.h>
+#include <sys/stat.h>
+#include <sys/syscall.h>
+#include <unistd.h>
+
+#include "kselftest_harness.h"
+
+#ifndef OPEN_TREE_CLONE
+#define OPEN_TREE_CLONE 1
+#endif
+
+#ifndef MOVE_MOUNT_F_EMPTY_PATH
+#define MOVE_MOUNT_F_EMPTY_PATH 0x00000004
+#endif
+
+#ifndef MOVE_MOUNT_T_EMPTY_PATH
+#define MOVE_MOUNT_T_EMPTY_PATH 0x00000040
+#endif
+
+#ifndef __NR_open_tree
+#define __NR_open_tree 428
+#endif
+
+#ifndef __NR_move_mount
+#define __NR_move_mount 429
+#endif
+
+static int sys_open_tree(int dfd, const char *path, unsigned int flags)
+{
+	return syscall(__NR_open_tree, dfd, path, flags);
+}
+
+static int sys_move_mount(int from_dfd, const char *from_path, int to_dfd,
+			  const char *to_path, unsigned int flags)
+{
+	return syscall(__NR_move_mount, from_dfd, from_path, to_dfd, to_path,
+		       flags);
+}
+
+/* Mount a bind of /dev/null right on the object @fd refers to. */
+static int move_mount_null(int fd)
+{
+	int fd_tree, ret;
+
+	fd_tree = sys_open_tree(AT_FDCWD, "/dev/null", OPEN_TREE_CLONE);
+	if (fd_tree < 0)
+		return -1;
+	ret = sys_move_mount(fd_tree, "", fd, "",
+			     MOVE_MOUNT_F_EMPTY_PATH | MOVE_MOUNT_T_EMPTY_PATH);
+	close(fd_tree);
+	return ret;
+}
+
+FIXTURE(unmountable) {
+	char path[PATH_MAX];
+};
+
+FIXTURE_SETUP(unmountable)
+{
+	if (geteuid())
+		SKIP(return, "mounting needs root");
+
+	ASSERT_EQ(unshare(CLONE_NEWNS), 0);
+	ASSERT_EQ(mount(NULL, "/", NULL, MS_PRIVATE | MS_REC, NULL), 0);
+}
+
+FIXTURE_TEARDOWN(unmountable)
+{
+}
+
+/* Nothing may be mounted on a link into /proc/self itself. */
+TEST_F(unmountable, self_links)
+{
+	static const char *const links[] = {
+		"/proc/self", "/proc/thread-self", "/proc/mounts", "/proc/net",
+	};
+
+	for (size_t i = 0; i < ARRAY_SIZE(links); i++) {
+		int fd;
+
+		fd = open(links[i], O_PATH | O_NOFOLLOW | O_CLOEXEC);
+		/* /proc/net needs CONFIG_NET */
+		if (fd < 0 && errno == ENOENT)
+			continue;
+		ASSERT_GE(fd, 0);
+		EXPECT_EQ(move_mount_null(fd), -1) {
+			TH_LOG("mounted on %s", links[i]);
+		}
+		EXPECT_EQ(errno, ENOENT);
+		close(fd);
+	}
+}
+
+/* Mounting through a link into /proc/self lands on the entry of the caller. */
+TEST_F(unmountable, through_links)
+{
+	struct stat st;
+
+	ASSERT_EQ(mount("/dev/null", "/proc/mounts", NULL, MS_BIND, NULL), 0);
+	/* the caller's /proc/<pid>/mounts is covered */
+	ASSERT_EQ(stat("/proc/self/mounts", &st), 0);
+	EXPECT_TRUE(S_ISCHR(st.st_mode));
+	/* the link itself is not */
+	ASSERT_EQ(lstat("/proc/mounts", &st), 0);
+	EXPECT_TRUE(S_ISLNK(st.st_mode));
+}
+
+/* The entries below /proc/<pid>/net take no mount. */
+TEST_F(unmountable, net_entries)
+{
+	if (access("/proc/self/net/dev", F_OK))
+		SKIP(return, "needs CONFIG_NET");
+
+	ASSERT_EQ(mount("/dev/null", "/proc/self/net/dev", NULL, MS_BIND, NULL), -1);
+	ASSERT_EQ(errno, ENOENT);
+}
+
+/* Neither do the entries below /proc/<pid>/fd and /proc/<pid>/fdinfo. */
+TEST_F(unmountable, fd_entries)
+{
+	int fd, fd_link;
+
+	fd = open("/dev/null", O_RDONLY | O_CLOEXEC);
+	ASSERT_GE(fd, 0);
+
+	snprintf(self->path, sizeof(self->path), "/proc/self/fd/%d", fd);
+	fd_link = open(self->path, O_PATH | O_NOFOLLOW | O_CLOEXEC);
+	ASSERT_GE(fd_link, 0);
+	EXPECT_EQ(move_mount_null(fd_link), -1);
+	EXPECT_EQ(errno, ENOENT);
+	close(fd_link);
+
+	snprintf(self->path, sizeof(self->path), "/proc/self/fdinfo/%d", fd);
+	EXPECT_EQ(mount("/dev/null", self->path, NULL, MS_BIND, NULL), -1);
+	EXPECT_EQ(errno, ENOENT);
+	close(fd);
+}
+
+TEST_HARNESS_MAIN

-- 
2.53.0

